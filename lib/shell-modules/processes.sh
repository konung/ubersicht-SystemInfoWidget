#!/bin/bash
# Process and CPU monitoring

get_top_processes() {
    local proc_count="${1:-3}"
    local json="["
    local first=true

    # Get top processes by CPU usage
    while IFS='|' read -r cpu cmd; do
        # Clean up command name
        local cmd_name=$(basename "$cmd" 2>/dev/null | cut -d' ' -f1)

        [ "$first" = false ] && json+=","
        first=false
        json+="{\"name\":\"$cmd_name\",\"cpu\":\"${cpu}%\"}"
    done < <(ps aux | awk 'NR>1 {print $3 "|" $11}' | sort -t'|' -k1 -rn | head -n "$proc_count")

    json+="]"
    echo "$json"
}