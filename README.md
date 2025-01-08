# Computer_Architecture_Assembly_Project

A mathematics-based memory card game implemented in MIPS assembly language. Players match multiplication equations with their corresponding answers while enjoying interactive sound effects and background music.

##  Game Features

- 4x4 grid of cards containing multiplication equations and answers
- Interactive card flipping with sound effects
- Background music during gameplay
- Timer to track completion time
- Input validation for card selection
- Victory celebration with special sound effects
- Randomized card placement for replayability

##  Audio Features

- Card flip sound effects
- Correct match celebration sounds
- Wrong match indication sounds
- Victory fanfare
- Continuous background music during gameplay

##  Project Structure

```
.
├── main.asm          # Main game loop and initialization
├── cards.asm         # Card generation and management
├── displayBoard.asm  # Board display and UI
├── userInput.asm     # Input handling and validation
├── audio.asm         # Sound effects and music
└── timer.asm         # Game timer functionality
```

##  Gameplay

1. The game presents a 4x4 grid of hidden cards
2. Players input row and column coordinates to flip cards
3. Each turn consists of flipping two cards:
   - If they match (equation matches answer), they remain visible
   - If they don't match, they flip back over
4. Game continues until all pairs are matched
5. Final time taken is displayed upon completion

##  Card Layout

- Grid Size: 4x4 (16 cards total)
- 8 pairs of cards (equation + answer)
- Example pair: "2 x 3" pairs with "6"
- Cards are randomly distributed at game start

##  Input Format

- Row and column input: "row col" (e.g., "2 3")
- Valid input range: 1-4 for both row and column
- Input validation ensures proper format

##  Building and Running

1. Load the program in MARS MIPS simulator
2. Assemble all files
3. Configure the MARS to enable bitmap display and keyboard input
4. Run the program
5. Use the console for input






