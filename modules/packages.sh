#!/bin/bash
# Package management and development tools

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
            # Mark this as brew_cache_update process
            exec -a brew_cache_update bash -c '
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

            write_cache_values "{
                \"brew_intel_count\": $intel_count,
                \"brew_arm_count\": $arm_count,
                \"brew_intel_cask\": $intel_cask,
                \"brew_arm_cask\": $arm_cask,
                \"brew_outdated_intel\": $intel_outdated,
                \"brew_outdated_arm\": $arm_outdated,
                \"brew_timestamp\": $(date +%s)
            }"
            ' ) &
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
    local asdf_timestamp=$(read_cache_value "asdf_timestamp" "0")
    local current_time=$(date +%s)
    local cache_age=$((current_time - asdf_timestamp))

    # Use cache if less than 1 hour old
    if [ $cache_age -lt 3600 ] && [ "$asdf_timestamp" != "0" ]; then
        local cached_languages=$(read_cache_value "asdf_languages" "{}")
        if [ "$cached_languages" != "{}" ] && [ "$cached_languages" != "null" ]; then
            echo "$cached_languages"
            return
        fi
    fi

    # Source asdf if available
    if [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
        . /opt/homebrew/opt/asdf/libexec/asdf.sh 2>/dev/null
    elif [ -f "$HOME/.asdf/asdf.sh" ]; then
        . $HOME/.asdf/asdf.sh 2>/dev/null
    fi

    # Check if asdf is available
    if ! command -v asdf &> /dev/null; then
        echo '{"version_manager": "asdf not found"}'
        return
    fi

    # Return cached value while updating in background
    local cached_languages=$(read_cache_value "asdf_languages" '{"version_manager": "asdf"}')
    echo "$cached_languages"

    # Update cache in background if not already running
    if ! pgrep -f "asdf_cache_update" > /dev/null 2>&1; then
        (
        # Source asdf
        if [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
            . /opt/homebrew/opt/asdf/libexec/asdf.sh 2>/dev/null
        elif [ -f "$HOME/.asdf/asdf.sh" ]; then
            . $HOME/.asdf/asdf.sh 2>/dev/null
        fi

        # Get all installed languages from asdf
        json_output='{"version_manager": "asdf"'

        # Get list of all plugins installed in asdf
        plugins=$(asdf plugin list 2>/dev/null)

        if [ ! -z "$plugins" ]; then
            # Build JSON for each installed plugin
            while IFS= read -r plugin; do
                # Skip empty lines
                [ -z "$plugin" ] && continue

                # Get current version for this plugin
                version=$(asdf current "$plugin" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\n\r')

                # If no version set, check if any versions are installed
                if [ -z "$version" ] || [ "$version" = "______" ]; then
                    version="N/A"
                fi

                # Add to JSON output
                json_output+=", \"$plugin\": \"$version\""
            done <<< "$plugins"
        fi

        json_output+='}'

        # Write to cache using jq to update specific fields
        if [ -f "$CACHE_FILE" ]; then
            echo "$json_output" | jq -c . > /tmp/asdf_langs.json
            current_timestamp=$(date +%s)
            jq --slurpfile langs /tmp/asdf_langs.json \
               ". + {asdf_languages: \$langs[0], asdf_timestamp: $current_timestamp}" \
               "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
            rm -f /tmp/asdf_langs.json
        fi
        ) &
    fi
}