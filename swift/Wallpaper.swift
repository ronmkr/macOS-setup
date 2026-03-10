import AppKit
import Foundation

// A native macOS helper to change the wallpaper
func setWallpaper(path: String) {
    let workspace = NSWorkspace.shared
    let screens = NSScreen.screens
    let imageURL = URL(fileURLWithPath: path)
    
    for screen in screens {
        do {
            try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
            print("Successfully set wallpaper for screen \(screen.description)")
        } catch {
            print("Error setting wallpaper: \(error.localizedDescription)")
        }
    }
}

let arguments = CommandLine.arguments
if arguments.count < 2 {
    print("Usage: wallpaper-helper <path-to-image>")
    exit(1)
}

setWallpaper(path: arguments[1])
