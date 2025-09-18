#!/bin/bash
# Storage and disk information

get_storage_info() {
    # APFS container info for accurate reporting
    local apfs_info=$(diskutil apfs list 2>/dev/null | grep "APFS Container Reference")

    if [ ! -z "$apfs_info" ]; then
        # Get the container reference
        local container=$(echo "$apfs_info" | head -1 | awk '{print $NF}')

        # Get container info
        local container_info=$(diskutil apfs list | grep -A 20 "$container")

        # Extract capacity and used space with new format
        local capacity_line=$(echo "$container_info" | grep "Size (Capacity Ceiling)")
        local used_line=$(echo "$container_info" | grep "Capacity In Use By Volumes")
        local free_line=$(echo "$container_info" | grep "Capacity Not Allocated")

        # Extract values in TB/GB format - take first occurrence only
        local capacity=$(echo "$capacity_line" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p' | head -1)
        local used=$(echo "$used_line" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p' | head -1)
        local free=$(echo "$free_line" | sed -n 's/.*(\([0-9.]* [TG]B\)).*/\1/p' | head -1)

        # Extract percentage - take first percentage value
        local percentage=$(echo "$used_line" | sed -n 's/.*(\([0-9.]*\)% used.*/\1/p' | head -1 | cut -d. -f1)

        # Set default if percentage is empty
        if [ -z "$percentage" ]; then
            percentage="0"
        fi

        # Format for display
        disk_total="$capacity"
        disk_used="$used"
        disk_available="$free"
        disk_percentage="$percentage"
    else
        # Fallback to df
        local disk_info=$(df -h / | awk 'NR==2')
        disk_total=$(echo "$disk_info" | awk '{print $2}')
        disk_used=$(echo "$disk_info" | awk '{print $3}')
        disk_available=$(echo "$disk_info" | awk '{print $4}')
        disk_percentage=$(echo "$disk_info" | awk '{gsub("%",""); print $5}')
    fi

    cat <<EOF
{
    "disk_total": "$disk_total",
    "disk_used": "$disk_used",
    "disk_available": "$disk_available",
    "disk_percentage": "$disk_percentage"
}
EOF
}