# ShockGate

A free, self-hosted multi-user PiShock remote. Create token links with custom limits and share them with anyone — no account needed for guests.

Built for VRChat with full OSC avatar integration via a local client app.

> ShockGate is completely free. No subscriptions, no paywalls.

---

## Download

Head to the [Releases](../../releases) page and download the latest `ShockGateClient-Setup.exe`.

> ✅ **0/70 on VirusTotal** – The installer is unsigned but clean.

> https://www.virustotal.com/gui/file/c93b6b47789a111f7c2814001e807be344b314a34d92fe7e7c5d6b8c7b938a0c

**Windows (installer)**

Download and run `ShockGateClient-Setup.exe`. No Python installation required.

**Windows / Linux (from source)**

```bash
pip install -r requirements.txt
python client.py
```

A setup window appears on first launch. Enter your ShockGate username and password.

---

## What is ShockGate?

ShockGate lets you share your PiShock with friends and partners via simple token links. You set the limits — max intensity, max duration, number of uses, expiry time — and send the link. Guests just open it in any browser, no account needed.

The ShockGate Client runs locally on your PC and connects your avatar in VRChat via OSC, so your avatar reacts in real time when someone operates your shocker.

```
Guest (token link) ──► ShockGate Server ──► PiShock API
                              │
                        WebSocket (wss)
                              │
                       ShockGate Client
                       (your local PC)
                              │
                       VRChat OSC (port 9000)
```

---

## Features

- Each user has their own account, shockers and tokens — fully isolated
- Token links with configurable limits: max intensity, max duration, use count, expiry
- Single-user claim lock, activate-on-first-use timer
- Pause a shocker or revoke a token — changes reflect instantly on the token page
- PiShock credentials are validated against the API before being saved
- Local client sends OSC parameters to VRChat and shows Discord Rich Presence
- Auto-update: client updates itself silently on startup
- Password reset via email

---

## ShockGate Client

The client runs locally on your PC and bridges ShockGate with VRChat. It receives commands from the server over a secure WebSocket and forwards them to VRChat as OSC avatar parameters.

### OSC Parameters

| Parameter | Type | Description |
|---|---|---|
| `SHOCK/IsShocking` | Bool | True during shock, resets after |
| `SHOCK/IsVibrating` | Bool | True during vibrate (including warning), resets after |
| `SHOCK/IsBeeping` | Bool | True during beep, resets after |
| `SHOCK/Intensity` | Float | 0.0–1.0 relative to token max intensity |
| `SHOCK/Duration` | Float | 0.0–1.0 relative to token max duration |
| `SHOCK/SendSignal` | Bool | Pulses on every operate — useful as a shared animator trigger |
| `SHOCK/Collar` | Bool | Heartbeat sent every 5s while client is connected |

---

## Token System

Tokens are shareable links tied to a specific shocker.

| Setting | Description |
|---|---|
| Max Intensity | Hard cap enforced server-side (1–100%) |
| Max Duration | Hard cap enforced server-side (1–15s) |
| Use Limit | Token stops working after N uses. Empty = unlimited |
| Expires After | Token expires after N hours. Empty = never |
| Single User | Only the first browser to open the token can use it |
| Activate on First Use | Expiry timer starts on first use, not on creation |

---

## Changelog

### v1.04 (2026-05-06)
- Switched to PiShock Broker WebSocket API (`wss://broker.pishock.com/v2`) — no share codes needed
- Multi-shocker tokens: one token can now control multiple shockers simultaneously, all fired in a single broker payload
- Token pause/unpause: tokens can be paused directly without touching the shocker
- Per-token activity logs now stored on disk (data/logs/) — persistent across server restarts
- Admin SSE endpoint (`/api/admin/stream`): admin panel receives live push updates instead of polling
- IP ban system: admin can ban exact IPs, CIDR ranges and wildcards (e.g. `1.2.3.*`)
- Login history: last 5 unique IPs tracked per user, visible in admin panel
- Rate limiting on `/api/login`, `/api/register`, `/api/forgot-password`, `/api/admin/login`
- Security headers on all responses: CSP with nonce, HSTS, X-Frame-Options, X-Content-Type-Options
- Templates moved to `templates/` folder, served via `render_template` with nonce injection
- Email verification on registration — unverified accounts deleted after 24 hours
- Client version + hash check on WebSocket connect — server rejects outdated or modified clients
- `websocket-client` library replaces `websockets` in the client for synchronous broker communication
- Shocker globally unique constraint — a shocker can only be registered on one ShockGate account at a time

