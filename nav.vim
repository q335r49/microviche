"Hosted at https://github.com/q335r49/textabyss

if &cp|se nocompatible|en              "[Vital] Enable vim features, sets ttymouse
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

silent highlight default link TXBmapSel Visual
silent highlight default link TXBmapSelEmpty Visual

if !exists('g:TXB_HOTKEY')
	let g:TXB_HOTKEY='<f10>'
en
exe 'nn <silent>' g:TXB_HOTKEY ':call {exists("t:txb")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'

if !has("gui_running")
	fun! <SID>centerCursor(row,col)
		let restoreView='norm! '.virtcol('.').'|'
		call s:redraw()
		call s:nav(a:col/2-&columns/4)
		let dy=&lines/4-a:row/2
		exe dy>0? restoreView.dy."\<c-y>" : dy<0? restoreView.(-dy)."\<c-e>" : restoreView
	endfun
	augroup TXB
		au!
		if v:version > 703 || v:version==703 && has("patch748")
			au VimResized * if exists('t:txb') | call <SID>centerCursor(screenrow(),screencol()) | en
		else
			au VimResized * if exists('t:txb') | call <SID>centerCursor(winline(),eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')) | en
		en
	augroup END
	nn <silent> <leftmouse> :exe get(TXBmsCmd,&ttymouse,TXBmsCmd.default)()<cr>
else
	nn <silent> <leftmouse> :exe TXBmsCmd.default()<cr>
en

augroup TXB
	au VimEnter * if stridx(maparg('<f10>'),'TXB')!=-1 | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' g:TXB_HOTKEY ':call {exists("t:txb")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'
augroup END

let TXBmsCmd={}
let TXBkyCmd={}

let s:help_bookmark=0
fun! s:printHelp()
	redir => bufenterAu
		silent au BufEnter
		silent au BufLeave
	redir END
	let auCommands=split(bufenterAu,"\n")
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	let s:help_bookmark=s:pager(s:formatPar("\n\n\n\\CWelcome to Textabyss v1.7!
	\\n\\Cgithub.com/q335r49/textabyss
	\\n\nPress ".g:TXB_HOTKEY." to start. You will be prompted for a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single file and use ".g:TXB_HOTKEY."A to append additional splits.\n
	\\nOnce loaded, use the mouse to pan or press ".g:TXB_HOTKEY." followed by:
	\\n    h j k l     Pan left / down / up / right*
	\\n    y u b n     Pan upleft / downleft / upright / downright*
	\\n    o           Open map (map grid: default 1 split x 45 lines)
	\\n    r           Redraw
	\\n    .           Snap to map grid
	\\n    D A E       Delete split / Append split / Edit split settings
	\\n    <f1>        Show this message
	\\n    q <esc>     Abort
	\\n    S           Edit Settings**
	\\n    W           Write plane to file
	\\n    ^X          Delete hidden buffers
	\\n* The movement keys take counts, as in vim. Eg, 3j will move down 3 grids. The count is capped at 99. Each grid is 1 split x 15 lines.
	\\n** Note that you can use S to set the global hotkey, currently ".g:TXB_HOTKEY.". If you find yourself with an inaccessible hotkey, you can also change settings by evoking ':call TXBinit()' and pressing S
	\\n\n\\CTroubleshooting\n\n"
	\.(len(auCommands)>2? "** BufEnter or BufLeave detected **\nIf you are experiencing mouse lag, considering slimming down the autocommands you have set for BufEnter and BufLeave. Each step of mouse panning switches buffers several times and would trigger those autocommands multiple times. Also consider the alternatives 'BufRead' and 'BufHidden'\n\n" : "")
	\.(has('gui_running')? "" : &ttymouse==?'xterm'? "** xterm detected **\nMouse panning is disabled because your ttymouse is set to 'xterm'. Try another ttymouse setting to enable. (Recommended: ':set ttymouse=xterm2' or 'sgr').\n\n" : (&ttymouse!=?"xterm2" && &ttymouse!=?"sgr")? "** Possible bad mouse setting detected **\nFor better performance, try 'set ttymouse=xterm2' or 'sgr', if possible.\n\n" : "")
	\."DIRECTORIES\nEnsuring a consistent starting directory is important because relative names are remembered (use ':cd ~/PlaneDir' to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.\n
	\\nSCROLLBIND DESYNC\nWhen scrolling in a split much longer than its neighbors scrollbinding my desync. You can press r to redraw when this happens. Alternatively, padding about 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then find it helpful to remap normal mode G (go to end of file) to go to the last non-blank line rather than the very last line.
	\\n\nHORIZONTAL SPLITS\nHorizontal splits aren't supported and may interfere with panning.\n
	\\n\\CAdvanced\n
	\\n--- Saving Planes ---\n
	\\nThe script uses the viminfo file (:help viminfo) to save plane and map data. The option to save global variables in CAPS is set automatically when the script is loaded. The saved plane is suggested when you press ".g:TXB_HOTKEY.".\n
	\\nTo manually save a snapshot of the current plane, navigate to the tab containing the plane and try:
	\\n    :let BACK01=deepcopy(t:txb) \"make sure name is in all CAPS\n
	\\nYou can then restore via:
	\\n    :call TXBinit(BACK01)\n
	\\nAlternatively, you can save a snapshot of the viminfo via:
	\\n    :wviminfo viminfo-backup-01\n
	\\nYou can then restore it by quitting vim and replacing your current viminfo file with the backup.\n
	\\n--- Line Anchors ---
	\\n    ^L          Insert line anchor
	\\n    ^A          Align all text anchors in split\n
	\\nInserting text at the top of a split misaligns everything below. Line anchors try to address this problem. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. It can be inserted with ".g:TXB_HOTKEY." ^L. The align command ".g:TXB_HOTKEY." ^A attempts to restore all displaced anchors in a split by removing or inserting immediately preceding blank lines. If there aren't enough blank lines to remove the effort will be abandoned with an error message.
	\\n\n\\CRecent Changes\n
	\\n1.6.7     Plane data optimizations, further init error checks
	\\n1.6.6     Multiple prompts for map label
	\\n1.6.5     Lots of initialization fixes
	\\n1.6.4     Center and redraw on zoom
	\\n1.6.2     Line anchors",width,(&columns-width)/2),s:help_bookmark)
endfun

fun! s:writePlaneToFile(plane,file)
	let lines=[]
	let data=string(a:plane)
	if stridx(data,"\n")!=-1
		let error=-10
 		let data=substitute(data,"\n",'''."\\n".''',"g")
	else
		let error=0
	en
	call add(lines,'unlet! txb_temp_plane')
	call add(lines,'let txb_temp_plane='.data)
	call add(lines,"call TXBinit(txb_temp_plane)")
	return writefile(lines,a:file)+error
endfun
let TXBkyCmd.W="let s:kc__continue=0\n
	\let input=input('[Write plane to file] Input file name:','','file')\n
	\if !empty(input)\n
		\let error=s:writePlaneToFile(t:txb,input)\n
		\if (error/10)\n
			\let s:kc__msg.='** Warning **\n    Plane data, unexpectedly, contains newlines, which can''t be predictably written to file.\n    (Are you using filenames containing the newline character?)\n    A workaround will be attempted, but there is a chance problems on restoration.\n'\n
		\en\n
		\if error%10==-1\n
			\let s:kc__msg.=' ERROR: File not writable'\n
		\else\n
			\let s:kc__msg.=' Plane written to file. Use '':source '.input.''' to restore'\n
		\en\n
	\else\n
    	\let s:kc__msg.=' (file write aborted)'\n
	\en\n"
fun! TXBinit(...)
	se noequalalways
	se winwidth=1
	se winminwidth=0
	let filtered=[]
	let [more,&more]=[&more,0]
	let seed=a:0? a:1 : -99
	if seed is -99
		let msg=''
		if !has("gui_running")
			if &ttymouse==?"xterm"
				let msg.="\n**WARNING**\n    ttymouse is set to 'xterm', which doesn't report mouse dragging.\n    Try ':set ttymouse=xterm2' or ':set ttymouse=sgr'"
			elseif &ttymouse!=?"xterm2" && &ttymouse!=?"sgr"
				let msg.="\n**WARNING**\n    For better mouse panning performance, try ':set ttymouse=xterm2' or 'set ttymouse=sgr'.\n    Your current setting is: ".&ttymouse
			en
		en
		if v:version < 703 || v:version==703 && !has('patch30')
			let msg.="\n**WARNING**\n    Vim version < 7.3.30; plane and map cannot be saved to the viminfo, but you can manually write to file with (HOTKEY) W."
		en
		if exists('g:TXB') && type(g:TXB)==4
			let plane=deepcopy(g:TXB)
			for i in range(len(plane.name)-1,0,-1)
				if !filereadable(plane.name[i])
					call add(filtered,remove(plane.name,i))
					call remove(plane.size,i)	
					call remove(plane.exe,i)	
				en
			endfor
			if !empty(filtered)
				let msg="\n   ".join(filtered," (unreadable)\n   ")." (unreadable)\n ---- ".len(filtered)." unreadable file(s) ----".msg
				let msg.="\n**WARNING**\n    Unreadable file(s) will be removed from the plane; make sure you are in the right directory!"
				let msg.="\n    Restore map and plane and remove unreadable files?\n -> Type R to confirm / ESC / S for settings / F1 for help: "
				let confirm_keys=[82]
			else
				let msg.="\nRestore last session (map and plane)?\n -> Type ENTER / ESC / S for settings / F1 for help:"
				let confirm_keys=[10,13]
			en
		else
			let plane={'name':[]}
			let confirm_keys=[]
		en
	elseif type(seed)==4
   		let plane=seed
		for i in range(len(seed.name)-1,0,-1)
			if !filereadable(plane.name[i])
				call add(filtered,remove(plane.name,i))
				call remove(plane.size,i)	
				call remove(plane.exe,i)	
			en
		endfor
		if !empty(filtered)
			let msg="\n   ".join(filtered," (unreadable)\n   ")." (unreadable)\n ---- ".len(filtered)." unreadable file(s) ----"
			let msg.="\n**WARNING**\n    Unreadable file(s) will be removed from the plane; make sure you are in the right directory!"
			let msg.="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo. You can save the previous plane to file with (HOTKEY) W"
			let msg.="\n    Load map and plane AND remove unreadable files?\n -> Type L to confirm / ESC / S for settings / F1 for help: "
			let confirm_keys=[76]
		else
			let msg ="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo. Press F1 for options on saving previous plane."
			let msg.="\n    Load map and plane?\n -> Type L to confirm / ESC / S for settings / F1 for help:"
			let confirm_keys=[76]
		en
	elseif type(seed)==1
		let plane={'name':map(filter(split(glob(seed),"\n"),'filereadable(v:val)'),'escape(v:val," ")')}
		let plane.size=repeat([60],len(plane.name))
		let plane.map=[[]]
		let plane.settings={}
		let plane.exe=repeat(['se scb cole=2 nowrap'],len(plane.name))
		if exists('g:TXB') && type(g:TXB)==4
			let msg ="\n**WARNING**\n    The last plane and map you used will be OVERWRITTEN in viminfo. Press F1 for options on saving previous plane\n -> Type O to confirm overwrite / ESC / S for Settings / F1 for help:"
			let confirm_keys=[79]
		else
			let msg ="\nUse current pattern '".seed."'?\n -> Type ENTER / ESC / S for Settings / F1 for help:"
			let confirm_keys=[10,13]
		en
	else
		echoerr "Argument must be dictionary {'name':[list of files], ... } or string filepattern"
		return 1
	en
	if !empty(plane.name) || !empty(filtered)
		if !exists('plane.size')
			let plane.size=repeat([60],len(plane.name))
		elseif len(plane.size)<len(plane.name)
			call extend(plane.size,repeat([exists("plane.settings['split width']")? plane.settings['split width'] : 60],len(plane.name)-len(plane.size)))
		en
		if !exists('plane.map')
			let plane.map=[[]]
		en
		let default={'split width':60,'autoexe':'se nowrap scb cole=2','lines panned by j,k':15,'kbd x pan speed':9,'kbd y pan speed':2,'mouse pan speed':[0,1,2,4,7,10,15,21,24,27],'lines per map grid':45}
		if !exists('plane.settings')
			let plane.settings=default
		else
			for i in keys(default)
				if !has_key(plane.settings,i)
					let plane.settings[i]=default[i]
				en
			endfor
			let cursor=0
			let vals=[1]
			for i in keys(plane.settings)
				let smsg=''
				unlet! input
				let input=plane.settings[i]
				exe get(s:ErrorCheck,i,['',''])[1]
				if !empty(smsg)
					let plane.settings[i]=s:ErrorCheck[i][0]
					let msg="\n**WARNING**\n    ".smsg."\n    Default setting restored".msg
				en
			endfor
		en
		if !exists('plane.exe')
			let plane.exe=repeat([plane.settings.autoexe],len(plane.name))
		elseif len(plane.exe)<len(plane.name)
			call extend(plane.exe,repeat([plane.settings.autoexe],len(plane.name)-len(plane.exe)))
		en
		let curbufix=index(plane.name,expand('%'))
		if curbufix==-1
			ec "\n  " join(plane.name,"\n   ") "\n ---- " len(plane.name) "file(s) ----" msg
		else
			let displist=copy(plane.name)
			let displist[curbufix].=' (current file)'
			ec "\n  " join(displist,"\n   ") "\n ----" len(plane.name) "file(s) (Plane will be loaded in current tab) ----" msg
		en
		let c=getchar()
	elseif seed isnot -99
		ec "\n    (No matches found)"
		let c=0
	else
		let c=0
	en
	if index(confirm_keys,c)!=-1
		if curbufix==-1 | tabe | en
		let g:TXB=plane
		let t:txb=plane
		let t:txb__len=len(t:txb.name)
		let [t:txb__ix,j]=[{},0]
		for e in t:txb.name
			let [t:txb__ix[e],j]=[j,j+1]
		endfor
		if !exists('s:gridNames') || len(s:gridNames)<t:txb__len+50
			let s:gridnames=s:getGridNames(t:txb__len+50)
		en
	    let t:panL=t:txb.settings['lines panned by j,k']
		let t:aniStepH=t:txb.settings['kbd x pan speed']
		let t:aniStepV=t:txb.settings['kbd y pan speed']
		let t:mouseAcc=t:txb.settings['mouse pan speed']
		let t:mapL=t:txb.settings['lines per map grid']
		call filter(t:txb,'index(["exe","map","name","settings","size"],v:key)!=-1')
		call filter(t:txb.settings,'index(["split width","autoexe","map cell height","map cell width","lines panned by j,k","kbd x pan speed","kbd y pan speed","mouse pan speed","lines per map grid"],v:key)!=-1')
		call s:redraw()
	elseif c is "\<f1>"
		call s:printHelp() 
	elseif c is 83
		let t_dict={'_global_hotkey' : (g:TXB_HOTKEY)}
		if s:settingsPager(t_dict,s:ErrorCheck)
			exe 'silent! nunmap' g:TXB_HOTKEY
			exe 'nn <silent>' t_dict._global_hotkey ':call {exists("t:txb")? "TXBdoCmd" : "TXBinit"}(-99)<cr>'
			let g:TXB_HOTKEY=t_dict._global_hotkey
			redr|echo "Settings Saved!"
		else
			redr|echo "Cancelled"
		en
	else
		let input=input("> Enter file pattern or type HELP: ")
		if input==?'help'
			call s:printHelp()
		elseif !empty(input)
			call TXBinit(input)
		en
	en
	let &more=more
endfun

let TXBkyCmd["\<c-l>"]="call setline('.','txb:'.line('.'))|let s:kc__continue=0|let s:kc__msg='(Anchor set)'"
let TXBkyCmd["\<c-a>"]="let s:kc__msg=s:anchor(1)|let s:kc__continue=0"
fun! s:anchor(interactive)
	let restoreView='norm! '.line('w0').'zt'.line('.').'G'.virtcol('.').'|'
	let line=search('^txb:','W')
	1
	if a:interactive
	   	let [cul,&cul]=[&cul,1]
		while line
			redr
			let mark=getline('.')[4:]
			if mark<line && mark>0
				let insertions=line-mark
				if prevnonblank(line-1)>=mark
					let &cul=cul
					echoerr "Not enough blank lines to restore current marker!"
					return 1
				elseif input('Remove '.insertions.' blank lines here (y/n)?','y')==?'y'
					exe 'norm! kd'.(insertions==1? 'd' : (insertions-1).'k')
				en
			elseif mark>line && input('Insert '.(mark-line).' line here (y/n)?','y')==?'y'
				exe 'norm! '.(mark-line)."O\ej"
			en
			let line=search('^txb:','W')
		endwhile
	  	let &cul=cul
	else
		while line
			let mark=getline('.')[4:]
			if mark<line && mark>=0
				let insertions=line-mark
				if prevnonblank(line-1)>=mark
					echoerr "Not enough blank lines to restore current marker!"
					return 1
				else
					exe 'norm! kd'.(insertions==1? 'd' : (insertions-1).'k')
				en
			elseif mark>line
				exe 'norm! '.(mark-line)."O\ej"
			en
			let line=search('^txb:','W')
		endwhile
	en
	exe restoreView
	return "Realign complete: ".expand('%')
endfun

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! s:initDragDefault()
	if exists('t:txb')
		call s:saveCursPos()
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:updateCursPos()
			let s0=t:txb__ix[bufname(winbufnr(v:mouse_win))]
			let t_r=v:mouse_lnum/t:mapL
			echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
			return "keepj norm! \<leftmouse>"
		else
			let s0=t:txb__ix[bufname('')]
			let t_r=line('.')/t:mapL
			let ecstr=s:gridnames[s0].t_r.' '.get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
			while c!="\<leftrelease>"
				if v:mouse_win!=w0
					let w0=v:mouse_win
					exe "norm! \<leftmouse>"
					if !exists('t:txb')
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
		let s0=t:txb__ix[bufname('')]
		let t_r=line('.')/t:mapL
		echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
	else
		let possav=[bufnr('%')]+getpos('.')[1:]
		call feedkeys("\<leftmouse>")
		call getchar()
		exe v:mouse_win."wincmd w"
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
let TXBmsCmd.default=function("s:initDragDefault")

fun! s:initDragSGR()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists("t:txb")
			let s0=t:txb__ix[bufname('')]
			let t_r=line('.')/t:mapL
			echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
		en
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:nav_state=[line('w0'),line('.'),-10,'']
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
		if !exists('t:txb')
			return
		en
		if k[1:]==[1,1]
			call TXBdoCmd('o')
		else
			let s0=t:txb__ix[bufname('')]
			let t_r=line('.')/t:mapL
			echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.sgr=function("s:initDragSGR")

fun! s:initDragXterm()
	return "norm! \<leftmouse>"
endfun
let TXBmsCmd.xterm=function("s:initDragXterm")

fun! s:initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists("t:txb")
			let s0=t:txb__ix[bufname('')]
			let t_r=line('.')/t:mapL
			echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
		en
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:nav_state=[line('w0'),line('.'),-10,'']
		let s:dragHandler=function("s:navPlane")
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! <SID>doDragXterm2()
	let k=[getchar(0),getchar(0),getchar(0)]
	if k[0]==35
		nunmap <esc>[M
		if !exists('t:txb')
			return
		en
		if k[1:]==[33,33]
			call TXBdoCmd('o')
		else
			let s0=t:txb__ix[bufname('')]
			let t_r=line('.')/t:mapL
			echon s:gridnames[s0] t_r ' ' get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9]
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.xterm2=function("s:initDragXterm2")

let s:panAcc=[0,1,2,4,7,10,15,21,24,27]
fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? get(s:panAcc,a:dy,s:panAcc[-1])."\<c-y>" : a:dy<0? get(s:panAcc,-a:dy,s:panAcc[-1])."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -get(t:mouseAcc,a:dx,t:mouseAcc[-1]) : get(t:mouseAcc,-a:dx,t:mouseAcc[-1]))
	let s0=max([1,a:dy>0? s:nav_state[0]-get(t:mouseAcc,a:dy,t:mouseAcc[-1]) : s:nav_state[0]+get(t:mouseAcc,-a:dy,t:mouseAcc[-1])])
	exe 'norm! '.s0.'zt'
	exe 'norm! '.(s:nav_state[1]<line('w0')? 'H' : line('w$')<s:nav_state[1]? 'L' : s:nav_state[1].'G')
	let s:nav_state=[s0,line('.'),t:txb__ix[bufname('')],s:nav_state[2],s:nav_state[3]!=s:nav_state[2]? s:gridnames[s:nav_state[2]].s:nav_state[1]/t:mapL.' '.get(get(t:txb.map,s:nav_state[2],[]),s:nav_state[1]/t:mapL,'')[:&columns-9] : s:nav_state[4]]
	echon s:nav_state[4]
endfun

fun! s:getGridNames(len)
	let alpha=map(range(65,90),'nr2char(v:val)')
	let powers=[26,676,17576]
	let array1=map(range(powers[0]),'alpha[v:val%26]." "')
	if a:len<=powers[0]
		return array1
	elseif a:len<=powers[0]+powers[1]
		return extend(array1,map(range(a:len-powers[0]),'alpha[v:val/powers[0]%26].alpha[v:val%26]." "'))
	else
		call extend(array1,map(range(powers[1]),'alpha[v:val/powers[0]%26].alpha[v:val%26]." "'))
		return extend(array1,map(range(a:len-len(array1)),'alpha[v:val/powers[1]%26].alpha[v:val/powers[0]%26].alpha[v:val%26]." "'))
	en
endfun

fun! s:getMapDisp()          
	let pad=repeat(' ',&columns+20)
	let s:disp__r=s:ms__cols*t:mBlockW+1
	let l=s:disp__r*t:mBlockH
	let templist=repeat([''],t:mBlockH)
	let last_entry_colored=copy(templist)
	let s:disp__selmap=map(range(s:ms__rows),'repeat([0],s:ms__cols)')
	let dispLines=[]
	let s:disp__color=[]
	let s:disp__colorv=[]
	let extend_color='call extend(s:disp__color,'.join(map(templist,'"colorix[".v:key."]"'),'+').')'
	let extend_colorv='call extend(s:disp__colorv,'.join(map(templist,'"colorvix[".v:key."]"'),'+').')'
	let let_colorix='let colorix=['.join(map(templist,'"[]"'),',').']'
	let let_colorvix=let_colorix[:8].'v'.let_colorix[9:]
	let let_occ='let occ=['.repeat("'',",t:mBlockH)[:-2].']'
	for i in range(s:ms__rows)
		exe let_occ
		exe let_colorix
		exe let_colorvix
		for j in range(s:ms__cols)
			if !exists("s:ms__array[s:ms__coff+j][s:ms__roff+i]") || empty(s:ms__array[s:ms__coff+j][s:ms__roff+i])
				let s:disp__selmap[i][j]=[i*l+j*t:mBlockW,0]
				continue
			en
			let k=0
			let cell_border=(j+1)*t:mBlockW
			while k<t:mBlockH && len(occ[k])>=cell_border
				let k+=1
			endw
			let parsed=split(s:ms__array[s:ms__coff+j][s:ms__roff+i],'#',1)
			if k==t:mBlockH
				let k=min(map(templist,'len(occ[v:key])*30+v:key'))%30
				if last_entry_colored[k]
					let colorix[k][-1]-=len(occ[k])-(cell_border-1)
				en
				let occ[k]=occ[k][:cell_border-2].parsed[0]
				let s:disp__selmap[i][j]=[i*l+k*s:disp__r+cell_border-1,len(parsed[0])]
			else
				let [s:disp__selmap[i][j],occ[k]]=len(occ[k])<j*t:mBlockW? [[i*l+k*s:disp__r+j*t:mBlockW,1],occ[k].pad[:j*t:mBlockW-len(occ[k])-1].parsed[0]] : [[i*l+k*s:disp__r+j*t:mBlockW+(len(occ[k])%t:mBlockW),1],occ[k].parsed[0]]
			en
			if len(parsed)>1
				call extend(colorix[k],[s:disp__selmap[i][j][0],s:disp__selmap[i][j][0]+len(parsed[0])])
				call extend(colorvix[k],['echoh NONE','echoh '.parsed[1]])
				let last_entry_colored[k]=1
			else
				let last_entry_colored[k]=0
			en
		endfor
		for z in range(t:mBlockH)
			if !empty(colorix[z]) && colorix[z][-1]%s:disp__r<colorix[z][-2]%s:disp__r
				let colorix[z][-1]-=colorix[z][-1]%s:disp__r
			en
		endfor
		exe extend_color
		exe extend_colorv
		let dispLines+=map(occ,'len(v:val)<s:ms__cols*t:mBlockW? v:val.pad[:s:ms__cols*t:mBlockW-len(v:val)-1]."\n" : v:val[:s:ms__cols*t:mBlockW-1]."\n"')
	endfor
	let s:disp__str=join(dispLines,'')
	call add(s:disp__color,99999)
	call add(s:disp__colorv,'echoh NONE')
endfun

fun! s:printMapDisp()
	let [sel,notempty]=s:disp__selmap[s:ms__r-s:ms__roff][s:ms__c-s:ms__coff]
	let colorl=len(s:disp__color)
	let p=0
	redr!
	if sel
		if sel>s:disp__color[0]
			if s:disp__color[0]
				exe s:disp__colorv[0]
				echon s:disp__str[0 : s:disp__color[0]-1]
			en
			let p=1
			while sel>s:disp__color[p]
				exe s:disp__colorv[p]
				echon s:disp__str[s:disp__color[p-1] : s:disp__color[p]-1]
				let p+=1
			endwhile
			exe s:disp__colorv[p]
			echon s:disp__str[s:disp__color[p-1]:sel-1]
		else
		 	exe s:disp__colorv[0]
			echon s:disp__str[:sel-1]
		en
	en
	if notempty
		let endmark=len(s:ms__array[s:ms__c][s:ms__r])
		let endmark=(sel+endmark)%s:disp__r<sel%s:disp__r? endmark-(sel+endmark)%s:disp__r-1 : endmark
		echohl TXBmapSel
		echon s:ms__array[s:ms__c][s:ms__r][:endmark-1]
		let endmark=sel+endmark
	else
		let endmark=sel+t:mBlockW
		echohl TXBmapSelEmpty
		echon s:disp__str[sel : endmark-1]
	en
	while s:disp__color[p]<endmark
		let p+=1
	endwhile
	exe s:disp__colorv[p]
	echon s:disp__str[endmark :s:disp__color[p]-1]
	for p in range(p+1,colorl-1)
		exe s:disp__colorv[p]
		echon s:disp__str[s:disp__color[p-1] : s:disp__color[p]-1]
	endfor
	echon get(s:gridnames,s:ms__c,'--') s:ms__r s:ms__msg
	let s:ms__msg=''
endfun
fun! s:printMapDispNoHL()
	redr!
	let [i,len]=s:disp__selmap[s:ms__r-s:ms__roff][s:ms__c-s:ms__coff]
	echon i? s:disp__str[0 : i-1] : ''
	if len
		let len=len(s:ms__array[s:ms__c][s:ms__r])
		let len=(i+len)%s:disp__r<i%s:disp__r? len-(i+len)%s:disp__r-1 : len
		echohl TXBmapSel
		echon s:ms__array[s:ms__c][s:ms__r][:len]
	else
		let len=t:mBlockW
		echohl TXBmapSelEmpty
		echon s:disp__str[i : i+len-1]
	en
	echohl NONE
	echon s:disp__str[i+len :] get(s:gridnames,s:ms__c,'--') s:ms__r s:ms__msg
	let s:ms__msg=''
endfun

fun! s:navMapKeyHandler(c)
	if a:c is -1
		if g:TXBmsmsg[0]==1
			let s:ms__prevcoord=copy(g:TXBmsmsg)
		elseif g:TXBmsmsg[0]==2
			if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
				let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/t:mBlockH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/t:mBlockW]),0]
				let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
				call s:getMapDisp()
				call s:ms__displayfunc()
			en
			let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%t:mBlockW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%t:mBlockH]
		elseif g:TXBmsmsg[0]==3
			if g:TXBmsmsg==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:ms__settings
				return
			elseif s:ms__prevcoord[0]==1
				if &ttymouse=='xterm' && s:ms__prevcoord[1]!=g:TXBmsmsg[1] && s:ms__prevcoord[2]!=g:TXBmsmsg[2] 
					if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
						let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/t:mBlockH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/t:mBlockW]),0]
						let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
						call s:getMapDisp()
						call s:ms__displayfunc()
					en
					let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%t:mBlockW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%t:mBlockH]
				else
					let s:ms__r=(g:TXBmsmsg[2]-&lines+&ch-1)/t:mBlockH+s:ms__roff
					let s:ms__c=(g:TXBmsmsg[1]-1)/t:mBlockW+s:ms__coff
					if [s:ms__r,s:ms__c]==s:ms__prevclick
						let [&ch,&more,&ls,&stal]=s:ms__settings
						call s:doSyntax(s:gotoPos(s:ms__c,t:mapL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#',1),2,''))
						return
					en
					let s:ms__prevclick=[s:ms__r,s:ms__c]
					let s:ms__prevcoord=[0,0,0]
					let [roffn,coffn]=[s:ms__r<s:ms__roff? s:ms__r : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__r-s:ms__rows+1 : s:ms__roff,s:ms__c<s:ms__coff? s:ms__c : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__c-s:ms__cols+1 : s:ms__coff]
					if [s:ms__roff,s:ms__coff]!=[roffn,coffn] || s:ms__redr
						let [s:ms__roff,s:ms__coff,s:ms__redr]=[roffn,coffn,0]
						call s:getMapDisp()
					en
					call s:ms__displayfunc()
				en
			en
		en
		call feedkeys("\<plug>TxbY")
	else
		exe get(s:mapdict,a:c,'let s:ms__msg=" Press f1 for help or q to quit"')
		if s:ms__continue==1
			let [roffn,coffn]=[s:ms__r<s:ms__roff? s:ms__r : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__r-s:ms__rows+1 : s:ms__roff,s:ms__c<s:ms__coff? s:ms__c : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__c-s:ms__cols+1 : s:ms__coff]
			if [s:ms__roff,s:ms__coff]!=[roffn,coffn] || s:ms__redr
				let [s:ms__roff,s:ms__coff,s:ms__redr]=[roffn,coffn,0]
				call s:getMapDisp()
			en
			call s:ms__displayfunc()
			call feedkeys("\<plug>TxbY")
		elseif s:ms__continue==2
			let [&ch,&more,&ls,&stal]=s:ms__settings
			call s:doSyntax(s:gotoPos(s:ms__c,t:mapL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#',1),2,''))
		else
			let [&ch,&more,&ls,&stal]=s:ms__settings
		en
	en
endfun

fun! s:doSyntax(stmt)
	if empty(a:stmt)
		return
	en
	let num=''
	let com={'s':0,'r':0,'R':0,'j':0,'k':0,'l':0,'C':0,'M':0,'W':0}
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
		call s:nav(-min([eval(join(map(range(s:ms__c-1,s:ms__c-com.s,-1),'1+t:txb.size[(v:val+t:txb__len)%t:txb__len]'),'+')),!com.W? &columns-winwidth(0) : &columns>com.W? &columns-com.W : 0]))
	en
endfun

let TXBkyCmd.o='let s:kc__continue=0|cal s:navMap(t:txb.map,t:txb__ix[expand("%")],line(".")/t:mapL)'
fun! s:navMap(array,c_ini,r_ini)
	let t:mBlockH=exists('t:txb.settings["map cell height"]')? t:txb.settings['map cell height'] : 2
	let t:mBlockW=exists('t:txb.settings["map cell width"]')? t:txb.settings['map cell width'] : 5
	let s:ms__num='01'
    let s:ms__posmes=(line('.')%t:mapL? line('.')%t:mapL.'j' : '').(virtcol('.')-1? virtcol('.')-1.'l' : '')
	let s:ms__initbk=[a:r_ini,a:c_ini]
	let s:ms__settings=[&ch,&more,&ls,&stal]
		let [&more,&ls,&stal]=[0,0,0]
		let &ch=&lines
	let s:ms__prevclick=[0,0]
	let s:ms__prevcoord=[0,0,0]
	let s:ms__array=a:array
	let s:ms__msg=''
	let s:ms__r=a:r_ini
	let s:ms__c=a:c_ini
	let s:ms__continue=1
	let s:ms__redr=1
	let s:ms__rows=(&ch-1)/t:mBlockH
	let s:ms__cols=(&columns-1)/t:mBlockW
	let s:ms__roff=max([s:ms__r-s:ms__rows/2,0])
	let s:ms__coff=max([s:ms__c-s:ms__cols/2,0])
	let s:ms__displayfunc=function('s:printMapDisp')
	call s:getMapDisp()
	call s:ms__displayfunc()
	let g:TXBkeyhandler=function("s:navMapKeyHandler")
	call feedkeys("\<plug>TxbY")
endfun
let s:last_yanked_is_column=0
let s:map_bookmark=0
let s:mapdict={"\e":"let s:ms__continue=0|redr",
\"\<f1>":'let width=&columns>80? min([&columns-10,80]) : &columns-2|let s:map_bookmark=s:pager(s:formatPar("\n\n\\CMap Help\n\nKeyboard: (Each map grid is 1 split x ".t:mapL." lines)
\\n    h j k l                   move 1 block cardinally*
\\n    y u b n                   move 1 block diagonally*
\\n    0 $                       Beginning / end of line
\\n    H M L                     High / Middle / Low of screen
\\n    x                         clear and obtain cell
\\n    o O                       obtain cell / Obtain column
\\n    p P                       Put obtained cell or column
\\n    c                         Change label
\\n    g <cr>                    Goto block (and exit map)
\\n    I D                       Insert / Delete and obtain column
\\n    Z                         Adjust map block size
\\n    T                         Toggle color
\\n    q                         Quit
\\n*The movement commands take counts, as in vim. Eg, 3j will move down 3 rows. The count is capped at 99.".(!has("gui_running")? "\n\nMouse:
\\n    doubleclick               Goto block
\\n    drag                      Pan
\\n    click at topleft corner   Quit
\\n    drag to topleft corner    Show map
\\n\nMouse commands only work when ttymouse is set to xterm2 or sgr. When ttymouse is xterm, a limited set of features will work." : "\n\n**Mouse is unsupported in gVim**")."\n\n\\CColor and Position (Optional):
\\n\nWhen [c]hanging a label, you will also be prompted for an optional highlight group and positioning command. Type '':hi'' for a list of currently defined highlight groups.
\\n\nPositioning commands move the jump from its default position of the split being at the left edge and the cursor at the top left corner. Eg, ''CM'' will [C]enter the split and put the cursor line in the screen [M]iddle. The full list of commmands is:\n
\\n    j k l  Cursor up / down / right
\\n    s      Shift view left 1 split
\\n    r R    Shift view down / up 1 row
\\n    C      Centered split horizontally (ignore s)
\\n    M      Scroll so cursor line is Middle line (ignore r R)
\\n    W*     Virtual split width
\\n\n* By default ''s'' won''t shift the split offscreen but only push it to the right edge, regardless of count. But setting the virtual width, eg, ''45s15W'', would cause ''s'' to shift further (here, up to the point where only 15 columns are visible.) Likewise, ''C'' centers the split as if it were ''W'' columns wide",width,(&columns-width)/2),s:map_bookmark)',
\"q":"let s:ms__continue=0",
\"l":"let s:ms__c+=s:ms__num|let s:ms__num='01'",
\"h":"let s:ms__c=max([s:ms__c-s:ms__num,0])|let s:ms__num='01'",
\"j":"let s:ms__r+=s:ms__num|let s:ms__num='01'",
\"k":"let s:ms__r=max([s:ms__r-s:ms__num,0])|let s:ms__num='01'",
\"\<right>":"let s:ms__c+=s:ms__num|let s:ms__num='01'",
\"\<left>":"let s:ms__c=max([s:ms__c-s:ms__num,0])|let s:ms__num='01'",
\"\<down>":"let s:ms__r+=s:ms__num|let s:ms__num='01'",
\"\<up>":"let s:ms__r=max([s:ms__r-s:ms__num,0])|let s:ms__num='01'",
\"y":"let [s:ms__r,s:ms__c]=[max([s:ms__r-s:ms__num,0]),max([s:ms__c-s:ms__num,0])]|let s:ms__num='01'",
\"u":"let [s:ms__r,s:ms__c]=[max([s:ms__r-s:ms__num,0]),s:ms__c+s:ms__num]|let s:ms__num='01'",
\"b":"let [s:ms__r,s:ms__c]=[s:ms__r+s:ms__num,max([s:ms__c-s:ms__num,0])]|let s:ms__num='01'",
\"n":"let [s:ms__r,s:ms__c]=[s:ms__r+s:ms__num,s:ms__c+s:ms__num]|let s:ms__num='01'",
\"1":"let s:ms__num=s:ms__num is '01'? '1' : s:ms__num>98? s:ms__num : s:ms__num.'1'",
\"2":"let s:ms__num=s:ms__num is '01'? '2' : s:ms__num>98? s:ms__num : s:ms__num.'2'",
\"3":"let s:ms__num=s:ms__num is '01'? '3' : s:ms__num>98? s:ms__num : s:ms__num.'3'",
\"4":"let s:ms__num=s:ms__num is '01'? '4' : s:ms__num>98? s:ms__num : s:ms__num.'4'",
\"5":"let s:ms__num=s:ms__num is '01'? '5' : s:ms__num>98? s:ms__num : s:ms__num.'5'",
\"6":"let s:ms__num=s:ms__num is '01'? '6' : s:ms__num>98? s:ms__num : s:ms__num.'6'",
\"7":"let s:ms__num=s:ms__num is '01'? '7' : s:ms__num>98? s:ms__num : s:ms__num.'7'",
\"8":"let s:ms__num=s:ms__num is '01'? '8' : s:ms__num>98? s:ms__num : s:ms__num.'8'",
\"9":"let s:ms__num=s:ms__num is '01'? '9' : s:ms__num>98? s:ms__num : s:ms__num.'9'",
\"0":"let [s:ms__c,s:ms__num]=s:ms__num is '01'? [s:ms__coff,s:ms__num] : [s:ms__c,s:ms__num>998? s:ms__num : s:ms__num.'0']",
\"$":"let s:ms__c=s:ms__coff+s:ms__cols-1",
\"H":"let s:ms__r=s:ms__roff",
\"M":"let s:ms__r=s:ms__roff+s:ms__rows/2",
\"L":"let s:ms__r=s:ms__roff+s:ms__rows-1",
\"T":"let s:ms__displayfunc=s:ms__displayfunc==function('s:printMapDisp')? function('s:printMapDispNoHL') : function('s:printMapDisp')",
\"x":"if exists('s:ms__array[s:ms__c][s:ms__r]')|let @\"=s:ms__array[s:ms__c][s:ms__r]|let s:ms__array[s:ms__c][s:ms__r]=''|let s:ms__redr=1|en",
\"o":"if exists('s:ms__array[s:ms__c][s:ms__r]')|let @\"=s:ms__array[s:ms__c][s:ms__r]|let s:ms__msg=' Cell obtained'|let s:last_yanked_is_column=0|en",
\"p":"if s:last_yanked_is_column\n
	\if s:ms__c+1>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+2-len(s:ms__array)),',').']'))\n
	\en\n
	\call insert(s:ms__array,s:copied_column,s:ms__c+1)\n
	\let s:ms__redr=1\n
\else\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\if s:ms__r>=len(s:ms__array[s:ms__c])\n
		\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
	\en\n
	\let s:ms__array[s:ms__c][s:ms__r]=@\"\n
	\let s:ms__redr=1\n
\en",
\"P":"if s:last_yanked_is_column\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\call insert(s:ms__array,s:copied_column,s:ms__c)\n
	\let s:ms__redr=1\n
\else\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\if s:ms__r>=len(s:ms__array[s:ms__c])\n
		\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
	\en\n
	\let s:ms__array[s:ms__c][s:ms__r]=@\"\n
	\let s:ms__redr=1\n
\en",
\"c":"let [lblTxt,hiColor,pos]=extend(split(exists('s:ms__array[s:ms__c][s:ms__r]')? s:ms__array[s:ms__c][s:ms__r] : '','#',1),['',''])[:2]\n
\let inLbl=input(s:disp__str.'Label: ',lblTxt)\n
\if !empty(inLbl)\n
	\let inHL=input('\nHighlight group: ',hiColor,'highlight')\n
	\if [s:ms__r,s:ms__c]==s:ms__initbk\n
		\let inPos=input(empty(s:ms__posmes)? '\nPosition: ' : '\nPosition ('.s:ms__posmes.' will jump to current cursor position) :', empty(pos)? s:ms__posmes : pos)\n
	\else\n
		\let inPos=input('\nPosition: ',pos)\n
	\en\n
	\if stridx(inLbl.inHL.inPos,'#')!=-1\n
		\let s:ms__msg=' ERROR: ''#'' is reserved for syntax and not allowed in the label text or settings'\n
	\else\n
		\if s:ms__c>=len(s:ms__array)\n
			\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
		\en\n
		\if s:ms__r>=len(s:ms__array[s:ms__c])\n
			\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
		\en\n
		\let s:ms__array[s:ms__c][s:ms__r]=strtrans(inLbl).'#'.strtrans(inHL).'#'.strtrans(inPos)\n
		\let s:ms__redr=1\n
	\en\n
\else\n
	\let s:ms__msg=' Change aborted (press ''x'' to clear)'\n
\en\n",
\"g":'let s:ms__continue=2',
\"Z":'let t:mBlockW=min([10,max([1,input(s:disp__str."\nBlock width (1-10): ",t:mBlockW)])])|let t:mBlockH=min([10,max([1,input("\nBlock height (1-10): ",t:mBlockH)])])|let [t:txb.settings["map cell height"],t:txb.settings["map cell width"],s:ms__redr,s:ms__rows,s:ms__cols]=[t:mBlockH,t:mBlockW,1,(&ch-1)/t:mBlockH,(&columns-1)/t:mBlockW]',
\"I":'if s:ms__c<len(s:ms__array)|call insert(s:ms__array,[],s:ms__c)|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." inserted"|en',
\"D":'if s:ms__c<len(s:ms__array) && input(s:disp__str."\nReally delete column? (y/n)")==?"y"|let s:copied_column=remove(s:ms__array,s:ms__c)|let s:last_yanked_is_column=1|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." deleted"|en',
\"O":'let s:copied_column=s:ms__c<len(s:ms__array)? deepcopy(s:ms__array[s:ms__c]) : []|let s:ms__msg=" Col ".(s:ms__c)." Obtained"|let s:last_yanked_is_column=1'}
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBkyCmd["\<c-x>"]='cal s:deleteHiddenBuffers()|let [s:kc__msg,s:kc__continue]=["Hidden Buffers Deleted",0]'

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

let TXBkyCmd.S="let s:kc__continue=0\n
\let settings_dict=deepcopy(t:txb.settings)\n
\let settings_dict._global_hotkey=g:TXB_HOTKEY\n
\let prev_autoexe=settings_dict.autoexe\n
\let prev_splitW=settings_dict['split width']\n
\if s:settingsPager(settings_dict,s:ErrorCheck)\n
	\let s:kc__msg='Settings saved!'\n
	\exe 'silent! nunmap' g:TXB_HOTKEY\n
	\exe 'nn <silent>' settings_dict._global_hotkey ':call {exists(\"t:txb\")? \"TXBdoCmd\" : \"TXBinit\"}(-99)<cr>'\n
	\let g:TXB_HOTKEY=settings_dict._global_hotkey\n
	\unlet settings_dict._global_hotkey\n
	\let t:txb.settings=deepcopy(settings_dict)\n
	\let t:panL=t:txb.settings['lines panned by j,k']\n
	\let t:aniStepH=t:txb.settings['kbd x pan speed']\n
	\let t:aniStepV=t:txb.settings['kbd y pan speed']\n
	\let t:mouseAcc=t:txb.settings['mouse pan speed']\n
	\let t:mapL=t:txb.settings['lines per map grid']\n
	\if prev_autoexe!=#t:txb.settings.autoexe\n
		\echohl MoreMsg\n
		\if 'y'==?input('Apply changed autoexe setting to current splits? (y/n)')\n
        	\let t:txb.exe=repeat([t:txb.settings.autoexe],len(t:txb.name))\n
			\call s:redraw()\n
			\let s:kc__msg.=' (Autoexe settings applied to current splits)'\n
		\else\n
			\let s:kc__msg.=' (Only newly appended splits will inherit new autoexe)'\n
		\en\n
		\echohl NONE\n
	\en\n
	\if prev_splitW!=#t:txb.settings['split width']\n
		\echohl MoreMsg\n
		\if 'y'==?input('Resize current splits to new default split width value? (y/n)')\n
        	\let t:txb.size=repeat([t:txb.settings['split width']],len(t:txb.name))\n
			\call s:redraw()\n
			\let s:kc__msg.=' (Current splits resized)'\n
		\else\n
			\let s:kc__msg.=' (Only newly appended splits will inherit split width)'\n
		\en\n
		\echohl NONE\n
	\en\n
\else\n
	\let s:kc__msg='Cancelled'\n
\en"
let s:sp__cursor=0
let s:sp__offset=0
let s:sp__height=9
fun! s:settingsPager(dict,errorcheck)
	let settings=[&more,&ch]
	let continue=1
	let smsg=''
	let keys=sort(keys(a:dict))
	let vals=map(copy(keys),'deepcopy(a:dict[v:val])')
	let [&more,&ch]=[0,s:sp__height+3]
	let cursor=s:sp__cursor<0? 0 : s:sp__cursor>=len(keys)? len(keys)-1 : s:sp__cursor

	let height=s:sp__height
	let offset=s:sp__offset<0? 0 : s:sp__offset>len(keys)-height+1? (len(keys)-height+1>=0? len(keys)-height+1 : 0) : s:sp__offset
    let offset=offset<cursor-height? cursor-height : offset>cursor? cursor : offset

	while continue
		redr!
		echohl Title
			echo 'Settings: j/k:up/down [c]change [S]ave [Q]uit [D]efaults'
		echohl NONE
		for i in range(offset,offset+height-1)
        	if i==cursor
            	echohl Visual
                	echo keys[i] ':' vals[i]
				echohl None
			else
                echo keys[i] ':' vals[i]
			en
		endfor
		if !empty(smsg)
			echohl WarningMsg
				echo smsg
			echohl NONE
		else
			echohl MoreMsg
			echo get(a:errorcheck,keys[cursor],'')[2]
			echohl NONE
		en
		let smsg=''
		let input=''
		let c=getchar()
		exe get(s:settingscom,c,'')
		let cursor=cursor<0? 0 : cursor>=len(keys)? len(keys)-1 : cursor

    	let offset=offset<cursor-height+1? cursor-height+1 : offset>cursor? cursor : offset

		if !empty(input)
			exe get(a:errorcheck,keys[cursor],[0,'let vals[cursor]=input'])[1]
		en
	endwhile
	let [&more,&ch]=settings
	redr
	let s:sp__cursor=cursor

	let s:sp__height=height
	let s:sp__offset=offset

	return exitcode
endfun
let s:settingscom={}
let s:settingscom.68="echohl WarningMsg|let confirm=input('Restore defaults (y/n)?')|echohl None\n
\if confirm==?'y'\n
	\for k in range(len(keys))\n
		\let vals[k]=get(a:errorcheck,keys[k],[vals[k]])[0]\n
	\endfor\n
\en"
let s:settingscom.113="let continue=0|let exitcode=0"
let s:settingscom.106='let cursor+=1'
let s:settingscom.107='let cursor-=1'
let s:settingscom.99="let input=input('Enter new value: ',type(vals[cursor])==1? vals[cursor] : string(vals[cursor]))"
let s:settingscom.83="for i in range(len(keys))\n
	\let a:dict[keys[i]]=vals[i]\n
\endfor\n
\let continue=0\n
\let exitcode=1"
let s:settingscom.27=s:settingscom.113

let s:ErrorCheck={'map cell width':[5,'','integer between 1 and 10'],'map cell height':[2,'','integer between 1 and 10'],'lines panned by j,k':[15,'','integer > 0'],'kbd x pan speed':[9,'','animation speed; integer > 0'],'kbd y pan speed':[2,'','animation speed; integer > 0'],'mouse pan speed':[[0,1,2,4,7,10,15,21,24,27],'','should be ascending list: every N steps with mouse -> speed[N] steps in plane'],'lines per map grid':[45,'','Each map grid is 1 split and this many lines'],'_global_hotkey':['<f10>','',"Examples: (don't type quotes) '<f10>', '<c-v>' (ctrl-v), 'vx' (v then x)\n**WARNING** If you're stuck with an inoperable hotkey, evoke ':call TXBinit()', then press 'S' to reset key"],'autoexe':['se nowrap scb cole=2','','command when a split is unhidden (default value). Change for individual splits via (HOTKEY) E'],'split width':[60,'','Default split width. Change for individual splits with (HOTKEY) E']}
let s:ErrorCheck['split width'][1]="let input=str2nr(input)|if input<=2\n
	\let smsg.='Error: default split width must be >2'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck['lines panned by j,k'][1]="let input=str2nr(input)|if input<=0\n
	\let smsg.='Error: lines panned by j,k must be >=0'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck['kbd x pan speed'][1]="let input=str2nr(input)|if input<=0\n
	\let smsg.='Error: x pan speed must be >=0'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck['kbd y pan speed'][1]="let input=str2nr(input)|if input<=0\n
	\let smsg.='Error: y pan speed must be >=0'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck._global_hotkey[1]="let vals[cursor]=input"
let s:ErrorCheck.autoexe[1]="let vals[cursor]=input"
let s:ErrorCheck['mouse pan speed'][1]="unlet! inList|let inList=type(input)==3? input : eval(input)\n
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
\en"
let s:ErrorCheck['lines per map grid'][1]="let input=str2nr(input)|if input<=0\n
	\let smsg.='Error: lines per map grid must be >=0'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck['map cell height'][1]="let input=str2nr(input)|if input<=0 || input>10\n
	\let smsg.='Error: map cell height must be between 0 and 10'\n
\else\n
	\let vals[cursor]=input\n
\en"
let s:ErrorCheck['map cell width'][1]="let input=str2nr(input)|if input<=0 || input>10\n
	\let smsg.='Error: map cell width must be between 0 and 10'\n
\else\n
	\let vals[cursor]=input\n
\en"

fun! s:pager(list,start)
	let pad=repeat(' ',&columns)
	let settings=[&more,&ch]
	let [&more,&ch]=[0,&lines]
	let [pos,bot,continue]=[-1,max([len(a:list)-&lines+1,0]),1]
	let next=a:start<0? 0 : a:start>bot? bot : a:start
	while continue
		if pos!=next
			let pos=next
			redr!|echo join(a:list[pos : pos+&lines-2],"\n")."\nSPACE/d/j:down, b/u/k: up, g/G:top/bottom, q:quit"
		en
		exe get(s:pagercom,getchar(),'')
	endwhile
	redr
	let [&more,&ch]=settings
	return pos
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
			\echon '\r'.a:list[pos+&lines-2].'\nSPACE/d/j:down, b/u/k: up, g/G:top/bottom, q:quit'\n
		\else\n
			\echon '\r'.a:list[pos+&lines-2].pad[:50-dispw].'\nSPACE/d/j:down, b/u/k: up, g/G:top/bottom, q:quit'\n
		\en\n
	\en",
\107:'let next=pos>0? pos-1 : pos',
\98:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\103:'let next=0',
\71:'let next=bot'}
let s:pagercom["\<up>"]=s:pagercom.107
let s:pagercom["\<down>"]=s:pagercom.106
let s:pagercom["\<left>"]=s:pagercom.98
let s:pagercom["\<right>"]=s:pagercom.32
let s:pagercom.100=s:pagercom.32
let s:pagercom.117=s:pagercom.98
let s:pagercom.27=s:pagercom.113

fun! s:gotoPos(col,row)
	let name=get(t:txb.name,a:col,-1)
	if name==-1
		echoerr "Split ".a:col." does not exist."
		return 1
	elseif name!=#expand('%')
		wincmd t
		exe 'e '.escape(name,' ')
	en
	norm! 0
	only
	call s:redraw()
	exe 'norm!' (a:row? a:row : 1).'zt'
endfun

fun! s:blockPan(dx,y,...)
	let cury=line('w0')
	let absolute_x=exists('a:1')? a:1 : 0
	let dir=absolute_x? absolute_x : a:dx
	let y=a:y>cury?  (a:y-cury-1)/t:panL+1 : a:y<cury? -(cury-a:y-1)/t:panL-1 : 0
	let update_ydest=y>=0? 'let y_dest=!y? cury : cury/'.t:panL.'*'.t:panL.'+'.t:panL : 'let y_dest=!y? cury : cury>'.t:panL.'? (cury-1)/'.t:panL.'*'.t:panL.' : 1'
	let pan_y=(y>=0? 'let cury=cury+'.t:aniStepV.'<y_dest? cury+'.t:aniStepV.' : y_dest' : 'let cury=cury-'.t:aniStepV.'>y_dest? cury-'.t:aniStepV.' : y_dest')."\n
		\if cury>line('$')\n
			\let longlinefound=0\n
			\for i in range(winnr('$')-1)\n
				\wincmd w\n
				\if line('$')>=cury\n
					\exe 'norm!' cury.'zt'\n
					\let longlinefound=1\n
					\break\n
				\en\n
			\endfor\n
			\if !longlinefound\n
				\exe 'norm! Gzt'\n
			\en\n
		\else\n
			\exe 'norm!' cury.'zt'\n
		\en"
	if dir>0
		let i=0
		let continue=1
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			while winwidth(1)>t:aniStepH
				call s:nav(t:aniStepH)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:nav(winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i+=1
			let continue=absolute_x? (t:txb__ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i<a:dx
		endwhile
	elseif dir<0
		let i=0
		let continue=!map([t:txb__ix[bufname(winbufnr(1))]],'absolute_x && v:val==a:dx && winwidth(1)>=t:txb.size[v:val]')[0]
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			let ix=t:txb__ix[bufname(buf0)]
			if winwidth(1)>=t:txb.size[ix]
				call s:nav(-4)
				let buf0=winbufnr(1)
			en
			while winwidth(1)<t:txb.size[ix]-t:aniStepH
				call s:nav(-t:aniStepH)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:nav(-t:txb.size[ix]+winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i-=1
			let continue=absolute_x? (t:txb__ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i>a:dx
		endwhile
	en
	while y
		exe update_ydest
		while cury!=y_dest
			exe pan_y
			redr
		endwhile
		let y+=y>0? -1 : y<0? 1 : 0
	endwhile
endfun
let s:Y1='let s:kc__y=s:kc__y/t:panL*t:panL+s:kc__num*t:panL|'
let s:Ym1='let s:kc__y=max([1,s:kc__y/t:panL*t:panL-s:kc__num*t:panL])|'
	let TXBkyCmd.h='cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)'
	let TXBkyCmd.j=s:Y1.'cal s:blockPan(0,s:kc__y)|let s:kc__num="01"|call s:updateCursPos()'
	let TXBkyCmd.k=s:Ym1.'cal s:blockPan(0,s:kc__y)|let s:kc__num="01"|call s:updateCursPos()' 
	let TXBkyCmd.l='cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
	let TXBkyCmd.y=s:Ym1.'cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)' 
	let TXBkyCmd.u=s:Ym1.'cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
	let TXBkyCmd.b =s:Y1.'cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)' 
	let TXBkyCmd.n=s:Y1.'cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
let TXBkyCmd.1="let s:kc__num=s:kc__num is '01'? '1' : s:kc__num>98? s:kc__num : s:kc__num.'1'"
let TXBkyCmd.2="let s:kc__num=s:kc__num is '01'? '2' : s:kc__num>98? s:kc__num : s:kc__num.'2'"
let TXBkyCmd.3="let s:kc__num=s:kc__num is '01'? '3' : s:kc__num>98? s:kc__num : s:kc__num.'3'"
let TXBkyCmd.4="let s:kc__num=s:kc__num is '01'? '4' : s:kc__num>98? s:kc__num : s:kc__num.'4'"
let TXBkyCmd.5="let s:kc__num=s:kc__num is '01'? '5' : s:kc__num>98? s:kc__num : s:kc__num.'5'"
let TXBkyCmd.6="let s:kc__num=s:kc__num is '01'? '6' : s:kc__num>98? s:kc__num : s:kc__num.'6'"
let TXBkyCmd.7="let s:kc__num=s:kc__num is '01'? '7' : s:kc__num>98? s:kc__num : s:kc__num.'7'"
let TXBkyCmd.8="let s:kc__num=s:kc__num is '01'? '8' : s:kc__num>98? s:kc__num : s:kc__num.'8'"
let TXBkyCmd.9="let s:kc__num=s:kc__num is '01'? '9' : s:kc__num>98? s:kc__num : s:kc__num.'9'"
let TXBkyCmd.0="let s:kc__num=s:kc__num is '01'? '01' : s:kc__num>98? s:kc__num : s:kc__num.'1'"
let TXBkyCmd["\<up>"]=TXBkyCmd.k
let TXBkyCmd["\<down>"]=TXBkyCmd.j
let TXBkyCmd["\<left>"]=TXBkyCmd.h
let TXBkyCmd["\<right>"]=TXBkyCmd.l

fun! s:snapToGrid()
	let [ix,l0]=[t:txb__ix[expand('%')],line('.')]
	let y=l0>t:mapL? l0-l0%t:mapL : 1
	let poscom=get(split(get(get(t:txb.map,ix,[]),l0/t:mapL,''),'#',1),2,'')
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
let TXBkyCmd['.']='call s:snapToGrid()|let s:kc__continue=0|call s:updateCursPos()' 

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
"mouse    leftdown leftdrag leftup
"xterm    32                35
"xterm2   32       64       35
"sgr      0M       32M      0m 
"TXBmsmsg 1        2        3            else 0
fun! <SID>getmouse()
	if &ttymouse=~?'xterm'
		let g:TXBmsmsg=[getchar(0)*0+getchar(0),getchar(0)-32,getchar(0)-32]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==64? 2 : g:TXBmsmsg[0]==32? 1 : g:TXBmsmsg[0]==35? 3 : 0
	elseif &ttymouse==?'sgr'
		let g:TXBmsmsg=split(join(map([getchar(0)*0+getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';')
		let g:TXBmsmsg=len(g:TXBmsmsg)> 2? [str2nr(g:TXBmsmsg[0]).g:TXBmsmsg[2][len(g:TXBmsmsg[2])-1],str2nr(g:TXBmsmsg[1]),str2nr(g:TXBmsmsg[2])] : [0,0,0]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==#'32M'? 2 : g:TXBmsmsg[0]==#'0M'? 1 : (g:TXBmsmsg[0]==#'0m' || g:TXBmsmsg[0]==#'32K') ? 3 : 0
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
	let s:kc__num='01'
	let s:kc__y=line('w0')
	let s:kc__continue=1
	let s:kc__msg=''
	call s:saveCursPos()
	let g:TXBkeyhandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:inicmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:TXBkyCmd,a:c,'let s:kc__continue=0|let s:kc__msg="(Invalid command) Press '.g:TXB_HOTKEY.' F1 for help"')
	if s:kc__continue
		let s0=t:txb__ix[bufname('')]
		let t_r=line('.')/t:mapL
		echon s:gridnames[s0] t_r ' ' empty(s:kc__msg)? get(get(t:txb.map,s0,[]),t_r,'')[:&columns-9] : s:kc__msg
		let s:kc__msg=''
		call feedkeys("\<plug>TxbZ") 
	elseif !empty(s:kc__msg)
		redr|ec s:kc__msg
	else
		let s0=t:txb__ix[bufname('')]
		let t_r=line('.')/t:mapL
		redr|echo '(done)' s:gridnames[s0].t_r get(get(t:txb.map,s0,[]),t_r,'')[:&columns-17]
	en
endfun

let TXBkyCmd[-1]='let s:kc__continue=0|call feedkeys("\<leftmouse>")'
let TXBkyCmd[-99]=""
let TXBkyCmd.D="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb__ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call s:deleteSplit(ix)\n
		\wincmd W\n
		\call s:saveCursPos()\n
		\call s:redraw()\n
		\let s:kc__msg='col '.ix.' removed'\n
	\else\n
		\let s:kc__msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en\n
\let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd.A="let ix=get(t:txb__ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append (do not escape spaces): ',substitute(bufname('%'),'\\d\\+','\\=(\"00000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\let error=s:appendSplit(ix,file)\n
	\if empty(error)\n
		\try\n
			\call s:redraw()\n
			\let s:kc__msg='col '.(ix+1).' appended'\n
		\catch\n
			\call s:deleteSplit(ix)\n
			\let s:kc__msg='Error detected while loading plane: file append aborted'\n
		\endtry\n
	\else\n
		\let s:kc__msg='Error: '.error\n
	\en\n
\else\n
	\let s:kc__msg='Current buffer not in plane'\n
\en\n
\let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd.q="let s:kc__continue=0"
let TXBkyCmd["\e"]=TXBkyCmd.q
let TXBkyCmd.r="call s:redraw()|redr|let s:kc__msg='(redrawn)'|let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd["\<f1>"]='call s:printHelp()|let s:kc__continue=0'
let TXBkyCmd.E='call s:editSplitSettings()|let s:kc__continue=0'

fun! s:editSplitSettings()
	let ix=get(t:txb__ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input('Column width: ',t:txb.size[ix])
		if empty(input) | return | en
		let t:txb.size[ix]=str2nr(input)
		let input=input("Autoexecute on load: ",t:txb.exe[ix])
		if empty(input) | return | en
		let t:txb.exe[ix]=input
		let input=input('Column position (0-'.(t:txb__len-1).'): ',ix)
		if empty(input) | return | en
		let newix=input
		if newix>=0 && newix<t:txb__len && newix!=ix
			let item=remove(t:txb.name,ix)
			call insert(t:txb.name,item,newix)
			let item=remove(t:txb.size,ix)
			call insert(t:txb.size,item,newix)
			let item=remove(t:txb.exe,ix)
			call insert(t:txb.exe,item,newix)
			let [t:txb__ix,i]=[{},0]
			for e in t:txb.name
				let [t:txb__ix[e],i]=[i,i+1]
			endfor
		en
		call s:redraw()
	en
endfun

fun! s:deleteSplit(index)
	call remove(t:txb.name,a:index)	
	call remove(t:txb.size,a:index)	
	call remove(t:txb.exe,a:index)	
	let t:txb__len=len(t:txb.name)
	let [t:txb__ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb__ix[e],i]=[i,i+1]
	endfor
endfun
fun! s:appendSplit(index,file,...)
	if empty(a:file)
		return 'File name is empty'
	elseif has_key(t:txb__ix,a:file)
		return 'Duplicate entries not allowed'
	en
	call insert(t:txb.name,a:file,a:index+1)
	call insert(t:txb.size,exists('a:1')? a:1 : t:txb.settings['split width'],a:index+1)
	call insert(t:txb.exe,t:txb.settings.autoexe,a:index+1)
	let t:txb__len=len(t:txb.name)
	let [t:txb__ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb__ix[e],i]=[i,i+1]
	endfor
	if len(s:gridnames)<t:txb__len
		let s:gridnames=s:getGridNames(t:txb__len+50)
	endif
endfun

fun! s:redraw()
	let [ix0,win0]=[get(t:txb__ix,bufname(''),-1),winnr()]
	if ix0==-1
		let ix0=0
		only
		let name=t:txb.name[0]
		if name!=#expand('%')
			exe 'e '.escape(name,' ')
		en
	en
	let pos=[bufnr('%'),line('w0')]
	exe winnr()==1? "norm! mt" : "norm! mt0"
	se scrollopt=jump
	if winnr()==1 && !&wrap
		let offset=virtcol('.')-wincol()
		if offset<t:txb.size[ix0]
			exe (t:txb.size[ix0]-offset).'winc|'
		en
	en
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,ix0,0]
	let remain=split0
	while remain>=1
		let colt=(colt-1)%t:txb__len
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[ix0,&columns-(split0>0? split0+1+t:txb.size[ix0] : min([winwidth(1),t:txb.size[ix0]])),1]
	while remain>=2
		let colb=(colb+1)%t:txb__len
		let colsRight+=1
		let remain-=t:txb.size[colb]+1
	endwhile
	let colbw=t:txb.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(ix0-win0)%t:txb__len
		for i in range(dif)
			let colt=(colt-1)%t:txb__len
			exe 'top vsp '.escape(t:txb.name[colt],' ')
			exe t:txb.exe[colt]
			se wfw
		endfor
	elseif dif<0
		wincmd t
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	let dif=colsRight+colsLeft-winnr('$')
	if dif>0
		let colb=(ix0+colsRight-1-dif)%t:txb__len
		for i in range(dif)
			let colb=(colb+1)%t:txb__len
			exe 'bot vsp '.escape(t:txb.name[colb],' ')
			exe t:txb.exe[colb]
			se wfw
		endfor
	elseif dif<0
		wincmd b
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	windo se nowfw
	wincmd =
	wincmd b
	let [bot,cwin]=[winnr(),-1]
	while winnr()!=cwin
		se wfw
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txb__len]
		if bufname('')!=#t:txb.name[ccol]
			exe 'e' escape(t:txb.name[ccol],' ')
		en
		exe t:txb.exe[ccol]
		if cwin==1
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(cwin==bot? colbw : t:txb.size[ccol])-winwidth(cwin)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		wincmd h
	endw
	se scrollopt=ver,jump
	try
	exe "silent norm! :syncbind\<cr>"
	catch
		se scrollopt=jump
		windo 1
		se scrollopt=ver,jump
	endtry
	exe "norm!" bufwinnr(pos[0])."\<c-w>w".pos[1]."zt`t"
	if len(s:gridnames)<t:txb__len
		let s:gridnames=s:getGridNames(t:txb__len+50)
	en
endfun

fun! s:saveCursPos()
	let t:txb__cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun
fun! s:updateCursPos(...)
    let default_scrolloff=a:0? a:1 : 0
	let win=bufwinnr(t:txb__cPos[0])
	if win!=-1
		if winnr('$')==1 || win==1
			winc t
			let offset=virtcol('.')-wincol()+1
			let width=offset+winwidth(0)-3
			exe 'norm! '.(t:txb__cPos[1]<line('w0')? 'H' : line('w$')<t:txb__cPos[1]? 'L' : t:txb__cPos[1].'G').(t:txb__cPos[2]<offset? offset : width<=t:txb__cPos[2]? width : t:txb__cPos[2]).'|'
		elseif win!=1
			exe win.'winc w'
			exe 'norm! '.(t:txb__cPos[1]<line('w0')? 'H' : line('w$')<t:txb__cPos[1]? 'L' : t:txb__cPos[1].'G').(t:txb__cPos[2]>winwidth(win)? '0g$' : t:txb__cPos[2].'|')
		en
	elseif default_scrolloff==1 || !default_scrolloff && t:txb__ix[bufname(t:txb__cPos[0])]>t:txb__ix[bufname('')]
		winc b
		exe 'norm! '.(t:txb__cPos[1]<line('w0')? 'H' : line('w$')<t:txb__cPos[1]? 'L' : t:txb__cPos[1].'G').(winnr('$')==1? 'g$' : '0g$')
	else
		winc t
		exe "norm! ".(t:txb__cPos[1]<line('w0')? 'H' : line('w$')<t:txb__cPos[1]? 'L' : t:txb__cPos[1].'G').'g0'
	en
	let t:txb__cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun

fun! s:nav(N)
	let c_bf=bufnr('')
	let c_vc=virtcol('.')
	let alignmentcmd='norm! '.line('w0').'zt'
	if a:N<0
		let N=-a:N
		let extrashift=0
		let tcol=t:txb__ix[bufname(winbufnr(1))]
		if N<&columns
			while winwidth(winnr('$'))<=N
				wincmd b
				let extrashift=(winwidth(0)==N)
				hide
			endw
		else
			wincmd t
			only
		en
		if winwidth(0)!=&columns
			wincmd t
			let topw=winwidth(0)
			if winwidth(winnr('$'))<=N+3+extrashift || winnr('$')>=9
				se nowfw
				wincmd b
				exe 'vert res-'.(N+extrashift)
				wincmd t
				if winwidth(1)==1
					wincmd l
					se nowfw
					wincmd t 
					exe 'vert res+'.(N+extrashift)
					wincmd l
					se wfw
					wincmd t
				elseif winwidth(0)==topw
					exe 'vert res+'.(N+extrashift)
				en
				se wfw
			else
				exe 'vert res+'.(N+extrashift)
			en
			while winwidth(0)>=t:txb.size[tcol]+2
				se nowfw scrollopt=jump
				let nextcol=(tcol-1)%t:txb__len
				exe 'top '.(winwidth(0)-t:txb.size[tcol]-1).'vsp '.escape(t:txb.name[nextcol],' ')
				exe alignmentcmd
				exe t:txb.exe[nextcol]
				wincmd l
				se wfw
				norm! 0
				wincmd t
				let tcol=nextcol
				se wfw scrollopt=ver,jump
			endwhile
			let offset=t:txb.size[tcol]-winwidth(0)-virtcol('.')+wincol()
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
			let loff=&wrap? -N-extrashift : virtcol('.')-wincol()-N-extrashift
			if loff>=0
				exe 'norm! '.(N+extrashift).(bufwinnr(c_bf)==-1? 'zhg$' : 'zh')
			else
				let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
				while loff<=-2
					let tcol=(tcol-1)%t:txb__len
					let loff+=t:txb.size[tcol]+1
				endwhile
				se scrollopt=jump
				exe 'e '.escape(t:txb.name[tcol],' ')
				exe alignmentcmd
				exe t:txb.exe[tcol]
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&columns-1
					let spaceremaining=&columns-t:txb.size[tcol]+loff
					let NextCol=(tcol+1)%t:txb__len
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bot '.(spaceremaining-1).'vsp '.escape(t:txb.name[NextCol],' ')
						exe alignmentcmd
						exe t:txb.exe[NextCol]
						norm! 0
						let spaceremaining-=t:txb.size[NextCol]+1
						let NextCol=(NextCol+1)%t:txb__len
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
		return -extrashift
	elseif a:N>0
		let tcol=t:txb__ix[bufname(winbufnr(1))]
		let [bcol,loff,extrashift,N]=[t:txb__ix[bufname(winbufnr(winnr('$')))],winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0),0,a:N]
		let nobotresize=0
		if N>=&columns
			if winwidth(1)==&columns
				let loff+=&columns
			else
				let loff=winwidth(winnr('$'))
				let bcol=tcol
			en
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%t:txb__len
			en
			let toshift=N-&columns
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%t:txb__len
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%t:txb__len
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%t:txb__len
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%t:txb__len
				let loff=0
			else
				let loff+=toshift	
			en
			se scrollopt=jump
			exe 'e '.escape(t:txb.name[tcol],' ')
			exe alignmentcmd
			exe t:txb.exe[tcol]
			se scrollopt=ver,jump
			only
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			if winwidth(1)==1
				let c_wn=winnr()
				wincmd t
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
				wincmd t
				hide
				if winwidth(1)==w2
					let nobotresize=1
				en
				let tcol=(tcol+1)%t:txb__len
				let loff=0
			endw
			let N+=extrashift
			let loff+=N-shifted
		en
		let wf=winwidth(1)-N
		if wf+N!=&columns
			if !nobotresize
				wincmd b
				exe 'vert res+'.N
				if virtcol('.')!=wincol()
					norm! 0
				en
				wincmd t	
				if winwidth(1)!=wf
					exe 'vert res'.wf
				en
			en
			while winwidth(winnr('$'))>=t:txb.size[bcol]+2
				wincmd b
				se nowfw scrollopt=jump
				let nextcol=(bcol+1)%t:txb__len
				exe 'rightb vert '.(winwidth(0)-t:txb.size[bcol]-1).'split '.escape(t:txb.name[nextcol],' ')
				exe alignmentcmd
				exe t:txb.exe[nextcol]
				wincmd h
				se wfw
				wincmd b
				norm! 0
				let bcol=nextcol
				se scrollopt=ver,jump
			endwhile
			wincmd t
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
			let bcol=tcol
			let spaceremaining=&columns-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let bcol=(bcol+1)%t:txb__len
				exe 'bot '.(spaceremaining-1).'vsp '.escape(t:txb.name[bcol],' ')
				exe alignmentcmd
				exe t:txb.exe[bcol]
				norm! 0
				let spaceremaining-=t:txb.size[bcol]+1
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
		return extrashift
	en
endfun
