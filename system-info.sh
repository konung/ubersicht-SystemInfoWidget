#!/bin/bash
# Modular system info collector with parallel execution
# Version: 2.0 - All features, optimized for speed

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CACHE_FILE="$SCRIPT_DIR/.cache.json"
MODULES_DIR="$SCRIPT_DIR/modules"
TEMP_DIR=$(mktemp -d)

# Cleanup on exit
trap "rm -rf $TEMP_DIR" EXIT

# Initialize cache if needed
[ ! -f "$CACHE_FILE" ] && echo '{}' > "$CACHE_FILE"

# Source all modules
source "$MODULES_DIR/core.sh"
source "$MODULES_DIR/system.sh"
source "$MODULES_DIR/network.sh"
source "$MODULES_DIR/packages.sh"
source "$MODULES_DIR/storage.sh"
source "$MODULES_DIR/battery.sh"
source "$MODULES_DIR/processes.sh"

# Get environment variables for configuration
NETWORK_APPS_COUNT="${NETWORK_APPS_COUNT:-3}"
SKIP_NETWORK_APPS="${SKIP_NETWORK_APPS:-kernel_task,IPNExtension,mDNSResponder}"

# Run all modules in parallel
{
    # Fast operations
    get_system_info > "$TEMP_DIR/system.json" &
    get_hardware_info > "$TEMP_DIR/hardware.json" &
    get_network_interfaces > "$TEMP_DIR/interfaces.json" &
    get_network_traffic > "$TEMP_DIR/traffic.json" &
    get_storage_info > "$TEMP_DIR/storage.json" &
    get_battery_info > "$TEMP_DIR/battery.json" &
    get_time_machine_status > "$TEMP_DIR/backup.json" &
    get_top_processes 3 > "$TEMP_DIR/processes.json" &
    get_package_info > "$TEMP_DIR/packages.json" &
    get_language_versions > "$TEMP_DIR/languages.json" &
    get_public_ip_info > "$TEMP_DIR/public_ip.json" &

    # Network apps (has 1 second sleep, run last)
    get_network_apps "$NETWORK_APPS_COUNT" "$SKIP_NETWORK_APPS" > "$TEMP_DIR/network_apps.json" &

    # Wait for all background jobs
    wait
}

# Get WiFi SSID separately (fast)
wifi_ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I 2>/dev/null | awk '/ SSID/ {print $2}')

# Get ping latency
ping_result="N/A"
ping_target="8.8.8.8"
if ping -c 1 -W 1 "$ping_target" &>/dev/null; then
    ping_result=$(ping -c 1 -W 1 "$ping_target" 2>/dev/null | grep 'round-trip' | awk -F'/' '{print $5 " ms"}')
fi

# Combine all JSON outputs using jq
jq -n \
    --slurpfile system "$TEMP_DIR/system.json" \
    --slurpfile hardware "$TEMP_DIR/hardware.json" \
    --slurpfile interfaces "$TEMP_DIR/interfaces.json" \
    --slurpfile traffic "$TEMP_DIR/traffic.json" \
    --slurpfile storage "$TEMP_DIR/storage.json" \
    --slurpfile battery "$TEMP_DIR/battery.json" \
    --slurpfile backup "$TEMP_DIR/backup.json" \
    --slurpfile processes "$TEMP_DIR/processes.json" \
    --slurpfile packages "$TEMP_DIR/packages.json" \
    --slurpfile languages "$TEMP_DIR/languages.json" \
    --slurpfile public_ip "$TEMP_DIR/public_ip.json" \
    --slurpfile network_apps "$TEMP_DIR/network_apps.json" \
    --arg wifi_ssid "$wifi_ssid" \
    --arg ping "$ping_result" \
    --arg ping_target "$ping_target" \
    '{
        system: $system[0],
        hardware: $hardware[0],
        network: {
            interfaces: $interfaces[0],
            primary_iface: ($interfaces[0] | map(select(.type == "wifi" or .type == "ethernet")) | .[0].name // "N/A"),
            primary_ip: ($interfaces[0] | map(select(.type == "wifi" or .type == "ethernet")) | .[0].ip // "N/A"),
            wifi_ssid: $wifi_ssid,
            traffic_down: $traffic[0].traffic_down,
            traffic_up: $traffic[0].traffic_up,
            public_ip: $public_ip[0].public_ip,
            public_city: $public_ip[0].public_city,
            public_region: $public_ip[0].public_region,
            public_country: $public_ip[0].public_country,
            public_location: (
                if $public_ip[0].public_city and $public_ip[0].public_region and $public_ip[0].public_country then
                    "\($public_ip[0].public_city), \($public_ip[0].public_region), \($public_ip[0].public_country)"
                else
                    ""
                end
            ),
            public_org: $public_ip[0].public_org,
            public_hostname: $public_ip[0].public_hostname,
            ping: $ping,
            ping_target: $ping_target,
            apps: $network_apps[0]
        },
        storage: $storage[0],
        battery: $battery[0],
        backup: $backup[0],
        processes: {
            top_cpu: $processes[0]
        },
        packages: {
            brew_intel: $packages[0].brew_intel,
            brew_arm: $packages[0].brew_arm,
            brew_intel_cask: $packages[0].brew_intel_cask,
            brew_arm_cask: $packages[0].brew_arm_cask,
            outdated_intel: $packages[0].brew_outdated_intel,
            outdated_arm: $packages[0].brew_outdated_arm,
            npm: $packages[0].npm,
            pip: $packages[0].pip,
            total: (
                $packages[0].brew_intel + $packages[0].brew_arm +
                $packages[0].brew_intel_cask + $packages[0].brew_arm_cask +
                $packages[0].npm + $packages[0].pip
            ),
            outdated: ($packages[0].brew_outdated_intel + $packages[0].brew_outdated_arm)
        },
        dev: {
            version_manager: $languages[0].version_manager,
            languages: ($languages[0] | del(.version_manager))
        }
    }'
