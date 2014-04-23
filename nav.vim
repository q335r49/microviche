"https://github.com/q335r49/microviche

if &cp|se nocompatible|en                    "[Vital] Enable vim features
se noequalalways winwidth=1 winminwidth=0    "[Vital] Needed for correct panning

se sidescroll=1                              "Smoother panning
se nostartofline                             "Keeps cursor in the same position when panning
se mouse=a                                   "Enables mouse
se lazyredraw                                "Less redraws
se virtualedit=all                           "Makes leftmost split align correctly
se hidden                                    "Suppresses error messages when a modified buffer pans offscreen
se scrolloff=0                               "Ensures correct vertical panning

if !exists('g:TXB_HOTKEY')
	let g:TXB_HOTKEY='<f10>'
en
exe 'nn <silent>' g:TXB_HOTKEY ':call TxbKey("init")<cr>'
augroup TXB
	au!
	au VimEnter * if stridx(maparg('<f10>'),'TXB')!=-1 | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' g:TXB_HOTKEY ':call TxbKey("init")<cr>'
augroup END

let s:badSync=v:version<704 || v:version==704 && !has('patch131')

if !has("gui_running")
	fun! <SID>centerCursor(row,col)
		call s:redraw()
		call s:nav(a:col/2-&columns/4,line('w0')-winheight(0)/4+a:row/2)
	endfun
	augroup TXB
		au VimResized * if exists('w:txbi') | call <SID>centerCursor(winline(),eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')) | en
	augroup END
	nn <silent> <leftmouse> :exe get(txbMsInit,&ttymouse,g:txbMsInit.default)()<cr>
else
	nn <silent> <leftmouse> :exe <SID>initDragDefault()<cr>
en

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
	\ (v:version<=703? "\n> Warning: Vim < 7.4 - Vim 7.4 is recommended.": '')
	\.(v:version<703 || v:version==703 && !has('patch106')? "\n> Warning: Vim < 7.3.106 - Splits won't sync until mouse release": '')
	\.(v:version<703 || v:version==703 && !has('patch30')?  "\n> Warning: Vim < 7.3.30 - Plane can't be saved to viminfo; write settings to file with [hotkey] W."
	\: empty(&vi) || stridx(&vi,'!')==-1? "\n> Warning: Viminfo not set - Plane will not be remembered between sessions because 'viminfo' doe not contain '!'. Try ':set viminfo+=!' or write to file with [hotkey] W." : '')
	\.(len(split(laggyAu,"\n"))>4? "\n> Warning: Autocommands - Mouse panning may lag due to BufEnter, BufLeave, WinEnter, and WinLeave autocommands. Slim down autocommands (':au Bufenter' to list) or use 'BufRead' or 'BufHidden'?" : '')
	\.(has('gui_running')? "\n> Warning: gVim - Auto-redrawing on resize disabled (resizing occurs too frequently in gVim): use [hotkey] r or ':call TxbKey('r')'" : '')
	\.(&ttymouse==?'xterm'? "\n> Warning: ttymouse - Mouse panning disabled for 'xterm'. Try ':set ttymouse=xterm2' or 'sgr'." : '')
	\.(ttymouseWorks && &ttymouse!=?'xterm2' && &ttymouse!=?'sgr'? "\n> Suggestion: 'set ttymouse=xterm2' or 'sgr' allows mouse panning in map mode." : '')
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	let s:help_bookmark=s:pager(s:formatPar("\nWelcome to microViche v1.8! (github.com/q335r49/microviche)\n"
	\.(empty(WarningsAndSuggestions)? "\nWarnings and Suggestions: (none)\n" : "\nWarnings and Suggestions:".WarningsAndSuggestions."\n")
	\."\nCurrent hotkey: ".g:TXB_HOTKEY."\n
	\\n\n\\CSTARTUP AND NAVIGATION:\n
	\\nStart by navigate to the WORKING DIRECTORY to create a plane. (After creation, the plane can be accessed from any directory). Press [hotkey] to bring up a prompt. You can try a pattern like '*.txt', or you can enter a file name and later [A]ppend others.\n
	\\nOnce loaded, use the MOUSE to pan, or press [hotkey] followed by:
	\\n    h j k l y u b n      Pan (takes count, eg, 3jjj=3j3j3j)
	\\n    r                    Redraw and remap visible splits
	\\n    o                    Remap visible and open map
	\\n    M                    Map all
	\\n    L                    Insert '[label marker][lnum]'
	\\n    D A                  Delete / Append split
	\\n    <f1>                 Help
	\\n *  S                    Settings
	\\n    W                    Write to file
	\\n    q <esc>              Abort
	\\n----------
	\\n *  If [hotkey] becomes inaccessible, :call TxbKey('S') to set.
	\\n\n\\CLABELING:\n
	\\nLabels are lines that start with a label marker (default 'txb:') and specify a line number, label text, or both. In addition to updating the map, remapping (with [hotkey][o], [r], or [M]) will move any displaced labels to the provided line number by inserting or removing preceding blank lines. Any relocation failures will be displayed in the map.
	\\n\nSYNTAX: marker(lnum)(:)( label#highlght#ignored)
	\\nEXAMPLES:
	\\n    txb:345 bla bla        Just move to 345
	\\n *  txb:345: Intro#Search  Move to 345, label 'Intro', color 'Search'
	\\n    txb: Intro             Just label 'Intro'
	\\n    txb: Intro##bla bla    Just label 'Intro'
	\\n----------
	\\n *  Note the ':' separator when both lnum and label are given
	\\n\n\\CMAP NAVIGATION:\n
	\\nTo remap the visbile region and view the map, press [hotkey][o]:
	\\n    h j k l y u b n      Move (takes count)
	\\n    H J K L Y U B N      Pan (takes count)
	\\n    c                    Put cursor at center of view
	\\n    g <cr>               Go to block and exit map
	\\n    z                    Change zoom
	\\n    q                    Quit"
	\.(ttymouseWorks? "\n *  doubleclick          Go to block
	\\n    drag                 Pan
	\\n    click NW corner      Quit
	\\n    drag to NW corner    (in the plane) Show map
	\\n----------\n *  The mouse only works when ttymouse is set to xterm, xterm2 or sgr. The 'hotcorner' is disabled for xterm."
	\:"\n    [Mouse in map mode is unsupported in gVim and Windows]\n----------"),
	\width,(&columns-width)/2),s:help_bookmark)
endfun
let txbCmd["\<f1>"]='call s:printHelp()|let s:kc_continue=""'

fun! TxbInit(...)
	se noequalalways winwidth=1 winminwidth=0
	let warnings=''
	let plane=!a:0? exists('g:TXB') && type(g:TXB)==4? deepcopy(g:TXB) : {'name':[]} : type(a:1)==4? deepcopy(a:1) : type(a:1)==3? {'name':copy(a:1)} : {'name':split(glob(a:1),"\n")}
	let defaults={}
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
				exe get(s:optatt[i],'checkErr','let emsg=0')
				if emsg isnot 0
					let plane.settings[i]=defaults[i]
					let warnings.="\n> Warning: invalid setting (default will be used): ".i.": ".emsg
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
	let plane_name_save=copy(plane.name)
	let abs_paths=map(copy(plane.name),'fnameescape(fnamemodify(v:val,":p"))')
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
			call remove(abs_paths,i)
		en
	endfor
	exe 'cd' fnameescape(prevwd)
	if !empty(plane.name)
		let bufix=index(abs_paths,fnameescape(fnamemodify(expand('%'),':p')))
		if !empty(unreadable) && a:0 && type(a:1)==4
			let warnings.="\n> Warning: unreadable file(s) will be REMOVED from the plane (This is often because of an incorrect working directory; change in [S]ettings)"
			let confirmMsg="> [R] Remove and ".(bufix!=-1? "restore plane " : "load in new tab ")."[S] settings [F1] help [esc] cancel"
			let confirmKeys=[82]
		else
			let confirmMsg="> [enter] ".(bufix!=-1? "restore plane " : "load in new tab ")."[S] settings [F1] help [esc] cancel"
			let confirmKeys=[10,13]
		en
	elseif !empty(unreadable) || a:0 && type(a:1)==4
		let warnings.="\n> No readable files remain (make sure working dir is correct)"
		let confirmMsg="> [S] settings [F1] help [esc] cancel"
		let confirmKeys=[-1]
	else
		let confirmMsg=''
		let confirmKeys=[]
	en
	echon empty(plane.name)? '' : "\n> ".len(plane.name).' readable: '.join(plane.name,', ')
	echon empty(unreadable)? '' : "\n> ".len(unreadable).' unreadable: '.join(unreadable,', ')
	echon "\n> working dir: ".plane.settings['working dir']
	echohl WarningMsg | ec warnings
	echohl moremsg | ec confirmMsg
	echohl
	let c=empty(confirmKeys)? 0 : getchar()
	if index(confirmKeys,c)!=-1
		if bufix==-1 | tabe | en
		let g:TXB=plane
		let t:txb=plane
		let t:txbL=len(t:txb.name)
		let t:deepest=max(t:txb.depth)
		let t:paths=abs_paths
		let dict=t:txb.settings
		for i in keys(dict)
			exe get(s:optatt[i].onInit,'')
		endfor
		call filter(t:txb,'index(["depth","exe","map","name","settings","size"],v:key)!=-1')
		call filter(t:txb.settings,'has_key(defaults,v:key)')
		call s:getMapDis()
		call s:redraw()
	elseif c is "\<f1>"
		call s:printHelp()
	elseif c is 83
		if !a0 && exists('g:TXB') && type(g:TXB)==4
			let g:TXB.settings['working dir']=get(g:TXB.settings,'working dir','')
			call s:settingsPager(g:TXB.settings,['    -- Global --','hotkey','    -- Plane --','working dir'],s:optatt)
			call TxbInit()
		else
			call s:settingsPager(plane.settings,['    -- Global --','hotkey','    -- Plane --','working dir'],s:optatt)
			let plane.settings['working dir']=fnamemodify(t_dict['working dir'],'p:')
			let plane.name=plane_name_save
			call TxbInit(plane)
		en
	else
		let fileinp=input("> Enter file pattern or type HELP: ",'','file')
		if fileinp==?'help'
			call s:printHelp()
		elseif !empty(fileinp)
			call TxbInit(fileinp)
		en
	en
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

let s:panAcc=[0,1,2,4,7,10,15,21,24,27]
fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? get(s:panAcc,a:dy,s:panAcc[-1])."\<c-y>" : a:dy<0? get(s:panAcc,-a:dy,s:panAcc[-1])."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -get(t:msSp,a:dx,t:msSp[-1]) : get(t:msSp,-a:dx,t:msSp[-1]),a:dy<0? line('w0')+get(t:msSp,-a:dy,t:msSp[-1]) : line('w0')-get(t:msSp,a:dy,t:msSp[-1]))
	echon w:txbi '-' line('.')
endfun

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

" --- Option attributes ---- ( * Required ) --------------------
" loadk    * Command (out: ret) Load from key into display
" apply    * Command (in: arg; out: emsg) Apply arg to current setting (only executed when value changed), optionally return a confirmation 'emsg'
" doc        String: Explanation of setting
" getDef     Command (out: arg) Load default value into arg
" checkErr   Command (in: arg, out: arg, emsg): Normalize 'input' (eg, convert from string to array); return emsg: (number) 0 if no error, (string) message otherwise
" getInput   Command (out: arg) Overwrite default (:let arg=input('New value: ') [c]hange behavior
" required   Bool: If provided and true, ensure that key is always initialized (default: empty string)
" onInit     Command (in: dict) Executed when first loading a plane; apply setting to initialization routine
" --------------------------------------------------------------
let s:optatt={
	\'autoexe': {'doc': 'Default command on reveal for new splits; [c]hange and [S]ave for prompt to apply to current splits',
		\'loadk': 'let ret=dict.autoexe',
		\'getDef': "let arg='se nowrap scb cole=2'",
		\'required': 1,
		\'apply': "if 'y'==?input('Apply new default autoexe to current splits? (y/n)')\n
				\let t:txb.exe=repeat([arg],t:txbL)\n
				\let emsg='(Autoexe applied to current splits)'\n
			\else\n
				\let emsg='(Only appended splits will inherit new autoexe)'\n
			\en\n
			\let dict.autoexe=arg"},
	\'current autoexe': {'doc': 'Command when current split is revealed',
		\'loadk': 'let ret=t:txb.exe[w:txbi]',
		\'apply': 'let t:txb.exe[w:txbi]=arg'},
	\'current file': {'doc': 'File associated with this split',
		\'loadk': 'let ret=t:txb.name[w:txbi]',
		\'getInput':"let prevwd=getcwd()\n
			\exe 'cd' fnameescape(t:wdir)\n
			\let arg=input('(Use full path if not in working dir '.t:wdir.')\nEnter file (do not escape spaces): ',type(vals[a:entry[cursor]])==1? vals[a:entry[cursor]] : string(vals[a:entry[cursor]]),'file')\n
			\exe 'cd' fnameescape(prevwd)",
		\'apply': "if !empty(arg)\n
				\let prevwd=getcwd()\n
				\exe 'cd' fnameescape(t:wdir)\n
				\let t:paths[w:txbi]=fnameescape(fnamemodify(arg,':p'))\n
				\let t:txb.name[w:txbi]=arg\n
				\exe 'cd' fnameescape(prevwd)\n
			\en"},
	\'current width': {'doc': 'Width of current split',
		\'loadk': 'let ret=t:txb.size[w:txbi]',
		\'checkErr': 'let arg=str2nr(arg)|let emsg=arg>2? 0 : ''Split width must be > 2''',
		\'apply': 'let t:txb.size[w:txbi]=arg'},
	\'hotkey': {'doc': "Examples: '<f10>', '<c-v>' (ctrl-v), 'vx' (v then x). WARNING: If the hotkey becomes inaccessible, :call TxbKey('S')",
		\'loadk': 'let ret=g:TXB_HOTKEY',
		\'getDef': 'let arg=''<f10>''',
		\'required': 1,
		\'apply': "if stridx(maparg(g:TXB_HOTKEY),'TXB')!=-1\n
				\exe 'silent! nunmap' g:TXB_HOTKEY\n
			\elseif stridx(maparg('<f10>'),'TXB')!=-1\n
				\silent! nunmap <f10>\n
			\en\n
			\exe 'nn <silent>' arg ':call TxbKey(\"init\")<cr>'\n
			\let g:TXB_HOTKEY=arg"},
	\'label marker': {'doc': 'Regex for map marker, default ''txb:''; labels are found via search(''^''.labelmark)',
		\'loadk': 'let ret=dict[''label marker'']',
		\'getDef': 'let arg=''txb:''',
		\'required': 1,
		\'onInit': 'let t:lblmrk=dict["label marker"]',
		\'apply': 'let dict[''label marker'']=arg|let t:lblmrk=arg'},
	\'lines per map grid': {'doc': 'Each map grid is 1 split and this many lines',
		\'loadk': 'let ret=dict[''lines per map grid'']',
		\'getDef': 'let arg=45',
		\'checkErr': 'let arg=str2nr(arg)|let emsg=arg>0? 0 : ''Lines per map grid must be > 0''',
		\'required': 1,
		\'cc': 't:gran',
		\'onInit': 'let t:gran=dict["lines per map grid"]',
		\'apply': 'let dict[''lines per map grid'']=arg|let t:gra=arg|call s:getMapDis()'},
	\'map cell width': {'doc': 'Width of map column',
		\'loadk': 'let ret=dict[''map cell width'']',
		\'getDef': 'let arg=5',
		\'checkErr': 'let arg=str2nr(arg)|let emsg=arg>2? 0 : ''Map cell width must be > 2''',
		\'required': 1,
		\'cc': 't:mapw',
		\'onInit': 'let t:mapw=dict["map cell width"]',
		\'apply': 'let dict[''map cell width'']=arg|let t:mapw=arg|call s:getMapDis()'},
	\'mouse pan speed': {'doc': 'For every N steps with mouse, pan speed[N] steps in plane (only works when ttymouse is xterm2 or sgr)',
		\'loadk': 'let ret=copy(dict[''mouse pan speed''])',
		\'getDef': 'let arg=[0,1,2,4,7,10,15,21,24,27]',
		\'required': 1,
		\'onInit': 'let t:msSp=dict["mouse pan speed"]',
		\'checkErr': "try\n
				\let arg=type(arg)==1? eval(arg) : type(arg)==3? arg : ''\n
				\let emsg=type(arg)!=3? 'Must evaluate to list' : arg[0]? 'First element must be 0' : 0\n
			\catch\n
				\let arg=''\n
				\let emsg='String evaluation error'\n
			\endtry",
		\'apply': 'let dict[''mouse pan speed'']=arg|let t:msSp=arg'},
	\'split width': {'doc': 'Default width for new splits; [c]hange and [S]ave for prompt to apply to current splits',
		\'loadk': 'let ret=dict[''split width'']',
		\'getDef': 'let arg=60',
		\'checkErr': "let arg=str2nr(arg)|let emsg=arg>2? 0 : 'Default split width must be > 2'",
		\'required': 1,
		\'apply': "if 'y'==?input('Apply new default width to current splits? (y/n)')\n
				\let t:txb.size=repeat([arg],t:txbL)\n
				\let emsg='(Current splits resized)'\n
			\else\n
				\let emsg='(Only appended splits will inherit new width)'\n
			\en\n
			\let dict['split width']=arg"},
	\'writefile': {'doc': 'Default settings save file',
		\'loadk': 'let ret=dict[''writefile'']',
		\'checkErr': 'let emsg=type(arg)==1? 0 : "Writefile must be string"',
		\'required': 1,
		\'apply':'let dict[''writefile'']=arg'},
	\'working dir': {'doc': 'Directory for relative paths',
		\'loadk': 'let ret=dict["working dir"]',
		\'getDef': 'let arg="~"',
		\'checkErr': "let [emsg, arg]=isdirectory(arg)? [0,fnamemodify(arg,':p')] : ['Not a valid directory',arg]",
		\'onInit': 'let t:wdir=dict["working dir"]',
		\'required': 1,
		\'getInput': "let arg=input('Working dir (do not escape spaces; must be absolute path; press tab for completion): ',type(vals[a:entry[cursor]])==1? vals[a:entry[cursor]] : string(vals[a:entry[cursor]]),'file')",
		\'apply': "let emsg='(Working dir not changed)'\n
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
						\let emsg='(Working dir changed)'\n
					\en\n
				\en\n
			\en"}}

let s:spPos=[0,0]
fun! s:settingsPager(dict,entry,attr)
	let dict=a:dict
	let settings=[&more,&ch]
	let len=len(a:entry)
	let [&more,&ch]=[0,len<8? len+3 : 11]
	let cursor=s:spPos[0]<0? 0 : s:spPos[0]>=len? len-1 : s:spPos[0]
	let height=&ch-1
	let offset=s:spPos[1]<0? 0 : s:spPos[1]>len-height? (len-height>=0? len-height : 0) : s:spPos[1]
	let offset=offset<cursor-height? cursor-height : offset>cursor? cursor : offset
	let undo={}
	let disp={}
    for key in a:entry
		if has_key(a:attr,key)
			unlet! ret
			exe a:attr[key].loadk
			let disp[key]=ret
		en
	endfor
	let [helpw,contentw]=&columns>120? [60,60] : [&columns/2,&columns/2-1]
	let pad=repeat(' ',&columns)
	let emsg=0
	let exitcode=0
	let title='= Settings =='
	let title=title.repeat('=',contentw-len(title)-1).' = Description ==============='
	let settingshelp=s:formatPar('> jkgG:up/down/top/bot c:change U:undo D:default q:quit',helpw,0)
	while !exitcode
		redr!
		echo title
		if emsg isnot 0
			let warningmsg=s:formatPar('> '.emsg,helpw,0)
			let warningmsglen=len(warningmsg)
			let helpmsg=warningmsg+s:formatPar('> '.get(get(a:attr,get(a:entry,cursor,''),{}),'doc',''),helpw,0)+settingshelp
		else
			let warningmsglen=0
			let helpmsg=s:formatPar('> '.get(get(a:attr,get(a:entry,cursor,''),{}),'doc',''),helpw,0)+settingshelp
		en
		let helpmsglen=len(helpmsg)
		for i in range(offset,offset+height-1)
			if i<len
				let key=a:entry[i]
				let line=has_key(disp,key)? key.' : '.(type(disp[key])==1? disp[key] : string(disp[key])) : key
			else
				let key=''
				let line=' '
			en
			if i==cursor
				echohl Visual
			elseif !has_key(a:attr,key)
				echohl Title
			en
			let abspos=i-offset
			if abspos<helpmsglen
				if len(line)>=contentw
					echon "\n" line[:contentw-1]
				else
					echon "\n" line
					echohl
					echon pad[:contentw-len(line)-1]
				en
				if abspos<warningmsglen
					echohl ErrorMsg
				else
					echohl
				en
				echon get(helpmsg,abspos,'')
			else
				echon "\n" line[:&columns-1]
			en
			echohl
		endfor
		let key=a:entry[cursor]
		exe get(s:spExe,getchar(),'')
		let cursor=cursor<0? 0 : cursor>=len? len-1 : cursor
		let offset=offset<cursor-height+1? cursor-height+1 : offset>cursor? cursor : offset
	endwhile
	let [&more,&ch]=settings
	redr
	let s:spPos=[cursor,offset]
	echohl
	return exitcode
endfun

let s:applySettings="exe get(a:attr[key],'checkErr','let emsg=0')\n
		\if emsg is 0 && arg!=#disp[key]\n
			\if !has_key(undo,key)\n
				\let undo[key]=arg\n
			\en\n
			\exe a:attr[key].apply\n
			\let disp[key]=arg\n
		\en\n
	\en"
let s:spExe={68: "if !has_key(disp,key) || !has_key(a:attr[key],'getDef')\n
			\let emsg='No default defined for this value'\n
		\else\n
			\unlet! arg\n
			\exe a:attr[key].getDef\n".s:applySettings,
	\85: "if !has_key(disp,key) || !has_key(undo,key)\n
			\let emsg='No undo defined for this value'\n
		\else\n
			\unlet! arg\n
			\let arg=undo[key]\n".s:applySettings,
	\99: "if has_key(disp,key)\n
			\unlet! arg\n
			\exe get(a:attr[key],'getInput','let arg=input(''Enter new value: '',type(dict[key])==1? dict[key] : string(dict[key]))')\n".s:applySettings,
	\113: "let exitcode=1",
	\27:  "let exitcode=1",
	\106: 'let cursor+=1',
	\107: 'let cursor-=1',
	\103: 'let cursor=0',
	\71:  'let cursor=len-1'}
unlet s:applySettings

let txbCmd.S="let s:kc_continue=''\n
	\if exists('w:txbi')\n
		\call s:settingsPager(t:txb.settings,['   -- Global --','hotkey','   -- Plane --','split width','autoexe','mouse pan speed','lines per map grid','map cell width','working dir','label marker','   -- Split '.w:txbi.' --','current width','current autoexe','current file'],s:optatt)\n
	\else\n
		\call s:settingsPager({},['   -- Global --','hotkey'],s:optatt)\n
	\en"

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
	let s:kc_continue=' '
	let g:TxbKeyHandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:cmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:txbCmd,a:c,'let s:kc_continue="Invalid command: Press '.g:TXB_HOTKEY.' F1 for help"')
	if s:kc_continue==' '
		echon w:txbi '.' line('.')
		call feedkeys("\<plug>TxbZ")
	elseif !empty(s:kc_continue)
		redr|echon w:txbi '.' line('.') ' ' s:kc_continue
	en
endfun
let txbCmd.q="let s:kc_continue=''"
let txbCmd[-1]="let s:kc_continue=''"
let txbCmd.init="if !exists('w:txbi')\n
		\call TxbInit()\n
 		\let s:kc_continue=''\n
	\en"
let txbCmd["\e"]=txbCmd.q

let txbCmd.h="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0'))|redrawstatus!"
let txbCmd.j="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(0,line('w0')+s:count)|redrawstatus!"
let txbCmd.k="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(0,line('w0')-s:count)|redrawstatus!"
let txbCmd.l="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0'))|redrawstatus!"
let txbCmd.y="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0')-s:count)|redrawstatus!"
let txbCmd.u="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0')-s:count)|redrawstatus!"
let txbCmd.b="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(-s:count,line('w0')+s:count)|redrawstatus!"
let txbCmd.n="let s:count=s:count[0] is '0'? s:count : '0'.s:count|call s:nav(s:count,line('w0')+s:count)|redrawstatus!"
let txbCmd.1="let s:count=s:count[0] is '0'? '1' : s:count.'1'"
let txbCmd.2="let s:count=s:count[0] is '0'? '2' : s:count.'2'"
let txbCmd.3="let s:count=s:count[0] is '0'? '3' : s:count.'3'"
let txbCmd.4="let s:count=s:count[0] is '0'? '4' : s:count.'4'"
let txbCmd.5="let s:count=s:count[0] is '0'? '5' : s:count.'5'"
let txbCmd.6="let s:count=s:count[0] is '0'? '6' : s:count.'6'"
let txbCmd.7="let s:count=s:count[0] is '0'? '7' : s:count.'7'"
let txbCmd.8="let s:count=s:count[0] is '0'? '8' : s:count.'8'"
let txbCmd.9="let s:count=s:count[0] is '0'? '9' : s:count.'9'"
let txbCmd.0="let s:count=s:count[0] is '0'? '01': s:count.'0'"
let txbCmd["\<up>"]=txbCmd.k
let txbCmd["\<down>"]=txbCmd.j
let txbCmd["\<left>"]=txbCmd.h
let txbCmd["\<right>"]=txbCmd.l

let txbCmd.L="let L=getline('.')\n
	\let s:kc_continue='(labeled)'\n
	\if -1!=match(L,'^'.t:lblmrk)\n
		\call setline(line('.'),substitute(L,'^'.t:lblmrk.'\\zs\\d*\\ze',line('.'),''))\n
	\else\n
		\let prefix=t:lblmrk.line('.').' '\n
		\call setline(line('.'),prefix.L)\n
		\call cursor(line('.'),len(prefix))\n
		\startinsert\n
	\en"

let txbCmd.D=
	\"redr\n
	\if t:txbL==1\n
		\let s:kc_continue='Cannot delete last split!'\n
	\elseif input('Really delete current column (y/n)? ')==?'y'\n
		\let t_index=index(t:paths,fnameescape(fnamemodify(expand('%'),':p')))\n
		\if t_index!=-1\n
			\call remove(t:txb.name,t_index)\n
			\call remove(t:paths,t_index)\n
			\call remove(t:txb.size,t_index)\n
			\call remove(t:txb.exe,t_index)\n
			\call remove(t:txb.map,t_index)\n
			\call remove(t:gridLbl,t_index)\n
			\call remove(t:gridClr,t_index)\n
			\call remove(t:gridPos,t_index)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:getMapDis()\n
		\en\n
		\winc W\n
		\let cpos=[line('.'),virtcol('.'),w:txbi]\n
		\call s:redraw()\n
		\let s:kc_continue='(Split deleted)'\n
	\en\n
	\call s:setCursor(cpos[0],cpos[1],cpos[2])"

let txbCmd.A=
	\"let t_index=index(t:paths,fnameescape(fnamemodify(expand('%'),':p')))\n
	\let cpos=[line('.'),virtcol('.'),w:txbi]\n
	\if t_index!=-1\n
		\let prevwd=getcwd()\n
		\exe 'cd' fnameescape(t:wdir)\n
		\let file=input('(Use full path if not in working directory '.t:wdir.')\nAppend file (do not escape spaces) : ',t:txb.name[w:txbi],'file')\n
		\if (fnamemodify(expand('%'),':p')==#fnamemodify(file,':p') || t:paths[(w:txbi+1)%t:txbL]==#fnameescape(fnamemodify(file,':p'))) && 'y'!=?input('\nWARNING\n    An unpatched bug in Vim causes errors when panning modified ADJACENT DUPLICATE SPLITS. Continue with append? (y/n)')\n
			\let s:kc_continue='File not appended'\n
		\elseif empty(file)\n
			\let s:kc_continue='File name is empty'\n
		\else\n
			\let s:kc_continue='[' . file . (index(t:txb.name,file)==-1? '] appended.' : '] (duplicate) appended.')\n
			\call insert(t:txb.name,file,w:txbi+1)\n
			\call insert(t:paths,fnameescape(fnamemodify(file,':p')),w:txbi+1)\n
			\call insert(t:txb.size,t:txb.settings['split width'],w:txbi+1)\n
			\call insert(t:txb.exe,t:txb.settings.autoexe,w:txbi+1)\n
			\call insert(t:txb.map,{},w:txbi+1)\n
			\call insert(t:txb.depth,100,w:txbi+1)\n
			\call insert(t:gridLbl,{},w:txbi+1)\n
			\call insert(t:gridClr,{},w:txbi+1)\n
			\call insert(t:gridPos,{},w:txbi+1)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:redraw(1)\n
			\call s:getMapDis()\n
		\en\n
		\exe 'cd' fnameescape(prevwd)\n
	\else\n
		\let s:kc_continue='Current file not in plane! [hotkey] r redraw before appending.'\n
	\en\n
	\call s:setCursor(cpos[0],cpos[1],cpos[2])"

let txbCmd.W=
	\"let prevwd=getcwd()\n
	\exe 'cd' fnameescape(t:wdir)\n
	\let input=input('Write plane to file (relative to '.t:wdir.'): ',t:txb.settings.writefile,'file')\n
	\let [t:txb.settings.writefile,s:kc_continue]=empty(input)? [t:txb.settings.writefile,'(file write aborted)'] : [input,writefile(['unlet! txb_temp_plane','let txb_temp_plane='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TxbInit(txb_temp_plane)'],input)? 'ERROR: File not writable' : 'File written, '':source '.input.''' to restore']\n
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
	elseif get(t:paths,w:txbi,'')!=#name0
		let ix=index(t:paths,name0)
		if ix==-1
			let prev_txbi=w:txbi
			exe 'e' t:paths[prev_txbi]
			let w:txbi=prev_txbi
		else
			let w:txbi=ix
		en
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
	for i in range(1,numcols)
		se wfw
		if fnameescape(fnamemodify(bufname(''),':p'))!=#t:paths[ccol]
			exe 'e' t:paths[ccol]
		en
		let w:txbi=ccol
		exe t:txb.exe[ccol]
		if a:0
			call s:mapSplit(ccol)
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
		winc h
		let ccol=ccol? ccol-1 : t:txbL-1
	endfor
	let t:deepest=max(t:txb.depth)
	se scrollopt=ver,jump
	if s:badSync
		windo 1
	en
	silent exe "norm! :syncbind\<cr>"
	exe bufwinnr(pos[0]).'winc w'
	let offset=virtcol('.')-wincol()
	exe 'norm!' pos[1].'zt'.pos[2].'G'.(pos[3]<=offset? offset+1 : pos[3]>offset+winwidth(0)? offset+winwidth(0) : pos[3])
endfun
let txbCmd.r="call s:redraw(1)|redr|let s:kc_continue='(redraw complete)'"

fun! s:mapSplit(col)
	let blankcell=repeat(' ',t:mapw)
	let negcell=repeat('.',t:mapw)
	let colIx=a:col*t:mapw
	let newd=line('$')
	let newdR=newd/t:gran
	let curdR=t:txb.depth[a:col]/t:gran
	if newd>t:deepest
		if newdR>t:deepR
			let dif=newdR-t:deepR
			call extend(t:bgd,repeat([repeat('.',t:mapw*t:txbL)],dif))
			for i in range(curdR+1,newdR)
				let t:bgd[i]=colIx? t:bgd[i][:colIx-1].blankcell.t:bgd[i][colIx+t:mapw :] : blankcell.t:bgd[i][colIx+t:mapw :]
			endfor
			let depthChanged=range(curdR+1,newdR)
			call extend(t:disIx,eval('['.join(repeat(['[98989]'],dif),',').']'))
			call extend(t:disClr,eval('['.join(repeat(["['']"],dif),',').']'))
			call extend(t:disTxt,copy(t:bgd[-dif :]))
			let t:deepR=newdR
		else
			let depthChanged=[]
		en
		let t:deepest=newd
	elseif newdR>curdR
		for i in range(curdR+1,newdR)
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].blankcell.t:bgd[i][colIx+t:mapw :] : blankcell.t:bgd[i][colIx+t:mapw :]
		endfor
		let depthChanged=range(curdR+1,newdR)
	elseif newdR<curdR
		for i in range(newdR+1,curdR)
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].negcell.t:bgd[i][colIx+t:mapw :] : negcell.t:bgd[i][colIx+t:mapw :]
		endfor
		let depthChanged=range(newdR+1,curdR)
	else
		let depthChanged=[]
	en
	let t:txb.depth[a:col]=newd
	let t:txb.map[a:col]={}
	norm! 1G0
	let line=search('^'.t:lblmrk.'\zs','Wc')
	while line
		let L=getline('.')
		let lnum=strpart(L,col('.')-1,6)
		if lnum!=0
			let lbl=lnum[len(lnum+0)]==':'? split(L[col('.')+len(lnum+0)+1:],'#',1) : []
			if lnum<line
				if prevnonblank(line-1)>=lnum
					let lbl=[" Error! ".get(lbl,0,''),'ErrorMsg']
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
			let t:txb.map[a:col][line]=[lbl[0],get(lbl,1,'')]
		en
		let line=search('^'.t:lblmrk.'\zs','W')
	endwhile
	let conflicts={}
	let splitLbl={}
	let splitClr={}
	let splitPos={}
	for j in keys(t:txb.map[a:col])
		let r=j/t:gran
		if has_key(splitLbl,r)
			let key=a:col.' '.r
			if !has_key(conflicts,key)
				if splitLbl[r][0][0]<#'0'
					let conflicts[key]=[a:col,r,splitLbl[r][0],splitPos[r][0]]
					let splitPos[r]=[]
				else
					let conflicts[key]=[a:col,r,'0',-1]
				en
			en
			if t:txb.map[a:col][j][0][0]<#conflicts[key][2][0]
				if conflicts[key][3]!=-1
					call add(splitPos[r],conflicts[key][3])
				en
				let conflicts[key][2]=t:txb.map[a:col][j][0]
				let conflicts[key][3]=j
			else
				call add(splitPos[r],j)
			en
		else
			let splitLbl[r]=[t:txb.map[a:col][j][0]]
			let splitClr[r]=t:txb.map[a:col][j][1]
			let splitPos[r]=[j]
		en
	endfor
	for pos in values(conflicts)
		call sort(splitPos[pos[1]])
		if pos[3]!=-1
			let splitLbl[pos[1]]=[pos[2]]+map(copy(splitPos[pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			call insert(splitPos[pos[1]],pos[3])
			let splitClr[pos[1]]=t:txb.map[pos[0]][pos[3]][1]
		else
			let splitLbl[pos[1]]=map(copy(splitPos[pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			let splitClr[pos[1]]=t:txb.map[pos[0]][splitPos[pos[1]][0]][1]
		en
	endfor
	let changed=copy(splitClr)
	for i in keys(t:gridLbl[a:col])
		if has_key(splitLbl,i)
			if splitLbl[i]==#t:gridLbl[a:col][i] && splitClr[i]==t:gridClr[a:col][i] 
				unlet changed[i]
			en
		else
			let changed[i]=''
		en
	endfor
	for i in depthChanged
		let changed[i]=-1
	endfor
	let tomerge={}
	for r in keys(changed)
		if !has_key(splitLbl,r) 
			if a:col && (t:disTxt[r][colIx-1]==#'#' || changed[r]==-1)
				let prevsp=a:col-1
				while !has_key(t:gridLbl[prevsp],r) && prevsp>=0
					let prevsp-=1
				endw
				if prevsp!=-1
					let begin=t:mapw*prevsp
					let text=t:gridLbl[prevsp][r][0]
					let l=len(text)
					let textc=t:gridClr[prevsp][r]
					let beginc=prevsp
				else
					let begin=0
					let text=''
					let l=0
					let textc=''
					let beginc=0
				en
			else
				let begin=t:mapw*a:col
				let text=''
				let l=0
				let textc=''
				let beginc=a:col
			en
		else
			let begin=t:mapw*a:col
			let text=splitLbl[r][0]
			let l=len(text)
			let textc=splitClr[r]
			let beginc=a:col
		en
		let nextsp=a:col+1
		while nextsp<t:txbL && !has_key(t:gridLbl[nextsp],r)
			let nextsp+=1
		endwhile
		let end=nextsp==t:txbL? 98989 : t:mapw*nextsp
		let prevContents=t:disTxt[r][begin : begin+t:mapw-1]
		if begin && !has_key(t:gridLbl[beginc],r) && prevContents!=blankcell && prevContents!=negcell
			let begint=begin-1
			let text='#'.text
		else
			let begint=begin
		en
		if !l
			let tomerge[r]=[[begin,end],[0,'']]
			let t:disTxt[r]=(begin? t:disTxt[r][:begint-1] : '').t:bgd[r][begint : end-1].t:disTxt[r][end :]
		elseif l>=end-begin
			let tomerge[r]=[[begin,end],[0,textc]]
			let t:disTxt[r]=(begin? t:disTxt[r][:begint-1] : '').text[:end-begint-2].'#'.t:disTxt[r][end :]
		else
			let tomerge[r]=[[begin,begin+l,end],[0,textc,'']]
			let t:disTxt[r]=(begin? t:disTxt[r][:begint-1] : '').text.t:bgd[r][begint+l : end-1].t:disTxt[r][end :]
		en
	endfor
	for r in keys(tomerge)
		let t=0
		while t:disIx[r][t]<tomerge[r][0][0]
			let t+=1
		endwhile
		if t:disIx[r][t]>tomerge[r][0][0]
			if tomerge[r][1][1]!=?t:disClr[r][t]
				call insert(t:disIx[r],tomerge[r][0][0],t)
				call insert(t:disClr[r],t:disClr[r][t],t)
				let t+=1
			en
		else
			let t+=1
		en
		let t2=1
		let len=len(tomerge[r][0])
		while t2<len
			while t:disIx[r][t]<tomerge[r][0][t2]
				call remove(t:disIx[r],t)
				call remove(t:disClr[r],t)
			endwhile
			if t:disIx[r][t]==98989
				while t2<len && tomerge[r][0][t2]!=98989
					if get(t:disClr[r],-2,-1)==?tomerge[r][1][t2]
						let t:disIx[r][-2]=tomerge[r][0][t2]
					else
						call insert(t:disIx[r],tomerge[r][0][t2],-1)
						call insert(t:disClr[r],tomerge[r][1][t2],-1)
					en
					let t2+=1
				endw
				break
			elseif t:disIx[r][t]==tomerge[r][0][t2]
				let t:disClr[r][t]=tomerge[r][1][t2]
			elseif tomerge[r][1][t2]!=?t:disClr[r][t]
				call insert(t:disIx[r],tomerge[r][0][t2],t)
				call insert(t:disClr[r],tomerge[r][1][t2],t)
			en
			let t+=1
			let t2+=1
		endw
	endfor
	let t:gridLbl[a:col]=splitLbl
	let t:gridClr[a:col]=splitClr
	let t:gridPos[a:col]=splitPos
endfun

let txbCmd.M="if 'y'==?input('Are you sure you want to map the entire plane? This will cycle through every file in the plane (y/n): ','y')\n
		\let curwin=w:txbi\n
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
		\let t:deepest=max(t:txb.depth)\n
		\call s:getMapDis()\n
		\call s:redraw()\n
		\let s:kc_continue='(Plane remapped)'\n
	\else\n
		\let s:kc_continue='(Plane remap cancelled)'\n
	\en"

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

fun! s:getMapDis()
	let t:gridLbl=range(t:txbL)
	let t:gridClr=copy(t:gridLbl)
	let t:gridPos=copy(t:gridLbl)
	let conflicts={}
	for i in copy(t:gridLbl)
		let t:gridLbl[i]={}
		let t:gridClr[i]={}
		let t:gridPos[i]={}
		for j in keys(t:txb.map[i])
			let r=j/t:gran
			if has_key(t:gridLbl[i],r)
				let key=i.' '.r
				if !has_key(conflicts,key)
					if t:gridLbl[i][r][0][0]<#'0'
				   		let conflicts[key]=[i,r,t:gridLbl[i][r][0],t:gridPos[i][r][0]]
						let t:gridPos[i][r]=[]
					else
				   		let conflicts[key]=[i,r,'0',-1]
					en
				en
				if t:txb.map[i][j][0][0]<#conflicts[key][2][0]
					if conflicts[key][3]!=-1
						call add(t:gridPos[i][r],conflicts[key][3])
					en
					let conflicts[key][2]=t:txb.map[i][j][0]
					let conflicts[key][3]=j
				else
					call add(t:gridPos[i][r],j)
				en
			else
				let t:gridLbl[i][r]=[t:txb.map[i][j][0]]
				let t:gridClr[i][r]=t:txb.map[i][j][1]
				let t:gridPos[i][r]=[j]
			en
		endfor
	endfor
	for pos in values(conflicts)
		if pos[3]!=-1
			call sort(t:gridPos[pos[0]][pos[1]])
			let t:gridLbl[pos[0]][pos[1]]=[pos[2]]+map(copy(t:gridPos[pos[0]][pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			call insert(t:gridPos[pos[0]][pos[1]],pos[3])
			let t:gridClr[pos[0]][pos[1]]=t:txb.map[pos[0]][pos[3]][1]
		else
			call sort(t:gridPos[pos[0]][pos[1]])
			let t:gridLbl[pos[0]][pos[1]]=map(copy(t:gridPos[pos[0]][pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			let t:gridClr[pos[0]][pos[1]]=t:txb.map[pos[0]][t:gridPos[pos[0]][pos[1]][0]][1]
		en
	endfor
	let t:bgd=map(range(0,t:deepest+t:gran,t:gran),'join(map(range(t:txbL),v:val.''>t:txb.depth[v:val]? "'.repeat('.',t:mapw).'" : "'.repeat(' ',t:mapw).'"''),'''')')
	let t:deepR=len(t:bgd)-1
	let t:disTxt=repeat([''],t:deepR+1)
	let t:disClr=copy(t:disTxt)
	let t:disIx=copy(t:disTxt)
	for i in range(t:deepR+1)
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
		exe get(s:mExe,a:c,'')
		if s:mExit==1
			call s:disMap()
			call feedkeys("\<plug>TxbY")
		elseif s:mExit==2
			let [&ch,&more,&ls,&stal]=s:mSavSettings
			call s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:gran])[0])
		else
			let [&ch,&more,&ls,&stal]=s:mSavSettings
		en
	en
endfun

let txbCmd.o="let s:kc_continue=''\n
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

let s:mExe={"\e":"let s:mExit=0|redr",
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
let s:mExe["\<c-m>"]  =s:mExe.g
let s:mExe["\<right>"]=s:mExe.l
let s:mExe["\<left>"] =s:mExe.h
let s:mExe["\<down>"] =s:mExe.j
let s:mExe["\<up>"]   =s:mExe.k
let s:mExe[" "]       =s:mExe.J
let s:mExe["\<bs>"]   =s:mExe.K

delf s:SID

let RefreshMap=function('s:getMapDis')
