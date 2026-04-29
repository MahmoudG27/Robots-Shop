#!/bin/sh

if [ -z "$HOST" ]; then
    echo "HOST env not set"
    exit 1
fi

if ! echo "$NUM_CLIENTS" | egrep -q '^[0-9]+$'; then
    echo "NUM_CLIENTS must be a number"
    exit 1
fi

if [ "$NUM_CLIENTS" -eq 0 ]; then
    NUM_CLIENTS=1
fi

if [ "$RUN_TIME" != "0" ] && echo "$RUN_TIME" | egrep -q '^([0-9]+h)?([0-9]+m)?$'; then
    TIME="-t $RUN_TIME"
else
    TIME=""
fi

RAMP_RATE=${RAMP_RATE:-1}

echo "Starting $NUM_CLIENTS clients for ${RUN_TIME:-forever}"

if [ "$SILENT" -eq 1 ]; then
    locust -f robot-shop.py --host "$HOST" --headless \
        -r "$RAMP_RATE" -u "$NUM_CLIENTS" $TIME > /dev/null 2>&1
else
    locust -f robot-shop.py --host "$HOST" --headless \
        -r "$RAMP_RATE" -u "$NUM_CLIENTS" $TIME
fi