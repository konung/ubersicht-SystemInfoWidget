#!/bin/bash
# System and hardware information

# Source core functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

get_system_info() {
    # Basic system info (all fast)
    # Get computer name (actual Mac name) vs network hostname
    local hostname=$(scutil --get ComputerName 2>/dev/null || hostname -s)
    local network_hostname=$(hostname -s)
    local full_hostname=$(hostname -f)
    local username=$(whoami)
    local os="$(sw_vers -productName) $(sw_vers -productVersion) $(sw_vers -buildVersion) $(uname -m)"
    local host=$(sysctl -n hw.model 2>/dev/null || echo "Unknown")
    local kernel=$(uname -r)
    local build=$(sw_vers -buildVersion)
    local shell="$(basename $SHELL)"
    local shell_version=""
    # Get shell version based on shell type
    case "$shell" in
        zsh)
            shell_version="$($SHELL --version | awk '{print $2}')"
            ;;
        bash)
            shell_version="$($SHELL --version | head -1 | awk '{print $4}')"
            ;;
        fish)
            shell_version="$($SHELL --version | awk '{print $3}')"
            ;;
        *)
            shell_version="unknown"
            ;;
    esac
    local desktop_env="Aqua"
    local window_manager="Quartz Compositor"
    local wm_theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light')

    # Uptime calculation - more robust parsing
    local uptime_str=$(uptime)
    local days=0 hours=0 minutes=0

    # Extract days if present (handle both "day" and "days")
    if [[ "$uptime_str" == *"day"* ]]; then
        days=$(echo "$uptime_str" | grep -o '[0-9]\+ day' | grep -o '[0-9]\+' | head -1)
        # Extract time part after days: "23:29" -> hours=23, minutes=29
        local time_part=$(echo "$uptime_str" | sed 's/.*day[s]*,[ ]*//' | sed 's/,.*//' | tr -d ' ')
        if [[ "$time_part" == *":"* ]]; then
            hours=$(echo "$time_part" | cut -d: -f1)
            minutes=$(echo "$time_part" | cut -d: -f2)
        fi
    elif [[ "$uptime_str" == *"hrs"* ]]; then
        # Format like "up 2 hrs, 30 mins"
        hours=$(echo "$uptime_str" | grep -o '[0-9]\+ hrs' | grep -o '[0-9]\+')
        minutes=$(echo "$uptime_str" | grep -o '[0-9]\+ mins' | grep -o '[0-9]\+')
    else
        # Format like "up 1:23" or "up 23 mins"
        if [[ "$uptime_str" == *":"* ]]; then
            local time_part=$(echo "$uptime_str" | grep -o 'up [0-9:]\+' | grep -o '[0-9:]\+')
            hours=$(echo "$time_part" | cut -d: -f1)
            minutes=$(echo "$time_part" | cut -d: -f2)
        elif [[ "$uptime_str" == *"mins"* ]]; then
            minutes=$(echo "$uptime_str" | grep -o '[0-9]\+ mins' | grep -o '[0-9]\+')
        fi
    fi

    # Extract load averages
    local load_avg=$(echo "$uptime_str" | grep -o 'load averages*: .*' | cut -d: -f2 | sed 's/^ *//' | tr -s ' ' ',')
    if [ -z "$load_avg" ]; then
        # Try alternative format
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//' | tr -s ' ' ',')
    fi

    # Ensure values are numeric and not empty
    days=$(echo "$days" | grep -o '^[0-9]\+$' || echo "0")
    hours=$(echo "$hours" | grep -o '^[0-9]\+$' || echo "0")
    minutes=$(echo "$minutes" | grep -o '^[0-9]\+$' || echo "0")

    # Process and thread counts
    local processes=$(ps aux | wc -l | tr -d ' ')
    local threads=$(sysctl -n hw.ncpu)

    cat <<EOF
{
    "hostname": "$hostname",
    "network_hostname": "$network_hostname",
    "full_hostname": "$full_hostname",
    "username": "$username",
    "os": "$os",
    "host": "$host",
    "kernel": "$kernel",
    "build": "$build",
    "shell": "$shell",
    "shell_version": "$shell_version",
    "desktop_env": "$desktop_env",
    "window_manager": "$window_manager",
    "wm_theme": "$wm_theme",
    "uptime_days": $days,
    "uptime_hours": $hours,
    "uptime_minutes": $minutes,
    "load_avg": "$load_avg",
    "current_date": "$(date +%Y-%m-%d)",
    "current_time": "$(date +%H:%M)",
    "current_datetime": "$(date +"%Y-%m-%d %H:%M")",
    "processes": $processes,
    "threads": $threads
}
EOF
}

