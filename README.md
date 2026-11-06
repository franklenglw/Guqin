古琴减字面板工具 V3.7 — 使用说明书
Guqin JianZiPu Panel Tool V3.7 — User Manual

一、这是什么 / What Is This

本插件是一个 MuseScore 3 的停靠面板插件，用于在音符下方快速输入、修改、删除"古琴减字谱"标记。所有标记统一使用 JianZiPu 字体渲染，并以文本框（Staff Text）的形式挂在音符上。
This plugin is a dock panel for MuseScore 3. It lets you quickly insert, edit and delete Guqin JianZiPu (tablature) marks below notes. All marks are rendered with the JianZiPu font and attached to notes as Staff Text elements.

一个标记就是一段"代码"，例如 s9k3 表示"名九勾三"。插件负责把你的代码变成谱面上的减字图形。
Each mark is a piece of "code", e.g. s9k3 means "Ring finger, 9th hui, gou (hook) on 3rd string". The plugin turns your code into the graphic on the score.

二、安装 / Installation

将插件文件夹放入 MuseScore 的插件目录（Windows 通常是 文档/MuseScore3/Plugins），重启 MuseScore，在菜单 插件 → 插件管理器 中启用本插件即可。
Put the plugin folder into your MuseScore plugin directory (on Windows usually Documents/MuseScore3/Plugins), restart MuseScore, then enable it in Plugins → Plugin Manager.

若要正确显示减字，请先安装 JianZiPu 字体到系统字体目录。若本发行版随附了字体文件，请一并安装。
To display the marks correctly, install the JianZiPu font into your system font directory first. If this distribution bundles the font file, install it as well.

三、界面说明 / Interface

面板从上到下依次为：标题、操作按钮行（读取 / 输入框 / 修改 / 删除）、提示文字、一键删除全部按钮、搜索行（搜索框 / 清空 / 计数）、代码列表。
From top to bottom the panel contains: the title, the action row (Read / input box / Apply / Delete), the hint text, the "Delete All" button, the search row (search box / Clear / counter), and the code list.

各按钮含义如下：
The buttons are as follows:

- 读取 (Read)：读取当前选中音符上已有的全部标记代码，填入输入框。
  Read: reads all existing mark codes on the currently selected note into the input box.
- 输入框 (Input Box)：显示 / 编辑代码，多个标记用分号 ; 分隔。
  Input Box: shows / edits codes; separate multiple marks with a semicolon ;.
- 修改 (Apply)：把输入框里的代码写回当前音符，覆盖原有标记。
  Apply: writes the codes in the input box back to the current note, overwriting existing marks.
- 删除 (Delete)：删除当前音符上的全部标记。
  Delete: removes all marks on the current note.
- 一键删除全部 (Delete All)：删除整份乐谱中所有本插件生成的古琴标记（只算一次撤销）。
  Delete All: removes every Guqin mark created by this plugin in the whole score (counts as a single undo step).

四、基本流程 / Basic Workflow

① 用鼠标点选一个音符；② 点"读取"看看它已有多少标记；③ 在输入框里编辑代码（多个用 ; 分隔）；④ 点"修改"。
① Click a note; ② press Read to see its existing marks; ③ edit the codes in the input box (separate with ;); ④ press Apply.

若想新增标记，可以直接在搜索框里搜索、在列表里点击条目，插件会自动追加到当前音符下方，不会覆盖已有标记。
To add a mark, you can also search in the search box and click a list item; the plugin appends it below the current note without overwriting existing marks.

【重要操作提示 / Important Notes】
1. 列表并非全部：搜索框下方的列表仅列出了【常用标记代码】。如果你知道其他代码，可以直接在“输入框”中手动敲入代码（多个用 ; 分隔），然后点“修改”即可生效。
   List is not exhaustive: The list below the search box contains only common mark codes. If you know other codes, you can type them directly into the Input Box (separate with ;) and click Apply.
2. 位置修复技巧：在删除部分标记后，如果直接点击列表添加新标记，新标记的位置可能会发生偏移（偏离音符）。此时，只需再点击一次“修改（Apply）”按钮，插件就会重新整理当前音符上所有标记的纵向位置，使其完美对齐。
   Position fix tip: After deleting some marks, if you add a new mark by clicking a list item, its position may be offset. In this case, simply click the "Apply" button again, and the plugin will re-align and fix the vertical positions of all marks on the current note.

