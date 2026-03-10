package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/ronmkr/macos-setup/pkg/core"
	"github.com/ronmkr/macos-setup/pkg/modules"
)

func main() {
	dryRun := flag.Bool("d", false, "Preview changes without applying them")
	verbose := flag.Bool("v", false, "Show detailed output")
	configPath := flag.String("c", "", "Path to configuration file")
	restore := flag.Bool("restore", false, "Restore Mac to factory defaults using config/settings_default.toml")
	flag.Parse()

	var appConfig *core.AppConfig
	var err error

	if *restore {
		fmt.Println("!!! RESTORE MODE ENABLED !!!")
		defaultPath := "config/settings_default.toml"
		appConfig, err = core.LoadConfig(defaultPath)
		if err != nil {
			fmt.Printf("Error: Could not load restore defaults from %s: %v\n", defaultPath, err)
			os.Exit(1)
		}
		fmt.Printf("Restoring settings from: %s\n", defaultPath)
	} else if *configPath != "" {
		appConfig, err = core.LoadConfig(*configPath)
		if err != nil {
			fmt.Printf("Error loading config: %v\n", err)
			os.Exit(1)
		}
	} else {
		path := "config/settings.toml"
		if _, err := os.Stat(path); err == nil {
			appConfig, _ = core.LoadConfig(path)
		} else {
			appConfig = core.GetDefaultConfig()
		}
	}

	ctx, err := core.GetUserContext()
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	engine := &core.Engine{
		Ctx:     ctx,
		DryRun:  *dryRun,
		Verbose: *verbose,
	}

	activeModules := []modules.Module{
		&modules.SoftwareUpdateModule{Engine: engine, Config: appConfig.SoftwareUpdate},
		&modules.DeveloperModule{Engine: engine, Config: appConfig.Developer},
		&modules.BrewModule{Engine: engine, Config: appConfig.Brew},
		&modules.SecurityModule{Engine: engine, Config: appConfig.Security},
		&modules.SystemModule{Engine: engine, Config: appConfig.System},
		&modules.InputModule{Engine: engine, Config: appConfig.Input},
		&modules.FinderModule{Engine: engine, Config: appConfig.Finder},
		&modules.DockModule{Engine: engine, Config: appConfig.Dock},
		&modules.CleanupModule{Engine: engine, Config: appConfig.Cleanup},
	}

	fmt.Printf("Starting macOS Setup Framework\n")
	fmt.Printf("User: %s | Mode: %s\n", ctx.UserName, map[bool]string{true: "Dry Run", false: "Apply"}[*dryRun])
	fmt.Println("========================================")

	for _, modName := range modules.ExecutionOrder {
		for _, mod := range activeModules {
			if mod.Name() == modName {
				if err := mod.Run(); err != nil {
					fmt.Printf("Error [%s]: %v\n", mod.Name(), err)
				}
			}
		}
	}

	engine.Notify("macOS Setup", "Operation Complete!")
}
