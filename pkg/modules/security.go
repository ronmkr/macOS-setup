package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type SecurityModule struct {
	Engine *core.Engine
	Config core.SecurityConfig
}

func (m *SecurityModule) Name() string { return "security" }
func (m *SecurityModule) Dependencies() []string { return []string{} }

func (m *SecurityModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Security...")
	m.Engine.DefaultsWrite("com.apple.screensaver", "askForPasswordDelay", strconv.Itoa(m.Config.ScreenLockDelay), "int")

	if m.Config.Firewall {
		if m.Engine.DryRun {
			fmt.Println("[DRY-RUN] Would enable Application Firewall")
		} else {
			m.Engine.Ctx.RunAsRoot("/usr/libexec/ApplicationFirewall/socketfilterfw", "--setglobalstate", "on").Run()
		}
	}

	if !m.Config.GuestAccount {
		m.Engine.DefaultsWrite("/Library/Preferences/com.apple.loginwindow", "GuestEnabled", "false", "bool")
	}

	return nil
}
