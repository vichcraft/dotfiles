#!/bin/bash

## Scripts
SCRIPT_AUDIO_OUTPUT="export PATH=$PATH; $RELPATH/plugins/audio_output/script.sh"

## Item properties
audio_output=(
  icon=􀟛
  icon.color=$ACTIVE
  label.drawing=off
  padding_left=0
  update_freq=30
  script="$SCRIPT_AUDIO_OUTPUT"
)

## Item addition
sketchybar --add item audio_output right \
  --set audio_output "${audio_output[@]}" \
  --subscribe audio_output mouse.clicked mouse.exited.global

sendLog "Added audio_output item" "vomit"
