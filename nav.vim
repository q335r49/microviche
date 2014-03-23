"Hosted at https://github.com/q335r49/textabyss

if &cp|se nocompatible|en              "[Vital] Enable vim features
se noequalalways                       "[Vital] Needed for correct panning
se winwidth=1                          "[Vital] Needed for correct panning
se winminwidth=0                       "[Vital] Needed For correct panning
se viminfo+=!                          "Needed to save map and plane in between sessions
se sidescroll=1                        "Smoother panning
se nostartofline                       "Keeps cursor in the same position when panning
se mouse=a                             "Enables mouse
se lazyredraw                          "Less redraws
se virtualedit=all                     "Makes leftmost split align correctly
se hidden                              "Suppresses error messages when a modified buffer pans offscreen
hi default link TXBmapSel Visual       "default hilight for map label selection
hi default link TXBmapSelEmpty Visual  "default hilight for map empty selection
se scrolloff=0                         "ensures correct vertical panning

if !exists('g:TXB_HOTKEY')
	let g:TXB_HOTKEY='<f10>'
en
exe 'nn <silent>' g:TXB_HOTKEY ':call {exists("w:txbi")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'
augroup TXB
	au!
	au VimEnter * if stridx(maparg('<f10>'),'TXB')!=-1 | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' g:TXB_HOTKEY ':call {exists("w:txbi")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'
augroup END

if !has("gui_running")
	fun! <SID>centerCursor(row,col)
		let restoreView='norm! '.virtcol('.').'|'
		call s:redraw()
		call s:nav(a:col/2-&columns/4)
		let dy=&lines/4-a:row/2
		exe dy>0? restoreView.dy."\<c-y>" : dy<0? restoreView.(-dy)."\<c-e>" : restoreView
	endfun
	augroup TXB
		au VimResized * if exists('w:txbi') | call <SID>centerCursor(winline(),eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')) | en
	augroup END
	nn <silent> <leftmouse> :exe get(TXBmsCmd,&ttymouse,TXBmsCmd.default)()<cr>
else
	nn <silent> <leftmouse> :exe <SID>initDragDefault()<cr>
en

fun! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

let TXBmsCmd={}
let TXBkyCmd={}

let s:help_bookmark=0
fun! s:printHelp()
	redir => laggyAu
		silent au BufEnter
		silent au BufLeave
		silent au WinEnter
		silent au WinLeave
	redir END
	let ttymouseWorks=!has('gui_running') && (has('unix') || has('vms'))
	let WarningsAndSuggestions=
	\ (v:version<703 || v:version==703 && !has('patch106')? "\n> Warning: Vim < 7.3.106 - Scrollbind won't sync on mouse panning until you release the mouse button": '')
	\.(v:version<703 || v:version==703 && !has('patch30')?  "\n> Warning: Vim < 7.3.30 - The plane can't be saved in the viminfo, but you can still write to file with [hotkey] W." : '')
	\.(len(split(laggyAu,"\n"))>4? "\n> Warning: Autocommands may slow down mouse - Possible mouse lag due to BufEnter, BufLeave, WinEnter, and WinLeave triggering during panning. Perhaps slim down those autocommands (':au Bufenter' to list) or use 'BufRead' or 'BufHidden'?" : '')
	\.(has('gui_running')? "\n> Warning: gVim - Resizing occurs unpredictably in gVim and automatic redrawing on resize has been disabled. Press [hotkey] r or ':call TXBdoCmd('r')' to redraw" : '')
	\.(&ttymouse==?'xterm'? "\n> Warning: Incompatible ttymouse setting - Panning disabled because ttymouse is 'xterm'. ':set ttymouse=xterm2' or 'sgr' is recommended." : '')
	\.(ttymouseWorks && &ttymouse!=?'xterm2' && &ttymouse!=?'sgr'? "\n> Suggestion: 'set ttymouse=xterm2' or 'sgr', if possible, allows mouse panning in map mode and overall smoother panning." : '')
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	let s:help_bookmark=s:pager(s:formatPar("\nWelcome to Textabyss v1.7! (github.com/q335r49/textabyss)\n"
	\.(empty(WarningsAndSuggestions)? "\nWarnings and Suggestions: (none)\n" : "\nWarnings and Suggestions:".WarningsAndSuggestions."\n")
	\."\nCurrent hotkey: ".g:TXB_HOTKEY."\n
	\\n\\CSTARTING UP:\n\nNavigate to the WORKING DIRECTORY (you only have to do this when you first create a plane). Press [hotkey] to bring up a prompt. You can try a pattern, eg '*.txt', or you can enter a file name and later [A]ppend others.\n
	\\nYou can now use the MOUSE to pan, or press [hotkey] followed by:
	\\n[1] h j k l y u b n      Pan cardinally & diagonally
	\\n[2] r R L                redraw / Remap / Label
	\\n    o                    Open map
	\\n    D A                  Delete / Append split
	\\n    <f1>                 Show this message
	\\n[3] S                    Settings
	\\n    W                    Write to file
	\\n    ^X                   Delete hidden buffers
	\\n    q <esc>              Abort
	\\n----------
	\\n(1) Movement keys take counts, capped at 99. Eg, '3j' = 'jjj'.
	\\n(2) Lines of the form 'txb[:line num][: label#highlght#position]' are used to generate autolabels. You can insert the 'txb:[line num]' with [L]abel instead of typing it out.
	\\n[R]emap (in addition to [r]edrawing):
	\\n+ moves labels to [line num] by inserting or removing blank lines directly above
	\\n+ sets the map cell to [label#highlight#position] (see MAP MODE (2) below)
	\\nExamples:
	\\n    txb:345 Blah blah    Move to 345
	\\n    txb:345: Blah blah   Move to 345, label map 'Blah blah'
	\\n    txb: Blah#Title#CM   Label 'Blah', highlight 'Title', position 'CM'
	\\n    txb: Blah##CM        Label 'Blah', position 'CM'
	\\n    txb: Blah###Ignored  Label 'Blah'
	\\n(3) If [hotkey] becomes inaccessible, reset via: ':call TXBinit()', press S
	\\n\n\\CMAP MODE:\n
	\\n[1] h j k l y u b n      Move cardinally & diagonally
	\\n    0 $                  Beginning / end of line
	\\n    H M L                High / Middle / Low of screen
	\\n    x                    Clear and obtain cell
	\\n    o O                  Obtain cell / Obtain column
	\\n    p P                  Put obtained after / before
	\\n[2] c                    Change label, color, position
	\\n    .                    (in plane) execute label position
	\\n    g <cr>               Go to block and exit map
	\\n    I D                  Insert / Delete and obtain column
	\\n    Z                    Adjust map block size
	\\n    T                    Toggle color
	\\n    q                    Quit"
	\.(ttymouseWorks? "\n[3] doubleclick          Go to block
	\\n    drag                 Pan
	\\n    click NW corner      Quit
	\\n    drag to NW corner    (in the plane) Show map
	\\n----------
	\\n(1) Movements take counts, capped at 99. Eg, '3j' = 'jjj'.\n(2)"
	\:"\n    [Mouse in map mode is unsupported in gVim or Windows]\n----------\n(1) Movements take counts, capped at 99. Eg, '3j'='jjj'.\n(2)")
	\." You can press <tab> to autocomplete from currently defined highlights.
	\\nPositioning commands move the jump from its default position (split at left edge, cursor at NW corner). Eg, 'CM' [C]enters the split and scrolls so the cursor is at the [M]iddle. The full list of commmands is:
	\\n    j k l                Cursor up / down / right
	\\n    s                    Shift view left 1 split
	\\n    r R                  Shift view down / up 1 row
	\\n    C                    Centered split horizontally (ignore s)
	\\n    M                    Center cursor vertically (ignore r R)
	\\n    W                    Virtual width (see below)
	\\nBy default, 's' won't shift the split offscreen but only push it to the right edge; a virtual width changes this limit. Eg, '99s15W' would shift up to the point where only 15 columns are visible regardless of actual width. 'C' is similarly altered."
	\.(ttymouseWorks? "\n(3) The mouse only works when ttymouse is xterm, xterm2 or sgr. The 'hotcorner' is disabled for xterm." : "")
	\."\n\n\\CTIPS:\n\n* Editing the file you [hotkey][W]rote is an easy way to change settings.
	\\n* HORIZONTAL SPLITS interfere with panning, consider using tabs instead.
	\\n* When working at the end of a LONG SPLIT you may experience jumps when leaving that split because Vim can't scroll past the end of the file. One solution would be to pad blank lines so the working area is mostly a rectangle.",width,(&columns-width)/2),s:help_bookmark)
endfun
let TXBkyCmd["\<f1>"]='call s:printHelp()|let s:kc_continue=0'

fun! TXBinit(...)
	se noequalalways winwidth=1 winminwidth=0
	let [more,&more]=[&more,0]
	let seed=a:0? a:1 : -99
	let msg=''
	if seed is -99
		if exists('g:TXB') && type(g:TXB)==4
			let plane=deepcopy(g:TXB)
		else
			let plane={'name':[]}
		en
	elseif type(seed)==4
   		let plane=deepcopy(seed)
	elseif type(seed)==1
		let plane={'name':split(glob(seed),"\n")}
	else
		echoerr "Argument must be dictionary {'name':[list of files], ... } or string filepattern"
		return 1
	en
	let default={'working dir':getcwd(),'map cell width':5, 'map cell height':2,'split width':60,'autoexe':'se nowrap scb cole=2','lines panned by j,k':15,'kbd x pan speed':9,'kbd y pan speed':2,'mouse pan speed':[0,1,2,4,7,10,15,21,24,27],'lines per map grid':45}
	if !exists('plane.settings')
		let plane.settings=default
	else
		for i in keys(default)
			if !has_key(plane.settings,i)
				let plane.settings[i]=default[i]
			else
				let cursor=0
				let vals=[1]
				let smsg=''
				unlet! input
				let input=plane.settings[i]
				silent! exe get(s:ErrorCheck,i,['',''])[1]
				if !empty(smsg)
					let plane.settings[i]=default[i]
					let msg="\n**WARNING** Invalid Setting: ".i."\n    ".smsg."\n    Default setting used".msg
				en
			en
		endfor
	en
	let plane.settings['working dir']=fnamemodify(plane.settings['working dir'],':p')
	if !exists('plane.size')
		let plane.size=repeat([60],len(plane.name))
	elseif len(plane.size)<len(plane.name)
		call extend(plane.size,repeat([exists("plane.settings['split width']")? plane.settings['split width'] : 60],len(plane.name)-len(plane.size)))
	en
	if !exists('plane.map')
		let plane.map=[[]]
	en
	if !exists('plane.exe')
		let plane.exe=repeat([plane.settings.autoexe],len(plane.name))
	elseif len(plane.exe)<len(plane.name)
		call extend(plane.exe,repeat([plane.settings.autoexe],len(plane.name)-len(plane.exe)))
	en
    let prevwd=getcwd()
	exe 'cd' fnameescape(plane.settings['working dir'])
	let filtered=[]
	let plane_name_save=copy(plane.name)
	let abs_paths=map(copy(plane.name),'fnameescape(fnamemodify(v:val,":p"))')
	for i in range(len(plane.name)-1,0,-1)
		if !filereadable(plane.name[i])
			call add(filtered,remove(plane.name,i))
			call remove(plane.size,i)	
			call remove(plane.exe,i)	
			call remove(abs_paths,i)
		en
	endfor
	exe 'cd' fnameescape(prevwd)
	let msg=(empty(plane.name)? '' : "\n ---- readable ----\n".join(s:formatPar(join(plane.name,', '),&columns-2,0),"\n")."\n")
	\.(empty(filtered)? '' : "\n ---- unreadable or directory ----\n".join(s:formatPar(join(filtered,', '),&columns-2,0),"\n")."\n")
	\."\n".len(plane.name)." readable, ".len(filtered)." unreadable or directory in working dir: ".plane.settings['working dir']."\n".msg
	if !empty(plane.name)
		let curbufix=index(abs_paths,fnameescape(fnamemodify(expand('%'),':p')))
		if curbufix!=-1
			let restoremsg=" in CURRENT tab"
		else
			let restoremsg=" in NEW tab"
		en
		if seed is -99
			if !empty(filtered)
				let msg.="\n**WARNING**\n    Unreadable file(s) will be REMOVED from the plane! You typically don't want this!\n    This is often because the WORKING DIRECTORY is wrong (change by pressing 'S')"
				let msg.="\n\n-> [R]emove unreadable and load last session".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[82]
			else
				let msg.="\n -> [enter] load last session".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[10,13]
			en
		elseif type(seed)==4
			if !empty(filtered)
				let msg.="\n**WARNING**\n    Unreadable file(s) will be REMOVED from the plane! You typically don't want this!\n    This is often because the WORKING DIRECTORY is wrong (change by pressing 'S')"
				if exists('g:TXB') && type(g:TXB)==4
					let msg.="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo.\n    Save by loading last plane and pressing [hotkey] W."
				en
				let msg.="\n\n -> [R]emove unreadable, overwrite, and load ".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[82]
			elseif exists('g:TXB') && type(g:TXB)==4
				let msg.="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo.\n    Save by loading last plane and pressing [hotkey] W."
				let msg.="\n -> [O]verwrite and load".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[79]
			else
				let msg.="\n\n -> [enter] load".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[10,13]
			en
		elseif type(seed)==1
			if exists('g:TXB') && type(g:TXB)==4
				let msg.="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo.\n    Save by loading last plane and pressing [hotkey] W."
				let msg.="\n\n -> [O]verwrite and load".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[79]
			else
				let msg.="\n -> [enter] load".restoremsg." [S] settings [F1] help [esc] cancel"
				let confirm_keys=[10,13]
			en
		else
			let confirm_keys=[]
		en
		ec msg
		let c=getchar()
	elseif !empty(filtered) || type(seed)==4
		let confirm_keys=[]
		let msg.="\n(No readable files remain -- make sure working dir is correct)"
		let msg.="\n\n -> [S] Settings [F1] help [any other key] cancel"
		ec msg
		let c=getchar()
	else
		let confirm_keys=[]
		ec msg
		let c=0
	en
	if index(confirm_keys,c)!=-1
		if curbufix==-1 | tabe | en
		let g:TXB=plane
		let t:txb=plane
		let t:txb_len=len(t:txb.name)
	    let t:kpLn=t:txb.settings['lines panned by j,k']
		let t:kpSpH=t:txb.settings['kbd x pan speed']
		let t:kpSpV=t:txb.settings['kbd y pan speed']
		let t:msSp=t:txb.settings['mouse pan speed']
		let t:mp_L=t:txb.settings['lines per map grid']
		let t:mp_clH=t:txb.settings['map cell height']
		let t:mp_clW=t:txb.settings['map cell width']
		let t:txb_wd=t:txb.settings['working dir']
		let t:txb_name=abs_paths
		call filter(t:txb,'index(["exe","map","name","settings","size"],v:key)!=-1')
		call filter(t:txb.settings,'index(["working dir","writefile","split width","autoexe","map cell height","map cell width","lines panned by j,k","kbd x pan speed","kbd y pan speed","mouse pan speed","lines per map grid"],v:key)!=-1')
		call s:redraw()
	elseif c is "\<f1>"
		call s:printHelp() 
	elseif c is 83
		let t_dict=['##label##',g:TXB_HOTKEY,'##label##',plane.settings['working dir']]
		if s:settingsPager(['    -- Global --','hotkey','    -- Plane --','working dir'],t_dict,s:ErrorCheck)
			echo "\nApplying Settings ..."
			sleep 200m
			echon "."
			sleep 200m
			echon "."
			sleep 200m
			exe 'silent! nunmap' g:TXB_HOTKEY
			exe 'nn <silent>' t_dict[1] ':call {exists("w:txbi")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'
			let g:TXB_HOTKEY=t_dict[1]
			if seed is -99 && exists('g:TXB') && type(g:TXB)==4
				let g:TXB.settings['working dir']=fnamemodify(t_dict[3],'p:')
				call TXBinit(-99)
			else
				let plane.settings['working dir']=fnamemodify(t_dict[3],'p:')
				let plane.name=plane_name_save
				call TXBinit(plane)
			en
		else
			redr|echo "Cancelled"
		en
	else
		let input=input("\n> Enter file pattern or type HELP: ",'','file')
		if input==?'help'
			call s:printHelp()
		elseif !empty(input)
			call TXBinit(input)
		en
	en
	let &more=more
endfun

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! <SID>initDragDefault()
	if exists('w:txbi')
		call s:saveCursPos()
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:updateCursPos()
			let t_r=v:mouse_lnum/t:mp_L
			echon getwinvar(v:mouse_win,'txbi') '-' t_r ' ' get(get(t:txb.map,getwinvar(v:mouse_win,'txbi'),[]),t_r,'')[:&columns-9]
			return "keepj norm! \<leftmouse>"
		else
			let t_r=line('.')/t:mp_L
			let ecstr=w:txbi.' '.t_r.' '.get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
			while c!="\<leftrelease>"
				if v:mouse_win!=w0
					let w0=v:mouse_win
					exe "norm! \<leftmouse>"
					if !exists('w:txbi')
						return ''
					en
					let [b0,wrap]=[winbufnr(0),&wrap]
					let [x,y,offset]=wrap? [wincol(),line('w0')+winline(),0] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol()]
				else
					if wrap
						exe "norm! \<leftmouse>"
						let [nx,l0]=[wincol(),y-winline()]
					else
						let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
					en
					let [x,xs]=x && nx? [x,s:nav(x-nx)] : [x? x : nx,0]
					exe 'norm! '.bufwinnr(b0)."\<c-w>w".(l0>0? l0 : 1).'zt'
					let [x,y]=[wrap? v:mouse_win>1? x : nx+xs : x, l0>0? y : y-l0+1]
					redr
					ec ecstr
				en
				let c=getchar()
				while c!="\<leftdrag>" && c!="\<leftrelease>"
					let c=getchar()
				endwhile
			endwhile
		en
		call s:updateCursPos()
		let t_r=line('.')/t:mp_L
		echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
	else
		let possav=[bufnr('%')]+getpos('.')[1:]
		call feedkeys("\<leftmouse>")
		call getchar()
		exe v:mouse_win."winc w"
		if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
			if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
			return "keepj norm! \<leftmouse>" | en
		exe "norm! \<leftmouse>"
		redr!
		let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
		let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(exists('g:opt_device') && g:opt_device==?'droid4' && veon)? 'redr!':'redr']
		let c=getchar()
		if c=="\<leftdrag>"
			while c=="\<leftdrag>"
				let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
				let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
				call winrestview(v)
				exe redrexpr
				let c=getchar()
			endwhile
		else
			return "keepj norm! \<leftmouse>"
		en
		if str2float(reltimestr(reltime(tl[(fr+1)%4][0])))<0.2
			let [glv,glh,vc,hc]=[tl[0][1]+tl[1][1]+tl[2][1]+tl[3][1],tl[0][2]+tl[1][2]+tl[2][2]+tl[3][2],0,0]
			let [tlx,lnx,glv,lcx,cax,glh]=(glv>3? ['y*v.topline>1','y*v.lnum>1',glv*glv] : glv<-3? ['-(y*v.topline<'.line('$').')','-(y*v.lnum<'.line('$').')',glv*glv] : [0,0,0])+(glh>3? ['x*v.leftcol>0','x*v.coladd>0',glh*glh] : glh<-3? ['-x','-x',glh*glh] : [0,0,0])
			while !getchar(1) && glv+glh
				let [y,x,vc,hc]=[vc>get(s:glidestep,glv,1),hc>get(s:glidestep,glh,1),vc+1,hc+1]
				if y||x
					let [v.topline,v.lnum,v.leftcol,v.coladd,glv,vc,glh,hc]-=[eval(tlx),eval(lnx),eval(lcx),eval(cax),y,y*vc,x,x*hc]
					call winrestview(v)
					exe redrexpr
				en
			endw
		en
		exe min([max([line('w0'),possav[1]]),line('w$')])
		let firstcol=virtcol('.')-wincol()+1
		let lastcol=firstcol+winwidth(0)-1
		let possav[3]=min([max([firstcol,possav[2]+possav[3]]),lastcol])
		exe "norm! ".possav[3]."|"
	en
	return ''
endfun
let TXBmsCmd.default=function("\<SNR>".s:SID()."_initDragDefault")

fun! <SID>initDragSGR()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			let t_r=line('.')/t:mp_L
			echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
		en
	elseif !exists('w:txbi')
		exe v:mouse_win.'winc w'
		if &wrap && (v:mouse_col%winwidth(0)==1 || v:mouse_lnum>line('w$')) || !&wrap && (v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum>line('w$'))
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:line0=line('w0')
		let s:dragHandler=function("s:navPlane")
		nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
	en
	return ''
endfun
fun! <SID>doDragSGR()
	let code=[getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)]
	let k=map(split(join(map(code,'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
		if exists('t:txb')
			if k[1:]==[1,1]
				call TXBdoCmd('o')
			elseif exists('w:txbi')
				let t_r=line('.')/t:mp_L
				echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
			en
		en
		return
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.sgr=function("\<SNR>".s:SID()."_initDragSGR")

fun! <SID>initDragXterm()
	return "norm! \<leftmouse>"
endfun
let TXBmsCmd.xterm=function("\<SNR>".s:SID()."_initDragXterm")

fun! <SID>initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			let t_r=line('.')/t:mp_L
			echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
		en
	elseif !exists('w:txbi')
		exe v:mouse_win.'winc w'
		if &wrap && (v:mouse_col%winwidth(0)==1 || v:mouse_lnum>line('w$')) || !&wrap && (v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum>line('w$'))
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:line0=line('w0')
		let s:dragHandler=function("s:navPlane")
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! <SID>doDragXterm2()
	let k=[getchar(0),getchar(0),getchar(0)]
	if k[0]==35
		nunmap <esc>[M
		if exists('t:txb')
			if k[1:]==[33,33]
				call TXBdoCmd('o')
			elseif exists('w:txbi')
				let t_r=line('.')/t:mp_L
				echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
			en
		en
		return
		TEST write to file
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.xterm2=function("\<SNR>".s:SID()."_initDragXterm2")

let s:panAcc=[0,1,2,4,7,10,15,21,24,27]
fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? get(s:panAcc,a:dy,s:panAcc[-1])."\<c-y>" : a:dy<0? get(s:panAcc,-a:dy,s:panAcc[-1])."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -get(t:msSp,a:dx,t:msSp[-1]) : get(t:msSp,-a:dx,t:msSp[-1]))
	if a:dy>0
		let spd=a:dy<len(t:msSp)? t:msSp[a:dy] : t:msSp[-1]
		let s:line0=s:line0>spd? s:line0-spd : 1
	else
		let s:line0=s:line0+get(t:msSp,-a:dy,t:msSp[-1])
	en
	let dif=line('w0')-s:line0
	if dif>0
		exe 'norm! '.dif."\<c-y>"
	elseif dif<0
		exe 'norm! '.-dif."\<c-e>"
	en
	let t_r=line('.')/t:mp_L
	echon w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9]
endfun

fun! s:getMapDisp()          
	let pad=repeat(' ',&columns+20)
	let s:disp_r=s:mp_cols*t:mp_clW+1
	let l=s:disp_r*t:mp_clH
	let templist=repeat([''],t:mp_clH)
	let last_entry_colored=copy(templist)
	let s:disp_selmap=map(range(s:mp_rows),'repeat([0],s:mp_cols)')
	let dispLines=[]
	let s:disp_color=[]
	let s:disp_colorv=[]
	let extend_color='call extend(s:disp_color,'.join(map(templist,'"colorix[".v:key."]"'),'+').')'
	let extend_colorv='call extend(s:disp_colorv,'.join(map(templist,'"colorvix[".v:key."]"'),'+').')'
	let let_colorix='let colorix=['.join(map(templist,'"[]"'),',').']'
	let let_colorvix=let_colorix[:8].'v'.let_colorix[9:]
	let let_occ='let occ=['.repeat("'',",t:mp_clH)[:-2].']'
	for i in range(s:mp_rows)
		exe let_occ
		exe let_colorix
		exe let_colorvix
		for j in range(s:mp_cols)
			if !exists("s:mp_array[s:mp_coff+j][s:mp_roff+i]") || empty(s:mp_array[s:mp_coff+j][s:mp_roff+i])
				let s:disp_selmap[i][j]=[i*l+j*t:mp_clW,0]
				continue
			en
			let k=0
			let cell_border=(j+1)*t:mp_clW
			while k<t:mp_clH && len(occ[k])>=cell_border
				let k+=1
			endw
			let parsed=split(s:mp_array[s:mp_coff+j][s:mp_roff+i],'#',1)
			if k==t:mp_clH
				let k=min(map(templist,'len(occ[v:key])*30+v:key'))%30
				if last_entry_colored[k]
					let colorix[k][-1]-=len(occ[k])-(cell_border-1)
				en
				let occ[k]=occ[k][:cell_border-2].parsed[0]
				let s:disp_selmap[i][j]=[i*l+k*s:disp_r+cell_border-1,len(parsed[0])]
			else
				let [s:disp_selmap[i][j],occ[k]]=len(occ[k])<j*t:mp_clW? [[i*l+k*s:disp_r+j*t:mp_clW,1],occ[k].pad[:j*t:mp_clW-len(occ[k])-1].parsed[0]] : [[i*l+k*s:disp_r+j*t:mp_clW+(len(occ[k])%t:mp_clW),1],occ[k].parsed[0]]
			en
			if len(parsed)>1
				call extend(colorix[k],[s:disp_selmap[i][j][0],s:disp_selmap[i][j][0]+len(parsed[0])])
				call extend(colorvix[k],['echoh NONE','echoh '.parsed[1]])
				let last_entry_colored[k]=1
			else
				let last_entry_colored[k]=0
			en
		endfor
		for z in range(t:mp_clH)
			if !empty(colorix[z]) && colorix[z][-1]%s:disp_r<colorix[z][-2]%s:disp_r
				let colorix[z][-1]-=colorix[z][-1]%s:disp_r
			en
		endfor
		exe extend_color
		exe extend_colorv
		let dispLines+=map(occ,'len(v:val)<s:mp_cols*t:mp_clW? v:val.pad[:s:mp_cols*t:mp_clW-len(v:val)-1]."\n" : v:val[:s:mp_cols*t:mp_clW-1]."\n"')
	endfor
	let s:disp_str=join(dispLines,'')
	call add(s:disp_color,99999)
	call add(s:disp_colorv,'echoh NONE')
endfun

fun! s:printMapDisp()
	let [sel,notempty]=s:disp_selmap[s:mp_r-s:mp_roff][s:mp_c-s:mp_coff]
	let colorl=len(s:disp_color)
	let p=0
	redr!
	if sel
		if sel>s:disp_color[0]
			if s:disp_color[0]
				exe s:disp_colorv[0]
				echon s:disp_str[0 : s:disp_color[0]-1]
			en
			let p=1
			while sel>s:disp_color[p]
				exe s:disp_colorv[p]
				echon s:disp_str[s:disp_color[p-1] : s:disp_color[p]-1]
				let p+=1
			endwhile
			exe s:disp_colorv[p]
			echon s:disp_str[s:disp_color[p-1]:sel-1]
		else
		 	exe s:disp_colorv[0]
			echon s:disp_str[:sel-1]
		en
	en
	if notempty
		let endmark=len(s:mp_array[s:mp_c][s:mp_r])
		let endmark=(sel+endmark)%s:disp_r<sel%s:disp_r? endmark-(sel+endmark)%s:disp_r-1 : endmark
		echohl TXBmapSel
		echon s:mp_array[s:mp_c][s:mp_r][:endmark-1]
		let endmark=sel+endmark
	else
		let endmark=sel+t:mp_clW
		echohl TXBmapSelEmpty
		echon s:disp_str[sel : endmark-1]
	en
	while s:disp_color[p]<endmark
		let p+=1
	endwhile
	exe s:disp_colorv[p]
	echon s:disp_str[endmark :s:disp_color[p]-1]
	for p in range(p+1,colorl-1)
		exe s:disp_colorv[p]
		echon s:disp_str[s:disp_color[p-1] : s:disp_color[p]-1]
	endfor
	echon s:mp_c '-' s:mp_r s:mp_msg
	let s:mp_msg=''
endfun
fun! s:printMapDispNoHL()
	redr!
	let [i,len]=s:disp_selmap[s:mp_r-s:mp_roff][s:mp_c-s:mp_coff]
	echon i? s:disp_str[0 : i-1] : ''
	if len
		let len=len(s:mp_array[s:mp_c][s:mp_r])
		let len=(i+len)%s:disp_r<i%s:disp_r? len-(i+len)%s:disp_r-1 : len
		echohl TXBmapSel
		echon s:mp_array[s:mp_c][s:mp_r][:len]
	else
		let len=t:mp_clW
		echohl TXBmapSelEmpty
		echon s:disp_str[i : i+len-1]
	en
	echohl NONE
	echon s:disp_str[i+len :] s:mp_c '-' s:mp_r s:mp_msg
	let s:mp_msg=''
endfun

fun! s:navMapKeyHandler(c)
	if a:c is -1
		if g:TXBmsmsg[0]==1
			let s:mp_prevcoord=copy(g:TXBmsmsg)
		elseif g:TXBmsmsg[0]==2
			if s:mp_prevcoord[1] && s:mp_prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
				let [s:mp_roff,s:mp_coff,s:mp_redr]=[max([0,s:mp_roff-(g:TXBmsmsg[2]-s:mp_prevcoord[2])/t:mp_clH]),max([0,s:mp_coff-(g:TXBmsmsg[1]-s:mp_prevcoord[1])/t:mp_clW]),0]
				let [s:mp_r,s:mp_c]=[s:mp_r<s:mp_roff? s:mp_roff : s:mp_r>=s:mp_roff+s:mp_rows? s:mp_roff+s:mp_rows-1 : s:mp_r,s:mp_c<s:mp_coff? s:mp_coff : s:mp_c>=s:mp_coff+s:mp_cols? s:mp_coff+s:mp_cols-1 : s:mp_c]
				call s:getMapDisp()
				call s:mp_displayfunc()
			en
			let s:mp_prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:mp_prevcoord[1])%t:mp_clW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:mp_prevcoord[2])%t:mp_clH]
		elseif g:TXBmsmsg[0]==3
			if g:TXBmsmsg==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:mp_settings
				return
			elseif s:mp_prevcoord[0]==1
				if &ttymouse=='xterm' && s:mp_prevcoord[1]!=g:TXBmsmsg[1] && s:mp_prevcoord[2]!=g:TXBmsmsg[2] 
					if s:mp_prevcoord[1] && s:mp_prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
						let [s:mp_roff,s:mp_coff,s:mp_redr]=[max([0,s:mp_roff-(g:TXBmsmsg[2]-s:mp_prevcoord[2])/t:mp_clH]),max([0,s:mp_coff-(g:TXBmsmsg[1]-s:mp_prevcoord[1])/t:mp_clW]),0]
						let [s:mp_r,s:mp_c]=[s:mp_r<s:mp_roff? s:mp_roff : s:mp_r>=s:mp_roff+s:mp_rows? s:mp_roff+s:mp_rows-1 : s:mp_r,s:mp_c<s:mp_coff? s:mp_coff : s:mp_c>=s:mp_coff+s:mp_cols? s:mp_coff+s:mp_cols-1 : s:mp_c]
						call s:getMapDisp()
						call s:mp_displayfunc()
					en
					let s:mp_prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:mp_prevcoord[1])%t:mp_clW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:mp_prevcoord[2])%t:mp_clH]
				else
					let s:mp_r=(g:TXBmsmsg[2]-&lines+&ch-1)/t:mp_clH+s:mp_roff
					let s:mp_c=(g:TXBmsmsg[1]-1)/t:mp_clW+s:mp_coff
					if [s:mp_r,s:mp_c]==s:mp_prevclick
						let [&ch,&more,&ls,&stal]=s:mp_settings
						call s:doSyntax(s:gotoPos(s:mp_c,t:mp_L*s:mp_r)? '' : get(split(get(get(s:mp_array,s:mp_c,[]),s:mp_r,''),'#',1),2,''))
						return
					en
					let s:mp_prevclick=[s:mp_r,s:mp_c]
					let s:mp_prevcoord=[0,0,0]
					let [roffn,coffn]=[s:mp_r<s:mp_roff? s:mp_r : s:mp_r>=s:mp_roff+s:mp_rows? s:mp_r-s:mp_rows+1 : s:mp_roff,s:mp_c<s:mp_coff? s:mp_c : s:mp_c>=s:mp_coff+s:mp_cols? s:mp_c-s:mp_cols+1 : s:mp_coff]
					if [s:mp_roff,s:mp_coff]!=[roffn,coffn] || s:mp_redr
						let [s:mp_roff,s:mp_coff,s:mp_redr]=[roffn,coffn,0]
						call s:getMapDisp()
					en
					call s:mp_displayfunc()
				en
			en
		elseif g:TXBmsmsg[0]==4
			let s:mp_roff=s:mp_roff>1? s:mp_roff-1 : 0
			let s:mp_r=s:mp_r>=s:mp_roff+s:mp_rows? s:mp_roff+s:mp_rows-1 : s:mp_r
			call s:getMapDisp()
			call s:mp_displayfunc()
			let s:mp_prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:mp_prevcoord[1])%t:mp_clW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:mp_prevcoord[2])%t:mp_clH]
		elseif g:TXBmsmsg[0]==5
			let s:mp_roff=s:mp_roff+1
			let s:mp_r=s:mp_r<s:mp_roff? s:mp_roff : s:mp_r
			call s:getMapDisp()
			call s:mp_displayfunc()
			let s:mp_prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:mp_prevcoord[1])%t:mp_clW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:mp_prevcoord[2])%t:mp_clH]
		en
		call feedkeys("\<plug>TxbY")
	else
		exe get(s:mapdict,a:c,'let s:mp_msg=" Press f1 for help or q to quit"')
		if s:mp_continue==1
			let [roffn,coffn]=[s:mp_r<s:mp_roff? s:mp_r : s:mp_r>=s:mp_roff+s:mp_rows? s:mp_r-s:mp_rows+1 : s:mp_roff,s:mp_c<s:mp_coff? s:mp_c : s:mp_c>=s:mp_coff+s:mp_cols? s:mp_c-s:mp_cols+1 : s:mp_coff]
			if [s:mp_roff,s:mp_coff]!=[roffn,coffn] || s:mp_redr
				let [s:mp_roff,s:mp_coff,s:mp_redr]=[roffn,coffn,0]
				call s:getMapDisp()
			en
			call s:mp_displayfunc()
			call feedkeys("\<plug>TxbY")
		elseif s:mp_continue==2
			let [&ch,&more,&ls,&stal]=s:mp_settings
			call s:doSyntax(s:gotoPos(s:mp_c,t:mp_L*s:mp_r)? '' : get(split(get(get(s:mp_array,s:mp_c,[]),s:mp_r,''),'#',1),2,''))
		else
			let [&ch,&more,&ls,&stal]=s:mp_settings
		en
	en
