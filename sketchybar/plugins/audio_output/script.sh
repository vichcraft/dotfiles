#!/bin/bash
export RELPATH=$(dirname $0)/../..
source $RELPATH/set_colors.sh
source $RELPATH/log_handler.sh

# Virtual/app audio devices to filter out (case-insensitive match)
VIRTUAL_DEVICES=(
  "microsoft teams"
  "zoom"
  "blackhole"
  "loopback"
  "soundflower"
  "obs"
  "virtual"
  "screenaudio"
)

is_virtual_device() {
  local name="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  for pattern in "${VIRTUAL_DEVICES[@]}"; do
    if [[ "$name" == *"$pattern"* ]]; then
      return 0
    fi
  done
  return 1
}

# Map device name to SF Symbol icon
get_device_icon() {
  local name="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "$name" in
    *airpods\ pro*|*airpods\ max*) echo "􀪷" ;;
    *airpods*)                      echo "􀲋" ;;
    *headphone*)                    echo "􀑈" ;;
    *macbook*|*built-in*|*internal*) echo "􀟛" ;;
    *homepod*)                      echo "􀟥" ;;
    *hdmi*|*display*|*tv*)          echo "􀨫" ;;
    *)                              echo "􀝎" ;;
  esac
}

# Remove all popup items
popup_close() {
  local items="$(sketchybar --query $NAME | sed 's/\\n//g; s/\\\$//g; s/\\ //g' | jq -r '.popup.items[]' 2>/dev/null)"
  for item in $items; do
    sketchybar --remove "$item" 2>/dev/null
  done
  sketchybar --set $NAME popup.drawing=off
}

# Build popup with all output devices
popup_open() {
  if ! command -v SwitchAudioSource &>/dev/null; then
    sendErr "SwitchAudioSource not installed" "info"
    return 1
  fi

  local current="$(SwitchAudioSource -c -t output)"
  local idx=0

  while IFS= read -r device; do
    [ -z "$device" ] && continue
    is_virtual_device "$device" && continue
    local item_name="audio_output.device.$idx"
    local icon="$(get_device_icon "$device")"

    if [ "$device" = "$current" ]; then
      local label_color="$SELECT"
      local display_icon="􀆅 $icon"
    else
      local label_color="$LABEL_COLOR"
      local display_icon="  $icon"
    fi

    sketchybar --add item "$item_name" popup.$NAME \
      --set "$item_name" \
        label="$device" \
        label.max_chars=25 \
        label.color="$label_color" \
        icon="$display_icon" \
        icon.color="$label_color" \
        icon.padding_left=5 \
        icon.padding_right=5 \
        label.padding_right=10 \
        click_script="SwitchAudioSource -s '$device' -t output; sketchybar --set $NAME popup.drawing=off; $RELPATH/plugins/audio_output/script.sh"

    idx=$((idx + 1))
  done < <(SwitchAudioSource -a -t output)

  sketchybar --set $NAME popup.drawing=on
}

# Refresh bar item with current output device
update_item() {
  if ! command -v SwitchAudioSource &>/dev/null; then
    sketchybar --set $NAME icon="􀝏" label="No SAS"
    sendErr "SwitchAudioSource is not installed (brew install switchaudio-osx)" "info"
    return 1
  fi

  # Icon stays fixed as headphone symbol; no label shown
  return 0
}

case "$SENDER" in
"mouse.clicked")
  local_drawing="$(sketchybar --query $NAME | sed 's/\\n//g; s/\\\$//g; s/\\ //g' | jq -r '.popup.drawing')"
  if [ "$local_drawing" = "on" ]; then
    popup_close
  else
    popup_close
    popup_open
  fi
  ;;
"mouse.exited.global")
  popup_close
  ;;
*)
  update_item
  ;;
esac
