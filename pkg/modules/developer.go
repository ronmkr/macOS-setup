package modules

import (
	"fmt"
	"os/exec"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type DeveloperModule struct {
	Engine *core.Engine
	Config core.DeveloperConfig
}

func (m *DeveloperModule) Name() string { return "developer" }
func (m *DeveloperModule) Dependencies() []string { return []string{"brew"} }

func (m *DeveloperModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Developer Tools...")
	if err := m.Engine.Ctx.RunAsUser("xcode-select", "-p").Run(); err != nil {
		fmt.Println("    Installing Xcode Command Line Tools...")
		if !m.Engine.DryRun {
			m.Engine.Ctx.RunAsUser("xcode-select", "--install").Run()
		}
	}

	if _, err := exec.LookPath("git"); err == nil {
		if m.Config.GitName != "" {
			if m.Engine.DryRun {
				fmt.Printf("[DRY-RUN] Would set git user.name to %s\n", m.Config.GitName)
			} else {
				m.Engine.Ctx.RunAsUser("git", "config", "--global", "user.name", m.Config.GitName).Run()
			}
		}
		if m.Config.GitEmail != "" {
			if m.Engine.DryRun {
				fmt.Printf("[DRY-RUN] Would set git user.email to %s\n", m.Config.GitEmail)
			} else {
				m.Engine.Ctx.RunAsUser("git", "config", "--global", "user.email", m.Config.GitEmail).Run()
			}
		}
		if m.Config.GitEditor != "" {
			if m.Engine.DryRun {
				fmt.Printf("[DRY-RUN] Would set git core.editor to %s\n", m.Config.GitEditor)
			} else {
				m.Engine.Ctx.RunAsUser("git", "config", "--global", "core.editor", m.Config.GitEditor).Run()
			}
		}
	}
	return nil
}
