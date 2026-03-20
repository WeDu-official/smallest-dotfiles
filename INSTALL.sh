#!/usr/bin/env bash

# =============================================================================
# Hyprland & Waybar Complete Setup Script
# =============================================================================
# This script installs all required packages for:
#   - Hyprland (Window Manager)
#   - Waybar (Status Bar)
#   - Wofi (Application Launcher)
#   - All supporting utilities and dependencies
# =============================================================================

set -euo pipefail

# =============================================================================
# LOG Definitions and DRY RUN MODE and AUR_HELPER VAR
# =============================================================================

LOG_FILE="/tmp/hyprland_install.log"
DRY_RUN=false
AUR_HELPER=""

# =============================================================================
# Color Definitions
# =============================================================================

# Regular Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'

# Bold Colors
readonly BOLD_RED='\033[1;31m'
readonly BOLD_GREEN='\033[1;32m'
readonly BOLD_YELLOW='\033[1;33m'
readonly BOLD_BLUE='\033[1;34m'
readonly BOLD_MAGENTA='\033[1;35m'
readonly BOLD_CYAN='\033[1;36m'
readonly BOLD_WHITE='\033[1;37m'

# Background Colors
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_YELLOW='\033[43m'
readonly BG_BLUE='\033[44m'

# Text Styles
readonly DIM='\033[2m'
readonly ITALIC='\033[3m'
readonly UNDERLINE='\033[4m'
readonly BLINK='\033[5m'
readonly REVERSE='\033[7m'

# Reset
readonly RESET='\033[0m'

# =============================================================================
# Icons (for visual feedback)
# =============================================================================

readonly ICON_CHECK="${GREEN}✓${RESET}"
readonly ICON_CROSS="${RED}✗${RESET}"
readonly ICON_INFO="${BLUE}ℹ${RESET}"
readonly ICON_WARN="${YELLOW}⚠${RESET}"
readonly ICON_PACKAGE="${MAGENTA}📦${RESET}"
readonly ICON_DOWNLOAD="${CYAN}⬇${RESET}"
readonly ICON_INSTALL="${GREEN}🔧${RESET}"
readonly ICON_AUR="${YELLOW}󰣇${RESET}"
readonly ICON_DONE="${BOLD_GREEN}✅${RESET}"
readonly ICON_ERROR="${BOLD_RED}❌${RESET}"

# =============================================================================
# Package Lists
# =============================================================================

# Core packages (always required)
readonly CORE_PACKAGES=(
    "hyprland"
    "waybar"
    "wofi"
    "rofi"
)

# Terminal packages
readonly TERMINAL_PACKAGES=(
    "alacritty"
    "fish"
)

# Screen & Display packages
readonly DISPLAY_PACKAGES=(
    "hyprlock"
    "hyprshot"
    "grim"
    "slurp"
    "mpv"
    "swaybg"
)

# Input & Control packages
readonly INPUT_PACKAGES=(
    "touchegg"
    "ydotool"
    "pamixer"
    "brightnessctl"
)

# System & Utility packages
readonly SYSTEM_PACKAGES=(
    "copyq"
    "dunst"
    "wl-clipboard"
    "python-psutil"
    "zenity"
    "yad"
    "bc"
    "jq"
    "libnotify"
    "procps-ng"
    "upower"
)

# Network packages
readonly NETWORK_PACKAGES=(
    "networkmanager"
    "network-manager-applet"
    "libappindicator-gtk3"
)

# Audio packages
readonly AUDIO_PACKAGES=(
    "pipewire"
    "pipewire-pulse"
    "wireplumber"
)

# Font packages
readonly FONT_PACKAGES=(
    "ttf-firacode-nerd"
    "ttf-cascadia-code-nerd"
    "ttf-jetbrains-mono-nerd"
    "noto-fonts"
    "noto-fonts-emoji"
    "adwaita-fonts"
    "ttf-dejavu"
    "gnu-free-fonts"
)

