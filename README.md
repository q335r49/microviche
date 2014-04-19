**1.8.3 introduces a more efficient but more complex mapping algorithm where the map can be partially redrawn, greatly increasing the speed of mapping for minor edits. (For example, new labels should show up immediately; future versions will remove explicit mapping.) However, if you experience glitchiness, <samp>:call RefreshMap()</samp> to redraw the whole map (and email me if you can reproduce the bug).**

#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Startup
- [Download](https://raw.github.com/q335r49/textabyss/master/nav.vim) nav.vim, open [Vim](http://www.vim.org), and <samp>:source [downloads]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the *working directory* via <samp>:cd [dir]</samp> 
- Evoke a file prompt with <kbd>f10</kbd>: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Usage
Once loaded, pan with the mouse or enter a keyboard command with <kbd>f10</kbd>:

<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | ←↓↑→↖↗↙↘ <sup>(takes count)</sup> || <kbd>f1</kbd> | help and warnings
:---: | :---: | :---: | :---: | :---:
<kbd>o</kbd> | open map || <kbd>A</kbd> <kbd>D</kbd> | append / delete split
<kbd>S</kbd> <kbd>W</kbd> | settings / write settings to file || <kbd>r</kbd> | redraw
<kbd>L</kbd> | insert "[marker]lnum" || <kbd>ctrl</kbd>+<kbd>x</kbd> | delete hidden buffers
<kbd>q</kbd> <kbd>esc</kbd> | quit || <kbd>m</kbd> <kbd>M</kbd> | map visible / map all

**Labels** are lines that start with a label marker (default <q>txb:</q>) and specify a line number, a map label, or both. Displaced labels will be relocated to *lnum*, if provided, by inserting or removing preceding blank lines, and any relocation failures will be highlighted in the map.

The label syntax is: <samp>marker(lnum)(:)( label#highlght# ignored text)</samp>. Some examples:  
&nbsp;&nbsp;&nbsp;txb:345 blah blah → just move to 345  
&nbsp;&nbsp;&nbsp;txb:345<b>:</b> Intro#Search → move to 345: label <q>Intro</q>, color <q>Search</q> (Note the <b>:</b> separator).  
&nbsp;&nbsp;&nbsp;txb: Intro## blah blah (or just txb: Intro) → just label <q>Intro</q>

<kbd>f10</kbd> <kbd>o</kbd> will map all visible splits and open the map:

<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | ←↓↑→↖↗↙↘ <sup>(takes count)</sup> | | <kbd>f1</kbd> | help
:---: | :---: | :---: | :---: | :---:
<kbd>H</kbd> <kbd>J</kbd> <kbd>K</kbd> <kbd>L</kbd> <kbd>Y</kbd> <kbd>U</kbd> <kbd>B</kbd> <kbd>N</kbd> | pan <sup>(takes count)</sup> || <kbd>q</kbd> <kbd>esc</kbd> | quit
<kbd>g</kbd> <kbd>enter</kbd> <kbd>doubleclick</kbd> | goto label || <kbd>c</kbd> | center cursor
 <kbd>click</kbd> <kbd>drag</kbd> | select / pan || <kbd>z</kbd> | zoom

#### Tips
- When there are **many labels for one map line**, the one prepended with: <kbd>!</kbd> <kbd>"</kbd> <kbd>$</kbd> <kbd>%</kbd> <kbd>&</kbd> <kbd>'</kbd> <kbd>(</kbd> <kbd>)</kbd> <kbd>*</kbd> <kbd>+</kbd> <kbd>,</kbd> <kbd>-</kbd> <kbd>.</kbd> <kbd>/</kbd>, in order of priority, will be shown, eg, <q>txb:321: !Important</q>
- **Terminal emulators** work better than gVim since the latter doesn't support mousing in map mode or automatic redrawing on window / font resize. [Cygwin](http://www.cygwin.com/) running [mintty](https://code.google.com/p/mintty/) is a great Windows setup.
- To **disable scrollbinding**: <kbd>f10</kbd> <kbd>S</kbd>ettings→ <kbd>c</kbd>hange <q>autoexe</q> to <samp>se </samp>**<samp>no</samp>**<samp>scb nowrap</samp>→<kbd>S</kbd>ave→apply all
- **Keyboard-free navigation** is possible: dragging to the topleft corner opens the map and clicking the topleft corner closes it. (Terminal emulator only; <samp>ttymouse</samp> must be set to <samp>sgr</samp> or <samp>xterm2</samp>.)
- If you have an **inaccessible hotkey**, <samp>:call TxbKey('S')</samp> for <kbd>S</kbd>ettings.
