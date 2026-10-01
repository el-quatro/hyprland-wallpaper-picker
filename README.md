# Hyprland Wallpaper Picker

A simple wallpaper picker for Hyprland using:

- Rofi
- Hyprpaper
- Bash
- Hyprland keybinds

The result:

```text
CTRL + W
   ↓
Rofi wallpaper picker opens
   ↓
Select a wallpaper
   ↓
Hyprpaper changes the wallpaper
```

---

## 1. Install required packages

On Arch Linux:

```bash
sudo pacman -S rofi hyprpaper git
```

---

## 2. Create required directories

Create the directories used by this setup:

```bash
mkdir -p ~/.config/scripts
mkdir -p ~/.config/rofi
mkdir -p ~/.config/hypr
mkdir -p ~/Pictures/Wallpaper
```

---

## 3. Download wallpapers

This setup uses wallpapers from:

```text
https://github.com/Somrat10369/Windows-11-Productive-Rice-Configs
```

You do not need to clone the entire repository.

Use Git sparse checkout to download only the `Wallpaper` directory:

```bash
git clone --depth 1 --filter=blob:none --sparse \
https://github.com/Somrat10369/Windows-11-Productive-Rice-Configs.git
```

Enter the repository:

```bash
cd Windows-11-Productive-Rice-Configs
```

Pull only the wallpaper folder:

```bash
git sparse-checkout set Wallpaper
```

Copy the wallpapers into:

```text
~/Pictures/Wallpaper
```

Run:

```bash
cp -r Wallpaper/* ~/Pictures/Wallpaper/
```

Check that the wallpapers were copied:

```bash
ls ~/Pictures/Wallpaper
```

You can now remove the temporary repository if you want:

```bash
cd ..
rm -rf Windows-11-Productive-Rice-Configs
```

---

## 4. Clone this repository

Clone this repository:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
```

Enter it:

```bash
cd YOUR_REPOSITORY
```

The repository contains:

```text
.
├── hyprpaper.conf
├── README.md
├── wallpaper-picker.sh
└── wallpaper.rasi
```

---

## 5. Copy the configuration files

Copy the wallpaper picker script:

```bash
cp wallpaper-picker.sh ~/.config/scripts/
```

Copy the Rofi theme:

```bash
cp wallpaper.rasi ~/.config/rofi/
```

Copy the Hyprpaper configuration:

```bash
cp hyprpaper.conf ~/.config/hypr/
```

Make the script executable:

```bash
chmod +x ~/.config/scripts/wallpaper-picker.sh
```

---

## 6. Find your monitor name

Run:

```bash
hyprctl monitors
```

You should see something similar to:

```text
Monitor eDP-1 (ID 0):
```

or:

```text
Monitor HDMI-A-1 (ID 1):
```

The important part is the monitor name.

For example:

```text
eDP-1
```

Open the wallpaper picker script:

```bash
nvim ~/.config/scripts/wallpaper-picker.sh
```

Find:

```bash
MONITOR="eDP-1"
```

Change it to match your monitor.

For example:

```bash
MONITOR="HDMI-A-1"
```

---

## 7. Wallpaper directory

The script expects your wallpapers here:

```text
~/Pictures/Wallpaper
```

Inside `wallpaper-picker.sh`:

```bash
WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
```

If you want to use another directory, change this variable.

---

## 8. Configure Hyprpaper

Open:

```bash
nvim ~/.config/hypr/hyprpaper.conf
```

Example configuration:

```conf
wallpaper {
    monitor = eDP-1
    path = /home/USERNAME/Pictures/Wallpaper/001.png
    fit_mode = cover
}

splash = false
ipc = on
```

Change:

```text
eDP-1
```

to your own monitor name.

Also change:

```text
/home/USERNAME/Pictures/Wallpaper/001.png
```

to a wallpaper that actually exists on your machine.

You can check your wallpapers with:

```bash
ls ~/Pictures/Wallpaper
```

The important setting is:

```conf
ipc = on
```

This allows the wallpaper picker script to communicate with Hyprpaper.

---

## 9. Start Hyprpaper

Start Hyprpaper:

```bash
hyprpaper &
```

Check that it is running:

```bash
pgrep -a hyprpaper
```

You can also test Hyprpaper IPC:

```bash
hyprctl hyprpaper listactive
```

---

## 10. Wallpaper picker script

The script is stored here:

```text
~/.config/scripts/wallpaper-picker.sh
```

Example:

```bash
#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
MONITOR="eDP-1"
THEME="$HOME/.config/rofi/wallpaper.rasi"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

SELECTED="$(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort \
        | while read -r file; do
            printf '%s\0icon\x1f%s\n' "$(basename "$file")" "$file"
        done \
        | rofi -dmenu \
            -i \
            -show-icons \
            -p "Wallpaper" \
            -theme "$THEME"
)"

[ -z "$SELECTED" ] && exit 0

WALLPAPER="$WALLPAPER_DIR/$SELECTED"

# Change wallpaper immediately
hyprctl hyprpaper wallpaper "$MONITOR, $WALLPAPER, cover"

# Save selected wallpaper so it survives logout/reboot
cat > "$HYPRPAPER_CONF" <<EOF
wallpaper {
    monitor = $MONITOR
    path = $WALLPAPER
    fit_mode = cover
}

splash = false
ipc = on
EOF
```

Make sure this matches your monitor:

```bash
MONITOR="eDP-1"
```

---

## 11. Rofi wallpaper theme

The custom Rofi theme is stored here:

```text
~/.config/rofi/wallpaper.rasi
```

Example:

```rasi
configuration {
    show-icons: true;
}

