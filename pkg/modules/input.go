package modules

import (
	"fmt"
	"strconv"

	"github.com/ronmkr/MacPilot/pkg/core"
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
	m.Engine.DefaultsWrite("com.apple.driver.AppleBluetoothMultitouch.trackpad", "TrackpadThreeFingerDrag", strconv.FormatBool(m.Config.ThreeFingerDrag), "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "KeyRepeat", strconv.Itoa(m.Config.KeyRepeat), "int")
	if m.Config.InitialKeyRepeat > 0 {
		m.Engine.DefaultsWrite("NSGlobalDomain", "InitialKeyRepeat", strconv.Itoa(m.Config.InitialKeyRepeat), "int")
	}
	m.Engine.DefaultsWrite("NSGlobalDomain", "com.apple.trackpad.scaling", fmt.Sprintf("%f", m.Config.TrackpadSpeed), "float")
	m.Engine.DefaultsWrite("NSGlobalDomain", "com.apple.swipescrolldirection", strconv.FormatBool(m.Config.NaturalScrolling), "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "NSAutomaticSpellingCorrectionEnabled", strconv.FormatBool(m.Config.KeyboardAutocorrect), "bool")

	return nil
}
