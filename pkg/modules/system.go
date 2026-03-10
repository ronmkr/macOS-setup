package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type SystemModule struct {
	Engine *core.Engine
	Config core.SystemConfig
}

func (m *SystemModule) Name() string { return "system" }
func (m *SystemModule) Dependencies() []string { return []string{"security"} }

func (m *SystemModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring System...")
	mode := "Dark"
	if !m.Config.DarkMode { mode = "Light" }
	m.Engine.DefaultsWrite("NSGlobalDomain", "AppleInterfaceStyle", mode, "")

	if m.Config.UIAnimations {
		m.Engine.DefaultsWrite("NSGlobalDomain", "NSAutomaticWindowAnimationsEnabled", "true", "bool")
	} else {
		m.Engine.DefaultsWrite("NSGlobalDomain", "NSAutomaticWindowAnimationsEnabled", "false", "bool")
	}

	m.Engine.DefaultsWrite("NSGlobalDomain", "_HIHideMenuBar", strconv.FormatBool(m.Config.AutohideMenuBar), "bool")
	m.Engine.DefaultsWrite("com.apple.menuextra.clock", "ShowSeconds", strconv.FormatBool(m.Config.ClockShowSeconds), "bool")

	return m.Engine.RestartApp("SystemUIServer")
}