五、代码语法规律 / Code Syntax Rules

代码分为三类：指法标记（无前缀）、泛音标记（fy 前缀）、复合/特殊标记（大写字母前缀或以 : 开头）。列表里每条都写成"中文说明 ｜ 代码"，以 ｜ 左边为搜索用说明文字，右边为实际代码。
Codes fall into three groups: fingering marks (no prefix), harmonic marks (fy prefix), and compound/special marks (uppercase prefix or starting with :). Each item in the list is written as "Chinese description ｜ code"; the text left of ｜ is for searching, the text right of it is the actual code.

1. 左右手基本指法 / Basic Left- and Right-Hand Fingering
左手名指前缀（指法名）：
Left-hand finger prefixes:
s = 名指 (Ring finger)
v = 大指 (Thumb)
d = 中指 (Middle finger)
f = 食指 (Index finger)
x = 跪指 (Kneeling finger)
0 = 散音 (Open string, no left hand)

右手八法（末位字母）：
Right-hand eight methods (trailing letters):
n = 劈 (Pi, outward)
h = 托 (Tuo, inward)
j = 抹 (Mo)
u = 挑 (Tiao)
k = 勾 (Gou)
i = 剔 (Ti)
l = 打 (Da)
o = 摘 (Zhai)
U = 历 (Li, sweep)

2. 徽位与弦号 / Hui Position and String Number
徽位用数字表示（七 = 7），弦号写在逗号之后；省略弦号表示"该徽位但不标弦"。
The hui position is a number (7 = seventh hui); the string number follows a comma. Omitting the string means "position only, no string shown".
- s9k3 → 名九勾三 / Ring finger, 9th hui, gou on string 3
- s7,6 → 名七,六 / Ring, 7th hui, string 6
- s76 → 名七六（无弦号）/ Ring, 7th hui, no string
- s13+u6 → 名外挑六（13 徽之外）/ Beyond 13th hui, tiao on string 6

3. 复合右手指法 / Compound Right-Hand Methods
用两个小写字母连写：ju 抹挑、ki 勾剔、lo 打摘；例：0ju5 散抹挑五。
Two lowercase letters combined: ju (mo-tiao), ki (gou-ti), lo (da-zhai); e.g. 0ju5 = open string, mo-tiao on string 5.

4. 左手装饰音 / Left-Hand Ornaments
在徽位后加符号：/ 绰、> 急、\ 注、V 掩；例：s9/k3 名九绰勾三、s9V6 名九掩六。
A symbol after the hui position: / chuo (slide up), > ji, \ zhu (slide down), V yan (stopped); e.g. s9/k3 and s9V6.

5. 泛音 / Harmonics
以 fy 开头：fys9k6 泛音名九勾六、fyv8,5 泛音大八五。
Starts with fy: fys9k6 (harmonic, ring finger, 9th hui, gou on 6) and fyv8,5.

6. 撮、拨剌、双弹 / Cuo, Bola, Shuangtan
大写前缀：C 撮、DC 大撮、BL 拨剌、TT 双弹。组合音用 | 分隔两段，如 Cv9, 6|03。
Uppercase prefixes: C (cuo), DC (da cuo), BL (bola), TT (shuangtan). Combined notes use | between the two parts, e.g. Cv9, 6|03.

7. 特殊符号 / Special Symbols
以冒号 : 开头，符号名为拼音：:shang79 上七九、:xia62 下六二、:fenkai 分开、:fanqi 泛起、:fanzhi 泛止、:gunfu 滚沸、:changyin 长吟、:xiyin 细吟、:dingyin 定吟、:xiaoyin 小吟、:daiqi 带起、:duiqi 对起、:zhuaqi 抓起、:pieqi 撇起、:jin 进、:tui 退、:fu4 复、:zhuang 撞、:yinghe 应合、:tang 淌、:daxi 大息、:shaoxi 少息。
Starts with a colon : followed by the pinyin name: :shang79 (up to 7.9), :xia62, :fenkai, :fanqi, :fanzhi, :gunfu, :changyin, :xiyin, :dingyin, :xiaoyin, :daiqi, :duiqi, :zhuaqi, :pieqi, :jin, :tui, :fu4, :zhuang, :yinghe, :tang, :daxi, :shaoxi.

