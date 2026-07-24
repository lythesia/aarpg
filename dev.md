## Player FSM

```mermaid
stateDiagram-v2

Idle --> Walk: inst. direction ≠ 0
Walk --> Idle: inst. direction = 0
```

## Z-index

grass(tile): -1
player: 0