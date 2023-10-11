#!/bin/bash

# ==============================================================
# MauticSmartSend 1.0.1
# ==============================================================
# Purpose: An intelligent script to send Mautic emails in a 
#          controlled manner, providing real-time feedback and
#          ensuring efficient email delivery.
#
# Author: Taylor Selden
# Date:   October 10, 2023
# ==============================================================
# ==================== CONFIGURATION START =====================
# ==============================================================
# NOTE: ⚠️ YOU MUST CONFIGURE THE FOLLOWING PARAMETERS ⚠️

# Path to your PHP executable
PHP_EXEC="/usr/local/bin/php"

# Directory where Mautic stores emails to be sent
SPOOL_DIR="/home/username/public_html/mautic/var/spool"

# Directory where Mautic's bin is located
BIN_DIR="/home/username/public_html/mautic/bin"

# Temporary lock file location. This ensures only one instance of the script runs at a time.
LOCK_FILE="/tmp/mautic_smartsend.lock"

# Maximum number of emails to be sent in a single cycle
MESSAGE_LIMIT=14

# Sleep time between sending cycles in seconds
SLEEP_TIME=1

# ==============================================================
# ===================== CONFIGURATION END ======================
# ==============================================================

# Script's main processing logic
main() {
    # Store the current script's PID in the lock file
    echo $$ > $LOCK_FILE

    # Ensure the lock file is removed when the script exits
    trap "rm -f $LOCK_FILE" EXIT

    # Set initial placeholder values for the display variables
    FILE_COUNT=$(count_files)
    MESSAGES_THIS_CYCLE="$MESSAGE_LIMIT"
    REMAINING_MESSAGES="$FILE_COUNT"
    ESTIMATED_FINISH_HUMAN="Calc..."
    TOTAL_MESSAGES_SENT=0

    # Print the initial "box" using the print_output function
    print_output
    ctput cuu 6

    # Start the loop
    while [[ $FILE_COUNT -gt 0 ]]; do
        # Capture the start time of the cycle
        START_TIME=$(date +%s)

        # Calculate messages being sent in this cycle
        MESSAGES_THIS_CYCLE=$(( FILE_COUNT < MESSAGE_LIMIT ? FILE_COUNT : MESSAGE_LIMIT ))

        # Execute the PHP command with the message limit
        $PHP_EXEC $BIN_DIR/console mautic:emails:send --message-limit $MESSAGE_LIMIT

        # Capture the output of the Mautic command
        MAUTIC_OUTPUT=$($PHP_EXEC $BIN_DIR/console mautic:emails:send --message-limit $MESSAGE_LIMIT 2>&1)

        # Check if there's any output
        if [[ ! -z "$MAUTIC_OUTPUT" ]]; then
            echo "Error: Mautic command produced an unexpected output:"
            echo "$MAUTIC_OUTPUT"
            exit 1
        fi

        # Increment the messages sent counter
        TOTAL_MESSAGES_SENT=$(( TOTAL_MESSAGES_SENT + MESSAGES_THIS_CYCLE ))

        # Wait for the specified sleep time
        sleep $SLEEP_TIME

        # Capture the end time of the cycle
        END_TIME=$(date +%s)
        CYCLE_DURATION=$(( END_TIME - START_TIME ))

        # Calculate the projected finish time after each cycle
        ESTIMATED_FINISH_TIME=$(( END_TIME + (REMAINING_MESSAGES / MESSAGE_LIMIT) * CYCLE_DURATION ))
        ESTIMATED_FINISH_HUMAN=$(date -d "@$ESTIMATED_FINISH_TIME" "+%Y-%m-%d %H:%M:%S")

        # Count the number of messages in the spool directory
        FILE_COUNT=$(count_files)

        REMAINING_MESSAGES=$(( FILE_COUNT - MESSAGES_THIS_CYCLE ))

        # Print the output and use tput to move the cursor up 6 lines (to start of the output block)
        print_output
        ctput cuu 6
    done

    # Clear any old output and display the final message
    ctput ed
    cprint "MauticSmartSend completed successfully. A total of $TOTAL_MESSAGES_SENT messages were sent."
}

