#!/bin/bash

echo "Starting Bridge Data Collection Workflow..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
if ! command_exists docker; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

if ! command_exists docker-compose; then
    echo "Error: Docker Compose is not installed or not in PATH"
    exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f "docker-compose.yml" ]]; then
    echo "Error: docker-compose.yml not found. Please run this script from the bridge_data_robot directory."
    exit 1
fi
run_in_new_terminal() {
    local title="$1"
    local commands="$2"
    if command_exists gnome-terminal; then
        gnome-terminal --title="$title" -- bash -c "$commands; exec bash"
    elif command_exists konsole; then
        konsole --title "$title" -e bash -c "$commands; exec bash"
    elif command_exists xterm; then
        xterm -title "$title" -e bash -c "$commands; exec bash" &
    elif command_exists alacritty; then
        alacritty --title "$title" -e bash -c "$commands; exec bash" &
    else
        echo "Warning: No supported terminal emulator found. Please run the commands manually."
        echo "Commands for $title:"
        echo "$commands"
        return 1
    fi
}

echo "Starting Docker Compose in first terminal window..."
FIRST_WINDOW_CMDS="cd ~/bridge_data_robot && echo 'Starting Docker Compose...' && sudo USB_CONNECTOR_CHART=\$(pwd)/usb_connector_chart.yml docker compose up --build robonet"

run_in_new_terminal "Bridge Data - Docker Compose" "$FIRST_WINDOW_CMDS"

echo "Waiting for Docker to start..."
sleep 5

echo "Starting data collection in second terminal window..."
SECOND_WINDOW_CMDS="cd ~/bridge_data_robot && echo 'Waiting for Docker container to be ready...' && sleep 10 && echo 'Connecting to Docker container...' && sudo docker compose exec robonet bash -c 'export DATA=/tmp && export EXP=/tmp && pip install --upgrade scipy && python widowx_envs/widowx_envs/run_data_collection.py widowx_envs/experiments/bridge_data_v2/conf.py'"

run_in_new_terminal "Bridge Data - Collection" "$SECOND_WINDOW_CMDS"

echo "Workflow started! Check the terminal windows for progress."
echo ""
echo "To copy data after collection:"
echo "sudo docker cp robonet_root:/tmp/robonetv2 ~/widowx_data/"
echo ""
echo "To start the remote policy server for inference:"
echo "docker compose exec robonet bash -lic 'widowx_env_service --server'" 