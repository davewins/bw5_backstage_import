#!/bin/bash

# --- 1. Configuration ---
EAR_DIR="./ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
IMPORT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- 2. Argument Parsing ---
PUSH_TO_GITHUB=false
VERBOSE=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --push) PUSH_TO_GITHUB=true ;;
        --verbose) VERBOSE=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# --- 3. Pre-flight Checks ---
[[ -z "$TRA_HOME" ]] && { echo "❌ ERROR: TRA_HOME not set."; exit 1; }
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
APPMANAGE_TRA="${APPMANAGE_BIN}.tra"

if [ "$PUSH_TO_GITHUB" = true ]; then
    [[ -z "$GITHUB_USER" || -z "$GITHUB_TOKEN" || -z "$GITHUB_REPO" ]] && { echo "❌ ERROR: GitHub credentials missing."; exit 1; }
fi

# Workspace Setup
shopt -s nullglob
mkdir -p "$APPS_DIR" "$RES_DIR"
rm -f "$APPS_DIR"/*.yaml
TMP_DB_LIST="/tmp/db_unique.txt"
TMP_JMS_LIST="/tmp/jms_unique.txt"
> "$TMP_DB_LIST"
> "$TMP_JMS_LIST"

# Initialize Index
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-global-inventory
spec:
  targets:
    - ./resources/discovered-infrastructure.yaml" > "$REPO_DIR/catalog-info.yaml"

# --- 4. Loop ---
echo "🚀 Starting Secure Deep Inventory Scan..."

for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    [[ "$VERBOSE" == "true" ]] && echo "▶️  Processing: $filename"
    
    XML_FILE="/tmp/${clean_name}_config.xml"
    "$APPMANAGE_BIN" --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1
    [[ ! -f "$XML_FILE" ]] && { echo "   ❌ AppManage failed for $filename"; continue; }

    # --- A. FT & Scale Detection ---
    IS_FT=$(grep -oP '(?<=<isFt>).*?(?=</isFt>)' "$XML_FILE" | head -1 || echo "false")
    
    # --- B. Process Extraction (Preserving Paths) ---
    PROCESS_SUMMARY_FILE="/tmp/${clean_name}_procs.txt"
    > "$PROCESS_SUMMARY_FILE"
    grep -n "<bwprocess " "$XML_FILE" | while IFS=: read -r line_num line_content; do
        P_PATH=$(echo "$line_content" | grep -oP '(?<=name=").*?(?=")')
        P_BLOCK=$(tail -n +$line_num "$XML_FILE" | head -n 12)
        P_STARTER=$(echo "$P_BLOCK" | grep -oP '(?<=<starter>).*?(?=</starter>)' | head -1)
        P_MAX=$(echo "$P_BLOCK" | grep -oP '(?<=<maxJob>).*?(?=</maxJob>)' | head -1)
        P_FLOW=$(echo "$P_BLOCK" | grep -oP '(?<=<flowLimit>).*?(?=</flowLimit>)' | head -1)
        
        [[ "$P_MAX" -gt 0 || "$P_FLOW" -gt 0 ]] && touch "/tmp/${clean_name}_scale_flag"
        echo "- ${P_PATH} [Starter: ${P_STARTER} | Max: ${P_MAX} | Flow: ${P_FLOW}]" >> "$PROCESS_SUMMARY_FILE"
    done

    # --- C. Secure Global Variable Extraction ---
    GV_SUMMARY_FILE="/tmp/${clean_name}_gv.txt"
    > "$GV_SUMMARY_FILE"
    # Isolate Global Variables block, pair name/value, then filter out passwords
    sed -n '/name="Global Variables"/,/<\/NVPairs>/p' "$XML_FILE" | \
    grep -E "<name>|<value>" | \
    sed 'N;s/<name>\(.*\)<\/name>.*\n.*<value>\(.*\)<\/value>/\1: "\2"/' | \
    grep -vE "Password|#!|Modulus|PrivateExponent" | \
    sed 's/^/- /' >> "$GV_SUMMARY_FILE"

    # --- D. YAML Generation ---
    TAGS="[\"bw5-imported\""
    [[ -f "/tmp/${clean_name}_scale_flag" ]] && { TAGS+=", \"high-concurrency\""; rm "/tmp/${clean_name}_scale_flag"; }
    [[ "$IS_FT" == "true" ]] && TAGS+=", \"fault-tolerant\""
    TAGS+="]"

    F_PROCS=$(sed 's/^/    /' "$PROCESS_SUMMARY_FILE")
    F_GVS=$(sed 's/^/    /' "$GV_SUMMARY_FILE")

    cat <<EOF > "$APPS_DIR/$clean_name.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  description: |
    TIBCO BW5 Service: $app_name
    
    Processes:
$F_PROCS
    
    Global Variables (Non-Sensitive):
$F_GVS
  annotations:
    tibco.com/is-fault-tolerant: "$IS_FT"
    backstage.io/imported-at: "$IMPORT_TIME"
  tags: $TAGS
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-admins
  dependsOn:
EOF

    # Infrastructure discovery
    grep -oP '(jdbc|tcp|ssl|aaa|ldap|tibjmsnaming)://[^<]+' "$XML_FILE" | sort -u | while read -r url; do
        prefix="endpoint"
        [[ "$url" == jdbc* ]] && prefix="db"
        res_id="${prefix}-$(echo "$url" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        [[ "$prefix" == "db" ]] && echo "$res_id|$url" >> "$TMP_DB_LIST" || echo "$res_id|$url" >> "$TMP_JMS_LIST"
    done

    echo "    - ./apps/$clean_name.yaml" >> "$REPO_DIR/catalog-info.yaml"
    rm -f "$XML_FILE" "$PROCESS_SUMMARY_FILE" "$GV_SUMMARY_FILE"
done

# --- 5. Infrastructure Resource Generation ---
{
  echo "# Discovered Infrastructure via EAR Batch Scan"
  [[ -s "$TMP_DB_LIST" ]] && sort -u "$TMP_DB_LIST" | while IFS='|' read -r id url; do
    echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JDBC: $url\"\nspec:\n  type: database\n  owner: group:default/infrastructure-team"
  done
  [[ -s "$TMP_JMS_LIST" ]] && sort -u "$TMP_JMS_LIST" | while IFS='|' read -r id url; do
    echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"Endpoint: $url\"\nspec:\n  type: endpoint\n  owner: group:default/infrastructure-team"
  done
} > "$RES_DIR/discovered-infrastructure.yaml"

# --- 6. GitHub Logic ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo "🌐 Checking GitHub Repository..."
    REPO_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO")
    [[ "$REPO_CHECK" -ne 200 ]] && curl -s -H "Authorization: token $GITHUB_TOKEN" -d "{\"name\":\"$GITHUB_REPO\", \"private\":true}" "https://api.github.com/user/repos"

    pushd "$REPO_DIR" > /dev/null
    echo -ne "*\n!*/\n!*.yaml\n!catalog-info.yaml\n!.gitignore" > .gitignore
    AUTH_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    [[ ! -d ".git" ]] && git init && git remote add origin "$AUTH_URL" && git branch -M main
    git add .
    git commit -m "Registry Sync: $IMPORT_TIME"
    git push -u origin main
    popd > /dev/null
    echo "✨ Registry Updated on GitHub."
fi
