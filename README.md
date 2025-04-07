# Tic Tac Toe in Bash (Console Game)

This is a simple yet functional implementation of the classic **Tic Tac Toe** game using Bash. It runs entirely in the terminal and supports features such as saving/loading game states, command-based gameplay, and a basic menu system.

## Features

- Play against another player on the same machine
- Adjustable board size (from 3x3 up to 8x8)
- Game saving and loading
- Game instructions and command help
- Support for in-game commands like `save`, `load`, `end`, and `exit`
- Text-based user interface with clean menu display

## File Overview

- `main.sh` – Entry point with the main menu logic
- `game_functions.sh` – Core game mechanics (input, win conditions, board updates, saving/loading)
- `display_functions.sh` – Functions that display menus, help, and instructions
- `config.sh` – Initializes global variables
- `saves/` – Directory where game saves are stored (created automatically)

## How to Run

Make sure the scripts are executable. From the terminal:

```bash
chmod +x main.sh game_functions.sh display_functions.sh config.sh
./main.sh