# AUR packages
readonly AUR_PACKAGES=(
    "grimblast-git"
    "dotool"
    "wlogout"
    "mpvpaper"
)

# Combine all packages
ALL_PACKAGES=(
    "${CORE_PACKAGES[@]}"
    "${TERMINAL_PACKAGES[@]}"
    "${DISPLAY_PACKAGES[@]}"
    "${INPUT_PACKAGES[@]}"
    "${SYSTEM_PACKAGES[@]}"
    "${NETWORK_PACKAGES[@]}"
    "${AUDIO_PACKAGES[@]}"
    "${FONT_PACKAGES[@]}"
)

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "\n${BOLD_CYAN}════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_CYAN}  $1${RESET}"
    echo -e "${BOLD_CYAN}════════════════════════════════════════════════════════════════${RESET}\n"
}

print_section() {
    echo -e "\n${BOLD_MAGENTA}▶ ${1}${RESET}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

print_success() {
    echo -e "  ${ICON_CHECK} ${GREEN}$1${RESET}"
}

print_error() {
    echo -e "  ${ICON_CROSS} ${RED}$1${RESET}"
}

print_info() {
    echo -e "  ${ICON_INFO} ${BLUE}$1${RESET}"
}

print_warning() {
    echo -e "  ${ICON_WARN} ${YELLOW}$1${RESET}"
}

print_package() {
    echo -e "    ${ICON_PACKAGE} ${WHITE}$1${RESET}"
}

print_step() {
    echo -e "\n  ${BOLD_WHITE}→${RESET} ${WHITE}$1${RESET} ..."
}

print_progress() {
    echo -ne "  ${ICON_DOWNLOAD} ${DIM}$1${RESET} \r"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_info "Please run as a normal user with sudo privileges"
        exit 1
    fi
}

# Check for pacman
check_pacman() {
    if ! command_exists pacman; then
        print_error "pacman not found. This script is for Arch Linux based systems only."
        exit 1
    fi
}

# Check for AUR helper
check_aur_helper() {
    if command_exists yay; then
        AUR_HELPER="yay"
        print_success "AUR helper found: ${AUR_HELPER}"
    elif command_exists paru; then
        AUR_HELPER="paru"
        print_success "AUR helper found: ${AUR_HELPER}"
    else
        print_warning "No AUR helper found (yay or paru)"
        print_info "You'll need to install AUR packages manually:"
        for pkg in "${AUR_PACKAGES[@]}"; do
            print_package "$pkg"
        done
        echo ""
        read -p "  Do you want to install yay now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_yay
        else
            AUR_HELPER="none"
            print_warning "AUR packages will be skipped"
        fi
    fi
}

# Install yay$HOME/.config/hypr/tmp_wallpaper.mp
install_yay() {
    print_step "Installing yay (AUR helper)"

    # Install base-devel if not present
    if ! pacman -Q base-devel &> /dev/null; then
        print_info "Installing base-devel group..."
        sudo pacman -S --needed --noconfirm base-devel git >>"$LOG_FILE" 2>&1
    fi

    # Clone and install yay
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    if ! command_exists git; then
    print_info "Installing git..."
    sudo pacman -S --needed git
fi
    git clone https://aur.archlinux.org/yay.git >>"$LOG_FILE" 2>&1
    cd yay
    makepkg -si --noconfirm >>"$LOG_FILE" 2>&1
    cd /
    rm -rf "$temp_dir"

    if command_exists yay; then
        AUR_HELPER="yay"
        print_success "yay installed successfully"
    else
        print_error "Failed to install yay"
        AUR_HELPER="none"
    fi
}


#command runner
run_cmd() {
    if $DRY_RUN; then
        echo -e "  ${ICON_INFO} ${YELLOW}[DRY RUN]${RESET} $*"
    else
        eval "$*" >>"$LOG_FILE" 2>&1
    fi
}


# Update system
update_system() {
    print_step "Requesting sudo access"
    sudo -v  # caches password so you don’t get surprises

    print_step "Updating system packages"

    if $DRY_RUN; then
        print_info "[DRY RUN] pacman -Syu"
        return
    fi

    print_info "You may be prompted for your password..."

    # Show live output while logging
    sudo pacman -Syu --noconfirm 2>&1 | tee "$LOG_FILE"

    print_success "System updated"
}
# ===============================
# Install all pacman packages
# ===============================
install_pacman_packages() {
    print_step "Installing all pacman packages (batch mode)"

    if $DRY_RUN; then
        print_info "[DRY RUN] pacman -S --needed --noconfirm ${ALL_PACKAGES[*]}"
        return
    fi

    # Run pacman install
    if sudo pacman -S --needed --noconfirm "${ALL_PACKAGES[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        print_info "Pacman command finished, verifying packages..."
    else
        print_error "Pacman command failed. Check $LOG_FILE"
        exit 1
    fi

    # Verify each package
    local failed=0
    for pkg in "${ALL_PACKAGES[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
    print_warning "Package $pkg not installed or unavailable"
    failed=1
fi
    done

    if [ $failed -eq 0 ]; then
        print_success "All pacman packages installed or already up-to-date"
    else
        print_error "Some pacman packages failed to install. Check $LOG_FILE"
        exit 1
    fi
}

# ===============================
# Install all AUR packages
# ===============================
install_aur_packages() {
    print_step "Installing AUR packages"

    if [ "$AUR_HELPER" == "none" ]; then
        print_warning "No AUR helper installed, skipping AUR packages"
        return
    fi

    if $DRY_RUN; then
        print_info "[DRY RUN] $AUR_HELPER -S --needed --noconfirm ${AUR_PACKAGES[*]}"
        return
    fi

    # Run AUR helper install
    if $AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}" >>"$LOG_FILE" 2>&1; then
        print_info "AUR helper finished, verifying packages..."
    else
        print_warning "Some AUR packages may have failed. Check $LOG_FILE"
    fi

    # Verify each package
    local failed=0
    for pkg in "${AUR_PACKAGES[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null && ! $AUR_HELPER -Q "$pkg" &>/dev/null; then
    print_warning "Package $pkg not installed or unavailable"
    failed=1
fi
    done

    if [ $failed -eq 0 ]; then
        print_success "All AUR packages installed or already up-to-date"
    else
        print_warning "Some AUR packages failed or are missing. Check $LOG_FILE"
    fi
}

