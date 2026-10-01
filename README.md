# CraftHead-26.3 · 合成头颅

**Minecraft Java 版 `26.3` 可用版** —— 把玩家名字写进书里，和凋灵骷髅头一起丢在地上，就能合成对应玩家的头颅。

> **本仓库不是原作者仓库。**
> 玩法来源：**[zhangshenxing/CraftingPlusPlus](https://github.com/zhangshenxing/CraftingPlusPlus)** → [`other_datapacks/CraftHead`](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead)
> 上游数据包署名：**ruhuasiyu**（`§6合成头颅(1.14) by ruhuasiyu`，`pack_format: 4`）
> 本仓库是 **26.3** 可用版，由 [Pau1am](https://github.com/Pau1am) 维护，**非官方**。

---

## 玩法

1. 拿一本 **书与笔**，把书名（title）填成**目标玩家的游戏 ID**；
2. **署名**（签名成书）；
3. 把这本书和**凋灵骷髅头**一起丢在地上，让它们靠在一起；
4. 凋灵骷髅头会被替换成**对应玩家的头颅**。

---

## 上游版本在 26.3 上为什么不能直接用

上游 `CraftHead` 是 **1.14 时代**的作品（`pack_format: 4`）。它不只是元数据过老，而是**依赖的整套物品数据写法在 1.20.5+ 已被移除**：

| 层面 | 上游 CraftHead（1.14） | 26.3 现状 |
|---|---|---|
| 元数据 | `pack_format: 4` | 需 `min_format` / `max_format` = `121` |
| 函数目录 | `data/cpp/functions/` | 已改名 `data/<ns>/function/` |
| 标签目录 | `data/minecraft/tags/functions/` | 已改名 `data/minecraft/tags/function/` |
| 读书名 | `Item.tag.title`（NBT） | `Item.components."minecraft:written_book_content".title` |
| 生成指定玩家头颅 | `tag:{SkullOwner:"名字"}`（NBT 字符串） | `components:{"minecraft:profile":"名字"}` |

`SkullOwner` 与 `Item.tag` 这类 NBT 路径在 1.20.5 的**物品组件（item components）** 重构中被整体替换，**没有向后兼容层**。因此本版不可能靠改几个字段完成移植，只能**面向 26.3 重新实现**。

---

## 本版实现要点

| 文件 | 作用 |
|---|---|
| `data/minecraft/tags/function/tick.json` | 挂载 `minecraft:tick` |
| `data/minecraft/tags/function/load.json` | 挂载 `minecraft:load` |
| `data/skullcraft/function/load.mcfunction` | 加载时向全体玩家播报一条提示 |
| `data/skullcraft/function/tick.mcfunction` | 每 tick 遍历所有**凋灵骷髅头掉落物**并交给 `check_pair` |
| `data/skullcraft/function/check_pair.mcfunction` | 在该头颅 1.5 格内寻找**成书**，找到后用**数据包宏**把书名传下去 |
| `data/skullcraft/function/read_book.mcfunction` | 取出书名的纯文本（`title.raw`） |
| `data/skullcraft/function/do_merge.mcfunction` | 生成对应玩家头颅，播放铁砧音效 + 灵魂火粒子，清除原料 |

关键技法：

- **数据包宏（macro）**：`$function skullcraft:read_book with entity @s Item.components."minecraft:written_book_content".title` —— 用 `$(raw)` 把书名当参数传进函数，这是 1.20.2+ 才有的能力，上游 1.14 时代完全不存在。
- **实体标记防重复**：用 `tag skullcraft.skull_here` 给头颅打临时标签，避免同一对原料在一 tick 内被反复处理，也保证合成后精确清除的是**这一个**凋灵骷髅头。
- **玩家头颅解析**：`minecraft:profile` 组件接玩家 ID 字符串，由服务端自行解析皮肤（上游用的是旧 NBT 字符串写法）。
- 合成后附带 **铁砧音效 + 灵魂火粒子**作为反馈（上游没有）。

---

## 与上游的差异一览

| | 上游 CraftHead（1.14） | 本版（26.3） |
|---|---|---|
| 元数据 | `pack_format: 4` | `min_format` / `max_format` = `121` |
| 命名空间 | `cpp` | `skullcraft` |
| 函数数量 | 2（`head/make`、`head/tick`） | 5（`load` / `tick` / `check_pair` / `read_book` / `do_merge`） |
| 函数目录 | `functions/` | `function/` |
| 读取书名 | `Item.tag.title`（NBT） | `written_book_content.title.raw`（组件 + 宏） |
| 生成头颅 | `tag:{SkullOwner:"名字"}` | `components:{"minecraft:profile":"名字"}` |
| 合成反馈 | 无 | 铁砧音效 + 灵魂火粒子 |
| 加载提示 | 无 | 有（`tellraw` 播报） |
| 触发范围 | 任意成书 `nbt` 匹配 | 凋灵骷髅头为准，1.5 格内找成书 + 实体标记防重入 |

> 玩法规则本身未变：**成书标题 = 目标玩家 ID**，与凋灵骷髅头配对合成。

---

## 安装

1. 从 [Releases](../../releases) 下载 `CraftHead-26.3-v1.0.zip`；
2. 放进存档的 `saves/<世界名>/datapacks/`（服务器为 `<服务端根目录>/world/datapacks/`）；
3. 进游戏执行 `/reload`，或用 `datapack list` 确认已启用。

启用成功时，全体玩家会看到一条绿色提示：

```
[SkullCraft] 已加载：凋零骷髅头 + 署名成书 = 玩家头颅
```

---

## 验证

在**原版 26.3 独立测试服**上完成以下验证：

- 冷启动**零报错、零警告**，`datapack list` 显示已启用；
- `skullcraft:load` / `tick` / `check_pair` / `read_book` / `do_merge` **5 个函数全部可解析执行**；
- 宏参数链路可用：`read_book` 能正确从成书组件里取到 `title.raw`；
- 合成产物 `minecraft:player_head` 带正确的 `minecraft:profile` 组件（即"谁的 ID 就出谁的头"）。

---

## 许可与致谢

本仓库的数据包实现——即 [`datapack/`](datapack) 目录下的全部文件（`pack.mcmeta` 与 `data/skullcraft/**`）——
以 **MIT 许可证** 发布，详见 [LICENSE](LICENSE)。

- **玩法与创意** 源自 [ruhuasiyu](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead) 的 `CraftHead`，经 [zhangshenxing/CraftingPlusPlus](https://github.com/zhangshenxing/CraftingPlusPlus) 集合仓库分发。上游仓库**未声明开源许可证**。
- 本版的 26.3 实现（`skullcraft` 命名空间下的 5 个函数文件）与前者的 1.14 代码**没有代码级复用**——因为上游依赖的 NBT 写法在 26.3 已不存在，属于面向 26.3 的重新实现。因此本仓库的实现部分可以独立授权。
- **若原作者希望撤下、改名或接管本仓库，请联系我，我会立即处理。**

---

## 相关实现

同样做「凋灵骷髅头 + 写有玩家 ID 的书 → 玩家头颅」这件事，但**交互方式不同**的其他项目：

| 项目 | 形式 | 交互 | 目标版本 |
|---|---|---|---|
| 本仓库 | 数据包 | 两者**丢在地上**靠在一起自动合成 | 26.3 |
| [Gu-ZT/**CraftingHead**](https://github.com/Gu-ZT/CraftingHead)（Gugle） | Fabric **模组** | 放进**铁砧**：头颅 + 成书，消耗 1 级经验 | 26.2 |
| [CraftingPlusPlus / CraftHead](https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead)（ruhuasiyu） | 数据包 | 两者**丢在地上**（1.14 原版，已无法在 26.3 运行） | 1.14 |

> 顺带一提：本包读取的书名是**书与笔的标题（title）**，不是书页内容——这是 CraftHead 原始玩法。
> `Gu-ZT/CraftingHead` 则要求把 ID 写在**第一页正文**里，两者容易混淆。

---

## 版本记录

见 [CHANGELOG.md](CHANGELOG.md)。

---

## 相关链接

- 上游集合仓库：https://github.com/zhangshenxing/CraftingPlusPlus
- 上游 CraftHead 目录：https://github.com/zhangshenxing/CraftingPlusPlus/tree/master/other_datapacks/CraftHead
- 同概念模组（铁砧版）：https://github.com/Gu-ZT/CraftingHead
- 26.3 版（本仓库）：https://github.com/Pau1am/CraftHead-26.3
