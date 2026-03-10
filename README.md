# macOS Setup Framework

A professional-grade automation framework for configuring macOS. This tool handles system preferences, security hardening, software installation, and developer environment setup with a focus on idempotency and safety.

## Key Features

- **User-Aware Context:** Automatically detects the logged-in user to apply preferences to your actual profile, even when running with `sudo`.
- **Idempotency:** Reads existing settings before writing; skips unnecessary changes to prevent service flickering (Dock/Finder).
- **Dry-Run Mode (`-d`):** Preview exactly what changes will be made without modifying your system.
- **Brewfile Support:** Manages all Homebrew packages, Casks, and App Store apps via a central `config/Brewfile`.
- **Dock Management:** Automatically cleans up "bloatware" and adds your preferred apps to the Dock using `dockutil`.
- **Modular Architecture:** Easily enable or disable specific features (Security, System, Finder, Developer, etc.).
- **Native Notifications:** Sends a macOS notification when the setup process is complete.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ronmkr/macOS-setup.git
   cd macOS-setup
   ```

2. **Customize your apps:**
   Edit `config/Brewfile` to add your preferred software.

3. **Preview changes (Dry Run):**
   ```bash
   sudo ./macos-setup -d --all
   ```

4. **Apply settings:**
   ```bash
   sudo ./macos-setup --all
   ```

## Modules

| Module | Description |
| :--- | :--- |
| `brew` | Installs Homebrew, Brews, Casks, and Mas apps from `config/Brewfile`. |
| `developer` | Installs Xcode CLI tools and configures global Git settings. |
| `dotfiles` | Symlinks configuration files from the `dotfiles/` directory. |
| `security` | Hardens macOS security (Firewall, FileVault check, SIP check, etc.). |
| `system` | Configures UI animations, power management, and Spotlight. |
| `dock` | Customizes Dock appearance and manages pinned applications. |
| `finder` | Optimizes Finder views, hidden files, and desktop icons. |
| `cleanup` | A robust system-wide cache and temporary file cleaner. |
| `softwareupdate` | Checks for and installs official macOS system updates. |

## CLI Options

- `-d, --dry-run`: Preview changes without applying them.
- `-V, --verbose`: Show detailed output for every setting check.
- `-a, --all`: Run the default set of configuration modules.
- `-l, --list`: List all available modules.
- `--no-restart`: Skip application/service restarts after changes.

## Requirements

- macOS (Intel or Apple Silicon).
- Sudo privileges.
- (Optional) `dotfiles/` directory for your custom configurations.

---
*Created and maintained with care for a seamless macOS experience.*
