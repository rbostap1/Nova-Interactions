# Nova-Interactions

Standalone FiveM interaction resource for player-to-player roleplay actions.

Included interactions:
- 350+ simple interactions generated from categories and style variants (handshakes, hugs, waves, salutes, nods, cheers, dance, and more)
- Hostage (weapon-gated advanced interaction)

## Features

- Standalone, no framework dependency required
- Request/accept flow for consent-based simple interactions
- Hostage flow with synced animations, control restrictions, and release/execute actions
- Interaction cooldowns and timeout handling
- Basic anti-state-conflict checks on server side
- Fully configurable settings in `config.lua`

## Installation

1. Place this folder in your server resources directory.
2. Ensure the folder name is `Nova-Interactions` (or update `ensure` with your folder name).
3. Add this line to your `server.cfg`:

```cfg
ensure Nova-Interactions
```

4. Restart the resource or server.

## Commands

- `/interact handshake` sends a handshake request to nearest player
- `/interact hug` sends a hug request to nearest player
- `/interact <name>` sends that interaction request to nearest player
- `/interact hostage` attempts to take nearest player hostage
- `/hostage` shorthand for hostage interaction
- `/ia` accept a pending interaction request
- `/id` decline a pending interaction request
- `/interactions` shows all available interaction names in multiple chat lines

## Hostage Controls

Default controls while holding a hostage:
- `G` release hostage
- `H` execute hostage

Control key codes can be changed in `config.lua` under `Config.Hostage.controls`.

## Configuration

Main settings are in `config.lua`:
- `Config.DefaultInteractDistance`
- `Config.RequestTimeoutMs`
- `Config.RequestCooldownMs`
- `Config.SimpleInteractions`
- `Config.Hostage`

To add simple interactions:
1. Add/adjust entries in `interactionTemplates` and `interactionGroups` inside `config.lua`
2. The script auto-generates `Config.SimpleInteractions` from those groups
3. Use `/interactions` to see generated names, then `/interact yourinteractionname`

## Notes

- Hostage requires the aggressor to hold one of the configured weapon names in `Config.Hostage.requiredWeapons`.
- Notification output uses `chat:addMessage`.
- If you use custom HUD/chat systems, you can replace notify behavior in client/server scripts.
