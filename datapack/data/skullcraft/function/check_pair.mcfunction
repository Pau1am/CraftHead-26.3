# 当前 executor = 一个凋零骷髅头掉落物实体，位置在其自身
# 在半径 1.5 格内寻找一本成书掉落物；找到后以其 written_book_content.title 作为宏源调用 read_book
# title 结构为 {raw:"书名", filtered:"..."}，通过 $(raw) 取到纯字符串
tag @s add skullcraft.skull_here
execute as @e[type=item,nbt={Item:{id:"minecraft:written_book"}},distance=..1.5,limit=1] run function skullcraft:read_book with entity @s Item.components."minecraft:written_book_content".title
tag @s remove skullcraft.skull_here
