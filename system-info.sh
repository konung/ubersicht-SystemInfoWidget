#!/bin/bash

# Set PATH to include common locations for brew and other tools
# Prioritize /usr/local/bin for Intel brew (which appears to be the user's primary)
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# ========================================
# TOOL REQUIREMENTS AND DEPENDENCIES
# ========================================
#
# REQUIRED TOOLS (script will exit if not installed):
# - jq: JSON processor for formatting output
#   Install: brew install jq
# - curl: HTTP client for IP geolocation
#   Install: Usually pre-installed on macOS
# - bc: Calculator for floating point math
#   Install: Usually pre-installed on macOS
#
# STANDARD macOS TOOLS USED (pre-installed):
# System Information:
# - sw_vers: macOS version info
# - sysctl: Kernel parameters (CPU, memory)
# - scutil: System configuration (hostname)
# - system_profiler: Hardware details (GPU, display)
# - uptime: System uptime
# - defaults: User preferences
# - uname: Kernel info
# - hostname: System hostname
# - whoami: Current username
#
# Network Tools:
# - ifconfig: Network interface info
# - networksetup: WiFi and network config
# - netstat: Network statistics and traffic
# - nettop: Per-app network usage (requires root for some features)
# - ping: Network latency
# - nslookup: DNS lookups
# - route: Routing table
#
# Storage Tools:
# - diskutil: APFS disk usage (accurate)
# - df: Filesystem usage (fallback)
#
# Power Management:
# - pmset: Battery and power info
#
# Process Tools:
# - pgrep: Process detection
# - ps: Process listing
#
# Text Processing (pre-installed):
# - awk, sed, grep, cut, sort, uniq, head, tail, tr, wc
#
# OPTIONAL TOOLS (enhance functionality if present):
# Package Managers:
# - brew: Homebrew package manager (Intel: /usr/local/bin, ARM: /opt/homebrew/bin)
# - npm: Node package manager
# - pip/pip3: Python package manager
#
# Version Managers (detected if present):
# - asdf: Universal version manager
# - rbenv: Ruby version manager
# - nvm: Node version manager
# - pyenv: Python version manager
#
# Programming Languages (detected if present):
# - ruby, node, python/python3, crystal, elixir, rust, go, java
#
# Enhanced Tools (install for better performance):
# - gping: Better ping with statistics (brew install gping)

# Check for required dependencies
if ! command -v jq &> /dev/null; then
    echo '{"error": "jq is required but not installed. Install via: brew install jq"}'
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo '{"error": "curl is required but not installed. Install via: brew install curl"}'
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo '{"error": "bc is required but not installed. Install via: brew install bc"}'
    exit 1
fi

# Helper function to safely get command output with fallback
get_value() {
    local cmd="$1"
    local fallback="${2:-N/A}"
    result=$(eval "$cmd" 2>/dev/null)
    echo "${result:-$fallback}"
}

# Helper function to extract sysctl values
get_sysctl() {
    sysctl -n "$1" 2>/dev/null || echo "${2:-N/A}"
}

# Get hostname
hostname=$(get_value "scutil --get LocalHostName" "localhost")
# Get full hostname with domain
full_hostname=$(get_value "hostname -f" "$hostname")

# Get macOS version and build
macos_version=$(get_value "sw_vers -productVersion" "Unknown")
macos_build=$(get_value "sw_vers -buildVersion" "Unknown")
macos_name=$(awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}' | tr -d '\' 2>/dev/null)
if [ -z "$macos_name" ]; then
    macos_major=$(echo "$macos_version" | cut -d. -f1)
    case "$macos_major" in
        15) macos_name="Sequoia" ;;
        14) macos_name="Sonoma" ;;
        13) macos_name="Ventura" ;;
        12) macos_name="Monterey" ;;
        11) macos_name="Big Sur" ;;
        *) macos_name="macOS" ;;
    esac
fi

# Get kernel version
kernel_version=$(get_value "uname -r" "Unknown")
kernel_arch=$(get_value "uname -m" "Unknown")

# Get host model
host_model=$(get_sysctl "hw.model" "Unknown")

# Get shell
user_shell=$(basename "$SHELL")
shell_version=""
if [[ "$user_shell" == "fish" ]]; then
    shell_version=$(fish --version 2>/dev/null | awk '{print $3}')
elif [[ "$user_shell" == "zsh" ]]; then
    shell_version=$(zsh --version 2>/dev/null | awk '{print $2}')
elif [[ "$user_shell" == "bash" ]]; then
    shell_version=$(bash --version 2>/dev/null | head -1 | awk '{print $4}' | cut -d'(' -f1)
fi

# Get terminal - detect installed/running terminal apps
detect_terminal() {
    # Check for running terminal apps
    if pgrep -x "iTerm2" > /dev/null 2>&1 || [ -d "/Applications/iTerm.app" ]; then
        echo "iTerm2"
    elif pgrep -x "kitty" > /dev/null 2>&1 || [ -d "/Applications/kitty.app" ]; then
        echo "kitty"
    elif pgrep -x "Alacritty" > /dev/null 2>&1 || [ -d "/Applications/Alacritty.app" ]; then
        echo "Alacritty"
    elif pgrep -x "Warp" > /dev/null 2>&1 || [ -d "/Applications/Warp.app" ]; then
        echo "Warp"
    elif pgrep -x "Hyper" > /dev/null 2>&1 || [ -d "/Applications/Hyper.app" ]; then
        echo "Hyper"
    elif [ -d "/System/Applications/Utilities/Terminal.app" ] || [ -d "/Applications/Utilities/Terminal.app" ]; then
        echo "Terminal"
    else
        echo "Unknown"
    fi
}
terminal=$(detect_terminal)

