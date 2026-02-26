#!/bin/bash

# --- 1. Configuration ---
EAR_DIR="./ears"
REPO_DIR="../bw5-inventory"
APPS_DIR="$REPO_DIR/apps"
RES_DIR="$REPO_DIR/resources"
LIB_DIR="$REPO_DIR/libs"
API_DIR="$REPO_DIR/apis"
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

[[ -z "$TRA_HOME" ]] && { echo "❌ ERROR: TRA_HOME not set."; exit 1; }
APPMANAGE_BIN="$TRA_HOME/bin/AppManage"
APPMANAGE_TRA="${APPMANAGE_BIN}.tra"

# Workspace Preparation
mkdir -p "$APPS_DIR" "$RES_DIR" "$LIB_DIR" "$API_DIR"
rm -rf "$APPS_DIR"/* "$API_DIR"/* "$LIB_DIR"/* "$RES_DIR"/*

# --- Graphviz check ---
if command -v dot &>/dev/null; then
    DOT_AVAILABLE=true
    DOT_VERSION=$(dot -V 2>&1 | head -1)
    echo "✅ Graphviz found: $DOT_VERSION"
else
    DOT_AVAILABLE=false
    echo "⚠️  WARNING: Graphviz 'dot' not found. Process diagrams will be skipped."
    echo "   Install with: sudo apt install graphviz   (Debian/Ubuntu)"
    echo "                 brew install graphviz        (macOS)"
fi

# Renders a .process file to an SVG.
# Usage: render_process_diagram <process_file> <output_dir> <slug>
# Writes: <output_dir>/<slug>.svg
# Returns exit code 0 on success, 1 on failure (caller constructs markdown)
render_process_diagram() {
    local proc_file="$1"
    local out_dir="$2"
    local slug="$3"
    local dot_file="/tmp/${slug}.dot"
    local svg_file="${out_dir}/${slug}.svg"

    [[ "$DOT_AVAILABLE" != "true" ]] && return 1

    perl "$DOT_PERL" "$proc_file" "$dot_file" 2>/dev/null || return 1
    dot -Tsvg "$dot_file" -o "$svg_file" 2>/dev/null || return 1
    rm -f "$dot_file"
    return 0
}

# --- Global temp files ---
GLOBAL_API_REGISTRY="/tmp/global_api_registry.tmp"
GLOBAL_API_CONSUMERS="/tmp/global_api_consumers.tmp"
GLOBAL_API_PROVIDERS="/tmp/global_api_providers.tmp"

# Infrastructure resource registries
# Format: resource_id|resource_type|display_name|detail
GLOBAL_JMS_REGISTRY="/tmp/global_jms_registry.tmp"
GLOBAL_HTTP_REGISTRY="/tmp/global_http_registry.tmp"
GLOBAL_DB_REGISTRY="/tmp/global_db_registry.tmp"

# App->Resource usage
# Format: app_clean_name|resource_id|protocol_tag
GLOBAL_RESOURCE_USAGE="/tmp/global_resource_usage.tmp"

> "$GLOBAL_API_REGISTRY"; > "$GLOBAL_API_CONSUMERS"; > "$GLOBAL_API_PROVIDERS"
> "$GLOBAL_JMS_REGISTRY"; > "$GLOBAL_HTTP_REGISTRY"; > "$GLOBAL_DB_REGISTRY"
> "$GLOBAL_RESOURCE_USAGE"

APP_INDEX="/tmp/app_index.tmp"
API_INDEX="/tmp/api_index.tmp"
LIB_INDEX="/tmp/lib_index.tmp"
RES_INDEX="/tmp/res_index.tmp"
> "$APP_INDEX"; > "$API_INDEX"; > "$LIB_INDEX"; > "$RES_INDEX"

# --- 3. Helper Scripts (Perl) ---

DOT_PERL="/tmp/dot_gen.pl"
cat <<'EOF' > "$DOT_PERL"
# Converts a BW5 .process XML file into a Graphviz DOT graph.
# Accepts one argument: the output .dot filepath.
# Usage: perl dot_gen.pl <process_file> <out.dot>
use strict; use warnings;
my $out_file = $ARGV[1] or die "No output file specified";

undef $/;
open(my $fh, '<', $ARGV[0]) or die "Cannot open $ARGV[0]: $!";
my $content = <$fh>;
close $fh;

# Collect unique node labels so we can assign clean IDs
my %node_id;
my @edges;
my $counter = 0;

sub node_id {
    my ($label) = @_;
    unless (exists $node_id{$label}) {
        $node_id{$label} = "n" . $counter++;
    }
    return $node_id{$label};
}

# Also try to detect start/end activities for shape differentiation
my %start_nodes;
my %end_nodes;
while ($content =~ /<(?:pd:)?type[^>]*>\s*(?:[\w.]*\.)?(\w*(?:Start|Starter|EventSource|Receive)\w*)\s*<\/(?:pd:)?type>/gsi) {
    # We'll mark these after edge collection
}

# Extract transitions
while ($content =~ /<(?:pd:)?transition\b[^>]*>(.*?)<\/(?:pd:)?transition>/gsi) {
    my $block = $1;
    my ($from) = ($block =~ /<(?:pd:)?from[^>]*>(.*?)<\/(?:pd:)?from>/si);
    my ($to)   = ($block =~ /<(?:pd:)?to[^>]*>(.*?)<\/(?:pd:)?to>/si);
    next unless defined $from && defined $to;
    $from =~ s/^\s+|\s+$//g;
    $to   =~ s/^\s+|\s+$//g;
    node_id($from); node_id($to);
    push @edges, [$from, $to];
}

# If no transitions found, emit a minimal placeholder graph
if (!@edges) {
    open(my $out, '>', $out_file) or die "Cannot write $out_file: $!";
    print $out "digraph process {\n";
    print $out "    graph [rankdir=LR fontname=\"Helvetica\" bgcolor=\"#ffffff\"];\n";
    print $out "    node [shape=box style=\"rounded,filled\" fillcolor=\"#e8f4f8\" fontname=\"Helvetica\" fontsize=11];\n";
    print $out "    no_transitions [label=\"No transitions found\" shape=note fillcolor=\"#fff9c4\"];\n";
    print $out "}\n";
    close $out;
    exit 0;
}

open(my $out, '>', $out_file) or die "Cannot write $out_file: $!";
print $out "digraph process {\n";
print $out "    graph [rankdir=LR fontname=\"Helvetica\" bgcolor=\"#ffffff\" pad=0.5 nodesep=0.6 ranksep=0.8];\n";
print $out "    node  [shape=box style=\"rounded,filled\" fillcolor=\"#e8f4f8\" fontname=\"Helvetica\" fontsize=11 margin=\"0.2,0.1\"];\n";
print $out "    edge  [fontname=\"Helvetica\" fontsize=9 color=\"#555555\"];\n\n";

# Emit node declarations with escaped labels
for my $label (sort { $node_id{$a} cmp $node_id{$b} } keys %node_id) {
    my $id  = $node_id{$label};
    my $esc = $label;
    $esc =~ s/\\/\\\\/g;
    $esc =~ s/"/\\"/g;
    # Highlight likely start/end activities with different colours
    my $fill = "#e8f4f8";
    if ($label =~ /\b(?:Start|Init|Begin|Starter|EventSource|Receive|Trigger)\b/i) {
        $fill = "#c8e6c9";  # green tint for entry points
    } elsif ($label =~ /\b(?:End|Stop|Finish|Reply|Response|Return)\b/i) {
        $fill = "#ffccbc";  # orange tint for exit points
    } elsif ($label =~ /\b(?:Error|Fault|Catch|Exception)\b/i) {
        $fill = "#ffcdd2";  # red tint for error handlers
    }
    print $out "    $id [label=\"$esc\" fillcolor=\"$fill\"];\n";
}

print $out "\n";

# Emit edges
for my $edge (@edges) {
    my ($from, $to) = @$edge;
    print $out "    " . $node_id{$from} . " -> " . $node_id{$to} . ";\n";
}

print $out "}\n";
close $out;
EOF

GV_PERL="/tmp/gv_gen.pl"
cat <<'EOF' > "$GV_PERL"
while(<>) {
    if (/<name>(.*?)<\/name>/) { $n = $1; }
    if (/<value>(.*?)<\/value>/) {
        $v = $1;
        if ($n) {
            if ($n =~ /Key|Token|Modulus|Exponent/i) { $v = substr($v,0,30)."..." }
            else { $v =~ s/(.{25})/$1&#x200B;/g }
            print "| $n | `$v` | ✅ OK |\n";
            $n = ""; $v = "";
        }
    }
}
EOF

SERVICE_DETECT_PERL="/tmp/service_detect.pl"
cat <<'EOF' > "$SERVICE_DETECT_PERL"
undef $/; $content = <>;
my %seen;
while($content =~ /<(?:pd:)?wsdlFileName>(.*?)<\/(?:pd:)?wsdlFileName>/gs) {
    my $fn = $1; $fn =~ s|.*/||;
    next if $seen{"API:$fn"}++;
    print "CONSUMES_API:$fn\n";
}
while($content =~ /<(?:pd:)?schemaFile>(.*?)<\/(?:pd:)?schemaFile>/gs) {
    my $fn = $1; $fn =~ s|.*/||;
    next if $seen{"API:$fn"}++;
    print "CONSUMES_API:$fn\n";
}
while($content =~ /schemaLocation="([^"]+)"/gs) {
    my $fn = $1; $fn =~ s|.*/||;
    next if $seen{"API:$fn"}++;
    print "CONSUMES_API:$fn\n";
}
while($content =~ /(?:resourceRef|href)="([^"]+\.(?:wsdl|xsd))"/gis) {
    my $fn = $1; $fn =~ s|.*/||;
    next if $seen{"API:$fn"}++;
    print "CONSUMES_API:$fn\n";
}
EOF

