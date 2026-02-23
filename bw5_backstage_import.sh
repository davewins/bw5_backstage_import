#!/bin/bash

# --- 1. Settings & Toggles ---
PUSH_TO_GITHUB=false   # Set to true for production push
VALIDATE_YAML=true     # Requires 'yq'
EAR_DIR="/path/to/ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"

# --- 2. Environment & Dependency Checks ---

# 2a. Check for TRA_HOME
if [[ -z "$TRA_HOME" ]]; then
    echo "❌ ERROR: TRA_HOME environment variable is not set."
    echo "   Example: export TRA_HOME=/opt/tibco/tra/5.13"
    exit 1
fi

# 2b. Define and Verify TIBCO Binaries
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
BUILDEAR_BIN="$TRA_HOME/bin/buildear"

if [[ ! -x "$APPMANAGE_BIN" ]]; then
    echo "❌ ERROR: AppManage not found or not executable at $APPMANAGE_BIN"
    exit 1
fi

if [[ ! -x "$BUILDEAR_BIN" ]]; then
    echo "❌ ERROR: buildear not found or not executable at $BUILDEAR_BIN"
    exit 1
fi

# 2c. Check GitHub Credentials (if pushing)
if [ "$PUSH_TO_GITHUB" = true ]; then
    if [[ -z "$GITHUB_USER" || -z "$GITHUB_TOKEN" || -z "$GITHUB_REPO" ]]; then
        echo "❌ ERROR: GITHUB_USER, GITHUB_TOKEN, and GITHUB_REPO must be set."
        exit 1
    fi
fi

# Cleanup and Setup Local Workspace
mkdir -p "$APPS_DIR" "$RES_DIR"
TMP_DB_LIST="/tmp/db_unique.txt"
TMP_JMS_LIST="/tmp/jms_unique.txt"
> "$TMP_DB_LIST"
> "$TMP_JMS_LIST"

# --- 3. Root Location Index ---
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-global-inventory
spec:
  targets:
    - ./resources/discovered-infrastructure.yaml" > "$REPO_DIR/catalog-info.yaml"

# --- 4. The Main Extraction Loop ---
echo "🚀 Pre-flight checks passed. Using TIBCO tools from: $TRA_HOME/bin"

for ear in "$EAR_DIR"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    if [ -f "$APPS_DIR/$clean_name.yaml" ]; then
        echo "⚠️ WARNING: Duplicate clean_name '$clean_name' detected for $filename. Skipping to avoid overwrite."
        continue
    fi

    # Run TIBCO AppManage (using the verified absolute path)
    $APPMANAGE_BIN -export -ear "$ear" -out "/tmp/$clean_name.xml" > /dev/null
    
    # Extract Infrastructure (JDBC/JMS)
    dbs=$(grep -oP 'jdbc:[^<]+' "/tmp/$clean_name.xml" | sort -u)
    jms=$(grep -oP '(tibjmsnaming|tcp|ssl)://[^<]+' "/tmp/$clean_name.xml" | sort -u)

    # Generate the Component YAML
    cat <<EOF > "$APPS_DIR/$clean_name.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  description: "BW5 Service: $app_name"
  tags: ["bw5-imported"]
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-admins
  dependsOn:
EOF

    # Map Resources to YAML
    for d in $dbs; do
        res_id="db-$(echo "$d" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        echo "$res_id|$d" >> "$TMP_DB_LIST"
    done
    for j in $jms; do
        res_id="jms-$(echo "$j" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$APPS_DIR/$clean_name.yaml"
        echo "$res_id|$j" >> "$TMP_JMS_LIST"
    done

    # Final logic for root index
    echo "    - ./apps/$clean_name.yaml" >> "$REPO_DIR/catalog-info.yaml"
    echo "✅ Analyzed: $clean_name"
done

# --- 5. Generate Infrastructure Resource YAML ---
echo "🏗️ Generating Infrastructure Map..."
# ... (Infrastructure generation logic same as previous) ...

# --- 6. GitHub Integration ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    # ... (Git push logic same as previous) ...
    echo "✨ Process complete and pushed to GitHub."
else
    echo "💾 Files ready locally in $REPO_DIR."
fi