# Get desktop environment and window manager (kept for compatibility)
desktop_env="Aqua"
window_manager="Quartz Compositor"

# Get appearance/theme
interface_style=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
if [ "$interface_style" == "Light" ]; then
    wm_theme="Light"
else
    wm_theme="Dark"
fi

# Check if auto appearance switching is enabled
auto_switch=$(defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null || echo "0")
if [ "$auto_switch" == "1" ]; then
    wm_theme="$wm_theme (Auto)"
fi

# Get CPU info
cpu_name=$(get_sysctl "machdep.cpu.brand_string" "Unknown" | sed 's/(R)//g;s/(TM)//g;s/CPU @ //g')
cpu_cores=$(get_sysctl "hw.physicalcpu" "0")
cpu_threads=$(get_sysctl "hw.logicalcpu" "0")

# Get uptime
boottime=$(get_sysctl "kern.boottime" | awk -F'[=,]' '{print $2}' | tr -d ' ')
current_time=$(date +%s)
uptime_seconds=$((current_time - boottime))
uptime_days=$((uptime_seconds / 86400))
uptime_hours=$(( (uptime_seconds % 86400) / 3600 ))
uptime_minutes=$(( (uptime_seconds % 3600) / 60 ))

# Get current date and time
current_date=$(date '+%Y-%m-%d')
current_time_display=$(date '+%H:%M')  # 24-hour format without seconds
current_datetime=$(date '+%Y-%m-%d %H:%M')  # Full datetime without seconds

# Get CPU usage - simplified extraction
cpu_usage=$(top -l 1 | awk '/^CPU/{print $3}' | tr -d '%')

# Get memory info
mem_total_bytes=$(get_sysctl "hw.memsize" "0")
mem_total_gb=$(echo "$mem_total_bytes" | awk '{printf "%.1f", $1/1073741824}')
mem_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | tr -d '%')
mem_used_percentage=$((100 - ${mem_pressure:-50}))
mem_used_gb=$(echo "$mem_total_gb $mem_used_percentage" | awk '{printf "%.1f", $1 * $2 / 100}')
# Get memory from top as backup
if [ -z "$mem_used_gb" ]; then
    mem_used=$(top -l 1 | grep PhysMem | awk '{print $2}' | tr -d 'M')
    mem_used_gb=$(echo "$mem_used" | awk '{printf "%.1f", $1/1024}')
fi

# Get GPU info
gpu_info=$(get_value "system_profiler SPDisplaysDataType | grep 'Chipset Model' | head -1 | awk -F': ' '{print \$2}'" "Unknown")

# Get disk usage - use APFS container info for accurate reporting on macOS
# APFS containers report actual used space correctly, unlike df which shows volume-specific usage
apfs_info=$(diskutil apfs list 2>/dev/null | grep -A5 "Container disk" | head -6)
if [ ! -z "$apfs_info" ]; then
    # Extract human-readable values from APFS container information
    disk_total=$(echo "$apfs_info" | grep "Size (Capacity Ceiling)" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p')
    disk_used=$(echo "$apfs_info" | grep "Capacity In Use By Volumes" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p')
    disk_percentage=$(echo "$apfs_info" | grep "Capacity In Use By Volumes" | sed -n 's/.*(\([0-9.]*%\).*/\1/p' | tr -d '%')
    disk_available=$(echo "$apfs_info" | grep "Capacity Not Allocated" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p')

    # Verify we got valid values
    if [ -z "$disk_total" ] || [ -z "$disk_used" ]; then
        # Fallback to df if APFS parsing fails
        disk_line=$(df -H / | tail -1)
        disk_total=$(echo "$disk_line" | awk '{print $2}')
        disk_used=$(echo "$disk_line" | awk '{print $3}')
        disk_available=$(echo "$disk_line" | awk '{print $4}')
        disk_percentage=$(echo "$disk_line" | awk '{print $5}' | tr -d '%')
    fi
elif command -v duf &> /dev/null; then
    # duf provides JSON output which is faster to parse
    disk_info=$(duf -json / 2>/dev/null | jq -r '.[0]')
    disk_total=$(echo "$disk_info" | jq -r '.size // "0"')
    disk_used=$(echo "$disk_info" | jq -r '.used // "0"')
    disk_available=$(echo "$disk_info" | jq -r '.avail // "0"')
    disk_percentage=$(echo "$disk_info" | jq -r '.use_percentage // 0' | cut -d. -f1)
else
    # Standard df command as last resort
    disk_line=$(df -H / | tail -1)
    disk_total=$(echo "$disk_line" | awk '{print $2}')
    disk_used=$(echo "$disk_line" | awk '{print $3}')
    disk_available=$(echo "$disk_line" | awk '{print $4}')
    disk_percentage=$(echo "$disk_line" | awk '{print $5}' | tr -d '%')
fi

# Get ALL network interfaces with IPs using a comprehensive scan
network_json="["
first=true

# Get all interfaces and their IPs, excluding loopback
for line in $(ifconfig | grep -E "^[a-zA-Z]" | cut -d: -f1 | sort -u); do
    if [ "$line" != "lo0" ]; then
        ip=$(ifconfig "$line" 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -1)
        if [ ! -z "$ip" ]; then
            # Determine interface type
            type="unknown"
            name="$line"

            # Categorize interface
            case "$line" in
                en0) type="wifi"; name="Wi-Fi";;
                en[1-9]) type="ethernet"; name="Ethernet ($line)";;
                bridge[0-9]*)
                    # Bridge interfaces are often used by Docker or VMs
                    # Check IP range to better identify
                    if echo "$ip" | grep -q "^192\.168\."; then
                        type="vm"; name="VM Bridge ($line)"
                    elif echo "$ip" | grep -q "^198\.19\."; then
                        type="docker"; name="Docker ($line)"
                    else
                        type="bridge"; name="Bridge ($line)"
                    fi
                    ;;
                utun[0-9]|utun[1-9][0-9])
                    # Check if it's Tailscale (usually 100.x.x.x range)
                    if echo "$ip" | grep -q "^100\."; then
                        type="tailscale"
                        name="Tailscale ($line)"
                    else
                        type="vpn"
                        name="VPN ($line)"
                    fi
                    ;;
                vnic*) type="parallels"; name="Parallels ($line)";;
                vboxnet*) type="virtualbox"; name="VirtualBox ($line)";;
                awdl*) type="airdrop"; name="AirDrop ($line)";;
                llw*) type="lowlatency"; name="Low Latency WiFi ($line)";;
                ap[0-9]) type="hotspot"; name="Hotspot ($line)";;
                *) type="other"; name="$line";;
            esac

            if [ "$first" = true ]; then
                first=false
            else
                network_json+=","
            fi
            network_json+="{\"interface\":\"$line\",\"name\":\"$name\",\"type\":\"$type\",\"ip\":\"$ip\"}"
        fi
    fi
