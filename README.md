#textabyss
<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/> ... is a **pannable**, **zoomable** plane for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose, but it also works well for note taking, planning out projects, margin comments, and brainstorming. It supports both the mouse and keyboard, and features a color map. Check out the (somewhat outdated) **[youtube video](http://www.youtube.com/watch?v=QTIaI_kI_X8).**

**Install** by **[downloading](https://raw.github.com/q335r49/textabyss/master/nav.vim)** the latest version of nav.vim, opening vim, and typing `:source ~/Downloads/nav.vim` (or wherever you downloaded the file).

**Help** is available in script, typically by pressing **F1** after pressing **F10** or in map mode.

###The Plane

Press **F10** to bring up the prompt `Enter file pattern or type HELP:`. You can try `*` for all files in the directory or, say, `plane*` for files beginning with 'plane'. You can also name a single file and later append additional splits as needed with **F10 A**

Once the plane is shown, move around by dragging the mouse or by pressing **F10** followed by the standard vim keys **h**, **j**, **k**, and **l**. The complete list of commands accessed via **F10** is: 

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
**hjkl** | Pan left **1 split** / down **15 lines** / up / right | | **F1** | Help
**yubn** | Pan upleft / downleft / upright / downright | | **A D E** | Append split / Delete split / Edit split
 **r**  | Redraw    | | **^X**| Delete hidden buffers
**o** | Open map | | **q esc** | Abort
**.** | Snap to map grid | | | 
_\* The hjklyubn keys take a count, capped at 99. For example, 3j is the same as jjj._  

###The Map

Press **F10 o** to access the map. Each map cell corresponds to **1 split** (column) x **45 lines** in the plane. Navigate the map by dragging the mouse or via **h**, **j**, **k**, **l**. The complete list of commands in map mode is:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
**h j k l** | Left / right / up / down | | **c i** | Change label
**y u b n** | Leftup / leftdown / rightup / rightdown | | **g <cr>** | Go to block and exit map
**0 $** | Start / end of line | | **I D** | Insert / Delete (and obtain) column
**H M L** | High / Middle / Low of screen | | **Z** | Zoom (adjust map block size)
**x** | Clear (and obtain) cell | | **T** | Toggle color
**o O p P** | Obtain (cell / column) / Put (after / before) | | **F1** | Help
**q**| Quit | | |
_\* The hjklyubn keys take a count, capped at 99. For example, 3j is the same as jjj._  

Mouse | Action | | Mouse | Action
--- | --- | --- | --- | ---
**doubleclick** | Go to block | | **click at topleft corner** | Quit
**drag** | Pan | | **drag to topleft corner** | (While in plane) Show map

###Troubleshooting

####Mousing Problems
If the mouse doesn't work, try setting `ttymouse` to `sgr` or `xterm2` via `:set ttymouse=sgr`. `xterm` doesn't report dragging and so is unsupported. Other modes should work but might take a speed penalty. Only `sgr`, `xterm2`, and `xterm` are supported in map mode. Note that in map mode mouse clicks are associated with the very first letter of the label (which will never be hidden), so it might be helpful to prepend a marker, eg, '+ Chapter 1'.

####Saving Planes
The script uses the viminfo file (`:help viminfo`) to save plane and map data. The option to save global variables in all caps (eg, 'BACKUP01') is set automatically (`:set viminfo+=!`) when the script is loaded. The saved plane is suggested on **F10**.

To manually save a snapshot of the current plane in the current viminfo, navigate to the tab containing the plane and try:  
```
:let BACKUP01=deepcopy(t:txb)\n
```
You can then restore via either:  
```
:call TXBload(BACKUP01)
```
which loads the backup in a new tab (this allows for having more than one plane open at once), or:  
```
:let g:TXB=BACKUP01     
```
which would overwrite the currently saved plane and load the backup the next time you press **F10**

Alternatively, you can save a snapshot of the viminfo via:
```
:wviminfo viminfo-backup-01
```
You can then restore it by quitting vim and replacing your current viminfo file with the backup.\n

####Directories
Ensuring a consistent directory is important because relative names are remembered (use `:cd directory` to switch directories). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory should be ok. If you find yourself constantly needing to swicth directories, consider adding an autocommand (see `:help autocommand`) to switch back to the plane directory when in the plane tab.

####Misaligned splits
When you scroll past the end of a split because one split is much longer than its neighbors, the splits may become misaligned. You can press r to redraw when this happens. Another solution is to pad 500 or 1000 blank lines to the end of every split so that you are never working at the very end of a particularly long split. It might be helpful, in that case, to remap **G** in vim's normal mode to go to the last non-blank line rather than the very last line -- you can uncomment a few lines in the source code for this option.

####Horizontal Splits

Horizontal splits aren't supported and may interfere with panning.

###Advanced

####Map Label Syntax

The general syntax is: `Map Label#optional highlight group#optional positioning command`.
`#` is reserved to mark syntax regions and, unfortunately, can never be used in the label itself.

#####Color

Color a label via the syntax `label_text#highlightgroup`. For example, `^ Danger!#WarningMsg` should color the label bright red. You can toggle coloring on and off with the **T** command while in map mode. See `:help highlight` for information on how to define highlight groups.

#####Position

Suppose you have just named a map block after a heading in the text, but the actual heading occurs halfway down the block. Furthermore, this heading is the second column in a larger block of text, so you would like to show the previous split as well. By default, jumping to the target grid will put the cursor at the top left corner and the split at the leftmost position, but positioning commands can alter this. These commands follow the second `#` in a label. (To reposition the view but skip highlighting use `##`.) For example, in the above case we would use `* Heading##s20j` to shift the view left one split (s) and move the cursor down 20 lines (20j), or perhaps just `* Heading##20jCM` to put that line in the center screen column (C) and the middle line of the screen (L). The complete list of commands is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
**j k l** | Move cursor down / up / right | |**C** | Shift view to Center cursor horizontally (overrides s)
**r R** | Shift view down / up 1 Row (1 line) | |**M** | Shift view so cursor is at the Middle line (overrides r,R)
**s** | Shift view left 1 Split | |**W** | Virtual window width (see below)

The order of the commands do not matter: for example, `* Heading##jMjsj`, `* Heading##s3jM`, and `* Heading##M3js` all do the same thing: shift the view left one split, move the cursor down 3 lines, and vertically center the view.

`W` changes the behavior of the `s` command. By default, `s` won't move the split offscreen, but only enough to push the target split to the right edge. So, for example, `45s` won't actually shift the view left 45 splits. This behavior can be modified with the `W` command which specifies a 'virtual width'. For example, `30W` means that the width of the split is treated as though it were 30 columns. This would mean that `2s30W` would either shift 2 splits or up to the point where 30 columns of the split are still visible.

When movement syntax is defined for a block, snap to grid (**F10 .**) will execute that command instead of its usual function.

####Line Anchors
Key | Action
--- | ---
**F10 ^L** | Insert line anchor
**F10 ^A** | Align all anchors in split

Line anchors try to address the issue where insertions at a higher line misalign lower lines. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. The align command starts from the top of the split and attempts to restore all displaced anchors by removing or inserting blank lines immediately before it. If there aren't enough blank lines to remove an error message will be shown.

####Scripting interface
The plane itself can be accessed via the `t:txb` variable when in the tab where the plane is loaded.

You can manually restore via `TXBload(plane)`: 
```
:let COPY=deepcopy(t:txb)    "make a copy
:let BACKUP=t:txb            "get plane
:call TXBload(BACKUP)        "load plane
```
Keyboard commands can be accessed via `TXBdoCmd(key)`. For example, the following mapping will activate the map with a doubleclick
```
nmap <2-leftmouse> :if exists("t:txb")\| call TXBdoCmd("o") \| en<cr>`
