#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [downloads]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with `F10`: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Usage
Once loaded, pan with the **mouse** or by pressing `F10` followed by a key command:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`h``j``k``l``y``u``b``n` | ←↓↑→↖↗↙↘ (takes count) || `F1` | help and warnings
`o` `drag`topleft `O` | open map / remap and open || `A` `D` | append / delete split
`S` `W` | settings / write settings to file || `r` | redraw
`L` | insert <samp>txb:lnum</samp> || `Ctrl-X` | delete hidden buffers
`q` `esc` | quit || `m` `M` | map visible / map all

**Map labels** start with a label marker, default <samp>txb:</samp>, and provide a line number, a label, a color, or all three. The general syntax is:

<samp>[label marker][lnum][:][ label[#highlght[#ignored]]]</samp>

Press `F10``m` to **map visible splits**. Displaced labels will be relocated to <samp>lnum</samp>, if provided, by inserting or removing preceding blank lines. If relocation fails the label will be highlighted <samp>ErrorMsg</samp>. Some examples:
- <samp>txb:345 blah blah</samp> - just move to 345
- <samp>txb:345: Intro#Search</samp> - move to 345, label *Intro*, highlight *Search*  
(Note the `:`, needed only when both <samp>lnum</samp> and <samp>label</samp> are provided.)
- <samp>txb: Intro##blah blah</samp> or <samp>txb: Intro</samp> - just label *Intro*

Once mapped, press `F10``o` to **view the map**:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`h``j``k``l``y``u``b``n` | ←↓↑→↖↗↙↘ (takes count) || `c` | center cursor
`H``J``K``L``Y``U``B``N` | pan || `click` `drag` | select / pan
`g` `enter` `2click` | goto label || `F1` | help
`q` `esc` `click`topleft | quit || `z` | zoom

#### Tips
- When there are **many labels for one map line**, the one prepended with: `!``"``$``%``&``'``(``)``*``+``,``-``.``/` (in order of priority) will be shown.
- **Terminal emulators** work better than gVim since the latter doesn't support mousing in map mode or automatic redrawing on window / font resize (resizing occurs too frequently). [Cygwin](http://www.cygwin.com/) running [mintty](https://code.google.com/p/mintty/) is a great setup for Windows.
- To **turn off scrollbinding**: `F10``S`ettings → `c`hange <samp>autoexe</samp> to <samp>se </samp>**<samp>no</samp>**<samp>wrap noscb cole=2</samp> → `S`ave → `y` at 'apply to all' prompt.
- If you have an **inaccessible hotkey**, <samp>:call TxbKey('S')</samp> for `S`ettings.
