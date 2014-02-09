Project:
Neck knife: strong rubber band

SHOPPING
chocolate milk
dairy stuff
chocolate shell
eggs
sea salt
Face cream
big bolt for removing tire???!!!
/Chili
jalapenos, corn, beef, gr.peppers, endive, meat, celery, carrots, 

#Songs
torelli - christmas concert
he took her to a movie
clockwork orange -- funeral for queen mary
8-bit lacrimosa
tiger lilly... my tiger lilly ... you're as wild as they come ... so what's the trouble, where's the problem , can't you see, it's amazing what u do to me
da da da dadada  (kylie minogue)
its crazy but its true, i only want to be with u
saddest thing in the whole world / seeing your baby with another girl
tori amos -- 'things are gonna changes, all the white horses"
tori amos -- leather
Dancing Queen
Chicago 25 or 6 to 4

#espeak / speak
espeak -w --stdout -f file | kbaudiosink

# town court number: 783-2714

#Home
Laptop sleeve
Beanbag

#shopping--online??
garlic
frozen spinach / brussel sprouts
fruits
beef
chicken, cherry tomatos
spring mix
baby carrots
lots of peppers

lvu9026
library card number --- 21182004826781
397034843196296

== car ==
hair stuff --> car
eye exam

== Oil Change ==
149200 1/7/12

== vim color problems, etc ==
for connectbot, make sure 'start shell session is checked'
download screen-256color from /lib/s/screen-256color, copy it to the /etc/termcap in android
run export TERM=screen-256
export TZ=EST+4

FE6yq4KR4Ck9
sue: 518-439-3321 518-300-6459
javascript: Qr = prompt('Search YubNub for', ''); if (Qr) location.href = 'http://www.yubnub.org/parser/parse?command=' + escape(Qr)

 		YOUTUBE OUTLINE
 4 parts: tech demo, extra features, some design considerations, some philosophy
 panning, zooming
  ...
 some advanced features I've added through use
 writeroom / only
    "only to remove clutter
    "tabe % versus only
    	"easy to get out of only
    "'fullscreen' options
 wrap versus hardwrap
    "hardwrap sort of reflects the nature of vim as well, as there are workarounds... some might argue that hardwrap *is* a workaround to no line-by-line scrolling of long texts
 customizations
    "I actually use the Q key...
 split color"
 step through features
 jumps
    "table of contents (hardlinks)
    "changelist
 todo
  ...
 scripting versus coding -- vimscript and crosswords
    I've stopped coding features that I don't really use
    my relationship with vim, building a house
    completely trivial to implement if vim offered a function for adjusting split sizes -- so the whole difficulty of scripting is workign within a set of preestablished rules...
 mouse panning ... long time with the n810 to not get such a basic feature? ... what vim "is" (not just keyboard ninjas)
 mouse pan win for free ... android devices ... earlier 'writing environment' ... vim's adaptability
     one of the coolest workspaces ... ti-89 ... building one's virtual house
  ...
 yes, infinite text, but also, the niceness of having splits too -- side by side -- but organized
    "No longer: A 'plane compiler'
 long term: more naturally hierarchical or linear organizations, non-linear memory
 memory excising, blocks"
 Incredibly elaborate systems to do incredibly simple things -- and it all has to do with the text as a medium -- with the convertability of the text .. well, I mean, pattern warrior
    "the willingness, fundamnetally, to work with TEXT in accepting what is convenient and inconvenient"
    "Microsoft word, Android, n810
    	"   Windows desktop
 horizontal splits
    'traditional' desktop
    why no horizontal splits
    text anchors

