package core

import (
	"os"

	"github.com/BurntSushi/toml"
)

type AppConfig struct {
	Finder         FinderConfig         `toml:"finder"`
	Dock           DockConfig           `toml:"dock"`
	System         SystemConfig         `toml:"system"`
	Security       SecurityConfig       `toml:"security"`
	Brew           BrewConfig           `toml:"brew"`
	Cleanup        CleanupConfig        `toml:"cleanup"`
	Input          InputConfig          `toml:"input"`
	SoftwareUpdate SoftwareUpdateConfig `toml:"softwareupdate"`
	Developer      DeveloperConfig      `toml:"developer"`
}

type FinderConfig struct {
	Enabled         bool   `toml:"enabled"`
	ShowAllFiles    bool   `toml:"show_all_files"`
	ShowExtensions  bool   `toml:"show_extensions"`
	ShowPathBar     bool   `toml:"show_path_bar"`
	ShowStatusBar   bool   `toml:"show_status_bar"`
	ViewStyle       string `toml:"view_style"`
	SearchScope     string `toml:"search_scope"`
	ScreenshotsPath string `toml:"screenshots_path"`
}

type DockConfig struct {
	Enabled        bool   `toml:"enabled"`
	TileSize       int    `toml:"tile_size"`
	Magnification  bool   `toml:"magnification"`
	LargeSize      int    `toml:"large_size"`
	Autohide       bool   `toml:"autohide"`
	ShowRecents    bool   `toml:"show_recent_apps"`
	MinimizeEffect string `toml:"minimize_effect"`
	Position       string `toml:"position"`
}

type SystemConfig struct {
	Enabled          bool `toml:"enabled"`
	DarkMode         bool `toml:"dark_mode"`
	UIAnimations     bool `toml:"ui_animations"`
	AutohideMenuBar  bool `toml:"autohide_menu_bar"`
	ClockShowSeconds bool `toml:"clock_show_seconds"`
}

type InputConfig struct {
	Enabled             bool    `toml:"enabled"`
	TapToClick          bool    `toml:"tap_to_click"`
	ThreeFingerDrag     bool    `toml:"three_finger_drag"`
	KeyRepeat           int     `toml:"key_repeat"`
	InitialKeyRepeat    int     `toml:"initial_key_repeat"`
	TrackpadSpeed       float64 `toml:"trackpad_speed"`
	NaturalScrolling    bool    `toml:"natural_scrolling"`
	KeyboardAutocorrect bool    `toml:"keyboard_autocorrect"`
}

type SecurityConfig struct {
	Enabled         bool `toml:"enabled"`
	Firewall        bool `toml:"firewall"`
	FileVaultCheck  bool `toml:"filevault_check"`
	GuestAccount    bool `toml:"guest_account"`
	ScreenLockDelay int  `toml:"screen_lock_delay"`
}

type BrewConfig struct {
	Enabled      bool   `toml:"enabled"`
	UseBrewfile  bool   `toml:"use_brewfile"`
	BrewfilePath string `toml:"brewfile_path"`
}

type CleanupConfig struct {
	Enabled               bool `toml:"enabled"`
	EmptyTrash            bool `toml:"empty_trash"`
	ClearCaches           bool `toml:"clear_caches"`
	DownloadsOlderThanDay int  `toml:"downloads_older_than_days"`
}

type SoftwareUpdateConfig struct {
	Enabled bool `toml:"enabled"`
	Auto    bool `toml:"auto_install"`
}

type DeveloperConfig struct {
	Enabled   bool   `toml:"enabled"`
	GitName   string `toml:"git_name"`
	GitEmail  string `toml:"git_email"`
	GitEditor string `toml:"git_editor"`
}

func LoadConfig(path string) (*AppConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var config AppConfig
	if _, err := toml.Decode(string(data), &config); err != nil {
		return nil, err
	}
	return &config, nil
}
