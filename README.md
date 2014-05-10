#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](https://www.youtube.com/watch?v=9YNiPUTGO28)**!

Installation is simple: **[download]**(https://raw.github.com/q335r49/textabyss/master/nav.vim) nav.vim, open [Vim](http://www.vim.org), <samp>:source nav.vim</samp>, and press <kbd>f10</kbd>.

####Commands
Drag the mouse to pan. Access keyboard commands by first pressing <kbd>f10</kbd>:

<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | pan (takes count) || <kbd>f1</kbd> | help and warnings
:---: | :---: | :---: | :---: | :---:
<kbd>r</kbd> <kbd>M</kbd> | redraw visible / all || <kbd>o</kbd> | open map
<kbd>A</kbd> <kbd>D</kbd> | append / delete split || <kbd>L</kbd> | Label <q>(marker)(lnum)</q>
<kbd>S</kbd> <kbd>W</kbd> | settings / save settings || <kbd>q</kbd> <kbd>esc</kbd> | quit

The following commands apply in the map (<kbd>f10</kbd> <kbd>o</kbd>):

<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | move (takes count) || <kbd>f1</kbd> | help and warnings
:---: | :---: | :---: | :---: | :---:
<kbd>H</kbd> <kbd>J</kbd> <kbd>K</kbd> <kbd>L</kbd> <kbd>Y</kbd> <kbd>U</kbd> <kbd>B</kbd> <kbd>N</kbd> | pan (takes count) || <kbd>z</kbd> | zoom
<kbd>g</kbd> <kbd>enter</kbd> <kbd>doubleclick</kbd> | goto label || <kbd>c</kbd> | center cursor
 <kbd>click</kbd> <kbd>drag</kbd> | select / pan || <kbd>q</kbd> <kbd>esc</kbd> | quit
 
####Labels
Labels are lines that start with a label marker (default <q>txb:</q>) and specify a line number, a map label, or both. The map is updated on <kbd>f10</kbd> <kbd>r</kbd>, <kbd>o</kbd>, and <kbd>M</kbd>. If a line number is provided, displaced labels will be restored by inserting or removing immediately preceding blank lines. Relocation failures will be shown as errors in the map.

The syntax is <samp>marker(lnum)(:)( label#highlght#ignored)</samp>, but let's just consider some examples:  
&nbsp;&nbsp;&nbsp;<samp>txb:345 blah blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp> *- just move to 345*  
&nbsp;&nbsp;&nbsp;<samp>txb:345<b>:</b> Intro#Search&nbsp;&nbsp;&nbsp;</samp> *- move to 345: label <q>Intro</q>, color <q>Search</q>* (Note the <b>:</b> separator).  
&nbsp;&nbsp;&nbsp;<samp>txb: Intro&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp> *- just label <q>Intro</q>*  
&nbsp;&nbsp;&nbsp;<samp>txb: Intro## blah blah&nbsp;&nbsp;</samp> *- just label <q>Intro</q>*

####Tips
- To resolve **labeling conflicts**, the case-insensitive alphabetically first label starting with <q>!</q> will be shown, eg, <q>txb:321: !aaaImportant</q>. On cursor-over, the rest will be shown in line number order.
- **Terminal emulators** work better than gVim since the latter doesn't support mousing in map mode or automatic redrawing on window / font resize. [Cygwin](http://www.cygwin.com/) running [mintty](https://code.google.com/p/mintty/) is a great Windows setup.
- To **disable scrollbinding**: <kbd>f10</kbd> <kbd>S</kbd>ettings→ <kbd>c</kbd>hange <q>autoexe</q> to <samp>se </samp>**<samp>no</samp>**<samp>scb nowrap</samp>→<kbd>S</kbd>ave→apply all
- **Keyboard-free navigation** is possible: dragging to the topleft corner opens the map and clicking the topleft corner closes it. (Terminal emulator only; <samp>ttymouse</samp> must be set to <samp>sgr</samp> or <samp>xterm2</samp>.)
- If you have an **inaccessible hotkey**, <samp>:call TxbKey('S')</samp> for <kbd>S</kbd>ettings.
- To **syntax highight labels**, try: <samp>syntax match Title +^txb\S*: \zs.[^#\n]*+ oneline display</samp>
