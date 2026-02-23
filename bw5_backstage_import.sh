#!/bin/bash

# --- 1. Settings ---
PUSH_TO_GITHUB=false
EAR_DIR="./ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
IMPORT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- 2. Checks ---
[[ -z "$TRA_HOME" ]] && { echo "❌ TRA_HOME not set."; exit 1; }
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
APPMANAGE_TRA="${APPMANAGE_BIN}.tra"

shopt -s nullglob
mkdir -p "$APPS_DIR" "$RES_DIR"
rm -f "$APPS_DIR"/*.yaml
TMP_DB_LIST="/tmp/db_unique.txt"
TMP_JMS_LIST="/tmp/jms_unique.txt"
> "$TMP_DB_LIST"
> "$TMP_JMS_LIST"

# Initialize Root Index
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-global-inventory
spec:
  targets:
    - ./resources/discovered-infrastructure.yaml" > "$REPO_DIR/catalog-info.yaml"

# --- 3. The Extraction Loop ---
for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    echo "▶️ Deep Scanning: $filename"
    XML_FILE="/tmp/${clean_name}_config.xml"
    $APPMANAGE_BIN --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1

    if [[ ! -f "$XML_FILE" ]]; then continue; fi

    # --- NEW: Process Anatomy Extraction ---
    # Extract Fault Tolerance status
    IS_FT=$(grep -oP '(?<=<isFt>).*?(?=</isFt>)' "$XML_FILE" || echo "false")
    
    # Parse the list of processes and their starters/limits
    # This block uses a small loop to find every process entry in the XML
    PROCESS_SUMMARY=""
    while read -r line; do
        # Extract name, remove path (e.g. Processes/), and remove .process extension
        P_NAME=$(echo "$line" | grep -oP '(?<=name=").*?(?=")' | sed 's|.*/||; s/\.process//')
        
        # Look ahead for the starter type and limits for this specific process
        # This finds the block following the process name match
        P_BLOCK=$(sed -n "/name=\".*${P_NAME}.process\"/,/<\/bwprocess>/p" "$XML_FILE")
        P_STARTER=$(echo "$P_BLOCK" | grep -oP '(?<=<starter>).*?(?=</starter>)' | head -1)
        P_MAX=$(echo "$P_BLOCK" | grep -oP '(?<=<maxJob>).*?(?=</maxJob>)' | head -1)
        P_FLOW=$(echo "$P_BLOCK" | grep -oP '(?<=<flowLimit>).*?(?=</flowLimit>)' | head -1)
        
        PROCESS_SUMMARY+="- ${P_NAME} (Starter: ${P_STARTER}, Max: ${P_MAX}, Flow: ${P_FLOW})\n"
    done < <(grep "<bwprocess " "$XML_FILE")

    # --- Generate YAML ---
    cat <<EOF > "$APPS_DIR/$clean_name.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  description: |
    BW5 Service: $app_name
    Fault Tolerant: $IS_FT
    Processes:
    $(echo -e "$PROCESS_SUMMARY")
  annotations:
    tibco.com/is-fault-tolerant: "$IS_FT"
    backstage.io/imported-at: "$IMPORT_TIME"
  tags: ["bw5-imported"]
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-admins
  dependsOn:
EOF

    # Infrastructure discovery (JDBC/JMS)
    dbs=$(grep -oP 'jdbc:[^<]+' "$XML_FILE" | sort -u)
    for d in $dbs; do
        res_id="db-$(echo "$d" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        echo "$res_id|$d" >> "$TMP_DB_LIST"
    done
    
    jms=$(grep -oP '(tibjmsnaming|tcp|ssl)://[^<]+' "$XML_FILE" | sort -u)
    for j in $jms; do
        res_id="jms-$(echo "$j" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        echo "$res_id|$j" >> "$TMP_JMS_LIST"
    done

    echo "    - ./apps/$clean_name.yaml" >> "$REPO_DIR/catalog-info.yaml"
    rm -f "$XML_FILE"
done

# --- 4. Finalize Infrastructure ---
echo "🏗️  Finalizing Infrastructure Map..."
{
  echo "# Discovered Infrastructure via EAR Batch Scan"
  if [[ -s "$TMP_DB_LIST" || -s "$TMP_JMS_LIST" ]]; then
      sort -u "$TMP_DB_LIST" | while IFS='|' read -r id url; do
        echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JDBC: $url\"\nspec:\n  type: database\n  owner: group:default/infrastructure-team"
      done
      sort -u "$TMP_JMS_LIST" | while IFS='|' read -r id url; do
        echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JMS: $url\"\nspec:\n  type: messaging-server\n  owner: group:default/messaging-team"
      done
  fi
} > "$RES_DIR/discovered-infrastructure.yaml"

# --- 5. GitHub Registry Push ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo "🚀 Checking if GitHub Registry exists..."

    # 1. Use GitHub API to check if repo exists; if not, create it
    REPO_STATUS=$(curl -o /dev/null -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
                  "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO")

    if [ "$REPO_STATUS" -ne 200 ]; then
        echo "📂 Repository not found. Creating $GITHUB_REPO on GitHub..."
        curl -H "Authorization: token $GITHUB_TOKEN" \
             -d "{\"name\":\"$GITHUB_REPO\", \"private\":true, \"description\":\"BW5 Registry for TIBCO Developer Hub\"}" \
             "https://api.github.com/user/repos"
    fi

    echo "🚀 Syncing Registry to GitHub..."
    pushd "$REPO_DIR" > /dev/null


    # Ensure a local registry .gitignore exists
    echo -e "*\n!*/\n!*.yaml\n!catalog-info.yaml\n!.gitignore" > .gitignore
    AUTH_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    [ ! -d ".git" ] && git init && git remote add origin "$AUTH_URL" && git branch -M main
    git add .
    git commit -m "Registry Sync: $IMPORT_TIME"
    git push -u origin main
    popd > /dev/null
fi

echo "💾 Process finished. Check $REPO_DIR"
