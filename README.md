<p align="center">
<img hspace='20' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/microviche-small.png" width="400" height="150" alt="animation"/>
</p>

###Microviche lets you pan and zoom through text archives
It works sort of like a microfiche reader for Vim. It has great mouse support, automatic mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Installation and Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [download dir]/nav.vim</samp>
- (Only necessary when creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with `F10`: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Basic commands
Pan with the mouse or press `F10` followed by:

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l` <sup>1</sup>| ← ↓ ↑ → | | `F1` <sup>2</sup> | *help*
`y``u``b``n` <sup>1</sup>| ↖ ↗ ↙ ↘  ||`A` `D` |*append / delete split*
`r` `R` <sup>3</sup>| *redraw / Remap* | | `L` <sup>3</sup> | *label autotext*
`o` | *open map* | | `Ctrl-X`| *delete hidden buffers*
`S` <sup>4</sup> | *settings* | |`W` <sup>5</sup>| *write to file*
`q` `esc` | *abort*| | |
<sup>1</sup> Movements take a count. Eg, `3j`=`jjj`.  
<sup>2</sup> Help will also display warnings and suggestions specific to your Vim setup.  
<sup>3</sup> See [Automapping](#automapping) below.  
<sup>4</sup> If the hotkey (default `F10`) becomes inaccessible, <samp>:call TxbInit()</samp> and press `S` to change.  
<sup>5</sup> The last used plane is also saved in the viminfo and suggested on `F10` the next session.

####Map Commands
Press `F10``o` to access the map:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`click`  `2click` <sup>1</sup>|*select / goto block*||`h``j``k``l` | ← ↓ ↑ → 
`drag` | *pan* || `y``u``b``n` | ↖ ↗ ↙ ↘  
`click` NW corner <sup>2</sup>|*exit map*||`g` `enter` | *goto block* 
`drag` to NW corner <sup>2</sup> | *(in plane) show map* || `c` <sup>3</sup> | *change label*
`H` `M` `L` | *high / middle / low row* || `0` `$` | *start / end of row*
`I` `D` | *insert / delete & obtain col* || `Z` | *adjust map zoom*
`x` | *delete & obtain cell* || `T` | *toggle color*
`o` `O` | *obtain cell / col*|| `q` `esc`|*quit*
`p` `P` | *put obtained after / before*|| `F1` | *help*
<sup>1</sup> gVim does not support the mouse in map mode.  
<sup>2</sup> 'Hot corners' only work when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.  
<sup>3</sup> See [Label Syntax](#label-syntax) below.

####Label Syntax
When `c`hanging a map lable, you're also prompted for optional highlighting and positioning commands:

* You can press `tab` at the highlight prompt to auto-complete from currently defined highlights.
* Positioning commands move the cursor and the split from their initial position at the top left corner and leftmost split, respectively. For example, say you want to label a heading that occurs 20 lines down the block. You can center the split and position the cursor at the heading via <samp>&nbsp;C20j</samp>. The complete syntax is:

Syntax | Action | | Syntax | Action
--- | --- | --- | --- | ---
<samp>j k l</samp>|*cursor down / up / right*| |<samp>W</samp> <sup>1</sup> | *virtual split width*
<samp>r R</samp>|*shift view down / up 1 row*| |<samp>M</samp> | *center cursor vertically (ignore* <samp>r R</samp>*)*
<samp>s</samp>|*shift view left 1 split*| |<samp>C</samp> | *center split horizontally (ignore* <samp>s</samp>*)*
<sup>1</sup> By default, <samp>s</samp> will not shift the split offscreen, regardless of count. But specifying, eg, <samp>15W</samp> would allow <samp>s</samp> to shift all but 15 columns offscreen. Likewise, <samp>15WC</samp> would center the split as though it were of width 15.

####Automapping
Automapping is recommended over `c`hanging labels in the map itself: you won't have to remap if you shift the text arround or insert or remove splits. `R`emap, in addition to `r`edrawing, will update the map to reflect the layout of all visible splits by processing lines of the form:

<samp>txb[:line num][: label#highlght#position]</samp>

* The line is moved to <samp>line num</samp> by inserting or removing immediately preceding blank lines
* The label is inserted into the map unless it conflicts with a preexisting user label. (Automatic labels are differentiated internally by a trailing <samp>A</samp>.)

Examples:  
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
- To **turn off scrollbinding** so the columns scroll independently: `F10``S`ettings → `c`hange <samp>autoexe</samp> for the <samp>Plane</samp> (and not the <samp>Split</samp>) from <samp>se nowrap scb cole=2</samp> to <samp>se nowrap noscb cole=2</samp> → `S`ave → <samp>y</samp> at 'apply to all' prompt.
- To automate **keyboard commands**, <samp>:call TxbExe(key)</samp>
- **Horizontal splits** aren't supported and will interfere with panning.
- A **terminal emulator** is recommended over gVim because of better mouse control and automatic redrawing. For Windows, **[Cygwin](http://www.cygwin.com/)** running the (bundled) [mintty](https://code.google.com/p/mintty/) terminal emulator is recommended over gVim (in turn recommended over the Windows command prompt).
