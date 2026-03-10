package modules

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type BrewModule struct {
	Engine *core.Engine
	Config core.BrewConfig
}

func (m *BrewModule) Name() string { return "brew" }
func (m *BrewModule) Dependencies() []string { return []string{"softwareupdate"} }

func (m *BrewModule) Run() error {
	if !m.Config.Enabled {
		return nil
	}
	fmt.Println("==> Configuring Homebrew...")

	// 1. Check if Homebrew is installed
	brewPath, err := exec.LookPath("brew")
	if err != nil {
		fmt.Println("    Homebrew not found. Starting installation...")
		if m.Engine.DryRun {
			fmt.Println("[DRY-RUN] Would install Homebrew")
		} else {
			installCmd := "bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
			// Homebrew must be run as the user, not root
			cmd := m.Engine.Ctx.RunAsUser("bash", "-c", installCmd)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			if err := cmd.Run(); err != nil {
				return fmt.Errorf("failed to install Homebrew: %w", err)
			}

			// After install, we need to locate it immediately for the current session
			// Common paths: Apple Silicon (/opt/homebrew/bin/brew), Intel (/usr/local/bin/brew)
			if _, err := os.Stat("/opt/homebrew/bin/brew"); err == nil {
				brewPath = "/opt/homebrew/bin/brew"
			} else if _, err := os.Stat("/usr/local/bin/brew"); err == nil {
				brewPath = "/usr/local/bin/brew"
			}
		}
	}

	// 2. Check for Git (Homebrew usually installs it, but let's be safe)
	if _, err := exec.LookPath("git"); err != nil {
		fmt.Println("    Git not found. Installing via Homebrew...")
		if m.Engine.DryRun {
			fmt.Println("[DRY-RUN] Would install git via brew")
		} else if brewPath != "" {
			cmd := m.Engine.Ctx.RunAsUser(brewPath, "install", "git")
			if err := cmd.Run(); err != nil {
				return fmt.Errorf("failed to install git: %w", err)
			}
		}
	}

	// 3. Run Brew Bundle
	brewfile := m.Config.BrewfilePath
	if brewfile == "" {
		brewfile = filepath.Join(".", "config", "Brewfile")
	}

	if m.Engine.DryRun {
		fmt.Printf("[DRY-RUN] Would run 'brew bundle' with %s\n", brewfile)
		return nil
	}

	if brewPath == "" {
		return fmt.Errorf("brew path could not be determined")
	}

	fmt.Printf("    Running brew bundle from %s...\n", brewfile)
	cmd := m.Engine.Ctx.RunAsUser(brewPath, "bundle", "--file="+brewfile)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