* {
    font: "JetBrainsMono Nerd Font 13";

    bg:             #11111bee;
    bg-alt:         #181825ff;
    foreground:     #cdd6f4ff;
    accent:         #89b4faff;
    selected-text:  #11111bff;

    background-color: transparent;
    text-color: @foreground;
}

window {
    width: 52%;
    height: 55%;

    location: center;
    anchor: center;

    background-color: @bg;

    border: 2px;
    border-color: @accent;
    border-radius: 16px;

    padding: 18px;
}

mainbox {
    background-color: transparent;
    spacing: 14px;

    children: [
        inputbar,
        listview
    ];
}

inputbar {
    background-color: @bg-alt;

    border-radius: 10px;
    padding: 10px 14px;

    spacing: 8px;

    children: [
        prompt,
        entry
    ];
}

prompt {
    text-color: @accent;
}

entry {
    background-color: transparent;
    text-color: @foreground;

    placeholder: "Search...";
    placeholder-color: #6c7086ff;
}

listview {
    background-color: transparent;

    columns: 4;
    lines: 2;

    spacing: 10px;

    fixed-height: true;
    fixed-columns: true;

    scrollbar: false;

    flow: horizontal;
}

element {
    orientation: vertical;

    background-color: @bg-alt;

    border-radius: 10px;

    padding: 8px;
    spacing: 6px;
}

element selected {
    background-color: @accent;
    text-color: @selected-text;
}

element-icon {
    size: 140px;

    horizontal-align: 0.5;
    vertical-align: 0.5;
}

element-text {
    background-color: transparent;
    text-color: inherit;

    horizontal-align: 0.5;

    margin: 4px 0px 0px 0px;
}
```

---

## 12. Test Rofi

Test Rofi itself:

```bash
rofi -show drun
```

Test the wallpaper theme directly:

```bash
printf 'test\n' | rofi -dmenu -theme ~/.config/rofi/wallpaper.rasi
```

---

## 13. Test the wallpaper script

Before adding a keybind, test the script manually:

```bash
~/.config/scripts/wallpaper-picker.sh
```

You should see the wallpaper picker.

Select a wallpaper.

Hyprpaper should apply it immediately.

---

## 14. Add a Hyprland keybind

### Standard Hyprland configuration

If you use `hyprland.conf`, add:

```conf
bind = CTRL, W, exec, ~/.config/scripts/wallpaper-picker.sh
```

Reload Hyprland:

```bash
hyprctl reload
```

---

### Lua-based Hyprland configuration

If your setup uses `hyprland.lua`, add:

```lua
hl.bind(
    "CTRL + W",
    hl.dsp.exec_cmd("~/.config/scripts/wallpaper-picker.sh")
)
```

Reload Hyprland:

```bash
hyprctl reload
```

---

## 15. Use the wallpaper picker

Press:

```text
CTRL + W
```

Rofi should open with wallpaper thumbnails.

Select one and Hyprpaper will change the wallpaper.

---

# Optional: Start Hyprpaper automatically

If Hyprpaper does not start automatically when you log in, add it to your Hyprland startup configuration.

For a standard Hyprland config:

```conf
exec-once = hyprpaper
```

Then reload or log out and back in.

---

# Troubleshooting

## Hyprpaper is not running

If you see:

```text
failed to connect to hyprpaper
```

start it:

```bash
hyprpaper &
```

Check it:

```bash
pgrep -a hyprpaper
```

---

## Invalid monitor

If you see:

```text
Invalid monitor
```

run:

```bash
hyprctl monitors
```

Then change:

```bash
MONITOR="eDP-1"
```

inside:

```text
~/.config/scripts/wallpaper-picker.sh
```

to your actual monitor name.

---

## Rofi already running

If you see:

```text
Rofi already running?
```

check for a running process:

```bash
pgrep -a rofi
```

Kill it:

```bash
pkill rofi
```

Remove the stale PID file:

```bash
rm -f "$XDG_RUNTIME_DIR/rofi.pid"
```

Then try again:

```bash
rofi -show drun
```

---

## Script does not execute

Make sure it is executable:

```bash
chmod +x ~/.config/scripts/wallpaper-picker.sh
```

Then run:

```bash
~/.config/scripts/wallpaper-picker.sh
```

---

## Wallpapers are not showing

Check the directory:

```bash
ls ~/Pictures/Wallpaper
```

The script expects:

```bash
WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
```

Make sure the directory name matches exactly.

---

## Rofi theme does not load

Check that this file exists:

```bash
ls ~/.config/rofi/wallpaper.rasi
```

Test it:

```bash
printf 'test\n' | rofi -dmenu -theme ~/.config/rofi/wallpaper.rasi
```

---

# Directory layout

After setup, your files should look like this:

```text
~/.config/
├── hypr/
│   └── hyprpaper.conf
│
├── rofi/
│   └── wallpaper.rasi
│
└── scripts/
    └── wallpaper-picker.sh
```

Wallpapers:

```text
~/Pictures/Wallpaper/
├── 001.png
├── 002.png
├── 003.png
├── 004.png
└── ...
```

---

# How it works

The setup is simple:

```text
CTRL + W
   ↓
Hyprland launches wallpaper-picker.sh
   ↓
The script scans ~/Pictures/Wallpaper
   ↓
Rofi displays image thumbnails
   ↓
You select an image
   ↓
The script sends the image to Hyprpaper
   ↓
Wallpaper changes
```

---

# Credits

Wallpapers used in this setup come from:

```text
https://github.com/Somrat10369/Windows-11-Productive-Rice-Configs
```

Wallpaper picker configuration and setup instructions are kept in this repository.
# hyprland-wallpaper-picker