done
network_json+="]"

# Get Wi-Fi SSID if connected
wifi_ssid=$(get_value "networksetup -getairportnetwork en0 | awk -F': ' '{print \$2}'" "")

# Get primary/default route interface
primary_iface=$(get_value "route -n get default | grep interface | awk '{print \$2}'" "")
primary_ip=$(get_value "ifconfig '$primary_iface' | grep 'inet ' | awk '{print \$2}' | head -1" "")

# Get public IP and location info with caching to avoid rate limits
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_file="$script_dir/.cache.json"

# JSON cache helper functions
read_cache_value() {
    local key="$1"
    local default="${2:-}"
    if [ -f "$cache_file" ] && command -v jq &> /dev/null; then
        value=$(jq -r ".$key // empty" "$cache_file" 2>/dev/null)
        if [ ! -z "$value" ] && [ "$value" != "null" ]; then
            echo "$value"
        else
            echo "$default"
        fi
    else
        echo "$default"
    fi
}

write_cache_values() {
    local json_data="$1"
    if command -v jq &> /dev/null; then
        if [ -f "$cache_file" ]; then
            # Merge with existing cache
            merged=$(jq -s '.[0] * .[1]' "$cache_file" <(echo "$json_data") 2>/dev/null)
            if [ ! -z "$merged" ]; then
                echo "$merged" > "$cache_file"
            else
                echo "$json_data" > "$cache_file"
            fi
        else
            echo "$json_data" > "$cache_file"
        fi
    fi
}

