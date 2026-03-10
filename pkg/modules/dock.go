package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/macos-setup/pkg/core"
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
	return m.Engine.RestartApp("Dock")
}
