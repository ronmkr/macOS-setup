package modules

import (
	"fmt"
	"os/exec"
	"path/filepath"

	"github.com/ronmkr/macos-setup/pkg/core"
)

type BrewModule struct {
	Engine *core.Engine
}

func (m *BrewModule) Name() string { return "brew" }

func (m *BrewModule) Dependencies() []string { return []string{"developer"} }

func (m *BrewModule) Run() error {
	fmt.Println("==> Configuring Homebrew...")

	if err := exec.Command("command", "-v", "brew").Run(); err != nil {
		fmt.Println("    Installing Homebrew...")
		if !m.Engine.DryRun {
			installCmd := "bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
			if err := m.Engine.Ctx.RunAsUser("bash", "-c", installCmd).Run(); err != nil {
				return fmt.Errorf("failed to install Homebrew: %w", err)
			}
		}
	}

	brewfile := filepath.Join(".", "config", "Brewfile")
	if m.Engine.DryRun {
		fmt.Printf("[DRY-RUN] Would run 'brew bundle' with %s\n", brewfile)
		return nil
	}

	fmt.Printf("    Running brew bundle from %s...\n", brewfile)
	return m.Engine.Ctx.RunAsUser("brew", "bundle", "--file="+brewfile).Run()
}
