package core

import (
	"testing"
)

func TestExpandPath(t *testing.T) {
	home := "/Users/testuser"
	tests := []struct {
		input    string
		expected string
	}{
		{"~/Desktop", "/Users/testuser/Desktop"},
		{"~", "/Users/testuser"},
		{"/var/tmp", "/var/tmp"},
		{"Desktop", "Desktop"},
	}

	for _, tt := range tests {
		result := ExpandPath(tt.input, home)
		if result != tt.expected {
			t.Errorf("ExpandPath(%q, %q) = %q; want %q", tt.input, home, result, tt.expected)
		}
	}
}
