#!/bin/bash

show_menu() {
echo "
|====================MENU=========================
|<To choose option type numer and press enter>
|1. Instruction TicTacToe
|2. Help
|3. New game [PLAYER_1] vs [PLAYER_2]
|4. Load game
|5. Exit
|================================================="
}

show_instruction() {
echo "
|=================INSTRUCTION=====================
|
|-------------------RULES-------------------------
|To win the game, get three of your marks in a row 
|(horizontally, vertically, diagonally).
|-----------------HOW TO PLAY---------------------
|To place a mark, enter the coordinates in the command line in the format:
|<row_number col_number> and press enter.
|During the game, you can use special commands, for example:
|type 'help' and press enter
|================================================"
}

show_commands() {
echo "
|====================COMMANDS=====================
|To use commands write <command_name> then press enter.
|-------------------------------------------------
|Commands available in the game:
|-------------------------------------------------
|info - display the game instruction
|help - displays commands
|save - save the current game
|load - load a saved game
|end - end current game and return to main menu
|exit - exits the program
|================================================="
}
