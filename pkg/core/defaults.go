package core

// GetDefaultConfig returns a safe default configuration
func GetDefaultConfig() *AppConfig {
	return &AppConfig{
		Finder: FinderConfig{
			Enabled:         true,
			ShowAllFiles:    true,
			ShowExtensions:  true,
			ShowPathBar:     true,
			ShowStatusBar:   true,
			ViewStyle:       "clmv",
			SearchScope:     "SCcf",
			ScreenshotsPath: "~/Desktop/Screenshots",
		},
		Dock: DockConfig{
			Enabled:        true,
			TileSize:       36,
			Magnification:  true,
			LargeSize:      64,
			Autohide:       true,
			ShowRecents:    false,
			MinimizeEffect: "scale",
			Position:       "bottom",
		},
		System: SystemConfig{
			Enabled:          true,
			DarkMode:         true,
			UIAnimations:     false,
			AutohideMenuBar:  true,
			ClockShowSeconds: true,
		},
		Input: InputConfig{
			Enabled:          true,
			TapToClick:       true,
			ThreeFingerDrag:  true,
			KeyRepeat:        2,
			InitialKeyRepeat: 15,
			TrackpadSpeed:    1.5,
			NaturalScrolling: false,
		},
		Security: SecurityConfig{
			Enabled:         true,
			Firewall:        true,
			FileVaultCheck:  true,
			GuestAccount:    false,
			ScreenLockDelay: 0,
		},
		Brew: BrewConfig{
			Enabled:      true,
			UseBrewfile:  true,
			BrewfilePath: "config/Brewfile",
		},
		Cleanup: CleanupConfig{
			Enabled:               true,
			EmptyTrash:            true,
			ClearCaches:           true,
			DownloadsOlderThanDay: 30,
		},
	}
}
