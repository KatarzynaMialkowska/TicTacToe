#!/bin/bash

SAVES_DIR="saves"
if [ ! -d "$SAVES_DIR" ]; then
    mkdir -p "$SAVES_DIR"
fi

source "./config.sh"
source "./display_functions.sh"
source "./game_functions.sh"

while true;
do
    show_menu
    read -p "Choose an option: " option
    
    case $option in
        1)
            show_instruction
            while true; do
                read -p "Type '0' to return back: " input
                if [[ $input == "0" ]]; then
                    break
                fi
            done
            ;;
        2)
            show_commands
            while true; do
                read -p "Type '0' to return back: " input
                if [[ $input == "0" ]]; then
                    break
                fi
            done
            ;;
        3)
            new_game
            ;;
        
        4)
            load_game
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
