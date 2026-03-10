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
	if !m.Config.Enabled {
		return nil
	}
	fmt.Println("==> Configuring Input (Trackpad & Keyboard)...")

	// Trackpad
	tap := strconv.FormatBool(m.Config.TapToClick)
	m.Engine.DefaultsWrite("com.apple.driver.AppleBluetoothMultitouch.trackpad", "Clicking", tap, "bool")
	m.Engine.DefaultsWrite("com.apple.AppleMultitouchTrackpad", "Clicking", tap, "bool")
	m.Engine.DefaultsWrite("NSGlobalDomain", "com.apple.mouse.tapBehavior", "1", "int")

	drag := strconv.FormatBool(m.Config.ThreeFingerDrag)
	m.Engine.DefaultsWrite("com.apple.driver.AppleBluetoothMultitouch.trackpad", "TrackpadThreeFingerDrag", drag, "bool")
	m.Engine.DefaultsWrite("com.apple.AppleMultitouchTrackpad", "TrackpadThreeFingerDrag", drag, "bool")

	m.Engine.DefaultsWrite("NSGlobalDomain", "com.apple.trackpad.scaling", fmt.Sprintf("%f", m.Config.TrackpadSpeed), "float")
	m.Engine.DefaultsWrite("NSGlobalDomain", "com.apple.swipescrolldirection", strconv.FormatBool(m.Config.NaturalScrolling), "bool")

	// Keyboard
	m.Engine.DefaultsWrite("NSGlobalDomain", "KeyRepeat", strconv.Itoa(m.Config.KeyRepeat), "int")
	m.Engine.DefaultsWrite("NSGlobalDomain", "InitialKeyRepeat", strconv.Itoa(m.Config.InitialKeyRepeat), "int")
	m.Engine.DefaultsWrite("NSGlobalDomain", "NSAutomaticSpellingCorrectionEnabled", strconv.FormatBool(m.Config.KeyboardAutocorrect), "bool")

	return nil
}
