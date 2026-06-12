---
name: godot-mentor
description: Godot 4.x game development mentorship for small playable prototypes, especially projects where Codex should teach rather than directly implement. Use when working on Godot scenes, GDScript, signals, UI, level flow, 2D physics, manual level design, architecture review, or sprint planning with a learning-first workflow.
---

# Godot Mentor

Use this skill for Godot 4.x projects where the goal is to teach, review, and guide implementation rather than automatically write game code.

## Operating Mode

- Read project docs first: `AGENTS.md`, `GDD.md`, `SPRINTS.md`, and `LEARNINGS.md` when present.
- Respect project rules about whether Codex may edit game files. If the project says not to edit scripts/scenes directly, give steps and review instead.
- Prefer small playable increments over large systems.
- Explain the design reason before the technical instruction.
- Give editor paths when relevant: node, Inspector section, signal tab, property, or scene path.
- Keep Godot version in mind. For important engine behavior, verify against official Godot docs for the target version.

## Architecture Defaults

- Use scenes as composition units.
- Keep the main scene responsible for game flow, not for the internals of every object.
- Use signals for decoupled events such as collect, danger, launch, stop, win, fail.
- Avoid autoloads until there is real global state.
- Avoid long `get_node()` chains from high-level controllers. Prefer a small public API on the scene being controlled.
- Keep UI as a view of game state. UI may display and animate; game rules decide.
- Use explicit states when behavior depends on phase: `PLAYING`, `STAGE_CLEARED`, `STAGE_FAILED`, etc.

## Level Scene Pattern

For manual level games, prefer:

```text
Main
  Player
  LevelContainer
  CanvasLayer
    HUD

Level
  Arena
  SlimeStart
  Fruits
    Fruit
  Spikes
    Spike
```

`Main` owns flow:

- instantiate current level;
- restart same level;
- advance to next level;
- decide stage cleared or failed;
- update HUD.

`Level` owns composition:

- start position;
- fruit list;
- spike list;
- initial fruit count;
- remaining fruit count;
- exported configuration such as `max_launches`.

Prefer a `Level` API like:

```gdscript
func get_slime_start_position() -> Vector2
func get_fruits() -> Array[Node]
func get_spikes() -> Array[Node]
func get_total_fruits_count() -> int
func get_remaining_fruits_count() -> int
```

Do not make `Main` repeatedly inspect `Level` internals with hard-coded paths if the level can expose a clearer method.

## Runtime Event Safety

When temporary scenes emit signals to persistent controllers, bind source context:

```gdscript
fruit.collected.connect(_on_fruit_collected.bind(current_level))
spike.player_hit.connect(_on_player_hit.bind(current_level))
```

Then validate:

```gdscript
if source_level != current_level:
	return

if state != State.PLAYING:
	return
```

Use this for levels, waves, rooms, pickups, projectiles, and spawned enemies.

## Player Activation

Separate these concepts:

- control enabled: player can receive input;
- movement reset: velocity and aiming state are cleared;
- physical presence: collision/hitbox can be detected by `Area2D`.

Do not assume `process_mode = PROCESS_MODE_DISABLED` removes physics overlap detection. For `Area2D.body_entered`, reason about `monitoring`, collision shapes, layers, masks, and whether the body is physically present.

Prefer player methods such as:

```gdscript
func set_control_enabled(is_enabled: bool) -> void
func set_active(is_active: bool) -> void
func reset_for_level(start_position: Vector2) -> void
```

This avoids repeating partial reset code in the main scene.

## HUD Pattern

Use:

```text
CanvasLayer
  HUD (Control)
    MarginContainer
      PanelContainer
        MarginContainer
          VBoxContainer
```

HUD should expose simple public methods:

```gdscript
func set_score(value: int) -> void
func set_launches_left(current: int, total: int) -> void
func set_level_number(value: int) -> void
func set_fruits_number(remaining: int, total: int) -> void
func show_result(text: String) -> void
func hide_result() -> void
```

Avoid `scale` for stable UI layout. Prefer anchors, size flags, margins, and containers.

## Review Checklist

Prioritize findings in this order:

- broken flow: win, fail, restart, advance;
- stale state after scene reload;
- signals from removed or wrong-context objects;
- UI owning rules instead of reflecting rules;
- repeated reset or transition code;
- fragile node paths;
- ambiguous names;
- prototype scope creep.

Always include at least one professional improvement point, even when the implementation works.

## Sprint Guidance

- Validate core mechanics before polishing feel.
- Postpone tuning parameters until enough content exists to reveal what needs tuning.
- Add content with intent: each level should test one design question.
- Treat bugs in restart/advance/fail flow as architecture bugs, not polish.
- Record reusable lessons in `LEARNINGS.md`.
