# .dotfiles

This repo is intended to be managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stow

By default, `stow` uses the *parent directory of the repo* as the target directory. If this repo is not
checked out directly under your home directory, you probably want to set the target explicitly:

```bash
stow --dir "$(pwd)" --target "$HOME" nvim
```

Or use the convenience wrapper:

```bash
./stow nvim
```

### If you already ran `stow nvim`

If you ran `stow nvim` from this repo, it likely stowed into the parent directory of the repo. You can undo that with:

```bash
stow --dir "$(pwd)" --target "$(pwd)/.." -D nvim
```
