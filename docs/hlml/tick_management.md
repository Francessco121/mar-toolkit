# Dealing With Game Ticks In HLML

In Much Assembly Required, it is vital that a bot does not spend too much time running code during a single tick. Running too much can result in the game timing out and stopping the bot in the middle of instructions, or causing the bot to run out of battery power.

HLML provides a simple way of 'pausing' the bot with the use of the `sleep` statement. Whenever this statement is encountered, HLML's generated assembly saves the current position in code. When the game enters the next tick and restarts at the beginning of the generated assembly, the code will then check for a saved position, and if one exists, immediately jump to it effectively 'resuming' the code.

## Sleep Example
```c
'sleep' ';'
```

```rust
entry {
    // ... do some stuff

    // Pause and wait for the next tick
    sleep;

    // ... remaining code is running on a second tick
}
```
