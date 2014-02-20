# textabyss
_A pannable, zoomable 2D text plane for [vim](http://www.vim.org) for working on a lifetime's worth of prose. Navigate with the mouse, keyboard, or via a map. **[Check out the youtube video](http://www.youtube.com/watch?v=QTIaI_kI_X8).**_

![Panning](https://raw.github.com/q335r49/textabyss/gh-pages/images/ta2.gif)     .     ![Map](https://raw.github.com/q335r49/textabyss/gh-pages/images/tamap.png)

#####Intro
Even as memory capacity grows exponentially, memory organization, especially when it comes to prose, seems quite underdeveloped. Text production even on the order of kilobytes per year may seem quite unmanageable. You may have hundreds or thousands of pages sitting in mysteriously named folders on old hard drives. There are various efforts to remedy this situation, including desktop indexing and personal wikis. It might not even be a bad idea to print out and keep as a hard copy everything written over the course of a month. 

The textabyss is yet another solution. It presents a plane that one can append to endlessly with very little overhead. It provides means to navigate and, either at the moment of writing or retrospectively, map out this plane. Ideally, you would be able to scan over the map and easily access writings from last night, a month ago, or even 5 or 10 years earlier. It presents some unique advantages over indexing, hyperlinking, and hierarchical organizing.

#####Installation
Download [the latest version of nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim), open [vim](http://www.vim.org), and type `:source nav.vim` (or wherever you downloaded the file). Once sourced, press **F10** to begin. Help is baked in, usually by pressing **F1** after **F10**. If the latest version is causing problems, earlier releases can be found at [vim.org/scripts](http://www.vim.org/scripts/script.php?script_id=4835) or under the releases tab.

#####Roadmap
**1.7** Change map background color based on depth >:-)  
**1.8** minimap - option to allow map to take up small area of screen, have panning follow map navigation  
**1.9** Commands to realign grid when editing pushes text down and misaligns the splits by deleting blank lines

##Guide
Note that this information can also be accessed from within the script, usually by pressing **F1** after **F10** or when the map is shown.

Start by downloading [the latest version of nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim), opening [vim](http://www.vim.org), and typing `:source nav.vim` (or wherever you downloaded the file).

Once sourced, press **F10** to begin. You will be prompted for a file pattern. You can try `*` for all files in the directory or, say, `pl*` for `pl1`, `plb`, `planetary.txt`, etc.. You can also name a single file and then use **F10,A** to append additional splits later on.

Once the files are loaded, you can pan using the mouse or by pressing **F10** followed by the standard vim keys (**h**, **j**, **k**, **l**). The full list of commands is:  

Key | Action
----- | -----
**h j k l** | Pan left 1 split / down 15 lines / up / right*
**y u b n** | Pan upleft / downleft / upright / downright*
**r** | Redraw
**o** | Open map
**.** | Snap to map grid (1 split x 45 lines)
**D A E** | Delete split / Append split / Edit split settings
**F1** | Help
**q ESC** | Abort
**^X** | Delete hidden buffers
_\* The movement keys will take a count (capped a 99), For example, 3j is the same as jjj._

If the mouse doesn't pan, try `:set ttymouse=sgr` or `:set ttymouse=xterm2`. Most other modes should work but the panning speed multiplier will be disabled. `xterm` does not report dragging and will disable mouse panning entirely.

Also, setting your viminfo to save global variables `:set viminfo+=!` is recommended as the plane will be suggested on **F10** the next time you run vim. This will also save the map.

####Map Mode

Each map grid is 1 split x 45 lines and is navigated much like in vim itself. The complete list of commands is:

Key | Action
--- | ---
**h j k l** | left / right / up / down\*
**y u b n** | leftup / leftdown / rightup / rightdown\*
**0 $** | Beginning / end of line
**H L M** | High / Middle / Low of screen
**x** | Clear (and obtain) cell
**o O** | obtain cell / Obtain column
**p P** | Put obtained cell or column
**c i** | Change label
**g <cr>** | Go to block and exit map
**I D** | Insert / Delete (and obtain) column
**Z** | Zoom: adjust map block size
**T** | Toggle color
**q** | Quit
_\* The movement keys will take a count (capped a 99), For example, 3j is the same as jjj._

You can also use the mouse to pan. Mouse clicks are associated with the very first letter of the label, so it might be helpful to prepend a marker, eg, '+ Chapter 1', so you have something to aim at. To facilitate navigating with the mouse only, the map can be activated with a mouse drag that ends at the top left corner; it can be closed by a click at the top left corner. To summarize:

Mouse | Action
--- | --- 
**doubleclick** | Go to block
**drag** | Pan
**click at topleft corner** | Quit
**drag to topleft corner** | Show map

Note that, as above, mouse commands only work when `ttymouse` is set to, `xterm2` or `sgr`. Unlike for plane navigation, a limited set of features work when `ttymouse` is `xterm`.

##Advanced

###Map Label Syntax

Special commands are included to (1) specify label color and (2) how the screen should be positioned after jumping to the target block. The `#` character is reserved to mark syntax regions and, unfortunately, can never be used in the label itself.

#####Coloring

Color a label via the syntax `label_text#highlightgroup`. For example, `^ Danger!#WarningMsg` should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the **T** command in map mode. See `:help highlight` for information on how to define highlight groups.

#####Positioning

Suppose you have just named a map block after a heading in the text, but the actual heading is halfway down the block. Furthermore, this heading occurs in the middle of a train of thought that began earlier, so you would like to show the previous split as well. By default, jumping to the target grid will put the cursor at the top left corner and the split at the leftmost position, but commands following the second `#` can change this. (To reposition the view but skip highlighting use `##`.) For example, in this case, we might want to use `* Heading##s25j` to shift the view left one split and move the cursor down 25 lines. The complete list of commands is:

Syntax | Action
--- | ---
**j k l** | Move cursor down / up / right
**r R** | Shift view down / up 1 Row (1 line)
**s** | Shift view left 1 Split
**C** | Shift view to Center cursor horizontally (overrides s)
**M** | Shift view so cursor is at the Middle line (overrides r,R)
**W** | Virtual window width (see below)

These commands work much like normal mode commands. For example, `* Heading##sjjjM` or `* Heading##s3jM` will shift the view left by one split, move the cursor down 3 lines, then vertically center the cursor.

By default, `s` won't move the split offscreen. For example, `45s` will not actually pan left 45 splits but only enough to push the target split to the right edge. This behavior can be modified by the `W` command, which specifies a 'virtual width'. For example, `30W` means that the width of the split is treated as though it were 30 columns. This would cause `5s30W` to shift only up to the point where 30 columns of the split are visible (and usually less than that).

When movement syntax is defined for a block, snap to grid (**F10**,**.**) will execute that command.

#####Potential Problems

Ensuring a consistent starting directory is important because relative names are remembered (use `:cd ~/PlaneDir` to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.

Regarding scrollbinding splits of uneven lengths -- I've tried to smooth this over but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding about 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G in normal mode to go to the last non-blank line rather than the very last line.

Horizontal splits aren't supported and may interfere with panning.

#####Scripting Functions
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
```

