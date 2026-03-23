# .dotfiles

This repo is intended to be managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stow

By default, `stow` uses the *parent directory of the repo* as the target directory. If this repo is not
checked out directly under your home directory, you probably want to set the target explicitly:

```bash
stow --dir "$(pwd)" --target "$HOME" nvim tmux
```

Or use the convenience wrapper:

```bash
./stow nvim tmux
```

## tmux

This repo includes a tmux config:

- `~/.tmux.conf` sources `~/.config/tmux/tmux.conf`
- Optional plugin support via TPM (tmux plugin manager)
- Reload inside tmux with `prefix` + `r` (default prefix is `Ctrl+a`)

After stowing, install TPM + plugins:

```bash
tmux-setup
```

If you see terminal/color issues, try changing `default-terminal` in `~/.config/tmux/tmux.conf` from
`tmux-256color` to `screen-256color` (or install the `tmux-256color` terminfo on your system).

### If you already ran `stow nvim`

If you ran `stow nvim` from this repo, it likely stowed into the parent directory of the repo. You can undo that with:

```bash
stow --dir "$(pwd)" --target "$(pwd)/.." -D nvim
```
