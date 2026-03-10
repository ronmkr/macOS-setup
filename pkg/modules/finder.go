package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/MacPilot/pkg/core"
)

type FinderModule struct {
	Engine *core.Engine
	Config core.FinderConfig
}

func (m *FinderModule) Name() string { return "finder" }
func (m *FinderModule) Dependencies() []string { return []string{} }

func (m *FinderModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Finder...")
	m.Engine.DefaultsWrite("com.apple.finder", "AppleShowAllFiles", strconv.FormatBool(m.Config.ShowAllFiles), "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "AppleShowAllExtensions", strconv.FormatBool(m.Config.ShowExtensions), "bool")
	m.Engine.DefaultsWrite("com.apple.finder", "ShowPathbar", strconv.FormatBool(m.Config.ShowPathBar), "bool")
	m.Engine.DefaultsWrite("com.apple.finder", "ShowStatusBar", strconv.FormatBool(m.Config.ShowStatusBar), "bool")

	if m.Config.ViewStyle != "" {
		m.Engine.DefaultsWrite("com.apple.finder", "FXPreferredViewStyle", m.Config.ViewStyle, "string")
	}
	if m.Config.SearchScope != "" {
		m.Engine.DefaultsWrite("com.apple.finder", "FXDefaultSearchScope", m.Config.SearchScope, "string")
	}

	path := core.ExpandPath(m.Config.ScreenshotsPath, m.Engine.Ctx.HomeDir)
	core.EnsureDir(path)
	m.Engine.DefaultsWrite("com.apple.screencapture", "location", path, "string")
	return m.Engine.RestartApp("Finder")
}
