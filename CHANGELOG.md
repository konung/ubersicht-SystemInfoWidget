# Changelog

All notable changes to SystemInfoWidget will be documented in this file.

## [3.6.0] - 2025-01-20

### Fixed
- **Memory Pressure Caching** - Separated static hardware info from dynamic values
  - CPU usage, memory usage, and memory pressure now update in real-time
  - Only static values (CPU model, GPU, resolution) are cached for performance
  - Hardware cache reduced from 5 minutes to 30 seconds for audio device switching

- **Audio Device Detection** - Fixed detection of current audio output device
  - Now properly shows Bluetooth and USB audio devices
  - Simplified system_profiler parsing for reliability

- **Network Mount Display** - Large network mounts now display in TB instead of GB
  - Added automatic conversion for values over 1000GB
  - Shows proper units (e.g., "3.7T" instead of "3678G")

- **JSON Control Characters** - Fixed persistent JSON parsing errors
  - Added aggressive control character filtering
  - Improved error handling for system_profiler output

### Changed
- **Path Resolution** - Fixed core.sh module path resolution using BASH_SOURCE
- **Screenshot** - Updated screenshot.png from preview.png with metadata stripped

### Improved
- Better separation of cached vs real-time data for accurate monitoring
- More robust JSON generation and validation
- Enhanced error handling for edge cases

## [3.1.2] - 2025-01-20

### Added
- GPU core count display for Apple Silicon Macs (e.g., "Apple M2 Max (30-core)")

### Fixed
- Hostname now shows actual Mac computer name instead of network-assigned hostname
- Added network_hostname field to track DHCP/DNS assigned name separately

### Improved
- Better hostname handling using scutil for accurate Mac name retrieval
- Enhanced GPU information display for Apple Silicon

## [3.1.1] - 2025-01-20

### Changed
- Updated documentation to include minimal development tools disclosure
- Fixed module path reference in packages.sh background script
- Updated all version references to maintain consistency

### Improved
- Cleaner git history with focused commits
- More accurate documentation reflecting actual development process

## [3.1.0] - 2025-01-20

### Major Bug Fixes & Refactoring
This release represents a complete architectural overhaul to resolve critical Übersicht compatibility issues.

### Fixed
- **Critical: Module Loading Issue** - UI modules were being loaded as separate widgets by Übersicht
  - Moved all modules to `/lib` directory per Übersicht documentation
  - Files in `/lib` are properly ignored by Übersicht's widget scanner
  - Resolved "Unexpected token ILLEGAL" parsing errors

- **Widget Display Issues**
  - Fixed empty rectangle rendering due to style property configuration
  - Fixed column layout displaying vertically instead of horizontally
  - Corrected CSS flexbox implementation for proper column display

- **Widget Identification**
  - Fixed widget name showing as "SystemInfoWidget-widget-index-coffee"
  - Added explicit `name` export for proper Übersicht identification

- **Shell Version Display**
  - Shell section now correctly displays version alongside shell name (e.g., "zsh 5.9")
  - Added version detection for zsh, bash, and fish shells

- **Resolution Display**
  - Fixed corrupted resolution icon that was showing "default"

### Changed
- **Complete Module Reorganization**
  - All modules now under `/lib` with clear subdirectory structure:
    - `/lib/ui-modules/` - CoffeeScript UI rendering modules
    - `/lib/shell-modules/` - Bash data collection modules
  - Updated all module paths in index.coffee and system-info.sh
  - Removed widget-renderer.coffee to avoid Übersicht parsing issues

- **Code Structure**
  - Widget reduced from 720 to 480 lines through modularization
  - Created 8 dedicated UI modules with CommonJS pattern
  - Improved separation of concerns between data collection and rendering

### Technical Details
- Style property corrected to use template string with config interpolation
- Added container display properties for proper layout
- Explicit flex-direction declarations for reliable column layout
- Updated all documentation to reflect new architecture

## [3.0.5] - 2025-01-20

### Fixed
- Reorganized module structure: all modules now in `/lib` directory with subdirectories
  - `/lib/ui-modules/` - CoffeeScript UI rendering modules
  - `/lib/shell-modules/` - Bash data collection modules
- Fixed widget name display in Übersicht (was showing as SystemInfoWidget-widget-index-coffee)
- Added explicit `name` export to index.coffee for proper widget identification
- Updated all module paths to reflect new structure
- Updated documentation to reflect correct directory structure

## [3.0.4] - 2025-01-20

### Fixed
- Module files moved to `/lib` directory per Übersicht documentation
- Files in `/lib` directory are not parsed as separate widgets by Übersicht
- Fixes persistent "Unexpected token ILLEGAL" errors from previous attempts
- Updated all documentation to reflect proper `/lib` directory structure

## [3.0.3] - 2025-01-20

### Fixed
- Critical bug where UI modules were being loaded as separate widgets by Übersicht
- Multiple attempts to fix via file renaming (`.coffee.module`, `.lib`, etc.)
- Discovered correct solution from Übersicht documentation: use `/lib` directory

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
  - `lib/` - CoffeeScript modules for UI rendering (Übersicht ignores /lib per documentation)
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
