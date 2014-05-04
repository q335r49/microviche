"https://github.com/q335r49/microviche

if &cp|se nocompatible|en                    "(Vital) Enable vim features
se noequalalways winwidth=1 winminwidth=0    "(Vital) Needed for correct panning
se sidescroll=1                              "Smoother panning
se nostartofline                             "Keeps cursor in the same position when panning
se mouse=a                                   "Enables mouse
se lazyredraw                                "Less redraws
se virtualedit=all                           "Makes leftmost split align correctly
se hidden                                    "Suppresses error messages when a modified buffer pans offscreen
se scrolloff=0                               "Ensures correct vertical panning

augroup TXB | au!

let g:TXB_HOTKEY=exists('g:TXB_HOTKEY')? g:TXB_HOTKEY : '<f10>'
let g:TXB_MSSP=exists('g:TXB_MSSP') && type(g:TXB_MSSP)==3 && g:TXB_MSSP[0]==0? g:TXB_MSSP : [0,1,2,4,7,10,15,21,24,27]
let s:hotkeyArg=':if exists("w:txbi")\|call TxbKey("null")\|else\|if !TxbInit(exists("TXB")? TXB : "")\|let TXB=t:txb\|en\|en<cr>'
exe 'nn <silent>' g:TXB_HOTKEY s:hotkeyArg
au VimEnter * if maparg('<f10>')==?s:hotkeyArg | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' g:TXB_HOTKEY s:hotkeyArg