endfun

let TXBkyCmd.o='let s:kc_continue=0|cal s:navMap(t:txb.map,w:txbi,line(".")/t:mp_L)'
fun! s:navMap(array,c_ini,r_ini)
	let s:mp_num='01'
    let s:mp_posmes=(line('.')%t:mp_L? line('.')%t:mp_L.'j' : '').(virtcol('.')-1? virtcol('.')-1.'l' : '').'CM'
	let s:mp_initbk=[a:r_ini,a:c_ini]
	let s:mp_settings=[&ch,&more,&ls,&stal]
		let [&more,&ls,&stal]=[0,0,0]
		let &ch=&lines
	let s:mp_prevclick=[0,0]
	let s:mp_prevcoord=[0,0,0]
	let s:mp_array=a:array
	let s:mp_msg=''
	let s:mp_r=a:r_ini
	let s:mp_c=a:c_ini
	let s:mp_continue=1
	let s:mp_redr=1
	let s:mp_rows=(&ch-1)/t:mp_clH
	let s:mp_cols=(&columns-1)/t:mp_clW
	let s:mp_roff=max([s:mp_r-s:mp_rows/2,0])
	let s:mp_coff=max([s:mp_c-s:mp_cols/2,0])
	let s:mp_displayfunc=function('s:printMapDisp')
	call s:getMapDisp()
	call s:mp_displayfunc()
	let g:TXBkeyhandler=function("s:navMapKeyHandler")
	call feedkeys("\<plug>TxbY")