# --- Infrastructure detection Perl scripts ---

# Parses AppManage XML export for shared JMS, HTTP, JDBC resources
INFRA_XML_PERL="/tmp/infra_xml.pl"
cat <<'EOF' > "$INFRA_XML_PERL"
# Parses TIBCO AppManage exported XML for shared resource configs
undef $/;
$content = <>;

# --- JDBC / Database connections ---
# BW5 JDBC shared resources use com.tibco.plugin.jdbc.JDBCConnectionResource
while ($content =~ /<resource[^>]*type="com\.tibco\.plugin\.jdbc\.[^"]*"[^>]*>(.*?)<\/resource>/gsi) {
    my $block = $1;
    my ($name)  = ($block =~ /<name>(.*?)<\/name>/si);
    my ($url)   = ($block =~ /<(?:databaseURL|url|connectionURL|jdbcURL)>(.*?)<\/(?:databaseURL|url|connectionURL|jdbcURL)>/si);
    my ($driver)= ($block =~ /<driverClass>(.*?)<\/driverClass>/si);
    $name   //= "unknown-db";
    $url    //= "";
    $driver //= "";
    print "DB|$name|$url|$driver\n";
}

# --- JMS connections ---
# com.tibco.plugin.jms.JMSSharedConfiguration
while ($content =~ /<resource[^>]*type="com\.tibco\.plugin\.jms\.[^"]*"[^>]*>(.*?)<\/resource>/gsi) {
    my $block = $1;
    my ($name)     = ($block =~ /<name>(.*?)<\/name>/si);
    my ($provider) = ($block =~ /<(?:providerURL|serverURL|brokerURL|url)>(.*?)<\/(?:providerURL|serverURL|brokerURL|url)>/si);
    my ($factory)  = ($block =~ /<(?:connectionFactory|queueConnectionFactory|topicConnectionFactory)>(.*?)<\/(?:connectionFactory|queueConnectionFactory|topicConnectionFactory)>/si);
    $name     //= "unknown-jms";
    $provider //= "";
    $factory  //= "";
    print "JMS|$name|$provider|$factory\n";
}