# Function to get and cache public IP info
get_public_ip_info() {
    local ip_check_interval=300    # 5 minutes - check IP only
    local full_info_duration=3600  # 1 hour - full info refresh
    local current_time=$(date +%s)
    local need_ip_check=false
    local need_full_update=false

    # Check cached values
    ip_cache_time=$(read_cache_value "ip_cache_timestamp" "0")
    ip_check_time=$(read_cache_value "ip_check_timestamp" "0")

    if [ "$ip_cache_time" != "0" ]; then
        # Check if we need full info update (1 hour)
        time_diff=$((current_time - ip_cache_time))
        if [ $time_diff -gt $full_info_duration ]; then
            need_full_update=true
        else
            # Check if we need IP check only (5 minutes)
            if [ "$ip_check_time" != "0" ]; then
                check_diff=$((current_time - ip_check_time))
                if [ $check_diff -gt $ip_check_interval ]; then
                    need_ip_check=true
                fi
            else
                need_ip_check=true
            fi

            # Read cached values
            public_ip=$(read_cache_value "public_ip" "")
            public_city=$(read_cache_value "public_city" "")
            public_region=$(read_cache_value "public_region" "")
            public_country=$(read_cache_value "public_country" "")
            public_org=$(read_cache_value "public_org" "")
            public_hostname=$(read_cache_value "public_hostname" "")
        fi
    else
        need_full_update=true
    fi

    # Do quick IP check if needed (every 5 minutes)
    if [ "$need_ip_check" = true ] && [ "$need_full_update" = false ]; then
        # Quick IP check using ipinfo.io/ip (less data, less likely to hit rate limit)
        current_ip=$(curl -s --max-time 2 https://ipinfo.io/ip 2>/dev/null || echo "")

        if [ ! -z "$current_ip" ] && [ "$current_ip" != "$public_ip" ]; then
            # IP changed, force full update
            need_full_update=true
        else
            # Update check timestamp only
            write_cache_values "{\"ip_check_timestamp\": $current_time}"
        fi
    fi

    if [ "$need_full_update" = true ]; then
        # Try ipinfo.io first (with reduced timeout to fail faster if rate limited)
        ipinfo_data=$(curl -s --max-time 2 https://ipinfo.io 2>/dev/null || echo '{}')

        # Check if we got rate limited
        if echo "$ipinfo_data" | jq -e '.status == 429' >/dev/null 2>&1; then
            # Rate limited, use fallback methods
            public_ip=$(curl -s --max-time 2 https://api.ipify.org 2>/dev/null ||
                       curl -s --max-time 2 https://checkip.amazonaws.com 2>/dev/null ||
                       curl -s --max-time 2 https://icanhazip.com 2>/dev/null ||
                       echo "N/A")

            # Try to get location from timezone/locale
            public_city=""
            public_region=""
            public_country=$(defaults read .GlobalPreferences Country 2>/dev/null || echo "")

            # Try to get ISP from reverse DNS
            if [ "$public_ip" != "N/A" ]; then
                public_hostname=$(nslookup "$public_ip" 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//')
                # Extract ISP from hostname if possible
                if [ ! -z "$public_hostname" ]; then
                    # Common patterns: xxx.comcast.net, xxx.att.net, etc.
                    public_org=$(echo "$public_hostname" | awk -F'.' '{print $(NF-1)"."$NF}')
                else
                    public_org=""
                fi
            else
                public_org=""
                public_hostname=""
            fi
        else
            # Parse successful ipinfo response
            public_ip=$(echo "$ipinfo_data" | jq -r '.ip // "N/A"')
            public_city=$(echo "$ipinfo_data" | jq -r '.city // ""')
            public_region=$(echo "$ipinfo_data" | jq -r '.region // ""')
            public_country=$(echo "$ipinfo_data" | jq -r '.country // ""')
            public_org=$(echo "$ipinfo_data" | jq -r '.org // ""')
            public_hostname=$(echo "$ipinfo_data" | jq -r '.hostname // ""')

            # Fallback to other services if ipinfo didn't return IP
            if [ "$public_ip" = "N/A" ]; then
                public_ip=$(curl -s --max-time 2 https://api.ipify.org 2>/dev/null || echo "N/A")
            fi
        fi

        # Only update cache if we got valid data
        if [ "$public_ip" != "N/A" ] || [ ! -z "$public_country" ]; then
            # Write new IP data to cache
            cache_json=$(cat <<EOF
{
    "ip_cache_timestamp": $current_time,
    "ip_check_timestamp": $current_time,
    "public_ip": "$public_ip",
    "public_city": "$public_city",
    "public_region": "$public_region",
    "public_country": "$public_country",
    "public_org": "$public_org",
    "public_hostname": "$public_hostname"
}
EOF
            )
            write_cache_values "$cache_json"
        fi
    fi
}

# Get public IP info (from cache or fresh)
get_public_ip_info

# Format location
public_location=""
if [ ! -z "$public_city" ] && [ ! -z "$public_region" ] && [ ! -z "$public_country" ]; then
    public_location="$public_city, $public_region, $public_country"
elif [ ! -z "$public_country" ]; then
    # Try to expand country code to full name if it's just a code
    if [ "${#public_country}" -eq 2 ]; then
        case "$public_country" in
            US) public_location="United States" ;;
            CA) public_location="Canada" ;;
            GB) public_location="United Kingdom" ;;
            DE) public_location="Germany" ;;
            FR) public_location="France" ;;
            JP) public_location="Japan" ;;
            AU) public_location="Australia" ;;
            *) public_location="$public_country" ;;
        esac
    else
        public_location="$public_country"
    fi
fi

# Get network traffic stats
# Note: cache_file already defined above for IP caching

get_network_traffic() {
    # Get primary interface
    primary_if=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')

    if [ ! -z "$primary_if" ]; then
        # Get current bytes
        stats=$(netstat -b -I "$primary_if" 2>/dev/null | tail -1)
        bytes_in=$(echo "$stats" | awk '{print $7}')
        bytes_out=$(echo "$stats" | awk '{print $10}')

        current_time=$(date +%s)

        # Read previous traffic values from cache
        prev_time=$(read_cache_value "traffic_timestamp" "0")
        prev_in=$(read_cache_value "traffic_bytes_in" "0")
        prev_out=$(read_cache_value "traffic_bytes_out" "0")

        # Calculate time difference
        if [ "$prev_time" != "0" ]; then
            time_diff=$((current_time - prev_time))

            if [ $time_diff -gt 0 ] && [ $time_diff -lt 60 ]; then
                # Calculate bytes per second
                bytes_per_sec_in=$(( (bytes_in - prev_in) / time_diff ))
                bytes_per_sec_out=$(( (bytes_out - prev_out) / time_diff ))

                # Convert to human readable (KB/s or MB/s)
                if [ $bytes_per_sec_in -gt 1048576 ]; then
                    traffic_down=$(echo "$bytes_per_sec_in" | awk '{printf "%.1f MB/s", $1/1048576}')
                else
                    traffic_down=$(echo "$bytes_per_sec_in" | awk '{printf "%.1f KB/s", $1/1024}')
                fi

                if [ $bytes_per_sec_out -gt 1048576 ]; then
                    traffic_up=$(echo "$bytes_per_sec_out" | awk '{printf "%.1f MB/s", $1/1048576}')
                else
                    traffic_up=$(echo "$bytes_per_sec_out" | awk '{printf "%.1f KB/s", $1/1024}')
                fi
            else
                traffic_down="0.0 KB/s"
                traffic_up="0.0 KB/s"
            fi
        else
            traffic_down="0.0 KB/s"
            traffic_up="0.0 KB/s"
        fi

        # Update traffic values in cache
        traffic_json=$(cat <<EOF
{
    "traffic_timestamp": $current_time,
    "traffic_bytes_in": $bytes_in,
    "traffic_bytes_out": $bytes_out
}
EOF
        )
        write_cache_values "$traffic_json"
    else
        traffic_down="N/A"
        traffic_up="N/A"
    fi
}

