package modules

import (
	"fmt"
	"os"
	"os/exec"
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
		fmt.Println("    Cleaning user caches...")
		cacheDir := filepath.Join(m.Engine.Ctx.HomeDir, "Library", "Caches")
		if !m.Engine.DryRun {
			entries, _ := os.ReadDir(cacheDir)
			for _, entry := range entries {
				os.RemoveAll(filepath.Join(cacheDir, entry.Name()))
			}
		} else {
			fmt.Printf("[DRY-RUN] Would remove all files in %s\n", cacheDir)
		}
	}

	return nil
}

type SoftwareUpdateModule struct {
	Engine *core.Engine
	Config core.SoftwareUpdateConfig
}

func (m *SoftwareUpdateModule) Name() string { return "softwareupdate" }
func (m *SoftwareUpdateModule) Dependencies() []string { return []string{} }

func (m *SoftwareUpdateModule) Run() error {
	if !m.Config.Enabled { return nil }
	fmt.Println("==> Checking for macOS updates...")
	
	if m.Engine.DryRun {
		fmt.Println("[DRY-RUN] Would check and install updates")
		return nil
	}

	if m.Config.Auto {
		cmd := exec.Command("sudo", "softwareupdate", "-i", "-a", "-R")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}
	
	return nil
}