# Enable services
enable_services() {
    print_section "Enabling Services"

    if $DRY_RUN; then
        print_info "[DRY RUN] systemctl enable NetworkManager"
        return
    fi

    if systemctl is-enabled NetworkManager &>/dev/null; then
        print_success "NetworkManager already enabled"
    else
        sudo systemctl enable --now NetworkManager >>"$LOG_FILE" 2>&1 \
            && print_success "NetworkManager enabled" \
            || print_warning "Failed to enable NetworkManager"
    fi
}

# Create initial config files
create_config_files() {
    print_section "Creating Initial Configuration Files"

    local config_dir="$HOME/.config/hypr"

    # Create config directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        print_success "Created $config_dir"
    fi

    # Create opacity tracking files
    if [[ ! -f "$config_dir/antoc.txt" ]]; then
        echo "1.00" > "$config_dir/antoc.txt"
        print_success "Created $config_dir/antoc.txt (active opacity: 1.00)"
    else
        print_info "$config_dir/antoc.txt already exists"
    fi

    if [[ ! -f "$config_dir/iantoc.txt" ]]; then
        echo "1.00" > "$config_dir/iantoc.txt"
        print_success "Created $config_dir/iantoc.txt (inactive opacity: 1.00)"
    else
        print_info "$config_dir/iantoc.txt already exists"
    fi

    # Create current wallpaper file
    if [[ ! -f "$config_dir/current_wallpaper.txt" ]]; then
        touch "$config_dir/current_wallpaper.txt"
        print_success "Created $config_dir/current_wallpaper.txt"
    else
        print_info "$config_dir/current_wallpaper.txt already exists"
    fi

    # Create scripts directory
    if [[ ! -d "$config_dir/scripts" ]]; then
        mkdir -p "$config_dir/scripts"
        print_success "Created $config_dir/scripts"
    fi
}