# Get network traffic
get_network_traffic

# Function to get top network apps by current traffic rate
get_network_apps() {
    local app_count="${1:-3}"  # Default to 3 apps if not specified
    local skip_apps="${2:-}"   # Comma-separated list of apps to skip

    # Convert skip list to awk pattern
    local skip_pattern=""
    if [ ! -z "$skip_apps" ]; then
        skip_pattern=$(echo "$skip_apps" | sed 's/,/|/g')
    fi

    # Use nettop with sampling to calculate rate
    local nettop_output
    if command -v nettop &> /dev/null; then
        # Capture two samples 1 second apart to calculate rate
        # First sample
        first_sample=$(nettop -P -x -L 1 2>/dev/null | tail -n +2 || echo "")
        sleep 1
        # Second sample
        second_sample=$(nettop -P -x -L 1 2>/dev/null | tail -n +2 || echo "")

        if [ ! -z "$first_sample" ] && [ ! -z "$second_sample" ]; then
            # Combine samples and calculate differences
            nettop_output=$(echo -e "$first_sample\n---SEPARATOR---\n$second_sample")

            # Parse both samples and calculate rate
            echo "$nettop_output" | awk -F',' -v skip_pattern="$skip_pattern" '
                BEGIN { sample = 1 }
                /---SEPARATOR---/ { sample = 2; next }

                $2 != "" && $5 != "" && $6 != "" {
                    # Extract process name from field 2 (process.pid)
                    process_field = $2

                    # Skip TCP/UDP connection lines
                    if (process_field ~ /^(tcp[46]|udp[46])/) next

                    # Remove the .pid suffix
                    split(process_field, parts, ".")
                    process = parts[1]

                    # Skip empty or system headers
                    if (process == "" || process == "time") next

                    # Skip apps in the skip list
                    if (skip_pattern != "" && process ~ skip_pattern) next

                    # Get bytes from fields 5 and 6
                    bytes_in = $5 + 0
                    bytes_out = $6 + 0

                    if (sample == 1) {
                        # Store first sample
                        first_in[process] = bytes_in
                        first_out[process] = bytes_out
                    } else if (sample == 2) {
                        # Calculate rate (bytes per second)
                        if (process in first_in) {
                            rate_in = bytes_in - first_in[process]
                            rate_out = bytes_out - first_out[process]

                            # Only store positive rates
                            if (rate_in >= 0 && rate_out >= 0) {
                                total_rate_in[process] = rate_in
                                total_rate_out[process] = rate_out
                            }
                        }
                    }
                }
                END {
                    # Output rate data for each process
                    for (proc in total_rate_in) {
                        total = total_rate_in[proc] + total_rate_out[proc]
                        if (total > 0) {
                            print proc "|" total_rate_in[proc] "|" total_rate_out[proc] "|" total
                        }
                    }
                }
            ' | sort -t'|' -k4 -rn | head -n "$app_count" | while IFS='|' read -r app down up total; do
                # Format bytes/sec to human readable rates
                down_rate=$(format_rate "$down")
                up_rate=$(format_rate "$up")
                total_rate=$(format_rate "$total")

                if [ "$first_app" = true ]; then
                    first_app=false
                else
                    echo -n ","
                fi
                echo -n "{\"name\":\"$app\",\"down\":\"$down_rate\",\"up\":\"$up_rate\",\"total\":\"$total_rate\"}"
            done
        fi
    fi
}

# Helper function to format bytes
format_bytes() {
    local bytes="$1"
    if [ -z "$bytes" ] || [ "$bytes" = "0" ]; then
        echo "0 B"
    elif [ "$bytes" -lt 1024 ]; then
        echo "$bytes B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$(echo "scale=1; $bytes/1024" | bc) KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$(echo "scale=1; $bytes/1048576" | bc) MB"
    else
        echo "$(echo "scale=1; $bytes/1073741824" | bc) GB"
    fi
}

# Helper function to format bytes/sec rates
format_rate() {
    local bytes_per_sec="$1"
    if [ -z "$bytes_per_sec" ] || [ "$bytes_per_sec" = "0" ]; then
        echo "0 B/s"
    elif [ "$bytes_per_sec" -lt 1024 ]; then
        echo "$bytes_per_sec B/s"
    elif [ "$bytes_per_sec" -lt 1048576 ]; then
        echo "$(echo "scale=1; $bytes_per_sec/1024" | bc) KB/s"
    elif [ "$bytes_per_sec" -lt 1073741824 ]; then
        echo "$(echo "scale=1; $bytes_per_sec/1048576" | bc) MB/s"
    else
        echo "$(echo "scale=1; $bytes_per_sec/1073741824" | bc) GB/s"
    fi
}

