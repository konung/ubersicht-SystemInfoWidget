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

    # Disk I/O statistics
    local disk_io=$(iostat -d 1 2 2>/dev/null | tail -1)
    local disk_read_mb=$(echo "$disk_io" | awk '{print $3}')
    local disk_write_mb=$(echo "$disk_io" | awk '{print $4}')

    # Convert to human readable if values exist
    if [ -n "$disk_read_mb" ] && [ "$disk_read_mb" != "" ]; then
        disk_read="${disk_read_mb} MB/s"
    else
        disk_read="N/A"
    fi

    if [ -n "$disk_write_mb" ] && [ "$disk_write_mb" != "" ]; then
        disk_write="${disk_write_mb} MB/s"
    else
        disk_write="N/A"
    fi

    cat <<EOF
{
    "disk_total": "$disk_total",
    "disk_used": "$disk_used",
    "disk_available": "$disk_available",
    "disk_percentage": "$disk_percentage",
    "disk_read": "$disk_read",
    "disk_write": "$disk_write"
}
EOF
}

# Helper function to convert large GB values to TB
convert_to_tb() {
    local value=$1
    # Use awk for more portable processing
    echo "$value" | awk '{
        if (match($0, /^[0-9]+G$/)) {
            # Extract numeric part
            gsub(/G$/, "", $0)
            num = $0
            if (num >= 1000) {
                printf "%.1fT\n", num / 1000
            } else {
                print $0 "G"
            }
        } else {
            print $0
        }
    }'
}

# Get mount points information (external drives and network mounts only)
get_mount_points() {
    # Get only external/network mounts, not APFS system volumes
    local json_output="["
    local first=true

    while IFS= read -r line; do
        local device=$(echo "$line" | awk '{print $1}')
        local mount_point=$(echo "$line" | sed 's/^[^ ]* on //' | sed 's/ (.*)$//')
        local fs_type=$(echo "$line" | sed 's/.*(//; s/,.*//')

        # Only include:
        # - External drives (usually mounted under /Volumes)
        # - Network mounts (SMB, AFP, NFS)
        # - USB drives
        # Skip APFS system volumes, root, and system mounts
        if [[ "$mount_point" == "/Volumes/"* ]] && \
           [[ "$fs_type" != "apfs" ]] && \
           [[ "$mount_point" != "/Volumes/Macintosh HD"* ]]; then

            # Get usage info for this mount (use -H for TB instead of TiB)
            local df_info=$(df -H "$mount_point" 2>/dev/null | tail -1)
            if [ ! -z "$df_info" ]; then
                local size=$(echo "$df_info" | awk '{print $2}')
                local used=$(echo "$df_info" | awk '{print $3}')
                local avail=$(echo "$df_info" | awk '{print $4}')
                local use_percent=$(echo "$df_info" | awk '{print $5}' | tr -d '%')

                # Convert large GB values to TB
                size=$(convert_to_tb "$size")
                used=$(convert_to_tb "$used")
                avail=$(convert_to_tb "$avail")

                # Clean up mount point name for display
                local display_name=$(basename "$mount_point")

                # Determine mount type for icon selection
                local mount_type="external"
                if [[ "$fs_type" == "smbfs" ]]; then
                    mount_type="network"
                elif [[ "$fs_type" == "afpfs" ]]; then
                    mount_type="network"
                elif [[ "$fs_type" == "nfs" ]]; then
                    mount_type="network"
                elif [[ "$fs_type" == "exfat" ]] || [[ "$fs_type" == "msdos" ]] || [[ "$fs_type" == "ntfs" ]] || [[ "$fs_type" == "hfs" ]]; then
                    mount_type="usb"
                fi

                [ "$first" = false ] && json_output+=","
                first=false

                json_output+="{\"name\":\"$display_name\","
                json_output+="\"path\":\"$mount_point\","
                json_output+="\"device\":\"$device\","
                json_output+="\"fs_type\":\"$fs_type\","
                json_output+="\"mount_type\":\"$mount_type\","
                json_output+="\"size\":\"$size\","
                json_output+="\"used\":\"$used\","
                json_output+="\"available\":\"$avail\","
                json_output+="\"use_percent\":\"$use_percent\"}"
            fi
        fi
    done < <(mount)

    json_output+="]"
    echo "$json_output"
}