# bemain's dotfiles
My configuration files for Linux systems.

I use [chezmoi](https://www.chezmoi.io/) to manage the dotfiles.

## Installation
To apply these dotfiles, simply run:
```bash
sh -c "$(curl -fsLS chezmoi.io/getlb)" -- init --apply bemain
```
This installs chezmoi to `~/.local/bin`, pulls and applies these dotfiles from GitHub.

Alternatively, you can [install chezmoi manually](https://www.chezmoi.io/install/) and then initialize the dotfiles with 
```bash
chezmoi init --apply bemain
```

## Usage
The `cz` command is an alias for `chezmoi`, specified in [~/.aliases](/dot_aliases).

To begin managing a file with chezmoi, use:
```bash
cz add FILE
```

To edit a file that is already managed by chezmoi, use:
```bash
cz edit FILE
```

Then, to apply those changes locally, use:
```bash
cz apply
```

To see what changes chezmoi will make to your local files, use:
```bash
cz diff
```

Changes to the dotfiles (done using `cz edit`) should be [automatically pushed](https://www.chezmoi.io/user-guide/daily-operations/#automatically-commit-and-push-changes-to-your-repo) when using the [default config](/.chezmoi.toml.tmpl), but if they aren't you can push them manually:
```bash
chezmoi cd
git add .
git commit -m "MESSAGE"
git push
```

To pull and apply the latest changes from this repo, use:
```bash
cz update
```