# Get top network apps (configurable count, default 5)
network_apps_count="${NETWORK_APPS_COUNT:-5}"
skip_apps="${SKIP_NETWORK_APPS:-}"
first_app=true
network_apps="["
app_data=$(get_network_apps "$network_apps_count" "$skip_apps")
if [ ! -z "$app_data" ]; then
    network_apps+="$app_data"
fi
network_apps+="]"

# Get ping latency - use gping if available for better accuracy
ping_target="8.8.8.8"
if command -v gping &> /dev/null; then
    # gping provides more accurate measurements
    ping_latency=$(gping -c 1 --buffer 0 $ping_target 2>/dev/null | tail -1 | awk '{print $NF}' | tr -d 'ms')
else
    ping_latency=$(ping -c 1 -t 1 $ping_target 2>/dev/null | awk -F'time=' '/time=/{print $2}' | awk '{print $1}')
fi
[ -z "$ping_latency" ] && ping_latency="N/A"

# Get battery info
battery_info=$(pmset -g batt)
battery_percentage=$(echo "$battery_info" | grep -o -E "([0-9]{1,3})%" | head -n 1 | tr -d '%')
charging_status="No"
if echo "$battery_info" | grep -q 'AC Power'; then
    charging_status="Yes"
elif echo "$battery_info" | grep -q 'charged'; then
    charging_status="Charged"
fi

# Get battery health metrics (MacBooks only)
if system_profiler SPPowerDataType 2>/dev/null | grep -q "Cycle Count"; then
    battery_cycles=$(system_profiler SPPowerDataType 2>/dev/null | grep "Cycle Count" | awk '{print $3}')
    battery_condition=$(system_profiler SPPowerDataType 2>/dev/null | grep "Condition" | awk '{print $2}')
    battery_max_capacity=$(system_profiler SPPowerDataType 2>/dev/null | grep "Maximum Capacity" | awk '{print $3}' | tr -d '%')
else
    battery_cycles="N/A"
    battery_condition="N/A"
    battery_max_capacity="N/A"
fi

# Get Time Machine backup status
tm_running="No"
tm_percent="0"
tm_last_backup="N/A"
tm_destination="N/A"
if command -v tmutil &> /dev/null; then
    tm_status=$(tmutil status 2>/dev/null || echo "")
    if [ ! -z "$tm_status" ]; then
        # Check if backup is running (look for "Running = 1")
        if echo "$tm_status" | grep -q "Running = 1"; then
            tm_running="Yes"
            # Get percentage - it's in the Progress section
            raw_percent=$(echo "$tm_status" | grep "Percent = " | head -1 | awk -F'"' '{print $2}')
            if [ ! -z "$raw_percent" ]; then
                tm_percent=$(echo "$raw_percent" | awk '{printf "%.1f", $1 * 100}')
            fi
            # Get destination - sanitize for JSON
            raw_destination=$(echo "$tm_status" | grep "DestinationMountPoint = " | awk -F'"' '{print $2}')
            if [ ! -z "$raw_destination" ]; then
                tm_destination=$(basename "$raw_destination" 2>/dev/null | tr -d '\n\r\t' | sed 's/[[:cntrl:]]//g' || echo "Backup Drive")
            fi
        fi
        # Get last successful backup
        last_backup_path=$(tmutil latestbackup 2>/dev/null || echo "")
        if [ ! -z "$last_backup_path" ]; then
            # Extract date from backup path (format: YYYY-MM-DD-HHMMSS)
            backup_name=$(basename "$last_backup_path" 2>/dev/null)
            if [[ "$backup_name" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
                year="${BASH_REMATCH[1]}"
                month="${BASH_REMATCH[2]}"
                day="${BASH_REMATCH[3]}"
                hour="${BASH_REMATCH[4]}"
                min="${BASH_REMATCH[5]}"
                # Format as ISO/Military time "YYYY-MM-DD HH:MM"
                tm_last_backup="${year}-${month}-${day} ${hour}:${min}"
            else
                tm_last_backup="N/A"
            fi
        fi
    fi
fi

# Function to get top CPU processes (similar to network apps)
get_top_processes() {
    local proc_count="${1:-3}"  # Default to 3 processes
    local first_proc=true

    # Get top processes by CPU usage
    ps aux | awk 'NR>1 {print $3 "|" $11}' | sort -t'|' -k1 -rn | head -n "$proc_count" | while IFS='|' read -r cpu cmd; do
        # Clean up command name (basename only)
        cmd_name=$(basename "$cmd" 2>/dev/null | cut -d' ' -f1)

        if [ "$first_proc" = true ]; then
            first_proc=false
        else
            echo -n ","
        fi
        echo -n "{\"name\":\"$cmd_name\",\"cpu\":\"$cpu%\"}"
    done
}

# Get top CPU processes
top_processes="["
top_proc_data=$(get_top_processes 3)
if [ ! -z "$top_proc_data" ]; then
    top_processes+="$top_proc_data"
fi
top_processes+="]"

# Get all resolutions
resolutions=$(get_value "system_profiler SPDisplaysDataType | grep Resolution | awk '{print \$2 \"x\" \$4}' | paste -sd ', ' -" "Unknown")

# Get current user
current_user=$(get_value "whoami" "unknown")

# Detect version manager (asdf, rbenv, nvm, etc.)
# Need to ensure asdf is in PATH and initialized
export PATH="/opt/homebrew/bin:$PATH"

# Source asdf if available (suppress output)
if [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh 2>/dev/null
elif [ -f "$HOME/.asdf/asdf.sh" ]; then
    . $HOME/.asdf/asdf.sh 2>/dev/null
fi

version_manager="none"
if command -v asdf &> /dev/null; then
    version_manager="asdf"
elif command -v rbenv &> /dev/null; then
    version_manager="rbenv"
elif command -v nvm &> /dev/null; then
    version_manager="nvm"
elif command -v pyenv &> /dev/null; then
    version_manager="pyenv"
fi

# Get language versions
# Function to get language version based on manager
get_language_version() {
    local lang="$1"
    local version="N/A"

    if [ "$version_manager" = "asdf" ]; then
        # Use asdf for version detection
        # asdf current outputs: Name Version Source Installed
        case "$lang" in
            ruby)
                version=$(asdf current ruby 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            nodejs|node)
                version=$(asdf current nodejs 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            python)
                version=$(asdf current python 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            crystal)
                version=$(asdf current crystal 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            elixir)
                version=$(asdf current elixir 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            rust)
                version=$(asdf current rust 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            go|golang)
                version=$(asdf current golang 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
            java)
                version=$(asdf current java 2>/dev/null | tail -1 | awk '{print $2}' || echo "N/A")
                ;;
        esac
    else
        # Fallback to direct commands if no version manager or different manager
        case "$lang" in
            ruby)
                version=$(ruby --version 2>/dev/null | awk '{print $2}' || echo "N/A")
                ;;
            nodejs|node)
                version=$(node --version 2>/dev/null | sed 's/^v//' || echo "N/A")
                ;;
            python)
                version=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
                ;;
            crystal)
                version=$(crystal --version 2>/dev/null | head -1 | awk '{print $2}' || echo "N/A")
                ;;
            elixir)
                version=$(elixir --version 2>/dev/null | grep "Elixir" | awk '{print $2}' || echo "N/A")
                ;;
            rust)
                version=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "N/A")
                ;;
            go|golang)
                version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
                ;;
            java)
                version=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}' || echo "N/A")
                ;;
        esac
    fi

    echo "$version"
}

