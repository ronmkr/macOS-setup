package core

import (
	"os"
	"os/exec"
	"os/user"
	"strings"
)

type UserContext struct {
	UserName string
	HomeDir  string
	IsRoot   bool
}

func GetUserContext() (*UserContext, error) {
	isRoot := os.Geteuid() == 0
	
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

func (ctx *UserContext) RunAsUser(name string, arg ...string) *exec.Cmd {
	if ctx.IsRoot && ctx.UserName != "" {
		args := append([]string{"-u", ctx.UserName, name}, arg...)
		return exec.Command("sudo", args...)
	}
	return exec.Command(name, arg...)
}

func (ctx *UserContext) RunAsRoot(name string, arg ...string) *exec.Cmd {
	if ctx.IsRoot {
		return exec.Command(name, arg...)
	}
	args := append([]string{name}, arg...)
	return exec.Command("sudo", args...)
}

func (ctx *UserContext) DefaultsRead(domain, key string) (string, error) {
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
