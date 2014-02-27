#Textabyss
<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/> ... is a **pannable**, **zoomable** plane for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose, but it also works well for note taking, planning out projects, margin comments, and brainstorming. It supports both the mouse and keyboard, and features a color map. Check out the **[youtube video](http://www.youtube.com/watch?v=xkED6Mv_4bc).**

**[Install by downloading the latest version of nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim)**, opening vim, and typing `:source ~/Downloads/nav.vim` (or wherever your download directory is). The documentation below is also available from within the script, typically by pressing **F1** after pressing **F10** or while in map mode.

###Navigating the plane

Press **F10** to bring up the prompt `Enter file pattern or type HELP:`. You can try `*` for all files in the directory or, say, `plane*` for files beginning with 'plane'. You can also name a single file and later append additional splits as needed with **F10 A**

Once in the plane, move around by dragging the mouse or by pressing **F10** followed by **h**, **j**, **k**, ord **l**. The complete list of commands accessed via **F10** is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
**hjkl** | Pan left **1 split** / down **15 lines** / up / right | | **F1** | Help
**yubn** | Pan upleft / downleft / upright / downright | | **A D E** | Append split / Delete split / Edit split
 **r**  | Redraw    | | `^X`| Delete hidden buffers
**o** | Open map | | **q** `esc` | Abort
**.** | Snap to map grid | | | 
_\* The hjklyubn keys take a count, capped at 99. For example, 3j is the same as jjj._  

###Using the map

Press **F10 o** to access the map. Each map cell corresponds to **1 split** (column) x **45 lines** in the plane. Navigate the map by dragging the mouse or via **h**, **j**, **k**, **l**. The complete list of commands in map mode is:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
**h j k l** | Left / right / up / down | | **c i** | Change label
**y u b n** | Leftup / leftdown / rightup / rightdown | | **g** `enter` | Goto block and exit map
**0 $** | Start / end of line | | **I D** | Insert / Delete (and obtain) column
**H M L** | High / Middle / Low of screen | | **Z** | Zoom (adjust map block size)
**x** | Clear (and obtain) cell | | **T** | Toggle color
**o O** | Obtain (cell / column)| | **F1** |Help
**p P** | Put obtained (after / before)| |**q**|Quit 
_\* The hjklyubn keys take a count, capped at 99. For example, 3j is the same as jjj._  

Mouse | Action | | Mouse | Action
--- | --- | --- | --- | ---
**doubleclick** | Go to block | | **click at topleft corner** | Quit
**drag** | Pan | | **drag to topleft corner** | (While in plane) Show map

###Troubleshooting

**Mouse problems** - If the mouse doesn't work, try setting `ttymouse` to `sgr` or `xterm2` via `:set ttymouse=sgr`. `xterm` doesn't report dragging and so is unsupported. Other modes should work but might take a speed penalty. Only `sgr`, `xterm2`, and `xterm` are supported in map mode. Note that in map mode mouse clicks are associated with the very first letter of the label (which will never be hidden), so it might be helpful to prepend a marker, eg, '+ Chapter 1'.

**Directories** - Ensuring a consistent directory is important because relative names are remembered (use `:cd directory` to switch directories). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory should be ok. If you find yourself constantly needing to swicth directories, consider adding an autocommand (see `:help autocommand`) to switch back to the plane directory when in the plane tab.

**Misaligned splits** - When you scroll past the end of a split because one split is much longer than its neighbors, the splits may become misaligned. You can press r to redraw when this happens. Another solution is to pad 500 or 1000 blank lines to the end of every split so that you are never working at the very end of a particularly long split. It might be helpful, in that case, to remap **G** in vim's normal mode to go to the last non-blank line rather than the very last line -- you can uncomment a few lines in the source code for this option.

**Horizontal splits** - Horizontal splits aren't supported and may interfere with panning.

###Advanced features

####Map syntax

The syntax for map labels is: `Label text#optional color#optional position`. Note that `#` is reserved for this purpose and can never be used in the label itself.

To **color** a label you must specify a highlight group: see `:help highlight` for details. For example, `^ Danger!#WarningMsg` should color the label bright red. Try `:hi` for a list of currently defined highlights.

Specifying **position** is a bit more elaborate. Suppose you want to name a map block after a heading in the text, but the actual heading occurs halfway down the block. Furthermore, this heading is the second column in a larger block of text so you'd like to show the previous split as well. Jumping to the target grid will typically put the cursor at the top left corner and the split at the leftmost point, but positioning commands can move it from this default position.

For example, in the above case we might use `* Heading##s20j` to shift the view left one split (`s`) and move the cursor down 20 lines (`20j`). Or perhaps just `* Heading##20jCM`: **C**enter that split and scroll so that 20th line is at the **M**iddle of the screen. 

Note that the order of the commands doesn't matter: for example, `* Heading##jMjsj`, `* Heading##s3jM`, and `* Heading##M3js` all do the same thing: shift the view left one split, move the cursor down 3 lines, and vertically center the view. The complete list of commands is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
**j k l**|Cursor down / up / right| |**W** | Virtual split width (see below)
**r R**|Shift view down / up 1 Row| |**M** | Center cursor vertically (override **r R**)
**s**|Shift view left 1 Split| |**C** | Center split horizontally (override **s**)

Specify a virtual width with `W` in order to change the behavior of `s` or `C`. By default, `s` won't move the split off screen but only enough to push the target split to the right edge. Specifying, for example, `15W` means that the width of the split is treated as though it were 15 columns. This would mean that `5s15W` would at most shift up to the point where the split's left border is 15 columns from the right edge of the screen. Likewise, `C` would center the split as though it were of width `W`.

Note that when movement syntax is defined for a block, "Snap to grid" (**F10 .**) will execute that movement instead.

####Line anchors
Key | Action
--- | ---
**F10 ^L** | Insert line anchor
**F10 ^A** | Align all anchors in split

Line anchors try to address the issue where insertions at a higher line misalign lower lines. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. The align command starts from the top of the split and attempts to restore all displaced anchors by removing or inserting blank lines immediately before it. If there aren't enough blank lines to remove an error message will be shown.

####Saving the plane
The script uses the viminfo file to save plane and map data, see `:help viminfo`. The option to save global variables in ALL CAPS is set automatically when the script is loaded via the command `:set viminfo+=!`. The saved plane is then suggested on **F10** the next time you start vim.

To manually save a snapshot (make sure name is in ALL CAPS):
```
    :let BACKUP_01=deepcopy(t:txb)  "evoke in tab containing plane
    :call TXBinitPlane(BACKUP_01)   "evoke anywhere
```

Alternatively, you can save a snapshot of the viminfo file via `:wviminfo viminfo-backup-01`. You can then restore it by quitting vim and replacing your current viminfo file with the snapshot.