# Get versions for common languages
lang_ruby=$(get_language_version "ruby")
lang_nodejs=$(get_language_version "nodejs")
lang_python=$(get_language_version "python")
lang_crystal=$(get_language_version "crystal")
lang_elixir=$(get_language_version "elixir")
lang_rust=$(get_language_version "rust")
lang_go=$(get_language_version "go")
lang_java=$(get_language_version "java")

# Get package count for both brew installations
# Intel brew at /usr/local/bin/brew (x86_64)
# Apple Silicon brew at /opt/homebrew/bin/brew (arm64)

# Intel brew stats
if [ -x "/usr/local/bin/brew" ]; then
    packages_brew_intel=$(/usr/local/bin/brew list 2>/dev/null | wc -l | tr -d ' ' || echo "0")
else
    packages_brew_intel="0"
fi

# ARM brew stats
if [ -x "/opt/homebrew/bin/brew" ]; then
    packages_brew_arm=$(/opt/homebrew/bin/brew list 2>/dev/null | wc -l | tr -d ' ' || echo "0")
else
    packages_brew_arm="0"
fi

# Total packages from both
packages_brew_total=$((packages_brew_intel + packages_brew_arm))

# For compatibility, set the primary brew (Intel first, then ARM)
if [ -x "/usr/local/bin/brew" ]; then
    BREW_CMD="/usr/local/bin/brew"
    packages_brew="$packages_brew_intel"
elif [ -x "/opt/homebrew/bin/brew" ]; then
    BREW_CMD="/opt/homebrew/bin/brew"
    packages_brew="$packages_brew_arm"
else
    BREW_CMD=""
    packages_brew="0"
fi

# Check for outdated packages for both brew installations using cache
# script_dir and cache_file already defined above
cache_age_limit=3600  # Cache for 1 hour

# Function to write structured cache for both brews
write_cache() {
    local intel_count="$1"
    local arm_count="$2"
    local timestamp=$(date +%s)

    # Write brew data to JSON cache
    brew_json=$(cat <<EOF
{
    "brew_outdated_intel": $intel_count,
    "brew_outdated_arm": $arm_count,
    "brew_timestamp": $timestamp
}
EOF
    )
    write_cache_values "$brew_json"
}

# Check if cache exists and is recent
cache_timestamp=$(read_cache_value "brew_timestamp" "0")
cache_age=$(($(date +%s) - cache_timestamp))

if [ $cache_age -lt $cache_age_limit ] && [ "$cache_timestamp" != "0" ]; then
    # Use cached values
    packages_outdated_intel=$(read_cache_value "brew_outdated_intel" "0")
    packages_outdated_arm=$(read_cache_value "brew_outdated_arm" "0")