六、多个标记的排列 / Multiple Marks

同一音符上的多个标记从上到下依次排列，间距固定。读取后输入框会显示为 代码1; 代码2; 代码3。修改时按顺序一一对应：输入框里第 1 个代码替换原第 1 个标记，多余的会追加到下方，少于原有的会删除多余的。
Multiple marks on the same note stack from top to bottom at fixed spacing. After reading, the input box shows code1; code2; code3. On Apply they are matched one-to-one by order: the 1st code replaces the 1st mark, extra codes are appended below, and missing ones cause the surplus marks to be deleted.

所有标记默认强制左右居中（offsetX = 0），避免标记与音符错位。
All marks are forced horizontally centered (offsetX = 0) to avoid misalignment with notes.

七、搜索 / Search

在搜索框输入关键词即可过滤列表，支持中文和代码混合搜索；多个关键词用空格分隔，需同时包含（AND 逻辑）才会显示。例如输入 散 挑 会筛出所有同时含"散"和"挑"的条目。
Typing in the search box filters the list; both Chinese and code are searchable. Separate multiple keywords with spaces; an item is shown only if it contains all keywords (AND logic). For example 散 挑 lists everything containing both "散" and "挑".

在搜索框按回车会直接插入第一条结果到当前音符。点"清空"重置搜索。
Pressing Enter in the search box directly inserts the first result onto the current note. Press Clear to reset the search.

八、一键删除全部 / Delete All

点击"一键删除全部古琴标记"按钮，插件会扫描所有谱表、所有声部，找出字体为 JianZiPu 的全部文本标记并一次性删除。此操作只记录为一次撤销，按一次 Ctrl+Z 即可全部恢复。
Clicking "Delete All Guqin Marks" scans every staff and every voice, finds all text marks using the JianZiPu font, and removes them in one go. This is recorded as a single undo step, so one Ctrl+Z restores everything.

注意：只会删除字体名为 JianZiPu 的文本，其他普通谱表文字不会被误删；反过来说，如果你手动改过标记的字体，它就不会被识别。
Note: only text using the JianZiPu font is removed, so ordinary staff text is safe; conversely, if you manually changed a mark's font, it will not be recognized.

九、外观参数 / Appearance Parameters

在插件源码顶部可以调整：markFont（字体名，默认 JianZiPu）、markFontSize（字号，默认 12）、markLineSpacing（行距，默认 1.2）、markOffsetY（第一个标记距音符高度，默认 3.5）、markStackSpacing（相邻标记间距，默认 2.0）。
At the top of the source you can adjust: markFont (default JianZiPu), markFontSize (default 12), markLineSpacing (default 1.2), markOffsetY (height of the first mark, default 3.5), and markStackSpacing (gap between stacked marks, default 2.0).

十、常见问题 / FAQ

Q：标记显示成方块或乱码？
A：系统未安装 JianZiPu 字体，请安装字体后重启 MuseScore。
Q: Marks show as boxes or gibberish?
A: The JianZiPu font is not installed. Install it and restart MuseScore.

Q：删除时提示"没有找到可删除的古琴标记"？
A：说明谱面中没有字体为 JianZiPu 的文本；请检查标记是否为手动添加的其他字体。
Q: "Delete All" says no marks were found?
A: There are no texts using the JianZiPu font in the score; the marks may have been added manually with another font.

Q：读取后再点修改，顺序乱了？
A：插件按 offsetY 从上到下排序，请勿手动拖动标记的纵向位置；若位置被改动，可先"删除"再重新"修改"。
Q: After Read then Apply, the order is scrambled?
A: The plugin sorts by offsetY from top to bottom. Do not drag marks vertically; if positions were changed, Delete and re-Apply.

Q：多声部谱表里标记会串到别的声部吗？
A：读取、修改、删除都以"当前音符所在的谱表 + 声部"为范围，不会影响其他声部；只有"一键删除全部"会覆盖全谱。
Q: Will marks leak into other voices in multi-voice staves?
A: Read, Apply and Delete operate only on the current note's staff + voice; only "Delete All" affects the whole score.
