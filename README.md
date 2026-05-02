# ShockHub

A self-hosted multi-user PiShock remote. Users create accounts, connect their own PiShock, and share token links with whoever they want to give control to — with full control over limits, expiry and revocation.

Built for VRChat with OSC avatar integration via a local client.

---

## Download

Head to the [Releases](../../releases) page and download the latest `ShockHubClient-Setup.exe`.

No account needed to use a token link — guests just open the URL in any browser.

---

## ShockHub Client

The client runs locally on your PC and bridges ShockHub with VRChat via OSC. It connects to the server over a secure WebSocket and forwards shock/vibrate/beep commands to your avatar in real time.

**Windows (installer)**

Download `ShockHubClient-Setup.exe` from the [Releases](../../releases) page. No Python installation required.

**Windows / Linux (from source)**

```bash
pip install -r requirements.txt
python client.py
```

A setup window appears on first launch. Enter your ShockHub username and password — that's it.

---

## How it works

```
Guest (token page) ──► ShockHub Server ──► PiShock API
                              │
                        WebSocket (wss)
                              │
                       ShockHub Client
                       (local Windows/Linux PC)
                              │
                       VRChat OSC (port 9000)
```

The server handles everything — PiShock API calls, token validation, per-user locking. The local client connects via WebSocket and forwards commands to VRChat as OSC parameters. Guests never interact with PiShock directly.

---

## Features

- Each user has their own account, shockers and tokens — fully isolated
- Tokens are shareable links with configurable limits: max intensity, max duration, use count, expiry time
- Single-user claim lock, activate-on-first-use timer
- Shocker pause and token revocation take effect instantly on the token page (SSE push)
- PiShock credentials are validated against the API when adding a shocker
- Local client sends OSC parameters to VRChat and shows Discord Rich Presence
- Auto-update: client silently updates itself on startup via SHA256 hash comparison
- Password reset via email (SMTP)
- Admin panel: user management, ban/unban, activity logs, online status

---

## Server Setup

### Requirements

```bash
pip install -r requirements.txt
```

### Configuration

Edit `data/config.env`:

```env
SECRET_KEY=        # generate with: python3 -c "import secrets; print(secrets.token_hex(32))"
ADMIN_USER=admin
ADMIN_PASS=changeme
HOST=0.0.0.0
PORT=1450
DB_PATH=/home/user/shockhub/data/shockhub.db

SMTP_HOST=smtp.example.com
SMTP_PORT=465
SMTP_USER=noreply@example.com
SMTP_PASS=your_password
SMTP_FROM=noreply@example.com
SITE_URL=https://your-domain.com
```

### Run

```bash
python3 app.py
```

Or as a systemd service:

```bash
sudo cp shockhub.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now shockhub
```

The WebSocket server starts automatically on `PORT+1` (default: 1451).

### Pushing a client update

Place the new `client.py` in the `updates/` directory. The server reads `CURRENT_VERSION` directly from the file — no version.txt needed.

---

## Token system

Tokens are the core of ShockHub. Each token is tied to a specific shocker and generates a unique URL that can be shared with anyone.

| Setting | Description |
|---|---|
| Max Intensity | Hard cap on intensity, enforced server-side |
| Max Duration | Hard cap on duration, enforced server-side |
| Use Limit | Token stops working after N uses. Empty = unlimited |
| Expires After | Token expires after N hours. Empty = never |
| Single User | Only the first browser to claim the token can use it |
| Activate on First Use | Expiry timer starts on first use, not on creation |

Pausing a shocker or deleting a token takes effect immediately — the token page updates within seconds via SSE without a page reload.

---

## Project structure

```
shockhub/
├── app.py                  # Routes, SSE, WebSocket server
├── auth.py                 # Login, registration, token auth, admin auth
├── database.py             # SQLite schema and connection helper
├── operate.py              # Per-user lock, PiShock dispatch, OSC relay
├── shockers.py             # Shocker CRUD and PiShock API calls
├── tokens.py               # Token CRUD and operate validation
├── mailer.py               # Password reset emails via SMTP
├── requirements.txt
├── shockhub.service
├── data/
│   ├── config.env
│   └── shockhub.db
├── updates/
│   └── client.py           # Served to clients for auto-update
└── static/
    ├── index.html
    ├── login.html
    ├── dashboard.html
    ├── token.html
    ├── admin.html
    ├── reset-password.html
    └── docs/
        ├── full-control.html
        └── vrchat-osc.html
```

---

## Security

- Passwords hashed with bcrypt
- Admin credentials stored only in `config.env`, not in the database
- Per-user operate locks — no concurrent shocks possible
- Token limits are enforced server-side and cannot be bypassed by guests
- Shocker credentials are validated against the PiShock API before being saved
- Server address and WebSocket URL are obfuscated in the client binary
- Auto-update uses SHA256 hash comparison before applying

---

## Changelog

### v1.00 (2026-05-02)
- Initial release

---

## License

© 2026 me0wg4ming. All rights reserved.

This project is source-available. You may view and study the code, but you may not copy, redistribute, or use it in your own projects without explicit written permission.

---

## Disclaimer

This tool is intended for consensual use between trusted parties. Always ensure the person running the client has given explicit consent. The developers are not responsible for misuse.
