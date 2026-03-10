# MacPilot 👨‍✈️

The easiest way to get your Mac exactly how you like it. No more clicking through System Settings for hours or copy-pasting random terminal commands from StackOverflow.

## Why use this?
Because setting up a new Mac (or fixing an old one) should be a "one and done" thing. MacPilot handles the boring stuff so you can get back to doing cool things. It's fast, it's safe, and it's smart.

## The Good Stuff
- **One Config to Rule Them All:** Every single setting lives in `config/settings.toml`. It’s easy to read, has comments for everything, and you can take it with you anywhere.
- **Smart Sudo:** It runs as a normal user and only asks for your password when it actually needs to touch system files. No spamming `sudo` for things that don't need it.
- **Safe Mode (Dry Run):** Run it with `-d` to see exactly what would happen without actually changing anything. No surprises.
- **Never Double-Dips:** If a setting is already how you want it, MacPilot just skips it. This prevents your Dock or Finder from flickering unnecessarily.
- **Zero to Hero:** On a brand new machine? MacPilot will automatically grab **Homebrew** and **Git** for you if they’re missing.

## Quick Start

1. **Build it:**
   ```bash
   make build
   ```

2. **Peek under the hood (Dry Run):**
   ```bash
   ./MacPilot -d -v
   ```

3. **Let it rip:**
   ```bash
   ./MacPilot
   ```

4. **Maintenance (Run Cleanup Only):**
   ```bash
   ./MacPilot --cleanup
   ```

## Runtime Config
Want to use a different profile for work vs. home? Just pass the config file you want:
```bash
./MacPilot -c my-work-config.toml
```

## Going Back to Normal
Regretting that "Dark Mode only" life? You can reset your Mac to factory defaults anytime:
```bash
./MacPilot --restore
```

## What's inside the box?
- **Brew:** All your apps and tools via Homebrew.
- **Developer:** Xcode tools and your Git identity.
- **Security:** Firewalls and screen locks without the hassle.
- **System:** Visual tweaks, dark mode, and power settings.
- **Input:** Make your trackpad and keyboard behave.
- **Finder & Dock:** Clean up the clutter and show hidden files.
- **Cleanup:** Clear out the junk caches when you're done.

---
*Built with care. Go grab a coffee while your Mac sets itself up.* ☕️
