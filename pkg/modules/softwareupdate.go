package modules

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type SoftwareUpdateModule struct {
	Engine *core.Engine
	Config core.SoftwareUpdateConfig
}

func (m *SoftwareUpdateModule) Name() string { return "softwareupdate" }
func (m *SoftwareUpdateModule) Dependencies() []string { return []string{} }

func (m *SoftwareUpdateModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Checking for macOS Updates...")
	if m.Engine.DryRun {
		fmt.Println("[DRY-RUN] Would check and install updates")
		return nil
	}
	if m.Config.Auto {
		cmd := exec.Command("sudo", "softwareupdate", "-i", "-a", "-R")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}
	return nil
}
