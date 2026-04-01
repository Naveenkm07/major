# KrushikaDhara – MongoDB Database Architecture

## Collection Overview

| # | Collection | Est. Growth | TTL | Key Indexes |
|---|------------|-------------|-----|-------------|
| 1 | `farmers` | Slow | — | phoneNumber (unique), state+district |
| 2 | `pestscans` | Medium | 2yr (optional) | farmerId+scanDate, diseaseDetected+cropType |
| 3 | `marketprices` | Fast | 90 days | cropName+state+lastUpdated, 2dsphere geo |
| 4 | `cropcalendars` | Static | — | cropName+month, cropName+stage (unique) |
| 5 | `governmentschemes` | Slow | — | text(schemeName, description), schemeType |
| 6 | `communityposts` | Fast | — | farmerId+createdAt, likeCount, text search |
| 7 | `comments` | Fast | — | postId+createdAt, farmerId+createdAt |
| 8 | `notifications` | Fast | 90 days | farmerId+readStatus+createdAt |
| 9 | `farmerlocations` | Slow | — | 2dsphere, cropType+2dsphere |
| 10 | `chathistories` | Fast | 1 year | farmerId+timestamp, sessionId |

## Relationships

```
Farmer (1)
  ├──→ PestScan (N)         via farmerId
  ├──→ CommunityPost (N)    via farmerId
  │      └──→ Comment (N)   via postId
  ├──→ Notification (N)     via farmerId
  ├──→ FarmerLocation (1)   via farmerId (unique)
  └──→ ChatHistory (N)      via farmerId + sessionId
```

## Index Strategy

### Hot Paths (optimized for query speed)
- **Feed**: `communityposts { createdAt: -1 }` — newest posts first
- **Notifications**: `notifications { farmerId, readStatus, createdAt }` — unread badge count
- **Market**: `marketprices { cropName, location.state, lastUpdated }` — price lookups
- **Nearby**: `farmerlocations { location: '2dsphere' }` — geo proximity

### TTL Policies (automatic cleanup)
- `marketprices.lastUpdated` — 90 days
- `notifications.createdAt` — 90 days
- `chathistories.timestamp` — 1 year

### Text Search Indexes
- `marketprices` — cropName, marketName
- `governmentschemes` — schemeName, description
- `communityposts` — content, tags

## Scalability Design Decisions

| Decision | Rationale |
|----------|-----------|
| Comments as separate collection | Avoids unbounded array growth in posts |
| Denormalized `likeCount`/`commentCount` | O(1) read on feed, updated via hooks |
| FarmerLocation as separate collection | Isolates geo-index overhead from Farmer profile queries |
| Sparse email unique index | Allows phone-only registration (common in rural India) |
| TTL indexes on high-write collections | Automatic storage management without cron jobs |
| 2dsphere indexes | Native MongoDB geo support for "nearest mandi" and "nearby farmer" |

## Seeding

```bash
# Seed all example data
cd backend_node_api
npm run seed

# Destroy and reseed
node src/utils/seeder.js --destroy
```
