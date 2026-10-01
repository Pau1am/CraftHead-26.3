# 每 tick 遍历所有"凋零骷髅头"掉落物实体
# tag 过滤：避免重复触发同一个实体
execute as @e[type=item,nbt={Item:{id:"minecraft:wither_skeleton_skull"}}] at @s run function skullcraft:check_pair
