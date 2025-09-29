#!/usr/bin/env bash

# Enhanced application detection and cleanup functions
get_app_bundle_ids() {
	# Get all installed application bundle IDs
	find /Applications ~/Applications /System/Applications -name "*.app" -maxdepth 3 2>/dev/null | while read -r app; do
		mdls -name kMDItemCFBundleIdentifier -raw "$app" 2>/dev/null
	done
}

get_app_cache_paths() {
	local bundle_id="$1"
	local cache_paths=(
		"~/Library/Caches/${bundle_id}"
		"~/Library/Containers/${bundle_id}/Data/Library/Caches"
		"~/Library/Application Support/${bundle_id}/Caches"
		"~/Library/Application Support/${bundle_id}/Cache"
		"~/Library/Application Support/${bundle_id}/CachedData"
	)
	printf "%s\n" "${cache_paths[@]/#\~/$HOME}"
}

# Define cleanup commands for known tools
declare -A TOOL_CLEANUP_COMMANDS=(
	["brew"]="cleanup --prune=all; brew autoremove"
	["docker"]="system prune -af"
	["npm"]="cache clean --force"
	["yarn"]="cache clean"
	["pnpm"]="store prune"
	["composer"]="clear-cache"
	["pip3"]="cache purge"
	["pip"]="cache purge"
	["gem"]="cleanup"
	["pod"]="cache clean --all"
	["conda"]="clean --all --yes"
	["gradle"]="clean --build-cache"
	["mvn"]="clean"
	["sbt"]="clean"
	["cargo"]="clean"
	["go"]="clean -cache -modcache -testcache"
	["rustup"]="self clean-cache"
)

# Define paths to check for tool-specific caches
declare -A TOOL_CACHE_PATHS=(
	["vscode"]="~/Library/Application Support/Code/Cache"
	["jetbrains"]="~/Library/Caches/JetBrains"
	["android-studio"]="~/Library/Caches/AndroidStudio"
	["gradle"]="~/.gradle/caches"
	["maven"]="~/.m2/repository"
	["npm"]="~/.npm"
	["yarn"]="~/Library/Caches/Yarn"
	["pip"]="~/Library/Caches/pip"
)