get_hardware_info() {
    # Check cache first for expensive STATIC hardware info
    local hw_cache_timestamp=$(read_cache_value "hw_cache_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - hw_cache_timestamp))

    # Get static hardware info from cache if available
    local cpu_model=""
    local gpu=""
    local resolution=""
    local display_count=""
    local audio_device=""

    # Use cache for static info if less than 30 seconds old (for audio switching)
    if [ $cache_age -lt 30 ] && [ "$hw_cache_timestamp" != "0" ]; then
        local cached_hw=$(read_cache_value "hardware_info" "{}")
        if [ "$cached_hw" != "{}" ] && [ "$cached_hw" != "null" ]; then
            # Extract static values from cache
            cpu_model=$(echo "$cached_hw" | jq -r '.cpu // empty')
            gpu=$(echo "$cached_hw" | jq -r '.gpu // empty')
            resolution=$(echo "$cached_hw" | jq -r '.resolution // empty')
            display_count=$(echo "$cached_hw" | jq -r '.display_count // empty')
            audio_device=$(echo "$cached_hw" | jq -r '.audio_device // empty')
        fi
    fi

    # Get static hardware if not cached
    if [ -z "$cpu_model" ]; then
        cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | sed 's/ @ .*//' | tr -d '\000-\037' | sed 's/[[:cntrl:]]//g' || echo "Unknown")
    fi

    # Always get dynamic values fresh (not from cache)
    local cpu_threads=$(sysctl -n hw.ncpu 2>/dev/null || echo "1")
    local cpu_usage=$(ps aux | awk 'BEGIN {sum=0} {sum+=$3} END {printf "%.1f", sum}')

    # Memory calculation
    local mem_total=$(sysctl -n hw.memsize)
    local mem_wired=$(vm_stat | awk '/Pages wired/ {print $4}' | tr -d '.')
    local mem_active=$(vm_stat | awk '/Pages active/ {print $3}' | tr -d '.')
    local mem_compressed=$(vm_stat | awk '/Pages occupied by compressor/ {print $5}' | tr -d '.')
    local mem_used=$(( (mem_wired + mem_active + mem_compressed) * 4096 ))
    local mem_total_gb=$(echo "$mem_total" | awk '{printf "%.0f", $1/1073741824}')
    local mem_used_gb=$(echo "$mem_used" | awk '{printf "%.1f", $1/1073741824}')

    # Swap calculation
    local swap_used=$(sysctl -n vm.swapusage 2>/dev/null | awk '{print $6}' | tr -d 'M')
    local swap_used_gb=$(echo "$swap_used" | awk '{printf "%.1f", $1/1024}')

    # Memory pressure
    local memory_pressure=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print $5}' | tr -d '%')
    if [ -z "$memory_pressure" ]; then
        # Alternative: check compressed pages as indicator
        local compressed_pages=$(vm_stat | awk '/Pages compressed/ {print $3}' | tr -d '.')
        local total_pages=$(vm_stat | awk '/Pages free/ {print $3}' | tr -d '.')
        if [ -n "$compressed_pages" ] && [ -n "$total_pages" ] && [ "$total_pages" != "0" ]; then
            memory_pressure=$(echo "$compressed_pages $total_pages" | awk '{printf "%.0f", ($1/$2)*100}')
        else
            memory_pressure="N/A"
        fi
    fi

    # Get static hardware info if not cached
    if [ -z "$display_count" ]; then
        display_count=$(system_profiler SPDisplaysDataType 2>/dev/null | tr -d '\000-\010\013-\037' | grep -c "Resolution:" || echo "1")
    fi

    if [ -z "$audio_device" ]; then
        # Audio output device - find the device with Default Output Device: Yes
        # Device name appears 2 lines before "Default Output Device: Yes"
        audio_device=$(system_profiler SPAudioDataType 2>/dev/null | grep -B 2 "Default Output Device: Yes" | head -1 | sed 's/^[[:space:]]*//' | sed 's/:$//')

        # Fallback to Built-in if nothing found or if we got separator line
        if [ -z "$audio_device" ] || [ "$audio_device" = "--" ]; then
            audio_device="Built-in"
        fi
    fi

    if [ -z "$gpu" ] || [ -z "$resolution" ]; then
        # GPU and resolution (these are slow, so cache them)
        local gpu_info=$(system_profiler SPDisplaysDataType 2>/dev/null | tr -d '\000-\037' | sed 's/[[:cntrl:]]//g')

        if [ -z "$gpu" ]; then
            gpu=$(echo "$gpu_info" | grep 'Chipset Model' | head -1 | awk -F': ' '{print $2}' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            local gpu_cores=$(echo "$gpu_info" | grep 'Total Number of Cores' | head -1 | awk -F': ' '{print $2}' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

            # Format GPU string with core count if available
            if [ -n "$gpu_cores" ]; then
                gpu="$gpu ($gpu_cores-core)"
            elif [ -z "$gpu" ]; then
                gpu="Apple Silicon GPU"
            fi
        fi

        if [ -z "$resolution" ]; then
            resolution=$(echo "$gpu_info" | grep -E "Resolution:" | head -1 | sed 's/.*Resolution: //' | awk '{print $1 "x" $3}' | sed 's/[[:space:]]*$//')
            [ -z "$resolution" ] && resolution="Default"
        fi
    fi

    local hw_json="{
    \"cpu\": \"$cpu_model\",
    \"cpu_threads\": \"$cpu_threads\",
    \"cpu_usage\": \"$cpu_usage\",
    \"memory_total\": \"$mem_total_gb\",
    \"memory_used\": \"$mem_used_gb\",
    \"memory_pressure\": \"$memory_pressure\",
    \"swap_used\": \"$swap_used_gb\",
    \"gpu\": \"$gpu\",
    \"resolution\": \"$resolution\",
    \"display_count\": \"$display_count\",
    \"audio_device\": \"$audio_device\"
}"

    # Cache only the STATIC hardware info (not dynamic values like CPU usage, memory)
    if [ -f "$CACHE_FILE" ]; then
        local static_hw_json="{
    \"cpu\": \"$cpu_model\",
    \"gpu\": \"$gpu\",
    \"resolution\": \"$resolution\",
    \"display_count\": \"$display_count\",
    \"audio_device\": \"$audio_device\"
}"
        echo "$static_hw_json" | jq -c . > /tmp/hw_info.json 2>/dev/null
        if [ $? -eq 0 ]; then
            # Only cache if JSON is valid
            jq --slurpfile hw /tmp/hw_info.json \
               ". + {hardware_info: \$hw[0], hw_cache_timestamp: $current_time}" \
               "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
        fi
        rm -f /tmp/hw_info.json
    fi

    echo "$hw_json"
}