# Print summary
print_summary() {
    print_header "INSTALLATION COMPLETE"

    echo -e "${BOLD_GREEN}  All packages have been installed successfully!${RESET}\n"

    echo -e "${BOLD_WHITE}  Installed Packages(${GREEN}●${RESET} are pacman packages ,${YELLOW}●${RESET} are AUR packages):${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${GREEN}●${RESET} Core:          ${WHITE}${#CORE_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Terminal:      ${WHITE}${#TERMINAL_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Display:       ${WHITE}${#DISPLAY_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Input:         ${WHITE}${#INPUT_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} System:        ${WHITE}${#SYSTEM_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Network:       ${WHITE}${#NETWORK_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Audio:         ${WHITE}${#AUDIO_PACKAGES[@]} packages${RESET}"
    echo -e "    ${GREEN}●${RESET} Fonts:         ${WHITE}${#FONT_PACKAGES[@]} packages${RESET}"

    if [[ "$AUR_HELPER" != "none" ]]; then
        echo -e "    ${YELLOW}●${RESET} AUR:           ${WHITE}${#AUR_PACKAGES[@]} packages${RESET}"
    fi

    echo -e "\n${BOLD_WHITE}  Next Steps:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${ICON_INFO} ${BLUE}1. Copy your configuration files to:${RESET}"
    echo -e "       ${DIM}~/.config/hypr/ (all but waybar folder)${RESET}"
    echo -e "       ${DIM}~/.config/waybar/ (only waybar folder)${RESET}"
    echo -e ""
    echo -e "    ${ICON_INFO} ${BLUE}2. Make all scripts executable:${RESET}"
    echo -e "       ${DIM}chmod +x ~/.config/hypr/*.sh${RESET}"
    echo -e "       ${DIM}chmod +x ~/.config/hypr/scripts/*.sh${RESET}"
    echo -e ""
    echo -e "    ${ICON_INFO} ${BLUE}3. Reboot or restart your session${RESET}"
    echo -e ""
    echo -e "    ${ICON_INFO} ${BLUE}4. Start Hyprland:${RESET}"
    echo -e "       ${DIM}Hyprland${RESET}"

    echo -e "\n${BOLD_CYAN}════════════════════════════════════════════════════════════════${RESET}\n"
    echo -e "    ${ICON_INFO} Logs saved to: ${DIM}${LOG_FILE}${RESET}"
}


# =============================================================================
# Argument parsing
# =============================================================================


parse_args() {
    for arg in "$@"; do
        case $arg in
            --dry-run)
                DRY_RUN=true
                ;;
        esac
    done
}



# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    clear
    parse_args "$@"
    # Banner
    echo -e "${BOLD_CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                                                                                                        ║"
    echo "║   ███▄ ▄███▓▓██   ██▓     ██████  ███▄ ▄███▓ ▄▄▄       ██▓     ██▓    ▓█████   ██████ ▄▄▄█████▓   ▓█████▄  ▒█████  ▄▄▄█████▓  █████▒██▓ ██▓    ▓█████   ██████         ║"
    echo "║   ▓██▒▀█▀ ██▒ ▒██  ██▒   ▒██    ▒ ▓██▒▀█▀ ██▒▒████▄    ▓██▒    ▓██▒    ▓█   ▀ ▒██    ▒ ▓  ██▒ ▓▒   ▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▓██   ▒▓██▒▓██▒    ▓█   ▀ ▒██    ▒        ║"
    echo "║   ▓██    ▓██░  ▒██ ██░   ░ ▓██▄   ▓██    ▓██░▒██  ▀█▄  ▒██░    ▒██░    ▒███   ░ ▓██▄   ▒ ▓██░ ▒░   ░██   █▌▒██░  ██▒▒ ▓██░ ▒░▒████ ░▒██▒▒██░    ▒███   ░ ▓██▄          ║"
    echo "║   ▒██    ▒██   ░ ▐██▓░     ▒   ██▒▒██    ▒██ ░██▄▄▄▄██ ▒██░    ▒██░    ▒▓█  ▄   ▒   ██▒░ ▓██▓ ░    ░▓█▄   ▌▒██   ██░░ ▓██▓ ░ ░▓█▒  ░░██░▒██░    ▒▓█  ▄   ▒   ██▒       ║"
    echo "║   ▒██▒   ░██▒  ░ ██▒▓░   ▒██████▒▒▒██▒   ░██▒ ▓█   ▓██▒░██████▒░██████▒░▒████▒▒██████▒▒  ▒██▒ ░    ░▒████▓ ░ ████▓▒░  ▒██▒ ░ ░▒█░   ░██░░██████▒░▒████▒▒██████▒▒       ║"
    echo "║   ░ ▒░   ░  ░   ██▒▒▒    ▒ ▒▓▒ ▒ ░░ ▒░   ░  ░ ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░  ▒ ░░       ▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░    ▒ ░   ░▓  ░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░       ║"
    echo "║   ░  ░      ░ ▓██ ░▒░    ░ ░▒  ░ ░░  ░      ░  ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░    ░          ░ ▒  ▒   ░ ▒ ▒░     ░       ░      ▒ ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░   ║"
    echo "║   ░      ░     ▒ ▒ ░░     ░  ░  ░  ░      ░     ░   ▒     ░ ░     ░ ░      ░   ░  ░  ░    ░            ░ ░  ░ ░ ░ ░ ▒    ░       ░ ░    ▒ ░  ░ ░      ░   ░  ░  ░      ║"
    echo "║          ░     ░ ░              ░         ░         ░  ░    ░  ░    ░  ░   ░  ░      ░                   ░        ░ ░                   ░      ░  ░   ░  ░      ░      ║"
    echo "║                ░ ░                                                                                   ░                                                                 ║"
    echo "║                                                                                                                                                                        ║"
    echo "║                                                                  Requirements install  v1.0                                                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "${DIM}This script will install all packages needed for:${RESET}"
    echo -e "  ${WHITE}• Hyprland (Wayland Window Manager)${RESET}"
    echo -e "  ${WHITE}• Waybar (Status Bar)${RESET}"
    echo -e "  ${WHITE}• Wofi & Rofi (Application Launchers)${RESET}"
    echo -e "  ${WHITE}• All supporting utilities and dependencies${RESET}"
    echo ""
    echo -e "${YELLOW}Total packages to install: ${#ALL_PACKAGES[@]} (pacman) + ${#AUR_PACKAGES[@]} (AUR)${RESET}"
    echo ""

    read -p "  Do you want to continue? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Installation cancelled.${RESET}"
        exit 0
    fi

    echo ""

    # Pre-flight checks
    print_header "Pre-Flight Checks"
    check_not_root
    check_pacman
    print_success "System checks passed"

    # Update system
    print_section "System Update"
    update_system

    # Install packages
    print_section "Installing Packages (pacman)"
    install_pacman_packages "${ALL_PACKAGES[@]}"

    # Check and install AUR packages
    print_section "AUR Packages"
    check_aur_helper

    if [[ "$AUR_HELPER" != "none" ]]; then
        install_aur_packages "${AUR_PACKAGES[@]}"
    else
        print_warning "Skipping AUR packages installation"
        print_info "Please install these manually: ${AUR_PACKAGES[*]}"
    fi

    # Enable services
    print_section "Service Configuration"
    enable_services

    # Create config files
    print_section "Configuration Files"
    create_config_files

    # Final summary
    print_summary
}

# Run main function
main "$@"