endfun
let s:last_yanked_is_column=0
let s:map_bookmark=0
let s:mapdict={"\e":"let s:mp_continue=0|redr",
\"\<f1>":'call s:printHelp()',
\"q":"let s:mp_continue=0",
\"l":"let s:mp_c+=s:mp_num|let s:mp_num='01'",
\"h":"let s:mp_c=max([s:mp_c-s:mp_num,0])|let s:mp_num='01'",
\"j":"let s:mp_r+=s:mp_num|let s:mp_num='01'",
\"k":"let s:mp_r=max([s:mp_r-s:mp_num,0])|let s:mp_num='01'",
\"\<right>":"let s:mp_c+=s:mp_num|let s:mp_num='01'",
\"\<left>":"let s:mp_c=max([s:mp_c-s:mp_num,0])|let s:mp_num='01'",
\"\<down>":"let s:mp_r+=s:mp_num|let s:mp_num='01'",
\"\<up>":"let s:mp_r=max([s:mp_r-s:mp_num,0])|let s:mp_num='01'",
\"y":"let [s:mp_r,s:mp_c]=[max([s:mp_r-s:mp_num,0]),max([s:mp_c-s:mp_num,0])]|let s:mp_num='01'",
\"u":"let [s:mp_r,s:mp_c]=[max([s:mp_r-s:mp_num,0]),s:mp_c+s:mp_num]|let s:mp_num='01'",
\"b":"let [s:mp_r,s:mp_c]=[s:mp_r+s:mp_num,max([s:mp_c-s:mp_num,0])]|let s:mp_num='01'",
\"n":"let [s:mp_r,s:mp_c]=[s:mp_r+s:mp_num,s:mp_c+s:mp_num]|let s:mp_num='01'",
\"1":"let s:mp_num=s:mp_num is '01'? '1' : s:mp_num>98? s:mp_num : s:mp_num.'1'",
\"2":"let s:mp_num=s:mp_num is '01'? '2' : s:mp_num>98? s:mp_num : s:mp_num.'2'",
\"3":"let s:mp_num=s:mp_num is '01'? '3' : s:mp_num>98? s:mp_num : s:mp_num.'3'",
\"4":"let s:mp_num=s:mp_num is '01'? '4' : s:mp_num>98? s:mp_num : s:mp_num.'4'",
\"5":"let s:mp_num=s:mp_num is '01'? '5' : s:mp_num>98? s:mp_num : s:mp_num.'5'",
\"6":"let s:mp_num=s:mp_num is '01'? '6' : s:mp_num>98? s:mp_num : s:mp_num.'6'",
\"7":"let s:mp_num=s:mp_num is '01'? '7' : s:mp_num>98? s:mp_num : s:mp_num.'7'",
\"8":"let s:mp_num=s:mp_num is '01'? '8' : s:mp_num>98? s:mp_num : s:mp_num.'8'",
\"9":"let s:mp_num=s:mp_num is '01'? '9' : s:mp_num>98? s:mp_num : s:mp_num.'9'",
\"0":"let [s:mp_c,s:mp_num]=s:mp_num is '01'? [s:mp_coff,s:mp_num] : [s:mp_c,s:mp_num>998? s:mp_num : s:mp_num.'0']",
\"$":"let s:mp_c=s:mp_coff+s:mp_cols-1",
\"H":"let s:mp_r=s:mp_roff",
\"M":"let s:mp_r=s:mp_roff+s:mp_rows/2",
\"L":"let s:mp_r=s:mp_roff+s:mp_rows-1",
\"T":"let s:mp_displayfunc=s:mp_displayfunc==function('s:printMapDisp')? function('s:printMapDispNoHL') : function('s:printMapDisp')",
\"x":"if exists('s:mp_array[s:mp_c][s:mp_r]')|let @\"=s:mp_array[s:mp_c][s:mp_r]|let s:mp_array[s:mp_c][s:mp_r]=''|let s:mp_redr=1|en",
\"o":"if exists('s:mp_array[s:mp_c][s:mp_r]')|let @\"=s:mp_array[s:mp_c][s:mp_r]|let s:mp_msg=' Cell obtained'|let s:last_yanked_is_column=0|en",
\"p":"if s:last_yanked_is_column\n
		\if s:mp_c+1>=len(s:mp_array)\n
			\call extend(s:mp_array,eval('['.join(repeat(['[]'],s:mp_c+2-len(s:mp_array)),',').']'))\n
		\en\n
		\call insert(s:mp_array,s:copied_column,s:mp_c+1)\n
		\let s:mp_redr=1\n
	\else\n
		\if s:mp_c>=len(s:mp_array)\n
			\call extend(s:mp_array,eval('['.join(repeat(['[]'],s:mp_c+1-len(s:mp_array)),',').']'))\n
		\en\n
		\if s:mp_r>=len(s:mp_array[s:mp_c])\n
			\call extend(s:mp_array[s:mp_c],repeat([''],s:mp_r+1-len(s:mp_array[s:mp_c])))\n
		\en\n
		\let s:mp_array[s:mp_c][s:mp_r]=@\"\n
		\let s:mp_redr=1\n
	\en",
\"P":"if s:last_yanked_is_column\n
		\if s:mp_c>=len(s:mp_array)\n
			\call extend(s:mp_array,eval('['.join(repeat(['[]'],s:mp_c+1-len(s:mp_array)),',').']'))\n
		\en\n
		\call insert(s:mp_array,s:copied_column,s:mp_c)\n
		\let s:mp_redr=1\n
	\else\n
		\if s:mp_c>=len(s:mp_array)\n
			\call extend(s:mp_array,eval('['.join(repeat(['[]'],s:mp_c+1-len(s:mp_array)),',').']'))\n
		\en\n
		\if s:mp_r>=len(s:mp_array[s:mp_c])\n
			\call extend(s:mp_array[s:mp_c],repeat([''],s:mp_r+1-len(s:mp_array[s:mp_c])))\n
		\en\n
		\let s:mp_array[s:mp_c][s:mp_r]=@\"\n
		\let s:mp_redr=1\n
	\en",
\"c":"let [lblTxt,hiColor,pos]=extend(split(exists('s:mp_array[s:mp_c][s:mp_r]')? s:mp_array[s:mp_c][s:mp_r] : '','#',1),['',''])[:2]\n
	\let inLbl=input(s:disp_str.'Label: ',lblTxt)\n
	\if !empty(inLbl)\n
		\let inHL=input('\nHighlight group: ',hiColor,'highlight')\n
		\if [s:mp_r,s:mp_c]==s:mp_initbk\n
			\let inPos=input(empty(s:mp_posmes)? '\nPosition: ' : '\nPosition ('.s:mp_posmes.' will center current cursor position) :', empty(pos)? s:mp_posmes : pos)\n
		\else\n
			\let inPos=input('\nPosition: ',pos)\n
		\en\n
		\if stridx(inLbl.inHL.inPos,'#')!=-1\n
			\let s:mp_msg=' ERROR: ''#'' is reserved for syntax and not allowed in the label text or settings'\n
		\else\n
			\if s:mp_c>=len(s:mp_array)\n
				\call extend(s:mp_array,eval('['.join(repeat(['[]'],s:mp_c+1-len(s:mp_array)),',').']'))\n
			\en\n
			\if s:mp_r>=len(s:mp_array[s:mp_c])\n
				\call extend(s:mp_array[s:mp_c],repeat([''],s:mp_r+1-len(s:mp_array[s:mp_c])))\n
			\en\n
			\let s:mp_array[s:mp_c][s:mp_r]=strtrans(inLbl).'#'.strtrans(inHL).'#'.strtrans(inPos)\n
			\let s:mp_redr=1\n
		\en\n
	\else\n
		\let s:mp_msg=' Change aborted (press ''x'' to clear)'\n
	\en\n",
\"g":'let s:mp_continue=2',
\"Z":"let t_in=[input(s:disp_str.'Block width (1-10): ',t:mp_clW),input('\nBlock height (1-10): ',t:mp_clH)]\n
	\let t:mp_clW=t_in[0]>0 && t_in[0]<=10? t_in[0] : t:mp_clW\n
	\let t:mp_clH=t_in[1]>0 && t_in[1]<=10? t_in[1] : t:mp_clH\n
	\let [t:txb.settings['map cell height'],t:txb.settings['map cell width'],s:mp_redr,s:mp_rows,s:mp_cols]=[t:mp_clH,t:mp_clW,1,(&ch-1)/t:mp_clH,(&columns-1)/t:mp_clW]",
\"I":'if s:mp_c<len(s:mp_array)|call insert(s:mp_array,[],s:mp_c)|let s:mp_redr=1|let s:mp_msg="Col ".(s:mp_c)." inserted"|en',
\"D":'if s:mp_c<len(s:mp_array) && input(s:disp_str."\nReally delete column? (y/n)")==?"y"|let s:copied_column=remove(s:mp_array,s:mp_c)|let s:last_yanked_is_column=1|let s:mp_redr=1|let s:mp_msg="Col ".(s:mp_c)." deleted"|en',
\"O":'let s:copied_column=s:mp_c<len(s:mp_array)? deepcopy(s:mp_array[s:mp_c]) : []|let s:mp_msg=" Col ".(s:mp_c)." Obtained"|let s:last_yanked_is_column=1'}
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
let TXBkyCmd["\<c-x>"]='cal s:deleteHiddenBuffers()|let [s:kc_msg,s:kc_continue]=["Hidden Buffers Deleted",0]'

