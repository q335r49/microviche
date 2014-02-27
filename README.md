#Textabyss
<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/> ... **is a pannable, zoomable plane** for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose, but it also works well for note taking, planning out projects, margin comments, and brainstorming. It supports both the mouse and keyboard, and features a color map. Check out the **[youtube video](http://www.youtube.com/watch?v=xkED6Mv_4bc).**

**[Install by downloading the latest version of nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim)**, opening vim, and typing <samp>&nbsp;:source [download directory]/nav.vim&nbsp;</samp>. The documentation below is also available within the script by pressing `F10``F1` or `F1` while in map mode.

###Navigating the plane

Press `F10` to bring up the prompt <samp>&nbsp;>&nbsp;Enter file pattern or type HELP:&nbsp;</samp>

You can try typing <samp>&nbsp;\*&nbsp;</samp> for all files in the directory or, say, <samp>&nbsp;plane*&nbsp;</samp>   for a list of files beginning with 'plane'. You can also name a single file and later append additional splits as needed with `F10``A`

Once in the plane, move around by dragging the mouse or by pressing `F10` followed by `←` `↓` `↑` `→` or `h` `j` `k` `l`. The complete list of commands (access by pressing `F10` first) is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l`  | Pan left / down / up / right | |`←``↓``↑``→` | Pan left / down / up / right
`y``u``b``n` | Pan upleft / downleft / upright / downright | | `A` `D` `E` | Append split / Delete split / Edit split
`r`  | Redraw    | | `Ctrl-X`| Delete hidden buffers
`o` | Open map | | `q` `esc` | Abort
`.` | Snap to map grid | | `F1` | Help
_\* Each pan step is **15 lines** and **1 split**. Panning keys take a count, capped at 99. For example,_ `F10``3``j` _is the same as_ `F10``j``j``j`.

###Using the map

Press `F10``o` to access the map. Each map cell corresponds to **45 lines** x **1 split** (column) in the plane. Navigate the map by dragging the mouse or via `←``↓``↑``→` / `h``j``k``l`. The complete list of commands in map mode is:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`h``j``k``l` | Left / right / up / down | | `c` `i` | Change label
`y``u``b``n` | Leftup / leftdown / rightup / rightdown | | `g` `enter` | Goto block and exit map
`0` `$` | Start / end of line | | `I` `D` | Insert / Delete (and obtain) column
`H` `M` `L` | High / Middle / Low of screen | | `Z` | Zoom (adjust map block size)
`x` | Clear (and obtain) cell | | `T` | Toggle color
`o` `O` | Obtain (cell / column)| | `F1` |Help
`p` `P` | Put obtained (after / before)| |`q`|Quit 
_\* The hjklyubn keys take a count, capped at 99. For example,_ `3``j` _is the same as_ `j``j``j`.  

Mouse | Action | | Mouse | Action
--- | --- | --- | --- | ---
`click`|Select block||`doubleclick`|Goto block and exit map
`drag` | Pan | | `drag` to top left corner | (While in plane) Show map
`click` at top left corner|Exit map|||

###Troubleshooting

<dl>
<dt>Mouse problems</dt>
<dd>If the mouse doesn't work, try setting <samp>&nbsp;'ttymouse'&nbsp;</samp> to <samp>&nbsp;sgr&nbsp;</samp> or <samp>&nbsp;xterm2&nbsp;</samp> via <samp>&nbsp;:set ttymouse=sgr&nbsp;</samp>. <samp>&nbsp;xterm&nbsp;</samp> doesn't report dragging and so is unsupported. Other modes should work but might take a speed penalty. Only <samp>&nbsp;sgr&nbsp;</samp>, <samp>&nbsp;xterm2&nbsp;</samp>, and <samp>&nbsp;xterm&nbsp;</samp> are supported in map mode. Note that in map mode mouse clicks are associated with the very first letter of the label (which will never be hidden), so it might be helpful to prepend a marker, eg, <samp>&nbsp;'+ Heading'&nbsp;</samp></dt>
<dt>Directories</dt>
<dd>Ensuring a consistent directory is important because relative names are remembered (use <samp>&nbsp;:cd directory&nbsp;</samp> to switch directories). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory should be ok. If you find yourself constantly needing to swicth directories, consider adding an autocommand (see <samp>&nbsp;:help autocommand&nbsp;</samp>) to switch back to the plane directory when in the plane tab.</dd>
<dt>Misaligned splits</dt>
<dd>When one split is much longer than its neighbors, you can scroll past the end of the other splits. This can occasionally cause the splits to become misaligned. You can press `r` to redraw when this happens. Another solution is to pad 500 or 1000 blank lines to the end of every split so that you are never working at the very end of a particularly long split, ie, so that the working region is mostly a large rectangle. It might be helpful, in that case, to remap `G` in vim's normal mode to go to the last non-blank line rather than the very last line -- you can uncomment a line in the source code for this option.</dd>
<dt>Horizontal splits</dt>
<dd>Horizontal splits aren't supported and may interfere with panning</dd>
<dl>

###Advanced features

####Map syntax

The syntax for map labels is: <samp>&nbsp;Label text#optional color#optional position&nbsp;</samp>. Note that <samp>&nbsp;#&nbsp;</samp> is reserved for this purpose and can never be used in the label itself.

To **color** a label you must specify a highlight group: see <samp>&nbsp;:help highlight&nbsp;</samp> for details. For example, <samp>&nbsp;Danger#WarningMsg&nbsp;</samp> should color the label bright red. Try <samp>&nbsp;:hi&nbsp;</samp> for a list of currently defined highlights.

Specifying **position** is a bit more elaborate. Suppose you want to name a map block after a heading in the text that occurs halfway down the block and is the second column in a larger block of text. You'd like to show the previous split and have the cursor jump straight to the heading, but the default behavior puts the split at the leftmost point and the cursor in the top left corner.

Positioning commands can move the view and the cursor. For example, in the above case we might use <samp>&nbsp;Heading##s20j&nbsp;</samp> to shift the view left one split (<samp>&nbsp;s&nbsp;</samp>) and move the cursor down 20 lines (<samp>&nbsp;20j&nbsp;</samp>). Or perhaps just <samp>&nbsp;Heading##20jCM&nbsp;</samp>: **C**enter that split and scroll so that 20th line is at the **M**iddle of the screen. 

Note that the order of the commands doesn't matter: for example, <samp>&nbsp;Heading##jMjsj&nbsp;</samp>, <samp>&nbsp;Heading##s3jM&nbsp;</samp>, and <samp>&nbsp;Heading##M3js&nbsp;</samp> all do the same thing: shift the view left one split, move the cursor down 3 lines, and vertically center the view. The complete list of commands is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
<samp>j k l</samp>|Cursor down / up / right| |<samp>W</samp> | Virtual split width (see below)
<samp>r R</samp>|Shift view down / up 1 Row| |<samp>M</samp> | Center cursor vertically (override <samp>r R</samp>)
<samp>s</samp>|Shift view left 1 Split| |<samp>C</samp> | Center split horizontally (override <samp>s</samp>)

Specify a virtual width with <samp>&nbsp;W&nbsp;</samp> in order to change the behavior of <samp>&nbsp;s&nbsp;</samp> or <samp>&nbsp;C&nbsp;</samp>. By default, <samp>&nbsp;s&nbsp;</samp> won't move the split off screen but only enough to push the target split to the right edge. However, specifying, for example, <samp>&nbsp;15W&nbsp;</samp> tells the parser to handle the split as though it were 15 columns wide. This would mean that <samp>&nbsp;5s15W&nbsp;</samp> would at most shift up to the point where the split's left border is 15 columns from the right edge of the screen. Likewise, <samp>&nbsp;C&nbsp;</samp> would center the split as though it were of width <samp>&nbsp;W&nbsp;</samp>.

Note that when movement syntax is defined for a block, "Snap to grid" `F10``.` will execute that movement instead.

####Line anchors
Line anchors address the fact that insertions at a higher line misalign lower lines. A line anchor is simply a line of the form <samp>&nbsp;txb:[current line]&nbsp;</samp>, eg, <samp>&nbsp;txb:455&nbsp;</samp>. The realigning process starts from the top of the split and attempts to restore all displaced anchors by removing or inserting blank lines immediately before it. If there aren't enough blank lines to remove an error message will be shown and the process aborted.

After pressing `F10`, the following commands manipulate line anchors:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`Ctrl-L` | Insert line anchor | | `Ctrl-A` | Align anchors in split

####Saving the plane
The script uses the viminfo file to save plane and map data, see <samp>&nbsp;:help viminfo&nbsp;</samp>. The option to save global variables in ALL CAPS is set automatically when the script is loaded via the command <samp>&nbsp;:set viminfo+=!&nbsp;</samp>. The saved plane is then suggested on `F10` the next time you start vim.

To manually save a snapshot, navigate to the tab containing plane and evoke:

<samp>&nbsp;&nbsp;&nbsp;:let BACKUP_01=deepcopy(t:txb)  "make sure name is in ALL CAPS</samp>

And to restore (evoke from anywhere):

<samp>&nbsp;&nbsp;&nbsp;:call TXBinitPlane(BACKUP_01)</samp>

Alternatively, you can save a snapshot of the viminfo file via <samp>&nbsp;:wviminfo viminfo-backup-01&nbsp;</samp>. You can then restore it by quitting vim and replacing your current viminfo file with the snapshot.
