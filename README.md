古琴减字谱编辑器
-------------------------------
这个插件是用在 MuseScore 中用于渲染古琴标记的，支持使用中文或代码来标记，所使用的是（https://github.com/Adrakaris/guqin-jianzipu-font ） 上面的思源琴黑 Noto Qin Jianzipu（字体作者：Adrakaris/Yijun）。
这个减字谱的字体是黑体的，或许有些人更喜欢楷体或者宋体，单独修改这个字体可能需要几天的时间（我用的是Glyphs）。目前先用着吧，如果有需要再说。
最初我选的是另外一款比较好看的楷体字体JianZiPu （作者： Nancy Yi Liang，台湾）（https://jianzipufont.com/ ） （ https://github.com/neuralfirings/JianZiPu ）这个字体使用的造字堆叠的方法可能和思源琴黑略有不同，作者有更多的考量，涵盖了更多的技法，比较成体系。但是，遗憾的是，在musescore 3.6中显示出来的字体有点错乱，原因难明，故而放弃了。
插件已经在 MuseScore 3.7 和 3.6.2 中经过稳定测试。对于 MuseScore 4.x，由于我电脑 Win7 上无法安装 4.x 版本，故未测试。

This plugin is used in MuseScore to render guqin notation symbols. It uses the Noto Qin Jianzipu from (https://github.com/Adrakaris/guqin-jianzipu-font) （Author: Adrakaris/Yijun）.
This Jianzipu font is in a sans-serif (Hei-ti) style, though some people might prefer a Kai (regular script) or Song (serif) style. Modifying or creating this font separately might take a few days (I use Glyphs). For now, let's just stick with the current one and see; we can revisit it later if there's a real need.
Initially, I chose another rather aesthetically pleasing Kai-style font called JianZiPu (Author: Nancy Yi Liang, Taiwan) (https://jianzipufont.com/) （ https://github.com/neuralfirings/JianZiPu ）. The character-stacking method used by this font might be slightly different from Noto Qin Jianzipu (Source Han Qin Hei). The author had more comprehensive considerations, covered a wider range of techniques, and the system was more systematic. However, unfortunately, the font rendered somewhat glitchy in MuseScore 3.6 for unknown reasons, so I gave up on it.
The plugin has been tested for stability in MuseScore 3.7 and 3.6.2. As for MuseScore 4.x, since I cannot install the 4.x version on my Windows 7 computer, it has not been tested.


古琴减字谱编辑器 V5.0（Guqin JianZiPu Editor V5.0）版权说明
---------------------------------------
一、许可声明

本项目（含全部源代码、界面文字、数据结构，以及本项目作者撰写的文档）以 CC0 1.0 Universal（公共领域贡献）协议发布。

在法律允许的最大范围内，本项目作者放弃对本作品的一切著作权及邻接权，包括全部相关权利与诉讼权。

CC0 1.0 全文见：https://creativecommons.org/publicdomain/zero/1.0/legalcode

二、你可以做什么

你可以自由地、无需任何许可地：使用、复制、修改、合并、发布、分发、再许可、出售本作品的原始版本或修改版本。

具体包括，但不限于：
- 在个人、教学、演出、录音、出版等任何场景中使用；
- 用于商业用途（含商业乐谱排版、付费软件集成、商业演出伴奏、外包制谱服务等）；
- 修改代码、增删功能、改换界面、改换字体、改换插件名称与菜单名；
- 将本插件整体或部分嵌入你自己的商业或非商业软件产品中；
- 分发原始版本或修改版本，无论免费或收费；
- 以闭源方式分发你的修改版本。

三、你不需要做什么

- 无需署名：你不必标注原作者、不必保留本说明文件、不必在界面或文档中出现任何致谢。
- 无需开源：你的修改版本可以完全闭源。
- 无需同协议：你不必沿用 CC0，可换成任何你喜欢的许可证（包括专有许可）。
- 无需声明修改：你不必说明你改动了哪些地方。

四、免责声明

本作品按“现状”提供，不附带任何明示或默示的担保，包括但不限于对适销性、特定用途适用性、权利无瑕疵或不侵权的担保。

作者不对因使用或无法使用本作品而产生的任何直接、间接、偶然、特殊、惩戒性或后果性损害承担责任。

使用前请自行备份乐谱。

五、第三方内容说明（重要）

CC0 仅覆盖本项目的代码与文档，不覆盖下列第三方内容，请自行确认其授权：

1. 字体：Noto Qin Jianzipu 字体（思源琴黑，Noto Qin Jianzipu Font）
授权信息：SIL Open Font License 1.1（OFL 1.1）
版权：© 2024 The Noto Qin Jianzipu Project Authors.（Based on Noto Sans SC）
说明：该字体基于思源黑体制作，利用 OpenType 的合字（Ligature）特性实现减字谱的拼装渲染。

【分发声明】本项目的 GitHub 仓库中随插件附带了该字体文件（.otf / .ttf）。根据 OFL 1.1 协议，允许将字体与软件捆绑、嵌入并一起免费分发。

分发时必须遵守的核心条件：
1）附带声明：仓库内包含一个独立的 OFL.txt 文件，其中包含了该字体的版权声明与 OFL 1.1 许可证全文。
2）不得单独售卖：本字体仅作为本插件的辅助组件免费提供，任何人不得将提取出的字体文件单独作为商品出售。
3）修改版改名：若有人修改了字体内部的字形并再次分发，修改版不得使用原保留字体名称（Reserved Font Name），除非获得版权持有人书面许可。仅原样打包分发不受此限制。

2. MuseScore 及其插件 API
属于 MuseScore 项目，遵循其自身的 GPL 等许可，与本项目无关。

3. allItems 标记代码整理
属本项目作者撰写，已随本项目一并进入公共领域。


Guqin JianZiPu Editor V5.0 — Copyright Notice
---------------------------------------
1. License Statement

This project — including all source code, UI text, data structures, and documentation written by the author of this project — is released under CC0 1.0 Universal (Public Domain Dedication).

To the greatest extent permitted by law, the author of this project waives all copyright and related or neighboring rights to this work, including all related claims and causes of action.

The full text of CC0 1.0 is available at: https://creativecommons.org/publicdomain/zero/1.0/legalcode

2. What You May Do

You may freely, without asking permission: use, copy, modify, merge, publish, distribute, sublicense, and sell the original or modified version of this work.

This includes, but is not limited to:
- Use in any scenario, including personal use, teaching, performance, recording, publishing, etc.;
- Use for commercial purposes (including commercial score typesetting, paid software integration, commercial performance accompaniment, outsourced score-making services, etc.);
- Modify the code, add or remove features, change the UI, change fonts, and change plugin names and menu names;
- Embed the plugin, in whole or in part, into your own commercial or non-commercial software products;
- Distribute the original or modified version, whether free of charge or for a fee;
- Distribute your modified version in closed-source form.

3. What You Do Not Have To Do

- No attribution required: You do not have to credit the original author, retain this notice file, or include any acknowledgment in the UI or documentation.
- No open-source requirement: Your modified version may be fully closed-source.
- No same-license requirement: You do not have to use CC0; you may choose any license you like, including a proprietary license.
- No modification disclosure required: You do not have to state what changes you made.

4. Disclaimer

This work is provided “as is,” without any express or implied warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, title, or non-infringement.

The author shall not be liable for any direct, indirect, incidental, special, exemplary, or consequential damages arising from the use of or inability to use this work.

Please back up your scores before use.

5. Third-Party Components (Important)

CC0 covers only the code and documentation of this project. It does not cover the following third-party content. Please verify their licensing yourself.

1. Font: Noto Qin Jianzipu Font (思源琴黑 / Noto Qin Jianzipu Font)
License: SIL Open Font License 1.1 (OFL 1.1)
Copyright: © 2024 The Noto Qin Jianzipu Project Authors. (Based on Noto Sans SC).
Description: This font is based on Noto Sans SC and uses OpenType ligature features to assemble and render jianzipu.

[Distribution Statement] The font files (.otf / .ttf) are bundled with the plugin in this project’s GitHub repository. Under OFL 1.1, the font may be bundled with, embedded in, and freely distributed together with the software.

Core conditions that must be observed when distributing:
1) Include notice: The repository contains a separate OFL.txt file containing the font’s copyright notice and the full text of the OFL 1.1 license.
2) Must not be sold separately: This font is provided free of charge only as an auxiliary component of this plugin. No one may sell the extracted font file as a product on its own.
3) Rename modified versions: If someone modifies the glyphs inside the font and redistributes it, the modified version must not use the original Reserved Font Name unless written permission is obtained from the copyright holder. Mere unmodified bundling and redistribution is not subject to this restriction.

2. MuseScore and its plugin API
MuseScore and its plugin API belong to the MuseScore project and are governed by its own licenses, such as GPL. They are unrelated to this project.

3. The code list in allItems
The code list in allItems was written by the author of this project and has entered the public domain together with this project.


