# macOS Setup Framework

A professional-grade automation framework for configuring macOS. This tool handles system preferences, security hardening, software installation, and developer environment setup with a focus on idempotency and safety.

## Key Features

- **TOML-First Config:** Manage your entire system via a human-readable `config/settings.toml` (similar to `.bashrc` or `tmux.conf`).
- **User-Aware Context:** Automatically detects the logged-in user to apply preferences to your actual profile.
- **Idempotency:** Reads existing settings before writing; skips unnecessary changes.
- **Dry-Run Mode (`-d`):** Preview exactly what changes will be made without modifying your system.
- **Brewfile Support:** Manages all Homebrew packages via a central `config/Brewfile`.
- **Dock Management:** Automatically manages pinned apps and appearance.
- **Native Notifications:** Sends a macOS notification when the setup process is complete.

## Quick Start

1. **Build the binary:**
   ```bash
   make build
   ```

2. **Customize your settings:**
   Edit `config/settings.toml`. Every option is commented and documented.

3. **Preview changes (Dry Run):**
   ```bash
   make dry
   ```

4. **Apply settings:**
   ```bash
   ./macos-setup -a
   ```

## Configuration (TOML)

The `config/settings.toml` file is the brain of the operation. It is divided into clear sections:
- `[finder]`: Hidden files, path bars, screenshots.
- `[dock]`: Icon size, autohide, magnification.
- `[system]`: Dark mode, UI animations, menu bar.
- `[input]`: Trackpad gestures, keyboard repeat rates.
- `[brew]`: Package management.
- `[cleanup]`: Cache and trash maintenance.

## Testing

Run the Go test suite:
```bash
make test
```

## Requirements

- macOS (Intel or Apple Silicon).
- Go 1.21+.
- Sudo privileges (requested on-demand).

---
*Created and maintained with care for a seamless macOS experience.*
