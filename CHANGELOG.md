# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-01-11

### Added
- New `--vaults` / `-V` flag to display vault investments for wallet addresses
- Shows vault name, user equity, current PnL, and all-time PnL
- Fetches vault details via `userVaultEquities` and `vaultDetails` API endpoints

## [1.2.1] - 2025-01-11

### Changed
- Updated color scheme to match Hyperliquid UI
  - Coin names now white, leverage dim gray, size cyan
  - ROE displayed in parentheses matching PnL color
- All colors upgraded to vibrant/high-intensity variants
- All numbers now display 2 decimal places for consistency

## [1.2.0] - 2025-01-11

### Changed
- Removed `bc` dependency - now uses only `awk` for calculations
- Significant performance improvement (~10x faster for many positions)
  - Consolidated multiple jq calls into single calls
  - Reduced process spawns per position from ~10 to ~3

### Added
- Dependency check at startup with helpful install instructions

### Fixed
- Negative number formatting bug (numbers between 100-999 displayed incorrectly)
- Removed dead code and improved maintainability

## [1.1.0] - 2025-01-11

### Added
- `--testnet` flag for testnet API support
- `--json` flag for raw JSON output
- `--no-color` flag (auto-detects piping)
- curl timeout (10s connect, 30s max)
- Detailed error messages for network/API failures
- Exit codes for scripting
- Number formatting with commas

### Changed
- Improved code structure and maintainability

## [1.0.0] - 2025-01-11

### Added
- Initial release
- Basic position monitoring
- Watch mode with configurable interval
- Color-coded output (green for profits, red for losses)
- Margin ratio alerts
- Cross leverage display
