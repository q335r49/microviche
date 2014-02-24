<img hspace='20' align='left' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif" width="400" height="150" alt="animation"/> TEXTABYSS is a **pannable**, **zoomable** plane for working on large amounts of text, implemented as a script for **[vim](http://www.vim.org)**. It is primarily intended as an archive for prose, but it also works well for note taking, planning out projects, margin comments, and brainstorming. It supports both the mouse and keyboard, and features a color map. Check out the **[youtube video](http://www.youtube.com/watch?v=QTIaI_kI_X8).**

Install by **[downloading](https://raw.github.com/q335r49/textabyss/master/nav.vim)** the latest version of nav.vim, opening vim, and typing `:source ~/Downloads/nav.vim` (or wherever you downloaded the file).

###Commands
_Help can be accessed in script, usually by pressing **F10 F1** or **F1** in map mode._

Press **F10** to bring up a file pattern prompt. You can try `*` for all files in the directory or, say, `plane*` for files beginning with 'plane'. You can also name a single file and later append additional splits as needed with **F10 A**

Once the plane is shown, move around either by dragging the mouse or by pressing **F10** followed by the standard vim keys **h**, **j**, **k**, and **l**. The full list of commands (press **F10** to access): 

Key | Movement
----- | -----
**h j k l** | Pan left **1 split** / down **15 lines** / up / right
**y u b n** | Pan upleft / downleft / upright / downright
_Movements take a count (capped at 99). For example, 3j is the same as jjj._  

Key | Command
---- | ----
**r** | Redraw
**D A E** | Delete split / Append split / Edit split settings
**F1** | Help
**q ESC** | Abort
**^X** | Delete hidden buffers

The following commands relate to the map:

Key | Command
--- | --- 
**o** | Open map (map block = **1 split x 45 lines**)
**.** | Snap to map grid

####The Map

You can navigate the map much as in vim, via **h**, **j**, **k**, **l**. Some basic map manipulation commands are also provided under familiar vim mnemonics. The complete list of commands in map mode:

Key | Movement
--- | ---
**h j k l*** | left / right / up / down
**y u b n*** | leftup / leftdown / rightup / rightdown
**0 $** | Start / end of line
**H M L** | High / Middle / Low of screen
_Some movements take a count (capped at 99). For example, 3j is the same as jjj._

Key | Command
--- | ---
**x** | Clear (and obtain) cell
**o O p P** | obtain cell / Obtain column / Put obtained after / before
**c i** | Change label
**g <cr>** | Go to block and exit map
**I D** | Insert / Delete (and obtain) column
**Z** | Zoom (adjust map block size)
**T** | Toggle color
**q** | Quit

You can also use the mouse:

Mouse | Action
--- | --- 
**doubleclick** | Go to block
**drag** | Pan
**click at topleft corner** | Quit
**drag to topleft corner** | Show map

###Issues

####Mousing Problems
If the mouse doesn't work, try setting `ttymouse` to `sgr` or `xterm2` (eg, `:set ttymouse=sgr`). `xterm` doesn't report dragging and so is unsupported. Most other modes should work but might take a speed penalty. Only `sgr`, `xterm2`, and `xterm` are supported in map mode. Note that in map mode mouse clicks are associated with the very first letter of the label (which will never be truncated), so it might be helpful to prepend a marker, eg, '+ Chapter 1'.

####Saving
The plane and map are saved in the your `viminfo` file, so you must set your viminfo to save global variables (`:set viminfo+=!`) for this to work. The saved plane will be suggested on **F10** the next time you run vim. Note that this will work only for vim v7.3.030 and higher. 

####Directories
Ensuring a consistent directory is important because relative names are remembered (use `:cd directory` to switch directories). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory should be ok. If you find yourself constantly needing to swicth directories, consider adding an autocommand (see `:help autocommand`) to switch back to the plane directory when in the plane tab.

####Misaligned splits
When you scroll past the end of a split because one split is much longer than its neighbors, the splits may become misaligned. You can press r to redraw when this happens. Another solution is to pad 500 or 1000 blank lines to the end of every split so that you are never working at the very end of a particularly long split. It might be helpful, in that case, to remap **G** in vim's normal mode to go to the last non-blank line rather than the very last line -- you can uncomment a few lines in the source code for this option.

####Horizontal Splits

Horizontal splits aren't supported and may interfere with panning.

###Advanced

####Map Label Syntax

The `#` character is reserved to mark syntax regions and, unfortunately, can never be used in the label itself. The general syntax is `Map Label#optional highlight group#optional positioning command`

#####Color

Color a label via the syntax `label_text#highlightgroup`. For example, `^ Danger!#WarningMsg` should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the **T** command while in map mode. See `:help highlight` for information on how to define highlight groups.

#####Position

Suppose you have just named a map block after a heading in the text, but the actual heading occurs halfway down the block. Furthermore, this heading is the second column in a larger block of text, so you would like to show the previous split as well. By default, jumping to the target grid will put the cursor at the top left corner and the split at the leftmost position, but positioning commands can alter this. These commands follow the second `#` in a label. (To reposition the view but skip highlighting use `##`.) For example, in the above case we would use `* Heading##s20j` to shift the view left one split (s) and move the cursor down 20 lines (20j). The complete list of commands is:

Syntax | Action
--- | ---
**j k l** | Move cursor down / up / right
**r R** | Shift view down / up 1 Row (1 line)
**s** | Shift view left 1 Split
**C** | Shift view to Center cursor horizontally (overrides s)
**M** | Shift view so cursor is at the Middle line (overrides r,R)
**W** | Virtual window width (see below)

The order of the commands do not matter: for example, `* Heading##jMjsj`, `* Heading##s3jM`, and `* Heading##M3js` all do the same thing: shift the view left one split, move the cursor down 3 lines, and vertically center the view.

By default, `s` won't move the split offscreen, but only enough to push the target split to the right edge. So, for example, `45s` won't actually shift the view left 45 splits. This behavior can be modified with the `W` command which specifies a 'virtual width'. For example, `30W` means that the width of the split is treated as though it were 30 columns. This would mean that `2s30W` would either shift 2 splits or up to the point where 30 columns of the split are still visible.

When movement syntax is defined for a block, snap to grid (**F10 .**) will execute that command instead of its usual function.

####Line Anchors
Key | Action
--- | ---
**^L** | Insert line anchor
**^A** | Align all anchors in split

Line anchors try to address the issue where inserting text at the top of a split misaligns everything below. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. The align command starts from the top of the split and attempts to restore all displaced anchors by removing or inserting blank lines immediately before it. If there aren't enough blank lines to remove an error message will be shown.

####Scripting interface
The plane itself can be accessed via the `t:txb` variable when in the tab where the plane is loaded.

You can manually restore via `TXBload()`: 
```
:let BACKUP=t:txb            "get plane
:call TXBload(BACKUP)        "load plane
```
Keyboard commands can be accessed via `TXBdoCmd()`. For example, the following mapping will activate the map with a doubleclick
```
nmap <2-leftmouse> :if exists("t:txb")\| call TXBdoCmd("o") \| en<cr>`
