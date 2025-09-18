# Changelog

All notable changes to SystemInfoWidget will be documented in this file.

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

## [1.1] - Previous Version

### Added
- Dual Homebrew support (Intel and ARM)
- APFS-accurate disk usage reporting
- Network traffic rate monitoring
- Smart caching for expensive operations
- Programming language version detection

## [1.0] - Initial Release

### Features
- System information display
- Network interface monitoring
- Storage information
- Package management tracking
- Developer tools integration
- Battery status monitoring
