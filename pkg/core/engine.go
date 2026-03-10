package core

import (
	"fmt"
	"os/exec"
	"strings"
)

type Engine struct {
	Ctx     *UserContext
	DryRun  bool
	Verbose bool
}

func (e *Engine) DefaultsWrite(domain, key, val, valType string) error {
	currentVal, _ := e.Ctx.DefaultsRead(domain, key)

	// Boolean normalization loophole fix
	if valType == "bool" {
		if (val == "true" && currentVal == "1") || (val == "false" && currentVal == "0") {
			if e.Verbose {
				fmt.Printf("  - %s: %s (bool) already set to %s\n", domain, key, val)
			}
			return nil
		}
	} else if currentVal == val {
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

	var cmd *exec.Cmd
	if strings.HasPrefix(domain, "/Library") || strings.HasPrefix(domain, "/System") {
		if e.Verbose {
			fmt.Printf("    Elevating privileges for system domain: %s\n", domain)
		}
		cmd = e.Ctx.RunAsRoot("defaults", args...)
	} else {
		cmd = e.Ctx.RunAsUser("defaults", args...)
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to write default: %w", err)
	}

	return nil
}

func (e *Engine) RestartApp(appName string) error {
	if e.DryRun {
		fmt.Printf("[DRY-RUN] Would restart %s\n", appName)
		return nil
	}

	if err := exec.Command("pgrep", "-x", appName).Run(); err != nil {
		return nil // App not running
	}

	fmt.Printf("Restarting %s...\n", appName)
	return e.Ctx.RunAsUser("killall", appName).Run()
}

func (e *Engine) Notify(title, message string) {
	if e.DryRun {
		return
	}
	script := fmt.Sprintf("display notification \"%s\" with title \"%s\" sound name \"Crystal\"", message, title)
	e.Ctx.RunAsUser("osascript", "-e", script).Run()
}
