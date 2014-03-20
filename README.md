<p align="center">
<img hspace='20' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/>
</p>

####Textabyss lets you pan and zoom through text archives.

It is implemented in **[Vim](http://www.vim.org)** script and has great mouse support and automatic mapping. Check out the **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Installation and Startup
1. **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open Vim, and <samp>:source [download dir]/nav.vim</samp>
1. (Only necessary when creating a plane) Switch to the **working directory** via <samp>:cd</samp> 
1. Evoke a file prompt with `F10`. You can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Navigating
Once in the plane, move around by dragging the mouse or by pressing `F10` followed by `←` `↓` `↑` `→` or `h` `j` `k` `l`. Steps are **15 lines** x **1 split** (column). Panning keys take a count: for example, `F10``3``j` is the same as `F10``j``j``j`. The complete list of commands (access by pressing `F10` first) is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l`| ← ↓ ↑ → | | `F1` [1] | *help*
`y``u``b``n`| ↖ ↗ ↙ ↘  ||`A` `D` |*append / delete split*
`r` `R` [2]| *redraw / redraw & remap* | | `L` [2] | insert label*
`o` | *open map* | | `Ctrl-X`| *delete hidden buffers*
`.` | *snap to map grid* | |`q` `esc` | *abort*
`S` [3] | *edit settings* | |`W` [4]| *write plane to file*
1. The help pager will also display warnings about possibly problematic settings.  
2. See [Automapping](#automapping) below.  
3. If the hotkey (default `F10`) becomes inaccessible, <samp>:call TXBinit()</samp> and press `S` to change.  
4. The last used plane is also saved in the viminfo and suggested on `F10` the next session.

####Labeling the map
Press `F10``o` to access the map. Each map cell corresponds to **45 lines** x **1 split** (column) in the plane. As above, you can navigate with the mouse or via (optionally count-prefixed) `←` `↓` `↑` `→`, `h` `j` `k` `l`. The complete list of commands in map mode is:

Mouse [1] | Action | | Mouse | Action
--- | --- | --- | --- | ---
`click`|*select block*||`click``click`|*goto block*
`drag` | *pan* | | `drag` to top left corner [2] | *(in plane) show map*
`click` top left corner|*exit map*|||
1. gVim does not support the mouse in map mode.  
2. 'Hot corners' only work when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`h``j``k``l` | ← ↓ ↑ → | | `c` | *change label (see below)*
`y``u``b``n` | ↖ ↗ ↙ ↘  | | `g` `enter` | *goto block* 
`0` `$` | *start / end of row* | | `I` `D` | *insert / delete and obtain column*
`H` `M` `L` | *high / middle / low row* | | `Z` | *adjust map block size (Zoom)*
`x` | *clear and obtain cell* | | `T` | *toggle color*
`o` `O` | *obtain cell / column*| | `F1` |*help*
`p` `P` | *put obtained after / before*| |`q` `esc`|*quit*

####Label color and position
When `c`hanging a label in the map, you're also prompted for an optional highlight group and optional position. You can press `tab` at the highlight prompt to auto-complete from currently defined highlights.

Positioning commands move the cursor and the split from their initial position at the top left corner and leftmost split, respectively. For example, say you want to label a heading that occurs 20 lines down the block. You can center the split and position the cursor at the heading via <samp>&nbsp;C20j</samp>. When movement is defined for a grid, `F10``.` *snap to grid* will perform that movement. The complete syntax is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
<samp>j k l</samp>|*cursor down / up / right*| |<samp>W</samp> [1] | *virtual split width*
<samp>r R</samp>|*shift view down / up 1 row*| |<samp>M</samp> | *center cursor vertically (ignore* <samp>r R</samp>*)*
<samp>s</samp>|*shift view left 1 split*| |<samp>C</samp> | *center split horizontally (ignore* <samp>s</samp>*)*
1. By default, <samp>s</samp> will not shift the split offscreen, regardless of count. But specifying, eg, <samp>15W</samp> would allow <samp>s</samp> to shift all but 15 columns offscreen. Likewise, <samp>15WC</samp> would center the split as though it were of width 15.

####Automapping
`R`edraw operates on all visible splits. When it encounters a line of the form:

<samp>txb[:line num][: label#highlght#position]</samp>

1. the line is moved to <samp>line num</samp> by inserting or removing immediately preceding blank lines
1. the label is inserted into the map unless it conflicts with a preexisting user label. (Details: automatic labels are marked internally by a trailing <samp>A</samp> in the position syntax, ie, <samp>label##CMA</samp>. Note that the initial position when evaluating syntax is the label line and not the first line of the map grid, which is what you would expect.)

Possible labels:  
<samp>&nbsp;txb:345 Blah blah&nbsp;&nbsp;&nbsp;&nbsp;</samp>*move to 345*  
<samp>&nbsp;txb:345: Blah blah&nbsp;&nbsp;&nbsp;</samp>*move to 345, label map 'Blah blah'*  
<samp>&nbsp;txb: Blah#Title#CM&nbsp;&nbsp;&nbsp;</samp>*label 'Blah', highlight 'Title', position 'CM'*  
<samp>&nbsp;txb: Blah blah##CM&nbsp;&nbsp;&nbsp;</samp>*label 'Blah blah', position 'CM'*  
<samp>&nbsp;txb: Blah###Ignored&nbsp;&nbsp;</samp>*label 'Blah'*

Possible <samp>:ec TxbReformatLog</samp> entries:  
<samp>&nbsp;move 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*In split 15, line 78 was moved to line 70*  
<samp>&nbsp;labl 15 78 Blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Line 78 of split 15 was labeled 'Blah'*  
<samp>&nbsp;EMOV 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Error: not enough blank lines to remove*  
<samp>&nbsp;EOCC 15 78 Blah bleh&nbsp;</samp>*Error: cell already occupied by user label 'bleh'*  
<samp>&nbsp;ECNF 15 78 Blah bleh&nbsp;</samp>*Error: autolabel 'bleh' was already specified for cell*  


####Tips
1. Editing the **save file** you `hotkey``W`rote is an easy way to modify settings.
* You can **turn off scrollbinding** (so the plane becomes a list of independently scrolling columns) by changing <samp>autoexe</samp>: open `F10``S`ettings and `c`hange <samp>autoexe</samp> from <samp>se nowrap scb cole=2</samp> to <samp>se nowrap noscb cole=2</samp> (make sure to change the setting for the <samp>PLANE</samp> and not the <samp>SPLIT</samp>). `S`ave and input <samp>y</samp> when prompted to apply to all splits.
1. `hotkey``F1` help also gives **warnings** specific to your Vim setup.
1. Vim can't scroll past the end of a split, so scrolling may jump when moving away from the end of a **long split**. One solution might be to pad blank lines to the end of every split so that you are rarely working past the end of a split, ie, so that the working region is mostly a large rectangle. It might be helpful, in that case, to remap `G` in Vim's normal mode [to go to the next non-blank line](https://github.com/q335r49/textabyss/wiki/G-gg-remappings) rather than the very last line.
1. In gVim, **redrawing on zoom** is disabled because of the frequency and unpredictability of when resizing occurs. Redrawing will have to be done manually with `F10``r`. Alternatively, you can set up a scheme to automatically redraw via <samp>:call TXBdoCmd('r')</samp>, for example, whenever you change your font. (Incidentally, all keyboard commands can be accessed via the <samp>TXBdoCmd(key)</samp> function.)
1. **Horizontal splits** aren't supported and may interfere with panning.