fun! s:formatPar(str,w,pad)
	let [pars,pad,bigpad,spc]=[split(a:str,"\n",1),repeat(" ",a:pad),repeat(" ",a:w+10),repeat(' ',len(&brk))]
	let ret=[]
	for k in range(len(pars))
		if pars[k][0]==#'\'
			let format=pars[k][1]
			let pars[k]=pars[k][(format=='\'? 1 : 2):]
		else
			let format=''
		en
		let seg=[0]
		while seg[-1]<len(pars[k])-a:w
			let ix=(a:w+strridx(tr(pars[k][seg[-1]:seg[-1]+a:w-1],&brk,spc),' '))%a:w
			call add(seg,seg[-1]+ix-(pars[k][seg[-1]+ix=~'\s']))
			let ix=seg[-2]+ix+1
			while pars[k][ix]==" "
				let ix+=1
			endwhile
			call add(seg,ix)
		endw
		call add(seg,len(pars[k])-1)
		let ret+=map(range(len(seg)/2),format==#'C'? 'pad.bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : format==#'R'? 'pad.bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : 'pad.pars[k][seg[2*v:val]:seg[2*v:val+1]]')
	endfor
	return ret
endfun

let TXBkyCmd.S=
	\"let s:kc_continue=0\n
	\let settings_names=range(17)\n
	\let settings_values=range(17)\n
	\let [settings_names[0],settings_values[0]]=['    -- Global --','##label##']\n
	\let [settings_names[1],settings_values[1]]=['hotkey',g:TXB_HOTKEY]\n
	\let [settings_names[2],settings_values[2]]=['    -- Plane --','##label##']\n
	\let [settings_names[3],settings_values[3]]=['split width',has_key(t:txb.settings,'split width') && type(t:txb.settings['split width'])<=1? t:txb.settings['split width'] : 60]\n
	\let [settings_names[4],settings_values[4]]=['autoexe',has_key(t:txb.settings,'autoexe') && type(t:txb.settings.autoexe)<=1? t:txb.settings.autoexe : 'se nowrap scb cole=2']\n
	\let [settings_names[5],settings_values[5]]=['lines panned by j,k',has_key(t:txb.settings,'lines panned by j,k') && type(t:txb.settings['lines panned by j,k'])<=1? t:txb.settings['lines panned by j,k'] : 15]\n
	\let [settings_names[6],settings_values[6]]=['kbd x pan speed',has_key(t:txb.settings,'kbd x pan speed') && type(t:txb.settings['kbd x pan speed'])<=1? t:txb.settings['kbd x pan speed'] : 9]\n
	\let [settings_names[7],settings_values[7]]=['kbd y pan speed',has_key(t:txb.settings,'kbd y pan speed') && type(t:txb.settings['kbd y pan speed'])<=1? t:txb.settings['kbd y pan speed'] : 2]\n
	\let [settings_names[8],settings_values[8]]=['mouse pan speed',has_key(t:txb.settings,'mouse pan speed') && type(t:txb.settings['mouse pan speed'])==3? copy(t:txb.settings['mouse pan speed']) : [0,1,2,4,7,10,15,21,24,27]]\n
	\let [settings_names[9],settings_values[9]]=['lines per map grid',has_key(t:txb.settings,'lines per map grid') && type(t:txb.settings['lines per map grid'])<=1? t:txb.settings['lines per map grid'] : 45]\n
	\let [settings_names[10],settings_values[10]]=['map cell width',has_key(t:txb.settings,'map cell width') && type(t:txb.settings['map cell width'])<=1? t:txb.settings['map cell width'] : 5]\n
	\let [settings_names[11],settings_values[11]]=['map cell height',has_key(t:txb.settings,'map cell height') && type(t:txb.settings['map cell height'])<=1? t:txb.settings['map cell height'] : 2]\n
	\let [settings_names[12],settings_values[12]]=['working dir',has_key(t:txb.settings,'working dir') && type(t:txb.settings['working dir'])==1? t:txb.settings['working dir'] : '']\n
	\if exists('w:txbi')\n
		\let [settings_names[13],settings_values[13]]=['    -- Split '.w:txbi.' --','##label##']\n
		\let [settings_names[14],settings_values[14]]=['current width',get(t:txb.size,w:txbi,60)]\n
		\let [settings_names[15],settings_values[15]]=['current autoexe',get(t:txb.exe,w:txbi,'se nowrap scb cole=2')]\n
		\let [settings_names[16],settings_values[16]]=['current file',get(t:txb.name,w:txbi,'')]\n
	\en\n
	\let prevVal=deepcopy(settings_values)\n
	\if s:settingsPager(settings_names,settings_values,s:ErrorCheck)\n
		\echohl MoreMsg\n
		\let s:kc_msg='Settings saved!'\n
		\if stridx(maparg(g:TXB_HOTKEY),'TXB')!=-1\n
			\exe 'silent! nunmap' g:TXB_HOTKEY\n
		\elseif stridx(maparg('<f10>'),'TXB')!=-1\n
			\silent! nunmap <f10>\n
		\en\n
		\exe 'nn <silent>' settings_values[1] ':call {exists(\"t:txb\")? \"TXBdoCmd\" : \"TXBinit\"}(-99)<cr>'\n
		\let g:TXB_HOTKEY=settings_values[1]\n
		\if exists('w:txbi')\n
			\let t:txb.size[w:txbi]=settings_values[14]\n
			\let t:txb.exe[w:txbi]=settings_values[15]\n
			\if !empty(settings_values[16]) && settings_values[16]!=prevVal[16]\n
				\let t:txb_name[w:txbi]=s:sp_newfname[0]\n
				\let t:txb.name[w:txbi]=s:sp_newfname[1]\n
			\en\n
		\en\n
		\let t:txb.settings['split width']=settings_values[3]\n
			\if prevVal[3]!=#t:txb.settings['split width']\n
				\if 'y'==?input('Apply new default split width to current splits? (y/n)')\n
					\let t:txb.size=repeat([t:txb.settings['split width']],len(t:txb.name))\n
					\let s:kc_msg.=' (Current splits resized)'\n
				\else\n
					\let s:kc_msg.=' (Only appended splits will inherit split width)'\n
				\en\n
			\en\n
		\let t:txb.settings['autoexe']=settings_values[4]\n
			\if prevVal[4]!=#t:txb.settings.autoexe\n
				\if 'y'==?input('Apply new default autoexe to current splits? (y/n)')\n
					\let t:txb.exe=repeat([t:txb.settings.autoexe],len(t:txb.name))\n
					\let s:kc_msg.=' (Autoexe settings applied to current splits)'\n
				\else\n
					\let s:kc_msg.=' (Only appended splits will inherit new autoexe)'\n
				\en\n
			\en\n
		\let t:txb.settings['lines panned by j,k']=settings_values[5]\n
			\let t:kpLn=settings_values[5]\n
		\let t:txb.settings['kbd x pan speed']=settings_values[6]\n
			\let t:kpSpH=settings_values[6]\n
		\let t:txb.settings['kbd y pan speed']=settings_values[7]\n
			\let t:kpSpV=settings_values[7]\n
		\let t:txb.settings['mouse pan speed']=settings_values[8]\n
			\let t:msSp=settings_values[8]\n
		\let t:txb.settings['lines per map grid']=settings_values[9]\n
			\let t:mp_L=settings_values[9]\n
		\let t:txb.settings['map cell width']=settings_values[10]\n
			\let t:mp_clW=settings_values[10]\n
		\let t:txb.settings['map cell height']=settings_values[11]\n
			\let t:mp_clH=settings_values[11]\n
		\if !empty(settings_values[12]) && settings_values[12]!=t:txb.settings['working dir']\n
			\let wd_msg=' (Working dir not changed)'\n
			\if 'y'==?input('Are you sure you want to change the working directory? (Step 1/3; cancel at any time) (y/n)')\n
				\let confirm=input('Step 2/3 (Recommended): Would you like to convert current files to absolute paths so that their locations remain unaffected? (y/n/cancel)')\n
				\if confirm==?'y' || confirm==?'n'\n
					\let confirm2=input('Step 3/3: Would you like to write a copy of the current plane to file, just in case? (y/n/cancel)')\n
					\if confirm2==?'y' || confirm2==?'n'\n
						\let curwd=getcwd()\n
						\if confirm2=='y'\n
							\exe g:TXBkyCmd.W\n
						\en\n
						\if confirm=='y'\n
							\exe 'cd' fnameescape(t:txb_wd)\n
							\call map(t:txb.name,'fnamemodify(v:val,'':p'')')\n
						\en\n
						\let t:txb.settings['working dir']=settings_values[12]\n
						\let t:txb_wd=settings_values[12]\n
						\exe 'cd' fnameescape(t:txb_wd)\n
						\let t:txb_name=map(copy(t:txb.name),'fnameescape(fnamemodify(v:val,'':p''))')\n
						\exe 'cd' fnameescape(curwd)\n
						\let wd_msg=' (Working dir changed)'\n
					\en\n
				\en\n
			\en\n
			\let s:kc_msg.=wd_msg\n
		\en\n
		\echohl NONE\n
		\call s:redraw()\n
	\else\n
		\let s:kc_msg='Cancelled'\n
	\en"

let s:sp_pos=[0,0]
fun! s:settingsPager(keys,vals,errorcheck)
	let settings=[&more,&ch]
	let continue=1
	let smsg=''
	let vals=deepcopy(a:vals)
	let len=len(a:keys)
	let [&more,&ch]=[0,len<8? len+3 : 11] 
	let cursor=s:sp_pos[0]<0? 0 : s:sp_pos[0]>=len? len-1 : s:sp_pos[0]
	let height=&ch>3? &ch-3 : 1
	let offset=s:sp_pos[1]<0? 0 : s:sp_pos[1]>len-height? (len-height>=0? len-height : 0) : s:sp_pos[1]
	let offset=offset<cursor-height? cursor-height : offset>cursor? cursor : offset
	echohl MoreMsg
	while continue
		redr!
		echo 'Change Settings: [j] up [k] down [g] top [G] bottom [c]hange [S]ave [q]uit [D]efault'
		for i in range(offset,offset+height-1)
			if i==cursor
				echohl Visual
				if vals[i] isnot '##label##'
					echo a:keys[i] ':' vals[i]
				else
					echo a:keys[i]
				en
			elseif i<len
				if vals[i] isnot '##label##'
					echohl NONE
					echo a:keys[i] ':' vals[i]
				else
					echohl Title
					echo a:keys[i]
				en
			en
		endfor
		if !empty(smsg)
			echohl WarningMsg
			echo smsg
		else
			echohl MoreMsg
			echo get(a:errorcheck,a:keys[cursor],'')[2]
		en
		let smsg=''
		let input=''
		let c=getchar()
		exe get(s:sp_exe,c,'')
		let cursor=cursor<0? 0 : cursor>=len? len-1 : cursor
		let offset=offset<cursor-height+1? cursor-height+1 : offset>cursor? cursor : offset
		if !empty(input)
			exe get(a:errorcheck,a:keys[cursor],[0,'let vals[cursor]=input'])[1]
		en
	endwhile
	let [&more,&ch]=settings
	redr
	let s:sp_pos=[cursor,offset]
	echohl NONE
	return exitcode
endfun
let s:sp_exe={}
let s:sp_exe.68=
	\"echohl WarningMsg|let confirm=input('Restore defaults (y/n)?')|echohl None\n
	\if confirm==?'y'\n
		\for k in [1,3,4,5,6,7,8,9,10,11]\n
			\let vals[k]=get(a:errorcheck,a:keys[k],[vals[k]])[0]\n
		\endfor\n
		\for k in [12,14,15,16]\n
			\let vals[k]=prevVal[k]\n
		\endfor\n
	\en"
let s:sp_exe.113="let continue=0|let exitcode=0"
let s:sp_exe.106='let cursor+=1'
let s:sp_exe.107='let cursor-=1'
let s:sp_exe.103='let cursor=0'
let s:sp_exe.71='let cursor=len-1'
let s:sp_exe.99=
	\"if a:keys[cursor]==?'current file'\n
		\let prevwd=getcwd()\n
		\exe 'cd' fnameescape(t:txb_wd)\n
		\let input=input('(Use full path if not in working dir '.t:txb_wd.')\nEnter file (do not escape spaces): ',type(vals[cursor])==1? vals[cursor] : string(vals[cursor]),'file')\n
		\let s:sp_newfname=[fnameescape(fnamemodify(input,':p')),input]\n
		\exe 'cd' fnameescape(prevwd)\n
	\elseif a:keys[cursor]==?'working dir'\n
		\let input=input('Working dir (do not escape spaces; must be absolute path; press tab for completion): ',type(vals[cursor])==1? vals[cursor] : string(vals[cursor]),'file')\n
	\elseif vals[cursor] isnot '##label##'\n
		\let input=input('Enter new value: ',type(vals[cursor])==1? vals[cursor] : string(vals[cursor]))\n
	\en\n"
let s:sp_exe.83=
	\"for i in range(len)\n
		\let a:vals[i]=vals[i]\n
	\endfor\n
	\let continue=0\n
	\let exitcode=1"
let s:sp_exe.27=s:sp_exe.113

let s:ErrorCheck={}
let s:ErrorCheck['working dir']=['~',
	\"if isdirectory(input)\n
		\let vals[cursor]=fnamemodify(input,':p')\n
	\else\n
		\let smsg.='Error: Not a valid directory'\n
	\en",'for files in plane with relative paths']
let s:ErrorCheck['current file']=['','let vals[cursor]=input','file associated with this split']
let s:ErrorCheck['current autoexe']=['se nowrap scb cole=2','let vals[cursor]=input','command when current split is unhidden']
let s:ErrorCheck['current width']=[60,
	\"let input=str2nr(input)|if input<=2\n
		\let smsg.='Error: current split width must be > 2'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'width of current split']
let s:ErrorCheck['split width']=[60,
	\"let input=str2nr(input)|if input<=2\n
		\let smsg.='Error: default split width must be > 2'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'default width for new splits; [c]hange value and [S]ave for the option to apply to current splits']
let s:ErrorCheck['lines panned by j,k']=[15,
	\"let input=str2nr(input)\n
	\if input<=0\n
		\let smsg.='Error: lines panned by j,k must be > 0'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'j k y u b n will place the top line at multiples of this number']
let s:ErrorCheck['kbd x pan speed']=[9,
	\"let input=str2nr(input)\n
	\if input<=0\n
		\let smsg.='Error: x pan speed must be > 0'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'keyboard pan animation speed horizontal']
let s:ErrorCheck['kbd y pan speed']=[2,
	\"let input=str2nr(input)\n
	\if input<=0\n
		\let smsg.='Error: y pan speed must be > 0'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'keyboard pan animation speed vertical']
let s:ErrorCheck.hotkey=['<f10>',"let vals[cursor]=input","For example: <f10>, <c-v> (ctrl-v), vx (v then x). WARNING: If the hotkey becomes inaccessible, evoke ':call TXBinit()', and press S to reset"]
let s:ErrorCheck.autoexe=['se nowrap scb cole=2',"let vals[cursor]=input",'default command on unhide for new splits; [c]hange and [S]ave for the option to apply to current splits']
let s:ErrorCheck['mouse pan speed']=[[0,1,2,4,7,10,15,21,24,27],
	\"unlet! inList\n
	\if type(input)==3\n
		\let inList=input\n
	\elseif type(input)==1\n
		\try\n
			\let inList=eval(input)\n
		\catch\n
			\let inList=''\n
		\endtry\n
	\else\n
		\let inList=''\n
	\en\n
	\if type(inList)!=3\n
		\let smsg.='Error: mouse pan speed must evaluate to a list'\n
	\elseif empty(inList)\n
		\let smsg.='list must be non-empty'\n
	\elseif inList[0]\n
		\let smsg.='Error: first element of mouse speed list must be 0'\n
	\elseif eval(join(map(copy(inList),'v:val<0'),'+'))\n
		\let smsg.='Error: mouse speed list must be non-negative'\n
	\else\n
		\let vals[cursor]=copy(inList)\n
	\en",'for every N steps with mouse, pan speed[N] steps in plane (only works when ttymouse is xterm2 or sgr)']
let s:ErrorCheck['lines per map grid']=[45,
	\"let input=str2nr(input)\n
	\if input<=0\n
		\let smsg.='Error: lines per map grid must be > 0'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'Each map grid is 1 split and this many lines']
let s:ErrorCheck['map cell height']=[2,
	\"let input=str2nr(input)\n
	\if input<=0 || input>10\n
		\let smsg.='Error: map cell height must be between 1 and 10'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'integer between 1 and 10']
let s:ErrorCheck['map cell width']=[5,
	\"let input=str2nr(input)\n
	\if input<=0 || input>10\n
		\let smsg.='Error: map cell width must be between 1 and 10'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'integer between 1 and 10']

fun! s:pager(list,start)
	if len(a:list)<&lines
		let [more,&more]=[&more,0]
		ec join(a:list,"\n")."\nPress ENTER to continue"
		while index([10,13,113,27],getchar())==-1
		endwhile
		redr
		let &more=more
		return 0
	else
		let pad=repeat(' ',&columns)
		let settings=[&more,&ch]
		let [&more,&ch]=[0,&lines]
		let [pos,bot,continue]=[-1,max([len(a:list)-&lines+1,0]),1]
		let next=a:start<0? 0 : a:start>bot? bot : a:start
		while continue
			if pos!=next
				let pos=next
				redr!|echo join(a:list[pos : pos+&lines-2],"\n")."\nSPACE/d/j:down, b/u/k:up, g/G:top/bottom, q:quit"
			en
			exe get(s:pagercom,getchar(),'')
		endwhile
		redr
		let [&more,&ch]=settings
		return pos
	en
endfun
let s:pagercom={113:'let continue=0',
\32:"let t=&lines/2\n
	\while pos<bot && t>0\n
		\let t-=1\n
		\exe s:pagercom.106\n
	\endw",
\106:"if pos<bot\n
		\let pos=pos+1\n
		\let next=pos\n
		\let dispw=strdisplaywidth(a:list[pos+&lines-2])\n
		\if dispw>49\n
			\echon '\r'.a:list[pos+&lines-2].'\nSPACE/d/j:down, b/u/k:up, g/G:top/bottom, q:quit'\n
		\else\n
			\echon '\r'.a:list[pos+&lines-2].pad[:50-dispw].'\nSPACE/d/j:down, b/u/k:up, g/G:top/bottom, q:quit'\n
		\en\n
	\en",
\107:'let next=pos>0? pos-1 : pos',
\98:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\103:'let next=0',
\71:'let next=bot'}
let s:pagercom["\<up>"]=s:pagercom.107
let s:pagercom["\<down>"]=s:pagercom.106
let s:pagercom["\<ScrollWheelUp>"]=s:pagercom.107
let s:pagercom["\<ScrollWheelDown>"]=s:pagercom.106
let s:pagercom["\<left>"]=s:pagercom.98
let s:pagercom["\<right>"]=s:pagercom.32
let s:pagercom.100=s:pagercom.32
let s:pagercom.117=s:pagercom.98
let s:pagercom.27=s:pagercom.113

fun! s:gotoPos(col,row)
	let name=get(t:txb_name,a:col,-1)
	if name==-1
		echoerr "Split ".a:col." does not exist."
	else
		if name!=#fnameescape(fnamemodify(expand('%'),':p'))
			winc t
			exe 'e '.name
			let w:txbi=a:col
		en
		norm! 0
		only
		call s:redraw()
		exe 'norm!' (a:row? a:row : 1).'zt'
	en
endfun

fun! s:doSyntax(stmt)
	if empty(a:stmt)
		return
	en
	let num=''
	let com={'s':0,'r':0,'R':0,'j':0,'k':0,'l':0,'C':0,'M':0,'W':0,'A':0}
	for t in range(len(a:stmt))
		if a:stmt[t]=~'\d'
			let num.=a:stmt[t]
		elseif has_key(com,a:stmt[t])
			let com[a:stmt[t]]+=empty(num)? 1 : num
			let num=''
		else
			echoerr '"'.a:stmt[t].'" is not a recognized command, view positioning aborted.'
			return
		en
	endfor
	exe 'norm! '.(com.j>com.k? (com.j-com.k).'j' : com.j<com.k? (com.k-com.j).'k' : '').(com.l>winwidth(0)? 'g$' : com.l? com.l .'|' : '').(com.M>0? 'zz' : com.r>com.R? (com.r-com.R)."\<c-e>" : com.r<com.R? (com.R-com.r)."\<c-y>" : 'g')
	if com.C
		call s:nav(min([com.W? (com.W-&columns)/2 : (winwidth(0)-&columns)/2,0]))
	elseif com.s
		call s:nav(-min([eval(join(map(range(s:mp_c-1,s:mp_c-com.s,-1),'1+t:txb.size[(v:val+t:txb_len)%t:txb_len]'),'+')),!com.W? &columns-winwidth(0) : &columns>com.W? &columns-com.W : 0]))
	en
endfun

let TXBkyCmd.h='cal s:blockPan(-s:kc_num,0,line(''w0''),1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(1)'
let TXBkyCmd.j='cal s:blockPan(0,0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos()'
let TXBkyCmd.k='cal s:blockPan(0,0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos()' 
let TXBkyCmd.l='cal s:blockPan(s:kc_num,0,line(''w0''),1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(-1)' 
let TXBkyCmd.y='cal s:blockPan(-s:kc_num,0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(1)' 
let TXBkyCmd.u='cal s:blockPan(s:kc_num,0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(-1)' 
let TXBkyCmd.b='cal s:blockPan(-s:kc_num,0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(1)' 
let TXBkyCmd.n='cal s:blockPan(s:kc_num,0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!|call s:updateCursPos(-1)' 
let TXBkyCmd.1="let s:kc_num=s:kc_num is '01'? '1' : s:kc_num>98? s:kc_num : s:kc_num.'1'"
let TXBkyCmd.2="let s:kc_num=s:kc_num is '01'? '2' : s:kc_num>98? s:kc_num : s:kc_num.'2'"
let TXBkyCmd.3="let s:kc_num=s:kc_num is '01'? '3' : s:kc_num>98? s:kc_num : s:kc_num.'3'"
let TXBkyCmd.4="let s:kc_num=s:kc_num is '01'? '4' : s:kc_num>98? s:kc_num : s:kc_num.'4'"
let TXBkyCmd.5="let s:kc_num=s:kc_num is '01'? '5' : s:kc_num>98? s:kc_num : s:kc_num.'5'"
let TXBkyCmd.6="let s:kc_num=s:kc_num is '01'? '6' : s:kc_num>98? s:kc_num : s:kc_num.'6'"
let TXBkyCmd.7="let s:kc_num=s:kc_num is '01'? '7' : s:kc_num>98? s:kc_num : s:kc_num.'7'"
let TXBkyCmd.8="let s:kc_num=s:kc_num is '01'? '8' : s:kc_num>98? s:kc_num : s:kc_num.'8'"
let TXBkyCmd.9="let s:kc_num=s:kc_num is '01'? '9' : s:kc_num>98? s:kc_num : s:kc_num.'9'"
let TXBkyCmd.0="let s:kc_num=s:kc_num is '01'? '01' : s:kc_num>98? s:kc_num : s:kc_num.'1'"
let TXBkyCmd["\<up>"]=TXBkyCmd.k
let TXBkyCmd["\<down>"]=TXBkyCmd.j
let TXBkyCmd["\<left>"]=TXBkyCmd.h
let TXBkyCmd["\<right>"]=TXBkyCmd.l

fun! s:snapToGrid()
	let [ix,l0]=[w:txbi,line('.')]
	let y=l0>t:mp_L? l0-l0%t:mp_L : 1
	let poscom=get(split(get(get(t:txb.map,ix,[]),l0/t:mp_L,''),'#',1),2,'')
	if !empty(poscom)
		call s:doSyntax(s:gotoPos(ix,y)? '' : poscom)
		call s:saveCursPos()
	elseif winnr()!=winnr('$')
		exe 'norm! '.y.'zt0'
		call s:redraw()
	elseif t:txb.size[ix]>&columns
		only
		exe 'norm! '.y.'zt0'
	elseif winwidth(0)<t:txb.size[ix]
		call s:nav(-winwidth(0)+t:txb.size[ix]) 
		exe 'norm! '.y.'zt0'
	elseif winwidth(0)>t:txb.size[ix]
		exe 'norm! '.y.'zt0'
		call s:redraw()
	en
endfun
let TXBkyCmd['.']='call s:snapToGrid()|let s:kc_continue=0|call s:updateCursPos()' 

nno <silent> <plug>TxbY<esc>[ :call <SID>getmouse()<cr>
nno <silent> <plug>TxbY :call <SID>getchar()<cr>
nno <silent> <plug>TxbZ :call <SID>getchar()<cr>
fun! <SID>getchar()
	if getchar(1) is 0
		sleep 1m
		call feedkeys("\<plug>TxbY")
	else
		call s:dochar()
	en
endfun
"mouse    leftdown leftdrag leftup  swup    swdown
"xterm    32                35      96      97
"xterm2   32       64       35      96      97
"sgr      0M       32M      0m      64      65
"TXBmsmsg 1        2        3       4       5      else 0
fun! <SID>getmouse()
	if &ttymouse=~?'xterm'
		let g:TXBmsmsg=[getchar(0)*0+getchar(0),getchar(0)-32,getchar(0)-32]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==64? 2 : g:TXBmsmsg[0]==32? 1 : g:TXBmsmsg[0]==35? 3 : g:TXBmsmsg[0]==96? 4 : g:TXBmsmsg[0]==97? 5 : 0
	elseif &ttymouse==?'sgr'
		let g:TXBmsmsg=split(join(map([getchar(0)*0+getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';')
		let g:TXBmsmsg=len(g:TXBmsmsg)> 2? [str2nr(g:TXBmsmsg[0]).g:TXBmsmsg[2][len(g:TXBmsmsg[2])-1],str2nr(g:TXBmsmsg[1]),str2nr(g:TXBmsmsg[2])] : [0,0,0]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==#'32M'? 2 : g:TXBmsmsg[0]==#'0M'? 1 : (g:TXBmsmsg[0]==#'0m' || g:TXBmsmsg[0]==#'32K') ? 3 : g:TXBmsmsg[0][:1]==#'64'? 4 : g:TXBmsmsg[0][:1]==#'65'? 5 : 0
	else
		let g:TXBmsmsg=[0,0,0]
	en
	while getchar(0) isnot 0
	endwhile
	call g:TXBkeyhandler(-1)	
endfun
fun! s:dochar()
	let [k,c]=['',getchar()]
	while c isnot 0
		let k.=type(c)==0? nr2char(c) : c
		let c=getchar(0)
	endwhile
	call g:TXBkeyhandler(k)
endfun

fun! TXBdoCmd(inicmd)
	let s:kc_num='01'
	let s:kc_continue=1
	let s:kc_msg=''
	call s:saveCursPos()
	let g:TXBkeyhandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:inicmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:TXBkyCmd,a:c,'let s:kc_continue=0|let s:kc_msg="(Invalid command) Press '.g:TXB_HOTKEY.' F1 for help"')
	if s:kc_continue
		let t_r=line('.')/t:mp_L
		echon w:txbi '.' t_r ' ' empty(s:kc_msg)? get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-9] : s:kc_msg
		let s:kc_msg=''
		call feedkeys("\<plug>TxbZ") 
	elseif !empty(s:kc_msg)
		redr|ec s:kc_msg
	else
		let t_r=line('.')/t:mp_L
		redr|echo '(done)' w:txbi '-' t_r ' ' get(get(t:txb.map,w:txbi,[]),t_r,'')[:&columns-17]
	en
endfun
let TXBkyCmd.q="let s:kc_continue=0"
let TXBkyCmd[-1]='let s:kc_continue=0'
let TXBkyCmd[-99]=""
let TXBkyCmd["\e"]=TXBkyCmd.q

let TXBkyCmd.L="exe getline('.')[:3]!=#'txb:'? 'startinsert|norm! 0itxb:'.line('.').' ' : 'norm! 0wlcw'.line('.')|let s:kc_continue=0|let s:kc_msg='(labeled)'"

let TXBkyCmd.D=
	\"redr\n
	\if t:txb_len==1\n
		\let s:kc_msg='Cannot delete last split!'\n
	\elseif input('Really delete current column (y/n)? ')==?'y'\n
		\let t_index=index(t:txb_name,fnameescape(fnamemodify(expand('%'),':p')))\n
		\if t_index!=-1\n
			\call remove(t:txb.name,t_index)\n
			\call remove(t:txb_name,t_index)\n
			\call remove(t:txb.size,t_index)\n
			\call remove(t:txb.exe,t_index)\n
			\let t:txb_len=len(t:txb.name)\n
		\en\n
		\winc W\n
		\call s:saveCursPos()\n
		\call s:redraw()\n
		\let s:kc_msg='(Split deleted)'\n
	\en\n
	\let s:kc_continue=0\n
	\call s:updateCursPos()" 

let TXBkyCmd.A=
	\"let t_index=index(t:txb_name,fnameescape(fnamemodify(expand('%'),':p')))\n
	\if t_index!=-1\n
		\let prevwd=getcwd()\n
		\exe 'cd' fnameescape(t:txb_wd)\n
		\let file=input('(Use full path if not in working directory '.t:txb_wd.')\nAppend file (do not escape spaces) : ',t:txb.name[w:txbi],'file')\n
		\if (fnamemodify(expand('%'),':p')==#fnamemodify(file,':p') || t:txb_name[(w:txbi+1)%t:txb_len]==#fnameescape(fnamemodify(file,':p'))) && 'y'!=?input('\n**WARNING**\n    An unpatched bug in Vim causes errors when panning modified ADJACENT DUPLICATE SPLITS. Continue with append? (y/n)')\n
			\let s:kc_msg='File not appended'\n
		\elseif empty(file)\n
			\let s:kc_msg='File name is empty'\n
		\else\n
			\let s:kc_msg='[' . file . (index(t:txb.name,file)==-1? '] appended.' : '] (duplicate) appended.')\n
			\call insert(t:txb.name,file,w:txbi+1)\n
			\call insert(t:txb_name,fnameescape(fnamemodify(file,':p')),w:txbi+1)\n
			\call insert(t:txb.size,t:txb.settings['split width'],w:txbi+1)\n
			\call insert(t:txb.exe,t:txb.settings.autoexe,w:txbi+1)\n
			\let t:txb_len=len(t:txb.name)\n
			\call s:redraw()\n
		\en\n
		\exe 'cd' fnameescape(prevwd)\n
	\else\n
		\let s:kc_msg='Current file not in plane! [hotkey] r redraw before appending.'\n
	\en\n
	\let s:kc_continue=0|call s:updateCursPos()" 

let TXBkyCmd.W=
	\"let prevwd=getcwd()\n
	\exe 'cd' fnameescape(t:txb_wd)\n
	\let s:kc_continue=0\n
	\let input=input('Write plane to file (relative to '.t:txb_wd.'): ',exists('t:txb.settings.writefile') && type(t:txb.settings.writefile)<=1? t:txb.settings.writefile : '','file')\n
	\let [t:txb.settings.writefile,s:kc_msg]=empty(input)? [t:txb.settings.writefile,' (file write aborted)'] : [input,writefile(['unlet! txb_temp_plane','let txb_temp_plane='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TXBinit(txb_temp_plane)'],input)? '** ERROR **\n    File not writable' : 'Use '':source '.input.''' to restore']\n
	\exe 'cd' fnameescape(prevwd)"

fun! s:saveCursPos()
	let t:txb_cPos=[bufnr('%'),line('.'),virtcol('.'),w:txbi]
endfun
fun! s:updateCursPos(...)
    let default_scrolloff=a:0? a:1 : 0
	let win=bufwinnr(t:txb_cPos[0])
	if win!=-1
		if winnr('$')==1 || win==1
			winc t
			let offset=virtcol('.')-wincol()+1
			let width=offset+winwidth(0)-3
			exe 'norm! '.(t:txb_cPos[1]<line('w0')? 'H' : line('w$')<t:txb_cPos[1]? 'L' : t:txb_cPos[1].'G').(t:txb_cPos[2]<offset? offset : width<=t:txb_cPos[2]? width : t:txb_cPos[2]).'|'
		elseif win!=1
			exe win.'winc w'
			exe 'norm! '.(t:txb_cPos[1]<line('w0')? 'H' : line('w$')<t:txb_cPos[1]? 'L' : t:txb_cPos[1].'G').(t:txb_cPos[2]>winwidth(win)? '0g$' : t:txb_cPos[2].'|')
		en
	elseif default_scrolloff==1 || !default_scrolloff && t:txb_cPos[3]>w:txbi
		winc b
		exe 'norm! '.(t:txb_cPos[1]<line('w0')? 'H' : line('w$')<t:txb_cPos[1]? 'L' : t:txb_cPos[1].'G').(winnr('$')==1? 'g$' : '0g$')
	else
		winc t
		exe "norm! ".(t:txb_cPos[1]<line('w0')? 'H' : line('w$')<t:txb_cPos[1]? 'L' : t:txb_cPos[1].'G').'g0'
	en
	let t:txb_cPos=[bufnr('%'),line('.'),virtcol('.'),w:txbi]
endfun

fun! s:blockPan(sp,off,y,relative)
	let upPan="norm! ".t:kpSpV."\<c-y>"
	let dnPan="norm! ".t:kpSpV."\<c-e>"
	let cSp=getwinvar(1,'txbi')
	let dSp=a:relative? ((cSp+a:sp)%t:txb_len+t:txb_len)%t:txb_len  : a:sp
	let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
	let dir=a:relative? a:sp : dSp-cSp+(dSp==cSp)*(cOff-a:off)
	if dir>0
		while 1
			let cSp=getwinvar(1,'txbi')
			if cSp==dSp-1
				if winwidth(1)+a:off>t:kpSpH
					call s:nav(t:kpSpH)
				else
					call s:nav(winwidth(1)+a:off)
					break
				en
			elseif cSp==dSp
				let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
				if cOff-a:off>t:kpSpH
					call s:nav(t:kpSpH)
				else
					call s:nav(cOff-a:off)
					break
				en
			else
				call s:nav(t:kpSpH)
			en
			let dif=line('w0')-a:y
			exe dif>t:kpSpV? upPan : dif<-t:kpSpV? dnPan : !dif? '' : dif>0? 'norm! '.dif."\<c-y>" : 'norm! '.-dif."\<c-e>"
			redr
		endwhile
	elseif dir<0
		while 1
			let cSp=getwinvar(1,'txbi')
			if cSp==dSp+1
				if winwidth(1)+t:txb.size[dSp]-a:off>t:kpSpH
					call s:nav(-t:kpSpH)
				else
					call s:nav(-winwidth(1)-t:txb.size[dSp]+a:off)
					break
				en
			elseif cSp==dSp
				let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
				if cOff-a:off>t:kpSpH
					call s:nav(-t:kpSpH)
				else
					call s:nav(-cOff+a:off)
					break
				en
			else
				call s:nav(-t:kpSpH)
			en
			let dif=line('w0')-a:y
			exe dif>t:kpSpV? upPan : dif<-t:kpSpV? dnPan : !dif? '' : dif>0? 'norm! '.dif."\<c-y>" : 'norm! '.-dif."\<c-e>"
			redr
		endwhile
	en
	let l0=line('w0')
	let ll=line('$')
	let dif=l0-a:y
	while dif && !(a:y>l0 && l0==ll)
		exe dif>t:kpSpV? upPan : dif<-t:kpSpV? dnPan : dif>0? 'norm! '.dif."\<c-y>" : 'norm! '.(-dif)."\<c-e>"
		let l0=line('w0')
		let dif=l0-a:y
		echon dif
		redr
	endwhile
endfun

fun! s:redraw(...)
	let name0=fnameescape(fnamemodify(expand('%'),':p'))
	if !exists('w:txbi')
		let ix=index(t:txb_name,name0)
		if ix==-1
			only
			exe 'e' t:txb_name[0]
			let w:txbi=0
		else
			let w:txbi=ix
		en
	elseif get(t:txb_name,w:txbi,'')!=#name0
		let ix=index(t:txb_name,name0)
		if ix==-1
			let prev_txbi=w:txbi
			exe 'e' t:txb_name[prev_txbi]
			let w:txbi=prev_txbi
		else
			let w:txbi=ix
		en
	en
	let win0=winnr()
	let pos=[bufnr('%'),line('w0'),line('.'), virtcol('.')]
	if win0==1 && !&wrap
		let offset=virtcol('.')-wincol()
		if offset<t:txb.size[w:txbi]
			exe (t:txb.size[w:txbi]-offset).'winc|'
		en
	en
	se scrollopt=jump
	let split0=win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2
	let colt=w:txbi
	let colsLeft=0
	let remain=split0
	while remain>=1
		let colt=colt? colt-1 : t:txb_len-1
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let colb=w:txbi
	let remain=&columns-(split0>0? split0+1+t:txb.size[w:txbi] : min([winwidth(1),t:txb.size[w:txbi]]))
	let colsRight=1
	while remain>=2
		let colb=(colb+1)%t:txb_len
		let colsRight+=1
		let remain-=t:txb.size[colb]+1
	endwhile
	let colbw=t:txb.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(w:txbi-win0+t:txb_len)%t:txb_len
		for i in range(dif)
			let colt=colt? colt-1 : t:txb_len-1
			exe 'top vsp' t:txb_name[colt]
			let w:txbi=colt
			exe t:txb.exe[colt]
		endfor
	elseif dif<0
		winc t
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	let numcols=colsRight+colsLeft
	let dif=numcols-winnr('$')
	if dif>0
		let nextcol=((colb-dif)%t:txb_len+t:txb_len)%t:txb_len
		for i in range(dif)
			let nextcol=(nextcol+1)%t:txb_len
			exe 'bot vsp' t:txb_name[nextcol]
			let w:txbi=nextcol
			exe t:txb.exe[nextcol]
		endfor
	elseif dif<0
		winc b
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	windo se nowfw
	winc =
	winc b
	let ccol=colb
	let log=[]
	let elog=[]
    for i in range(1,numcols)
		se wfw
		if fnameescape(fnamemodify(bufname(''),':p'))!=#t:txb_name[ccol]
			exe 'e' t:txb_name[ccol]
		en
		let w:txbi=ccol
		exe t:txb.exe[ccol]
		if i==numcols
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(ccol==colb? colbw : t:txb.size[ccol])-winwidth(0)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		if a:0
			if ccol>=len(t:txb.map)
				call extend(t:txb.map,eval('['.join(repeat(['[]'],ccol+1-len(t:txb.map)),',').']'))
			en
			call map(t:txb.map[ccol],'v:val[-1:]==#"A"? "" : v:val')
			1
			let line=search('^txb:','W')
			while line
				let L=getline('.')[4:]
				let lref=matchstr(L,'^\d*')
				if !empty(lref) && lref!=line
					if lref<line
						let deletions=line-lref
						if prevnonblank(line-1)>=lref
							call add(elog,'EMOV'."\t".ccol."\t".line."\t".lref)
						else
							call add(log,'move'."\t".ccol."\t".line."\t".lref)
							exe 'norm! kd'.(deletions==1? 'd' : (deletions-1).'k')
						en
					else
						call add(log,'move'."\t".ccol."\t".line."\t".lref)
						exe 'norm! '.(lref-line)."O\ej"
					en
				en
				let line=line('.')
				let head=empty(lref)? 1 : L[len(lref)]==':'? len(lref)+2 : 0
				if head
					let r=line('.')/t:mp_L
					if r>=len(t:txb.map[ccol])
						call extend(t:txb.map[ccol],repeat([''],r+1-len(t:txb.map[ccol])))
					en
					let autolbl=split(L[head :],'#',1)
					if !empty(autolbl) && !empty(autolbl[0])
						if empty(t:txb.map[ccol][r])
							let row=line%t:mp_L
							let t:txb.map[ccol][r]=autolbl[0].'#'.get(autolbl,1,'').'#'.(row? row.'r'.row.'j' : '').get(autolbl,2,'CM').'A'
							call add(log,'labl'."\t".ccol."\t".line."\t".autolbl[0])
						else
							call add(elog,(t:txb.map[ccol][r][-1:-1]==#'A'? 'ECNF' : 'EOCC')."\t".ccol."\t".line."\t".autolbl[0]."\t".t:txb.map[ccol][r])
						en
					en
				en
				let line=search('^txb:','W')
			endwhile
		en
		winc h
		let ccol=ccol? ccol-1 : t:txb_len-1
	endfor
	se scrollopt=ver,jump
	try
		exe "silent norm! :syncbind\<cr>"
	catch
		se scrollopt=jump
		windo 1
		se scrollopt=ver,jump
	endtry
	exe bufwinnr(pos[0]).'winc w'
	let offset=virtcol('.')-wincol()
	exe 'norm!' pos[1].'zt'.pos[2].'G'.(pos[3]<=offset? offset+1 : pos[3]>offset+winwidth(0)? offset+winwidth(0) : pos[3])
	if !a:0
		let s:kc_msg='(redraw complete)'
	elseif empty(elog)
		let s:kc_msg='(Remap complete, :ec TxbRemapLog to see changes)'
		let g:TxbRemapLog=join(log,"\n")
	else
		let g:TxbRemapLog=join(elog,"\n")
		let s:kc_msg=":ec TxbRemapLog to review errors:\n".g:TxbRemapLog
		let g:TxbRemapLog.=join(log,"\n")
	en
endfun
let TXBkyCmd.r="call s:redraw()|redr|let s:kc_continue=0|call s:updateCursPos()" 
let TXBkyCmd.R="call s:redraw(1)|redr|let s:kc_continue=0|call s:updateCursPos()" 

fun! s:nav(N)
	let c_bf=bufnr('')
	let c_vc=virtcol('.')
	let l0=line('w0')
	let alignmentcmd='norm! '.l0'.'zt'
	let dosyncbind=0
	if a:N<0
		let N=-a:N
		let extrashift=0
		if N<&columns
			while winwidth(winnr('$'))<=N
				winc b
				let extrashift=(winwidth(0)==N)
				hide
			endw
		else
			winc t
			only
		en
		if winwidth(0)!=&columns
			winc t
			let topw=winwidth(0)
			if winwidth(winnr('$'))<=N+3+extrashift || winnr('$')>=9
				se nowfw
				winc b
				exe 'vert res-'.(N+extrashift)
				winc t
				if winwidth(1)==1
					winc l
					se nowfw
					winc t 
					exe 'vert res+'.(N+extrashift)
					winc l
					se wfw
					winc t
				elseif winwidth(0)==topw
					exe 'vert res+'.(N+extrashift)
				en
				se wfw
			else
				exe 'vert res+'.(N+extrashift)
			en
			while winwidth(0)>=t:txb.size[w:txbi]+2
				se nowfw scrollopt=jump
				let nextcol=w:txbi? w:txbi-1 : t:txb_len-1
				exe 'top '.(winwidth(0)-t:txb.size[w:txbi]-1).'vsp '.t:txb_name[nextcol]
				let w:txbi=nextcol
				if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
					let dosyncbind=1
				else
					exe alignmentcmd
				en
				exe t:txb.exe[nextcol]
				winc l
				se wfw
				norm! 0
				winc t
				se wfw scrollopt=ver,jump
			endwhile
			let offset=t:txb.size[w:txbi]-winwidth(0)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				winc b
				norm! 0g$
			elseif c_wn!=1
				exe c_wn.'winc w'
				exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
			en
		else
			let tcol=w:txbi
			let loff=&wrap? -N-extrashift : virtcol('.')-wincol()-N-extrashift
			if loff>=0
				exe 'norm! '.(N+extrashift).(bufwinnr(c_bf)==-1? 'zhg$' : 'zh')
			else
				let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
				while loff<=-2
					let tcol=tcol? tcol-1 : t:txb_len-1
					let loff+=t:txb.size[tcol]+1
				endwhile
				se scrollopt=jump
				exe 'e' t:txb_name[tcol]
				let w:txbi=tcol
				if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
					let dosyncbind=1
				else
					exe alignmentcmd
				en
				exe t:txb.exe[tcol]
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&columns-1
					let spaceremaining=&columns-t:txb.size[tcol]+loff
					let nextcol=(tcol+1)%t:txb_len
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bot '.(spaceremaining-1).'vsp '.t:txb_name[nextcol]
						let w:txbi=nextcol
						if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
							let dosyncbind=1
						elseif !dosyncbind
							exe alignmentcmd
						en
						exe t:txb.exe[nextcol]
						norm! 0
						let spaceremaining-=t:txb.size[nextcol]+1
						let nextcol=(nextcol+1)%t:txb_len
					endwhile
					se scrollopt=ver,jump
					windo se wfw
				en
				let c_wn=bufwinnr(c_bf)
				if c_wn!=-1
					exe c_wn.'winc w'
					exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
				else
					norm! 0g$
				en
			en
		en
		let extrashift=-extrashift
	elseif a:N>0
		let tcol=getwinvar(1,'txbi')
		let loff=winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0)
		let extrashift=0
		let N=a:N
		let nobotresize=0
		if N>=&columns
			let loff=winwidth(1)==&columns? loff+&columns : winwidth(winnr('$'))
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%t:txb_len
			en
			let toshift=N-&columns
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%t:txb_len
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%t:txb_len
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%t:txb_len
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%t:txb_len
				let loff=0
			else
				let loff+=toshift	
			en
			se scrollopt=jump
			exe 'e' t:txb_name[tcol]
			let w:txbi=tcol
			if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
				let dosyncbind=1
			else
				exe alignmentcmd
			en
			exe t:txb.exe[tcol]
			se scrollopt=ver,jump
			only
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			if winwidth(1)==1
				let c_wn=winnr()
				winc t
				hide
				let N-=2
				if N<=0
					if c_wn!=1
						exe (c_wn-1).'winc w'
					else
						1winc w
						norm! 0
					en
					return
				en
			en
			let shifted=0
			while winwidth(1)<=N
				let w2=winwidth(2)
				let extrashift=winwidth(1)==N
				let shifted+=winwidth(1)+1
				winc t
				hide
				if winwidth(1)==w2
					let nobotresize=1
				en
				let tcol=(tcol+1)%t:txb_len
				let loff=0
			endw
			let N+=extrashift
			let loff+=N-shifted
		en
		let wf=winwidth(1)-N
		if wf+N!=&columns
			if !nobotresize
				winc b
				exe 'vert res+'.N
				if virtcol('.')!=wincol()
					norm! 0
				en
				winc t	
				if winwidth(1)!=wf
					exe 'vert res'.wf
				en
			en
			while winwidth(winnr('$'))>=t:txb.size[getwinvar(winnr('$'),'txbi')]+2
				winc b
				se nowfw scrollopt=jump
				let nextcol=(w:txbi+1)%t:txb_len
				exe 'rightb vert '.(winwidth(0)-t:txb.size[w:txbi]-1).'split '.t:txb_name[nextcol]
				let w:txbi=nextcol
				if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
					let dosyncbind=1
				elseif !dosyncbind
					exe alignmentcmd
				en
				exe t:txb.exe[nextcol]
				winc h
				se wfw
				winc b
				norm! 0
				se scrollopt=ver,jump
			endwhile
			winc t
			let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
			exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
			else
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		elseif &columns-t:txb.size[tcol]+loff>=2
			let spaceremaining=&columns-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let nextcol=(w:txbi+1)%t:txb_len
				exe 'bot '.(spaceremaining-1).'vsp '.t:txb_name[nextcol]
				let w:txbi=nextcol
				if line('$')<l0 && stridx(t:txb.exe[nextcol],'noscb')!=-1
					let dosyncbind=1
				elseif !dosyncbind
					exe alignmentcmd
				en
				exe t:txb.exe[nextcol]
				norm! 0
				let spaceremaining-=t:txb.size[nextcol]+1
			endwhile
			se scrollopt=ver,jump
			windo se wfw
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				winc t
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				if c_vc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.c_vc.'|'
				en
			else
				winc t
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		else
			let offset=loff-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				if c_vc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.c_vc.'|'
				en
			else
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		en
	en
    if dosyncbind
		try
			exe "silent norm! :syncbind\<cr>"
		catch
			se scrollopt=jump
			windo 1
			se scrollopt=ver,jump
		endtry
	en
	return extrashift
endfun

delf s:SID
