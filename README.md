#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [downloads]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with <kbd>f10</kbd>: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Usage
Once loaded, pan with the **mouse** or by pressing <kbd>f10</kbd> followed by a key command:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | ←↓↑→↖↗↙↘ (takes count) || <kbd>F1</kbd> | help and warnings
<kbd>o</kbd> <kbd>O</kbd> | open map / remap and open || <kbd>A</kbd> <kbd>D</kbd> | append / delete split
<kbd>S</kbd> <kbd>W</kbd> | settings / write settings to file || <kbd>r</kbd> | redraw
<kbd>L</kbd> | insert <samp>txb:lnum</samp> || <kbd>Ctrl</kbd>+<kbd>x</kbd> | delete hidden buffers
<kbd>q</kbd> <kbd>esc</kbd> | quit || <kbd>m</kbd> <kbd>M</kbd> | map visible / map all

**Map labels** start with a label marker, default <samp>txb:</samp>, and provide a line number, a label, a color, or all three. The general syntax is:

<samp>[label marker][lnum][:][ label[#highlght[#ignored]]]</samp>

Press <kbd>f10</kbd> <kbd>m</kbd> to **map visible splits**. Displaced labels will be relocated to <samp>lnum</samp>, if provided, by inserting or removing preceding blank lines. If relocation fails the label will be highlighted <samp>ErrorMsg</samp>. Some examples:
- <samp>txb:345 blah blah</samp> - just move to 345
- <samp>txb:345: Intro#Search</samp> - move to 345, label *Intro*, highlight *Search*  
(Note the <kbd>:</kbd>, needed only when both <samp>lnum</samp> and <samp>label</samp> are provided.)
- <samp>txb: Intro##blah blah</samp> or <samp>txb: Intro</samp> - just label *Intro*

Once mapped, press <kbd>f10</kbd> <kbd>o</kbd> to **view the map**: 

Key | Action | | Key | Action
--- | --- | --- | --- | ---
<kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> <kbd>y</kbd> <kbd>u</kbd> <kbd>b</kbd> <kbd>n</kbd> | ←↓↑→↖↗↙↘ (takes count) || <kbd>c</kbd> | center cursor
<kbd>H</kbd> <kbd>J</kbd> <kbd>K</kbd> <kbd>L</kbd> <kbd>Y</kbd> <kbd>U</kbd> <kbd>B</kbd> <kbd>N</kbd> | pan (takes count) || <kbd>q</kbd> <kbd>esc</kbd> | quit
<kbd>g</kbd> <kbd>enter</kbd> <kbd>2click</kbd> | goto label || <kbd>F1</kbd> | help
 <kbd>click</kbd> <kbd>drag</kbd> | select / pan || <kbd>z</kbd> | zoom

#### Tips
- When there are **many labels for one map line**, the one prepended with: <kbd>!</kbd> <kbd>"</kbd> <kbd>$</kbd> <kbd>%</kbd> <kbd>&</kbd> <kbd>'</kbd> <kbd>(</kbd> <kbd>)</kbd> <kbd>*</kbd> <kbd>+</kbd> <kbd>,</kbd> <kbd>-</kbd> <kbd>.</kbd> <kbd>/</kbd> (in order of priority) will be shown.
- **Terminal emulators** work better than gVim since the latter doesn't support mousing in map mode or automatic redrawing on window / font resize (resizing occurs too frequently). [Cygwin](http://www.cygwin.com/) running [mintty](https://code.google.com/p/mintty/) is a great setup for Windows.
- To **turn off scrollbinding**: <kbd>f10</kbd> <kbd>S</kbd>ettings → <kbd>c</kbd>hange <samp>autoexe</samp> to <samp>se </samp>**<samp>no</samp>**<samp>wrap noscb cole=2</samp> → <kbd>S</kbd>ave → <kbd>y</kbd> at 'apply to all' prompt.
- **Keyboard-free navigation** is possible: dragging to the topleft corner opens the map and clicking the topleft corner closes it. (Terminal emulator only; <samp>ttymouse</samp> must be set to <samp>sgr/<samp> or <samp>xterm2</samp>.)
- If you have an **inaccessible hotkey**, <samp>:call TxbKey('S')</samp> for <kbd>S</kbd>ettings.