# Check for command-line arguments
process_args() {
    SILENT_MODE=false
    for arg in "$@"; do
        case $arg in
            -h|--help)
                print_help
                exit 0
                ;;
            -s|--silent)
                SILENT_MODE=true
                ;;
            *)
                # Capture unrecognized argument
                echo "Error: Invalid argument '$arg'"
                print_help
                exit 1
                ;;
        esac
        shift
    done
}

# Check the number of messages in the spool
count_files() {
    find "$SPOOL_DIR" -maxdepth 1 -type f | wc -l
}

# Conditional print function
cprint() {
    if ! $SILENT_MODE; then
        echo "$@"
    fi
}

# Conditional tput function
ctput() {
    if ! $SILENT_MODE; then
        tput "$@"
    fi
}

print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo " MauticSmartSend 1.0"
    echo " An intelligent script to send Mautic emails in a controlled manner, providing"
    echo " real-time feedback and ensuring efficient email delivery."
    echo 
    echo " This tool is intended to replace Mautic's mautic:emails:send cron job. By using"
    echo " MauticSmartSend, you can schedule email sending as frequently as desired."
    echo
    echo " Options:"
    echo "  -h,--help               Display this help screen"
    echo "  -s,--silent             Enable silent mode (no output)"
    echo
    echo " Examples:"
    echo "  $0                      Regular execution"
    echo "  $0 -s                   Execute in silent mode"
    echo
}

# Function to display the output block
print_output() {
    cprint "=========================================="
    cprint "Messages waiting to be sent: $FILE_COUNT                           "
    cprint "Sending in this cycle: $MESSAGES_THIS_CYCLE                        "
    cprint "Remaining after this cycle: $REMAINING_MESSAGES                    "
    cprint "Projected finish time: $ESTIMATED_FINISH_HUMAN                     "
    cprint "=========================================="
}

pre_run_checks() {
    # Check for the existence of the lock file and retrieve PID
    if [ -e "$LOCK_FILE" ]; then
        LOCKED_PID=$(cat $LOCK_FILE)
        echo "The script is already running with PID $LOCKED_PID. Exiting."
        exit 1
    fi

    # Check if we can write to the lock file directory
    if ! touch "$LOCK_FILE" 2> /dev/null; then
        echo "Error: Cannot write to lock file ($LOCK_FILE). Check permissions or directory path. Exiting."
        exit 1
    else
        rm -f "$LOCK_FILE"  # remove the temporary lock file created by touch
    fi

    # Check if PHP exists and can be run
    if ! $PHP_EXEC -v > /dev/null 2>&1; then
        echo "Error: PHP is not found or not executable."
        exit 1
    else
        PHP_VERSION=$($PHP_EXEC --version | head -n 1 | cut -d " " -f 2)
        if [[ -z "$PHP_VERSION" ]]; then
            echo "Error: Unable to determine PHP version."
            exit 1
        else
            cprint "Detected PHP Version: $PHP_VERSION"
        fi
    fi

    # Check Mautic's console function exists and can be run
    MAUTIC_CONSOLE_CMD="$BIN_DIR/console"
    if ! $PHP_EXEC $MAUTIC_CONSOLE_CMD --version > /dev/null 2>&1; then
        echo "Error: Mautic console is not found or not executable."
        exit 1
    else
        MAUTIC_VERSION=$($PHP_EXEC $MAUTIC_CONSOLE_CMD --version | head -n 1 | awk '{print $2}')
        if [[ -z "$MAUTIC_VERSION" ]]; then
            echo "Error: Unable to determine Mautic version."
            exit 1
        else
            cprint "Detected Mautic Version: $MAUTIC_VERSION"
        fi
    fi

    # Check the directories exist
    if [[ ! -d "$SPOOL_DIR" ]]; then
        echo "Error: Spool directory ($SPOOL_DIR) does not exist."
        exit 1
    fi
    if [[ ! -d "$BIN_DIR" ]]; then
        echo "Error: Bin directory ($BIN_DIR) does not exist."
        exit 1
    fi

    # Check for files in the spool directory
    FILE_COUNT=$(find "$SPOOL_DIR" -maxdepth 1 -type f | wc -l)
    if [[ $FILE_COUNT -eq 0 ]]; then
        cprint "No messages found in mautic spool. Exiting."
        exit 0
    fi
}

# Run the process_args function to check arguments
process_args "$@"

# Run pre-execution checks
pre_run_checks

# Run the main script execution logic
main