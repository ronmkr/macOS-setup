package modules

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/ronmkr/macos-setup/pkg/core"
)

type CleanupModule struct {
	Engine *core.Engine
	Config core.CleanupConfig
}

func (m *CleanupModule) Name() string { return "cleanup" }
func (m *CleanupModule) Dependencies() []string { return []string{} }

func (m *CleanupModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Performing System Cleanup...")
	if m.Config.ClearCaches {
		cacheDir := filepath.Join(m.Engine.Ctx.HomeDir, "Library", "Caches")
		if !m.Engine.DryRun {
			entries, _ := os.ReadDir(cacheDir)
			for _, entry := range entries {
				os.RemoveAll(filepath.Join(cacheDir, entry.Name()))
			}
		}
	}
	return nil
}
