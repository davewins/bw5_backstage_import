#!/bin/bash

# --- 1. Settings & Toggles ---
PUSH_TO_GITHUB=false             # Set to true for production push
EAR_DIR="./ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
IMPORT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- 2. Pre-flight Checks ---
if [[ -z "$TRA_HOME" ]]; then echo "❌ ERROR: TRA_HOME not set."; exit 1; fi
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
APPMANAGE_TRA="${APPMANAGE_BIN}.tra"

# Check GitHub Credentials (if pushing)
if [ "$PUSH_TO_GITHUB" = true ]; then
    if [[ -z "$GITHUB_USER" || -z "$GITHUB_TOKEN" || -z "$GITHUB_REPO" ]]; then
        echo "❌ ERROR: GITHUB_USER, GITHUB_TOKEN, and GITHUB_REPO must be set for push."
        exit 1
    fi
fi

# Prepare Workspace
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
echo "🚀 Starting Batch Import (Timestamp: $IMPORT_TIME)..."

for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    echo "▶️ Processing: $filename"
    XML_FILE="/tmp/${clean_name}_config.xml"
    $APPMANAGE_BIN --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1

    if [[ ! -f "$XML_FILE" ]]; then
        echo "   ❌ ERROR: Export failed for $filename"
        continue
    fi

    # --- ARCHITECTURAL GLEANING ---
    
    # 1. Detect Tech Stack (Tags)
    TAGS="[\"bw5-imported\""
    grep -qi "JDBCpalette" "$XML_FILE" && TAGS+=", \"jdbc\""
    grep -qi "SOAPpalette" "$XML_FILE" && TAGS+=", \"soap\""
    grep -qi "JMSpalette" "$XML_FILE" && TAGS+=", \"jms\""
    grep -qi "RESTpalette" "$XML_FILE" && TAGS+=", \"rest\""
    
    # 2. Check for "Broken Links" (Empty Global Variables)
    if grep -qP '<value>\s*</value>|<value/>' "$XML_FILE"; then
        TAGS+=", \"needs-review\""
        STATUS_MSG="⚠️ Flagged: Empty Global Variables found."
    else
        STATUS_MSG="✅ Clean: All variables populated."
    fi
    TAGS+="]"

    # 3. Extract Metadata (Designer Ver & Max Jobs)
    TIB_VER=$(grep -A 1 "ae.designerapp.version" "$XML_FILE" | grep "value" | sed 's/<[^>]*>//g' | xargs | head -n 1 || echo "Unknown")
    MAX_JOBS=$(grep -A 1 "maxJobs" "$XML_FILE" | grep "value" | sed 's/<[^>]*>//g' | xargs | head -n 1 || echo "Default")

    # --- Generate YAML ---
    cat <<EOF > "$APPS_DIR/$clean_name.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  description: "BW5 App: $app_name | Designer: $TIB_VER"
  tags: $TAGS
  annotations:
    tibco.com/max-jobs: "$MAX_JOBS"
    tibco.com/config-status: "$STATUS_MSG"
    backstage.io/imported-at: "$IMPORT_TIME"
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-admins
  dependsOn:
EOF

    # Map Infrastructure (JDBC/JMS)
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

# --- 5. GitHub Integration ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo "🚀 Syncing to GitHub..."
    cd "$REPO_DIR"
    AUTH_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

    if [ ! -d ".git" ]; then
        git init
        git remote add origin "$AUTH_URL"
        git branch -M main
    fi

    git add .
    git commit -m "BW5 Architectural Sync - $IMPORT_TIME"
    git push -u origin main
    echo "✨ All apps are now live in GitHub."
else
    echo "💾 Local mode: Process finished. Check ./bw5-inventory"
fi

