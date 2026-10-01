# 当前 executor = 成书掉落物实体，位置默认为自己
# 宏参数 $(owner) = 头颅所有者名（成书标题）
# 步骤：
#   1. 在当前位置生成一个带对应 profile 的玩家头颅掉落物
#   2. 消除本成书自身
#   3. 消除附近被标记的凋零骷髅头
$summon item ~ ~ ~ {Item:{id:"minecraft:player_head",count:1,components:{"minecraft:profile":"$(owner)"}},PickupDelay:10s}
playsound minecraft:block.anvil.use block @a ~ ~ ~ 1 1.5
particle minecraft:soul_fire_flame ~ ~0.3 ~ 0.2 0.2 0.2 0.02 20
kill @s
kill @e[type=item,nbt={Item:{id:"minecraft:wither_skeleton_skull"}},tag=skullcraft.skull_here,distance=..1.5,limit=1]
