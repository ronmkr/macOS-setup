package modules

import (
	"fmt"

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
	// ... (rest of logic)
	return m.Engine.RestartApp("Dock")
}
