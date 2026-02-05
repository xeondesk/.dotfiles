#!/bin/bash

# installer for dotfiles
function brew_shellenv() {
	if [ -d "$HOME/homebrew" ]; then
		eval "$("$HOME"/homebrew/bin/brew shellenv)"
	else
		if [[ $OSTYPE == 'darwin'* ]]; then
			test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
			test -f /usr/local/bin/brew && eval "$(/usr/local/bin/brew shellenv)"
		else
			test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi
	fi
}

cd "$HOME" || exit

# ask the user whether they want to use system's homebrew or use a local install
echo "Do you want to use the system's homebrew? (recommended) [Y/n]"
read -r answer
if [ "$answer" = "n" ]; then
	echo "Installing local homebrew..."
	mkdir homebrew
	curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
else
	# delete local homebrew if it exists
	rm -rf ~/homebrew
	echo "Installing system homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew_shellenv

# install github cli
brew install gh
# install chezmoi
brew install chezmoi
# install zsh
brew install zsh
# install gum
brew install gum
# add $(which zsh) to the list of shells if it doesn't exist
if ! grep -q $(which zsh) /etc/shells; then
	echo "Adding $(which zsh) to /etc/shells"
	sudo sh -c "echo $(which zsh) >> /etc/shells"
fi
chsh -s $(which zsh)

echo "Authenticating with GitHub. Please make sure to choose ssh option for authentication."

# authenticate with github
gh auth login -p ssh

# check if $HOME/.git exists and back it up if it does
if [ -d "$HOME"/.git ]; then
	echo "Backing up $HOME/.git to $HOME/.git.bak"
	mv "$HOME"/.git "$HOME"/.git.bak
fi

echo "Setting up .gitconfig_local"

# Helper function to escape gitconfig values
escape_gitconfig() {
	# Escape backslashes and quotes for gitconfig format
	printf '%s\n' "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
}

# Helper function to validate email
validate_email() {
	local email="$1"
	# Simple email validation pattern
	if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
		return 0
	else
		return 1
	fi
}

# Helper function to validate name
validate_name() {
	local name="$1"
	# Allow letters, spaces, hyphens, apostrophes
	if [[ "$name" =~ ^[a-zA-Z\ \'-]+$ ]] && [[ ${#name} -le 100 ]]; then
		return 0
	else
		return 1
	fi
}

# Collect and validate user input
while true; do
	email=$(gum input --placeholder "Please enter your CodeRabbit email address")
	if validate_email "$email"; then
		break
	fi
	echo "❌ Invalid email format. Please try again."
done

while true; do
	name=$(gum input --placeholder "Please enter your name")
	if validate_name "$name"; then
		break
	fi
	echo "❌ Invalid name. Only letters, spaces, hyphens, and apostrophes allowed (max 100 chars)."
done

# Escape and write safely
email_escaped=$(escape_gitconfig "$email")
name_escaped=$(escape_gitconfig "$name")

{
	echo "[user]"
	echo "  name = $name_escaped"
	echo "  email = $email_escaped"
} >"$HOME/.gitconfig_local"

chmod 600 "$HOME/.gitconfig_local"  # Restrict permissions
echo "✅ Git configuration saved"

# Initialize chezmoi with SSH/HTTPS fallback
echo "Initializing chezmoi..."
if ssh -T git@github.com >/dev/null 2>&1; then
	# SSH key available, use SSH URL
	chezmoi init git@github.com:xeondesk/.dotfiles.git
else
	# Fall back to HTTPS (requires git credentials or gh CLI token)
	echo "SSH authentication not available, using HTTPS..."
	chezmoi init https://github.com/xeondesk/.dotfiles.git
fi

chezmoi apply -v

# run autoupdate script
echo "Running autoupdate script..."
# Look for the custom autoupdate script in dotfiles after chezmoi apply
if [ -x "$HOME/.local/bin/autoupdate" ]; then
	"$HOME/.local/bin/autoupdate" --force || {
		echo "⚠️  autoupdate script failed, but dotfiles are applied"
	}
elif [ -x "$HOME/.dotfiles/bin/autoupdate" ]; then
	"$HOME/.dotfiles/bin/autoupdate" --force || {
		echo "⚠️  autoupdate script failed, but dotfiles are applied"
	}
else
	echo "⚠️  autoupdate script not found, skipping (will run on next shell launch)"
fi

# reboot computer (skip in containers)
echo "Script completed successfully!"
echo ""

# Detect if running in a container
if [ -f /.dockerenv ] || [ -f /run/secrets/kubernetes.io ]; then
	echo "ℹ️  Container detected. Skipping reboot."
	echo "Your dotfiles have been applied. Please restart your shell to load the new configuration:"
	echo "  exec \$SHELL"
else
	echo "⚠️  The system needs to restart to apply all changes."
	echo ""

	if gum confirm "Restart now?"; then
		echo "Restarting computer..."
		sudo reboot
	else
		echo "Restart skipped. Please restart manually when ready:"
		echo "  sudo reboot"
	fi
fi
