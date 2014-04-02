**\*\* Maps from versions < 1.8 are incompatible (manual mapping has been removed) \*\***

---
#microViche
microViche is sort of like a [microfiche](http://www.wisegeek.org/what-is-microfiche.htm) reader for Vim - it lets you pan and zoom through archives. It has great mouse support, mapping, and a **[youtube demo](http://www.youtube.com/watch?v=xkED6Mv_4bc)**!

####Startup
- **[Download](https://raw.github.com/q335r49/textabyss/master/nav.vim)** nav.vim, open **[Vim](http://www.vim.org)**, and <samp>:source [download dir]/nav.vim</samp>
- (Only necessary when first creating a plane) Switch to the **working directory** via <samp>:cd [dir]</samp> 
- Evoke a file prompt with `F10`: you can start with a pattern (eg, <samp>*.txt</samp>) or a single file.

####Usage
Once loaded, pan with the **mouse** or by pressing `F10` followed by:

Key | Action | | Key | Action
----- | ----- | --- | --- | ---
`h``j``k``l` <sup>1</sup>| ← ↓ ↑ → | | `F1` <sup>2</sup> | *help*
`y``u``b``n` | ↖ ↗ ↙ ↘  ||`A` `D` |*append / delete split*
`r` `R` | *redraw / Remap* | |`o` `O` | *view map / Remap & view'
`L` | *insert* <samp>txb:lnum</samp> ||`Ctrl-X`| *delete hidden buffers*
`S` <sup>3</sup> | *settings* | |`W` <sup>4</sup>| *write to file*
`q` `esc` | *quit*| | 

**Map labels** are lines that look like:

<samp>&nbsp;txb[:lnum][: label#highlght#ignored text]</samp>

Press `f10``R` to **map visible splits**. In addition, displaced labels will be relocated to <samp>lnum</samp>, if provided, by inserting or removing preceding blank lines. If relocation fails the label will be highlighted <samp>ErrorMsg</samp>. Some examples:
- <samp>&nbsp;txb:345 ignored&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp>*move to 345*  
- <samp>&nbsp;txb:345: Blah#Title&nbsp;</samp>*move to 345, label 'Blah', highlight 'Title'**  
- <samp>&nbsp;txb: Blah##ignored&nbsp;&nbsp;</samp>*label 'Blah'*  

Once mapped, press `F10``o` to **view the map**:

Key | Action | | Key | Action
--- | --- | --- | --- | ---
`click`  `2click` <sup>5</sup>|*select / goto block*||`h``j``k``l` <sup>1</sup>|← ↓ ↑ →
`drag` | *pan* || `y``u``b``n` |↖ ↗ ↙ ↘
`click` NW corner <sup>6</sup>|*exit map*||`H``J``K``L`` |*pan* ← ↓ ↑ →
`drag` to NW corner | *(in plane) show map* ||`Y``U``B``N` |*pan* ↖ ↗ ↙ ↘
`g` `enter`| *goto label*|| `c` |*move cursor to center*
`q` `esc`|*quit* || `z` |*change zoom*

#### Tips
- To **turn off scrollbinding** so columns scroll independently: `F10``S`ettings → `c`hange <samp>autoexe</samp> (for the <samp>Plane</samp> and not the <samp>Split</samp>) from <samp>se nowrap scb cole=2</samp> to <samp>se nowrap noscb cole=2</samp> → `S`ave → <samp>y</samp> at 'apply all' prompt.  
- **Horizontal splits** will screw up panning.  
- **Terminal emulators** work better than gVim (allows mousing in map mode and automatic redrawing, among other features). On Windows, **[Cygwin](http://www.cygwin.com/)** running the bundled [mintty](https://code.google.com/p/mintty/) terminal works better than gVim which works better than cmd.exe.
- **Emphasize** a label by prepending it an ASCII char < <samp>A</samp>, eg, <samp>*</samp>, <samp>!</samp>, <samp>_</samp> - they are shown when there are multiple labels in the map line.

----
<sup>1</sup> Motions take a count, eg, `3``j`=`j``j``j`.  
<sup>2</sup> Help will also display warnings and suggestions specific to your Vim setup.  
<sup>3</sup> If the hotkey, default `F10`, becomes inaccessible, <samp>:call TxbInit()</samp> and press `S` to change.  
<sup>4</sup> The last used plane is also saved in the viminfo and suggested on `F10` the next session.  
<sup>5</sup> gVim does not support mousing in map mode.  
<sup>6</sup> 'Hot corners' only work when <samp>ttymouse</samp> is <samp>xterm2</samp> or <samp>sgr</samp>.
