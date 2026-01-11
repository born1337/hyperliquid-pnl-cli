# Hyperliquid API Reference

This document describes the Hyperliquid public API endpoints used by `hl-pnl`.

## Base URLs

| Network | Endpoint |
|---------|----------|
| Mainnet | `https://api.hyperliquid.xyz/info` |
| Testnet | `https://api.hyperliquid-testnet.xyz/info` |

All requests are `POST` with `Content-Type: application/json`.

---

## Endpoints Used

### 1. `clearinghouseState`

**Purpose:** Get account state including open positions, margin info, and PnL for a wallet or vault address.

**Request:**
```json
{
  "type": "clearinghouseState",
  "user": "0x..."
}
```

**Response:**
```json
{
  "marginSummary": {
    "accountValue": "314096.11",
    "totalNtlPos": "1308154.22",
    "totalRawUsd": "52648.86",
    "totalMarginUsed": "261447.25"
  },
  "crossMaintenanceMarginUsed": "130361.27",
  "withdrawable": "34867.51",
  "assetPositions": [
    {
      "type": "oneWay",
      "position": {
        "coin": "BTC",
        "szi": "1.0982",
        "entryPx": "91001.0",
        "positionValue": "99789.95",
        "unrealizedPnl": "-148.25",
        "returnOnEquity": "-0.046",
        "leverage": {
          "type": "cross",
          "value": 31
        },
        "liquidationPx": "75234.12",
        "marginUsed": "3219.35",
        "maxLeverage": 50
      }
    }
  ]
}
```

**Key Fields:**

| Field | Description |
|-------|-------------|
| `marginSummary.accountValue` | Total account value in USD |
| `marginSummary.totalNtlPos` | Total notional position value |
| `marginSummary.totalMarginUsed` | Initial margin used |
| `crossMaintenanceMarginUsed` | Maintenance margin requirement |
| `withdrawable` | Available balance for withdrawal |
| `assetPositions` | Array of open positions |

**Position Fields:**

| Field | Description |
|-------|-------------|
| `coin` | Asset symbol (BTC, ETH, etc.) |
| `szi` | Signed size (negative = short) |
| `entryPx` | Entry price |
| `positionValue` | Current position value in USD |
| `unrealizedPnl` | Unrealized profit/loss |
| `returnOnEquity` | ROE as decimal (0.1 = 10%) |
| `leverage.value` | Leverage multiplier |
| `liquidationPx` | Liquidation price |

---

### 2. `userVaultEquities`

**Purpose:** Get list of vaults a user has invested in along with their equity in each vault.

**Request:**
```json
{
  "type": "userVaultEquities",
  "user": "0x..."
}
```

**Response:**
```json
[
  {
    "vaultAddress": "0x010461c14e146ac35fe42271bdc1134ee31c703a",
    "equity": "80379985.9635280073",
    "lockedUntilTimestamp": 1767424986312
  },
  {
    "vaultAddress": "0x2e3d94f0562703b25c83308a05046ddaf9a8dd14",
    "equity": "1000000.0",
    "lockedUntilTimestamp": 1763281187663
  }
]
```

**Fields:**

| Field | Description |
|-------|-------------|
| `vaultAddress` | Vault contract address |
| `equity` | User's equity in the vault (USD) |
| `lockedUntilTimestamp` | Unix timestamp when funds unlock |

**Notes:**
- Returns empty array `[]` if user has no vault investments
- Equity represents user's share of the vault's total value

---

### 3. `vaultDetails`

**Purpose:** Get detailed information about a specific vault, including the user's PnL if they are invested.

**Request:**
```json
{
  "type": "vaultDetails",
  "vaultAddress": "0x...",
  "user": "0x..."
}
```

**Response:**
```json
{
  "name": "HLP Strategy A",
  "vaultAddress": "0x010461c14e146ac35fe42271bdc1134ee31c703a",
  "leader": "0xdfc24b077bc1425ad1dea75bcb6f8158e10df303",
  "description": "A component market making strategy included in the HLP vault.",
  "leaderCommission": 0.1,
  "leaderFraction": 0.0,
  "maxDistributable": 78558337.224312,
  "maxWithdrawable": 78558337.224312,
  "apr": 0.017889205660477817,
  "isClosed": false,
  "allowDeposits": true,
  "followerState": {
    "user": "0xdfc24b077bc1425ad1dea75bcb6f8158e10df303",
    "vaultEquity": "80380440.9702650607",
    "pnl": "1636917.2868910581",
    "allTimePnl": "5907351.8798060566",
    "daysFollowing": 982,
    "vaultEntryTime": 1683243598416,
    "lockupUntil": 1767424986312
  },
  "followers": [
    {
      "user": "0x...",
      "vaultEquity": "1000000.0",
      "pnl": "50000.0",
      "allTimePnl": "75000.0"
    }
  ],
  "portfolio": [...]
}
```

**Key Fields:**

| Field | Description |
|-------|-------------|
| `name` | Human-readable vault name |
| `vaultAddress` | Vault contract address |
| `leader` | Vault manager's address |
| `description` | Vault description |
| `leaderCommission` | Performance fee (0.1 = 10%) |
| `maxDistributable` | Maximum distributable amount |
| `apr` | Annual percentage return (decimal) |
| `isClosed` | Whether vault is closed |
| `allowDeposits` | Whether new deposits allowed |

**followerState Fields (user-specific):**

| Field | Description |
|-------|-------------|
| `vaultEquity` | User's current equity in vault |
| `pnl` | User's current/recent PnL |
| `allTimePnl` | User's all-time PnL in this vault |
| `daysFollowing` | Days since user invested |
| `vaultEntryTime` | Unix timestamp of first deposit |
| `lockupUntil` | Unix timestamp when funds unlock |

---

## Rate Limits

Hyperliquid's API has rate limits. Recommendations:
- Minimum 5 seconds between requests in watch mode
- Avoid rapid successive calls
- If you receive HTTP 429, wait before retrying

---

## Error Handling

**HTTP Status Codes:**

| Code | Meaning |
|------|---------|
| 200 | Success |
| 429 | Rate limited |
| 500-504 | Server error |

**API Error Response:**
```json
{
  "error": "Error message here"
}
```

---

## Example: Calculate Derived Values

### Cross Leverage
```
Cross Leverage = Total Position Value / Account Value
```

### Margin Ratio (Liquidation Risk)
```
Margin Ratio = Maintenance Margin / Account Value × 100%
```

| Margin Ratio | Risk Level |
|--------------|------------|
| < 50% | Safe |
| 50-80% | Caution |
| > 80% | High Risk |

### Position Side
```
If szi > 0: LONG
If szi < 0: SHORT
```

### ROE Percentage
```
ROE % = returnOnEquity × 100
```

---

## Official Documentation

For complete API documentation, see:
- [Hyperliquid API Docs](https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api)
- [Info Endpoint Reference](https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/info-endpoint)
