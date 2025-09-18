#!/bin/bash
# Battery and power information

get_battery_info() {
    if ! pmset -g batt | grep -q "InternalBattery"; then
        echo '{"percentage": "N/A", "charging": "N/A", "cycles": "N/A", "condition": "N/A", "max_capacity": "N/A"}'
        return
    fi

    # Basic battery info (fast)
    local battery_info=$(pmset -g batt | grep "InternalBattery" | head -1)
    local percentage=$(echo "$battery_info" | grep -o '[0-9]*%' | tr -d '%')

    # Determine charging status
    local charging="No"
    if [[ "$battery_info" == *"AC Power"* ]] || [[ "$battery_info" == *"charging"* ]]; then
        charging="Yes"
    elif [[ "$battery_info" == *"charged"* ]]; then
        charging="Charged"
    elif [[ "$battery_info" == *"discharging"* ]]; then
        charging="No"
    fi

    # Battery health (slower, cache it)
    local battery_cycles=$(read_cache_value "battery_cycles" "")
    local battery_condition=$(read_cache_value "battery_condition" "")
    local battery_max_capacity=$(read_cache_value "battery_max_capacity" "")

    # Check cache age
    local battery_timestamp=$(read_cache_value "battery_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - battery_timestamp))

    # Update if cache is old (> 1 hour)
    if [ $cache_age -gt 3600 ] || [ "$battery_timestamp" == "0" ]; then
        (
            cycles=$(system_profiler SPPowerDataType 2>/dev/null | grep "Cycle Count" | awk '{print $3}')
            condition=$(system_profiler SPPowerDataType 2>/dev/null | grep "Condition" | awk '{print $2}')
            max_cap=$(system_profiler SPPowerDataType 2>/dev/null | grep "Maximum Capacity" | awk '{print $3}' | tr -d '%')

            write_cache_values "{
                \"battery_cycles\": \"${cycles:-N/A}\",
                \"battery_condition\": \"${condition:-N/A}\",
                \"battery_max_capacity\": \"${max_cap:-N/A}\",
                \"battery_timestamp\": $current_time
            }"
        ) &
    fi

    cat <<EOF
{
    "percentage": "$percentage",
    "charging": "$charging",
    "cycles": "${battery_cycles:-N/A}",
    "condition": "${battery_condition:-N/A}",
    "max_capacity": "${battery_max_capacity:-N/A}"
}
EOF
}

get_time_machine_status() {
    local tm_running="No"
    local tm_percent="0"
    local tm_last_backup="N/A"
    local tm_destination="N/A"

    if command -v tmutil &> /dev/null; then
        local tm_status=$(tmutil status 2>/dev/null)
        if [ ! -z "$tm_status" ]; then
            # Check if backup is running
            if echo "$tm_status" | grep -q "Running = 1"; then
                tm_running="Yes"
                # Get percentage
                local raw_percent=$(echo "$tm_status" | grep "Percent = " | head -1 | awk -F'"' '{print $2}')
                if [ ! -z "$raw_percent" ]; then
                    tm_percent=$(echo "$raw_percent" | awk '{printf "%.1f", $1 * 100}')
                fi
                # Get destination
                local raw_destination=$(echo "$tm_status" | grep "DestinationMountPoint = " | awk -F'"' '{print $2}')
                if [ ! -z "$raw_destination" ]; then
                    tm_destination=$(basename "$raw_destination" 2>/dev/null | tr -d '\n\r\t' | sed 's/[[:cntrl:]]//g')
                fi
            fi

            # Get last backup
            local last_backup_path=$(tmutil latestbackup 2>/dev/null)
            if [ ! -z "$last_backup_path" ]; then
                local backup_name=$(basename "$last_backup_path")
                if [[ "$backup_name" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
                    local year="${BASH_REMATCH[1]}"
                    local month="${BASH_REMATCH[2]}"
                    local day="${BASH_REMATCH[3]}"
                    local hour="${BASH_REMATCH[4]}"
                    local min="${BASH_REMATCH[5]}"
                    tm_last_backup="${year}-${month}-${day} ${hour}:${min}"
                fi
            fi
        fi
    fi

    cat <<EOF
{
    "time_machine_running": "$tm_running",
    "time_machine_percent": "$tm_percent",
    "last_backup": "$tm_last_backup",
    "destination": "$tm_destination"
}
EOF
}