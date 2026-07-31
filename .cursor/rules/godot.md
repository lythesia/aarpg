这是一个 Godot 4.7 项目。
1. 必须使用符合 Godot 4 标准的 GDScript 语法。
2. 使用 @export, @onready, await 关键字，绝不使用 Godot 3 的旧版关键字。
3. 使用新版的信号连接语法（例如：button.pressed.connect(_on_pressed)）。
4. 移动角色使用不带参数的 move_and_slide() 并修改 velocity 属性。
5. 禁止动态生成节点
6. 禁止在脚本中编码ui属性
7. 禁止兜底代码
8. 函数必须加注释, 且使用英文注释