### v1.03 (2026-05-04)

**VRChat / OSC Detection**
- Client now detects whether VRChat is running and whether OSC is enabled, using VRChat's OSCQuery HTTP endpoint
- Three distinct states shown in the GUI: `Connected` (green), `Running – OSC disabled` (orange), `Not running` (red)
- VRChat status checked immediately on server connect and then every 5 seconds
- Heartbeat (`SHOCK/Collar`) only sent when VRChat OSC is actually reachable

**Collar Signal**
- `SHOCK/Collar = False` now sent to VRChat when the client exits cleanly
- `SHOCK/Collar = True` sent immediately on successful server authentication

**GUI**
- VRChat status row added to info block with colour-coded dot indicator
- System log increased in height and wraps long lines

**Email (server)**
- Registration and password reset emails now include a `text/plain` part alongside HTML, fixing SpamAssassin flags and improving deliverability

### v1.02 (2026-05-03)
- Add Shocker modal redesigned as a two-step flow: credentials → shocker picker
- Shockers are now fetched directly from the PiShock API (`GetUserDevices`) — no manual share code entry
- Multi-select shocker picker: add multiple shockers in one step, each with its own name and share code
- Share codes shown per shocker in a dropdown; manual code entry field always visible as fallback
- Shocker names pre-filled from PiShock API, editable before saving
- Shocker globally unique: a shocker already registered by another user is shown as unavailable
- Token status badges added to dashboard: ACTIVE, EXPIRED, USED UP, NO SHOCKER
- Refresh button label changed from icon to text
- Dashboard rows switched from flexbox to CSS grid for aligned columns

### v1.01 (2026-05-02)
- Auto-update system: client checks for updates on startup via SHA256 hash comparison
- URL obfuscation: server and WebSocket URLs XOR-encoded in client binary
- Settings window no longer shows server URL (hardcoded, not user-configurable)
- Discord Rich Presence via pypresence
- Admin panel: Edit User modal (username, email, optional password reset)
- Admin panel: online status dot per user (green/red), auto-refreshes every 10s
- Admin panel: per-user activity log (last 100 operates)
- Token page polls shocker status every 3s as fallback; SSE push on pause/unpause
- Shocker validation on add uses direct Operate test beep instead of GetShareCodesByOwner
- `is_invalid` column added to shockers table — marked on positive API confirmation only
- FAQ section and safety disclaimer added to landing page
- Rate limiting placeholder (full implementation in v1.04)

### v1.00 (2026-05-02)
- Initial release
- Multi-user accounts with bcrypt passwords and 8-hour session tokens
- PiShock credentials validated against API on shocker add
- Token system with intensity/duration/use/expiry limits, all enforced server-side
- Single-user claim lock with token-specific cookies
- SSE push for lock state, shocker status, flash events
- Per-user WebSocket client relay to local ShockGate Client
- Client: tkinter GUI, OSC relay, auto-update stub, settings window
- Admin panel: user list, ban/unban, delete, online status via polling
- Password reset via SMTP email
- SQLite WAL mode

---

## License

© 2026 me0wg4ming. All rights reserved.

This project is source-available. You may view and study the code, but you may not copy, redistribute, or use it in your own projects without explicit written permission.

---

## Disclaimer

This tool is intended for consensual use between trusted parties. Always ensure the person running the client has given explicit consent. The developers are not responsible for misuse.
