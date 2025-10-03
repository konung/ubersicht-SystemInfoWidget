#!/bin/bash
# Package management and development tools

get_docker_status() {
    if command -v docker &> /dev/null; then
        # Get running containers count
        local running=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        # Get total containers count
        local total=$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')
        echo "{\"docker_running\": $running, \"docker_total\": $total}"
    else
        echo "{\"docker_running\": 0, \"docker_total\": 0}"
    fi
}

get_package_info() {
    # Ensure CACHE_FILE is set
    if [ -z "$CACHE_FILE" ]; then
        CACHE_FILE="$(dirname "$0")/.cache.json"
    fi

    # Check brew installations
    local brew_intel_count=0
    local brew_arm_count=0
    local brew_intel_cask=0
    local brew_arm_cask=0

    # Check cache first
    local brew_timestamp=$(read_cache_value "brew_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - brew_timestamp))

    if [ $cache_age -lt 3600 ] && [ "$brew_timestamp" != "0" ]; then
        # Use cached values
        brew_intel_count=$(read_cache_value "brew_intel_count" "0")
        brew_arm_count=$(read_cache_value "brew_arm_count" "0")
        brew_intel_cask=$(read_cache_value "brew_intel_cask" "0")
        brew_arm_cask=$(read_cache_value "brew_arm_cask" "0")
        brew_outdated_intel=$(read_cache_value "brew_outdated_intel" "0")
        brew_outdated_arm=$(read_cache_value "brew_outdated_arm" "0")
    else
        # ALWAYS use cached values - never block on brew commands
        brew_intel_count=$(read_cache_value "brew_intel_count" "0")
        brew_arm_count=$(read_cache_value "brew_arm_count" "0")
        brew_intel_cask=$(read_cache_value "brew_intel_cask" "0")
        brew_arm_cask=$(read_cache_value "brew_arm_cask" "0")
        brew_outdated_intel=$(read_cache_value "brew_outdated_intel" "0")
        brew_outdated_arm=$(read_cache_value "brew_outdated_arm" "0")

        # Update cache in background ONLY if not already running
        if ! pgrep -f "brew_cache_update" > /dev/null 2>&1; then
            (
            # Create a temporary script to run in background
            cat > /tmp/brew_cache_update.$$ << 'EOF'
#!/bin/bash
# Intel brew
if [ -x "/usr/local/bin/brew" ]; then
    intel_count=$(/usr/local/bin/brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    intel_cask=$(/usr/local/bin/brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    intel_outdated=$(/usr/local/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
else
    intel_count=0
    intel_cask=0
    intel_outdated=0
fi

# ARM brew
if [ -x "/opt/homebrew/bin/brew" ]; then
    arm_count=$(/opt/homebrew/bin/brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    arm_cask=$(/opt/homebrew/bin/brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    arm_outdated=$(/opt/homebrew/bin/brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
else
    arm_count=0
    arm_cask=0
    arm_outdated=0
fi

# Source the core functions
CACHE_FILE="$1"
source "$(dirname "$CACHE_FILE")/lib/shell-modules/core.sh"

write_cache_values "{
    \"brew_intel_count\": $intel_count,
    \"brew_arm_count\": $arm_count,
    \"brew_intel_cask\": $intel_cask,
    \"brew_arm_cask\": $arm_cask,
    \"brew_outdated_intel\": $intel_outdated,
    \"brew_outdated_arm\": $arm_outdated,
    \"brew_timestamp\": $(date +%s)
}"

# Clean up
rm -f /tmp/brew_cache_update.$$
EOF
            chmod +x /tmp/brew_cache_update.$$
            exec -a brew_cache_update /tmp/brew_cache_update.$$ "$CACHE_FILE"
            ) &
        fi
    fi

    # NPM packages (fast)
    local npm_count=$(npm list -g --depth=0 2>/dev/null | grep -c '^├\|^└' || echo "0")

    # Pip packages (fast)
    local pip_count=$(pip3 list 2>/dev/null | tail -n +3 | wc -l | tr -d ' ' || echo "0")

    cat <<EOF
{
    "brew_intel": $brew_intel_count,
    "brew_arm": $brew_arm_count,
    "brew_intel_cask": $brew_intel_cask,
    "brew_arm_cask": $brew_arm_cask,
    "brew_outdated_intel": $brew_outdated_intel,
    "brew_outdated_arm": $brew_outdated_arm,
    "npm": $npm_count,
    "pip": $pip_count
}
EOF
}

get_language_versions() {
    # Check cache first
    local mise_timestamp=$(read_cache_value "mise_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - mise_timestamp))

    # Use cache if less than 1 hour old
    if [ $cache_age -lt 3600 ] && [ "$mise_timestamp" != "0" ]; then
        local cached_languages=$(read_cache_value "mise_languages" "{}")
        local cached_latest=$(read_cache_value "mise_latest" "{}")
        if [ "$cached_languages" != "{}" ] && [ "$cached_languages" != "null" ]; then
            # Merge current and latest versions into single output
            if [ "$cached_latest" != "{}" ] && [ "$cached_latest" != "null" ]; then
                echo "$cached_languages" | jq --argjson latest "$cached_latest" '. + {mise_latest: $latest}'
            else
                echo "$cached_languages"
            fi
            return
        fi
    fi

    # Check if mise is available
    if ! command -v mise &> /dev/null; then
        echo '{"version_manager": "mise not found"}'
        return
    fi

    # Return cached value while updating in background
    local cached_languages=$(read_cache_value "mise_languages" '{"version_manager": "mise"}')
    local cached_latest=$(read_cache_value "mise_latest" "{}")

    # Merge current and latest versions
    if [ "$cached_latest" != "{}" ] && [ "$cached_latest" != "null" ]; then
        echo "$cached_languages" | jq --argjson latest "$cached_latest" '. + {mise_latest: $latest}'
    else
        echo "$cached_languages"
    fi

    # Update cache in background if not already running
    if ! pgrep -f "mise_cache_update" > /dev/null 2>&1; then
        (
        # Get all installed languages from mise
        json_output='{"version_manager": "mise"'
        latest_output='{}'

        # Get list of all tools installed in mise
        tools=$(mise ls --installed 2>/dev/null | awk '{print $1}' | sort -u)

        if [ ! -z "$tools" ]; then
            # Build JSON for each installed tool
            while IFS= read -r tool; do
                # Skip empty lines
                [ -z "$tool" ] && continue

                # Get current version for this tool
                version=$(mise current "$tool" 2>/dev/null | awk '{print $2}' | tr -d '\n\r')

                # If no version set, get the installed version
                if [ -z "$version" ]; then
                    version=$(mise ls "$tool" 2>/dev/null | grep -v 'not installed' | tail -1 | awk '{print $2}' | tr -d '\n\r')
                fi

                # If still no version, mark as N/A
                if [ -z "$version" ]; then
                    version="N/A"
                fi

                # Add to JSON output
                json_output+=", \"$tool\": \"$version\""

                # Get latest available version (only for tools with current version)
                if [ "$version" != "N/A" ]; then
                    # Get latest stable version from mise
                    latest=$(mise ls-remote "$tool" 2>/dev/null | \
                            grep -v -E '(rc|beta|dev|alpha|preview|snapshot)' | \
                            grep -E '^[0-9]+\.[0-9]+' | \
                            tail -1 | \
                            tr -d ' \n\r')

                    if [ ! -z "$latest" ]; then
                        # Build latest versions JSON
                        if [ "$latest_output" = "{}" ]; then
                            latest_output="{\"$tool\": \"$latest\""
                        else
                            latest_output="${latest_output%\}}, \"$tool\": \"$latest\""
                        fi
                        latest_output="${latest_output}}"
                    fi
                fi
            done <<< "$tools"
        fi

        json_output+='}'

        # Write to cache using jq to update specific fields
        if [ -f "$CACHE_FILE" ]; then
            echo "$json_output" | jq -c . > /tmp/mise_langs.json
            echo "$latest_output" | jq -c . > /tmp/mise_latest.json 2>/dev/null || echo '{}' > /tmp/mise_latest.json
            current_timestamp=$(date +%s)
            jq --slurpfile langs /tmp/mise_langs.json \
               --slurpfile latest /tmp/mise_latest.json \
               ". + {mise_languages: \$langs[0], mise_latest: \$latest[0], mise_timestamp: $current_timestamp}" \
               "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
            rm -f /tmp/mise_langs.json /tmp/mise_latest.json
        fi
        ) &
    fi
}