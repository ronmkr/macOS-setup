package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/macos-setup/pkg/core"
)

type InputModule struct {
	Engine *core.Engine
	Config core.InputConfig
}

func (m *InputModule) Name() string { return "input" }
func (m *InputModule) Dependencies() []string { return []string{} }

func (m *InputModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Configuring Input...")
	m.Engine.DefaultsWrite("com.apple.driver.AppleBluetoothMultitouch.trackpad", "Clicking", strconv.FormatBool(m.Config.TapToClick), "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "KeyRepeat", strconv.Itoa(m.Config.KeyRepeat), "int")
	return nil
}
