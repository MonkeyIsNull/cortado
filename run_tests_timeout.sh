#!/bin/bash
# Simple timeout wrapper since timeout command isn't available
cargo run test &
PID=$!
sleep 60  # Wait 60 seconds
kill $PID 2>/dev/null
wait $PID 2>/dev/null
echo "Test run completed or timed out after 60 seconds"