if !has('gui_running')
	au VimResized * if exists('w:txbi') | call s:redraw() | call s:nav(eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')/2-&columns/4,line('w0')-winheight(0)/4+winline()/2) | en
	nn <silent> <leftmouse> :exe get(txbMsInit,&ttymouse,g:txbMsInit.default)()<cr>
else
	nn <silent> <leftmouse> :exe <SID>initDragDefault()<cr>
en
let s:badSync=v:version<704 || v:version==704 && !has('patch131')

fun! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

let txbMsInit={}
let txbCmd={}

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
	\ (v:version<=703? "\n# Warning: Vim < 7.4 - Vim 7.4 is recommended.": '')
	\.(v:version<703 || v:version==703 && !has('patch106')? "\n# Warning: Vim < 7.3.106 - Splits won't sync until mouse release": '')
	\.(v:version<703 || v:version==703 && !has('patch30')?  "\n# Warning: Vim < 7.3.30 - Plane can't be saved to viminfo; write settings to file with (hotkey) W."
	\: empty(&vi) || stridx(&vi,'!')==-1? "\n# Warning: Viminfo not set - Plane will not be remembered between sessions because 'viminfo' doe not contain '!'. Try ':set viminfo+=!' or write to file with (hotkey) W." : '')
	\.(len(split(laggyAu,"\n"))>4? "\n# Warning: Autocommands - Mouse panning may lag due to BufEnter, BufLeave, WinEnter, and WinLeave autocommands. Slim down autocommands (':au Bufenter' to list) or use 'BufRead' or 'BufHidden'?" : '')
	\.(has('gui_running')? "\n# Warning: gVim - Auto-redrawing on resize disabled (resizing occurs too frequently in gVim): use (hotkey) r or ':call TxbKey('r')'" : '')
	\.(&ttymouse==?'xterm'? "\n# Warning: ttymouse - Mouse panning disabled for 'xterm'. Try ':set ttymouse=xterm2' or 'sgr'." : '')
	\.(ttymouseWorks && &ttymouse!=?'xterm2' && &ttymouse!=?'sgr'? "\n# Suggestion: 'set ttymouse=xterm2' or 'sgr' allows mouse panning in map mode." : '')
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	let s:help_bookmark=s:pager(s:formatPar(" \n\n\\R\nv1.8.4 \n\n\n\n\n\n\n\n\n\\C\nWelcome to microViche!\n\n\n\n\n    Current hotkey: ".g:TXB_HOTKEY
	\.(empty(WarningsAndSuggestions)? "\n    Warnings & Suggestions: (none)\n" : "\n    Warnings & Suggestions:".WarningsAndSuggestions."\n")
	\."\nPress (hotkey) to load or initialize a plane. Once loaded, use the mouse to pan or press (hotkey) followed by:
	\\n    h j k l y u b n      pan (takes count, eg, 3jjj=3j3j3j)
	\\n    r                    redraw
	\\n    o                    open map
	\\n    M                    Map all
	\\n    L                    Label (insert [marker][lnum])
	\\n    D A                  Delete / Append split
	\\n    <f1>                 Help
	\\n *  S                    Settings
	\\n    W                    Write to file
	\\n    q <esc>              quit
	\\n----------
	\\n *  Settings can also be accessed with :call TxbKey('S'), such as when the hotkey is inaccessible.
	\\n\n    Labels\n
	\\nLabels are lines that start with a label marker (default 'txb:') and specify a line number, label text, or both. In addition to updating the map, remapping (with (hotkey) o, r, or M) will move any displaced labels to the provided line number by inserting or removing preceding blank lines. Any relocation failures will be displayed in the map.
	\\n\nSyntax: marker(lnum)(:)( label#highlght#ignored)
	\\n    txb:345 bla bla        Just move to 345
	\\n *  txb:345: Intro#Search  Move to 345, label 'Intro', color 'Search'
	\\n    txb: Intro             Just label 'Intro'
	\\n    txb: Intro##bla bla    Just label 'Intro'
	\\n----------
	\\n *  Note the ': ' separator when both lnum and label are given
	\\n\n    Map Commands\n
	\\nTo remap the visbile region and view the map, press (hotkey) o
	\\n    h j k l y u b n      Move (takes count)
	\\n    H J K L Y U B N      Pan (takes count)
	\\n    c                    center cursor
	\\n    g <cr>               go
	\\n    z                    zoom
	\\n    q                    quit"
	\.(ttymouseWorks? "\n *  doubleclick          go
	\\n    drag                 pan
	\\n    click NW corner      quit
	\\n    drag to NW corner    (in the plane) show map
	\\n----------\n *  The mouse only works when ttymouse is set to xterm, xterm2 or sgr. The 'hotcorner' is disabled for xterm.\n\n\n\n\n\n\n\n\n\n"
	\:"\n    (Mouse in map mode is unsupported in gVim and Windows)\n\n\n\n\n\n\n\n\n\n")."4/29/2014\n\n",width,repeat(' ',(&columns-width)/2)),s:help_bookmark)
endfun
fun! s:pager(list,start)
	if len(a:list)<&lines
		ec join(a:list,"\n")
		return 0
	en
	let pad=repeat(' ',46)
	let settings=[&more,&ch]
	let [&more,&ch]=[0,&lines]
	let [pos,bot,continue]=[-1,len(a:list)-&lines,1]
	let next=a:start<0? 0 : a:start>bot? bot : a:start
	while continue
		if pos!=next
			let pos=next
			redr!|echo join(a:list[pos : pos+&lines-2],"\n")."\nSPACE/d/j:down b/u/k:up g/G:top/bottom q:quit"
		en
		exe get(s:pgCase,getchar(),'')
	endwhile
	redr
	let [&more,&ch]=settings
	return pos
endfun
let s:pgCase={113:'let continue=0',
\32:"for i in range(bot>pos? bot-pos : 0)\n
		\exe s:pgCase.106\n
	\endfor",
\106:"if pos<bot\n
		\let pos+=1\n
		\let next+=1\n
		\echon '\r' a:list[pos+&lines-2] strpart(pad,0,46-strdisplaywidth(a:list[pos+&lines-2])) '\nSPACE/d/j:down b/u/k:up g/G:top/bottom q:quit'\n
	\en",
\107:'let next=pos>0? pos-1 : pos',
\98:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\103:'let next=0',
\71:'let next=bot'}
let s:pgCase["\<up>"]   =s:pgCase.107 | let s:pgCase["\<ScrollWheelUp>"]  =s:pgCase.107
let s:pgCase["\<down>"] =s:pgCase.106 | let s:pgCase["\<ScrollWheelDown>"]=s:pgCase.106
let s:pgCase["\<left>"] =s:pgCase.98  | let s:pgCase.117=s:pgCase.98
let s:pgCase["\<right>"]=s:pgCase.32  | let s:pgCase.100=s:pgCase.32
let s:pgCase.27=s:pgCase.113
let txbCmd["\<f1>"]='call s:printHelp()|let mes=""'

fun! TxbInit(seed)
	se noequalalways winwidth=1 winminwidth=0
	if empty(a:seed)
		let plane={'settings':{'working dir':input("# Creating a new plane...\n? Working dir: ",getcwd())}}
		if empty(plane.settings['working dir'])
			return 1
		en
		let plane.settings['working dir']=fnamemodify(plane.settings['working dir'],':p')
		let prevwd=getcwd()
		exe 'cd' fnameescape(plane.settings['working dir'])
		let input=input("\n? Starting files (enter a single file or a filepattern such as '*.txt'; press tab for completion): ",'','file')
		if empty(input)
			exe 'cd' fnameescape(prevwd)
			return 1
		en
		let plane.name=split(glob(input),"\n")
		exe 'cd' fnameescape(prevwd)
	else
		let plane=type(a:seed)==4? deepcopy(a:seed) : type(a:seed)==3? {'name':copy(a:seed)} : {'name':split(glob(a:seed),"\n")}
	en
	let defaults={}
	let prompt=''
    for i in filter(keys(s:optatt),'get(s:optatt[v:val],"required")')
		unlet! arg
		exe get(s:optatt[i],'getDef','let arg=""')
		let defaults[i]=arg
	endfor
	if !exists('plane.settings')                                    
		let plane.settings=defaults
	else
		for i in keys(defaults)
			if !has_key(plane.settings,i)
				let plane.settings[i]=defaults[i]
			else
				unlet! arg
				let arg=plane.settings[i]
				exe get(s:optatt[i],'check','let msg=0')
				if msg isnot 0
					let plane.settings[i]=defaults[i]
					let prompt.="\n# WARNING: invalid setting (default will be used): ".i.": ".msg
				en
			en
		endfor
	en
	let plane.settings['working dir']=fnamemodify(plane.settings['working dir'],':p')
	let plane_save=deepcopy(plane)
	if !exists('plane.size')
		let plane.size=repeat([60],len(plane.name))
	elseif len(plane.size)<len(plane.name)
		call extend(plane.size,repeat([exists("plane.settings['split width']")? plane.settings['split width'] : 60],len(plane.name)-len(plane.size)))
	en
	if !exists('plane.map')
		let plane.map=eval('['.join(repeat(['{}'],len(plane.name)),',').']')
	elseif len(plane.map)<len(plane.name)
		call extend(plane.map,eval('['.join(repeat(['{}'],len(plane.name)-len(plane.map)),',').']'))
	en
	for i in range(len(plane.map))
		if type(plane.map[i])!=4
			let plane.map[i]={}
		en
	endfor
	if !exists('plane.exe')
		let plane.exe=repeat([plane.settings.autoexe],len(plane.name))
	elseif len(plane.exe)<len(plane.name)
		call extend(plane.exe,repeat([plane.settings.autoexe],len(plane.name)-len(plane.exe)))
	en
	if !exists('plane.depth')
		let plane.depth=repeat([0],len(plane.name))
	elseif len(plane.depth)<len(plane.name)
		call extend(plane.depth,repeat([0],len(plane.name)-len(plane.depth)))
	en
	let prevwd=getcwd()
	exe 'cd' fnameescape(plane.settings['working dir'])
	let unreadable=[]
	for i in range(len(plane.name)-1,0,-1)
		if !filereadable(plane.name[i])
			if !isdirectory(plane.name[i])
				call add(unreadable,remove(plane.name,i))
			else
				call remove(plane.name,i)
			en
			call remove(plane.size,i)
			call remove(plane.exe,i)
			call remove(plane.map,i)
		en
	endfor
	let abs_paths=map(copy(plane.name),'fnameescape(fnamemodify(v:val,":p"))')
	exe 'cd' fnameescape(prevwd)
	if empty(plane.name)
		let prompt.="\n# No matches\n? (N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[-1]
	else
		let bufix=index(abs_paths,fnameescape(fnamemodify(expand('%'),':p')))
		if !empty(unreadable)
			let prompt.="\n# Unreadable files will be removed!\n? (R)emove unreadable files and ".(bufix!=-1? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
			let confirmKeys=[82,114]
		else
			let prompt.="\n? (enter) ".(bufix!=-1? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
			let confirmKeys=[10,13]
		en
	en
	echon empty(plane.name)? '' : "\n# ".len(plane.name)." readable\n# ".join(plane.name,', ')
	echon empty(unreadable)? '' : "\n# ".len(unreadable).' unreadable\n# '.join(unreadable,', ')
	echon empty(plane.name)? '' : "\n# Working dir: ".plane.settings['working dir']
	echon prompt
	let c=getchar()
	echon strtrans(type(c)? c : nr2char(c))
	if index(confirmKeys,c)!=-1
		if bufix==-1 | tabe | en
		let t:txb=plane
		let t:txbL=len(t:txb.name)
		let dict=t:txb.settings
		for i in keys(dict)
			exe get(s:optatt[i],'onInit','')
		endfor
		call filter(t:txb,'index(["depth","exe","map","name","settings","size"],v:key)!=-1')
		call filter(t:txb.settings,'has_key(defaults,v:key)')
		let t:paths=abs_paths
		if empty(a:seed)
			echon "\n# Optional preliminary scan"
			exe g:txbCmd.M
		en
		call s:getMapDis()
		call s:redraw()
		return 0
	elseif index([83,115],c)!=-1
		let plane=plane_save
		call s:settingsPager(plane.settings,['Global','hotkey','mouse pan speed','Plane','working dir'],s:optatt)
		return TxbInit(plane)
	elseif index([78,110],c)!=-1
		return TxbInit('')
	elseif c is "\<f1>"
		call s:printHelp()
	en
	return 1
endfun

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! <SID>initDragDefault()
	if exists('w:txbi')
		let cpos=[line('.'),virtcol('.'),w:txbi]
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:setCursor(cpos[0],cpos[1],cpos[2])
			echon getwinvar(v:mouse_win,'txbi') '-' v:mouse_lnum
			return "keepj norm! \<leftmouse>"
		else
			let ecstr=w:txbi.' '.line('.')
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
					exe 'norm! '.bufwinnr(b0)."\<c-w>w"
					let [x,xs]=x && nx? [x,s:nav(x-nx,l0)] : [x? x : nx,0]
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
		call s:setCursor(cpos[0],cpos[1],cpos[2])
		echon w:txbi '-' line('.')
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
let txbMsInit.default=function("\<SNR>".s:SID()."_initDragDefault")

fun! <SID>initDragSGR()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			echon w:txbi '-' line('.')
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
				call TxbKey('o')
			elseif exists('w:txbi')
				echon w:txbi '-' line('.')
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
let txbMsInit.sgr=function("\<SNR>".s:SID()."_initDragSGR")

fun! <SID>initDragXterm()
	return "norm! \<leftmouse>"
endfun
let txbMsInit.xterm=function("\<SNR>".s:SID()."_initDragXterm")

fun! <SID>initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			echon w:txbi '-' line('.')
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
				call TxbKey('o')
			elseif exists('w:txbi')
				echon w:txbi '-' line('.')
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
let txbMsInit.xterm2=function("\<SNR>".s:SID()."_initDragXterm2")

fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? get(g:TXB_MSSP,a:dy,g:TXB_MSSP[-1])."\<c-y>" : a:dy<0? get(g:TXB_MSSP,-a:dy,g:TXB_MSSP[-1])."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -get(g:TXB_MSSP,a:dx,g:TXB_MSSP[-1]) : get(g:TXB_MSSP,-a:dx,g:TXB_MSSP[-1]),a:dy<0? line('w0')+get(g:TXB_MSSP,-a:dy,g:TXB_MSSP[-1]) : line('w0')-get(g:TXB_MSSP,a:dy,g:TXB_MSSP[-1]))
	echon w:txbi '-' line('.')
endfun

fun! s:formatPar(str,w,pad)
	let spaces=repeat(" ",a:w+10)
	let trspace=repeat(' ',len(&brk))
	let ret=[]
	let format=''
	for par in split(a:str,"\n")
		if par=~'\\\u'
			let format=par
		else
			let seg=[0]
			while seg[-1]<len(par)-a:w
				let ix=(a:w+strridx(tr(strpart(par,seg[-1],a:w),&brk,trspace),' '))%a:w
				call add(seg,seg[-1]+ix-(par[seg[-1]+ix]=~'\s'))
				let ix=seg[-2]+ix+1
				while par[ix]==" "
					let ix+=1
				endwhile
				call add(seg,ix)
			endw
			call add(seg,len(par)-1)
			let ret+=map(range(len(seg)/2),format==#'\C'? 'a:pad.spaces[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].par[seg[2*v:val]:seg[2*v:val+1]]' : format==#'\R'? 'a:pad.spaces[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)].par[seg[2*v:val]:seg[2*v:val+1]]' : 'a:pad.par[seg[2*v:val]:seg[2*v:val+1]]')
			let format=''
		en
	endfor
	return ret
endfun

"loadk()    ret REQUIRED Get setting and load into ret
"apply(arg) msg REQUIRED When setting is changed, apply; optionally return str msg
"doc            (str) What the setting does
"getDef()   arg Load default value into arg
"check(arg) msg Normalize arg (eg convert from str to num) return msg (str if error, else num 0)
"getInput() arg Overwrite default (let arg=input('New value:')) [c]hange behavior
"required       (bool) t:txb.setting[key] will always be initialized (via getDef, '' if undefined)
"onInit()       Exe when loading plane
let s:optatt={
	\'autoexe': {'doc': 'Command when splits are revealed (for new splits, (c)hange for prompt to apply to current splits)',
		\'loadk': 'let ret=dict.autoexe',
		\'getDef': "let arg='se nowrap scb cole=2'",
		\'required': 1,
		\'apply': "if 'y'==?input('Apply new default autoexe to current splits? (y/n)')\n
				\let t:txb.exe=repeat([arg],t:txbL)\n
				\let msg='(Autoexe applied to current splits)'\n
			\else\n
				\let msg='(Only appended splits will inherit new autoexe)'\n
			\en\n
			\let dict.autoexe=arg"},
	\'current autoexe': {'doc': 'Command when current split is revealed',
		\'loadk': 'let ret=t:txb.exe[w:txbi]',
		\'apply': 'let t:txb.exe[w:txbi]=arg|call s:redraw()'},
	\'current file': {'doc': 'File associated with this split',
		\'loadk': 'let ret=t:txb.name[w:txbi]',
		\'getInput':"let prevwd=getcwd()\n
			\exe 'cd' fnameescape(t:wdir)\n
			\let arg=input('(Use full path if not in working dir '.t:wdir.')\nEnter file (do not escape spaces): ',type(disp[key])==1? disp[key] : string(disp[key]),'file')\n
			\exe 'cd' fnameescape(prevwd)",
		\'apply': "if !empty(arg)\n
				\let prevwd=getcwd()\n
				\exe 'cd' fnameescape(t:wdir)\n
				\let t:paths[w:txbi]=fnameescape(fnamemodify(arg,':p'))\n
				\let t:txb.name[w:txbi]=arg\n
				\exe 'cd' fnameescape(prevwd)\n
				\let curview=winsaveview()\n
				\call s:redraw()\n
				\call winrestview(curview)\n
			\en"},
	\'current width': {'doc': 'Width of current split',
		\'loadk': 'let ret=t:txb.size[w:txbi]',
		\'check': 'let arg=str2nr(arg)|let msg=arg>2? 0 : ''Split width must be > 2''',
		\'apply': 'let t:txb.size[w:txbi]=arg|call s:redraw()'},
	\'hotkey': {'doc': "Global hotkey. Examples: '<f10>', '<c-v>' (ctrl-v), 'vx' (v then x). WARNING: If the hotkey becomes inaccessible, :call TxbKey('S')",
		\'loadk': 'let ret=g:TXB_HOTKEY',
		\'getDef': 'let arg=''<f10>''',
		\'required': 1,
		\'apply': "if maparg(g:TXB_HOTKEY)==?s:hotkeyArg\n
				\exe 'silent! nunmap' g:TXB_HOTKEY\n
			\elseif maparg('<f10>')==?s:hotkeyArg\n
				\silent! nunmap <f10>\n
			\en\n
			\let g:TXB_HOTKEY=arg\n
			\exe 'nn <silent>' g:TXB_HOTKEY s:hotkeyArg"},
	\'mouse pan speed': {'doc': 'Pan speed[N] steps for every N mouse steps (only applies in terminal and ttymouse=xterm2 or sgr)',
		\'loadk': 'let ret=g:TXB_MSSP',
		\'getDef': 'let arg=[0,1,2,4,7,10,15,21,24,27]',
		\'check': "try\n
				\if type(arg)==1\n
					\let temp=eval(arg)\n
					\unlet! arg\n
					\let arg=temp\n
				\en\n
				\let msg=type(arg)!=3? 'Must evaluate to list' : arg[0]? 'First element must be 0' : 0\n
			\catch\n
				\let msg='String evaluation error'\n
			\endtry",
		\'apply': 'let g:TXB_MSSP=arg'},
	\'label marker': {'doc': 'Regex for map marker, default ''txb:''. Labels are found via search(''^''.labelmark)',
		\'loadk': 'let ret=dict[''label marker'']',
		\'getDef': 'let arg=''txb:''',
		\'required': 1,
		\'onInit': 'let t:lblmrk=dict["label marker"]',
		\'apply': 'let dict[''label marker'']=arg|let t:lblmrk=arg'},
	\'lines per map grid': {'doc': 'Lines mapped by each map line',
		\'loadk': 'let ret=dict[''lines per map grid'']',
		\'getDef': 'let arg=45',
		\'check': 'let arg=str2nr(arg)|let msg=arg>0? 0 : ''Lines per map grid must be > 0''',
		\'required': 1,
		\'cc': 't:gran',
		\'onInit': 'let t:gran=dict["lines per map grid"]',
		\'apply': 'let dict[''lines per map grid'']=arg|let t:gra=arg|call s:getMapDis()'},
	\'map cell width': {'doc': 'Display width of map column',
		\'loadk': 'let ret=dict[''map cell width'']',
		\'getDef': 'let arg=5',
		\'check': 'let arg=str2nr(arg)|let msg=arg>2? 0 : ''Map cell width must be > 2''',
		\'required': 1,
		\'cc': 't:mapw',
		\'onInit': 'let t:mapw=dict["map cell width"]',
		\'apply': 'let dict[''map cell width'']=arg|let t:mapw=arg|call s:getMapDis()'},
	\'split width': {'doc': 'Default split width (for appended splits, (c)hange for prompt to resize current splits)',
		\'loadk': 'let ret=dict[''split width'']',
		\'getDef': 'let arg=60',
		\'check': "let arg=str2nr(arg)|let msg=arg>2? 0 : 'Default split width must be > 2'",
		\'required': 1,
		\'apply': "if 'y'==?input('Apply new default width to current splits? (y/n)')\n
				\let t:txb.size=repeat([arg],t:txbL)\n
				\let msg='(All splits resized)'\n
			\else\n
				\let msg='(Only newly appended splits will inherit new width)'\n
			\en\n
			\let dict['split width']=arg"},
	\'writefile': {'doc': 'Default settings save file',
		\'loadk': 'let ret=dict[''writefile'']',
		\'check': 'let msg=type(arg)==1? 0 : "Writefile must be string"',
		\'required': 1,
		\'apply':'let dict[''writefile'']=arg'},
	\'working dir': {'doc': 'Directory assumed when loading splits with relative paths',
		\'loadk': 'let ret=dict["working dir"]',
		\'getDef': 'let arg=fnamemodify(getcwd(),":p")',
		\'check': "let [msg, arg]=isdirectory(arg)? [0,fnamemodify(arg,':p')] : ['Not a valid directory',arg]",
		\'onInit': 'let t:wdir=dict["working dir"]',
		\'required': 1,
		\'getInput': "let arg=input('Working dir (do not escape spaces; must be absolute path; press tab for completion): ',type(disp[key])==1? disp[key] : string(disp[key]),'file')",
		\'apply': "let msg='(Working dir not changed)'\n
			\if 'y'==?input('Are you sure you want to change the working directory? (Step 1/3) (y/n)')\n
				\let confirm=input('Step 2/3 (Recommended): Would you like to convert current files to absolute paths so that their locations remain unaffected? (y/n/cancel)')\n
				\if confirm==?'y' || confirm==?'n'\n
					\let confirm2=input('Step 3/3: Would you like to write a copy of the current plane to file, just in case? (y/n/cancel)')\n
					\if confirm2==?'y' || confirm2==?'n'\n
						\let curwd=getcwd()\n
						\if confirm2=='y'\n
							\exe g:txbCmd.W\n
						\en\n
						\if confirm=='y'\n
							\exe 'cd' fnameescape(t:wdir)\n
							\call map(t:txb.name,'fnamemodify(v:val,'':p'')')\n
						\en\n
						\let dict['working dir']=arg\n
						\let t:wdir=arg\n
						\exe 'cd' fnameescape(t:wdir)\n
						\let t:paths=map(copy(t:txb.name),'fnameescape(fnamemodify(v:val,'':p''))')\n
						\exe 'cd' fnameescape(curwd)\n
						\let msg='(Working dir changed)'\n
					\en\n
				\en\n
			\en"}}

let [s:spCursor,s:spOff]=[0,0]
fun! s:settingsPager(dict,entry,attr)
	let dict=a:dict
	let entries=len(a:entry)
	let [chsav,&ch]=[&ch,entries+3>11? 11 : entries+3]
	let s:spCursor=s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
	let s:spOff=s:spOff<0? 0 : s:spOff>entries-&ch? (entries-&ch>=0? entries-&ch : 0) : s:spOff
	let s:spOff=s:spOff<s:spCursor-&ch? s:spCursor-&ch : s:spOff>s:spCursor? s:spCursor : s:spOff
	let undo={}
	let disp={}
	for key in filter(copy(a:entry),'has_key(a:attr,v:val)')
		unlet! ret
		exe a:attr[key].loadk
		let disp[key]=ret
	endfor
	let [helpw,contentw]=&columns>120? [60,60] : [&columns/2,&columns/2-1]
	let pad=repeat(' ',contentw)
	let msg=0
	let continue=1
	let settingshelp='jkgG:dn,up,top,bot (c)hange (U)ndo (D)efault (q)uit'
	let errlines=[]
	let doclines=s:formatPar(settingshelp,helpw,'')
	while continue
		redr!
		for [scrPos,i,key] in map(range(&ch),'[v:val,v:val+s:spOff,get(a:entry,v:val+s:spOff,"")]')
			let line=has_key(disp,key)? ' '.key.' : '.(type(disp[key])==1? disp[key] : string(disp[key])) : key
			if i==s:spCursor
				echohl Visual
			elseif !has_key(a:attr,key)
				echohl Title
			en
			if scrPos
				echon "\n"
			en
			if scrPos<len(doclines)
				if len(line)>=contentw
					echon line[:contentw-1]
				else
					echon line
					echohl
					echon pad[:contentw-len(line)-1]
				en
				if scrPos<len(errlines)
					echohl WarningMsg
				else
					echohl MoreMsg
				en
				echon get(doclines,scrPos,'')
			else
				echon line[:&columns-2]
			en
			echohl
		endfor
		let key=a:entry[s:spCursor]
		let validkey=1
		exe get(s:spExe,getchar(),'let validkey=0')
		let s:spCursor=s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
		let s:spOff=s:spOff<s:spCursor-&ch+1? s:spCursor-&ch+1 : s:spOff>s:spCursor? s:spCursor : s:spOff
		let errlines=msg is 0? [] : s:formatPar(msg,helpw,'')
		let doclines=errlines+s:formatPar(validkey? get(get(a:attr,a:entry[s:spCursor],{}),'doc',settingshelp) : settingshelp,helpw,'')
	endwhile
	let &ch=chsav
	redr
	echo
endfun
let s:ApplySettingsCmd="if empty(arg)\n
			\let msg='Input cannot be empty'\n
		\else\n
			\exe get(a:attr[key],'check','let msg=0')\n
		\en\n
		\if (msg is 0) && (arg!=#disp[key])\n
			\let undo[key]=get(undo,key,disp[key])\n
			\exe a:attr[key].apply\n
			\let disp[key]=arg\n
		\en\n
	\en"
let s:spExe={68: "if !has_key(disp,key) || !has_key(a:attr[key],'getDef')\n
			\let msg='No default defined for this value'\n
		\else\n
			\unlet! arg\n
			\exe a:attr[key].getDef\n".s:ApplySettingsCmd,
	\85: "if !has_key(disp,key) || !has_key(undo,key)\n
			\let msg='No undo defined for this value'\n
		\else\n
			\unlet! arg\n
			\let arg=undo[key]\n".s:ApplySettingsCmd,
	\99: "if has_key(disp,key)\n
			\unlet! arg\n
			\exe get(a:attr[key],'getInput','let arg=input(''Enter new value: '',type(disp[key])==1? disp[key] : string(disp[key]))')\n".s:ApplySettingsCmd,
	\113: "let continue=0",
	\27:  "let continue=0",
	\106: 'let s:spCursor+=1',
	\107: 'let s:spCursor-=1',
	\103: 'let s:spCursor=0',
	\71:  'let s:spCursor=entries-1'}
let s:spExe.13=s:spExe.99
let s:spExe.10=s:spExe.99
unlet s:ApplySettingsCmd
let txbCmd.S="let mes=''\n
	\if exists('w:txbi')\n
		\call s:settingsPager(t:txb.settings,['Global','hotkey','mouse pan speed','Plane','split width','autoexe','lines per map grid','map cell width','working dir','label marker','Split '.w:txbi,'current width','current autoexe','current file'],s:optatt)\n
	\else\n
		\call s:settingsPager({},['Global','hotkey','mouse pan speed'],s:optatt)\n
	\en"

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
"msStat   1        2        3       4       5      else 0
fun! <SID>getmouse()
	if &ttymouse=~?'xterm'
		let s:msStat=[getchar(0)*0+getchar(0),getchar(0)-32,getchar(0)-32]
		let s:msStat[0]=s:msStat[0]==64? 2 : s:msStat[0]==32? 1 : s:msStat[0]==35? 3 : s:msStat[0]==96? 4 : s:msStat[0]==97? 5 : 0
	elseif &ttymouse==?'sgr'
		let s:msStat=split(join(map([getchar(0)*0+getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';')
		let s:msStat=len(s:msStat)> 2? [str2nr(s:msStat[0]).s:msStat[2][len(s:msStat[2])-1],str2nr(s:msStat[1]),str2nr(s:msStat[2])] : [0,0,0]
		let s:msStat[0]=s:msStat[0]==#'32M'? 2 : s:msStat[0]==#'0M'? 1 : (s:msStat[0]==#'0m' || s:msStat[0]==#'32K') ? 3 : s:msStat[0][:1]==#'64'? 4 : s:msStat[0][:1]==#'65'? 5 : 0
	else
		let s:msStat=[0,0,0]
	en
	while getchar(0) isnot 0
	endwhile
	call g:TxbKeyHandler(-1)
endfun
fun! s:dochar()
	let [k,c]=['',getchar()]
	while c isnot 0
		let k.=type(c)==0? nr2char(c) : c
		let c=getchar(0)
	endwhile
	call g:TxbKeyHandler(k)
endfun

let s:count='03'
fun! TxbKey(cmd)
	let g:TxbKeyHandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:cmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:txbCmd,a:c,'let mes="(0..9) count (f1) help (hjklyubn) move (r)edraw (M)ap all (o)pen map (A)ppend (D)elete (L)abel (S)ettings (W)rite settings (q)uit"')
	if mes==' '
		echon '? ' w:txbi '.' line('.') ' ' str2nr(s:count) ' ' strtrans(a:c)
		call feedkeys("\<plug>TxbZ")
	elseif !empty(mes)
		redr|echon '# ' mes
	en
endfun
let txbCmd.q="let mes='  '"
let txbCmd[-1]="let mes=''"
let txbCmd["\e"]=txbCmd.q
let txbCmd.null='let mes=" "'

let txbCmd.h="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0'))|redrawstatus!"
let txbCmd.j="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(0,line('w0')+s:count)|redrawstatus!"
let txbCmd.k="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(0,line('w0')-s:count)|redrawstatus!"
let txbCmd.l="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0'))|redrawstatus!"
let txbCmd.y="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0')-s:count)|redrawstatus!"
let txbCmd.u="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0')-s:count)|redrawstatus!"
let txbCmd.b="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0')+s:count)|redrawstatus!"
let txbCmd.n="let mes=' '|let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0')+s:count)|redrawstatus!"
let txbCmd.1="let mes=' '|let s:count=s:count[0] is '0'? '1' : s:count.'1'"
let txbCmd.2="let mes=' '|let s:count=s:count[0] is '0'? '2' : s:count.'2'"
let txbCmd.3="let mes=' '|let s:count=s:count[0] is '0'? '3' : s:count.'3'"
let txbCmd.4="let mes=' '|let s:count=s:count[0] is '0'? '4' : s:count.'4'"
let txbCmd.5="let mes=' '|let s:count=s:count[0] is '0'? '5' : s:count.'5'"
let txbCmd.6="let mes=' '|let s:count=s:count[0] is '0'? '6' : s:count.'6'"
let txbCmd.7="let mes=' '|let s:count=s:count[0] is '0'? '7' : s:count.'7'"
let txbCmd.8="let mes=' '|let s:count=s:count[0] is '0'? '8' : s:count.'8'"
let txbCmd.9="let mes=' '|let s:count=s:count[0] is '0'? '9' : s:count.'9'"
let txbCmd.0="let mes=' '|let s:count=s:count[0] is '0'? '01': s:count.'0'"
let txbCmd["\<up>"]   =txbCmd.k
let txbCmd["\<down>"] =txbCmd.j
let txbCmd["\<left>"] =txbCmd.h
let txbCmd["\<right>"]=txbCmd.l

let txbCmd.L="let L=getline('.')\n
	\let mes='Labeled'\n
	\if -1!=match(L,'^'.t:lblmrk)\n
		\call setline(line('.'),substitute(L,'^'.t:lblmrk.'\\zs\\d*\\ze',line('.'),''))\n
	\else\n
		\let prefix=t:lblmrk.line('.').' '\n
		\call setline(line('.'),prefix.L)\n
		\call cursor(line('.'),len(prefix))\n
		\startinsert\n
	\en"

let txbCmd.D="redr\n
	\if t:txbL==1\n
		\let mes='Cannot delete last split!'\n
	\elseif input('Really delete current column (y/n)? ')==?'y'\n
		\let t_index=index(t:paths,fnameescape(fnamemodify(expand('%'),':p')))\n
		\if t_index!=-1\n
			\call remove(t:txb.name,t_index)\n
			\call remove(t:paths,t_index)\n
			\call remove(t:txb.size,t_index)\n
			\call remove(t:txb.exe,t_index)\n
			\call remove(t:txb.map,t_index)\n
			\call remove(t:gridLbl,t_index)\n
			\call remove(t:txb.depth,t_index)\n
			\call remove(t:oldDepth,t_index)\n
			\call remove(t:gridClr,t_index)\n
			\call remove(t:gridPos,t_index)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:getMapDis()\n
		\en\n
		\winc W\n
		\let cpos=[line('.'),virtcol('.'),w:txbi]\n
		\call s:redraw()\n
		\let mes='Split deleted'\n
	\en\n
	\call s:setCursor(cpos[0],cpos[1],cpos[2])"

let txbCmd.A="let t_index=index(t:paths,fnameescape(fnamemodify(expand('%'),':p')))\n
	\let cpos=[line('.'),virtcol('.'),w:txbi]\n
	\if t_index!=-1\n
		\let prevwd=getcwd()\n
		\exe 'cd' fnameescape(t:wdir)\n
		\let file=input('(Use full path if not in working directory '.t:wdir.')\nAppend file (do not escape spaces) : ',t:txb.name[w:txbi],'file')\n
		\if (fnamemodify(expand('%'),':p')==#fnamemodify(file,':p') || t:paths[(w:txbi+1)%t:txbL]==#fnameescape(fnamemodify(file,':p'))) && 'y'!=?input('\nWARNING\n    An unpatched bug in Vim causes errors when panning modified ADJACENT DUPLICATE SPLITS. Continue with append? (y/n)')\n
			\let mes='File not appended'\n
		\elseif empty(file)\n
			\let mes='File name is empty'\n
		\else\n
			\let mes='[' . file . (index(t:txb.name,file)==-1? '] appended.' : '] (duplicate) appended.')\n
			\call insert(t:txb.name,file,w:txbi+1)\n
			\call insert(t:paths,fnameescape(fnamemodify(file,':p')),w:txbi+1)\n
			\call insert(t:txb.size,t:txb.settings['split width'],w:txbi+1)\n
			\call insert(t:txb.exe,t:txb.settings.autoexe,w:txbi+1)\n
			\call insert(t:txb.map,{},w:txbi+1)\n
			\call insert(t:txb.depth,100,w:txbi+1)\n
			\call insert(t:oldDepth,100,w:txbi+1)\n
			\call insert(t:gridLbl,{},w:txbi+1)\n
			\call insert(t:gridClr,{},w:txbi+1)\n
			\call insert(t:gridPos,{},w:txbi+1)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:redraw(1)\n
			\call s:getMapDis()\n
		\en\n
		\exe 'cd' fnameescape(prevwd)\n
	\else\n
		\let mes='Current file not in plane! (hotkey) (r)edraw before appending.'\n
	\en\n
	\call s:setCursor(cpos[0],cpos[1],cpos[2])"

let txbCmd.W="let prevwd=getcwd()\n
	\exe 'cd' fnameescape(t:wdir)\n
	\let input=input('? Write plane to file (relative to '.t:wdir.'): ',t:txb.settings.writefile,'file')\n
	\let [t:txb.settings.writefile,mes]=empty(input)? [t:txb.settings.writefile,'File write aborted'] : [input,writefile(['let TXB='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TxbInit(TXB)'],input)? 'Error: File not writable' : 'File written, '':source '.input.''' to restore']\n
	\exe 'cd' fnameescape(prevwd)"

fun! s:setCursor(l,vc,ix)
	let wt=getwinvar(1,'txbi')
	let wb=wt+winnr('$')-1
	if a:ix<wt
		winc t
		exe "norm! ".(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').'g0'
	elseif a:ix>wb
		winc b
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(wb==wt? 'g$' : '0g$')
	elseif a:ix==wt
		winc t
		let offset=virtcol('.')-wincol()+1
		let width=offset+winwidth(0)-3
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(a:vc<offset? offset : width<=a:vc? width : a:vc).'|'
	else
		exe (a:ix-wt+1).'winc w'
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(a:vc>winwidth(0)? '0g$' : '0'.a:vc.'|')
	en
endfun

fun! s:goto(sp,ln,...)
	let sp=(a:sp%t:txbL+t:txbL)%t:txbL
	let dln=a:ln>0? a:ln : 1
	let dsp=sp
	let doff=a:0? a:1 : t:txb.size[sp]>&columns? 0 : -(&columns-t:txb.size[sp])/2
	while doff<0
		let dsp=dsp>0? dsp-1 : t:txbL-1
		let doff+=t:txb.size[dsp-1]+1
	endwhile
	while doff>t:txb.size[dsp]
		let doff-=t:txb.size[dsp]+1
		let dsp=dsp>=t:txbL-1? 0 : dsp+1
	endwhile
	exe t:paths[dsp]!=#fnameescape(fnamemodify(expand('%'),':p'))? 'only|e'.t:paths[dsp] : 'only'
	let w:txbi=dsp
	if a:0
		exe 'norm! '.(dln? dln : 1).(doff>0? 'zt0'.doff.'zl' : 'zt0')
		call s:redraw()
	else
		exe 'norm! 0'.(doff>0? doff.'zl' : '')
		call s:redraw()
		exe ((sp-getwinvar(1,'txbi')+1+t:txbL)%t:txbL).'wincmd w'
		let l0=dln-winheight(0)/2
		let dif=line('w0')-(l0>1? l0 : 1)
		exe dif>0? 'norm! '.dif."\<c-y>".dln.'G' : dif<0? 'norm! '.-dif."\<c-e>".dln.'G' : dln
	en
endfun

fun! s:redraw(...)
	let name0=fnameescape(fnamemodify(expand('%'),':p'))
	if !exists('w:txbi')
		let ix=index(t:paths,name0)
		if ix==-1
			only
			exe 'e' t:paths[0]
			let w:txbi=0
		else
			let w:txbi=ix
		en
	elseif t:paths[w:txbi]!=#name0
		exe 'e' t:paths[w:txbi]
	en
	let win0=winnr()
	let pos=[bufnr('%'),line('w0'),line('.'), virtcol('.')]
	if winnr('$')>1
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
			let colt=colt? colt-1 : t:txbL-1
			let remain-=t:txb.size[colt]+1
			let colsLeft+=1
		endwhile
		let colb=w:txbi
		let remain=&columns-(split0>0? split0+1+t:txb.size[w:txbi] : min([winwidth(1),t:txb.size[w:txbi]]) )
		let colsRight=1
		while remain>=2
			let colb=(colb+1)%t:txbL
			let colsRight+=1
			let remain-=t:txb.size[colb]+1
		endwhile
		let colbw=t:txb.size[colb]+remain
	else
		let colt=w:txbi
		let colsLeft=0
		let colb=w:txbi
		let offset=&wrap? 0 : virtcol('.')-wincol()
		let remain=&columns-max([2,t:txb.size[w:txbi]-offset])
		let colsRight=1
		while remain>=2
			let colb=(colb+1)%t:txbL
			let colsRight+=1
			let remain-=t:txb.size[colb]+1
		endwhile
		let colbw=t:txb.size[colb]+remain
	en
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(w:txbi-win0+t:txbL)%t:txbL
		for i in range(dif)
			let colt=colt? colt-1 : t:txbL-1
			exe 'top vsp' t:paths[colt]
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
		let nextcol=((colb-dif)%t:txbL+t:txbL)%t:txbL
		for i in range(dif)
			let nextcol=(nextcol+1)%t:txbL
			exe (t:txbL==1? 'bot vsp' : 'bot vsp '.t:paths[nextcol])
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
	let changedsplits={}
	for i in range(1,numcols)
		se wfw
		if fnameescape(fnamemodify(bufname(''),':p'))!=#t:paths[ccol]
			exe 'e' t:paths[ccol]
		en
		let w:txbi=ccol
		exe t:txb.exe[ccol]
		if a:0
			let changedsplits[ccol]=1
			let t:txb.depth[ccol]=line('$')
			let t:txb.map[ccol]={}
			norm! 1G0
			let line=search('^'.t:lblmrk.'\zs','Wc')
			while line
				let L=getline('.')
				let lnum=strpart(L,col('.')-1,6)
				if lnum!=0
					let lbl=lnum[len(lnum+0)]==':'? split(L[col('.')+len(lnum+0)+1:],'#',1) : []
					if lnum<line
						if prevnonblank(line-1)>=lnum
							let lbl=["! Error ".get(lbl,0,''),'ErrorMsg']
						else
							exe 'norm! kd'.(line-lnum==1? 'd' : (line-lnum-1).'k')
						en
					elseif lnum>line
						exe 'norm! '.(lnum-line)."O\ej"
					en
					let line=line('.')
				else
					let lbl=split(L[col('.'):],'#',1)
				en
				if !empty(lbl) && !empty(lbl[0])
					let t:txb.map[ccol][line]=[lbl[0],get(lbl,1,'')]
				en
				let line=search('^'.t:lblmrk.'\zs','W')
			endwhile
		en
		if i==numcols
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		elseif i==1
			let dif=colbw-winwidth(0)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
			norm! 0
		else
			let dif=t:txb.size[ccol]-winwidth(0)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
			norm! 0
		en
		if s:badSync
			1
		en
		winc h
		let ccol=ccol? ccol-1 : t:txbL-1
	endfor
	if !empty(changedsplits)
		call s:getMapDis(keys(changedsplits))
	en
	se scrollopt=ver,jump
	silent exe "norm! :syncbind\<cr>"
	exe bufwinnr(pos[0]).'winc w'
	let offset=virtcol('.')-wincol()
	exe 'norm!' pos[1].'zt'.pos[2].'G'.(pos[3]<=offset? offset+1 : pos[3]>offset+winwidth(0)? offset+winwidth(0) : pos[3])
endfun
let txbCmd.r="call s:redraw(1)|redr|let mes='Redraw complete'"

fun! s:nav(N,L)
	let cBf=bufnr('')
	let cVc=virtcol('.')
	let cL0=line('w0')
	let cL=line('.')
	let alignmentcmd='norm! '.cL0.'zt'
	let dosyncbind=0
	let extrashift=0
	if a:N<0
		let N=-a:N
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
				let nextcol=w:txbi? w:txbi-1 : t:txbL-1
				exe 'top '.(winwidth(0)-t:txb.size[w:txbi]-1).'vsp '.t:paths[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let dosyncbind=1
					else
						exe alignmentcmd
					en
				en
				winc l
				se wfw
				norm! 0
				winc t
				se wfw scrollopt=ver,jump
			endwhile
			let offset=t:txb.size[w:txbi]-winwidth(0)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				winc b
				norm! 0g$
			elseif cWn!=1
				exe cWn.'winc w'
				exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
			en
		else
			let tcol=w:txbi
			let loff=&wrap? -N-extrashift : virtcol('.')-wincol()-N-extrashift
			if loff>=0
				exe 'norm! '.(N+extrashift).(bufwinnr(cBf)==-1? 'zhg$' : 'zh')
			else
				let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
				while loff<=-2
					let tcol=tcol? tcol-1 : t:txbL-1
					let loff+=t:txb.size[tcol]+1
				endwhile
				se scrollopt=jump
				exe 'e' t:paths[tcol]
				let w:txbi=tcol
				exe t:txb.exe[tcol]
				if &scb
					if line('$')<cL0
						let dosyncbind=1
					else
						exe alignmentcmd
					en
				en
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&columns-1
					let spaceremaining=&columns-t:txb.size[tcol]+loff
					let nextcol=(tcol+1)%t:txbL
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bot '.(spaceremaining-1).'vsp '.t:paths[nextcol]
						let w:txbi=nextcol
						exe t:txb.exe[nextcol]
						if &scb
							if line('$')<cL0
								let dosyncbind=1
							elseif !dosyncbind
								exe alignmentcmd
							en
						en
						norm! 0
						let spaceremaining-=t:txb.size[nextcol]+1
						let nextcol=(nextcol+1)%t:txbL
					endwhile
					se scrollopt=ver,jump
					windo se wfw
				en
				let cWn=bufwinnr(cBf)
				if cWn!=-1
					exe cWn.'winc w'
					exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
				else
					norm! 0g$
				en
			en
		en
		let extrashift=-extrashift
	elseif a:N>0
		let tcol=getwinvar(1,'txbi')
		let loff=winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0)
		let N=a:N
		let botalreadysized=0
		if N>=&columns
			let loff=winwidth(1)==&columns? loff+&columns : winwidth(winnr('$'))
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%t:txbL
			en
			let toshift=N-&columns
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%t:txbL
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%t:txbL
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%t:txbL
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%t:txbL
				let loff=0
			else
				let loff+=toshift
			en
			se scrollopt=jump
			exe 'e' t:paths[tcol]
			let w:txbi=tcol
			exe t:txb.exe[tcol]
			if &scb
				if line('$')<cL0
					let dosyncbind=1
				else
					exe alignmentcmd
				en
			en
			se scrollopt=ver,jump
			only
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			if winwidth(1)==1
				let cWn=winnr()
				winc t
				hide
				let N-=2
				if N<=0
					if cWn!=1
						exe (cWn-1).'winc w'
					else
						1winc w
						norm! 0
					en
					exe cL
					let dif=line('w0')-a:L
					exe dif>0? 'norm! '.dif."\<c-y>" : dif<0? 'norm! '.-dif."\<c-e>" : ''
					return
				en
			en
			let shifted=0
			let w1=winwidth(1)
			while w1<=N-botalreadysized
				let w2=winwidth(2)
				let extrashift=w1==N
				let shifted=w1+1
				winc t
				hide
				if winwidth(1)==w2
					let botalreadysized+=w1+1
				en
				let tcol=(tcol+1)%t:txbL
				let loff=0
				let w1=winwidth(1)
			endw
			let N+=extrashift
			let loff+=N-shifted
		en
		let ww1=winwidth(1)
		if ww1!=&columns
			let N=N-botalreadysized
			if N
				winc b
				exe 'vert res+'.N
				if virtcol('.')!=wincol()
					norm! 0
				en
				winc t
				if winwidth(1)!=ww1-N
					exe 'vert res'.(ww1-N)
				en
			en
			while winwidth(winnr('$'))>=t:txb.size[getwinvar(winnr('$'),'txbi')]+2
				winc b
				se nowfw scrollopt=jump
				let nextcol=(w:txbi+1)%t:txbL
				exe 'rightb '.(winwidth(0)-t:txb.size[w:txbi]-1).'vsp '.t:paths[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let dosyncbind=1
					elseif !dosyncbind
						exe alignmentcmd
					en
				en
				winc h
				se wfw
				winc b
				norm! 0
				se scrollopt=ver,jump
			endwhile
			winc t
			let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
			exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
			else
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		elseif &columns-t:txb.size[tcol]+loff>=2
			let spaceremaining=&columns-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let nextcol=(w:txbi+1)%t:txbL
				exe 'bot '.(spaceremaining-1).'vsp '.t:paths[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let dosyncbind=1
					elseif !dosyncbind
						exe alignmentcmd
					en
				en
				norm! 0
				let spaceremaining-=t:txb.size[nextcol]+1
			endwhile
			se scrollopt=ver,jump
			windo se wfw
			let cWn=bufwinnr(cBf)
			if cWn==-1
				winc t
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				if cVc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.cVc.'|'
				en
			else
				winc t
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		else
			let offset=loff-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				if cVc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.cVc.'|'
				en
			else
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		en
	en
	if dosyncbind
		if s:badSync
			windo 1
		en
		silent exe "norm! :syncbind\<cr>"
	en
	exe cL
	let dif=line('w0')-a:L
	exe dif>0? 'norm! '.dif."\<c-y>" : dif<0? 'norm! '.-dif."\<c-e>" : ''
	return extrashift
endfun

fun! s:getMapDis(...)
	let blankcell=repeat(' ',t:mapw)
	let negcell=repeat('.',t:mapw)
	let redR={}
	if !a:0
		let t:bgd=map(range(0,max(t:txb.depth)+t:gran,t:gran),'join(map(range(t:txbL),v:val.''>t:txb.depth[v:val]? "'.negcell.'" : "'.blankcell.'"''),'''')')
		let t:deepR=len(t:bgd)-1
		let t:disTxt=copy(t:bgd)
		let t:disClr=eval('['.join(repeat(['[""]'],t:deepR+1),',').']')
		let t:disIx=eval('['.join(repeat(['[98989]'],t:deepR+1),',').']')
		let t:gridClr=eval('['.join(repeat(['{}'],t:txbL),',').']')
		let t:gridLbl=deepcopy(t:gridClr)
		let t:gridPos=deepcopy(t:gridClr)
		let t:oldDepth=copy(t:txb.depth)
	en
	for sp in a:0? a:1 : range(t:txbL)
		let newdR=t:txb.depth[sp]/t:gran
		while newdR>len(t:bgd)-1
			call add(t:bgd,repeat('.',t:txbL*t:mapw))
			call add(t:disIx,[98989])
			call add(t:disClr,[''])
			call add(t:disTxt,'')
			let redR[len(t:bgd)-1]=1
		endwhile
		let i=t:oldDepth[sp]/t:gran
		let colIx=sp*t:mapw
		while i<newdR
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].blankcell.t:bgd[i][colIx+t:mapw :] : blankcell.t:bgd[i][colIx+t:mapw :]
			let redR[i]=1
			let i+=1
		endwhile
		while i>newdR
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].negcell.t:bgd[i][colIx+t:mapw :] : negcell.t:bgd[i][colIx+t:mapw :]
			let redR[i]=1
			let i-=1
		endwhile
		let t:oldDepth[sp]=t:txb.depth[sp]
		let conflicts={}
		let splitLbl={}
		let splitClr={}
		let splitPos={}
		for j in keys(t:txb.map[sp])
			let r=j/t:gran
			if has_key(splitLbl,r)
				if !has_key(conflicts,r)
					if splitLbl[r][0][0]=='!'
						let conflicts[r]=[splitLbl[r][0],splitPos[r][0]]
						let splitPos[r]=[]
					else
						let conflicts[r]=['$',0]
					en
				en
				if t:txb.map[sp][j][0][0]=='!' && t:txb.map[sp][j][0]<?conflicts[r][0]
					if conflicts[r][1]
						call add(splitPos[r],conflicts[r][1])
					en
					let conflicts[r][0]=t:txb.map[sp][j][0]
					let conflicts[r][1]=j
				else
					call add(splitPos[r],j)
				en
			else
				let splitLbl[r]=[t:txb.map[sp][j][0]]
				let splitClr[r]=t:txb.map[sp][j][1]
				let splitPos[r]=[j]
			en
		endfor
		for r in keys(conflicts)
			call sort(splitPos[r])
			if conflicts[r][1]
				let splitLbl[r]=['+'.conflicts[r][0]]+map(copy(splitPos[r]),'t:txb.map[sp][v:val][0]')
				call insert(splitPos[r],conflicts[r][1])
				let splitClr[r]=t:txb.map[sp][conflicts[r][1]][1]
			else
				let splitLbl[r]=map(copy(splitPos[r]),'t:txb.map[sp][v:val][0]')
				let splitLbl[r][0]='+'.splitLbl[r][0]
				let splitClr[r]=t:txb.map[sp][splitPos[r][0]][1]
			en
		endfor
		let changed=copy(splitClr)
		for i in keys(t:gridLbl[sp])
			if !has_key(splitLbl,i)
				let changed[i]=''
			elseif splitLbl[i]==#t:gridLbl[sp][i] && splitClr[i]==t:gridClr[sp][i] 
				unlet changed[i]
			en
		endfor
		call extend(redR,changed,'keep')
		let t:gridLbl[sp]=splitLbl
		let t:gridClr[sp]=splitClr
		let t:gridPos[sp]=splitPos
	endfor
	let t:deepR=len(t:bgd)-1
	for i in keys(redR)
		let t:disTxt[i]=''
		let j=t:txbL-1
		let padl=t:mapw
		while j>=0
			let l=len(get(get(t:gridLbl[j],i,[]),0,''))
			if !l
				let padl+=t:mapw
			elseif l>=padl
				if empty(t:disTxt[i])
					let t:disTxt[i]=t:gridLbl[j][i][0]
					let intervals=[padl]
					let t:disClr[i]=[t:gridClr[j][i]]
				else
					let t:disTxt[i]=t:gridLbl[j][i][0][:padl-2].'#'.t:disTxt[i]
					if t:gridClr[j][i]==t:disClr[i][0]
						let intervals[0]+=padl
					else
						call insert(intervals,padl)
						call insert(t:disClr[i],t:gridClr[j][i])
					en
				en
				let padl=t:mapw
			elseif empty(t:disTxt[i])
				let t:disTxt[i]=t:gridLbl[j][i][0].strpart(t:bgd[i],j*t:mapw+l,padl-l)
				if empty(t:gridClr[j][i])
					let intervals=[padl]
					let t:disClr[i]=['']
				else
					let intervals=[l,padl-l]
					let t:disClr[i]=[t:gridClr[j][i],'']
				en
				let padl=t:mapw
			else
				let t:disTxt[i]=t:gridLbl[j][i][0].strpart(t:bgd[i],j*t:mapw+l,padl-l).t:disTxt[i]
				if empty(t:disClr[i][0])
					let intervals[0]+=padl-l
				else
					call insert(intervals,padl-l)
					call insert(t:disClr[i],'')
				en
				if empty(t:gridClr[j][i])
					let intervals[0]+=l
				else
					call insert(intervals,l)
					call insert(t:disClr[i],t:gridClr[j][i])
				en
				let padl=t:mapw
			en
			let j-=1
		endw
		if empty(get(t:gridLbl[0],i,''))
			let padl-=t:mapw
			if empty(t:disTxt[i])
				let t:disTxt[i]=strpart(t:bgd[i],0,padl)
				let intervals=[padl]
				let t:disClr[i]=['']
			else
				let t:disTxt[i]=strpart(t:bgd[i],0,padl).t:disTxt[i]
				if empty(t:disClr[i][0])
					let intervals[0]+=padl
				else
					call insert(intervals,padl)
					call insert(t:disClr[i],'')
				en
			en
		en
		let sum=0
		for j in range(len(intervals))
			let intervals[j]=sum+intervals[j]
			let sum=intervals[j]
		endfor
		let t:disIx[i]=intervals
		let t:disIx[i][-1]=98989
	endfor
endfun

fun! s:disMap()
	let xe=s:mCoff+&columns-2
	let b=s:mC*t:mapw
	if b<xe
		let selection=get(t:gridLbl[s:mC],s:mR,[t:bgd[s:mR][b : b+t:mapw-1]])
		let sele=s:mR+len(selection)-1
		let truncb=b>=s:mCoff? 0 : s:mCoff-b
		let trunce=truncb+xe-b
		let vxe=b-1
	else
		let sele=-999999
	en
	let i=s:mRoff>0? s:mRoff : 0
	let lastR=i+&ch-2>t:deepR? t:deepR : i+&ch-2
	while i<=lastR
		let j=0
		if i<s:mR || i>sele
			while t:disIx[i][j]<s:mCoff
				let j+=1
			endw
			exe 'echohl' t:disClr[i][j]
			if t:disIx[i][j]>xe
				echon t:disTxt[i][s:mCoff : xe] "\n"
			else
				echon t:disTxt[i][s:mCoff : t:disIx[i][j]-1]
				let j+=1
				while t:disIx[i][j]<xe
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				echon t:disTxt[i][t:disIx[i][j-1] : xe] "\n"
			en
		else
			let seltext=selection[i-s:mR][truncb : trunce]
			if !truncb && b
				while t:disIx[i][j]<s:mCoff
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				if t:disIx[i][j]>vxe
					echon t:disTxt[i][s:mCoff : vxe]
				else
					echon t:disTxt[i][s:mCoff : t:disIx[i][j]-1]
					let j+=1
					while t:disIx[i][j]<vxe
						exe 'echohl' t:disClr[i][j]
						echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : vxe]
				en
				let vOff=b+len(seltext)
			else
				let vOff=s:mCoff+len(seltext)
			en
			echohl Visual
			if vOff<xe
				echon seltext
				while t:disIx[i][j]<vOff
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				if t:disIx[i][j]>xe
					echon t:disTxt[i][vOff : xe] "\n"
				else
					echon t:disTxt[i][vOff : t:disIx[i][j]-1]
					let j+=1
					while t:disIx[i][j]<xe
						exe 'echohl' t:disClr[i][j]
						echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : xe] "\n"
				en
			else
				echon seltext "\n"
			en
		en
		let i+=1
	endwhile
	echohl
	echon s:mC '-' s:mR*t:gran
endfun

fun! s:mapKeyHandler(c)
	if a:c is -1
		if s:msStat[0]==1
			let s:mPrevCoor=copy(s:msStat)
		elseif s:msStat[0]==2
			if s:mPrevCoor[1] && s:mPrevCoor[2] && s:msStat[1] && s:msStat[2]
				let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
				let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
				let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
				let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
				call s:disMap()
			en
			let s:mPrevCoor=copy(s:msStat)
		elseif s:msStat[0]==3
			if s:msStat==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:mSavSettings
				return
			elseif s:mPrevCoor[0]==1
				if &ttymouse=='xterm' && (s:mPrevCoor[1]!=s:msStat[1] || s:mPrevCoor[2]!=s:msStat[2])
					if s:mPrevCoor[1] && s:mPrevCoor[2] && s:msStat[1] && s:msStat[2]
						let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
						let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
						let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
						let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
						call s:disMap()
					en
					let s:mPrevCoor=copy(s:msStat)
				else
					let s:mR=s:msStat[2]-&lines+&ch-1+s:mRoff
					let s:mC=(s:msStat[1]-1+s:mCoff)/t:mapw
					if [s:mR,s:mC]==s:mPrevClk
						let [&ch,&more,&ls,&stal]=s:mSavSettings
						call s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:gran])[0])
						return
					en
					let s:mPrevClk=[s:mR,s:mC]
					let s:mPrevCoor=[0,0,0]
					call s:disMap()
				en
			en
		elseif s:msStat[0]==4
			let s:mRoff=s:mRoff>1? s:mRoff-1 : 0
			call s:disMap()
			let s:mPrevCoor=[0,0,0]
		elseif s:msStat[0]==5
			let s:mRoff=s:mRoff+1
			call s:disMap()
			let s:mPrevCoor=[0,0,0]
		en
		call feedkeys("\<plug>TxbY")
	else
		exe get(s:mCase,a:c,'let invalidkey=1')
		if s:mExit==1
			call s:disMap()
			echon exists('invalidkey')? ' (0..9) count (f1) help (hjklyubn) move (HJKLYUBN) pan (c)enter (g)o (q)uit (z)oom' : s:mCount is '01'? '' : ' '.s:mCount
			call feedkeys("\<plug>TxbY")
		elseif s:mExit==2
			let [&ch,&more,&ls,&stal]=s:mSavSettings
			call s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:gran])[0])
		else
			let [&ch,&more,&ls,&stal]=s:mSavSettings
		en
	en
endfun
let s:mCase={"\e":"let s:mExit=0|redr",
\"\<f1>":'call s:printHelp()',
\'q':"let s:mExit=0",
\'h':"let s:mC=s:mC>s:mCount? s:mC-s:mCount : 0|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0",
\'j':"let s:mR=s:mR+s:mCount<t:deepR? s:mR+s:mCount : t:deepR|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'k':"let s:mR=s:mR>s:mCount? s:mR-s:mCount : 0|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'l':"let s:mC=s:mC+s:mCount<t:txbL? s:mC+s:mCount : t:txbL-1|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'y':"let [s:mR,s:mC]=[max([s:mR-s:mCount,0]),max([s:mC-s:mCount,0])]|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'u':"let [s:mR,s:mC]=[max([s:mR-s:mCount,0]),min([s:mC+s:mCount,t:txbL-1])]|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'b':"let [s:mR,s:mC]=[min([s:mR+s:mCount,t:deepR]),max([s:mC-s:mCount,0])]|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'n':"let [s:mR,s:mC]=[min([s:mR+s:mCount,t:deepR]),min([s:mC+s:mCount,t:txbL-1])]|let s:mCount='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'H':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let s:mCoff=s:mCoff>s:mCount*t:mapw? s:mCoff-s:mCount*t:mapw : 0|let s:mCount='01'",
\'J':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let s:mRoff=s:mRoff+s:mCount<t:deepR? s:mRoff+s:mCount : t:deepR|let s:mCount='01'",
\'K':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let s:mRoff=s:mRoff>s:mCount? s:mRoff-s:mCount : 0|let s:mCount='01'",
\'L':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let s:mCoff=s:mCoff+s:mCount*t:mapw<t:mapw*t:txbL? s:mCoff+s:mCount*t:mapw : t:mapw*t:txbL|let s:mCount='01'",
\'Y':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let [s:mRoff,s:mCoff]=[max([s:mRoff-s:mCount,0]),max([s:mCoff-s:mCount*t:mapw,0])]|let s:mCount='01'",
\'U':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let [s:mRoff,s:mCoff]=[max([s:mRoff-s:mCount,0]),min([s:mCoff+s:mCount*t:mapw,t:txbL*t:mapw-1])]|let s:mCount='01'",
\'B':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let [s:mRoff,s:mCoff]=[min([s:mRoff+s:mCount,t:deepR]),max([s:mCoff-s:mCount*t:mapw,0])]|let s:mCount='01'",
\'N':"let s:mCount=s:mCount is '01'? 3 : s:mCount|let [s:mRoff,s:mCoff]=[min([s:mRoff+s:mCount,t:deepR]),min([s:mCoff+s:mCount*t:mapw,t:txbL*t:mapw-1])]|let s:mCount='01'",
\'1':"let s:mCount=s:mCount is '01'? 1 : s:mCount.'1'",
\'2':"let s:mCount=s:mCount is '01'? 2 : s:mCount.'2'",
\'3':"let s:mCount=s:mCount is '01'? 3 : s:mCount.'3'",
\'4':"let s:mCount=s:mCount is '01'? 4 : s:mCount.'4'",
\'5':"let s:mCount=s:mCount is '01'? 5 : s:mCount.'5'",
\'6':"let s:mCount=s:mCount is '01'? 6 : s:mCount.'6'",
\'7':"let s:mCount=s:mCount is '01'? 7 : s:mCount.'7'",
\'8':"let s:mCount=s:mCount is '01'? 8 : s:mCount.'8'",
\'9':"let s:mCount=s:mCount is '01'? 9 : s:mCount.'9'",
\'0':"let s:mCount=s:mCount is '01'? '01' : s:mCount.'0'",
\'c':"let s:mR=s:mRoff+(&ch-2)/2\n
	\let s:mC=(s:mCoff+&columns/2)/t:mapw\n
	\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
	\let s:mC=s:mC>=t:txbL? t:txbL-1 : s:mC",
\'z':"call s:disMap()\n
	\let input=str2nr(input('File lines per map line (>=10): ',t:gran))\n
	\let width=str2nr(input('Width of map column (>=1): ',t:mapw))\n
	\if input<10 || width<1\n
		\echohl ErrorMsg\n
		\echo 'Error: Invalid values'\n
		\sleep 500m\n
		\redr!\n
	\elseif input!=t:gran || width!=t:mapw\n
		\let s:mR=s:mR*t:gran/input\n
		\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
		\let t:txb.settings['lines per map grid']=input\n
		\let t:gran=input\n
		\let t:mapw=width\n
		\let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0\n
		\call s:getMapDis()\n
		\let s:mPrevClk=[0,0]\n
		\redr!\n
	\en\n",
\'g':'let s:mExit=2'}
let s:mCase["\<c-m>"]  =s:mCase.g
let s:mCase["\<right>"]=s:mCase.l
let s:mCase["\<left>"] =s:mCase.h
let s:mCase["\<down>"] =s:mCase.j
let s:mCase["\<up>"]   =s:mCase.k
let s:mCase[" "]       =s:mCase.J
let s:mCase["\<bs>"]   =s:mCase.K

let txbCmd.o="let mes=''\n
	\let s:mCount='01'\n
	\let s:mSavSettings=[&ch,&more,&ls,&stal]\n
		\let [&more,&ls,&stal]=[0,0,0]\n
		\let &ch=&lines\n
	\let s:mPrevClk=[0,0]\n
	\let s:mPrevCoor=[0,0,0]\n
	\let s:mR=line('.')/t:gran\n
	\call s:redraw(1)\n
	\redr!\n
	\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
	\let s:mC=w:txbi\n
	\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
	\let s:mExit=1\n
	\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
	\let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0\n
	\call s:disMap()\n
	\let g:TxbKeyHandler=function('s:mapKeyHandler')\n
	\call feedkeys(\"\\<plug>TxbY\")\n"

let txbCmd.M="if 'y'==?input('? Entirely build map by scanning all files? (Map partially updates on (o)pening and (r)edrawing) (y/n): ')\n
		\let curwin=exists('w:txbi')? w:txbi : 0\n
		\let view=winsaveview()\n
		\for i in map(range(t:txbL),'(curwin+v:val)%t:txbL')\n
			\exe t:paths[i]!=#fnameescape(fnamemodify(expand('%'),':p'))? 'e'.t:paths[i] : ''\n
			\let t:txb.depth[i]=line('$')\n
			\let t:txb.map[i]={}\n
			\exe 'norm! 1G0'\n
			\let line=search('^'.t:lblmrk.'\\zs','Wc')\n
			\while line\n
				\let L=getline('.')\n
				\let lnum=strpart(L,col('.')-1,6)\n
				\if lnum!=0\n
					\let lbl=lnum[len(lnum+0)]==':'? split(L[col('.')+len(lnum+0)+1:],'#',1) : []\n
					\if lnum<line\n
						\if prevnonblank(line-1)>=lnum\n
							\let lbl=[' Error! '.get(lbl,0,''),'ErrorMsg']\n
						\else\n
							\exe 'norm! kd'.(line-lnum==1? 'd' : (line-lnum-1).'k')\n
						\en\n
					\elseif lnum>line\n
						\exe 'norm! '.(lnum-line).'O\ej'\n
					\en\n
					\let line=line('.')\n
				\else\n
					\let lbl=split(L[col('.'):],'#',1)\n
				\en\n
				\if !empty(lbl) && !empty(lbl[0])\n
					\let t:txb.map[i][line]=[lbl[0],get(lbl,1,'')]\n
				\en\n
				\let line=search('^'.t:lblmrk.'\\zs','W')\n
			\endwhile\n
		\endfor\n
		\exe t:paths[curwin]!=#fnameescape(fnamemodify(expand('%'),':p'))? 'e'.t:paths[curwin] : ''\n
		\call winrestview(view)\n
		\call s:getMapDis()\n
		\call s:redraw()\n
		\let mes='Plane remapped'\n
	\else\n
		\let mes='Plane remap cancelled'\n
	\en"

delf s:SID
