**\*\* Maps from versions < 1.8 are incompatible (manual mapping has been removed) \*\***

---
#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [downloads]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with `F10`: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Usage
Once loaded, pan with the **mouse** or by pressing `F10` followed by a key command

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l`| ←↓↑→ *(takes count)* | | `F1` | *help and warnings*
`y``u``b``n` | ↖↗↙↘ *(takes count)* ||`A` `D` |*append / delete split*
`r` `R` | *redraw / Remap* | |`o` `O` | *view map / Remap & view*
`L` | *insert* <samp>txb:lnum</samp> ||`Ctrl-X`| *delete hidden buffers*
`S` | *settings* | |`W` | *write to file*
`q` `esc` | *quit*| |`M`| *remap entire plane*

**Map labels** start with [label marker], default <samp>txb:</samp>, and provide a line number, a label, a color, or all three. The general syntax is:

<samp>&nbsp;[label marker][lnum][:][ label[#highlght[#ignored]]]</samp>

Press `f10``R` to **map visible splits**. Displaced labels will be relocated to <samp>lnum</samp>, if provided, by inserting or removing preceding blank lines. If relocation fails the label will be highlighted <samp>ErrorMsg</samp>. Some examples:
- <samp>&nbsp;txb:345 blah blah</samp> - just move to 345
- <samp>&nbsp;txb:345: Intro#Search</samp> - move to 345, label *Intro*, highlight *Search*  
Note the `:` separator, needed only when both <samp>lnum</samp> and <samp>label</samp> are provided.  
- <samp>&nbsp;txb: Intro##blah blah</samp> - just label *Intro*
- <samp>&nbsp;txb: Intro</samp> - just label *Intro*

Once mapped, press `F10``o` to **view the map**:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`click`  `2click` |*select / goto block*||`h``j``k``l`|←↓↑→ *(takes count)*
`drag` | *pan* || `y``u``b``n` |↖↗↙↘ *(takes count)*
`click` NW corner |*exit map*||`H``J``K``L`` |*pan* ←↓↑→ *(takes count)*
`drag` to NW corner | *(in plane) show map* ||`Y``U``B``N` |*pan* ↖↗↙↘ *(takes count)*
`g` `enter`| *goto label*|| `c` |*move cursor to center*
`q` `esc`|*quit* || `z` |*change zoom*

#### Tips
- Movement commands take a **count**, eg, `3``j`=`j``j``j`.
- The **last used plane** is saved in the viminfo and suggested on `F10` the next session.  
- To **turn off scrollbinding**: `F10``S`ettings → `c`hange <samp>autoexe</samp> to <samp>se </samp>**<samp>no</samp>**<samp>wrap noscb cole=2</samp> → `S`ave → `y` at 'apply to all' prompt.  
- **Horizontal splits** will screw up panning.  
- To resolve **labeling conflicts** (multiple labels for one map line), prepend the important one with: `!``"``$``%``&``'``(``)``*``+``,``-``.``/` (in order of priority)
- **gVim** does not support mousing in map mode or automatic redrawing on window or font resize.
- The map **hot corners** only work in the terminal emulator, and when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.
- For the above reasons, a **terminal emulators** is recommended over gVim.
- On **Windows**, [Cygwin](http://www.cygwin.com/) running the bundled [mintty](https://code.google.com/p/mintty/) is recommended.
- If, via `Settings`, you make the the **hotkey inaccessible**, <samp>:call TxbInit()</samp> and press `S` to change.  
