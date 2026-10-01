# 更新记录 / Changelog

> 一个数据包有两份这个文件：仓库根目录的 `CHANGELOG.md`（本文件），
> 以及**包内自带的** `datapack/CHANGELOG-26.3.md` —— 后者会随 zip 一起分发，
> 保证拿到包的人不用上网也能看到改了什么。

---

## v1.0.2 — 2026-10-01

**修正 v1.0.1 的 LICENSE 文件格式。数据包玩法逻辑仍未改动。**

### 为什么会有 v1.0.2

v1.0.1 的 `LICENSE` 在标准 MIT 正文后面附了一段「说明 / Note」（讲许可证适用范围与创意出处）。
这破坏了 GitHub 对标准许可证文本的匹配——仓库侧栏的 License 显示为 **`NOASSERTION`**（看起来像"未授权"），
会误导来访者。

### 变更

- `LICENSE` 改为**纯标准 MIT 文本**（无附加段落）→ GitHub 正确识别为 **MIT**。
- 原「说明 / Note」中关于**适用范围**的内容（MIT 适用于 `datapack/` 下全部文件）移入
  `README.md` / `README_en.md` 的「许可与致谢」小节，信息未丢失。
- 资产文件名按版本化规范递增为 **`CraftHead-26.3-v1.0.2.zip`**（LICENSE 随包分发，故 zip 内容变化）。
- v1.0 与 v1.0.1 均**保留可下载**，未覆盖。

### 未改动

- `pack.mcmeta` 与 `data/skullcraft/**` 下 5 个函数文件**与 v1.0 / v1.0.1 逐字节相同**。

---

## v1.0.1 — 2026-10-01

**许可证与文档更新。数据包玩法逻辑未改动。**

### 变更

- **新增 `LICENSE`**（MIT，© 2026 Pau1am），并**打进数据包 zip 内**。
  依据 MIT 条款「本版权声明与许可声明应包含在本软件的所有副本或实质性部分中」，
  许可证文本必须随包分发，故重新打包。
- `README.md` / `README_en.md`：补充「许可与致谢」小节，明确本仓库实现以 MIT 发布。
- 新增「相关实现」小节，区分三种同类项目：
  - 本仓库（数据包，**丢在地上**合成，26.3）
  - `Gu-ZT/CraftingHead`（Gugle 的 Fabric **模组**，**铁砧**合成，26.2）
  - `CraftingPlusPlus / CraftHead`（ruhuasiyu，数据包，丢在地上，1.14）
  并说明本包读取的是**书名（title）**，而 Gu-ZT 的模组要求写在**第一页正文**，两者易混淆。

### 未改动

- `pack.mcmeta` 与 `data/skullcraft/**` 下的 5 个函数文件**与 v1.0 逐字节相同**。
- 资产文件名按版本化规范递增为 **`CraftHead-26.3-v1.0.1.zip`**，v1.0 保留可下载。

---

## v1.0 — 2026-10-01

**首个正式发布版（26.3 可用版）。**

### 元数据修正

```diff
 {
   "pack": {
     "description": "凋零骷髅头 + 成书 -> 玩家头颅 (以书名为头颅ID)",
-    "pack_format": 121
+    "min_format": 121,
+    "max_format": 121
   }
 }
```

**为什么要改**：26.3 有一条原版硬规则——`pack_format` 只要 **大于 81**，就必须改用 `min_format` / `max_format`，
否则**每次服务端启动、每次 `/reload`、每次 `datapack list`** 都会刷一段警告 + 长堆栈：

```
Pack declares support for version newer than 81
...
attempting fallback type
```

需要说明的是：**这个报错本身无害**（`attempting fallback type` 表示首次解析失败后回退旧格式元数据，包仍被正常读入，
功能完全不受影响），修掉它只是为了让服务端日志干净。

### 内容

- `skullcraft` 命名空间下 5 个函数文件（`load` / `tick` / `check_pair` / `read_book` / `do_merge`）
  **与修正前逐字节相同**，玩法逻辑一行未动。
- 除 `pack.mcmeta` 外的所有条目均未改动（已逐条目 SHA256 比对确认）。

### 验证

- 原版 26.3 独立测试服：冷启动零报错、零警告。
- 5 个函数全部可解析执行；`datapack list` 显示已启用。
- 三组对照实验（原包 / 改后包 / 另一无问题包）：修正后警告出现次数 **2 → 0**。

---

## 附：本仓库与上游的关系

| | 说明 |
|---|---|
| 玩法来源 | `CraftingPlusPlus` → `other_datapacks/CraftHead`（署名 ruhuasiyu，1.14 版，`pack_format: 4`） |
| 本版实现 | `skullcraft` 命名空间，面向 26.3 的重新实现（上游的 `SkullOwner` / `Item.tag.title` NBT 写法在 1.20.5+ 已被物品组件取代，无兼容层） |
| 代码复用 | **无**。上游 1.14 代码无法在 26.3 运行，故未沿用 |

---

## 版本号约定

本仓库使用 `v<主>.<次>` 标记版本。

- 数值 / 玩法行为调整，或新的 Minecraft 版本适配 → **次版本 +1**（如 `v1.0` → `v1.1`）
- 纯文档 / 注释订正 → 三位版本（如 `v1.0.1`）

更新时**不会覆盖旧文件**：Release 资产名带版本号，历史 zip 始终可下载。