# --- HTTP connections ---
# com.tibco.plugin.http.HTTPClientResource or HTTPConnectionResource
while ($content =~ /<resource[^>]*type="com\.tibco\.plugin\.http[^"]*"[^>]*>(.*?)<\/resource>/gsi) {
    my $block = $1;
    my ($name) = ($block =~ /<name>(.*?)<\/name>/si);
    my ($host) = ($block =~ /<(?:host|serverHost|baseURL)>(.*?)<\/(?:host|serverHost|baseURL)>/si);
    my ($port) = ($block =~ /<(?:port|serverPort)>(.*?)<\/(?:port|serverPort)>/si);
    $name //= "unknown-http";
    $host //= "";
    $port //= "";
    print "HTTP|$name|$host|$port\n";
}
EOF

# Parses .process files for transport/protocol hints, JMS destinations,
# HTTP endpoints (both inbound listeners and outbound calls), and DB refs.
#
# All substitution variables (%prop.name%) are preserved as-is so the
# resource ID is stable and predictable — resolution happens in bash using
# the AppManage-exported property values when available.
PROCESS_INFRA_PERL="/tmp/process_infra.pl"
cat <<'EOF' > "$PROCESS_INFRA_PERL"
undef $/;
$content = <>;
my (%seen, %proto_seen);

# ── Protocol detection ──────────────────────────────────────────────────────
my $has_soap = $content =~ /com\.tibco\.plugin\.soap\.SOAP|SOAPRequestReply|SOAPSendReceive|SOAPEventSource/i;
my $has_jms  = $content =~ /com\.tibco\.plugin\.jms\.JMS/i;
my $has_http = $content =~ /com\.tibco\.plugin\.http\.HTTP/i;
my $has_json = $content =~ /application\/json|JSON(?:Serializer|Deserializer|Parse|Render)/i;
my $has_xml  = $content =~ /XMLSerializer|XMLDeserializer|xsd:element|text\/xml|application\/xml/i;
my $has_jdbc = $content =~ /com\.tibco\.plugin\.jdbc\.JDBC/i;

if ($has_soap && $has_jms)  { $proto_seen{"soap-jms"}  = 1 }
elsif ($has_soap)            { $proto_seen{"soap-http"} = 1 }

if ($has_jms && !$has_soap) {
    if ($has_json) { $proto_seen{"json-jms"} = 1 }
    else           { $proto_seen{"xml-jms"}  = 1 }  # default JMS payload is XML in BW5
}

if ($has_http && !$has_soap) {
    if ($has_json) { $proto_seen{"json-http"} = 1 }
    elsif ($has_xml){ $proto_seen{"xml-http"} = 1 }
    else            { $proto_seen{"http"}      = 1 }
}

if ($has_jdbc) { $proto_seen{"jdbc"} = 1 }

print "PROTO:$_\n" for sort keys %proto_seen;

# ── JMS destinations ─────────────────────────────────────────────────────────
# Covers queue/topic names, which may contain %substitution.variables%
for my $tag (qw(destination queue topic replyToQueue replyToTopic)) {
    while ($content =~ /<(?:pd:)?${tag}[^>]*>(.*?)<\/(?:pd:)?${tag}>/gsi) {
        my $d = $1; $d =~ s/^\s+|\s+$//g; $d =~ s/<[^>]+>//g;
        next if !$d || $seen{"JD:$d"}++;
        print "JMS_DEST:$d\n";
    }
}

# ── HTTP endpoints — OUTBOUND calls ──────────────────────────────────────────
for my $tag (qw(endpointURI url serverURL baseURL)) {
    while ($content =~ /<(?:pd:)?${tag}[^>]*>(.*?)<\/(?:pd:)?${tag}>/gsi) {
        my $u = $1; $u =~ s/^\s+|\s+$//g;
        # Accept both resolved URLs and substitution-variable URLs
        next unless $u =~ /^https?:\/\//i || $u =~ /^%[^%]+%/;
        next if $seen{"HE:$u"}++;
        print "HTTP_EP:$u\n";
    }
}

# ── HTTP endpoints — INBOUND listeners (EventSource / Receiver) ───────────────
# BW5 HTTP EventSource stores the path in <pd:resourcePath> or <pd:path>
# and the port in <pd:port> or via a shared HTTPConnector resource reference.
# We emit HTTP_LISTEN lines so bash can tag these as "provided" endpoints.
{
    my ($port, $path, $ctx) = ("", "", "");
    ($port) = ($content =~ /<(?:pd:)?port[^>]*>(\d+)<\/(?:pd:)?port>/si);
    ($ctx)  = ($content =~ /<(?:pd:)?contextPath[^>]*>(.*?)<\/(?:pd:)?contextPath>/si);
    ($path) = ($content =~ /<(?:pd:)?resourcePath[^>]*>(.*?)<\/(?:pd:)?resourcePath>/si);
    $path //= "";  $ctx //= "";  $port //= "";
    my $full = ($ctx ? "/$ctx" : "") . ($path ? "/$path" : "");
    $full =~ s|//+|/|g;
    if ($content =~ /HTTPEventSource|HTTPReceive|com\.tibco\.plugin\.http\.HTTP(?:Event|Receive)/i) {
        my $ep = ($port ? ":$port" : "") . ($full ? $full : "/");
        print "HTTP_LISTEN:$ep\n" unless $seen{"HL:$ep"}++;
    }
}

