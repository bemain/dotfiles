#!/bin/bash
# Install VSCode extensions

pkglist=(
	# Theme
	"jdinhlife.gruvbox"
	
	# Languages
	"dart-code.flutter"
	"ms-python.python"
	
	# Tools
	"eamodio.gitlens"
	"google.geminicodeassist"
	"github.vscode-github-actions"
	"github.vscode-pull-request-github"
)

for APP_ID in ${pkglist[@]}; do
  distrobox enter -- code --install-extension "${APP_ID}"
done
