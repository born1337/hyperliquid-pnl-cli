# hl-pnl

A command-line tool to monitor Hyperliquid wallet and vault positions with real-time PnL tracking.

![Version](https://img.shields.io/badge/version-1.3.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

## Features

- **Real-time PnL monitoring** - View unrealized profit/loss for all open positions
- **No authentication required** - Uses Hyperliquid's public API
- **Watch mode** - Auto-refresh positions at custom intervals
- **Color-coded output** - Green for profits, red for losses, warnings for high margin
- **Margin tracking** - Cross leverage, margin ratio, and liquidation risk alerts
- **Works with wallets and vaults** - Monitor any Hyperliquid address
- **Testnet support** - Switch between mainnet and testnet
- **JSON output** - Scriptable output for automation
- **Number formatting** - Readable numbers with comma separators

## Installation

### Prerequisites

- `bash` (version 4.0+)
- `curl`
- `jq` (JSON processor)
- `awk` (usually pre-installed)

On macOS:
```bash
brew install jq
```

On Ubuntu/Debian:
```bash
sudo apt-get install jq
```

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/born1337/hyperliquid-pnl-cli/main/install.sh | bash
```

### User Install (No sudo)

Install to `~/.local/bin` without requiring sudo:

```bash
curl -fsSL https://raw.githubusercontent.com/born1337/hyperliquid-pnl-cli/main/install.sh | bash -s -- --user
```

### Manual Install

```bash
# Clone the repository
git clone https://github.com/born1337/hyperliquid-pnl-cli.git
cd hyperliquid-pnl-cli

# Make executable
chmod +x hl-pnl

# Add to PATH for global access
sudo ln -s $(pwd)/hl-pnl /usr/local/bin/hl-pnl
```

## Usage

### Basic Usage

```bash
# Check positions once
hl-pnl <address>

# Example
hl-pnl 0x4cb5f4d145cd16460932bbb9b871bb6fd5db97e3
```

### Watch Mode

Auto-refresh positions at a specified interval:

```bash
# Refresh every 30 seconds
hl-pnl <address> --watch 30

# Short form
hl-pnl <address> -w 30
```

Press `Ctrl+C` to stop watching.

### Testnet

Use the Hyperliquid testnet API:

```bash
hl-pnl <address> --testnet
hl-pnl <address> -t
```

### JSON Output

Get raw JSON output for scripting and automation:

```bash
# Full JSON response
hl-pnl <address> --json

# Extract specific fields with jq
hl-pnl <address> --json | jq '.marginSummary.accountValue'

# Get all coin names
hl-pnl <address> --json | jq '.assetPositions[].position.coin'
```

### Disable Colors

For piping to files or other tools:

```bash
# Explicit flag
hl-pnl <address> --no-color

# Colors auto-disable when piping
hl-pnl <address> > positions.txt
```

### All Options

```
OPTIONS
  -w, --watch <seconds>  Auto-refresh every N seconds (min: 5)
  -t, --testnet          Use testnet API instead of mainnet
  -j, --json             Output raw JSON (for scripting)
      --no-color         Disable colored output
  -h, --help             Show this help message
  -v, --version          Show version number
```

## Output Fields

| Field | Description |
|-------|-------------|
| **Account Value** | Total account value in USD |
| **Position Value** | Total notional value of all positions |
| **Margin Used** | Initial margin used for positions |
| **Maint. Margin** | Maintenance margin requirement |
| **Withdrawable** | Available balance for withdrawal |
| **Cross Leverage** | Position Value / Account Value |
| **Margin Ratio** | Maint. Margin / Account Value (liquidation risk indicator) |

### Position Details

| Field | Description |
|-------|-------------|
| **COIN** | Asset symbol (BTC, ETH, etc.) |
| **SIDE** | Position direction (LONG/SHORT) |
| **LEV** | Leverage used for this position |
| **SIZE** | Position size in asset units |
| **ENTRY** | Entry price |
| **VALUE** | Current position value in USD |
| **PNL** | Unrealized profit/loss |
| **ROE** | Return on equity (%) |

## Margin Ratio Alerts

The margin ratio indicates how close an account is to liquidation:

| Margin Ratio | Status | Color |
|--------------|--------|-------|
| < 50% | Safe | Green |
| 50-80% | Caution | Yellow |
| > 80% | High Risk | Red |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid arguments or address |
| 2 | Network error (timeout, connection failed) |
| 3 | API error (rate limited, server error) |

## Example Output

```
════════════════════════════════════════════════════════════════════════════════
                            HYPERLIQUID POSITION PNL
════════════════════════════════════════════════════════════════════════════════

Address: 0x4cb5f4d145cd16460932bbb9b871bb6fd5db97e3

Account Value:      $314,096.11
Position Value:     $1,308,154.22
Margin Used:        $261,447.25
Maint. Margin:      $130,361.27
Withdrawable:       $34,867.51

Cross Leverage:     4.16x
Margin Ratio:       41.50%

────────────────────────────────────────────────────────────────────────────────
OPEN POSITIONS (18)
────────────────────────────────────────────────────────────────────────────────

COIN      SIDE   LEV    SIZE               ENTRY          VALUE           PNL            ROE
VVV       LONG   3x     104,364.1          $2.3011        $335,321.85     +$95,168.39    +118.9%
IP        LONG   3x     36,991.6           $2.0443        $81,940.09      +$6,319.35     +25.1%
AVNT      LONG   5x     286,765            $0.3141        $91,827.89      +$1,749.53     +9.7%
...

────────────────────────────────────────────────────────────────────────────────
SUMMARY
────────────────────────────────────────────────────────────────────────────────

Winners:            +$105,433.64
Losers:             -$15,395.58
Cross Leverage:     4.16x
Margin Ratio:       41.50%

════════════════════════════════════════════════════════════════════════════════
NET PNL:            +$90,038.06
════════════════════════════════════════════════════════════════════════════════
```

## API

This tool uses the Hyperliquid public API. No authentication required.

| Network | Endpoint |
|---------|----------|
| Mainnet | `https://api.hyperliquid.xyz/info` |
| Testnet | `https://api.hyperliquid-testnet.xyz/info` |

**Endpoints used:**
- `clearinghouseState` - Account positions and margin info
- `userVaultEquities` - User's vault investments
- `vaultDetails` - Vault name and user PnL

For detailed API documentation, see **[API.md](API.md)**.

### Rate Limits

The Hyperliquid API has rate limits. The minimum watch interval is set to 5 seconds to avoid hitting these limits. If you receive a rate limit error, wait a few seconds before retrying.

## Error Handling

The tool provides clear error messages for different failure scenarios:

| Error | Cause | Solution |
|-------|-------|----------|
| "Could not resolve host" | No internet / DNS failure | Check internet connection |
| "Failed to connect to API" | API server unreachable | Try again later |
| "Request timed out" | Slow network / API | Check connection, retry |
| "Rate limited" | Too many requests | Wait before retrying |
| "API server error" | Server-side issue | Try again later |

## Troubleshooting

### "jq: command not found"

Install jq using your package manager:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Arch Linux
sudo pacman -S jq
```

### Numbers showing without commas

Ensure your version of `awk` supports the formatting. GNU awk (gawk) is recommended:
```bash
# Ubuntu/Debian
sudo apt-get install gawk
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Disclaimer

This tool is for informational purposes only. It is not financial advice. Trading cryptocurrency derivatives involves substantial risk of loss. Always do your own research and trade responsibly.

## Acknowledgments

- [Hyperliquid](https://hyperliquid.xyz) for providing a public API
- Built with [Claude Code](https://claude.ai)
