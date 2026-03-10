# GEMINI.md - Project Mandates & Architecture

This document serves as the primary source of truth for all AI-driven development and maintenance tasks within the `macos-setup` project. Adhere strictly to these guidelines.

## 1. Project Overview
`macos-setup` is a professional-grade automation framework for configuring macOS. It has transitioned from a Bash-based modular script to a compiled **Go-based CLI tool** to improve performance, type safety, and error handling.

## 2. Core Architecture
The project follows a modular, engine-driven design:
- **`main.go`**: Entry point for CLI flag parsing and module orchestration.
- **`pkg/core/`**: The "Engine" layer.
    - `context.go`: Manages user detection, home directory resolution, and privilege escalation (Sudo-on-demand).
    - `engine.go`: Implements idempotency logic for `defaults write` operations and application restarts.
- **`pkg/modules/`**: Discrete setup units implementing the `Module` interface.
- **`config/Brewfile`**: Externalized dependency list for Homebrew, Casks, and App Store apps.

## 3. Engineering Mandates

### 3.1. Privilege Escalation (Sudo-on-demand)
- **Do NOT** enforce global root execution in `main.go`.
- Use `ctx.RunAsUser()` for all user-level preferences (e.g., `com.apple.finder`).
- Use `ctx.RunAsRoot()` only for system-level changes (e.g., `/Library/Preferences` or `pmset`). This triggers the terminal's password prompt only when necessary.

### 3.2. Idempotency & Safety
- **Always read before writing**: Every configuration change must verify the current state. If the state matches the target, skip the operation.
- **Respect Dry-Run**: All actions that modify the system (file writes, `defaults write`, `killall`) MUST be guarded by the `Engine.DryRun` flag.
- **Surgical Restarts**: Only restart applications (e.g., `killall Dock`) if a setting was actually changed during that execution.

### 3.3. Porting Guidelines (Bash to Go)
When porting remaining `.sh` modules to Go:
1.  Create a new file in `pkg/modules/`.
2.  Implement the `Module` interface: `Name() string` and `Run() error`.
3.  Register the new module in the `availableModules` slice in `main.go`.
4.  Replace shell commands with calls to `Engine.DefaultsWrite` wherever possible.

## 4. Coding Standards
- **Go Version**: 1.21+
- **Error Handling**: Wrap errors with context (e.g., `fmt.Errorf("failed to write key: %w", err)`).
- **Logging**: Use `fmt.Printf` for user-facing status. Prefix status messages with `==>` for modules and `    -` for individual settings.
- **Paths**: Always use `filepath.Join` and `ctx.HomeDir` for filesystem operations. Do not hardcode `/Users/username`.

## 5. Development Workflow
1.  **Research**: Identify the `defaults` domain and key for a setting.
2.  **Implementation**: Add the logic to the appropriate Go module.
3.  **Validation**: Run with `./macos-setup -d -v --module-name` to verify the dry-run output and idempotency check.
4.  **Documentation**: Update `README.md` if a new module or CLI flag is added.

---
*Note: This file is for AI context. Do not delete or modify without a specific Directive.*
