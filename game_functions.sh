#!/bin/bash

handle_command() {
    case $1 in
        "info")
            show_instruction
            ;;
        "help")
            show_commands
            ;;
        "end")
            prompt_save_if_active_game
            echo "End game. Returning to the main menu..."
            game_active=false
            ;;
        "save")
            save_game
            ;;
        "load")
            load_game
            ;;
        "exit")
            echo "Exiting the game..."
            exit 0
            ;;
        *)
            echo "Unknown command. Type 'help' for available commands."
            ;;
    esac
}

prompt_save_if_active_game() {
    if [[ $game_active == true ]]; then
        while true; do
            read -p "Save game (Y/N): " choice
            case $choice in
                [Yy]* )
                    save_game
                    break
                    ;;
                [Nn]* )
                    break
                    ;;
                * )
                    echo "Type 'Y' or 'N'."
                    ;;
            esac
        done
    fi
}

load_game() {
    prompt_save_if_active_game

    echo "=============SAVES==============="
    save_files=($(ls "$SAVES_DIR" 2> /dev/null))
    if [ ${#save_files[@]} -eq 0 ]; then
        echo "No saves."
        return
    fi

    local i=1
    for file in "${save_files[@]}"; do
        file_time=$(date -r "$SAVES_DIR/$file" "+%d/%m/%y %H:%M:%S")
        name="${file%.*}"
        echo "$i. $name $file_time"
        ((i++))
    done

    echo "================================"
    read -p "Enter number: " choice
    let choice=choice-1
    if [[ choice -ge 0 && choice -lt ${#save_files[@]} ]]; then
        filename=${save_files[$choice]}
        save_path="$SAVES_DIR/$filename"
    else
        echo "Invalid selection."
        return
    fi

    if [ ! -f "$save_path" ]; then
        echo "Save file not found."
        return
    fi

    new_game "$save_path"
}

# FIRST NUMBER = BOARD SIZE
# 0 = x
# 1 = o
# -1 = EMPTY
save_game() {
    while true; do
        read -p "Enter file name: " filename

        if [[ $filename == *.txt ]]; then
            save_path="$SAVES_DIR/$filename"
        else
            save_path="$SAVES_DIR/$filename.txt"
        fi

        if [[ -f "$save_path" ]]; then
            echo "File ${filename} already exists."
            read -p "Do you want to overwrite the file? (Y/N): " overwrite
            case $overwrite in
                [Yy]* )
                    break
                    ;;
                [Nn]* )
                    continue
                    ;;
                * )
                    echo "Type 'Y' or 'N'."
                    ;;
            esac
        else
            break
        fi
    done

    echo "$rows" > "$save_path"
    for ((i=0; i<rows; i++ )); do
        for ((j=0; j<cols; j++ )); do
            echo "${matrix[$i,$j]}" >> "$save_path"
        done
    done
}

init_matrix() {
    while true; do
        read -p "Enter the size of the board (3-8): " size
        if [[ $size =~ ^[3-8]$ ]]; then
            rows=$size
            cols=$size
            break
        else
            echo "Invalid size. Please enter a number between 3 and 8."
        fi
    done

    for ((i=0; i<rows; i++ )) do
        for (( j=0; j<cols; j++ )) do
            matrix["$i,$j"]="-1"
        done
    done
}

draw_matrix() {
    for ((i=0; i<rows; i++ )) do
        echo
        for (( j=0; j<cols; j++ )) do
            if [ "${matrix[$i,$j]}" = "1" ]; then
                printf "%5s" "o"
            elif [ "${matrix[$i,$j]}" = "0" ]; then
                printf "%5s" "x"
            else
                printf "%5s" "."
            fi
        done
    done
    echo
}

function make_move() {
    local player=$1
    while true; do
        echo -n "Player $player <row column> or <command>: "
        read input

        if [[ $input =~ ^(info|help|save|load|end|exit)$ ]]; then
            handle_command "$input"
            if [ $game_active == false ]; then
                return
            fi
            draw_matrix
            continue
        fi

        local x y
        IFS=' ' read -r x y <<< "$input"

        ((x--))
        ((y--))

        if [[ $x -lt 0 ]] || [[ $x -ge $rows ]] || [[ $y -lt 0 ]] || [[ $y -ge $cols ]]; then
            echo "Invalid input. Please enter numbers between 1 and $rows, or a command."
            continue
        fi

        if [ "${matrix[$x,$y]}" == "-1" ]; then
            matrix[$x,$y]=$((player-1))
            break
        else
            echo "Position already filled. Re-enter valid position."
        fi
    done
}

# PLAYER_1 WIN = 1, PLAYER_1 WIN = 2, DRAW = 3
function check_winner() {
    local i j winner
    # CHECK WIN ON VERTICAL OR HORIZONTAL
    for ((i=0; i<rows; i++)); do
        for winner in 0 1; do
            local row_win=true col_win=true
            for ((j=0; j<cols; j++)); do
                [[ "${matrix[$i,$j]}" != "$winner" ]] && row_win=false
                [[ "${matrix[$j,$i]}" != "$winner" ]] && col_win=false
            done

            if [[ $row_win == true || $col_win == true ]]; then 
                echo $((winner + 1))
                return
            fi

        done
    done

    # CHECK WIN ON DIAGONAL
    for winner in 0 1; do
        local diag1_win=true diag2_win=true
        for ((i=0; i<rows; i++)); do
            [[ "${matrix[$i,$i]}" != "$winner" ]] && diag1_win=false
            [[ "${matrix[$i,$((rows-i-1))]}" != "$winner" ]] && diag2_win=false
        done

        if [[ $diag1_win == true || $diag2_win == true ]]; then 
            echo $((winner + 1))
            return
        fi
    done

    # DRAW
    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            if [[ "${matrix[$i,$j]}" == "-1" ]]; then
                echo 0
                return
            fi
        done
    done
    echo 3
    return
}

function check_gameover() {
    local result=$(check_winner)
    local message="==============\n>> GAME OVER <<\n"

    case $result in
        1|2)
            local player=$([ $result -eq 1 ] && echo "x" || echo "o")
            message+="> RESULT: $player WINS! <\n"
            game_active=false
            ;;
        3)
            message+="> RESULT: DRAW <\n"
            game_active=false
            ;;
    esac

    if [[ $game_active == false ]]; then
        message+="=============="
        echo -e "$message"
        return
    fi
}

# CALCULATES BASE ON THE INFO THAT x STARTS THE GAME.
function determine_next_player() {
    local count_x=0
    local count_o=0

    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            if [ "${matrix[$i,$j]}" == "0" ]; then
                ((count_x++))
            elif [ "${matrix[$i,$j]}" == "1" ]; then
                ((count_o++))
            fi
        done
    done

    if [ $count_x -le $count_o ]; then
        next_player=1
    else
        next_player=2
    fi
}

new_game() {
    local matrix_data="$1"
    game_active=true
    if [[ -n $matrix_data ]]; then
        readarray -t lines < "$matrix_data"
        rows=${lines[0]}
        cols=$rows
        local index=1
        for ((i=0; i<rows; i++ )); do
            for ((j=0; j<cols; j++ )); do
                matrix["$i,$j"]="${lines[$index]}"
                ((index++))
            done
        done
        determine_next_player
    else
        init_matrix
        next_player=1
    fi

    draw_matrix

    while $game_active; do
        make_move $next_player
        draw_matrix
        echo
        check_gameover
        if [ $game_active == false ]; then
            break 2
        fi

        if [ $next_player -eq 1 ]; then
            next_player=2
        else
            next_player=1
        fi
    done
}
