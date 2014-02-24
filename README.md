![Panning](https://raw.github.com/q335r49/textabyss/gh-pages/images/textabyss-animation-optimized.gif)
Textabyss is a **pannable**, **zoomable** plane for working on large amounts of text. It is implemented as a script for [vim](http://www.vim.org). 
* It is primarily intended as an archive for prose, but it also works well for note taking, planning out projects, taking margin notes, and brainstorming.
* It supports both mouse and keyboard, and features a color map.

##Installation
Download [the latest version of nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim), open [vim](http://www.vim.org), and install by typing `:source nav.vim` (or wherever you downloaded the file). Once sourced, press **F10** to begin. Help is baked in, usually by pressing **F1** after **F10**.

##Commands
_Help can be accessed in script, usually by pressing **F1**, either after pressing **F10** or when the map is shown._

Once installed, press **F10** to begin. You will be prompted for a file pattern. You can try `*` for all files in the directory or, say, `plane*` for files beginning with 'plane'. You can also name a single file and later append additional splits as needed with **F10 A**

Once the files are loaded, you can pan using the mouse or by pressing **F10** followed by the standard vim keys **h**, **j**, **k**, and **l**. The full list of commands is:  

Key | Action
----- | -----
**h j k l*** | Pan left **1 split** / down **15 lines** / up / right
**y u b n*** | Pan upleft / downleft / upright / downright
**r** | Redraw
**D A E** | Delete split / Append split / Edit split settings
**F1** | Help
**q ESC** | Abort
**^X** | Delete hidden buffers
_\* Movement keys take a count (capped a 99). For example, 3j is the same as jjj._

####The Map

The following commands, accessed via **F10**, relate to the map:

Key | Action
--- | --- 
**o** | Open map (map block = **1 split x 45 lines**)
**.** | Snap to map grid

You can navigate the map much as in vim, via **h**, **j**, **k**, **l**. Some basic block manipulation commands are also provided under the familiar vim mnemonics. The complete list of commands in map mode is:

Key | Action
--- | ---
**h j k l*** | left / right / up / down
**y u b n*** | leftup / leftdown / rightup / rightdown
**0 $** | Beginning / end of line
**H L M** | High / Middle / Low of screen
**x** | Clear (and obtain) cell
**o O p P** | obtain cell / Obtain column / Put obtained after / before
**c i** | Change label
**g <cr>** | Go to block and exit map
**I D** | Insert / Delete (and obtain) column
**Z** | Zoom (adjust map block size)
**T** | Toggle color
**q** | Quit
_\* Movement keys take a count (capped a 99). For example, 3j is the same as jjj._

You can also use the mouse to pan and select. Mouse clicks are associated with the location of the very first letter of the label, so it might be helpful to prepend a marker, eg, '+ Chapter 1'. Mouse-only navigation is possible: the map can be activated with a mouse drag that ends at the top left corner and closed with a click at the top left corner. To summarize:

Mouse | Action
--- | --- 
**doubleclick** | Go to block
**drag** | Pan
**click at topleft corner** | Quit
**drag to topleft corner** | Show map

Note that, as above, mouse commands only work when `ttymouse` is set to `xterm2` or `sgr`. Unlike for plane navigation, a limited set of features will still work when `ttymouse` is `xterm`.

##Issues

####Mousing Problems
If the mouse doesn't pan, try `:set ttymouse=sgr` or `:set ttymouse=xterm2`. `xterm` does not report dragging and so is unsupported. Most other modes should work but might take a speed penalty.

####Saving
Setting your viminfo to save global variables `:set viminfo+=!` is recommended as the plane will be suggested on **F10** the next time you run vim. This means you don't have to type the file pattern again. You also need to enable this setting to save the map, below.

####Directories
Ensuring a consistent starting directory is important because relative names are remembered (use `:cd directory` to switch directories). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent. If you find yourself constantly needing to swith directories, consider adding an autocommand (see `:help autocommand`) to switch back to some fixed directory when in the plane tab.

####Misaligned splits at end of file
When at the bottom of a split much longer than its neighbors, desyncing may occur -- ie, the lines may become misaligned. You can press r to redraw when this happens. Another more permanent solution is to pad about 500 or 1000 blank lines to the end of every split so that you are never working at the very end of a particularly long split. (It might be helpful, in that case, to remap **G** in vim's normal mode to go to the last non-blank line rather than the very last line -- see the source code for this option.)

####Horizontal Splits

Horizontal splits aren't supported and may interfere with panning.

##Advanced

####Map Label Syntax

Special commands may be given in the label to specify (1) the color and (2) how the screen should be positioned after jumping to the target block. The `#` character is reserved to mark syntax regions and, unfortunately, can never be used in the label itself.

#####Color

Color a label via the syntax `label_text#highlightgroup`. For example, `^ Danger!#WarningMsg` should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the **T** command (while in map mode). See `:help highlight` for information on how to define highlight groups.

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

The order of the commands do not matter: for example, `* Heading##sjjjM`, `* Heading##s3jM`, and `* Heading##M3js` all accomplish the same task of shifting the view left by one split, moving the cursor down 3 lines, and vertically centering the cursor. A typical use case is `* Heading##20jCM`, which would just put the cursor on the 20th line and that line at the direct center of the screen.

By default, `s` won't move the split offscreen. For example, `45s` will not actually pan left 45 splits but only enough to push the target split to the right edge. This behavior can be modified with the `W` command which specifies a 'virtual width'. For example, `30W` means that the width of the split is treated as though it were 30 columns. This would cause `2s30W` to shift 2 splits, but only up to the point where 30 columns of the split are still visible (and usually less than that).

When movement syntax is defined for a block, snap to grid (**F10 .**) will execute that command instead of its usual function.

####Line Anchors
Key | Action
--- | ---
**^L** | Insert line anchor
**^A** | Align all text anchors in split

Inserting text at the top of a split misaligns everything below. Line anchors try to address this problem. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. It can be inserted with **F10 ^L**. The align command **F10 ^A** attempts to restore all displaced anchors in a split by removing or inserting *immediately preceding* blank lines. If there aren't enough blank lines to remove the effort will be abandoned with an error message.

####Scripting interface
The plane itself can be accessed via the `t:txb` variable when in the tab where the plane is loaded.

You can manually restore via `TXBload()`: 
```
:let BACKUP=deepcopy(t:txb)  "get current state snapshot
:let BACKUP=t:txb            "get plane
:call TXBload(BACKUP)        "load plane
```
Keyboard commands can be accessed via `TXBdoCmd()`. For example, the following mapping will activate the map with a doubleclick
```
nmap <2-leftmouse> :if exists("t:txb")\| call TXBdoCmd("o") \| en<cr>`
