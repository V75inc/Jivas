#
# A helper script to restart a given process as part of a Live Update.
#
# Further reading:
# https://docs.tilt.dev/live_update_reference.html#restarting-your-process
#
# Usage:
#   Copy start.sh and restart.sh to your container working dir.
#
#   Make your container entrypoint:
#   ./start.sh path-to-binary [args]
#
#   To restart the container:
#   ./restart.sh

set -eu

process_id=""

trap quit TERM INT

quit() {
  if [ -n "$process_id" ]; then
    kill $process_id
  fi
}

while true; do
    rm -f restart.txt
    jac clean
    jac run /app/main.jac &
    # ./run_test.sh &
    echo "🕒 Started jaseci server. This usually take a few seconds... 🕒"
    ./init_jivas.sh
    process_id=$!
    echo "$process_id" > process.txt
    set +e
    wait $process_id
    EXIT_CODE=$?
    set -e
    if [ ! -f restart.txt ]; then
        echo "Exiting with code $EXIT_CODE"
        exit $EXIT_CODE
    fi
    echo "Restarting"
done
