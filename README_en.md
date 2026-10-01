# CraftHead-26.3 · Craft Heads

**Working version for Minecraft Java `26.3`** — write a player's name into a book, drop it on the ground together with a wither skeleton skull, and you get that player's head.

> **This is NOT the original author's repository.**
> Gameplay origin: **[zhangshenxing/CraftingPlusPlus](https://github.com/zhangshenxing/CraftingPlusPlus)** → [`other_datapacks/CraftHead`](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead)
> Upstream datapack credited to **ruhuasiyu** (`§6合成头颅(1.14) by ruhuasiyu`, `pack_format: 4`).
> This 26.3 version is maintained by [Pau1am](https://github.com/Pau1am) and is **unofficial**.

---

## How to use

1. Take a **book and quill** and set its title to the **target player's game ID**;
2. **Sign** it (written book);
3. Drop the book and a **wither skeleton skull** on the ground close to each other;
4. The skull turns into that **player's head**.

---

## Why the upstream version cannot be used on 26.3

Upstream `CraftHead` is from the **1.14 era** (`pack_format: 4`). The problem is not just stale metadata — the entire item-data syntax it relies on was **removed in 1.20.5+**:

| Layer | Upstream CraftHead (1.14) | 26.3 |
|---|---|---|
| Metadata | `pack_format: 4` | needs `min_format` / `max_format` = `121` |
| Function dir | `data/cpp/functions/` | renamed to `data/<ns>/function/` |
| Tag dir | `data/minecraft/tags/functions/` | renamed to `data/minecraft/tags/function/` |
| Read book title | `Item.tag.title` (NBT) | `Item.components."minecraft:written_book_content".title` |
| Spawn a specific player head | `tag:{SkullOwner:"name"}` (NBT string) | `components:{"minecraft:profile":"name"}` |

`SkullOwner` and `Item.tag`-style NBT paths were replaced wholesale by the **item component** refactor in 1.20.5, with **no compatibility layer**. So this cannot be ported by editing a few fields — it has to be **reimplemented for 26.3**.

---

## Implementation notes (26.3)

| File | Purpose |
|---|---|
| `data/minecraft/tags/function/tick.json` | hooks `minecraft:tick` |
| `data/minecraft/tags/function/load.json` | hooks `minecraft:load` |
| `data/skullcraft/function/load.mcfunction` | broadcasts a load message to all players |
| `data/skullcraft/function/tick.mcfunction` | iterates every **wither skeleton skull** item entity, hands off to `check_pair` |
| `data/skullcraft/function/check_pair.mcfunction` | looks for a **written book** within 1.5 blocks, then passes the title down via a **datapack macro** |
| `data/skullcraft/function/read_book.mcfunction` | extracts the plain text of the title (`title.raw`) |
| `data/skullcraft/function/do_merge.mcfunction` | spawns the matching player head, plays anvil sound + soul fire particles, consumes inputs |

Key techniques:

- **Datapack macros**: `$function skullcraft:read_book with entity @s Item.components."minecraft:written_book_content".title` — uses `$(raw)` to pass the book title as a function parameter. This capability only exists since 1.20.2; it did not exist in the 1.14 era at all.
- **Entity tagging to prevent re-entry**: a temporary `skullcraft.skull_here` tag stops the same pair of inputs from being processed repeatedly within a tick, and guarantees that exactly *this* skull is removed after merging.
- **Player head resolution**: the `minecraft:profile` component takes a player ID string and the server resolves the skin (upstream used the old NBT string form).
- Adds **anvil sound + soul fire particles** as feedback (upstream had none).

---

## Differences from upstream

| | Upstream CraftHead (1.14) | This version (26.3) |
|---|---|---|
| Metadata | `pack_format: 4` | `min_format` / `max_format` = `121` |
| Namespace | `cpp` | `skullcraft` |
| Function count | 2 (`head/make`, `head/tick`) | 5 (`load` / `tick` / `check_pair` / `read_book` / `do_merge`) |
| Function dir | `functions/` | `function/` |
| Reading title | `Item.tag.title` (NBT) | `written_book_content.title.raw` (component + macro) |
| Spawning head | `tag:{SkullOwner:"name"}` | `components:{"minecraft:profile":"name"}` |
| Feedback | none | anvil sound + soul fire particles |
| Load message | none | yes (`tellraw`) |
| Trigger scope | any written book by `nbt` match | skull-centric, book within 1.5 blocks, entity tag guard |

> The gameplay rule is unchanged: **written book title = target player ID**, paired with a wither skeleton skull.

---

## Installation

1. Download `CraftHead-26.3-v1.0.zip` from [Releases](../../releases);
2. Drop it into `saves/<world>/datapacks/` (or `<server root>/world/datapacks/` on a server);
3. Run `/reload` in game, or verify with `datapack list`.

On success every player sees a green message:

```
[SkullCraft] 已加载：凋零骷髅头 + 署名成书 = 玩家头颅
```

---

## Verification

Verified on a **standalone vanilla 26.3 test server**:

- Cold start: **zero errors, zero warnings**; shows as enabled in `datapack list`;
- `skullcraft:load` / `tick` / `check_pair` / `read_book` / `do_merge` — **all 5 functions parse and run**;
- Macro argument chain works: `read_book` correctly reads `title.raw` from the book component;
- The produced `minecraft:player_head` carries the correct `minecraft:profile` component (i.e. whoever's ID you wrote is whose head you get).

---

## License & credits

The datapack implementation in this repository — i.e. everything under
[`datapack/`](datapack) (`pack.mcmeta` and `data/skullcraft/**`) — is released
under the **MIT License**, see [LICENSE](LICENSE).

- **Gameplay and concept** originate from `CraftHead` by [ruhuasiyu](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead), distributed via the [zhangshenxing/CraftingPlusPlus](https://github.com/zhangshenxing/CraftingPlusPlus) collection. The upstream repository **declares no open-source license**.
- The 26.3 implementation here (the 5 files under the `skullcraft` namespace) shares **no code** with the 1.14 original — the NBT syntax upstream depends on no longer exists in 26.3, making this a from-scratch reimplementation targeting 26.3. The implementation can therefore be licensed independently.
- **If the original author wants this taken down, renamed, or taken over, contact me and I will act immediately.**

---

## Related implementations

Other projects that also turn "wither skeleton skull + book with a player ID" into a player head, but with a **different interaction**:

| Project | Form | Interaction | Target |
|---|---|---|---|
| This repo | datapack | drop both on the **ground** next to each other | 26.3 |
| [Gu-ZT/**CraftingHead**](https://github.com/Gu-ZT/CraftingHead) (Gugle) | Fabric **mod** | use an **anvil**: skull + written book, costs 1 XP level | 26.2 |
| [CraftingPlusPlus / CraftHead](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead) (ruhuasiyu) | datapack | drop both on the **ground** (1.14, no longer runs on 26.3) | 1.14 |

> Note: this pack reads the book's **title**, not its pages — that is the original CraftHead behaviour.
> `Gu-ZT/CraftingHead` instead requires the ID on the **first page body**, so the two are easy to confuse.

---

## Links

- Upstream collection: https://github.com/zhangshenxing/CraftingPlusPlus
- Upstream CraftHead folder: https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead
- Related mod (anvil-based): https://github.com/Gu-ZT/CraftingHead
- 26.3 version (this repo): https://github.com/Pau1am/CraftHead-26.3
