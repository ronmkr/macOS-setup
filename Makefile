.PHONY: build test clean run help

# Binary name
BINARY=macos-setup

# Default configuration path
CONFIG=config/settings.json

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build   - Build the Go binary and Swift helpers"
	@echo "  run     - Run the tool with default settings"
	@echo "  test    - Run the unit tests"
	@echo "  dry     - Run a dry-run with verbose output"
	@echo "  clean   - Remove binary and build artifacts"

build:
	@echo "Building macOS Setup Framework..."
	@go build -o $(BINARY) main.go
	@if [ -d "swift" ]; then \
		echo "Building Swift helpers..."; \
		swiftc swift/*.swift -o bin/swift-helper 2>/dev/null || true; \
	fi

run: build
	@./$(BINARY)

dry: build
	@./$(BINARY) -d -v

test:
	@go test ./... -v

clean:
	@rm -f $(BINARY)
	@rm -rf bin/
	@go clean
