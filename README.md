# Nagi

Flat, quiet light and dark themes for [Mailspring](https://getmailspring.com).
Nagi (凪) is the calm when the wind drops.

## Install

```bash
./install.sh
```

The script finds Mailspring's packages dir (snap, flatpak, macOS, or
`~/.config`). Pass a path to override it. Restart Mailspring, then pick
Nagi Light and Nagi Dark under Preferences → Appearance.

## Layout

- `light/`, `dark/`: theme packages; each `ui-variables.less` holds the palette.
- `shared/`: styles used by both, copied into each package on install.
- `check.sh`: compiles every Mailspring stylesheet against both themes.
