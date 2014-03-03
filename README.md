#Textabyss
<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/>
is a **pannable, zoomable plane** for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose but also works well for note taking, planning, margin notes, and brainstorming. It supports both the mouse and keyboard and features a color map. Check out the **[youtube video](http://www.youtube.com/watch?v=xkED6Mv_4bc).**

<dl>
<dt>Installation and Startup</dt>
<dd>**[Download nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim)** (latest version), open vim, and type: <samp>&nbsp;:source [download directory]/nav.vim&nbsp;</samp>. If the latest version is giving major errors, try one of the [older releases](https://github.com/q335r49/textabyss/releases).

Press `F10` to bring up the prompt <samp>>&nbsp;Enter file pattern or type HELP:</samp>. You can try typing <samp>&nbsp;\*&nbsp;</samp> for all files in the directory or, say, <samp>&nbsp;plane*&nbsp;</samp>   for a list of files beginning with 'plane'. You can also name a single file and append others as needed.</dd>

<dt>Navigating the plane</dt>
<dd>Once in the plane, move around by dragging the mouse or by pressing `F10` followed by `←` `↓` `↑` `→` or `h` `j` `k` `l`. Steps are **15 lines** x **1 split** (column). Panning keys take a count: for example, `F10``3``j` is the same as `F10``j``j``j`. The complete list of commands (access by pressing `F10` first) is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l`| ← ↓ ↑ → | | `F1` | *help*
`y``u``b``n`| ↖ ↗ ↙ ↘  ||`A` `D` | *append / delete split*
`r`  | *redraw*    | | `E`|*edit split settings* 
`o` | *open map* | | `Ctrl-X`| *delete hidden buffers*
`.` | *snap to map grid* | |`q` `esc` | *abort*
</dd>

<dt>Using the map</dt>
<dd>Press `F10``o` to access the map. Each map cell corresponds to **45 lines** x **1 split** (column) in the plane. As above, you can navigate with the mouse or via (optionally count-prefixed) `←` `↓` `↑` `→`, `h` `j` `k` `l`. The complete list of commands in map mode is:

Mouse | Action | | Mouse | Action
--- | --- | --- | --- | ---
`click`|*select block*||`click``click`|*goto block*
`drag` | *pan* | | `drag` to top left corner | *(in plane) show map*
`click` top left corner|*exit map*|||

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

Positioning commands can move the cursor and the split from their default positions (top left corner and leftmost split, respectively). For example, say you want to label a heading that occurs 20 lines down the block. You can center the split and position the cursor at the heading via <samp>&nbsp;C20j</samp>. Also, when movement is defined for a block, `F10``.` *snap to grid* will perform that movement. The complete syntax is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
<samp>j k l</samp>|*cursor down / up / right*| |<samp>W</samp>__*__ | *virtual split width*
<samp>r R</samp>|*shift view down / up 1 row*| |<samp>M</samp> | *center cursor vertically (ignore* <samp>r R</samp>*)*
<samp>s</samp>|*shift view left 1 split*| |<samp>C</samp> | *center split horizontally (ignore* <samp>s</samp>*)*
\* _By default,_ <samp>s</samp> _will not shift the split offscreen, regardless of count. But specifying, eg,_ <samp>15W</samp> _would allow_ <samp>s</samp> _to shift all but 15 columns offscreen. Likewise,_ <samp>15WC</samp> _would center the split as though it were of width 15._
</dd>

####Troubleshooting
<dl>
<dt>Mouse</dt>
<dd>If the mouse doesn't work, try setting 'ttymouse' to either 'sgr' or 'xterm2' via <samp>&nbsp;:set ttymouse=sgr&nbsp;</samp>. Most other modes except for 'xterm', which is unsupported, should work, but may take a speed penalty. In map mode, only 'sgr', 'xterm2', and 'xterm' will work.
<dt>Directories</dt>
<dd>Since relative paths are used, switching working directories will cause problems. If you find yourself constantly changing working directories, consider adding an autocommand to automatically switch back to the plane directory when in the plane tab. Adding files not in the working directory should be ok.</dd>
<dt>Misaligned splits</dt>
<dd>Scrolling past the end of splits can occasionally cause splits to misalign. You can press `r` to redraw when this happens. Another solution is to pad 500 or 1000 blank lines to the end of every split so that you are rarely working past the end of a split, ie, so that the working region is mostly a large rectangle. It might be helpful, in that case, to remap `G` in vim's normal mode to go to the last non-blank line rather than the very last line -- you can uncomment a line in the source code for this option.</dd>
<dt>BufEnter, BufLeave autocommands</dt>
<dd>If you have autocommands defined *BufEnter* and *BufLeave* (<samp>:autocmd BufEnter</samp> to list), they can be a cause of lagging for plane mouse panning because a single panning step actually has to switch buffers a few times. Consider slimming down those autcommands or using *BufRead* or *BufHidden* instead.</dd>
<dt>Zooming and GVim</dt>
<dd>The VimResize autocommand is disabled for GVim because of the sheer frequency of resizing. Redrawing will have to be done manually with `F10``r`.</dt>
<dt>Horizontal splits</dt>
<dd>Horizontal splits aren't supported and may interfere with panning</dd>
<dl>

####Advanced 
<dt>Anchoring Lines</dt>
<dd>Line anchors address the problem that insertions at a higher lines misalign lower lines. An anchor is a line of the form *txb:line number*, eg, <samp>&nbsp;txb:455&nbsp;</samp>. Re-anchoring starts at the top of the split and tries to restore all displaced anchors by removing or inserting immediately preceding blank lines. If there aren't enough blank lines to remove the process aborts with an error message. The following commands manipulate anchors:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`F10``Ctrl-L` | *insert anchor* | | `F10``Ctrl-A` | *re-anchor split*
</dd>

<dt>Saving and Restoring</dt>
<dd>The script uses the viminfo file to save plane and map data. The option to save global variables in ALL CAPS is set automatically when the script is loaded, via the command <samp>&nbsp;:set viminfo+=!&nbsp;</samp>. The saved plane is then suggested on `F10` the next time you start vim.

To manually save and restore (make sure name is in ALL CAPS):

<samp>&nbsp;&nbsp;&nbsp;:let BACKUP_01=deepcopy(t:txb)&nbsp;"evoke from tab containing plane</samp>  
<samp>&nbsp;&nbsp;&nbsp;:call TXBinit(BACKUP_01)&nbsp;&nbsp;"evoke from anywhere</samp>

Alternatively, you can save a snapshot of the viminfo file, <samp>&nbsp;:wviminfo viminfo-backup-01&nbsp;</samp>, and then restore it by quitting vim and replacing your current viminfo file with the snapshot.</dd>
