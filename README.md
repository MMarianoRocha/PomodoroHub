# PomodoroHub

A client-server application for managing team Pomodoro sessions.

The server runs on a single machine on the local network and clients connect via a desktop app.

---

## Key characteristics

| Item | Detail |
|---|---|
| **Architecture** | 1 FastAPI server + N desktop clients (PySide6) |
| **Communication** | HTTP REST over LAN — no internet required |
| **Database** | Local SQLite on the server (`test.db`) |
| **Authentication** | Username + password with bcrypt hashing (passlib 1.7.4 + bcrypt 4.0.1) |
| **Overlay** | Floating draggable widget displayed on top of all windows |
| **Distribution** | Desktop distributed as a self-contained `.exe` (PyInstaller) — no Python required on client machines |
| **Python** | 3.14+ |
| **OS** | Windows |

---

## Project structure

```
main.py               # Server entrypoint (Uvicorn)
desktop_app.py        # Desktop client entrypoint
app/app.py            # FastAPI app + lifecycle + routers
models/               # SQLAlchemy models (User, Pomodoro)
routes/               # REST routes (users, pomodoro)
schemas/              # Pydantic validation schemas
services/             # Authentication logic (bcrypt)
database/             # SQLAlchemy config + async session
desktop/              # PySide6 UI, HTTP client, local session
requirements-server.txt   # Server dependencies
requirements-client.txt   # Client dependencies (PySide6 + PyInstaller)
run_server.bat        # Starts the server from source
run_client.bat        # Starts the desktop app from source
build_windows.bat     # Builds the .exe files (server + client)
```

---

## Prerequisites

- Windows 10/11
- Python 3.14+ installed and on PATH (`py --list` should show Python 3.14)
- Access to the project folder (local or network share)

---

## Server setup

### 1. Set the server IP

Edit the two files below and replace `10.20.30.228` with the actual LAN IP of the machine that will run the server:

**`desktop/ui.py`** and **`desktop/api_client.py`** — find the line:
```python
"http://10.20.30.228:8000"
```
and replace it with the correct IP.

After changing it, [rebuild the executables](#building-the-executables).

### 2. Start the server

On the server machine, run as the service user:

```bat
run_server.bat
```

The script automatically creates an isolated virtual environment (`.venv-server`), installs dependencies, and starts the API on `0.0.0.0:8000`.

> **UNC paths:** the bat uses `pushd` — works even when launched from a network path `\\server\share\...`

### 3. Verify it is running

From any PC on the network, open in a browser:
```
http://<SERVER_IP>:8000/docs
```
If the interactive API documentation loads, the server is up. If it times out, allow port 8000 in Windows Firewall:
```bat
netsh advfirewall firewall add rule name="PomodoroHub" dir=in action=allow protocol=TCP localport=8000
```

---

## Building the executables

On the development machine (does not need to be the server):

```bat
build_windows.bat
```

The script creates the `.venv-build` environment, installs all dependencies and generates:

```
dist\PomodoroHubServer.exe   ← runs on the server machine
dist\PomodoroHubClient.exe   ← distribute to users
```

> **Important:** rebuild `PomodoroHubClient.exe` whenever the server IP is changed in the code.

---

## Distributing to users

Copy `dist\PomodoroHubClient.exe` to each user's PC. No Python or any other dependency needs to be installed — the exe is fully self-contained.

When the app opens:
1. The **Server** field is already pre-filled with the IP configured at build time
2. Click **Criar conta** to register a new user
3. **Login** with username and password
4. Click **Iniciar Pomodoro** — the floating overlay appears on screen

---

## Running from source (development)

To test the client without building an exe:

```bat
run_client.bat
```

Creates the `.venv-client` environment and runs `python -m desktop`.

---

## Authentication

- Passwords stored as bcrypt hashes via passlib
- **Required pinned versions:** `passlib==1.7.4` + `bcrypt==4.0.1` — newer bcrypt versions break compatibility with passlib 1.7.4
- Password validation: minimum 6 characters, maximum 72

---

## Compatibility notes

| Component | Pinned version | Reason |
|---|---|---|
| `bcrypt` | `==4.0.1` | Versions 4.2+ are incompatible with passlib 1.7.4 |
| `passlib` | `==1.7.4` | Last stable version with bcrypt support |
| `pydantic` | `>=2.9.0` | Earlier versions have no wheel for Python 3.14 (requires Rust compilation) |
| `PySide6` | `>=6.8.0` | Version 6.8.x does not support Python 3.14; pip picks a compatible version automatically |



## Session management

- `POST /pomodoro/start` starts a new Pomodoro session for the authenticated user.
- `POST /pomodoro/stop` stops the current active session.
- `GET /pomodoro/active` returns all currently active Pomodoro sessions.

The desktop client polls this endpoint regularly so every connected user can see who
is actively working in real time.

## Main API endpoints

- `POST /users/register`
- `POST /users/login`
- `POST /pomodoro/start`
- `POST /pomodoro/stop`
- `GET /pomodoro/active`

## Notes

- The backend must be reachable via network from each client machine.
- The client uses the saved `Servidor` value, `POMODORO_HUB_API_URL`, or `--api-url` to connect to the backend.
