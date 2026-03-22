#!/bin/bash
export PATH=/opt/homebrew/bin/:$PATH
export RELPATH=$(dirname $0)/../..

MUSICSTATE="$(sketchybar --query music | sed 's/\\n//g; s/\\\$//g; s/\\ //g' | jq -r '.geometry.drawing')"

if [ "$MUSICSTATE" = "on" ]; then
  sketchybar --set separator_center drawing=on
else
  sketchybar --set separator_center drawing=off
fi
