package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/macos-setup/pkg/core"
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

	m.Engine.DefaultsWrite("com.apple.screensaver", "askForPassword", "1", "int")
	m.Engine.DefaultsWrite("com.apple.screensaver", "askForPasswordDelay", strconv.Itoa(m.Config.ScreenLockDelay), "int")
	
	// Firewall
	state := "0"
	if m.Config.Firewall { state = "1" }
	m.Engine.DefaultsWrite("/Library/Preferences/com.apple.alf", "globalstate", state, "int")

	return nil
}
