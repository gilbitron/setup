# Ask for the administrator password upfront.
sudo -v

# Keep Sudo until script is finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Update macOS
echo "Looking for updates..."
sudo softwareupdate -i -a

# Install Rosetta
sudo softwareupdate --install-rosetta --agree-to-license

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Creating an SSH key..."
  ssh-keygen -t rsa
fi

echo "Installing xcode..."
xcode-select --install

if test ! $(which brew); then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Checking installation..."
brew update && brew doctor
export HOMEBREW_NO_INSTALL_CLEANUP=1

echo "Installing brew packages..."
brew tap homebrew/cask
brew tap homebrew/cask-versions
brew tap homebrew/cask-fonts
brew install git jq python ruby zsh wget awscli telnet tree

echo "Installing Git..."
brew install git

echo "Setting up Git..."
echo "Please enter your git username:"
read name
echo "Please enter your git email:"
read email

git config --global user.name "$name"
git config --global user.email "$email"

echo "Cleaning up brew..."
brew cleanup

echo "Installing dotfiles from Github..."
git clone https://github.com/gilbitron/dotfiles.git ~/.dotfiles
sh ~/.dotfiles/install.sh

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "installing apps with Cask..."
apps=(
  beeper
  readdle-spark
  todoist
  arc
  google-chrome
  slack
  github
  iterm2
  spotify
  zoomus
  onepassword
  setapp
  cursor
  visual-studio-code
  fantastical
  raycast
)
brew install --appdir="/Applications" ${apps[@]} --cask

brew cleanup --cask
brew cleanup

echo "Setting up Dock..."
dockutil --add "/Applications/Beeper.app" &>/dev/null
dockutil --add "/Applications/Spark Desktop.app" &>/dev/null
dockutil --add "/Applications/Todoist.app" &>/dev/null
dockutil --add "/Applications/Arc.app" &>/dev/null
dockutil --add "/Applications/Slack.app" &>/dev/null
dockutil --add "/Applications/Cursor.app" &>/dev/null
dockutil --add "/Applications/Visual Studio Code.app" &>/dev/null
dockutil --add "/Applications/GitHub Desktop.app" &>/dev/null
dockutil --add "/Applications/iTerm.app" &>/dev/null
dockutil --add "/Applications/Spotify.app" &>/dev/null

echo "Setting some sensible macOS defaults..."
# Sets the mouse speed to 3
defaults write -g com.apple.mouse.scaling 3
# Sets the trackpad speed to 3
defaults write -g com.apple.trackpad.scaling 3
#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE
#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
#"Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
#"Saving to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
#"Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2
#"Hide icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
#"Use column view in all Finder windows by default"
defaults write com.apple.finder FXPreferredViewStyle Clmv
#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true
#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
#"Disable annoying backswipe in Chrome"
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
#"Setting screenshots location to ~/Screenshots"
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"
# Makes the Library folder visible in Finder
chflags nohidden ~/Library

killall Finder

echo "Done!"
echo "Remember to add your public key to Github: https://github.com/account/ssh"
echo "Remember to install apps from Setapp"
