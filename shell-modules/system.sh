#!/bin/bash
# System and hardware information

get_system_info() {
    # Basic system info (all fast)
    local hostname=$(hostname -s)
    local full_hostname=$(hostname -f)
    local username=$(whoami)
    local os="$(sw_vers -productName) $(sw_vers -productVersion) $(sw_vers -buildVersion) $(uname -m)"
    local host=$(sysctl -n hw.model 2>/dev/null || echo "Unknown")
    local kernel=$(uname -r)
    local build=$(sw_vers -buildVersion)
    local shell="$(basename $SHELL)"
    local desktop_env="Aqua"
    local window_manager="Quartz Compositor"
    local wm_theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light')

    # Uptime calculation - more robust parsing
    local uptime_str=$(uptime)
    local days=0 hours=0 minutes=0

    # Extract days if present
    if [[ "$uptime_str" == *"days"* ]]; then
        days=$(echo "$uptime_str" | grep -o '[0-9]\+ days' | grep -o '[0-9]\+')
        # Extract time part after days: "18:49" -> hours=18, minutes=49
        local time_part=$(echo "$uptime_str" | sed 's/.*days, *//' | sed 's/,.*//')
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
    "full_hostname": "$full_hostname",
    "username": "$username",
    "os": "$os",
    "host": "$host",
    "kernel": "$kernel",
    "build": "$build",
    "shell": "$shell",
    "desktop_env": "$desktop_env",
    "window_manager": "$window_manager",
    "wm_theme": "$wm_theme",
    "uptime_days": $days,
    "uptime_hours": $hours,
    "uptime_minutes": $minutes,
    "current_date": "$(date +%Y-%m-%d)",
    "current_time": "$(date +%H:%M)",
    "current_datetime": "$(date +"%Y-%m-%d %H:%M")",
    "processes": $processes,
    "threads": $threads
}
EOF
}

get_hardware_info() {
    # CPU info
    local cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | sed 's/ @ .*//' || echo "Unknown")
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

    # GPU and resolution (these are slow, so cache them)
    local gpu=$(system_profiler SPDisplaysDataType 2>/dev/null | grep 'Chipset Model' | head -1 | awk -F': ' '{print $2}')
    [ -z "$gpu" ] && gpu="Apple Silicon GPU"

    local resolution=$(system_profiler SPDisplaysDataType 2>/dev/null | grep Resolution | awk '{print $2 "x" $4}' | paste -sd ', ' -)
    [ -z "$resolution" ] && resolution="Default"

    cat <<EOF
{
    "cpu": "$cpu_model",
    "cpu_threads": "$cpu_threads",
    "cpu_usage": "$cpu_usage",
    "memory_total": "$mem_total_gb",
    "memory_used": "$mem_used_gb",
    "gpu": "$gpu",
    "resolution": "$resolution"
}
EOF
}