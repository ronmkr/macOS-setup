package modules

import (
	"testing"
	"github.com/ronmkr/MacPilot/pkg/core"
)

func TestModuleNames(t *testing.T) {
	engine := &core.Engine{}
	config := &core.AppConfig{}

	mods := []Module{
		&SoftwareUpdateModule{Engine: engine, Config: config.SoftwareUpdate},
		&DeveloperModule{Engine: engine, Config: config.Developer},
		&BrewModule{Engine: engine, Config: config.Brew},
		&SecurityModule{Engine: engine, Config: config.Security},
		&SystemModule{Engine: engine, Config: config.System},
		&InputModule{Engine: engine, Config: config.Input},
		&FinderModule{Engine: engine, Config: config.Finder},
		&DockModule{Engine: engine, Config: config.Dock},
		&CleanupModule{Engine: engine, Config: config.Cleanup},
	}

	for _, mod := range mods {
		if mod.Name() == "" {
			t.Errorf("Module %T has empty name", mod)
		}
	}
}
