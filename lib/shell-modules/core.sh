#!/bin/bash
# Core utility functions

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export LC_ALL=en_US.UTF-8

# Utility to safely get values
get_value() {
    local cmd="$1"
    local default="$2"
    result=$(eval "$cmd" 2>/dev/null || echo "$default")
    echo "${result:-$default}"
}

# Cache management
read_cache_value() {
    local key="$1"
    local default="${2:-}"
    if [ -f "$CACHE_FILE" ] && command -v jq &> /dev/null; then
        value=$(jq -r ".$key // empty" "$CACHE_FILE" 2>/dev/null)
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
        if [ -f "$CACHE_FILE" ]; then
            merged=$(jq -s '.[0] * .[1]' "$CACHE_FILE" <(echo "$json_data") 2>/dev/null)
            if [ ! -z "$merged" ]; then
                echo "$merged" > "$CACHE_FILE"
            else
                echo "$json_data" > "$CACHE_FILE"
            fi
        else
            echo "$json_data" > "$CACHE_FILE"
        fi
    fi
}

# Format bytes to human readable
format_bytes() {
    local bytes="$1"
    if [ -z "$bytes" ] || [ "$bytes" = "0" ]; then
        echo "0 B"
    elif [ "$bytes" -gt 1099511627776 ]; then
        echo "$bytes" | awk '{printf "%.1f TB", $1/1099511627776}'
    elif [ "$bytes" -gt 1073741824 ]; then
        echo "$bytes" | awk '{printf "%.1f GB", $1/1073741824}'
    elif [ "$bytes" -gt 1048576 ]; then
        echo "$bytes" | awk '{printf "%.1f MB", $1/1048576}'
    elif [ "$bytes" -gt 1024 ]; then
        echo "$bytes" | awk '{printf "%.1f KB", $1/1024}'
    else
        echo "$bytes B"
    fi
}

# Format rate (bytes per second)
format_rate() {
    local bytes="$1"
    if [ -z "$bytes" ] || [ "$bytes" = "0" ]; then
        echo "0 B/s"
    elif [ "$bytes" -gt 1048576 ]; then
        echo "$bytes" | awk '{printf "%.1f MB/s", $1/1048576}'
    elif [ "$bytes" -gt 1024 ]; then
        echo "$bytes" | awk '{printf "%.1f KB/s", $1/1024}'
    else
        echo "$bytes B/s"
    fi
}