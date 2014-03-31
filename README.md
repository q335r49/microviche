<p align="center">
<img hspace='20' src="https://raw.github.com/q335r49/textabyss/gh-pages/images/microviche-small.png" width="400" height="150" alt="animation"/>
</p>

###microViche lets you pan and zoom through text archives
It works sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim. It has great mouse support, automatic mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Installation and Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [download dir]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with `F10`: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Basic commands
Pan with the mouse or press `F10` followed by:

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l` <sup>1</sup>| ← ↓ ↑ → | | `F1` <sup>2</sup> | *help*
`y``u``b``n` <sup>1</sup>| ↖ ↗ ↙ ↘  ||`A` `D` |*append / delete split*
`r` `R` | *redraw / Remap* | | `L` | *label autotext*
`o` | *open map* | | `Ctrl-X`| *delete hidden buffers*
`S` <sup>3</sup> | *settings* | |`W` <sup>4</sup>| *write to file*
`q` `esc` | *abort*| | |
<sup>1</sup> Movements take a count. Eg, `3j`=`jjj`.  
<sup>2</sup> Help will also display warnings and suggestions specific to your Vim setup.  
<sup>3</sup> If the hotkey, default `F10`, becomes inaccessible, <samp>:call TxbInit()</samp> and press `S` to change.  
<sup>4</sup> The last used plane is also saved in the viminfo and suggested on `F10` the next session.

####Mapping

Lines beginning with <samp>txb:</samp> are considered **mapping labels**. The full syntax is:  
<samp>&nbsp;txb[:line num][: label#highlght#ignored text]</samp>

**`F10``R`emap** will (1) `r`edraw the view (2) map all labels for the splits in the view and (3) try to relocate any displaced label lines to the corresponding <samp>line num</samp>, if provided, by inserting or removing immediately preceding blank lines. Some example labels:  
<samp>&nbsp;txb:345 Blah blah&nbsp;&nbsp;&nbsp;</samp>*move to 345, if possible*  
<samp>&nbsp;txb:345: Blah blah&nbsp;&nbsp;</samp>*move to 345, label map 'Blah blah'*  
<samp>&nbsp;txb: Blah#Title&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*label 'Blah', highlight 'Title'*  
<samp>&nbsp;txb: Blah##Ignored&nbsp;&nbsp;</samp>*label 'Blah'*

<samp>:ec TxbReformatLog</samp> entries:  
<samp>&nbsp;move 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*In split 15, line 78 was moved to line 70*  
<samp>&nbsp;labl 15 78 Blah&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Line 78 of split 15 was labeled 'Blah'*  
<samp>&nbsp;EMOV 15 78 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*Error: not enough blank lines to remove*  

To **view the map**, press `F10``o`:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`click`  `2click` <sup>1</sup>|*select / goto block*||`h``j``k``l` |← ↓ ↑ →
`drag` | *pan* || `y``u``b``n` |↖ ↗ ↙ ↘
`click` NW corner <sup>2</sup>|*exit map*||`H``J``K``L`` |*pan* ← ↓ ↑ →
`drag` to NW corner <sup>2</sup> | *(in plane) show map* ||`Y``U``B``N` |*pan* ↖ ↗ ↙ ↘
`g` `enter`| *goto label*||`q` `esc`|*quit*
<sup>1</sup> gVim does not support the mouse in map mode.  
<sup>2</sup> 'Hot corners' only work when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.  

####Tips
- To **turn off scrollbinding** so the columns scroll independently: `F10``S`ettings → `c`hange <samp>autoexe</samp> for the <samp>Plane</samp> (and not the <samp>Split</samp>) from <samp>se nowrap scb cole=2</samp> to <samp>se nowrap noscb cole=2</samp> → `S`ave → <samp>y</samp> at 'apply to all' prompt.
- To automate **keyboard commands**, <samp>:call TxbExe(key)</samp>
- **Horizontal splits** aren't supported and will interfere with panning.
- A **terminal emulator** is recommended over gVim because of better mouse control and automatic redrawing. For Windows, **[Cygwin](http://www.cygwin.com/)** running the (bundled) [mintty](https://code.google.com/p/mintty/) terminal emulator is recommended over gVim (in turn recommended over the Windows command prompt).
