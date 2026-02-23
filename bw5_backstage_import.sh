#!/bin/bash

# --- 1. Settings & Toggles ---
PUSH_TO_GITHUB=true
EAR_DIR="./ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
IMPORT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- 2. Pre-flight Checks ---
[[ -z "$TRA_HOME" ]] && { echo "❌ ERROR: TRA_HOME not set."; exit 1; }
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
echo "🚀 Starting Deep Scan Import..."

for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    echo "▶️ Processing: $filename"
    XML_FILE="/tmp/${clean_name}_config.xml"
    
    # Use --propFile to ensure AppManage runs correctly
    "$APPMANAGE_BIN" --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1

    if [[ ! -f "$XML_FILE" ]]; then 
        echo "   ❌ AppManage failed for $filename"
        continue 
    fi

    # --- Process Anatomy Extraction ---
    IS_FT=$(grep -oP '(?<=<isFt>).*?(?=</isFt>)' "$XML_FILE" | head -1 || echo "false")
    
    PROCESS_SUMMARY=""
    # We use grep to get line numbers for each process block to avoid 'sed' pattern errors
    grep -n "<bwprocess " "$XML_FILE" | while IFS=: read -r line_num line_content; do
        P_RAW=$(echo "$line_content" | grep -oP '(?<=name=").*?(?=")')
        P_NAME=$(echo "$P_RAW" | sed 's|.*/||; s/\.process//')
        
        # Extract 10 lines following the process name to find starter/limits
        # This is safer than range matching in sed
        P_BLOCK=$(tail -n +$line_num "$XML_FILE" | head -n 15)
        
        P_STARTER=$(echo "$P_BLOCK" | grep -oP '(?<=<starter>).*?(?=</starter>)' | head -1)
        P_MAX=$(echo "$P_BLOCK" | grep -oP '(?<=<maxJob>).*?(?=</maxJob>)' | head -1)
        P_FLOW=$(echo "$P_BLOCK" | grep -oP '(?<=<flowLimit>).*?(?=</flowLimit>)' | head -1)
        
        # Append to summary
        echo "- ${P_NAME} (Starter: ${P_STARTER}, Max: ${P_MAX}, Flow: ${P_FLOW})" >> "/tmp/${clean_name}_summary.txt"
    done

    # Properly indent the summary for YAML
    if [ -f "/tmp/${clean_name}_summary.txt" ]; then
        FORMATTED_SUMMARY=$(sed 's/^/    /' "/tmp/${clean_name}_summary.txt")
        rm "/tmp/${clean_name}_summary.txt"
    else
        FORMATTED_SUMMARY="    - No processes found"
    fi

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
$FORMATTED_SUMMARY
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
    # Using fixed grep patterns for JDBC and JMS
    grep -oP 'jdbc:[^<]+' "$XML_FILE" | sort -u | while read -r d; do
        res_id="db-$(echo "$d" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        echo "$res_id|$d" >> "$TMP_DB_LIST"
    done
    
    grep -oP '(tibjmsnaming|tcp|ssl|local)://[^<]+' "$XML_FILE" | sort -u | while read -r j; do
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
  if [[ -s "$TMP_DB_LIST" ]]; then
      sort -u "$TMP_DB_LIST" | while IFS='|' read -r id url; do
        echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JDBC: $url\"\nspec:\n  type: database\n  owner: group:default/infrastructure-team"
      done
  fi
  if [[ -s "$TMP_JMS_LIST" ]]; then
      sort -u "$TMP_JMS_LIST" | while IFS='|' read -r id url; do
        echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JMS: $url\"\nspec:\n  type: messaging-server\n  owner: group:default/messaging-team"
      done
  fi
} > "$RES_DIR/discovered-infrastructure.yaml"

# --- 5. GitHub API & Push ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo "🌐 Checking GitHub Repository..."
    REPO_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO")
    
    if [ "$REPO_CHECK" -ne 200 ]; then
        echo "🔨 Creating private repository $GITHUB_REPO..."
        curl -s -H "Authorization: token $GITHUB_TOKEN" -d "{\"name\":\"$GITHUB_REPO\", \"private\":true}" "https://api.github.com/user/repos"
    fi

    pushd "$REPO_DIR" > /dev/null
    echo -ne "*\n!*/\n!*.yaml\n!catalog-info.yaml\n!.gitignore" > .gitignore
    AUTH_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    [ ! -d ".git" ] && git init && git remote add origin "$AUTH_URL" && git branch -M main
    git add .
    git commit -m "Registry Sync: $IMPORT_TIME"
    git push -u origin main
    popd > /dev/null
fi

echo "💾 Process finished. Inventory available in $REPO_DIR"

