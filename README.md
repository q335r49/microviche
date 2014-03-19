#Textabyss
<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/>
is a **pannable, zoomable plane** for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose but also works well for note taking, planning, margin notes, and brainstorming. It supports both the mouse and keyboard and features a color map. Check out the **[youtube video](http://www.youtube.com/watch?v=xkED6Mv_4bc).**

<dl>
<dt>Installation and Startup</dt>
<dd>**[Download nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim)** (latest version), open vim, and type: <samp>&nbsp;:source [download directory]/nav.vim&nbsp;</samp>. If the latest version is giving major errors, try one of the [older releases](https://github.com/q335r49/textabyss/releases).

Navigate to the **working directory** to be associated with the plane (you only need to do this when you first create it). Press `F10` to bring up a prompt for files. You can try a pattern like <samp>&nbsp;\*.txt&nbsp;</samp>, or you can name a single file and append others as needed.</dd>

<dt>Navigating the plane</dt>
<dd>Once in the plane, move around by dragging the mouse or by pressing `F10` followed by `←` `↓` `↑` `→` or `h` `j` `k` `l`. Steps are **15 lines** x **1 split** (column). Panning keys take a count: for example, `F10``3``j` is the same as `F10``j``j``j`. The complete list of commands (access by pressing `F10` first) is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l`| ← ↓ ↑ → | | `F1` [1] | *help*
`y``u``b``n`| ↖ ↗ ↙ ↘  ||`A` `D` |*append / delete split*
`r` | *redraw*    | | `R` `L` [2] |*reformat / insert label*
`o` | *open map* | | `Ctrl-X`| *delete hidden buffers*
`.` | *snap to map grid* | |`q` `esc` | *abort*
`S` [3] | *edit settings* | |`W` [4]| *write plane to file*
[1] The help pager will also display warnings about possibly problematic settings.  
[2] See **Reformating** below.  
[3] If the hotkey (default `F10`) becomes inaccessible, <samp>:call TXBinit()</samp> and press `S` to change.  
[4] The last used plane is also saved in the viminfo and suggested on `F10` the next session.
</dd>

<dt>Using the map</dt>
<dd>Press `F10``o` to access the map. Each map cell corresponds to **45 lines** x **1 split** (column) in the plane. As above, you can navigate with the mouse or via (optionally count-prefixed) `←` `↓` `↑` `→`, `h` `j` `k` `l`. The complete list of commands in map mode is:

Mouse [1] | Action | | Mouse | Action
--- | --- | --- | --- | ---
`click`|*select block*||`click``click`|*goto block*
`drag` | *pan* | | `drag` to top left corner [2] | *(in plane) show map*
`click` top left corner|*exit map*|||
[1] gVim does not support the mouse in map mode.  
[2] 'Hot corners' only work when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`h``j``k``l` | ← ↓ ↑ → | | `c` | *change label (see below)*
`y``u``b``n` | ↖ ↗ ↙ ↘  | | `g` `enter` | *goto block* 
`0` `$` | *start / end of row* | | `I` `D` | *insert / delete and obtain column*
`H` `M` `L` | *high / middle / low row* | | `Z` | *adjust map block size (Zoom)*
`x` | *clear and obtain cell* | | `T` | *toggle color*
`o` `O` | *obtain cell / column*| | `F1` |*help*
`p` `P` | *put obtained after / before*| |`q` `esc`|*quit*

<dt>Label color and position
<dd>When `c`hanging a label in the map, you're also prompted for a (optional) highlight group and (optional) position. You can press `tab` at the highlight prompt for auto-completion from the list of currently defined highlights.

Positioning commands can move the cursor and the split from their default positions (top left corner and leftmost split, respectively). For example, say you want to label a heading that occurs 20 lines down the block. You can center the split and position the cursor at the heading via <samp>&nbsp;C20j</samp>. When movement is defined for a block, `F10``.` *snap to grid* will perform that movement. The complete syntax is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
<samp>j k l</samp>|*cursor down / up / right*| |<samp>W</samp> [1] | *virtual split width*
<samp>r R</samp>|*shift view down / up 1 row*| |<samp>M</samp> | *center cursor vertically (ignore* <samp>r R</samp>*)*
<samp>s</samp>|*shift view left 1 split*| |<samp>C</samp> | *center split horizontally (ignore* <samp>s</samp>*)*
[1] By default, <samp>s</samp> will not shift the split offscreen, regardless of count. But specifying, eg, <samp>15W</samp> would allow <samp>s</samp> to shift all but 15 columns offscreen. Likewise, <samp>15WC</samp> would center the split as though it were of width 15.
</dd>

<dt>Reformating</dt>
<dd><samp>txb[:line num][: label#highlght#position]</samp></dd>
<dd>Lines of the above form are considered labels. `R`eformat, in addition to `r`edrawing, will:  
(1) move labels to <samp>line num</samp> by inserting or removing immediately preceding blank lines  
(2) remap the region unless autolabeling conflicts with a preexisting user label. (Details: automatic labels are marked internally by a trailing <samp>A</samp> in the position syntax, eg, <samp>autolable##CMA</samp>. Note that for autolabels, the initial position has the label line, which is what you would expect. For example <samp>txb:: Label##CM</samp> would center the *label line* and not the first line of of the plane associated with that map cell.)</dd>
<dd>Examples:  
<samp>&nbsp;txb:345 Blah blah&nbsp;&nbsp;&nbsp;</samp>*move to 345*  
<samp>&nbsp;txb:345: Blah blah&nbsp;&nbsp;</samp>*move to 345, label map 'Blah blah'*  
<samp>&nbsp;txb: Blah#Title#CM&nbsp;&nbsp;</samp>*label 'Blah', highlight 'Title', position 'CM'*  
<samp>&nbsp;txb: Blah blah##CM&nbsp;&nbsp;</samp>*label 'Blah blah', position 'CM'*
<samp>&nbsp;txb: Blah###Ignored&nbsp;</samp>*label 'Blah'*
<dd>The string <samp>TxbReformatLog</samp> contains a list of chances and errors made. Some examples:  
<samp>&nbsp;move 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*In split 15, line 78 was moved to line 70*  
<samp>&nbsp;labl 15 78 Blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Line 78 of split 15 was labeled 'Blah'*  
<samp>&nbsp;EMOV 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Move failed; not enough blank lines to remove*  
<samp>&nbsp;EOCC 15 78 Blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Label failed; cell already occupied by user label*  
<samp>&nbsp;ECNF 15 78 Blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Label failed; multiple autolabels for one cell*  


</dd>
<dt>Toggling Scrollbind</dt>
<dd>You can turn off global scrollbind (so the plane becomes a list of independently scrolling articles) by changing the <samp>autoexe</samp> value: open up the settings interface by pressing `F10``S`, and `c`hange the <samp>autoexe</samp> from its default of <samp>se nowrap scb cole=2</samp> to <samp>se nowrap **no**scb cole=2</samp>. Press `S` to save. When prompted whether to retroactively apply to existing splits, input <samp>y</samp>.</dd>

####Tips
* Editing the **save file** you `hotkey``W`rote is an easy way to modify settings.
* `hotkey``F1` help also gives **warnings** specific to your vim setup.
* Vim can't scroll past the end of a split, so scrolling may jump when moving away from the end of a **long split**. One solution might be to pad blank lines to the end of every split so that you are rarely working past the end of a split, ie, so that the working region is mostly a large rectangle. It might be helpful, in that case, to remap `G` in vim's normal mode [to go to the next non-blank line](https://github.com/q335r49/textabyss/wiki/G-gg-remappings) rather than the very last line.
* **Redrawing on zoom** (via <samp>:au VimResize</samp>) is disabled for gVim because of the frequency and unpredictability of when resizing occurs. Redrawing will have to be done manually with `F10``r`. Alternatively, you can set up a scheme to automatically redraw via <samp>:call TXBdoCmd('r')</samp>, for example, whenever you change your font. (Incidentally, all keyboard commands can be accessed via the <samp>TXBdoCmd(key)</samp> function.)
* **Horizontal splits** aren't supported and may interfere with panning.
