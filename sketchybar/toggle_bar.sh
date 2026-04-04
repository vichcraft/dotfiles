#!/bin/bash
# Toggle SketchyBar visibility + AeroSpace top gaps
# Used by AeroSpace keybinding (alt-space)

STATE_FILE="/tmp/sketchybar_hidden"
AEROSPACE_CONFIG="$HOME/.aerospace.toml"

GAP_BAR_VISIBLE='outer.top = [{ monitor."built-in" = 5 }, { monitor.main = 35 }, 36]'
GAP_BAR_HIDDEN='outer.top = [{ monitor."built-in" = 5 }, { monitor.main = 5 }, 5]'

if [ -f "$STATE_FILE" ]; then
	# Show bar, restore gaps
	sketchybar --bar hidden=off
	sed -i '' "s|^outer\.top = .*|$GAP_BAR_VISIBLE|" "$AEROSPACE_CONFIG"
	rm "$STATE_FILE"
else
	# Hide bar, shrink gaps
	sketchybar --bar hidden=on
	sed -i '' "s|^outer\.top = .*|$GAP_BAR_HIDDEN|" "$AEROSPACE_CONFIG"
	touch "$STATE_FILE"
fi

aerospace reload-config
