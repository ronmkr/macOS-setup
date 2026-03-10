package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type DockModule struct {
	Engine *core.Engine
	Config core.DockConfig
}

func (m *DockModule) Name() string { return "dock" }
func (m *DockModule) Dependencies() []string { return []string{} }

func (m *DockModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Dock...")
	m.Engine.DefaultsWrite("com.apple.dock", "tilesize", strconv.Itoa(m.Config.TileSize), "int")
	m.Engine.DefaultsWrite("com.apple.dock", "magnification", strconv.FormatBool(m.Config.Magnification), "bool")
	m.Engine.DefaultsWrite("com.apple.dock", "autohide", strconv.FormatBool(m.Config.Autohide), "bool")

	if m.Config.LargeSize > 0 {
		m.Engine.DefaultsWrite("com.apple.dock", "largesize", strconv.Itoa(m.Config.LargeSize), "int")
	}
	m.Engine.DefaultsWrite("com.apple.dock", "show-recents", strconv.FormatBool(m.Config.ShowRecents), "bool")

	if m.Config.MinimizeEffect != "" {
		m.Engine.DefaultsWrite("com.apple.dock", "mineffect", m.Config.MinimizeEffect, "string")
	}
	if m.Config.Position != "" {
		m.Engine.DefaultsWrite("com.apple.dock", "orientation", m.Config.Position, "string")
	}

	return m.Engine.RestartApp("Dock")
}
