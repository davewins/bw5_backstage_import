#!/bin/bash

# --- 1. Configuration ---
EAR_DIR="./ears"
REPO_DIR="./bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
LIB_DIR="$REPO_DIR/libs"
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

mkdir -p "$APPS_DIR" "$RES_DIR" "$LIB_DIR"
rm -f "$APPS_DIR"/*.yaml

TMP_DB_LIST="/tmp/db_unique.txt"
TMP_JMS_LIST="/tmp/jms_unique.txt"
TMP_LIB_LIST="/tmp/lib_discovered.txt"
GLOBAL_CATALOG_LIST="/tmp/global_catalog_targets.tmp"

> "$TMP_DB_LIST"
> "$TMP_JMS_LIST"
> "$TMP_LIB_LIST"
> "$GLOBAL_CATALOG_LIST"

echo "    - ./resources/discovered-infrastructure.yaml" >> "$GLOBAL_CATALOG_LIST"
echo "    - ./libs/catalog-info.yaml" >> "$GLOBAL_CATALOG_LIST"

# --- 4. Processing Loop ---
for ear in "${EAR_DIR}"/*.ear; do
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/^-//;s/-$//')

    echo "▶️ Processing: $filename"
    APP_BASE_DIR="$(pwd)/$APPS_DIR/$clean_name"
    APP_DOCS_DIR="$APP_BASE_DIR/docs"
    mkdir -p "$APP_DOCS_DIR"
    echo "    - ./apps/$clean_name/catalog-info.yaml" >> "$GLOBAL_CATALOG_LIST"

    XML_FILE="/tmp/${clean_name}_config.xml"
    ( unset LD_PRELOAD; "$APPMANAGE_BIN" --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1 )

    EXTRACT_PATH="/tmp/extract_$clean_name"
    rm -rf "$EXTRACT_PATH" && mkdir -p "$EXTRACT_PATH"
    unzip -q "$ear" -d "$EXTRACT_PATH"
    find "$EXTRACT_PATH" -type f \( -name "*.par" -o -name "*.sar" -o -name "*.zip" \) | while read -r sub; do
        unzip -q -o "$sub" -d "${sub%.*}"
    done

    LOCAL_LIB_DEPS="/tmp/${clean_name}_local_libs.tmp"
    > "$LOCAL_LIB_DEPS"

    # Unique Library ID combining App Name and Library Name
    find "$EXTRACT_PATH" -name "*.sar" | while read -r sar_file; do
        sar_filename=$(basename "$sar_file")
        lib_id="${clean_name}-$(echo "${sar_filename%.*}" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g')"
        lib_extract_path="/tmp/lib_extract_$lib_id"
        mkdir -p "$lib_extract_path"
        unzip -q -o "$sar_file" -d "$lib_extract_path"
        
        if find "$lib_extract_path" -iname "*.process" | grep -q "."; then
            [[ "$VERBOSE" == "true" ]] && echo "   📦 Shared Library: $lib_id"
            echo "$lib_id|${sar_filename%.*} (Internal to $app_name)|$lib_extract_path" >> "$TMP_LIB_LIST"
            echo "    - component:default/$lib_id" >> "$LOCAL_LIB_DEPS"
        fi
    done

    # Process Discovery
    PROC_DATA_FILE="/tmp/${clean_name}_procs.raw"
    MERMAID_SECTION_FILE="/tmp/${clean_name}_mermaid.md"
    > "$PROC_DATA_FILE" && > "$MERMAID_SECTION_FILE"

    find "$EXTRACT_PATH" -iname "*.process" | sort | while read -r proc_file; do
        rel_proc=$(echo "$proc_file" | sed "s|$EXTRACT_PATH/||")
        [[ "$VERBOSE" == "true" ]] && echo "   🔍 Scoping: $rel_proc"

        P_BASE=$(basename "$rel_proc")
        P_MATCH=$(grep -n "name=\"$P_BASE\"" "$XML_FILE" | head -1 | cut -d: -f1)
        [[ -n "$P_MATCH" ]] && P_BLOCK=$(tail -n +$P_MATCH "$XML_FILE" | head -n 12)
        P_MAX=$(echo "$P_BLOCK" | grep -oP '(?<=<maxJob>).*?(?=</maxJob>)' | head -1 || echo "0")
        P_FLOW=$(echo "$P_BLOCK" | grep -oP '(?<=<flowLimit>).*?(?=</flowLimit>)' | head -1 || echo "0")

        fid=$(echo "$rel_proc" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        echo "$(echo "$rel_proc" | cut -d'/' -f1)|$rel_proc|$P_MAX|$P_FLOW|$fid" >> "$PROC_DATA_FILE"

        echo "#### Process: $rel_proc {: #$fid }" >> "$MERMAID_SECTION_FILE"
        echo '```mermaid' >> "$MERMAID_SECTION_FILE"
        echo "graph LR" >> "$MERMAID_SECTION_FILE"
        perl -0777 -ne 'while(/<(?:pd:)?transition>.*?<(?:pd:)?from>(.*?)<\/(?:pd:)?from>.*?<(?:pd:)?to>(.*?)<\/(?:pd:)?to>(?:.*?<(?:pd:)?conditionType>(.*?)<\/(?:pd:)?conditionType>)?.*?<\/(?:pd:)?transition>/gs){ print "$1|$2|$3\n"; }' "$proc_file" | while IFS='|' read -r FROM TO COND; do
            [[ -z "$FROM" || -z "$TO" ]] && continue
            echo "    n_$(echo "$FROM" | sed 's/[^a-zA-Z0-9]/_/g')([\"$FROM\"]) --> n_$(echo "$TO" | sed 's/[^a-zA-Z0-9]/_/g')([\"$TO\"])" >> "$MERMAID_SECTION_FILE"
        done
        echo -e '```\n\n[↑ Back to Inventory](#process-inventory)\n' >> "$MERMAID_SECTION_FILE"
    done

    # --- REFACTORED COMPILATION-SAFE GV EXTRACTION ---
    GV_MD_FILE="/tmp/${clean_name}_gv.md"
    echo -e "| Variable Name | Value | Status |" > "$GV_MD_FILE"
    echo -e "| :--- | :--- | :--- |" >> "$GV_MD_FILE"
    
    # Using a safer approach to Perl to avoid Compilation Errors
    perl -ne '
        if (/<name>(.*?)<\/name>/) { $n = $1; }
        if (/<value>(.*?)<\/value>/) { 
            $v = $1; 
            if ($n) {
                if ($n =~ /Key|Token|Modulus|Exponent/i) { $v = substr($v,0,30)."..." }
                else { $v =~ s/(.{25})/$1&#x200B;/g }
                print "$n|$v\n";
                $n = ""; $v = "";
            }
        }
    ' "$XML_FILE" | while IFS='|' read -r name value; do
        STATUS="✅ OK"
        [[ "$value" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} && ! "$value" =~ "127.0.0.1" ]] && STATUS="⚠️ **IP**"
        echo "| $name | \`$value\` | $STATUS |" >> "$GV_MD_FILE"
    done

    cat <<EOF > "$APP_BASE_DIR/mkdocs.yml"
site_name: $app_name Docs
nav:
  - Architecture Overview: index.md
  - Process Inventory: index.md#process-inventory
  - Visual Flow Diagrams: index.md#visual-flow-diagrams
  - Global Variables: index.md#global-variables
theme: { name: material }
EOF

    {
      echo "# $app_name Architecture"
      echo -e "\n## Process Inventory"
      if [[ -s "$PROC_DATA_FILE" ]]; then
          sort -t'|' -k2,2 "$PROC_DATA_FILE" | cut -d'|' -f1 | uniq | while read -r group_name; do
              echo -e "### Group: $group_name\n| Process Path | Max Jobs | Flow Limit |\n| :--- | :--- | :--- |"
              grep "^$group_name|" "$PROC_DATA_FILE" | sort -t'|' -k2,2 | while IFS='|' read -r g path max flow fid; do echo "| [$path](#$fid) | $max | $flow |"; done
          done
      fi
      echo -e "\n## Visual Flow Diagrams\n" && cat "$MERMAID_SECTION_FILE"
      echo -e "\n## Global Variables\n" && cat "$GV_MD_FILE"
    } > "$APP_DOCS_DIR/index.md"

    # Component YAML
    DEP_FILE="/tmp/${clean_name}_deps.tmp"
    > "$DEP_FILE"
    [[ -f "$LOCAL_LIB_DEPS" ]] && cat "$LOCAL_LIB_DEPS" >> "$DEP_FILE"
    grep -oP '(jdbc|tcp|ssl|aaa|ldap|tibjmsnaming)://[^<]+' "$XML_FILE" | sort -u | while read -r url; do
        res_id="endpoint-$(echo "$url" | sed 's/[^a-z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | cut -c1-50 | sed 's/-$//')"
        echo "    - resource:default/$res_id" >> "$DEP_FILE"
        [[ "$url" == jdbc* ]] && echo "$res_id|$url" >> "$TMP_DB_LIST" || echo "$res_id|$url" >> "$TMP_JMS_LIST"
    done
    
    cat <<EOF > "$APP_BASE_DIR/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  annotations: { backstage.io/techdocs-ref: dir:. }
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-imported
EOF
    [[ -s "$DEP_FILE" ]] && echo "  dependsOn:" >> "$APP_BASE_DIR/catalog-info.yaml" && sort -u "$DEP_FILE" >> "$APP_BASE_DIR/catalog-info.yaml"

    rm -rf "$EXTRACT_PATH" "$XML_FILE" "$PROC_DATA_FILE" "$MERMAID_SECTION_FILE" "$DEP_FILE" "$LOCAL_LIB_DEPS" "$GV_MD_FILE"
    ((SUCCESS_COUNT++))
done

# --- 5. Library Docs (Project Scoped) ---
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-libraries
spec:
  targets:" > "$LIB_DIR/catalog-info.yaml"

sort -u "$TMP_LIB_LIST" | while IFS='|' read -r lib_id original lib_path; do
    LIB_BASE_DIR="$LIB_DIR/$lib_id" && mkdir -p "$LIB_BASE_DIR/docs"
    LIB_MERMAID="/tmp/lib_${lib_id}_mermaid.md" && LIB_PROC_RAW="/tmp/lib_${lib_id}_procs.raw"
    > "$LIB_MERMAID" && > "$LIB_PROC_RAW"
    
    find "$lib_path" -iname "*.process" | sort | while read -r proc_file; do
        rel_proc=$(echo "$proc_file" | sed "s|$lib_path/||")
        fid=$(echo "$rel_proc" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        echo "$rel_proc|$fid" >> "$LIB_PROC_RAW"
        echo -e "#### Process: $rel_proc {: #$fid }\n"'```mermaid'"\ngraph LR" >> "$LIB_MERMAID"
        perl -0777 -ne 'while(/<(?:pd:)?transition>.*?<(?:pd:)?from>(.*?)<\/(?:pd:)?from>.*?<(?:pd:)?to>(.*?)<\/(?:pd:)?to>(?:.*?<(?:pd:)?conditionType>(.*?)<\/(?:pd:)?conditionType>)?.*?<\/(?:pd:)?transition>/gs){ print "$1|$2|$3\n"; }' "$proc_file" | while IFS='|' read -r FROM TO COND; do
            [[ -z "$FROM" || -z "$TO" ]] && continue
            echo "    n_$(echo "$FROM" | sed 's/[^a-zA-Z0-9]/_/g')([\"$FROM\"]) --> n_$(echo "$TO" | sed 's/[^a-zA-Z0-9]/_/g')([\"$TO\"])" >> "$LIB_MERMAID"
        done
        echo -e '```\n' >> "$LIB_MERMAID"
    done

    echo "site_name: $original Library Docs" > "$LIB_BASE_DIR/mkdocs.yml"
    { echo -e "# $original\n\n## Library Process Inventory\n| Path |\n| :--- |"
      sort "$LIB_PROC_RAW" | while IFS='|' read -r path fid; do echo "| [$path](#$fid) |"; done
      echo -e "\n## Visual Flow Diagrams\n" && cat "$LIB_MERMAID"
    } > "$LIB_BASE_DIR/docs/index.md"
    
    cat <<EOF > "$LIB_BASE_DIR/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $lib_id
  annotations: { backstage.io/techdocs-ref: dir:. }
spec: { type: library, lifecycle: production, owner: group:default/tibco-imported }
EOF
    echo "    - ./$lib_id/catalog-info.yaml" >> "$LIB_DIR/catalog-info.yaml"
    rm -rf "$lib_path" "$LIB_MERMAID" "$LIB_PROC_RAW"
done

# Root Registry
echo "apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-global-inventory
spec:
  targets:" > "$REPO_DIR/catalog-info.yaml"
cat "$GLOBAL_CATALOG_LIST" >> "$REPO_DIR/catalog-info.yaml"

if [ "$PUSH_TO_GITHUB" = true ]; then
    pushd "$REPO_DIR" > /dev/null
    git add . && git commit -m "Comp-safe Responsive Scoped Sync: $IMPORT_TIME" && git push origin main
    popd > /dev/null
fi
echo "✅ Finished! Projects and Shared Archives are now cleanly separated without compilation errors."
