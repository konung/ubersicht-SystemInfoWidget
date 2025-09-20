#!/bin/bash
# Network information gathering

get_network_interfaces() {
    local interfaces_json="["
    local first=true

    for interface in $(ifconfig -l); do
        local ip=$(ifconfig "$interface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)
        if [ ! -z "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
            [ "$first" = false ] && interfaces_json+=","
            first=false

            # Determine interface type
            local if_type="ethernet"
            case "$interface" in
                en0) if_type="wifi" ;;
                en*) if_type="ethernet" ;;
                utun*|tailscale*) if_type="vpn" ;;
                bridge*) if_type="bridge" ;;
                vmnet*) if_type="vm" ;;
                docker*) if_type="docker" ;;
                ppp*) if_type="vpn" ;;
                awdl*) if_type="airdrop" ;;
            esac

            interfaces_json+="{\"name\":\"$interface\",\"ip\":\"$ip\",\"type\":\"$if_type\"}"
        fi
    done
    interfaces_json+="]"

    echo "$interfaces_json"
}

get_network_traffic() {
    local primary_if=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')

    if [ -z "$primary_if" ]; then
        echo '{"traffic_down": "N/A", "traffic_up": "N/A"}'
        return
    fi

    # Get current bytes
    local stats=$(netstat -b -I "$primary_if" 2>/dev/null | tail -1)
    local bytes_in=$(echo "$stats" | awk '{print $7}')
    local bytes_out=$(echo "$stats" | awk '{print $10}')
    local current_time=$(date +%s)

    # Read previous values from cache
    local prev_time=$(read_cache_value "traffic_timestamp" "0")
    local prev_in=$(read_cache_value "traffic_bytes_in" "0")
    local prev_out=$(read_cache_value "traffic_bytes_out" "0")

    local traffic_down="0 KB/s"
    local traffic_up="0 KB/s"

    if [ "$prev_time" != "0" ]; then
        local time_diff=$((current_time - prev_time))
        if [ $time_diff -gt 0 ] && [ $time_diff -lt 60 ]; then
            local rate_in=$(( (bytes_in - prev_in) / time_diff ))
            local rate_out=$(( (bytes_out - prev_out) / time_diff ))
            traffic_down=$(format_rate $rate_in)
            traffic_up=$(format_rate $rate_out)
        fi
    fi

    # Update cache
    write_cache_values "{\"traffic_timestamp\": $current_time, \"traffic_bytes_in\": $bytes_in, \"traffic_bytes_out\": $bytes_out}"

    echo "{\"traffic_down\": \"$traffic_down\", \"traffic_up\": \"$traffic_up\"}"
}

