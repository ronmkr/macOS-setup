package core

import (
	"os"
	"testing"
)

func TestLoadConfig(t *testing.T) {
	content := `
[finder]
enabled = true
show_all_files = true

[dock]
tile_size = 42
`
	tmpfile, err := os.CreateTemp("", "settings.toml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpfile.Name())

	if _, err := tmpfile.Write([]byte(content)); err != nil {
		t.Fatal(err)
	}
	if err := tmpfile.Close(); err != nil {
		t.Fatal(err)
	}

	config, err := LoadConfig(tmpfile.Name())
	if err != nil {
		t.Fatalf("LoadConfig failed: %v", err)
	}

	if !config.Finder.Enabled {
		t.Error("Expected finder.enabled to be true")
	}
	if config.Dock.TileSize != 42 {
		t.Errorf("Expected dock.tile_size to be 42, got %d", config.Dock.TileSize)
	}
}
