package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/macos-setup/pkg/core"
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

	m.Engine.DefaultsWrite("NSGlobalDomain", "NSAutomaticWindowAnimationsEnabled", strconv.FormatBool(m.Config.UIAnimations), "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "_HIHideMenuBar", strconv.FormatBool(m.Config.AutohideMenuBar), "bool")

	return nil
}
