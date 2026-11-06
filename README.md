这个插件是用在musescore 3.7中用于渲染古琴标记的，所使用的是https://github.com/neuralfirings/JianZiPu

上面的jianzipu字体（V3.2）。
使用说明和版权说明，具体见说明书和LICENSE。

This plugin is used in MuseScore 3.7 to render Guqin notation marks. It uses the JianZiPu font (V3.2) from https://github.com/neuralfirings/JianZiPu. For usage instructions and copyright information, please refer to the manual and the LICENSE.

不知是这个版本的软件对于字体堆叠渲染的不支持还是什么原因，有些可以完美的渲染出来，有的则不行。由于字库设计时是用空格用来锚定位置的，然后musescore却用来切换。字库设计者虽然给出来用+号的解决办法。但是musescore中却要用回车来渲染，也可能会造成结构上的一些偏差。鉴于这个插件是在win7 64位系统上MuseScore 3.7中开发的，其表现不是很令人满意。或许在win10的musescore4.x版本中能有所突破。

I'm not sure whether this version of the software does not support layered font rendering or whether it is due to some other reason—some marks render perfectly, while others do not. In the font design, the space character is used as a positioning anchor, but MuseScore uses it for switching/advancing instead. Although the font designer provided a workaround using the plus sign (+), in MuseScore one has to use the Enter key for rendering, which may also cause some structural deviations. Given that this plugin was developed on a 64-bit Windows 7 system with MuseScore 3.7, its performance is not very satisfactory. Perhaps there may be some breakthrough in MuseScore 4.x on Windows 10.



