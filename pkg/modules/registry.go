package modules

// Module defines the interface for setup modules
type Module interface {
	Name() string
	Run() error
	Dependencies() []string
}

// ExecutionOrder defines the sequence in which modules should be run
var ExecutionOrder = []string{
	"softwareupdate",
	"developer",
	"brew",
	"security",
	"system",
	"input",
	"finder",
	"dock",
	"cleanup",
}
