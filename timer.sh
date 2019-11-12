#!/bin/bash

CMD="$1"

./monitor-on-off.sh off

# sleep for x hours
sleep $CMD"h"


./monitor-on-off.sh on