#done
Added shortcuts to log functions in normD command
Fixed menu history bug in pager
Added gliding touch scrolling
Added y emulation to cmdnorm
Changed cmdnorm to exit on Esc rather than Q
Fixed scrolling in folded texts via winline()
Removed Center function: already implemented as :ce
Explore no longer interacts with history
remap center as `k, add line feed
fixed c-r / s-r confusion
longpress to toggle fold
seamless way to deal with end of document scrolling
have logappend calculate offset (for normal mode appends)
invisible horizontal scrollbar on bottom
no autocap on elipse
yank for nested
reading mode: remember offset
long press to go to link
Reformat folding, remove reading mode autocommands
longpresses are activated on timeout
fixed wacky log time display
fixed cmdnorm cursor sticking around
single esc to get out of autocap, use uppercase to avoid transformation
synergize autocap and tmenu
no new line autocap if option not set
change log visualizations to pagers
[pager] T/op
pager constructor can now set cursor / offset
add option to hide numbers on pager (default)
changed folding to marker (from expr)
fully swap g, gj, k, gk
backspace / esc bug for autocap
synergize mouse scrolling and statusline / split dragging
changed fold to display line number
editmru now edits input if no match was found
log histogram accounts for current task
combined histogram & printlog
shownum, default statusline for pager
separate histogram mode and chart mode
shortcut for se invwrap
included day of week in date display
fixed viminfo bug (&vi was being reset to default)
changed seach hl quick command to toggle
changed foldtext to display custom marks
cleared args before mksession to prevent unnecessary file loading
curdevice for device specific settings
changed tmenu trigger to _
changed autocap cursor to ^
added option to [S]ave and [L]oad color schemes
last scheme name default entry for load color scheme
change color chooser from C to c
use /f to automcomplete {{{
added () to distinguish folds, removed fold centering
variable maxQselsize for Qsel list length
added cygwin customizations (must define Cyg_Working_Dir... confusing as hell)
Writeroom(margin) function for wide screens
Mapped normal c-n c-p to search for folds
opt_DisableAutocap added
Changed Writeroom to take percentage
Autoexit after saving a color scheme
added ^W to activate writeroom in normD
moved device-dependent settings to main vimrc file
Cygwin: added ^C and ^V (clipboard) visual mode bindings
added u/nformat to visD
autoexit after loading a color scheme
[Cygwin] Cursor changes shape based on mode
[Cygwin] innoremap escape to escape-escape to prevent delay
set nocompatible to avoid absurd errors
notepad mode (set Cur_RunAs='notepad') with ^W ^S nmaps
added option to set colorscheme (set opt_colorscheme), eliminated unnecessary persistent vars
`il `iw for invlist, invwrap in normal / insert mode
mutline fFtT for prose
Eliminate longpress to expand folds for Cygwin by setting opt_LongPressTimeout
Mouse now continues scrolling even for low timeouts if there is no fold or no jump under cursor
mintty: `< anc `> to adjust font size
no Mscroll for cygwin
added `C to visD to copy and unwrap lines
CheckFormatted: set wrap and autoformat options to execute after loading modelines, simplifying detection
streamlined opt_TenuKey to change keymenu  
cygwin: set timeoutlen=1 to avoid delay when exiting insert mode
software caps lock for insert mode via `a
TD: Command to jump to previous cursor position?
Middle click to close split or tab
added `it `is to toggle tab bar and status line
updated visual `x to work on all lines
`tb to tggle bookmark visibility
remapped `1 ... `9 to switch tabs
remapped arrow keys to alt-hjkl
removed `< and `>, duplicates ctrl++ and ctrl+-
altered checkformatted to check for fo=aw versus fo=a
fixed A or I at beginning or end of line bug for checkformatted
Used dictionary with InvertSetting()
optimize: replace has_key() with get() in some instances
turn recursion into loop in TMenu
`<f1> and `<f2> for scrolling through buffers
define EscAsc at beginning of file so that dictionaries can now be defined anywhere
incorporated safeseach commands (SS, S) to keep search history when searching
mapped v_g and n_g to avoid timeout commands
v_gU to change to title case
`X to execute inner paragraph
logically streamlined TMenu
remove arrow key remappings, due to ^n ^p
gA to move to end of line (regardless of autoformat)
vgP to select inner paragraph on formatted mode
added command mappings for arrows, c-h, c-j, etc.
removed +/- to jump to heading
Scrollbar, toggle via B
disable scrollbar/bookmarks if version lacks signs
no longer writes variables, WriteVar() now writes to saveD by default if no argument supplied
changed do_once to firstrun
varsave no longer activates on :wa
T command for edit in new tb
mapped space and tab / bkspace to c-e, c-y in normal
added current state to toggle menu
322: minor bug with tabline highlighting
minor bug with loading default colorscheme
allow possibility of multiple device matches, obviate cur_runas
remap space, tab, and backspace in normal mode to scroll for all devices
simplify variable backup scheme: once a day, no varsaves
remove Qsel
rewrote history function, with PRUNE (untested).
recent history browser, with sort by date / name
use viminfo to save lists and dicts, no more varsaves
option to dim inactive window (`<tab>D)
merged invertD with normD
updated normD help menu
cleared n_c-i, remapped <f1> to scroll up
custom help messages for all Tmenus, reorganized dictionary definitions
fixed VARSAV_8 etc staying in memory
Tmenu S for scrollbind, matching line numbers
Recent files: t to open in new tab, quit on edit command
Tmeni io for next, prev tab
replaced tmenu with Qmenu, no more opt_tmenukey, no more insert menu
auto-name folds without title
replaced all ascii functions with ascii table qg
generalzed printdic to all dictionaries and not just string dictionaries
droid4 doesn't supprt %S in printf?
hopefully fixed leftmouse being unable to select tabs
merged SCHEMES and SWATCHES, swapped qc, qC, made caps more convenient
set minimum split width, wiw=72
need some scheme for saving settings
paragraph mode for folding
Have checkformatted recognize more predefined formatting (hardwrap, foldmark, foldpara)
rightmouse to fold and unfold
foldpara text now shows markings if the first to chars are the same
qw qW to navigate splits, qr now wraps
qw respects scrollbind
set wiw to wrap width if autoformat
removed a few unnecessary toggle variables
manually enter colors
can now choose NONE as color
solarized color schemes
change keys in dic
[pager] now sorts keys
cleaned up / optimized ridiculous nestedprint
[pager] handles extreme window cases
[pager] now uses full screen, no more more, no more resizing
fixed vimrc bug introduced with removing varsav
[pager] eval changed to E
use printdic in all pagerfunctions as help
[pager] / searches
q: for command line normal
greatly simplified printchart for Log
changed lf to open and close folds, may not be portable
Classes are no longer stored, vars are reinitialized
Merged dictionary and list functions for pager
mruf now listed under pager, chaned to FileList
restore old viminfo settings since obviating varsave
move all $MYVIMRC settings to vimrc
implemented solarized for cygwin
unlet Vars after saving them to avoid duplicate entries in patched versions of vim
writevimstate, restorevars can now be called at any time
saving now writes more natural names, X saved under SAVED_X
finally, qmenu not dependant on logdic, via 'try'
prettify, optimize qmenu
pretty major mruf logical bug
removed autocommands from ReloadVars
ensure Lkeys and L were syncing when adding new keys
made sure vim runs okay on minimal settings, better fallback for qmenu
expand normal gj gk to visual as well
minor bug in applying checkformatted movement mappings {}
remove TODO from vim startup items
logidic now starts at last row on startup
prettify asciidic
space between columns in nestedlist
nestedlist now does not truncate unnecessarily on expand
further nestedprint optimizations
pager.setcursor for noninteractive manipulations
colorized nested list!
no redraws for nestedlist when recolors suffices
removed se nocompatible -- was resetting &history
remove wiw settings in checkformatted since setting is global
qV to write viminfo file
added gj / j swap to gvmap
simplified fold paragraph
[nestedlist] fixed dictionary highlight path by adding 'displaypath'
[dropsync] Prompt to load dropsync conflicted files if new version is detected
[nestedlist] fixed highlight bug when path goes all the way across!
softcap now combines undos, has cursor
[droid4] remap rightshift-2 to @
Chat mode! via Dialogue()
removed Cygwin_Working_Directory
[chat] enter on blank entry to switch speakers
windows tweaks
RestoreSettings command wrapper for RestoreVimState()
A more informiatve message to resolve viminfo conflicts
remap ctrl-bkspace to c-w in cmode too
R to undo for all systems (too confusing)
small bug in @ mapping
Blockwise text with Annotate()
[log] LogClear (C)
caps lock bug: remaped shift-bs to bs for droid4
nargs should be + not 1 for escape chars in RestoreSettings
possble bug in hour format in dropsync?
enabled diff in droid4
:qnv quit without writing viminfo
Dialog can be used for formatted paragraphs
Breaklines now breaks at &brk
[Mscroll] now handles horizontal scrolling
[Mscroll] horizontal scrolling enabled by 'se ve=all'
[Prose] *Bold* and /italics/
[Logdic] 'start' replaced with '-'
[Mscroll] use redr (without !) on vert scroll
Single undo x/X, x/X doesn't alter register
Echo messages for q settings for wrap, virtualedit
<353> Simplify qw/qW (no need for &scb consideration)
qS now toggles, echos
droid4 now uses separate viminfo
x now no longer moves cusor
bold and italics works over multiple lines
complex logic for correct entry in "x for long deletes
x works with counts
qC now automatically prompts for group
*bold* /italics/ now matches at beginning of line
qG goes to section end (last non-whitespace before blank lines)
minor but old variable mismatch bug (needed to use unlet) in CSChooser
minor bug in load color scheme, used unlet! instead of unlet
echo state for Writeroom
Nocompatible setting for notepad (using command line, 'vim -uC', won't work???)
Softcap: use startinsert! for end of line
Softcap: added c-h as shortcut for insert mode
colorscheme now remembers last scheme loaded.
tab now scrolls up
qm now toggles panning mode
moved mousepan from vimrc to nav.vim to make nav.vim independent
[nav] added exists('opt_device') check for compatibility
[nav] InitPlane loading message
[nav] PanMode now local to tab
[cs] default color scheme name changed on save (and not just load)
[nav] replace wincmd resizing with :vert res
[nav] pause during automatic mouse mode switch to display error message
[nav] set scrollopt=jump (and not scrollopt=) to prevent flickering on scrolloff
[nav] set noea just in case it improves efficiency
moved block text functions to code graveyard
[q] qF now toggles both statusline and tabline
changed BufWinEnter to BufRead for mappings
[nav] opt_disable_syntax_while_panning
[cs] echon used for fg / bg
known issue: CSChooser clears cmaps <bs> . =
[cs] complete rehaul based on command line input
[cs] ^X to delete group
[cs] removed help messages for CS
[nav] lots of minor optimizations to panleft for heavy-use cases
[nav] TogglePanMode restores from previous session
[cs] can use +/- to toggle other attributes
[cs] HJ now sets fg / bg to 'NONE'
[q] removed: qL Load colorscheme
[issue] windows doesn't support %s in strftime
[cs] Enter now no longer exits
[cs] press L to link 
[cs] Swatches now displayed on load
set ttimeoutlen=10
[cs] [e]dit - current settings as default text, error checking
f1 i-mapped to Ctrl-Ozh
ctrl-bs, ctrl-w now works in Softcaps()                                                  
[opt_cygwin] map ctrl-hjkl to arrow keys for all modes (especially tab completion)
[nav] prettify InitPlane message
<360> [cs] hjkl to navigates fields
[cs] remove pn for navigating swatches, can only save and load now
[cs] Go to Link
[cs] Change redr to redr! for some cases, minor error catching
[q] qw, qe now goes back / foward in jumplist
[q] qg now prints out ascii under cursor, char for number under cursor, and waits for user input
[q] tabswitching remapped to space / tab
fixed norm! A when formatting is enabled and ve is enabled, will no longer jump to file end
Bold and Underline now heave concealed ends (when &cole is set)
[issue] resetting statusbar within mouseclick causes jumping
Incredibly stupid CS_hi() link bug
Undojx now echos correctly
gd delete surround v1
[nav] RedrawPlane() to restore plane based on currently active column
[nav] changed leftabove to topleft
[nav] RedrawPlane() restores cursor position
[nav] ReinitializePlane() now works on single column (assuming NAV_NAMES, etc. valid)
minor qG (go to section end) bug
[nav] remove LCol / RCol as global variables
[nav] Redraw now checks whether file names match
[nav] PanLeft/right now throws exceptions, returns extra shift amount
[nav] TogglePanMode removed
[nav] Keyboard panning v1
[nav] helpful error message for when t:txP doesn't exist
[nav] redraw now fixes alignment
[cs] load current highlight if group undefined in colorscheme
qmenu leftmouse does not show help menu
(finally) implemented multiline f/t for visual mode
omap a/: eg, da/ (multiline!)
removed manual reinflate since storing nested lists to viminfo seems to work
norm! ga was overwriting last line of PrintDic
prettify q-menu printing
[nav] automatically switch windows when one reaches end of doc
[nav] mouse panning works in KeyboardPan
gA appends to end of paragraph
vmap s<char> to surround selection with braces
[nav] make mouse always pans cols when KeyboardPan is active
enter maps to '+'
consistent CS_ variable names
map f1 to zh in normal mode too
[nav] helpful message for creating planes
[nav] use introduction incorporated into fuction
[nav] eliminated opt_mousepan
f3, f5 now works only if t:txP is loaded
f1 Prints help mssage
[nav] scrollbinding now a global option
[nav] merge HelpfulPlaneWizard and CreatePlane
[nav] shift certain messages back to throw
[nav] fully inline help message
[nav] pressing f3 will now access all plane commands
[nav] ShiftView v1 to go to a particular line and column
[nav] CenterView / Centerbookmark
[nav] echo currently active windows if there is no statusbar
[nav] hackish workaround to getchar() dropping leftrelease occasionally
[nav] minor bug when keyboard panning after mouse panning
minor bug involving 'dead' qF command on first use
idiotic nmap f1 bug
[nav] keyboard nav will no longer go past top of screen
qf jumps to function declaration
[nav] changed syncbind to exe "norm! :syncbind\<cr>"
minor bug: redraw will now respect left scrolloff on first (or only) column
[nav] mesages enabled in keyboardpan
[nav] Shiftview now works both ways (having destination column be between -txP.len and 2*txP.len-1)
[nav] Bookmark now takes shortest route
[nav] Prettified bookmark enter
[nav] changed redundant line.Gzt to line.zt
greatly simplied qG, echo line numbers
[nav] optimize MousePanCol + no more graphical glitches!!
q menu prints tabs and splits if statusline and tabline are hidden
[nav] E315 now caught
[nav] txp_hotkey for easy hotkey changes
[nav] Insert and delete column
[nav] MousePan echos message if there is no statusbar
[nav] Shiftview revamped
Debug PRINT(str) function
Both ql and qL works for log menu
Bold and Underline now works on WORDS rather than on non-whitespaces
Text Links of the form file@linenumber
Put location reference here (navkey->g)
[nav] mousepan no longer goes past beginning of window
remapped Q to plane functions, <c-r> to 'record'
[nav] changelist v1
qG will jump to previous section break if none found
q<tab>/<space> will 'keep up dashboard'
Changed qw/e changelist scrolling to keep up dashboard
revert: line number position in qmenu
the return of writeroom, optimiazed (left col only)
writeroom will only suggest minimum margin of 10
vno S now automatically trims whitespaces
vno T now strips outer parentheses, ignoring whitespaces
[nav] mousepancol now works with &wrap (after sinister bug)
[nav] autoexe as global variable in 'user settings'
[nav] fixed bug when wrapped window is first column
[nav] Removed loading message when loading new window
[nav] Dialog for editing current settings / relocating column
qg ascii dic now puts entry in cut register
[nav] debugged wrap and long cols for PanL/R
[nav] redraw reloads current window
[nav] redraw remapped to r
[nav] fixed winnr('$')>9 glitches, mostly (and also uncovered a long undiscovered bug!)
[nav] added check for mouseclick that would change tabs into mousepancol
[nav] always set cul during getchar loop (both kybdpan and Qmenu)
[nav] RELEEEAAASSEEE111111111111
black magic to remove tab bar toggle jitter
revamped qmenu to show and hide statusbar and tabbar
remapped G,gg to go to jump to 'section breaks' and not end or beginning of line
add close / move tab to Qmenu cycle
[nav] subtle bug in pan right involving windows of width 1
[nav] more helpful mousepan message
removed opt_colorscheme, now uses separate viminfo instead
random foreground AND background for CS_UI
[cs] edit edits only current field
[cs] c-backspace now works
Remapped nav-hotkey (f10) to qn
cuc highlighting only
added resizing splits to qmenu cycle
[nav] redraw and quit mapped to r, redraw to R
[nav] nasty redraw bug involving pre/post decrement
[nav] change kbdpan message to match that of mousepan
[nav] added a few final echos
[nav] edgy name change, script-local functions
PRINT now no longer has empty parenthesis as default input entry
[cs] allow ctrl-backspace for editing cs_name
[cs] ^Reload
[nav] hotkey now raw
[nav] Previous plane saved in between sessions (as suggestion)
[nav] Separated help message and prompt: prompt is now only for when t:txb doesn't exist
[nav] regression: hotkey now a name
Goal: Cyberpunk home
[cs] starts with color group under cursor
[nav] esc in nav-E immediately quits
'dG/gg' now works (ie, with G going to end of section)
[nav] glob() uses only 1 argument for compatibility
eliminated a few globals
minor bug involving escaping spaces in MRUF
[nav] nasty bug in panright involving autoshifting on hide for small winwidths
[nav] block_pan mostly works
[nav] big_block_pan mostly works
[nav] retore txbcmd help message
[nav] display block name
[nav] Gotoblock
[nav] obviated BigBlockPan()
[nav] coordinates mostly works
[nav] synergized qmenu and nav menu
PRINT now splits at '|' and not ','
qf now works for local functions
[nav] suggests name for next column on append call
[nav] appendcol and loadplane checks block names length
[nav] vicious bug involving panning to long lines
q<f5> now toggles debug mode (PRINT functions)
whoa! setting wrap *and* hardwrap seems to fix narrow column issue!
[nav] splits now automatically open wrapped
[nav] elaborate solution for bgridpan left and right
[nav] cursor screen position now stays constant when panning grid
nasty esc bug in G,gg
[nav] Added inbuilt monologue
[nav] removed cursorhighlight
whoa! the best way to display seems to be ch=1 & redr!|ec
[nav] mousing during txbcmd exits
[nav] complex conditions for blockpanning simply staying still
[nav] snap to big grid
all unassigned keys automatically assigned to Qnrm
[nav] TXBcmds now global
skeleton file of 500 blank lines for plane* (in vimrc)
map display function is done
map now expands and changes
[nav] map incorporated!
removed qp (plane hotkey) mapping from Qnrm
[nav] no spaces in map
[nav] synergize append / delete col
[nav] streamlined -- removed bookmark, changelist
G/gg now works when there are whitepsaces between the new lines
Ed works with multiline entries..
{} in wordwrap now works as motions
TODO EMPTY
[nav] zoom in and Out on blocks!
[nav] First start fixes
[nav] RELEAAAAAAAASSEEE!!!!111!!!!!! 1.2 (on vim.org)
[nav] map: insert / delete
[nav] messaging system for map
q-f1 now automatically jumps to help file
[nav] Align right for FormatPar
[nav] hard error check to bug where rightmost col becomes decentered on vert res in panright
WONT FIX: weird panleft bug where there rightmost split is 1 and it pushes and narrows he previous split
[nav] - Minor bug with map when horizontal block size divides columns
removed cursorcolumn highlighting for match highlighting of cursor position
revamped mouse nav using feedkeys()
[nav] cursor remains fixed when navigating and panning
[nav] weird bug with restore position (changing windows will sidescroll)
bug?: implications of changing windows causing sidescroll? <f10>c-j<f-10>c-k
[nav] C-YUBNHJKL navigates within grid

#todo
mouse nav for map????? -- works for all cases except when the click is past the end -- just print an error message ('vim limitation') ... or just go to a new tab with map????? :D
	mouse *drag* for map???? -- right click for map? zoom in and out????

#deferred
(in vimrc?) No need to compile, but just highlight the space that needs to be deleted (or appended) and warn about nonwhitetext -- (not block number but raw line number)  / macro to insert line number
mousepanwin doesn't work when wrap is on and the wrapped paragraph is HUGE