elif [ "$cache_timestamp" != "0" ]; then
    # Cache is old, update it in background
    # Read old values first
    packages_outdated_intel=$(read_cache_value "brew_outdated_intel" "0")
    packages_outdated_arm=$(read_cache_value "brew_outdated_arm" "0")

    # Update in background
    (
        intel_count="0"
        arm_count="0"
        [ -x "/usr/local/bin/brew" ] && intel_count=$(/usr/local/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        [ -x "/opt/homebrew/bin/brew" ] && arm_count=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        write_cache "$intel_count" "$arm_count"
    ) &
else
    # No cache, create it in background
    packages_outdated_intel="0"
    packages_outdated_arm="0"
    (
        intel_count="0"
        arm_count="0"
        [ -x "/usr/local/bin/brew" ] && intel_count=$(/usr/local/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        [ -x "/opt/homebrew/bin/brew" ] && arm_count=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        write_cache "$intel_count" "$arm_count"
    ) &
fi

# For backwards compatibility, set main outdated count
packages_outdated="$packages_outdated_intel"

# Get last upgrade time from primary brew
if [ ! -z "$BREW_CMD" ]; then
    brew_prefix=$($BREW_CMD --prefix 2>/dev/null || echo "/usr/local")
    update_file="$brew_prefix/Homebrew/.git/FETCH_HEAD"

    if [ -f "$update_file" ]; then
        # Get file modification time in seconds since epoch
        last_update=$(stat -f %m "$update_file" 2>/dev/null)

        if [ ! -z "$last_update" ]; then
            current_time=$(date +%s)
            time_diff=$((current_time - last_update))
            days_since=$((time_diff / 86400))
            hours_since=$(( (time_diff % 86400) / 3600 ))

            if [ $days_since -gt 0 ]; then
                brew_update_status="${days_since}d ago"
            elif [ $hours_since -gt 0 ]; then
                brew_update_status="${hours_since}h ago"
            else
                brew_update_status="< 1h ago"
            fi
        else
            brew_update_status="unknown"
        fi
    else
        brew_update_status="never"
    fi
else
    brew_update_status="N/A"
fi

# Ensure all package values have defaults
packages_outdated=${packages_outdated:-0}
packages_outdated_intel=${packages_outdated_intel:-0}
packages_outdated_arm=${packages_outdated_arm:-0}

# For other package managers, we'll skip them if they take too long
# These often hang or are very slow
packages_cask="0"
packages_npm="0"
packages_pip="0"

# Total is now tracked as packages_brew_total above
packages_total="$packages_brew_total"

# Output JSON
cat <<EOF
{
  "system": {
    "hostname": "$hostname",
    "full_hostname": "$full_hostname",
    "username": "$current_user",
    "os": "$macos_name $macos_version $macos_build $kernel_arch",
    "host": "$host_model",
    "kernel": "$kernel_version",
    "build": "$macos_build",
    "shell": "$user_shell $shell_version",
    "terminal": "$terminal",
    "desktop_env": "$desktop_env",
    "window_manager": "$window_manager",
    "wm_theme": "$wm_theme",
    "uptime_days": $uptime_days,
    "uptime_hours": $uptime_hours,
    "uptime_minutes": $uptime_minutes,
    "current_date": "$current_date",
    "current_time": "$current_time_display",
    "current_datetime": "$current_datetime",
    "packages": "$packages_brew_total",
    "packages_brew": "$packages_brew",
    "packages_brew_intel": "$packages_brew_intel",
    "packages_brew_arm": "$packages_brew_arm",
    "packages_outdated": "$packages_outdated",
    "packages_outdated_intel": "$packages_outdated_intel",
    "packages_outdated_arm": "$packages_outdated_arm",
    "brew_update_status": "$brew_update_status",
    "packages_cask": "$packages_cask",
    "packages_npm": "$packages_npm",
    "packages_pip": "$packages_pip",
    "version_manager": "$version_manager",
    "lang_ruby": "$lang_ruby",
    "lang_nodejs": "$lang_nodejs",
    "lang_python": "$lang_python",
    "lang_crystal": "$lang_crystal",
    "lang_elixir": "$lang_elixir",
    "lang_rust": "$lang_rust",
    "lang_go": "$lang_go",
    "lang_java": "$lang_java"
  },
  "hardware": {
    "cpu": "$cpu_name",
    "cpu_cores": $cpu_cores,
    "cpu_threads": $cpu_threads,
    "cpu_usage": "$cpu_usage",
    "gpu": "$gpu_info",
    "memory_total": "$mem_total_gb",
    "memory_used": "$mem_used_gb",
    "memory_percentage": $mem_used_percentage,
    "resolution": "$resolutions"
  },
  "storage": {
    "disk_used": "$disk_used",
    "disk_total": "$disk_total",
    "disk_available": "$disk_available",
    "disk_percentage": "$disk_percentage"
  },
  "network": {
    "interfaces": $network_json,
    "primary_ip": "$primary_ip",
    "primary_iface": "$primary_iface",
    "wifi_ssid": "$wifi_ssid",
    "public_ip": "$public_ip",
    "public_hostname": "$public_hostname",
    "public_location": "$public_location",
    "public_org": "$public_org",
    "ping_target": "$ping_target",
    "ping": "$ping_latency",
    "traffic_down": "$traffic_down",
    "traffic_up": "$traffic_up",
    "apps": $network_apps
  },
  "battery": {
    "percentage": "$battery_percentage",
    "charging": "$charging_status",
    "cycles": "$battery_cycles",
    "condition": "$battery_condition",
    "max_capacity": "$battery_max_capacity"
  },
  "backup": {
    "time_machine_running": "$tm_running",
    "time_machine_percent": "$tm_percent",
    "last_backup": "$tm_last_backup",
    "destination": "$tm_destination"
  },
  "processes": {
    "top_cpu": $top_processes
  }
}
EOF
