package modules

import (
	"fmt"
	"os/exec"

	"github.com/ronmkr/macos-setup/pkg/core"
)

type DeveloperModule struct {
	Engine *core.Engine
	Config core.DeveloperConfig
}

func (m *DeveloperModule) Name() string { return "developer" }
func (m *DeveloperModule) Dependencies() []string { return []string{} }

func (m *DeveloperModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Developer Tools...")
	if err := exec.Command("xcode-select", "-p").Run(); err != nil {
		fmt.Println("    Installing Xcode Command Line Tools...")
		if !m.Engine.DryRun {
			exec.Command("xcode-select", "--install").Run()
		}
	}
	return nil
}
