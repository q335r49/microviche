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
	\\n\\CSTARTING UP:\n\nNavigate to the WORKING DIRECTORY (you only have to do this when you first create a plane). Press [hotkey] to bring up a prompt. You can try a pattern like '*.txt', or you can enter a file name and later [A]ppend others.\n
	\\nYou can now use the MOUSE to pan, or press [hotkey] followed by:
	\\n    h j k l y u b n      Pan (takes count, eg, 3j=jjj)
	\\n    r                    redraw
	\\n    o O                  Open map / map visible and open map
	\\n    m M                  map visible / Map all
	\\n    L                    insert '[label marker][lnum]'
	\\n    D A                  Delete / Append split
	\\n    <f1>                 Help
	\\n *  S                    Settings
	\\n    W                    Write to file
	\\n    ^X                   Delete hidden buffers
	\\n    q <esc>              Abort
	\\n----------
	\\n *  If [hotkey] becomes inaccessible, ':call TxbKey('S')'
	\\n\n\\CMAPPING:\n
	\\nLines starting with [label marker], default 'txb:', are considered labels. Labels can provide a line number, a label, a color, or all three. The general syntax is:
	\\n\n    [label marker][lnum][:][ label[#highlght[#ignored]]]
	\\n\n[hotkey][R]emap will [r]edraw, map, and relocate the label line to [line num] by inserting or removing blank lines above for all visible splits.\n
	\\nExamples: (Note the ':' when both lnum and label are provided)
	\\n    txb:345 bla bla        Just move to 345
	\\n    txb:345: Intro#Search  Move to 345, label 'Intro', color 'Search'
	\\n    txb: Intro##bla bla    Just label 'Blah'
	\\n\nPress [hotkey][o] to view the map:
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
	let minimal={'label marker':'txb:','working dir':getcwd(),'map cell width':5,'split width':60,'autoexe':'se nowrap scb cole=2','lines panned by j,k':15,'kbd x pan speed':9,'kbd y pan speed':2,'mouse pan speed':[0,1,2,4,7,10,15,21,24,27],'lines per map grid':45}
	if !exists('plane.settings')
		let plane.settings=minimal
	else
		for i in keys(minimal)
			if !has_key(plane.settings,i)
				let plane.settings[i]=minimal[i]
			else
				let cursor=0
				let vals=[1]
				let smsg=''
				unlet! input
				let input=plane.settings[i]
				silent! exe get(s:ErrorCheck,i,['',''])[1]
				if !empty(smsg)
					let plane.settings[i]=minimal[i]
					let warnings.="\n> Warning: invalid setting (default will be used): ".i.": ".smsg
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
		let t:kpLn=t:txb.settings['lines panned by j,k']
		let t:kpSpH=t:txb.settings['kbd x pan speed']
		let t:kpSpV=t:txb.settings['kbd y pan speed']
		let t:msSp=t:txb.settings['mouse pan speed']
		let t:gran=t:txb.settings['lines per map grid']
		let t:deepest=max(t:txb.depth)
		let t:mapw=t:txb.settings['map cell width']
		let t:lblmrk=t:txb.settings['label marker']
		let t:wdir=t:txb.settings['working dir']
		let t:paths=abs_paths
		call filter(t:txb,'index(["depth","exe","map","name","settings","size"],v:key)!=-1')
		call filter(t:txb.settings,'index(["label marker","working dir","writefile","split width","autoexe","map cell width","lines panned by j,k","kbd x pan speed","kbd y pan speed","mouse pan speed","lines per map grid"],v:key)!=-1')
		call s:redraw()
		call s:getMapDis()
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
			exe 'nn <silent>' t_dict[1] ':call TxbKey("init")<cr>'
			let g:TXB_HOTKEY=t_dict[1]
			if !a0 && exists('g:TXB') && type(g:TXB)==4
				let g:TXB.settings['working dir']=fnamemodify(t_dict[3],'p:')
				call TxbInit()
			else
				let plane.settings['working dir']=fnamemodify(t_dict[3],'p:')
				let plane.name=plane_name_save
				call TxbInit(plane)
			en
		else
			redr|echo "Cancelled"
		en
	else
		let input=input("> Enter file pattern or type HELP: ",'','file')
		if input==?'help'
			call s:printHelp()
		elseif !empty(input)
			call TxbInit(input)
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

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
let txbCmd["\<c-x>"]='cal s:deleteHiddenBuffers()|let s:kc_continue="Hidden Buffers Deleted"'

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

let txbCmd.S="if !exists('w:txbi')\n
	\let [settings_names,settings_values]=[['hotkey'],[g:TXB_HOTKEY]]\n
	\if s:settingsPager(settings_names,settings_values,s:ErrorCheck)\n
		\if stridx(maparg(g:TXB_HOTKEY),'TXB')!=-1\n
			\exe 'silent! nunmap' g:TXB_HOTKEY\n
		\elseif stridx(maparg('<f10>'),'TXB')!=-1\n
			\silent! nunmap <f10>\n
		\en\n
		\exe 'nn <silent>' settings_values[0] ':call TxbKey(\"init\")<cr>'\n
		\let g:TXB_HOTKEY=settings_values[0]\n
	\en\n
	\let s:kc_continue=''\n
\else\n
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
	\let [settings_names[11],settings_values[11]]=['working dir',has_key(t:txb.settings,'working dir') && type(t:txb.settings['working dir'])==1? t:txb.settings['working dir'] : '']\n
	\let [settings_names[12],settings_values[12]]=['label marker',has_key(t:txb.settings,'label marker') && type(t:txb.settings['label marker'])==1? t:txb.settings['label marker'] : '']\n
	\let [settings_names[13],settings_values[13]]=['    -- Split '.w:txbi.' --','##label##']\n
	\let [settings_names[14],settings_values[14]]=['current width',get(t:txb.size,w:txbi,60)]\n
	\let [settings_names[15],settings_values[15]]=['current autoexe',get(t:txb.exe,w:txbi,'se nowrap scb cole=2')]\n
	\let [settings_names[16],settings_values[16]]=['current file',get(t:txb.name,w:txbi,'')]\n
	\let prevVal=deepcopy(settings_values)\n
	\if s:settingsPager(settings_names,settings_values,s:ErrorCheck)\n
		\echohl MoreMsg\n
		\let s:kc_continue='Settings saved! '\n
		\if stridx(maparg(g:TXB_HOTKEY),'TXB')!=-1\n
			\exe 'silent! nunmap' g:TXB_HOTKEY\n
		\elseif stridx(maparg('<f10>'),'TXB')!=-1\n
			\silent! nunmap <f10>\n
		\en\n
		\exe 'nn <silent>' settings_values[1] ':call TxbKey(\"init\")<cr>'\n
		\let g:TXB_HOTKEY=settings_values[1]\n
		\let t:txb.size[w:txbi]=settings_values[14]\n
		\let t:txb.exe[w:txbi]=settings_values[15]\n
		\if !empty(settings_values[16]) && settings_values[16]!=prevVal[16]\n
			\let t:paths[w:txbi]=s:sp_newfname[0]\n
			\let t:txb.name[w:txbi]=s:sp_newfname[1]\n
		\en\n
		\let t:txb.settings['split width']=settings_values[3]\n
			\if prevVal[3]!=#t:txb.settings['split width']\n
				\if 'y'==?input('Apply new default split width to current splits? (y/n)')\n
					\let t:txb.size=repeat([t:txb.settings['split width']],len(t:txb.name))\n
					\let s:kc_continue.='(Current splits resized) '\n
				\else\n
					\let s:kc_continue.='(Only appended splits will inherit split width) '\n
				\en\n
			\en\n
		\let t:txb.settings['autoexe']=settings_values[4]\n
			\if prevVal[4]!=#t:txb.settings.autoexe\n
				\if 'y'==?input('Apply new default autoexe to current splits? (y/n)')\n
					\let t:txb.exe=repeat([t:txb.settings.autoexe],len(t:txb.name))\n
					\let s:kc_continue.='(Autoexe settings applied to current splits)'\n
				\else\n
					\let s:kc_continue.='(Only appended splits will inherit new autoexe) '\n
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
		\if t:txb.settings['lines per map grid']!=settings_values[9] || t:txb.settings['map cell width']!=settings_values[10]\n
			\let t:txb.settings['lines per map grid']=settings_values[9]\n
			\let t:gran=settings_values[9]\n
			\let t:txb.settings['map cell width']=settings_values[10]\n
			\let t:mapw=settings_values[10]\n
			\call s:getMapDis()\n
		\en\n
		\if !empty(settings_values[11]) && settings_values[11]!=t:txb.settings['working dir']\n
			\let wd_msg='(Working dir not changed)'\n
			\if 'y'==?input('Are you sure you want to change the working directory? (Step 1/3; cancel at any time) (y/n)')\n
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
						\let t:txb.settings['working dir']=settings_values[11]\n
						\let t:wdir=settings_values[11]\n
						\exe 'cd' fnameescape(t:wdir)\n
						\let t:paths=map(copy(t:txb.name),'fnameescape(fnamemodify(v:val,'':p''))')\n
						\exe 'cd' fnameescape(curwd)\n
						\let wd_msg='(Working dir changed)'\n
					\en\n
				\en\n
			\en\n
			\let s:kc_continue.=wd_msg\n
		\en\n
		\let t:txb.settings['label marker']=settings_values[12]\n
			\let t:lblmrk=settings_values[12]\n
		\echohl NONE\n
		\call s:redraw()\n
	\else\n
		\let s:kc_continue='Cancelled'\n
	\en\n
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
			echohl
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
		\for k in [1,3,4,5,6,7,8,9,10,12]\n
			\let vals[k]=get(a:errorcheck,a:keys[k],[vals[k]])[0]\n
		\endfor\n
		\for k in [11,14,15,16]\n
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
		\exe 'cd' fnameescape(t:wdir)\n
		\let input=input('(Use full path if not in working dir '.t:wdir.')\nEnter file (do not escape spaces): ',type(vals[cursor])==1? vals[cursor] : string(vals[cursor]),'file')\n
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
let s:ErrorCheck['label marker']=['txb:','let vals[cursor]=input','(Default :txb) Regexs are allowed, labels are found via search(''^''.labelmark)']
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
let s:ErrorCheck.hotkey=['<f10>',"let vals[cursor]=input","For example: <f10>, <c-v> (ctrl-v), vx (v then x). WARNING: If the hotkey becomes inaccessible, evoke ':call TxbKey(\"S\")'"]
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
let s:ErrorCheck['map cell width']=[5,
	\"let input=str2nr(input)\n
	\if input<1\n
		\let smsg.='Error: map cell width must be >= 1'\n
	\else\n
		\let vals[cursor]=input\n
	\en",'number >= 1']

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

fun! TxbKey(cmd)
	let s:kc_num='01'
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

let txbCmd.h='cal s:blockPan(-s:kc_num+!!s:getOffset(),0,line(''w0''),1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.j='cal s:blockPan(0,0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.k='cal s:blockPan(0,0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.l='cal s:blockPan(s:kc_num,0,line(''w0''),1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.y='cal s:blockPan(-s:kc_num+!!s:getOffset(),0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.u='cal s:blockPan(s:kc_num,0,max([1,line(''w0'')/t:kpLn*t:kpLn-s:kc_num*t:kpLn]),1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.b='cal s:blockPan(-s:kc_num+!!s:getOffset(),0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.n='cal s:blockPan(s:kc_num,0,line(''w0'')/t:kpLn*t:kpLn+s:kc_num*t:kpLn,1)|let s:kc_num=''01''|redrawstatus!'
let txbCmd.1="let s:kc_num=s:kc_num is '01'? '1' : s:kc_num.'1'"
let txbCmd.2="let s:kc_num=s:kc_num is '01'? '2' : s:kc_num.'2'"
let txbCmd.3="let s:kc_num=s:kc_num is '01'? '3' : s:kc_num.'3'"
let txbCmd.4="let s:kc_num=s:kc_num is '01'? '4' : s:kc_num.'4'"
let txbCmd.5="let s:kc_num=s:kc_num is '01'? '5' : s:kc_num.'5'"
let txbCmd.6="let s:kc_num=s:kc_num is '01'? '6' : s:kc_num.'6'"
let txbCmd.7="let s:kc_num=s:kc_num is '01'? '7' : s:kc_num.'7'"
let txbCmd.8="let s:kc_num=s:kc_num is '01'? '8' : s:kc_num.'8'"
let txbCmd.9="let s:kc_num=s:kc_num is '01'? '9' : s:kc_num.'9'"
let txbCmd.0="let s:kc_num=s:kc_num is '01'? '01': s:kc_num.'0'"
let txbCmd["\<up>"]=txbCmd.k
let txbCmd["\<down>"]=txbCmd.j
let txbCmd["\<left>"]=txbCmd.h
let txbCmd["\<right>"]=txbCmd.l

let txbCmd.L="let L=getline('.')\n
	\let s:kc_continue='(labeled)'\n
	\if L[: t:lblmrklen-1]!=#t:lblmrk\n
		\let inserttext=t:lblmrk.line('.').' '\n
		\call setline(line('.'),inserttext.L)\n
		\call cursor(line('.'),len(inserttext)+1)\n
		\startinsert\n
	\else\n 
		\let ix=stridx(L,': ',t:lblmrklen)\n
		\if ix==-1\n
			\let ix2=stridx(L,' ',t:lblmrklen)\n
			\call setline(line('.'),t:lblmrk.line('.').(ix2==-1? '' : L[ix2 :]))\n
		\else\n
			\call setline(line('.'),t:lblmrk.line('.').L[ix :])\n
		\en\n
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
			\let t:txbL=len(t:txb.name)\n
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
			\let t:txbL=len(t:txb.name)\n
			\call s:redraw()\n
		\en\n
		\exe 'cd' fnameescape(prevwd)\n
	\else\n
		\let s:kc_continue='Current file not in plane! [hotkey] r redraw before appending.'\n
	\en\n
	\call s:setCursor(cpos[0],cpos[1],cpos[2])"

let txbCmd.W=
	\"let prevwd=getcwd()\n
	\exe 'cd' fnameescape(t:wdir)\n
	\let input=input('Write plane to file (relative to '.t:wdir.'): ',exists('t:txb.settings.writefile') && type(t:txb.settings.writefile)<=1? t:txb.settings.writefile : '','file')\n
	\let [t:txb.settings.writefile,s:kc_continue]=empty(input)? [t:txb.settings.writefile,'(file write aborted)'] : [input,writefile(['unlet! txb_temp_plane','let txb_temp_plane='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TxbInit(txb_temp_plane)'],input)? 'ERROR: File not writable' : 'File written, '':source '.input.''' to restore']\n
	\exe 'cd' fnameescape(prevwd)"

fun! s:getOffset()
	let cSp=getwinvar(1,'txbi')
	return winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : -1
endfun

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

fun! s:getDest(sp,off,N)
	let offset=a:off+a:N
	let sp=a:sp
	while offset<0
		let sp=sp>0? sp-1 : t:txbL-1
		let offset+=t:txb.size[sp-1]+1
	endwhile
	while offset>t:txb.size[sp]
		let offset-=t:txb.size[sp]+1
		let sp=sp>=t:txbL-1? 0 : sp+1
	endwhile
	return [sp,offset]
endfun

fun! s:blockPan(sp,off,y,mode)
	if a:mode==2
		let sp=(a:sp%t:txbL+t:txbL)%t:txbL
		let cpos=[line('.'),virtcol('.'),w:txbi]
		let name=t:paths[sp]
		if name!=#fnameescape(fnamemodify(expand('%'),':p'))
			winc t
			exe 'e '.name
			let w:txbi=sp
		en
		only
		exe 'norm! '.(a:y? a:y : 1).'zt0'.a:off.'zl'
		call s:redraw()
		call s:setCursor(cpos[0],cpos[1],cpos[2])
		return
	en
	let cSp=getwinvar(1,'txbi')
	let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
	let dSp=((a:mode? cSp+a:sp : a:sp)%t:txbL+t:txbL)%t:txbL
	let dir=a:mode? a:sp+(!a:sp)*(cOff-a:off) : dSp-cSp+(dSp==cSp)*(cOff-a:off)
	if dir>0
		while 1
			let l0=line('w0')
			let dif=a:y-l0
			let yn=dif>t:kpSpV? l0+t:kpSpV : dif<-t:kpSpV? l0-t:kpSpV : !dif? l0 : dif>0? l0+dif : l0-dif
			let cSp=getwinvar(1,'txbi')
			if !((cSp-dSp+1)%t:txbL)
				if winwidth(1)+a:off>t:kpSpH
					call s:nav(t:kpSpH,yn)
				else
					call s:nav(winwidth(1)+a:off,yn)
					break
				en
			elseif cSp==dSp
				let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
				if a:off-cOff>t:kpSpH
					call s:nav(t:kpSpH,yn)
				else
					call s:nav(a:off-cOff,yn)
					break
				en
			else
				call s:nav(t:kpSpH,yn)
			en
			redr
		endwhile
	elseif dir<0
		while 1
			let l0=line('w0')
			let dif=a:y-l0
			let yn=dif>t:kpSpV? l0+t:kpSpV : dif<-t:kpSpV? l0-t:kpSpV : !dif? l0 : dif>0? l0+dif : l0-dif
			let cSp=getwinvar(1,'txbi')
			if !((cSp-dSp-1)%t:txbL)
				if winwidth(1)+t:txb.size[dSp]-a:off>t:kpSpH
					call s:nav(-t:kpSpH,yn)
				else
					call s:nav(-winwidth(1)-t:txb.size[dSp]+a:off,yn)
					break
				en
			elseif cSp==dSp
				let cOff=winwidth(1)>t:txb.size[cSp]? 0 : winnr('$')!=1? t:txb.size[cSp]-winwidth(1) : !&wrap? virtcol('.')-wincol() : a:off>t:txb.size[cSp]-&columns? t:txb.size[cSp]-&columns : a:off
				if cOff-a:off>t:kpSpH
					call s:nav(-t:kpSpH,yn)
				else
					call s:nav(a:off-cOff,yn)
					break
				en
			else
				call s:nav(-t:kpSpH,yn)
			en
			redr
		endwhile
	en
	let l0=line('w0')
	let ll=line('$')
	let dif=l0-a:y
	while dif && !(a:y>l0 && l0==ll)
		exe dif>t:kpSpV? 'norm! '.t:kpSpV."\<c-y>" : dif<-t:kpSpV? 'norm! '.t:kpSpV."\<c-e>" : dif>0? 'norm! '.dif."\<c-y>" : 'norm! '.(-dif)."\<c-e>"
		let l0=line('w0')
		let dif=l0-a:y
		redr
	endwhile
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
			exe 'bot vsp' t:paths[nextcol]
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
	if a:0
		call s:getMapDis()
	en
endfun
let txbCmd.r="call s:redraw()|redr|let s:kc_continue='(redraw complete)'"
let txbCmd.m="call s:redraw(1)|redr|let s:kc_continue='(Remap complete)'"

fun! s:mapSplit(col)
	let t:txb.depth[a:col]=line('$')
	let t:txb.map[a:col]={}
	norm! 1G0
	let line=search('^'.t:lblmrk.'\zs','Wc')
	while line
		let L=getline('.')
		let lnum=strpart(L,col('.')-1,6)
		if lnum!=0
			let lbl=split(L[col('.')+len(lnum+0):],'#',1)
			if lnum<line
				let deletions=line-lnum
				if prevnonblank(line-1)>=lnum
					let lbl=[" Error! ".get(lbl,0,''),'ErrorMsg']
				else
					exe 'norm! kd'.(deletions==1? 'd' : (deletions-1).'k')
				en
				let line=line('.')
			elseif lnum>line
				exe 'norm! '.(lnum-line)."O\ej"
				let line=line('.')
			en
		else
			let lbl=split(L[col('.'):],'#',1)
		en
		if !empty(lbl) && !empty(lbl[0])
			let t:txb.map[a:col][line]=[lbl[0],get(lbl,1,'')]
		en
		let line=search('^'.t:lblmrk.'\zs','W')
	endwhile
endfun

let txbCmd.M="if 'y'==?input('Are you sure you want to remap the entire plane? This will cycle through every file in the plane (y/n): ','y')\n
		\let curwin=w:txbi\n
		\let view=winsaveview()\n
		\for i in map(range(1,t:txbL),'(curwin+v:val)%t:txbL')\n
			\exe 'e' t:paths[i]\n 
			\call s:mapSplit(i)\n
		\endfor\n
		\exe 'e' t:paths[curwin]\n 
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
				exe 'rightb vert '.(winwidth(0)-t:txb.size[w:txbi]-1).'split '.t:paths[nextcol]
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
	let s:gridLbl=range(t:txbL)
	let gridClr=copy(s:gridLbl)
	let s:gridPos=copy(s:gridLbl)
	let conflicts={}
	for i in copy(s:gridLbl)
		let s:gridLbl[i]={}
		let gridClr[i]={}
		let s:gridPos[i]={}
		for j in keys(t:txb.map[i])
			let r=j/t:gran
			if has_key(s:gridLbl[i],r)
				let key=i.' '.r
				if !has_key(conflicts,key)
					if s:gridLbl[i][r][0][0]<#'0'
				   		let conflicts[key]=[i,r,s:gridLbl[i][r][0],s:gridPos[i][r][0]]
						let s:gridPos[i][r]=[]
					else
				   		let conflicts[key]=[i,r,'0',-1]
					en
				en
				if t:txb.map[i][j][0][0]<#conflicts[key][2][0]
					if conflicts[key][3]!=-1
						call add(s:gridPos[i][r],conflicts[key][3])
					en
					let conflicts[key][2]=t:txb.map[i][j][0]
					let conflicts[key][3]=j
				else
					call add(s:gridPos[i][r],j)
				en
			else
				let s:gridLbl[i][r]=[t:txb.map[i][j][0]]
				let gridClr[i][r]=t:txb.map[i][j][1]
				let s:gridPos[i][r]=[j]
			en
		endfor
	endfor
	for pos in values(conflicts)
		if pos[3]!=-1
			call sort(s:gridPos[pos[0]][pos[1]])
			let s:gridLbl[pos[0]][pos[1]]=[pos[2]]+map(copy(s:gridPos[pos[0]][pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			call insert(s:gridPos[pos[0]][pos[1]],pos[3])
			let gridClr[pos[0]][pos[1]]=t:txb.map[pos[0]][pos[3]][1]
		else
			call sort(s:gridPos[pos[0]][pos[1]])
			let s:gridLbl[pos[0]][pos[1]]=map(copy(s:gridPos[pos[0]][pos[1]]),'t:txb.map[pos[0]][v:val][0]')
			let gridClr[pos[0]][pos[1]]=t:txb.map[pos[0]][s:gridPos[pos[0]][pos[1]][0]][1]
		en
	endfor
	let pad=map(range(1,t:deepest,t:gran),'join(map(range(t:txbL),v:val.''>t:txb.depth[v:val]? "'.repeat('.',t:mapw).'" : "'.repeat(' ',t:mapw).'"''),'''')')
	let t:deepR=len(pad)-1
	let g:pad=pad
	let s:disTxt=repeat([''],t:deepR+1)
	let s:disClr=copy(s:disTxt)
	let s:disIx=copy(s:disTxt)
	for i in range(t:deepR+1)
		let j=t:txbL-1
		let padl=t:mapw
		while j>=0
			let l=len(get(get(s:gridLbl[j],i,[]),0,''))
			if !l
				let padl+=t:mapw
			elseif l>=padl
				if empty(s:disTxt[i])
					let s:disTxt[i]=s:gridLbl[j][i][0]
					let intervals=[padl]
					let s:disClr[i]=[gridClr[j][i]]
				else
					let s:disTxt[i]=s:gridLbl[j][i][0][:padl-2].'>'.s:disTxt[i]
					if gridClr[j][i]==s:disClr[i][0]
						let intervals[0]+=padl
					else
						call insert(intervals,padl)
						call insert(s:disClr[i],gridClr[j][i])
					en
				en
				let padl=t:mapw
			elseif empty(s:disTxt[i])
				let s:disTxt[i]=s:gridLbl[j][i][0].strpart(pad[i],j*t:mapw+l,padl-l)
				if empty(gridClr[j][i])
					let intervals=[padl]
					let s:disClr[i]=['']
				else
					let intervals=[l,padl-l]
					let s:disClr[i]=[gridClr[j][i],'']
				en
				let padl=t:mapw
			else
				let s:disTxt[i]=s:gridLbl[j][i][0].strpart(pad[i],j*t:mapw+l,padl-l).s:disTxt[i]
				if empty(s:disClr[i][0])
					let intervals[0]+=padl-l
				else
					call insert(intervals,padl-l)
					call insert(s:disClr[i],'')
				en
				if empty(gridClr[j][i])
					let intervals[0]+=l
				else
					call insert(intervals,l)
					call insert(s:disClr[i],gridClr[j][i])
				en
				let padl=t:mapw
			en
			let j-=1
		endw
		if empty(get(s:gridLbl[0],i,''))
			let padl-=t:mapw
			if empty(s:disTxt[i])
				let s:disTxt[i]=strpart(pad[i],0,padl)
				let intervals=[padl]
				let s:disClr[i]=['']
			else
				let s:disTxt[i]=strpart(pad[i],0,padl).s:disTxt[i]
				if empty(s:disClr[i][0])
					let intervals[0]+=padl
				else
					call insert(intervals,padl)
					call insert(s:disClr[i],'')
				en
			en
		en
		let sum=0
		for j in range(len(intervals))
			let intervals[j]=sum+intervals[j]
			let sum=intervals[j]
		endfor
		let s:disIx[i]=intervals
		let s:disIx[i][-1]=99999
	endfor
endfun

fun! s:disMap()
	let xe=s:mCoff+&columns-2
	let b=s:mC*t:mapw
	if b<xe
		let selection=get(s:gridLbl[s:mC],s:mR,[repeat(' ',t:mapw)])
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
			while s:disIx[i][j]<s:mCoff
				let j+=1
			endw
			exe 'echohl' s:disClr[i][j]
			if s:disIx[i][j]>xe
				echon s:disTxt[i][s:mCoff : xe] "\n"
			else
				echon s:disTxt[i][s:mCoff : s:disIx[i][j]-1]
				let j+=1
				while s:disIx[i][j]<xe
					exe 'echohl' s:disClr[i][j]
					echon s:disTxt[i][s:disIx[i][j-1] : s:disIx[i][j]-1]
					let j+=1
				endw
				exe 'echohl' s:disClr[i][j]
				echon s:disTxt[i][s:disIx[i][j-1] : xe] "\n"
			en
		else
			let seltext=selection[i-s:mR][truncb : trunce]
			if !truncb && b
				while s:disIx[i][j]<s:mCoff
					let j+=1
				endw
				exe 'echohl' s:disClr[i][j]
				if s:disIx[i][j]>vxe
					echon s:disTxt[i][s:mCoff : vxe]
				else
					echon s:disTxt[i][s:mCoff : s:disIx[i][j]-1]
					let j+=1
					while s:disIx[i][j]<vxe
						exe 'echohl' s:disClr[i][j]
						echon s:disTxt[i][s:disIx[i][j-1] : s:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' s:disClr[i][j]
					echon s:disTxt[i][s:disIx[i][j-1] : vxe]
				en
				let vOff=b+len(seltext)
			else
				let vOff=s:mCoff+len(seltext)
			en
			echohl Visual
			if vOff<xe
				echon seltext
				while s:disIx[i][j]<vOff
					let j+=1
				endw
				exe 'echohl' s:disClr[i][j]
				if s:disIx[i][j]>xe
					echon s:disTxt[i][vOff : xe] "\n"
				else
					echon s:disTxt[i][vOff : s:disIx[i][j]-1]
					let j+=1
					while s:disIx[i][j]<xe
						exe 'echohl' s:disClr[i][j]
						echon s:disTxt[i][s:disIx[i][j-1] : s:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' s:disClr[i][j]
					echon s:disTxt[i][s:disIx[i][j-1] : xe] "\n"
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
						if t:txb.size[s:mC]>&columns
							let [sp,off]=[s:mC,0]
						else
							let [sp,off]=s:getDest(s:mC,0,-(&columns-t:txb.size[s:mC])/2)
						en
						let r=get(s:gridPos[s:mC],s:mR,[s:mR*t:gran])[0]
						let r0=r-winheight(0)/2
						let r0=r0<1? 1 : r0
						call s:blockPan(sp,off,r0,2)
						exe ((t:txbL+s:mC-getwinvar(1,'txbi'))%t:txbL+1).'wincmd w'
						let dif=line('w0')-r0
						if !dif
							exe r
						elseif dif>0
							exe 'norm! '.dif."\<c-y>".r.'G'
						else
							exe 'norm! '.(-dif)."\<c-e>".r.'G'
						en
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
			if t:txb.size[s:mC]>&columns
				let [sp,off]=[s:mC,0]
			else
				let [sp,off]=s:getDest(s:mC,0,-(&columns-t:txb.size[s:mC])/2)
			en
			let r=get(s:gridPos[s:mC],s:mR,[s:mR*t:gran])[0]
			let r0=r-winheight(0)/2
			let r0=r0<1? 1 : r0
			call  s:blockPan(sp,off,r0,2)
			exe ((t:txbL+s:mC-getwinvar(1,'txbi'))%t:txbL+1).'wincmd w'
			let dif=line('w0')-r0
			if !dif
				exe r
			elseif dif>0
				exe 'norm! '.dif."\<c-y>".r.'G'
			else
				exe 'norm! '.(-dif)."\<c-e>".r.'G'
			en
		else
			let [&ch,&more,&ls,&stal]=s:mSavSettings
		en
	en
endfun

let txbCmd.o="let s:kc_continue=''\n
	\let s:mNum='01'\n
	\let s:mSavSettings=[&ch,&more,&ls,&stal]\n
		\let [&more,&ls,&stal]=[0,0,0]\n
		\let &ch=&lines\n
	\let s:mPrevClk=[0,0]\n
	\let s:mPrevCoor=[0,0,0]\n
	\let s:mR=line('.')/t:gran\n
	\if s:mR>t:deepR\n
		\call s:redraw(1)\n
		\redr!\n
	\en\n
	\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
	\let s:mC=w:txbi\n
	\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
	\let s:mExit=1\n
	\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
	\let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0\n
	\call s:disMap()\n
	\let g:TxbKeyHandler=function('s:mapKeyHandler')\n
	\call feedkeys(\"\\<plug>TxbY\")\n"
let txbCmd.O="let t:deepR=-1|".txbCmd.o

let s:mExe={"\e":"let s:mExit=0|redr",
\"\<f1>":'call s:printHelp()',
\'q':"let s:mExit=0",
\'h':"let s:mC=s:mC>s:mNum? s:mC-s:mNum : 0|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0",
\'j':"let s:mR=s:mR+s:mNum<t:deepR? s:mR+s:mNum : t:deepR|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'k':"let s:mR=s:mR>s:mNum? s:mR-s:mNum : 0|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'l':"let s:mC=s:mC+s:mNum<t:txbL? s:mC+s:mNum : t:txbL-1|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'y':"let [s:mR,s:mC]=[max([s:mR-s:mNum,0]),max([s:mC-s:mNum,0])]|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'u':"let [s:mR,s:mC]=[max([s:mR-s:mNum,0]),min([s:mC+s:mNum,t:txbL-1])]|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'b':"let [s:mR,s:mC]=[min([s:mR+s:mNum,t:deepR]),max([s:mC-s:mNum,0])]|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'n':"let [s:mR,s:mC]=[min([s:mR+s:mNum,t:deepR]),min([s:mC+s:mNum,t:txbL-1])]|let s:mNum='01'|let s:mCoff=s:mC*t:mapw>&columns/2? s:mC*t:mapw-&columns/2 : 0|let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0", 
\'H':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let s:mCoff=s:mCoff>s:mNum*t:mapw? s:mCoff-s:mNum*t:mapw : 0|let s:mNum='01'",
\'J':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let s:mRoff=s:mRoff+s:mNum<t:deepR? s:mRoff+s:mNum : t:deepR|let s:mNum='01'",
\'K':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let s:mRoff=s:mRoff>s:mNum? s:mRoff-s:mNum : 0|let s:mNum='01'",
\'L':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let s:mCoff=s:mCoff+s:mNum*t:mapw<t:mapw*t:txbL? s:mCoff+s:mNum*t:mapw : t:mapw*t:txbL|let s:mNum='01'",
\'Y':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let [s:mRoff,s:mCoff]=[max([s:mRoff-s:mNum,0]),max([s:mCoff-s:mNum*t:mapw,0])]|let s:mNum='01'",
\'U':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let [s:mRoff,s:mCoff]=[max([s:mRoff-s:mNum,0]),min([s:mCoff+s:mNum*t:mapw,t:txbL*t:mapw-1])]|let s:mNum='01'",
\'B':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let [s:mRoff,s:mCoff]=[min([s:mRoff+s:mNum,t:deepR]),max([s:mCoff-s:mNum*t:mapw,0])]|let s:mNum='01'",
\'N':"let s:mNum=s:mNum is '01'? 3 : s:mNum|let [s:mRoff,s:mCoff]=[min([s:mRoff+s:mNum,t:deepR]),min([s:mCoff+s:mNum*t:mapw,t:txbL*t:mapw-1])]|let s:mNum='01'",
\'1':"let s:mNum=s:mNum is '01'? 1 : s:mNum.'1'",
\'2':"let s:mNum=s:mNum is '01'? 2 : s:mNum.'2'",
\'3':"let s:mNum=s:mNum is '01'? 3 : s:mNum.'3'",
\'4':"let s:mNum=s:mNum is '01'? 4 : s:mNum.'4'",
\'5':"let s:mNum=s:mNum is '01'? 5 : s:mNum.'5'",
\'6':"let s:mNum=s:mNum is '01'? 6 : s:mNum.'6'",
\'7':"let s:mNum=s:mNum is '01'? 7 : s:mNum.'7'",
\'8':"let s:mNum=s:mNum is '01'? 8 : s:mNum.'8'",
\'9':"let s:mNum=s:mNum is '01'? 9 : s:mNum.'9'",
\'0':"let s:mNum=s:mNum is '01'? '01' : s:mNum.'0'",
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
