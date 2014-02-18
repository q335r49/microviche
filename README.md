# textabyss
A pannable, zoomable 2D text plane for [vim](http://www.vim.org) for working on a lifetime's worth of prose. Navigate with the mouse, keyboard, or via a map. **[Check out the youtube video](http://www.youtube.com/watch?v=QTIaI_kI_X8).**

![Panning](https://raw.github.com/q335r49/textabyss/gh-pages/images/ta2.gif)     .     ![Map](https://raw.github.com/q335r49/textabyss/gh-pages/images/tamap.png)

#####Purpose
In a time when memory capacity is growing exponentially, memory organization, especially when it comes to prose, seems quite underdeveloped. Text production even on the order of kilobytes per year may still seem quite unmanageable. Depending on how prolific you are, you may have hundreds or thousands of pages sitting in mysteriously named folders on old hard drives. There are various efforts to remedy this situation including desktop indexing and personal wikis. It might not even be a bad idea to simply print out and keep as a hard copy everything written over the course of a month. 

The textabyss is yet another solution. It presents a plane that one can append to endlessly with very little overhead. It provides means to navigate and, either at the moment of writing or retrospectively, map out this plane. Ideally, you would be able to scan over the map and easily access writings from last night, a month ago, or even 5 or 10 years earlier. It presents some unique advantages over both indexing and hyperlinked or hierarchical organizing.

#####Installation
Download [nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim), open vim, and type `:source nav.vim`. Once sourced, press **F10** to begin. Help is baked in, usually by pressing **F1** after **F10**. Earlier releases can be found at [vim.org/scripts](http://www.vim.org/scripts/script.php?script_id=4835) or under the releases tab.

#####Roadmap
**1.7** Change map background color based on depth >:-)  
**1.8** minimap - option to allow map to take up small area of screen, have panning follow map navigation  
**1.9** Commands to realign grid when editing pushes text down and misaligns the splits by deleting blank lines

##Help
Help can also be accessed within the script, usually by pressing **F1** after **F10** or when the map is shown.

#####Startup
Download [nav.vim](https://raw.github.com/q335r49/textabyss/master/nav.vim), open vim, and type `:source nav.vim` (or wherever you downloaded the file). Once sourced, press **F10** to begin. You will be prompted for a file pattern. You can try `*` for all files or, say, `pl*` for `pl1`, `plb`, `planetary.txt`, etc.. You can also start with a single file and use **F10,A** to append additional splits.

Once loaded, use the mouse to pan or press **F10** followed by:  

Key | Action
----- | -----
**hjklyubn** | pan 1 split x 15 line grids
**HJKLYUBN** | pan 3 splits x 45 line grids
**o** | Open map (map grid: 1 split x 45 lines)
**r** | Redraw
**.** | Snap to the current big grid
**D A E** | Delete split / Append split / Edit split settings
**F1** | Show this message
**q ESC** | Abort
**^X** | Delete hidden buffers

#####Settings

If dragging the mouse doesn't pan, try `:set ttymouse=sgr` or `:set ttymouse=xterm2`. Most other modes should work but the panning speed multiplier will be disabled. `xterm` does not report dragging and will disable mouse panning entirely.

Setting your viminfo to save global variables (`:set viminfo+=!`) is recommended as the plane will be suggested on **F10** the next time you run vim. This will also save the map. You can also manually restore via `:let BACKUP=t:txb` and `:call TXBload(BACKUP)`.

Keyboard commands can be accessed via the `TXBdoCmd(key)` function in order to integrate textabyss into your workflow. For example `nmap <2-leftmouse> :call TXBdoCmd(\"o\")<cr>` will activate the map with a double-click.

#####Potential Problems

Ensuring a consistent starting directory is important because relative names are remembered (use `:cd ~/PlaneDir` to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.

Regarding scrollbinding splits of uneven lengths -- I've tried to smooth this over but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding about 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.

Horizontal splits aren't supported and may interfere with panning.

###Map Mode Help

Each map grid is 1 split x 45 lines

Key | Action
--- | ---
**hjklyubn** | move 1 block
**HJKLYUBN** | move 3 blocks
**x p** | Cut label / Put label
**c i** | Change label
**g <cr>** | Goto block (and exit map)
**I D** | Insert / delete column
**z** | Adjust map block size
**T** | Toggle color
**q** | Quit

Mouse | Action
--- | --- 
**doubleclick** | Goto block
**drag** | Pan
**click at topleft corner** | Quit
**drag to topleft corner** | Show map

Mouse clicks are associated with the very first letter of the label, so it might be helpful to prepend a marker, eg, '+ Chapter 1', so you can aim your mouse at the '+'. To facilitate navigating with the mouse only, the map can be activated with a mouse drag that ends at the top left corner; it can be closed by a click at the top left corner.

Mouse commands only work when `ttymouse` is set to `xterm2` or `sgr`. When `ttymouse` is `xterm`, a limited set of features will work.

###Advanced - Map Label Syntax

Syntax is provided for map labels in order to (1) color labels and (2) allow for additional positioning after jumping to the target block. The `#` character is reserved to designated syntax regions and, unfortunately, can never be used in the label itself.

#####Coloring:

Color a label via the syntax `label_text#highlightgroup`. For example, `^ Danger!#WarningMsg` should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the **T** command in map mode.

#####Positioning:

By default, jumping to the target grid will put the cursor at the top left corner and the split as the leftmost split. The commands following the second `#` character can change this. To shift the view but skip highlighting use `##`. For example, `^ Danger!##CM` will *C*enter the cursor horizontally and put it in the *M*iddle of the screen. The full command list is:  

Syntax | Action
--- | ---
**jkl** | Move the cursor as in vim
**s** | Shift view left 1 Split
**r** | Shift view down 1 row (1 line)
**R** | Shift view up 1 Row (1 line)
**C** | Shift view so that cursor is Centered horizontally
**M** | Shift view so that cursor is at the vertical Middle of the screen

These commands work much like normal mode commands. For example, `^ Danger!#WarningMsg#sjjj` or `^ Danger!#WarningMsg#s3j` will both shift the view left by one split and move the cursor down 3 lines. The order of the commands does not matter.

Shifting the view horizontally will never cause the cursor to move offscreen. For example, `45s` will not actually pan left 45 splits but only enough to push the cursor right edge.
