package core

import (
	"os"
	"os/exec"
	"os/user"
	"strings"
)

// UserContext holds the identity and paths
type UserContext struct {
	UserName string
	HomeDir  string
	IsRoot   bool
}

// GetUserContext detects the current user environment
func GetUserContext() (*UserContext, error) {
	isRoot := os.Geteuid() == 0
	
	// If we are root, we want the name of the person who called sudo
	if isRoot {
		sudoUser := os.Getenv("SUDO_USER")
		if sudoUser != "" {
			u, err := user.Lookup(sudoUser)
			if err != nil {
				return nil, err
			}
			return &UserContext{UserName: sudoUser, HomeDir: u.HomeDir, IsRoot: true}, nil
		}
	}

	// Normal user execution
	u, err := user.Current()
	if err != nil {
		return nil, err
	}
	return &UserContext{
		UserName: u.Username,
		HomeDir:  u.HomeDir,
		IsRoot:   isRoot,
	}, nil
}

// RunAsUser ensures a command runs as the non-privileged user
func (ctx *UserContext) RunAsUser(name string, arg ...string) *exec.Cmd {
	if ctx.IsRoot && ctx.UserName != "" {
		args := append([]string{"-u", ctx.UserName, name}, arg...)
		return exec.Command("sudo", args...)
	}
	return exec.Command(name, arg...)
}

// RunAsRoot ensures a command runs with sudo privileges
func (ctx *UserContext) RunAsRoot(name string, arg ...string) *exec.Cmd {
	if ctx.IsRoot {
		return exec.Command(name, arg...)
	}
	// Prepend sudo to trigger password prompt if not already authenticated
	args := append([]string{name}, arg...)
	return exec.Command("sudo", args...)
}

// DefaultsRead gets a value from the defaults system
func (ctx *UserContext) DefaultsRead(domain, key string) (string, error) {
	// Most reads don't need sudo, but system domains might
	var cmd *exec.Cmd
	if strings.HasPrefix(domain, "/Library") || strings.HasPrefix(domain, "/System") {
		cmd = ctx.RunAsRoot("defaults", "read", domain, key)
	} else {
		cmd = ctx.RunAsUser("defaults", "read", domain, key)
	}
	
	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}
