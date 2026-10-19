# Battleships MIPS32

A self-playing **Battleships** game written in **MIPS32 assembly**.

The program randomly places a fleet on a 10×10 grid, then plays against itself: it fires at random cells and, as soon as it hits a ship, hunts it down recursively until every ship has been sunk. The grid is redrawn after every shot, so you can watch the game unfold step by step.

---

## Table of contents

- [Requirements](#requirements)
- [Running the program](#running-the-program)
- [How it works](#how-it-works)
- [Grid legend](#grid-legend)
- [Code overview](#code-overview)
- [Authors and license](#authors-and-license)

---

## Requirements

- [**MARS**](https://dpetersanderson.github.io/) (MIPS Assembler and Runtime Simulator), which needs **Java**.

> The program uses syscall **42** (random integer in a range), which is specific to MARS. It will not run as-is on SPIM / QtSpim.

## Running the program

### With the MARS GUI

1. Open `start.s` in MARS.
2. Assemble it (**Run → Assemble**, or `F3`).
3. Run it (**Run → Go**, or `F5`).

The output appears in the *Run I/O* panel at the bottom of the window.

### From the command line

```bash
java -jar Mars4_5.jar nc start.s
```

(`nc` hides the copyright notice; adjust the JAR name to match your MARS version.)

## How it works

### 1. Fleet placement

Five ships are placed at random, each one either horizontally or vertically:

| Ship | Symbol | Size |
|---|---|---|
| Aircraft carrier | `A` | 5 |
| Battleship | `B` | 4 |
| Cruiser | `C` | 3 |
| Submarine | `S` | 3 |
| Destroyer | `D` | 2 |

For each ship, the program draws a random direction and starting cell, then checks that the ship stays inside the grid and does not overlap another one. If the position is invalid, it simply draws a new one.

### 2. The simulated game

The game loop then runs until all **17 ship cells** have been hit:

- **Random shot:** the program picks a random cell. Cells already fired at are skipped.
- **Miss:** the cell is marked with `~`.
- **Hit:** the cell is marked with `X`, and the program immediately **hunts** the ship by recursively firing at the four neighbouring cells (north, east, south, west). Each new hit triggers the same search, so a ship is sunk in one go once it has been found.

This mirrors the classic *hunt and target* strategy used by human players.

### Example output

At the start of a game, the grid shows the fleet before any shot is fired (columns A–J, rows 1–10):

```
  A B C D E F G H I J
1 . . . . . . . . . .
2 . . A A A A A . . .
3 . . . . . . . . B .
4 . S . . . . . . B .
5 . S . . . . . . B .
6 . S . . . . . . B .
7 . . . . . C C C . .
8 . . . . . . . . . .
9 . . . . D D . . . .
10. . . . . . . . . .
```

(Ship positions are random and change on every run.)

## Grid legend

| Symbol | Meaning |
|---|---|
| `.` | Empty water, not yet targeted |
| `A` `B` `C` `S` `D` | Ship cell, not yet hit |
| `~` | Missed shot |
| `X` | Hit ship cell |

## Code overview

Everything lives in a single file, `start.s`. Comments in the source are in French.

| Routine | Role |
|---|---|
| `main` | Initializes the game, displays the grid and starts the simulation. |
| `initPartie` | Clears the grid and places the five ships. |
| `initGrille` | Fills the 100-byte grid with `.`. |
| `setShip` | Picks a random orientation for a ship and delegates to the placement routines. |
| `placeHorizontale` / `placeVerticale` | Draw a random position until a valid one is found, then write the ship into the grid. |
| `verifPlaceHorizontale` / `verifPlaceVerticale` | Check grid bounds and overlaps; return `0` if the placement is valid, `1` otherwise. |
| `simulationJeu` | Main game loop: random shots until 17 hits. |
| `traque` | Fires at a cell and recursively hunts neighbouring cells after a hit. |
| `displayGrille` | Prints the grid with column letters and row numbers. |
| `getModulo` | Computes `a mod b` (and the quotient) by repeated subtraction. |
| `getAleatoire` | Returns a random integer in `[0, n-1]` (syscall 42). |

The grid is stored in the `.data` section as 100 bytes (`grille`), indexed as `row × 10 + column`. Two counters, `nb_tir` (shots fired) and `nb_tirBut` (hits), track the game's progress. Function calls follow the usual MIPS conventions, saving `$ra` and the `$s` registers on the stack, which allows `traque` to call itself recursively.

## Authors and license

Made by **Guillaume Niederlaender** and **Mounir Chargui**.

Released under the [MIT](LICENSE) license.