# ── JDBC / shared config references ──────────────────────────────────────────
while ($content =~ /<(?:pd:)?JDBCConnection[^>]*>(.*?)<\/(?:pd:)?JDBCConnection>/gsi) {
    my $r = $1; $r =~ s/^\s+|\s+$//g; $r =~ s/<[^>]+>//g;
    next if !$r || $seen{"DB:$r"}++;
    print "DB_REF:$r\n";
}
while ($content =~ /<(?:pd:)?sharedConfig[^>]*>(.*?)<\/(?:pd:)?sharedConfig>/gsi) {
    my $r = $1; $r =~ s/^\s+|\s+$//g; $r =~ s/<[^>]+>//g;
    next if !$r || $seen{"SC:$r"}++;
    print "SHARED_REF:$r\n";
}
EOF

# --- 4. Helper Functions ---

get_api_id() {
    local api_fn="$1"
    echo "${api_fn%.*}" | tr '[:upper:]' '[:lower:]' | tr '_. ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Normalize any string to a safe Backstage resource name
make_resource_id() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_. /:@' '-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-63
}

register_api_global() {
    local api_file="$1"
    local provider_app="$2"
    local api_fn; api_fn=$(basename "$api_file")
    local api_id; api_id=$(get_api_id "$api_fn")
    echo "${api_id}|${api_fn}|${provider_app}|${api_file}" >> "$GLOBAL_API_REGISTRY"
    echo "${provider_app}|${api_id}" >> "$GLOBAL_API_PROVIDERS"
}

# --- 5. PASS 1: Extract EARs, discover APIs and infrastructure ---
echo "🔍 Pass 1: Extracting EARs and discovering all resources..."

declare -A APP_EXTRACT_PATHS
declare -A APP_XML_FILES

