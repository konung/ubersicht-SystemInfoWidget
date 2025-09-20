# Changelog

All notable changes to SystemInfoWidget will be documented in this file.

## [3.0.2] - 2025-01-20

### Fixed
- Shell version not displaying - now shows version alongside shell name (e.g., "zsh 5.9")
- Resolution icon displaying incorrectly - fixed corrupted icon definition
- Added shell version detection for zsh, bash, and fish shells

## [3.0.1] - 2025-01-20

### Changed
- **Major UI code restructuring** - Complete modularization of CoffeeScript rendering code
- Widget reduced from 720 lines to 480 lines (33% reduction)
- Created 9 dedicated UI modules using CommonJS pattern:
  - `helpers.coffee` - Shared utility functions
  - `system-renderer.coffee` - System info rendering
  - `network-renderer.coffee` - Network interfaces and traffic
  - `storage-renderer.coffee` - Disk usage display
  - `cpu-renderer.coffee` - CPU usage and processes
  - `dev-renderer.coffee` - Development tools and languages
  - `logo-renderer.coffee` - ASCII logo rendering
  - `widget-renderer.coffee` - Main orchestrator module (removed due to Übersicht constraints)
- Reorganized folder structure:
  - `shell-modules/` - Bash script modules for data collection
  - `ui-modules/` - CoffeeScript modules for UI rendering
- Improved code organization with clear section headers and documentation

### Added
- **Debug footer** - Optional performance monitoring display (disabled by default)
  - Shows widget version, total execution time, and refresh frequency
  - Configurable via `config.display.showDebugFooter`
  - Zero performance impact when disabled
  - Tracks both shell script execution time and rendering time
- Shell script execution time measurement (conditional, only when debug footer enabled)

### Fixed
- Module loading issues with Übersicht's Browserify/CoffeeScript 1.x environment
- Reserved word conflicts ('location' renamed to 'publicLocation')
- Undefined display errors in widget rendering

### Technical Details
- Übersicht uses CoffeeScript 1.12.7 with Browserify for module bundling
- Modules use CommonJS (require/module.exports) pattern
- Styles must remain inline due to Übersicht parse-time evaluation constraints

## [2.1.1] - 2025-01-18

### Fixed
- Background brew cache update script syntax error causing shell errors
- Replaced complex inline quoting with temporary script approach
- Added tmutil command timeouts to prevent hanging

## [2.1] - 2025-01-18

### Improved
- **Aggressive caching strategy** - Widget never blocks on slow commands
- **Consistent performance** - Execution time variance reduced from 1.2-43s to consistent 2-3s
- **Background updates** - All expensive operations (brew outdated, asdf) now update cache asynchronously
- **Singleton pattern** - Prevents duplicate background jobs from competing for resources
- **Zero blocking** - Always returns cached values immediately while refreshing in background

### Fixed
- Performance degradation when cache expired causing 40+ second execution times
- Synchronous execution of brew outdated commands blocking for 20-30 seconds
- Multiple asdf current calls causing unnecessary delays
- Background job race conditions from parallel cache updates

## [2.0] - 2025-01-18

### Added
- Modular architecture with parallel execution for performance improvement (4.2s → 3s)
- Dynamic asdf language detection - automatically detects all installed asdf plugins
- JSON-based cache system to prevent duplicate keys
- Battery charging status detection (Charging/Charged/Discharging)

### Changed
- Complete script modularization into separate modules for maintainability
- Cache format switched from ENV to JSON to prevent duplicate keys
- Removed terminal field from display (not meaningful in widget context)
- Language versions now exclusively use asdf (removed rbenv/nvm support)
- Version bumped to 2.0 for major architectural changess
- Script execution time reduced from 4.2 seconds to 3 seconds

### Fixed
- Brew package counts showing 0 (cache refresh issue)
- Battery not showing charging status
- Missing disk info with APFS containers
- JSON parsing errors with leading zeros in uptime
- Control characters in asdf version output
- jq combination errors in modular script

### Improved
- Performance: 1.2s reduction in execution time through parallel processing
- Code organization: Split 1200-line monolithic script into 7 focused modules
- Flexibility: Languages shown are now configurable via config array
- Reliability: Better error handling and cache management

## [1.2] - 2025-01-17

### Added
- Per-app network traffic monitoring using `nettop`
- CPU Info section with top processes display
- Battery health metrics (cycles, condition, max capacity)
- Time Machine backup status with live progress
- Nerd Font icon support throughout the widget
- Configurable network app filtering
- ISO/Military time format for backup dates

### Changed
- Moved CPU information from System Info to dedicated CPU Info section
- Renamed "Top CPU Usage" to "CPU Info"
- Improved Time Machine status parsing
- Updated backup date format to ISO standard (YYYY-MM-DD HH:MM)
- Enhanced cache system for rate limiting

### Fixed
- Time Machine detection when backup is actively running
- Duplicate CPU process display issue
- JSON parsing errors with control characters

## [1.1] - 2025-01-17 (Earlier today)

### Added
- Real-time network traffic monitoring with up/down speeds
- Per-app network usage tracking via nettop
- Smart caching system for expensive operations
- Public IP location tracking with intelligent rate limiting
- Network app filtering configuration
- Current date and time display

### Changed
- Improved network interface detection
- Enhanced cache file format with timestamps
- Better handling of multiple network interfaces

### Fixed
- Network traffic calculation accuracy
- Cache file duplicate entry handling

## [1.0] - 2025-01-17 (Initial Release)

### Features
- System information display (OS, kernel, uptime)
- Hardware monitoring (CPU, memory, GPU)
- Network interface monitoring with IP addresses
- APFS-accurate disk usage reporting
- Dual Homebrew support (Intel x86 and ARM)
- Package management tracking (brew, npm, pip)
- Programming language version detection (via asdf/rbenv/nvm)
- Battery status monitoring
- Developer tools integration
- Nerd Font icon support
- Configurable display sections
- Multi-column responsive layout
