#!/bin/bash
export RELPATH=$(dirname $0)/../..
source $RELPATH/log_handler.sh

if command -v aerospace >/dev/null; then
	aerospace layout floating tiling
	sendLog "Toggle window floating" "vomit"
else
	sendErr "No aerospace" "debug"
fi
