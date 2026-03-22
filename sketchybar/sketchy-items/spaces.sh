#!/bin/bash

## Item properties
dummy_space=(
	icon.padding_left=6
	icon.padding_right=7
	icon.color=$NOTICE
	padding_left=3
	padding_right=3
	background.color=$HIGH_MED
	background.height=$(($BAR_HEIGHT - 12))
	background.corner_radius=$(($ZONE_CORNER_RADIUS - 2))
	background.drawing=off
	icon.highlight_color=$CRITICAL
	label.padding_right=20
	label.font="sketchybar-app-font:Regular:16.0"
	label.background.height=$(($BAR_HEIGHT - 12))
	label.background.drawing=off
	label.background.color=$HIGH_HIGH
	label.background.corner_radius=$(($ZONE_CORNER_RADIUS - 2))
	label.y_offset=-1
	label.drawing=on
	label.width=0
)

separator=(
	icon=􀆊
	label.drawing=off
	icon.font="$FONT:Semibold:14.0"
	associated_display=active
	icon.color=$SUBTLE
)

## Scripts
SCRIPT_SPACES="export PATH=$PATH; $RELPATH/plugins/spaces/aerospace/script-space.sh"
SCRIPT_SPACE_WINDOWS="export PATH=$PATH; $RELPATH/plugins/spaces/aerospace/script-windows.sh"

## Aerospace space setup
sketchybar --add event aerospace_workspace_change

SPACES=($(aerospace list-workspaces --all 2>/dev/null))
sendLog "Detected aerospace spaces : ${SPACES[*]}" "vomit"

# Detect number of displays
DISPLAY_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
sendLog "Detected $DISPLAY_COUNT display(s)" "vomit"

for sid in "${SPACES[@]}"; do
	# Per-monitor workspace filtering
	# Single monitor: all workspaces on display 1
	# Dual monitor: workspaces 1-5 on display 1 (external), 6-9 on display 2 (macbook)
	if [ "$DISPLAY_COUNT" -le 1 ] 2>/dev/null; then
		DISPLAY_NUM=1
	elif [ "$sid" -le 5 ] 2>/dev/null; then
		DISPLAY_NUM=1
	else
		DISPLAY_NUM=2
	fi

	space=("${dummy_space[@]}")
	space+=(
		icon="$sid"
		script="$SCRIPT_SPACES $sid"
		drawing=on
		display=$DISPLAY_NUM
		click_script="aerospace workspace $sid"
	)

	sketchybar --add item space.$sid left \
		--set space.$sid "${space[@]}" \
		--subscribe space.$sid aerospace_workspace_change mouse.clicked mouse.entered

	sendLog "Add aerospace space item id : $sid on display $DISPLAY_NUM" "vomit"
done

# Single monitor: only one separator on display 1
# Dual monitor: separator per display
if [ "$DISPLAY_COUNT" -le 1 ] 2>/dev/null; then
	separator_d1=("${separator[@]}")
	separator_d1+=(display=1)
	sketchybar --add item separator.1 left \
		--set separator.1 "${separator_d1[@]}"
else
	separator_d1=("${separator[@]}")
	separator_d1+=(display=1)
	sketchybar --add item separator.1 left \
		--set separator.1 "${separator_d1[@]}"

	separator_d2=("${separator[@]}")
	separator_d2+=(display=2)
	sketchybar --add item separator.2 left \
		--set separator.2 "${separator_d2[@]}"
fi

## Add all spaces in a bracket
sketchybar --add bracket spaces '/space\..*/' \
	--set spaces "${zones[@]}"
