package core

import (
	"fmt"
	"os/exec"
	"strings"
)

// Engine handles the core execution logic
type Engine struct {
	Ctx     *UserContext
	DryRun  bool
	Verbose bool
}

// DefaultsWrite performs an idempotent write to the macOS defaults system
func (e *Engine) DefaultsWrite(domain, key, val, valType string) error {
	// Read current value
	currentVal, _ := e.Ctx.DefaultsRead(domain, key)
	if currentVal == val {
		if e.Verbose {
			fmt.Printf("  - %s: %s already set\n", domain, key)
		}
		return nil
	}

	if e.DryRun {
		fmt.Printf("[DRY-RUN] Would write: %s %s -> %s\n", domain, key, val)
		return nil
	}

	var args []string
	args = append(args, "write", domain, key)
	if valType != "" {
		args = append(args, "-"+valType, val)
	} else {
		args = append(args, val)
	}

	// Determine if this needs root (Library/System domains)
	var cmd *exec.Cmd
	if strings.HasPrefix(domain, "/Library") || strings.HasPrefix(domain, "/System") {
		fmt.Printf("    Elevating privileges for system domain: %s\n", domain)
		cmd = e.Ctx.RunAsRoot("defaults", args...)
	} else {
		cmd = e.Ctx.RunAsUser("defaults", args...)
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to write default: %w", err)
	}

	return nil
}

// RestartApp restarts a macOS application
func (e *Engine) RestartApp(appName string) error {
	if e.DryRun {
		fmt.Printf("[DRY-RUN] Would restart %s\n", appName)
		return nil
	}

	// Check if running
	if err := exec.Command("pgrep", "-x", appName).Run(); err != nil {
		return nil // App not running
	}

	fmt.Printf("Restarting %s...\n", appName)
	return e.Ctx.RunAsUser("killall", appName).Run()
}

// Notify sends a macOS notification
func (e *Engine) Notify(title, message string) {
	if e.DryRun {
		return
	}
	script := fmt.Sprintf("display notification \"%s\" with title \"%s\" sound name \"Crystal\"", message, title)
	e.Ctx.RunAsUser("osascript", "-e", script).Run()
}
