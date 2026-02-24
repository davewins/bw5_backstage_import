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
DEBUG=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --push) PUSH_TO_GITHUB=true ;;
        --verbose) VERBOSE=true ;;
        --debug) DEBUG=true; VERBOSE=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# --- 3. Pre-flight Checks ---
[[ -z "$TRA_HOME" ]] && { echo "❌ ERROR: TRA_HOME not set."; exit 1; }
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
APPMANAGE_TRA="${APPMANAGE_BIN}.tra"

# Prepare Workspace
shopt -s nullglob
mkdir -p "$APPS_DIR" "$RES_DIR"
rm -f "$APPS_DIR"/*.yaml

TMP_DB_LIST="/tmp/db_unique.txt"
TMP_JMS_LIST="/tmp/jms_unique.txt"
IP_AUDIT_LOG="/tmp/ip_audit_summary.txt"
> "$TMP_DB_LIST"
> "$TMP_JMS_LIST"
> "$IP_AUDIT_LOG"

# Initialize Root Location for Backstage
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-global-inventory
spec:
  targets:
    - ./resources/discovered-infrastructure.yaml" > "$REPO_DIR/catalog-info.yaml"

# --- 4. Processing Loop ---
echo "🚀 Starting Full Architectural Extraction..."
SUCCESS_COUNT=0

for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    echo "▶️ Processing: $filename"

    APP_BASE_DIR="$(pwd)/$APPS_DIR/$clean_name"
    APP_DOCS_DIR="$APP_BASE_DIR/docs"
    mkdir -p "$APP_DOCS_DIR"

    # 4a. Metadata Export
    XML_FILE="/tmp/${clean_name}_config.xml"
    ( unset LD_PRELOAD; "$APPMANAGE_BIN" --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1 )
    [[ ! -f "$XML_FILE" ]] && { echo "   ❌ AppManage failed for $filename"; continue; }

    # 4b. Recursive Extraction
    EXTRACT_PATH="/tmp/extract_$clean_name"
    rm -rf "$EXTRACT_PATH" && mkdir -p "$EXTRACT_PATH"
    unzip -q "$ear" -d "$EXTRACT_PATH"
    
    find "$EXTRACT_PATH" -name "*.zip" -o -name "*.sar" -o -name "*.par" | while read -r sub; do
        target_dir="${sub%.*}"
        [[ "$VERBOSE" == "true" ]] && echo "   📦 Unpacking: $(basename "$sub")"
        mkdir -p "$target_dir"
        unzip -q -o "$sub" -d "$target_dir"
    done

    # 4c. Process Discovery & Mermaid Generation
    PROC_DATA="/tmp/${clean_name}_procs.raw"
    MERMAID_SECTION="/tmp/${clean_name}_mermaid.md"
    > "$PROC_DATA"
    > "$MERMAID_SECTION"

    find "$EXTRACT_PATH" -name "*.process" | sort | while read -r proc_file; do
        rel_proc=$(echo "$proc_file" | sed "s|$EXTRACT_PATH/||")
        [[ "$VERBOSE" == "true" ]] && echo "   🔍 Scoping: $rel_proc"
        
        P_BASE=$(basename "$rel_proc")
        P_MATCH=$(grep -n "name=\"$P_BASE\"" "$XML_FILE" | head -1 | cut -d: -f1)
        if [[ -n "$P_MATCH" ]]; then
            P_BLOCK=$(tail -n +$P_MATCH "$XML_FILE" | head -n 12)
            P_MAX=$(echo "$P_BLOCK" | grep -oP '(?<=<maxJob>).*?(?=</maxJob>)' | head -1 || echo "0")
            P_FLOW=$(echo "$P_BLOCK" | grep -oP '(?<=<flowLimit>).*?(?=</flowLimit>)' | head -1 || echo "0")
        else
            P_MAX="0"; P_FLOW="0"
        fi

        GROUP=$(echo "$rel_proc" | cut -d'/' -f1)
        echo "$GROUP|$rel_proc|$P_MAX|$P_FLOW" >> "$PROC_DATA"

        # The Header text is exactly "#### Process: $rel_proc"
        echo "#### Process: $rel_proc" >> "$MERMAID_SECTION"
        echo '```mermaid' >> "$MERMAID_SECTION"
        echo "graph LR" >> "$MERMAID_SECTION"
        echo "    linkStyle default stroke:#333,stroke-width:2px;" >> "$MERMAID_SECTION"
        
        T_COUNT=0
        perl -0777 -ne 'while(/<(?:pd:)?transition>.*?<(?:pd:)?from>(.*?)<\/(?:pd:)?from>.*?<(?:pd:)?to>(.*?)<\/(?:pd:)?to>(?:.*?<(?:pd:)?conditionType>(.*?)<\/(?:pd:)?conditionType>)?.*?<\/(?:pd:)?transition>/gs){ print "$1|$2|$3\n"; }' "$proc_file" | while IFS='|' read -r FROM TO COND; do
            [[ -z "$FROM" || -z "$TO" ]] && continue
            C_FROM="n_$(echo "$FROM" | sed 's/[^a-zA-Z0-9]/_/g')"
            C_TO="n_$(echo "$TO" | sed 's/[^a-zA-Z0-9]/_/g')"
            
            if [[ "$COND" == "error" ]]; then
                echo "    $C_FROM([\"$FROM\"]) -- Error --> $C_TO([\"$TO\"])" >> "$MERMAID_SECTION"
                echo "    linkStyle $T_COUNT stroke:#ff0000,stroke-width:2px;" >> "$MERMAID_SECTION"
            elif [[ -n "$COND" && "$COND" != "always" ]]; then
                echo "    $C_FROM([\"$FROM\"]) -- \"$COND\" --> $C_TO([\"$TO\"])" >> "$MERMAID_SECTION"
            else
                echo "    $C_FROM([\"$FROM\"]) --> $C_TO([\"$TO\"])" >> "$MERMAID_SECTION"
            fi
            ((T_COUNT++))
        done
        echo '```' >> "$MERMAID_SECTION"
        echo -e "\n[↑ Back to Inventory](#process-inventory)\n" >> "$MERMAID_SECTION"
    done

    # 4d. GV Extraction & Audit
    GV_TABLE="| Variable Name | Value | Status |\n| :--- | :--- | :--- |\n"
    GV_RAW="/tmp/${clean_name}_gv.raw"
    sed -n '/name="Global Variables"/,/<\/NVPairs>/p' "$XML_FILE" | grep -E "<name>|<value>" | \
    sed 'N;s/<name>\(.*\)<\/name>.*\n.*<value>\(.*\)<\/value>/\1|\2/' | \
    grep -vE "Password|#!|Modulus|PrivateExponent" > "$GV_RAW"

    HAS_IP_ISSUE=false
    while IFS='|' read -r name value; do
        STATUS="✅ OK"
        if [[ $value =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
            if [[ ! $value =~ "127.0.0.1" && ! $value =~ "0.0.0.0" ]]; then
                STATUS="⚠️ **Hardcoded IP**"
                HAS_IP_ISSUE=true
            fi
        fi
        GV_TABLE+="| $name | \`$value\` | $STATUS |\n"
    done < "$GV_RAW"
    [[ "$HAS_IP_ISSUE" == "true" ]] && echo "$filename" >> "$IP_AUDIT_LOG"

    # 4e. TechDocs generation (Nav-Fix & Double-Hyphen Slug)
    cat <<EOF > "$APP_BASE_DIR/mkdocs.yml"
site_name: $app_name Docs
nav:
  - Architecture Overview: index.md
  - Process Inventory: index.md#process-inventory
  - Visual Flow Diagrams: index.md#visual-flow-diagrams
  - Global Variables: index.md#global-variables
theme:
  name: material
  features:
    - navigation.sections
    - navigation.expand
    - toc.follow
EOF

    {
      echo "# $app_name Architecture"
      
      echo -e "\n## Process Inventory"
      sort -t'|' -k2,2 "$PROC_DATA" | cut -d'|' -f1 | uniq | while read -r group_name; do
          echo "### Group: $group_name"
          echo -e "| Process Path | Max Jobs | Flow Limit |"
          echo -e "| :--- | :--- | :--- |"
          # HUB PRECISION:
          # MkDocs turns "Process: Archive/..." into "process-process-archive..."
          # 1. Prefix 'process-'
          # 2. Add the first word of the path, lowercase.
          # 3. Add a hyphen.
          # 4. Add the rest of the path stripped of non-alphanumeric.
          grep "^$group_name|" "$PROC_DATA" | sort -t'|' -k2,2 | while IFS='|' read -r g path max flow; do
              FIRST_WORD=$(echo "$path" | cut -d'/' -f1 | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
              REST_OF_PATH=$(echo "$path" | cut -d'/' -f2- | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
              LINK_ID="process-$FIRST_WORD-$REST_OF_PATH"
              echo "| [$path](#$LINK_ID) | $max | $flow |"
          done
          echo -e "\n"
      done

      echo -e "\n## Visual Flow Diagrams"
      [[ -s "$MERMAID_SECTION" ]] && cat "$MERMAID_SECTION" || echo "_No flows discovered._"
      
      echo -e "\n## Global Variables"
      echo -e "$GV_TABLE"
      
      echo -e "\n---"
      echo -e "_Last synchronized from source on: $IMPORT_TIME (UTC)_"
    } > "$APP_DOCS_DIR/index.md"

    # 4f. Backstage Component YAML
    cat <<EOF > "$APP_BASE_DIR/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  annotations:
    backstage.io/techdocs-ref: dir:.
    tibco.com/imported-at: "$IMPORT_TIME"
  tags: ["bw5-imported"]
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-imported
EOF

    # 4g. Infrastructure Discovery
    grep -oP '(jdbc|tcp|ssl|aaa|ldap|tibjmsnaming)://[^<]+' "$XML_FILE" | sort -u | while read -r url; do
        prefix="endpoint"; [[ "$url" == jdbc* ]] && prefix="db"
        res_id="${prefix}-$(echo "$url" | sed 's/[^a-z0-9]/-/g' | cut -c1-40 | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')"
        echo "    - resource:default/$res_id" >> "$APP_BASE_DIR/catalog-info.yaml"
        [[ "$prefix" == "db" ]] && echo "$res_id|$url" >> "$TMP_DB_LIST" || echo "$res_id|$url" >> "$TMP_JMS_LIST"
    done

    echo "    - ./apps/$clean_name/catalog-info.yaml" >> "$REPO_DIR/catalog-info.yaml"
    rm -rf "$EXTRACT_PATH" "$XML_FILE" "$GV_RAW" "$MERMAID_SECTION" "$PROC_DATA"
    ((SUCCESS_COUNT++))
done

# --- 5. Global Resource Generation ---
{
  echo "# Discovered Infrastructure"
  [[ -s "$TMP_DB_LIST" ]] && sort -u "$TMP_DB_LIST" | while IFS='|' read -r id url; do
    echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"JDBC: $url\"\nspec:\n  type: database\n  owner: group:default/infrastructure-team"
  done
  [[ -s "$TMP_JMS_LIST" ]] && sort -u "$TMP_JMS_LIST" | while IFS='|' read -r id url; do
    echo -e "---\napiVersion: backstage.io/v1alpha1\nkind: Resource\nmetadata:\n  name: $id\n  description: \"Endpoint: $url\"\nspec:\n  type: endpoint\n  owner: group:default/infrastructure-team"
  done
} > "$RES_DIR/discovered-infrastructure.yaml"

# --- 6. GitHub Sync ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    pushd "$REPO_DIR" > /dev/null
    echo -ne "*\n!*/\n!*.yaml\n!*.yml\n!*.md\n!.gitignore" > .gitignore
    AUTH_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
    [[ ! -d ".git" ]] && git init && git remote add origin "$AUTH_URL" && git branch -M main
    git add .
    git commit -m "Registry & Mermaid Sync: $IMPORT_TIME"
    git push -u origin main
    popd > /dev/null
fi

# --- 7. Final Summary ---
echo "------------------------------------------------"
echo "✅ Finished! Processed $SUCCESS_COUNT EAR files."
if [[ -s "$IP_AUDIT_LOG" ]]; then
    echo -e "\n⚠️  HARDCODED IP WARNING - Review these services:"
    cat "$IP_AUDIT_LOG" | sort -u | sed 's/^/   - /'
fi
echo "------------------------------------------------"
