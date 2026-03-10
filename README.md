# macOS Setup Framework (Go Edition)

A professional-grade automation framework for configuring macOS.

## Key Features

- **TOML-Driven:** Manage everything via `settings.toml`.
- **Sudo-on-Demand:** Security-first privilege escalation.
- **Restore Mode:** Reset your Mac to factory defaults with a single command.
- **Dry-Run Mode:** Safe preview of all changes.

## Quick Start

1. **Build the tool:**
   ```bash
   make build
   ```

2. **Apply your custom settings:**
   ```bash
   ./macos-setup -a
   ```

3. **Restore to factory defaults:**
   ```bash
   ./macos-setup --restore
   ```

## Runtime Configuration

- `-c <path>`: Use a specific configuration file.
- `--restore`: Use the internal factory defaults (`config/settings_default.toml`).
- `-d`: Dry-run mode (no changes made).
- `-v`: Verbose output.

---
*Maintained with care for a seamless macOS experience.*