for ear in "${EAR_DIR}"/*.ear; do
    [[ -f "$ear" ]] || continue
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

    [[ "$VERBOSE" == "true" ]] && echo "  ▶️  Extracting: $filename -> $clean_name"

    EXTRACT_PATH="/tmp/extract_$clean_name"
    rm -rf "$EXTRACT_PATH"
    mkdir -p "$EXTRACT_PATH"
    unzip -q "$ear" -d "$EXTRACT_PATH"
    find "$EXTRACT_PATH" -type f \( -name "*.par" -o -name "*.sar" -o -name "*.zip" \) | while read -r sub; do
        unzip -q -o "$sub" -d "${sub%.*}"
    done

    APP_EXTRACT_PATHS[$clean_name]="$EXTRACT_PATH"

    XML_FILE="/tmp/${clean_name}_config.xml"
    ( unset LD_PRELOAD; "$APPMANAGE_BIN" --propFile "$APPMANAGE_TRA" -export -ear "$ear" -out "$XML_FILE" > /dev/null 2>&1 )
    APP_XML_FILES[$clean_name]="$XML_FILE"

    # APIs provided
    while IFS= read -r api_file; do
        register_api_global "$api_file" "$clean_name"
    done < <(find "$EXTRACT_PATH" -type f \( -iname "*.wsdl" -o -iname "*.xsd" \))

    # --- Infrastructure from AppManage XML export ---
    if [[ -f "$XML_FILE" ]]; then
        while IFS='|' read -r res_type res_name detail1 detail2; do
            res_id=$(make_resource_id "${res_type,,}-${res_name}")
            case "$res_type" in
                DB)
                    echo "${res_id}|database|${res_name}|${detail1}|${detail2}" >> "$GLOBAL_DB_REGISTRY"
                    echo "${clean_name}|${res_id}|jdbc" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;
                JMS)
                    echo "${res_id}|jms-broker|${res_name}|${detail1}|${detail2}" >> "$GLOBAL_JMS_REGISTRY"
                    echo "${clean_name}|${res_id}|jms" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;
                HTTP)
                    echo "${res_id}|http-endpoint|${res_name}|${detail1}|${detail2}" >> "$GLOBAL_HTTP_REGISTRY"
                    echo "${clean_name}|${res_id}|http" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;
            esac
        done < <(perl "$INFRA_XML_PERL" "$XML_FILE" 2>/dev/null)
    fi

    # --- Protocol tags and infra refs from process files ---
    # IMPORTANT: we avoid "perl ... | while read" pipelines here because
    # the pipe creates a subshell and any "echo >> file" inside it is lost
    # when the subshell exits.  Instead we write perl output to a temp file
    # and read it with a plain while loop (no pipe = no subshell).
    PROTO_TMP="/tmp/${clean_name}_protos.tmp"
    PERL_OUT="/tmp/${clean_name}_perl_out.tmp"
    > "$PROTO_TMP"

    while IFS= read -r process_file; do

        # Run both Perl scripts and collect all output in one file
        perl "$PROCESS_INFRA_PERL"  "$process_file" >  "$PERL_OUT" 2>/dev/null
        perl "$SERVICE_DETECT_PERL" "$process_file" >> "$PERL_OUT" 2>/dev/null

        while IFS= read -r line; do
            ptype="${line%%:*}"
            pval="${line#*:}"
            [[ -z "$pval" ]] && continue

            case "$ptype" in
                PROTO)
                    echo "$pval" >> "$PROTO_TMP"
                    ;;

                JMS_DEST)
                    dest_id=$(make_resource_id "jms-dest-${pval}")
                    # Write to registry unconditionally; dedup happens at pass-2 read
                    echo "${dest_id}|jms-destination|${pval}|discovered-in-process|" >> "$GLOBAL_JMS_REGISTRY"
                    echo "${clean_name}|${dest_id}|jms" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;

                HTTP_EP)
                    # Normalise to scheme+host+port — strip path so shared hosts merge
                    if [[ "$pval" =~ ^https?:// ]]; then
                        base_url=$(echo "$pval" | sed 's|\(https\?://[^/]*\).*|\1|')
                    else
                        # substitution variable URL — use as-is
                        base_url="$pval"
                    fi
                    ep_id=$(make_resource_id "http-$(echo "$base_url" | sed 's|https\?://||')")
                    echo "${ep_id}|http-endpoint|${base_url}|outbound|" >> "$GLOBAL_HTTP_REGISTRY"
                    echo "${clean_name}|${ep_id}|http" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;

                HTTP_LISTEN)
                    # Inbound HTTP listener — record as a provided endpoint resource
                    listen_id=$(make_resource_id "http-listen-${clean_name}-${pval}")
                    display="${clean_name} listener ${pval}"
                    echo "${listen_id}|http-endpoint|${display}|inbound|${pval}" >> "$GLOBAL_HTTP_REGISTRY"
                    echo "${clean_name}|${listen_id}|http-inbound" >> "$GLOBAL_RESOURCE_USAGE"
                    ;;

                DB_REF|SHARED_REF)
                    # Try to match against already-known DB or JMS resources by name fragment
                    matched=$(grep -i "|${pval}|" "$GLOBAL_DB_REGISTRY"  2>/dev/null | head -1 | cut -d'|' -f1)
                    [[ -n "$matched" ]] && echo "${clean_name}|${matched}|jdbc" >> "$GLOBAL_RESOURCE_USAGE"
                    matched=$(grep -i "|${pval}|" "$GLOBAL_JMS_REGISTRY" 2>/dev/null | head -1 | cut -d'|' -f1)
                    [[ -n "$matched" ]] && echo "${clean_name}|${matched}|jms"  >> "$GLOBAL_RESOURCE_USAGE"
                    ;;

                CONSUMES_API)
                    local_api_id=$(get_api_id "$pval")
                    [[ -n "$local_api_id" ]] && echo "${clean_name}|${local_api_id}|${pval}" >> "$GLOBAL_API_CONSUMERS"
                    ;;
            esac
        done < "$PERL_OUT"

    done < <(find "$EXTRACT_PATH" -type f -iname "*.process")

    rm -f "$PERL_OUT"

    # Deduplicate and persist protocol tags
    sort -u "$PROTO_TMP" > "/tmp/${clean_name}_protos_final.tmp"
    rm -f "$PROTO_TMP"
done

# --- 6. PASS 2: Write all Resource entities ---
echo "🔌 Pass 2: Writing infrastructure Resource entities..."

write_resource_entity() {
    local res_id="$1"
    local res_type="$2"    # database | jms-broker | jms-destination | http-endpoint
    local display_name="$3"
    local detail="$4"
    local extra="$5"
    local out_file="$RES_DIR/${res_id}.yaml"

    [[ -f "$out_file" ]] && return

    local tags="tibco bw5"
    case "$res_type" in
        database)          tags="$tags database jdbc" ;;
        jms-broker)        tags="$tags messaging jms broker" ;;
        jms-destination)   tags="$tags messaging jms destination" ;;
        http-endpoint)     tags="$tags http rest" ;;
    esac

    local desc="$display_name"
    [[ -n "$detail" && "$detail" != "discovered-in-process" ]] && desc="$desc — $detail"
    [[ -n "$extra" ]] && desc="$desc ($extra)"

    echo "    - ./${res_id}.yaml" >> "$RES_INDEX"

    cat <<EOF > "$out_file"
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: $res_id
  title: "$display_name"
  description: "$desc"
  tags:
$(for t in $tags; do echo "    - $t"; done)
spec:
  type: $res_type
  lifecycle: production
  owner: group:default/tibco-imported
  system: system:default/tibco-bw5-estate
EOF
}

# Deduplicate all three registries by resource_id (field 1), keeping first occurrence
# This handles the fact that process-file scanning writes duplicates intentionally
sort -t'|' -k1,1 -u "$GLOBAL_JMS_REGISTRY"  | while IFS='|' read -r res_id res_type display_name detail1 detail2; do
    write_resource_entity "$res_id" "$res_type" "$display_name" "$detail1" "$detail2"
done
sort -t'|' -k1,1 -u "$GLOBAL_HTTP_REGISTRY" | while IFS='|' read -r res_id res_type display_name detail1 detail2; do
    write_resource_entity "$res_id" "$res_type" "$display_name" "$detail1" "$detail2"
done
sort -t'|' -k1,1 -u "$GLOBAL_DB_REGISTRY"   | while IFS='|' read -r res_id res_type display_name detail1 detail2; do
    write_resource_entity "$res_id" "$res_type" "$display_name" "$detail1" "$detail2"
done

# Deduplicate resource usage links too so dependsOn lists aren't noisy
sort -u "$GLOBAL_RESOURCE_USAGE" -o "$GLOBAL_RESOURCE_USAGE"

# --- 7. PASS 3: Write all API entities (same as before) ---
echo "🔗 Pass 3: Writing API entities..."

DEDUPED_REGISTRY="/tmp/global_api_registry_deduped.tmp"
sort -t'|' -k1,1 -u "$GLOBAL_API_REGISTRY" > "$DEDUPED_REGISTRY"

while IFS='|' read -r api_id api_fn provider_app api_file; do
    [[ -f "$API_DIR/${api_id}.yaml" ]] && continue
    echo "    - ./${api_id}.yaml" >> "$API_INDEX"
    local_api_type="${api_fn##*.}"
    case "${local_api_type,,}" in
        wsdl) api_type="openapi" ;;
        xsd)  api_type="grpc" ;;
        *)    api_type="openapi" ;;
    esac
    cat <<EOF > "$API_DIR/${api_id}.yaml"
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: $api_id
  title: "${api_fn%.*}"
  description: "Shared interface: $api_fn (provided by $provider_app)"
  tags:
    - tibco
    - bw5
spec:
  type: $api_type
  lifecycle: production
  owner: group:default/tibco-imported
  system: system:default/tibco-bw5-estate
  definition: |
$(sed 's/^/    /' "$api_file" 2>/dev/null || echo "    # Definition file not readable")
EOF
done < "$DEDUPED_REGISTRY"

# Stub unresolved consumed APIs
while IFS='|' read -r consumer_app api_id ref_filename; do
    if [[ ! -f "$API_DIR/${api_id}.yaml" ]]; then
        [[ "$VERBOSE" == "true" ]] && echo "  ⚠️  Stub API: $api_id (referenced as '$ref_filename' by $consumer_app)"
        echo "    - ./${api_id}.yaml" >> "$API_INDEX"
        cat <<EOF > "$API_DIR/${api_id}.yaml"
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: $api_id
  title: "${ref_filename%.*}"
  description: "External or unresolved API — referenced by $consumer_app as '$ref_filename'"
  tags:
    - tibco
    - bw5
    - external
    - unresolved
spec:
  type: openapi
  lifecycle: unknown
  owner: group:default/tibco-imported
  system: system:default/tibco-bw5-estate
  definition: |
    # Not found in scanned EAR files.
    # Original reference: $ref_filename
    # First referenced by: $consumer_app
EOF
    fi
done < <(sort -t'|' -k1,2 -u "$GLOBAL_API_CONSUMERS")

# --- 8. PASS 4: Write Component (app) catalog entries ---
echo "📦 Pass 4: Writing Component catalog entries..."

for ear in "${EAR_DIR}"/*.ear; do
    [[ -f "$ear" ]] || continue
    filename=$(basename -- "$ear")
    app_name="${filename%.*}"
    clean_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

    EXTRACT_PATH="${APP_EXTRACT_PATHS[$clean_name]}"
    XML_FILE="${APP_XML_FILES[$clean_name]}"

    APP_BASE_DIR="$APPS_DIR/$clean_name"
    APP_DOCS_DIR="$APP_BASE_DIR/docs"
    mkdir -p "$APP_DOCS_DIR"
    echo "    - ./$clean_name/catalog-info.yaml" >> "$APP_INDEX"

    cat <<EOF > "$APP_BASE_DIR/mkdocs.yml"
site_name: $app_name
site_description: Documentation for $app_name
nav:
  - Process Inventory: index.md
  - Visual Flow Diagrams: diagrams.md
  - Global Variables: variables.md
theme:
  name: material
  features:
    - navigation.sections
    - navigation.expand
    - navigation.top
EOF

    # --- Shared Libraries ---
    LOCAL_LIB_DEPS="/tmp/${clean_name}_lib_deps.tmp"
    > "$LOCAL_LIB_DEPS"
    while IFS= read -r sar_file; do
        sar_fn=$(basename "$sar_file")
        lib_id="${clean_name}-$(echo "${sar_fn%.*}" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-' | sed 's/[^a-z0-9-]//g')"
        lib_extract="/tmp/lib_extract_$lib_id"
        mkdir -p "$lib_extract"
        unzip -q -o "$sar_file" -d "$lib_extract"
        if find "$lib_extract" -iname "*.process" | grep -q "."; then
            echo "    - ./$lib_id/catalog-info.yaml" >> "$LIB_INDEX"
            LIB_BASE="$LIB_DIR/$lib_id"
            mkdir -p "$LIB_BASE/docs"
            cat <<EOF > "$LIB_BASE/mkdocs.yml"
site_name: $sar_fn Library
nav:
  - Process Inventory: index.md
theme:
  name: material
  features:
    - navigation.top
EOF
            echo -e "# $sar_fn\n\n## Visual Flow Diagrams" > "$LIB_BASE/docs/index.md"
            find "$lib_extract" -iname "*.process" | while read -r lp; do
                proc_base=$(basename "$lp" .process)
                proc_slug=$(echo "$proc_base" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g;s/^-//;s/-$//')
                echo -e "#### Process: $proc_base\n" >> "$LIB_BASE/docs/index.md"
                if render_process_diagram "$lp" "$LIB_BASE/docs" "$proc_slug"; then
                    echo -e "![${proc_slug} flow](${proc_slug}.svg)\n" >> "$LIB_BASE/docs/index.md"
                else
                    echo -e "_No diagram available — install Graphviz to enable process diagrams._\n" >> "$LIB_BASE/docs/index.md"
                fi
            done
            cat <<EOF > "$LIB_BASE/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $lib_id
  title: "$sar_fn"
  description: "Shared library from $app_name"
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:default/tibco-imported
  system: system:default/tibco-bw5-estate
EOF
            echo "    - component:default/$lib_id" >> "$LOCAL_LIB_DEPS"
        fi
        rm -rf "$lib_extract"
    done < <(find "$EXTRACT_PATH" -name "*.sar")

    # --- Documentation ---
    PROC_RAW="/tmp/${clean_name}_procs.raw"
    DIAGRAMS_MD="$APP_DOCS_DIR/diagrams.md"
    VARIABLES_MD="$APP_DOCS_DIR/variables.md"
    > "$PROC_RAW"

    # Header for diagrams page
    echo -e "# $app_name — Visual Flow Diagrams\n" > "$DIAGRAMS_MD"

    while IFS= read -r p_file; do
        rel_p=$(echo "$p_file" | sed "s|$EXTRACT_PATH/||")
        [[ "$VERBOSE" == "true" ]] && echo "   🔍 Scoping: $rel_p"
        fid=$(echo "$rel_p" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        echo "$(echo "$rel_p" | cut -d'/' -f1)|$rel_p|$fid" >> "$PROC_RAW"

        echo -e "#### Process: $rel_p {: #$fid }\n" >> "$DIAGRAMS_MD"
        if render_process_diagram "$p_file" "$APP_DOCS_DIR" "$fid"; then
            echo -e "![${fid} flow](${fid}.svg)\n" >> "$DIAGRAMS_MD"
        else
            echo -e "_No diagram available — install Graphviz to enable process diagrams._\n" >> "$DIAGRAMS_MD"
        fi
        echo -e "[↑ Back to Inventory](index.md)\n" >> "$DIAGRAMS_MD"
    done < <(find "$EXTRACT_PATH" -iname "*.process" | sort)

    # --- index.md: Process Inventory table with links into diagrams.md ---
    {
        echo "# $app_name"
        echo -e "\n## Process Inventory\n"
        if [[ -s "$PROC_RAW" ]]; then
            sort -u "$PROC_RAW" | cut -d'|' -f1 | uniq | while read -r group; do
                echo -e "### $group\n| Process | Diagram |\n| :--- | :--- |"
                grep "^$group|" "$PROC_RAW" | while IFS='|' read -r g path fid; do
                    echo "| $path | [View diagram](diagrams.md#$fid) |"
                done
                echo ""
            done
        else
            echo "_No processes found in this application._"
        fi
    } > "$APP_DOCS_DIR/index.md"

    # --- variables.md: Global Variables table ---
    {
        echo "# $app_name — Global Variables"
        echo -e "\n| Name | Value | Status |\n| :--- | :--- | :--- |"
        perl "$GV_PERL" "$XML_FILE"
    } > "$VARIABLES_MD"

    # --- Build relationship lists ---
    LOCAL_PROVIDES_API="/tmp/${clean_name}_provides.tmp"
    LOCAL_CONSUMES_API="/tmp/${clean_name}_consumes.tmp"
    LOCAL_DEPENDS_RES="/tmp/${clean_name}_depends_res.tmp"
    > "$LOCAL_PROVIDES_API"; > "$LOCAL_CONSUMES_API"; > "$LOCAL_DEPENDS_RES"

    grep "^${clean_name}|" "$GLOBAL_API_PROVIDERS" | cut -d'|' -f2 | sort -u | \
        while read -r api_id; do echo "    - api:default/$api_id"; done >> "$LOCAL_PROVIDES_API"

    grep "^${clean_name}|" "$GLOBAL_API_CONSUMERS" | cut -d'|' -f2 | sort -u | \
        while read -r api_id; do
            grep -q "^${clean_name}|${api_id}$" "$GLOBAL_API_PROVIDERS" 2>/dev/null || \
                echo "    - api:default/$api_id"
        done >> "$LOCAL_CONSUMES_API"

    # Resource dependencies — all infra (JMS destinations, HTTP endpoints, databases)
    # Use a temp file read (not pipe) to avoid subshell losing writes
    RES_USAGE_TMP="/tmp/${clean_name}_res_usage.tmp"
    grep "^${clean_name}|" "$GLOBAL_RESOURCE_USAGE" | cut -d'|' -f2 | sort -u > "$RES_USAGE_TMP"
    while read -r res_id; do
        # Only emit if the resource YAML was actually created
        if [[ -f "$RES_DIR/${res_id}.yaml" ]]; then
            echo "    - resource:default/$res_id"
        else
            echo "  ⚠️  WARNING: resource $res_id referenced by $clean_name but YAML missing — skipping" >&2
        fi
    done < "$RES_USAGE_TMP" >> "$LOCAL_DEPENDS_RES"
    rm -f "$RES_USAGE_TMP"

    # Merge lib deps and resource deps into dependsOn
    LOCAL_DEPENDS_ALL="/tmp/${clean_name}_depends_all.tmp"
    cat "$LOCAL_LIB_DEPS" "$LOCAL_DEPENDS_RES" | sort -u > "$LOCAL_DEPENDS_ALL"

    # --- Collect protocol tags ---
    PROTO_FILE="/tmp/${clean_name}_protos_final.tmp"

    # --- Write catalog-info.yaml ---
    # Write the opening metadata and the start of the tags block
    cat <<EOF > "$APP_BASE_DIR/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $clean_name
  title: "$app_name"
  description: "TIBCO BW5 Application: $app_name"
  annotations:
    backstage.io/techdocs-ref: dir:.
  tags:
    - tibco
    - bw5
    - integration
EOF
    # Append protocol tags into the SAME tags block before closing metadata.
    # These must be written here (not in a heredoc) so the variable expands correctly.
    if [[ -f "$PROTO_FILE" && -s "$PROTO_FILE" ]]; then
        sed 's/^/    - /' "$PROTO_FILE" >> "$APP_BASE_DIR/catalog-info.yaml"
    fi

    cat <<EOF >> "$APP_BASE_DIR/catalog-info.yaml"
  links:
    - url: https://example.com/admin/$clean_name
      title: Admin Console
      icon: dashboard
spec:
  type: service
  lifecycle: production
  owner: group:default/tibco-imported
  system: system:default/tibco-bw5-estate
EOF

    [[ -s "$LOCAL_PROVIDES_API" ]] && { echo "  providesApis:"; sort -u "$LOCAL_PROVIDES_API"; } >> "$APP_BASE_DIR/catalog-info.yaml"
    [[ -s "$LOCAL_CONSUMES_API" ]] && { echo "  consumesApis:"; sort -u "$LOCAL_CONSUMES_API"; } >> "$APP_BASE_DIR/catalog-info.yaml"
    [[ -s "$LOCAL_DEPENDS_ALL"  ]] && { echo "  dependsOn:";    sort -u "$LOCAL_DEPENDS_ALL";  } >> "$APP_BASE_DIR/catalog-info.yaml"

    rm -f "$PROC_RAW" "$LOCAL_PROVIDES_API" "$LOCAL_CONSUMES_API" \
          "$LOCAL_LIB_DEPS" "$LOCAL_DEPENDS_RES" "$LOCAL_DEPENDS_ALL" "$PROTO_FILE"
done

# --- 9. System, Group, and index catalog files ---
echo "📋 Writing catalog index files..."

cat <<EOF > "$REPO_DIR/system-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: tibco-bw5-estate
  title: "TIBCO BusinessWorks 5 Estate"
  description: "Complete inventory of TIBCO BW5 applications and services"
  tags:
    - tibco
    - integration
    - middleware
spec:
  owner: group:default/tibco-imported
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: tibco-imported
  title: "TIBCO Imported Assets"
  description: "Auto-imported TIBCO BW5 components"
spec:
  type: team
  children: []
EOF

finalize_index() {
    local dir="$1"; local index_tmp="$2"; local name="$3"; local title="$4"
    echo -e "apiVersion: backstage.io/v1alpha1\nkind: Location\nmetadata:\n  name: $name\n  title: \"$title\"\nspec:\n  targets:" > "$dir/catalog-info.yaml"
    [[ -s "$index_tmp" ]] && sort -u "$index_tmp" >> "$dir/catalog-info.yaml"
}

finalize_index "$APPS_DIR" "$APP_INDEX" "bw5-apps"  "BW5 Applications"
finalize_index "$API_DIR"  "$API_INDEX" "bw5-apis"  "BW5 APIs"
finalize_index "$LIB_DIR"  "$LIB_INDEX" "bw5-libs"  "BW5 Libraries"
finalize_index "$RES_DIR"  "$RES_INDEX" "bw5-resources" "BW5 Infrastructure Resources"

cat <<EOF > "$REPO_DIR/catalog-info.yaml"
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: bw5-root-inventory
  title: "TIBCO BW5 Root Inventory"
  description: "Root location for all TIBCO BW5 imported assets"
spec:
  targets:
    - ./system-info.yaml
    - ./apps/catalog-info.yaml
    - ./libs/catalog-info.yaml
    - ./apis/catalog-info.yaml
    - ./resources/catalog-info.yaml
EOF

# --- 10. Cleanup ---
for clean_name in "${!APP_EXTRACT_PATHS[@]}"; do
    rm -rf "${APP_EXTRACT_PATHS[$clean_name]}"
done
rm -f "$DOT_PERL" "$GV_PERL" "$SERVICE_DETECT_PERL" "$INFRA_XML_PERL" "$PROCESS_INFRA_PERL"
rm -f "$GLOBAL_API_REGISTRY" "$GLOBAL_API_CONSUMERS" "$GLOBAL_API_PROVIDERS" "$DEDUPED_REGISTRY"
rm -f "$GLOBAL_JMS_REGISTRY" "$GLOBAL_HTTP_REGISTRY" "$GLOBAL_DB_REGISTRY" "$GLOBAL_RESOURCE_USAGE"
rm -f /tmp/*.tmp /tmp/*.raw /tmp/*.md /tmp/*_config.xml

# --- 11. Git ---
if [ "$PUSH_TO_GITHUB" = true ]; then
    pushd "$REPO_DIR" > /dev/null
    git add .
    git commit -m "TIBCO BW5 Import - $IMPORT_TIME"
    git push origin main
    popd > /dev/null
    echo "✅ Pushed to GitHub successfully"
fi

# --- Summary ---
app_count=$(find "$APPS_DIR" -mindepth 2 -name 'catalog-info.yaml' | wc -l)
api_count=$(find "$API_DIR"  -mindepth 1 -name '*.yaml' ! -name 'catalog-info.yaml' | wc -l)
lib_count=$(find "$LIB_DIR"  -mindepth 2 -name 'catalog-info.yaml' | wc -l)
res_count=$(find "$RES_DIR"  -mindepth 1 -name '*.yaml' ! -name 'catalog-info.yaml' | wc -l)
jms_count=$(grep -rl 'type: jms' "$RES_DIR" 2>/dev/null | grep -v 'catalog-info.yaml' | wc -l)
db_count=$( grep -rl 'type: database' "$RES_DIR" 2>/dev/null | grep -v 'catalog-info.yaml' | wc -l)
http_count=$(grep -rl 'type: http-endpoint' "$RES_DIR" 2>/dev/null | grep -v 'catalog-info.yaml' | wc -l)
unresolved_count=$(grep -rl 'unresolved' "$API_DIR" 2>/dev/null | wc -l)

echo ""
echo "✅ Import complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "📦 Applications  : %s\n" "$app_count"
printf "🔌 APIs          : %s  (↳ %s unresolved stubs)\n" "$api_count" "$unresolved_count"
printf "📚 Libraries     : %s\n" "$lib_count"
printf "🏗️  Resources     : %s\n" "$res_count"
printf "   ↳ JMS destinations : %s\n" "$jms_count"
printf "   ↳ Databases        : %s\n" "$db_count"
printf "   ↳ HTTP endpoints   : %s\n" "$http_count"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Protocol tag distribution across apps:"
# Collect all app catalog-info.yaml files (mindepth 2 skips the top-level index)
# then grep for the specific protocol tag lines we write — they look like "    - soap-http"
PROTO_TAGS=$(find "$APPS_DIR" -mindepth 2 -name 'catalog-info.yaml' \
    -exec grep -ohE '^\s+- (soap-http|soap-jms|xml-http|xml-jms|json-http|json-jms|jdbc|http)' {} \; \
    2>/dev/null | sed 's/^[[:space:]]*- //' | sort | uniq -c | sort -rn)

if [[ -n "$PROTO_TAGS" ]]; then
    echo "$PROTO_TAGS" | while read -r count tag; do
        printf "  %-14s : %s apps\n" "$tag" "$count"
    done
else
    echo "  (none detected - check that process files contain recognisable TIBCO activity class names)"
fi
