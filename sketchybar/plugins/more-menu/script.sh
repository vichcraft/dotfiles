#!/bin/bash
export RELPATH=$(dirname $0)/../..
source $RELPATH/log_handler.sh
shopt -s expand_aliases
command -v 'ft-haptic' 2>/dev/null 1>&2 || alias ft-haptic="$RELPATH/ft-haptic"

## Default and global settings
menuitems=($1) # What items will be in the moremenu
INNER_PADDINGS=$2
FONT="$3"

## Define state depending on the icon of the separator (this is a bad practice tho)
ICON_VALUE="$(sketchybar --query $NAME | sed 's/\\n//g; s/\\\$//g; s/\\ //g' | jq -r '.icon.value')"

if [[ $ICON_VALUE = '|' ]]; then
	STATE=on
else
	STATE=off
fi

## Internal functions
menu_set() {
	sendLog "Toggle moremenu to $1" "debug"

	# Toggle drawing of each menu item
	for item in ${menuitems[@]}; do
		item=$(echo "$item" | sed -e "s/__/ /g")
		sketchybar --animate tanh 15 \
			--set "$item" drawing=$1
		sendLog "Set \"$item\" drawing to $1" "vomit"
	done

	# When setting to on, then update menu items
	if [ $1 = "on" ]; then
		separator=(
			icon="|"
			icon.font="$FONT:Bold:16.0"
			icon.padding_left=0
			icon.padding_right=0
		)
		sketchybar --set $NAME icon.y_offset=2 \
			--animate tanh 15 \
			--set $NAME "${separator[@]}"
		sketchybar --trigger more-menu-update
	else
		separator=(
			icon="􀯶"
			icon.font="$FONT:Semibold:14.0"
			icon.padding_left=$INNER_PADDINGS
			icon.padding_right=$INNER_PADDINGS
		)
		sketchybar --set $NAME icon.y_offset=0 \
			--animate tanh 15 \
			--set $NAME "${separator[@]}"
	fi
}

## Main logic
case "$SENDER" in
"mouse.entered")
	ft-haptic -n 1
	;;
"mouse.clicked")
	if [ "$STATE" = "off" ]; then
		menu_set "on"
	else
		menu_set "off"
	fi
	;;
esac
