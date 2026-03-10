package modules

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/ronmkr/MacPilot/pkg/core"
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
		if m.Engine.DryRun {
			fmt.Println("[DRY-RUN] Would clear caches")
		} else {
			entries, _ := os.ReadDir(cacheDir)
			for _, entry := range entries {
				os.RemoveAll(filepath.Join(cacheDir, entry.Name()))
			}
		}
	}

	if m.Config.EmptyTrash {
		trashDir := filepath.Join(m.Engine.Ctx.HomeDir, ".Trash")
		if m.Engine.DryRun {
			fmt.Println("[DRY-RUN] Would empty trash")
		} else {
			entries, _ := os.ReadDir(trashDir)
			for _, entry := range entries {
				os.RemoveAll(filepath.Join(trashDir, entry.Name()))
			}
		}
	}

	if m.Config.DownloadsOlderThanDay > 0 {
		downloadsDir := filepath.Join(m.Engine.Ctx.HomeDir, "Downloads")
		if m.Engine.DryRun {
			fmt.Printf("[DRY-RUN] Would clear downloads older than %d days\n", m.Config.DownloadsOlderThanDay)
		} else {
			cutoff := time.Now().AddDate(0, 0, -m.Config.DownloadsOlderThanDay)
			entries, _ := os.ReadDir(downloadsDir)
			for _, entry := range entries {
				info, err := entry.Info()
				if err == nil && info.ModTime().Before(cutoff) {
					os.RemoveAll(filepath.Join(downloadsDir, entry.Name()))
				}
			}
		}
	}

	return nil
}