get_network_apps() {
    local app_count="${1:-3}"
    local skip_apps="${2:-kernel_task,IPNExtension,mDNSResponder}"

    # Convert skip list to awk pattern
    local skip_pattern=$(echo "$skip_apps" | sed 's/,/|/g')

    if ! command -v nettop &> /dev/null; then
        echo "[]"
        return
    fi

    # Take two samples 1 second apart for rate calculation
    local first_sample=$(nettop -P -x -L 1 2>/dev/null | tail -n +2)
    sleep 1
    local second_sample=$(nettop -P -x -L 1 2>/dev/null | tail -n +2)

    if [ -z "$first_sample" ] || [ -z "$second_sample" ]; then
        echo "[]"
        return
    fi

    echo -e "$first_sample\n---SEPARATOR---\n$second_sample" | awk -F',' -v skip_pattern="$skip_pattern" -v app_count="$app_count" '
        BEGIN {
            sample = 1
            print "["
        }
        /---SEPARATOR---/ { sample = 2; next }

        $2 != "" && $5 != "" && $6 != "" {
            process_field = $2
            if (process_field ~ /^(tcp[46]|udp[46])/) next

            split(process_field, parts, ".")
            process = parts[1]

            if (process == "" || process == "time") next
            if (skip_pattern != "" && process ~ skip_pattern) next

            bytes_in = $5 + 0
            bytes_out = $6 + 0

            if (sample == 1) {
                first_in[process] = bytes_in
                first_out[process] = bytes_out
            } else if (sample == 2 && process in first_in) {
                rate_in = bytes_in - first_in[process]
                rate_out = bytes_out - first_out[process]

                if (rate_in >= 0 && rate_out >= 0) {
                    total = rate_in + rate_out
                    if (total > 0) {
                        apps[process] = rate_in "|" rate_out "|" total
                    }
                }
            }
        }
        END {
            count = 0
            for (app in apps) {
                split(apps[app], rates, "|")
                sorted[rates[3] "|" app] = apps[app]
            }

            n = 0
            for (key in sorted) {
                n++
                sorted_keys[n] = key
            }
            # Manual sort by total traffic (descending)
            for (i = 1; i <= n; i++) {
                for (j = i+1; j <= n; j++) {
                    split(sorted_keys[i], a, "|")
                    split(sorted_keys[j], b, "|")
                    if (a[1] + 0 < b[1] + 0) {
                        temp = sorted_keys[i]
                        sorted_keys[i] = sorted_keys[j]
                        sorted_keys[j] = temp
                    }
                }
            }

            first = 1
            for (i = 1; i <= n && count < app_count; i++) {
                split(sorted_keys[i], key_parts, "|")
                app = key_parts[2]
                split(sorted[sorted_keys[i]], rates, "|")

                if (!first) print ","
                first = 0

                # Format rates
                down_rate = rates[1] > 1048576 ? sprintf("%.1f MB/s", rates[1]/1048576) : sprintf("%.1f KB/s", rates[1]/1024)
                up_rate = rates[2] > 1048576 ? sprintf("%.1f MB/s", rates[2]/1048576) : sprintf("%.1f KB/s", rates[2]/1024)
                total_rate = rates[3] > 1048576 ? sprintf("%.1f MB/s", rates[3]/1048576) : sprintf("%.1f KB/s", rates[3]/1024)

                printf "  {\"name\":\"%s\",\"down\":\"%s\",\"up\":\"%s\",\"total\":\"%s\"}",
                    app, down_rate, up_rate, total_rate

                count++
            }
            print ""
            print "]"
        }
    '
}

get_public_ip_info() {
    # Check cache first
    local ip_timestamp=$(read_cache_value "ip_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - ip_timestamp))

    # Use cache if less than 10 minutes old
    if [ $cache_age -lt 600 ] && [ "$ip_timestamp" != "0" ]; then
        cat <<EOF
{
    "public_ip": "$(read_cache_value "public_ip" "N/A")",
    "public_city": "$(read_cache_value "public_city" "")",
    "public_region": "$(read_cache_value "public_region" "")",
    "public_country": "$(read_cache_value "public_country" "")",
    "public_org": "$(read_cache_value "public_org" "")",
    "public_hostname": "$(read_cache_value "public_hostname" "")"
}
EOF
    else
        # Fetch new data
        local ipinfo=$(curl -s --max-time 2 https://ipinfo.io 2>/dev/null)
        if [ ! -z "$ipinfo" ]; then
            local ip=$(echo "$ipinfo" | jq -r '.ip // "N/A"')
            local city=$(echo "$ipinfo" | jq -r '.city // ""')
            local region=$(echo "$ipinfo" | jq -r '.region // ""')
            local country=$(echo "$ipinfo" | jq -r '.country // ""')
            local org=$(echo "$ipinfo" | jq -r '.org // ""')
            local hostname=$(echo "$ipinfo" | jq -r '.hostname // ""')

            # Update cache
            write_cache_values "{
                \"public_ip\": \"$ip\",
                \"public_city\": \"$city\",
                \"public_region\": \"$region\",
                \"public_country\": \"$country\",
                \"public_org\": \"$org\",
                \"public_hostname\": \"$hostname\",
                \"ip_timestamp\": $current_time
            }"

            cat <<EOF
{
    "public_ip": "$ip",
    "public_city": "$city",
    "public_region": "$region",
    "public_country": "$country",
    "public_org": "$org",
    "public_hostname": "$hostname"
}
EOF
        else
            echo '{"public_ip": "N/A"}'
        fi
    fi
}