cleanup_detected_tools() {
	local tool_found=false
	print_status "Scanning for installed development tools..."

	# Check common tool paths
	for tool in "${!TOOL_CACHE_PATHS[@]}"; do
		local cache_path="${TOOL_CACHE_PATHS[$tool]/#\~/$HOME}"
		if [[ -d "$cache_path" ]]; then
			tool_found=true
			print_status "Found $tool cache at $cache_path"
			rm -rf "${cache_path}"/* 2>/dev/null || true
			log_info "Cleaned $tool cache"
		fi
	done

	# Check commands and run their cleanup
	for tool in "${!TOOL_CLEANUP_COMMANDS[@]}"; do
		if command_exists "$tool"; then
			tool_found=true
			print_status "Found $tool, running cleanup..."
			eval "$tool ${TOOL_CLEANUP_COMMANDS[$tool]}" &>/dev/null || true
			log_info "Cleaned $tool cache and temporary files"
		fi
	done

	# Special case for Node.js tools
	if command_exists node; then
		tool_found=true
		print_status "Found Node.js environment..."
		# Clean npm cache if npm exists
		if command_exists npm; then
			npm cache clean --force &>/dev/null || true
			log_info "Cleaned npm cache"
		fi
		# Clean yarn cache if yarn exists
		if command_exists yarn; then
			yarn cache clean &>/dev/null || true
			log_info "Cleaned yarn cache"
		fi
		# Clean pnpm cache if pnpm exists
		if command_exists pnpm; then
			pnpm store prune &>/dev/null || true
			log_info "Cleaned pnpm cache"
		fi
	fi

	if [ "$tool_found" = false ]; then
		log_info "No additional development tools detected"
	fi
}

cleanup_detected_applications() {
	print_status "Scanning for installed applications..."

	# Check standard application directories
	local app_directories=(
		"/Applications"
		"$HOME/Applications"
		"/System/Applications"
	)

	# Scan Library containers for app-specific data
	for container in ~/Library/Containers/*; do
		if [[ -d "$container" ]]; then
			local app_id=$(basename "$container")
			print_status "Found application container: $app_id"

			# Clean app-specific caches
			rm -rf "$container/Data/Library/Caches"/* 2>/dev/null || true
			rm -rf "$container/Data/Library/Application Support/Caches"/* 2>/dev/null || true
			log_info "Cleaned caches for $app_id"
		fi
	done

	# Scan Application Support directory
	for app_support in ~/Library/Application\ Support/*; do
		if [[ -d "$app_support" ]]; then
			local app_name=$(basename "$app_support")
			if [[ -d "$app_support/Caches" ]]; then
				print_status "Found application support cache: $app_name"
				rm -rf "$app_support/Caches"/* 2>/dev/null || true
				log_info "Cleaned Application Support cache for $app_name"
			fi
		fi
	done

	# Scan for app-specific caches
	for cache_dir in ~/Library/Caches/*; do
		if [[ -d "$cache_dir" ]]; then
			local cache_name=$(basename "$cache_dir")
			print_status "Found cache directory: $cache_name"
			rm -rf "$cache_dir"/* 2>/dev/null || true
			log_info "Cleaned cache for $cache_name"
		fi
	done

	# Scan for application preferences backup
	for pref in ~/Library/Preferences/*.plist; do
		if [[ -f "$pref" ]]; then
			local backup_pref="${pref}.bak"
			if [[ -f "$backup_pref" ]]; then
				rm -f "$backup_pref" 2>/dev/null || true
				log_info "Removed backup preferences for $(basename "$pref")"
			fi
		fi
	done
}

setup_cleanup() {
	print_status "Starting system cleanup..."
	log_info "Beginning comprehensive system cleanup"

	# Run automatic application detection and cleanup
	cleanup_detected_applications

	# Run automatic tool detection and cleanup
	cleanup_detected_tools

	# Continue with standard tools
	if command_exists brew; then
		print_status "Cleaning Homebrew files..."
		brew cleanup --prune=all &>/dev/null || true
		brew autoremove &>/dev/null || true
		log_info "Cleaned Homebrew cache and old versions"
	fi

	if command_exists docker; then
		print_status "Cleaning Docker data..."
		docker system prune -af &>/dev/null || true
		log_info "Cleaned Docker system"
	fi

	if command_exists npm; then
		print_status "Cleaning npm cache..."
		npm cache clean --force &>/dev/null || true
		log_info "Cleaned npm cache"
	fi

	if command_exists yarn; then
		print_status "Cleaning Yarn cache..."
		yarn cache clean &>/dev/null || true
		log_info "Cleaned Yarn cache"
	fi

	if command_exists composer; then
		print_status "Cleaning Composer cache..."
		composer clear-cache &>/dev/null || true
		log_info "Cleaned Composer cache"
	fi

	if command_exists pip3; then
		print_status "Cleaning pip cache..."
		pip3 cache purge &>/dev/null || true
		log_info "Cleaned pip cache"
	fi

	if command_exists gem; then
		print_status "Cleaning Ruby gems..."
		gem cleanup &>/dev/null || true
		log_info "Cleaned Ruby gems"
	fi

	if command_exists pod; then
		print_status "Cleaning CocoaPods cache..."
		pod cache clean --all &>/dev/null || true
		log_info "Cleaned CocoaPods cache"
	fi

	if command_exists conda; then
		print_status "Cleaning Conda cache..."
		conda clean --all --yes &>/dev/null || true
		log_info "Cleaned Conda cache"
	fi

	# Git cleanup
	if command_exists git; then
		print_status "Cleaning Git repositories..."
		find ~ -type d -name ".git" -exec sh -c 'cd "{}" && git gc --prune=now' \; 2>/dev/null || true
		log_info "Cleaned Git repositories"
	fi

	# User cache cleanup
	print_status "Cleaning user caches..."
	rm -rf ~/Library/Caches/* 2>/dev/null || true
	rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cache/* 2>/dev/null || true
	rm -rf ~/Library/Application\ Support/Firefox/Profiles/*/cache2/* 2>/dev/null || true
	rm -rf ~/Library/Containers/com.apple.Safari/Data/Library/Caches/* 2>/dev/null || true

	# Temporary files cleanup
	print_status "Cleaning temporary files..."
	rm -rf /private/var/folders/*/*/*/* 2>/dev/null || true
	rm -rf /private/tmp/* 2>/dev/null || true
	rm -rf ~/Library/Logs/* 2>/dev/null || true

	# Downloads cleanup (files older than 30 days)
	print_status "Cleaning old downloads..."
	find ~/Downloads -type f -mtime +30 -delete 2>/dev/null || true

	# Browser data cleanup
	print_status "Cleaning browser data..."
	# Chrome
	if [[ -d ~/Library/Application\ Support/Google/Chrome ]]; then
		rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Google/Chrome/Default/IndexedDB/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Local\ Storage/* 2>/dev/null || true
	fi
	# Firefox
	if [[ -d ~/Library/Application\ Support/Firefox ]]; then
		rm -rf ~/Library/Application\ Support/Firefox/Profiles/*/cache2/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Firefox/Profiles/*/thumbnails/* 2>/dev/null || true
	fi
	# Safari
	if [[ -d ~/Library/Safari ]]; then
		rm -rf ~/Library/Safari/LocalStorage/* 2>/dev/null || true
		rm -rf ~/Library/Safari/Databases/* 2>/dev/null || true
		rm -rf ~/Library/Safari/ServiceWorker/* 2>/dev/null || true
	fi

	# Application specific cleanup
	print_status "Cleaning application caches..."
	rm -rf ~/Library/Application\ Support/*/Caches/* 2>/dev/null || true
	rm -rf ~/Library/Application\ Support/*/Cache/* 2>/dev/null || true
	rm -rf ~/Library/Application\ Support/*/Service\ Worker/* 2>/dev/null || true

	# VSCode cleanup
	if [[ -d ~/Library/Application\ Support/Code ]]; then
		print_status "Cleaning VSCode caches..."
		rm -rf ~/Library/Application\ Support/Code/Cache/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Code/CachedData/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Code/CachedExtensions/* 2>/dev/null || true
		rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs/* 2>/dev/null || true
		log_info "Cleaned VSCode caches"
	fi

	# JetBrains IDEs cleanup
	print_status "Cleaning JetBrains IDE caches..."
	rm -rf ~/Library/Caches/JetBrains/* 2>/dev/null || true
	find ~/Library/Application\ Support/JetBrains -name "caches" -type d -exec rm -rf {} + 2>/dev/null || true
	log_info "Cleaned JetBrains caches"

	# Adobe Creative Cloud cleanup
	if [[ -d ~/Library/Application\ Support/Adobe ]]; then
		print_status "Cleaning Adobe caches..."
		rm -rf ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files/* 2>/dev/null || true
		log_info "Cleaned Adobe caches"
	fi

	# Spotify cache
	if [[ -d ~/Library/Caches/com.spotify.client ]]; then
		print_status "Cleaning Spotify cache..."
		rm -rf ~/Library/Caches/com.spotify.client/* 2>/dev/null || true
		log_info "Cleaned Spotify cache"
	fi

	# Microsoft Office cache
	if [[ -d ~/Library/Containers/com.microsoft.* ]]; then
		print_status "Cleaning Microsoft Office caches..."
		rm -rf ~/Library/Containers/com.microsoft.*/Data/Library/Caches/* 2>/dev/null || true
		log_info "Cleaned Microsoft Office caches"
	fi

	# Unity cache
	if [[ -d ~/Library/Unity ]]; then
		print_status "Cleaning Unity caches..."
		rm -rf ~/Library/Unity/Cache/* 2>/dev/null || true
		log_info "Cleaned Unity cache"
	fi

	# System cleanup (requires sudo)
	if is_sudo; then
		print_status "Cleaning system caches and logs..."
		# System caches
		sudo rm -rf /Library/Caches/* 2>/dev/null || true
		sudo rm -rf /System/Library/Caches/* 2>/dev/null || true

		# System logs
		sudo rm -rf /private/var/log/*.log 2>/dev/null || true
		sudo rm -rf /private/var/log/asl/*.asl 2>/dev/null || true
		sudo rm -rf /Library/Logs/* 2>/dev/null || true

		# XCode derived data and archives
		if [[ -d ~/Library/Developer/Xcode ]]; then
			rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
			rm -rf ~/Library/Developer/Xcode/Archives/* 2>/dev/null || true
		fi

		# Spotlight index
		sudo mdutil -E / 2>/dev/null || true

		# Clear system font cache
		sudo atsutil databases -remove 2>/dev/null || true

		# Clear DNS cache
		sudo dscacheutil -flushcache
		sudo killall -HUP mDNSResponder
	fi

	# Application Support cleanup (old files)
	print_status "Cleaning old application support files..."
	find ~/Library/Application\ Support -type f -mtime +90 -name "*.log" -delete 2>/dev/null || true
	find ~/Library/Application\ Support -type f -mtime +90 -name "*.old" -delete 2>/dev/null || true

	# Clean automatic app cache detection
	print_status "Scanning and cleaning application caches..."
	local cleaned_count=0
	local total_size=0

	while read -r bundle_id; do
		[[ -z "$bundle_id" ]] && continue

		for cache_path in $(get_app_cache_paths "$bundle_id"); do
			if [[ -d "$cache_path" ]]; then
				local size_before
				size_before=$(du -sk "$cache_path" 2>/dev/null | cut -f1)

				# Clean the cache
				rm -rf "${cache_path:?}"/* 2>/dev/null || true

				local size_after
				size_after=$(du -sk "$cache_path" 2>/dev/null | cut -f1)
				local freed_space=$((size_before - size_after))

				if ((freed_space > 0)); then
					((cleaned_count++))
					((total_size += freed_space))
					log_info "Cleaned ${bundle_id} cache (${freed_space}KB freed)"
				fi
			fi
		done
	done < <(get_app_bundle_ids)

	if ((cleaned_count > 0)); then
		print_success "Cleaned ${cleaned_count} application caches (${total_size}KB total)"
	fi

	# Clean app-specific development caches
	print_status "Cleaning development tool caches..."

	# Android Studio and mobile development
	if [[ -d ~/Library/Android ]]; then
		rm -rf ~/Library/Android/sdk/build-cache/* 2>/dev/null || true
		rm -rf ~/.gradle/caches/* 2>/dev/null || true
		rm -rf ~/.android/cache/* 2>/dev/null || true
		log_info "Cleaned Android development caches"
	fi

	# Flutter development
	if [[ -d ~/Library/Developer/Flutter ]]; then
		rm -rf ~/Library/Developer/Flutter/bin/cache/* 2>/dev/null || true
		flutter clean &>/dev/null || true
		log_info "Cleaned Flutter development caches"
	fi

	# Unity development
	if [[ -d ~/Library/Unity ]]; then
		rm -rf ~/Library/Unity/cache/* 2>/dev/null || true
		rm -rf ~/Library/Unity/Packages/Cache/* 2>/dev/null || true
		log_info "Cleaned Unity development caches"
	fi

	# Mail attachments cleanup
	print_status "Cleaning mail attachments..."
	rm -rf ~/Library/Containers/com.apple.mail/Data/Library/Mail\ Downloads/* 2>/dev/null || true

	# Quick Look cache
	print_status "Cleaning Quick Look cache..."
	rm -rf ~/Library/QuickLook/Thumbnails/* 2>/dev/null || true
	qlmanage -r cache

	# iTunes device backups (older than 30 days)
	print_status "Cleaning old device backups..."
	find ~/Library/Application\ Support/MobileSync/Backup -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true

	# Language files cleanup
	print_status "Removing unused language files..."
	find ~/Library/Application\ Support -name "*.lproj" -type d ! -name "en.lproj" ! -name "Base.lproj" -exec rm -rf {} \; 2>/dev/null || true
	log_info "Cleaned language files"

	# Python cache cleanup
	print_status "Cleaning Python cache..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	log_info "Cleaned Python cache files"

	# Clean .DS_Store files
	print_status "Removing .DS_Store files..."
	find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	log_info "Cleaned .DS_Store files"

	# Empty trash
	print_status "Emptying trash..."
	rm -rf ~/.Trash/* 2>/dev/null || true
	log_info "Emptied user trash"

	# Time Machine local snapshots
	if is_sudo; then
		print_status "Cleaning Time Machine snapshots..."
		tmutil listlocalsnapshots / 2>/dev/null | cut -d. -f4 | while read -r snapshot; do
			tmutil deletelocalsnapshots "$snapshot" &>/dev/null || true
		done
		log_info "Cleaned Time Machine snapshots"
	fi

	# Empty recent items
	print_status "Cleaning recent items..."
	rm -rf ~/Library/Application\ Support/com.apple.sharedfilelist/* 2>/dev/null || true
	log_info "Cleaned recent items"

	print_success "System cleanup completed"
	log_info "Comprehensive system cleanup finished"
}

setup_cleanup_cleanup() {
	print_status "Performing post-cleanup operations..."
	log_info "Starting post-cleanup tasks"

	# Verify disk space reclaimed
	if command_exists df; then
		local disk_space
		disk_space=$(df -h / | awk 'NR==2 {print $4}')
		log_info "Available disk space after cleanup: $disk_space"
	fi

	# Reset system caches that need to be present
	if is_sudo; then
		# Rebuild launch services database
		/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user &>/dev/null || true
		log_info "Reset LaunchServices"

		# Update locate database if it exists
		if command_exists locate; then
			sudo /usr/libexec/locate.updatedb &>/dev/null || true
			log_info "Updated locate database"
		fi
	fi

	print_success "Post-cleanup operations completed"
	log_info "All cleanup tasks finished successfully"
}