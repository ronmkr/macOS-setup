package modules

// Module defines the interface for setup modules
type Module interface {
	Name() string
	Run() error
	Dependencies() []string
}

// Order defines the preferred execution sequence
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
