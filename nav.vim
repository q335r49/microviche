"github.com/q335r49/microviche

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

let TXB_HOTKEY=exists('TXB_HOTKEY')? TXB_HOTKEY : '<f10>'
let s:hotkeyArg=':if exists("w:txbi")\|call TxbKey("null")\|else\|if !TxbInit(exists("TXB")? TXB : "")\|let TXB=t:txb\|en\|en<cr>'
exe 'nn <silent>' TXB_HOTKEY s:hotkeyArg
au VimEnter * if escape(maparg('<f10>'),'|')==?s:hotkeyArg | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' TXB_HOTKEY s:hotkeyArg

if has('gui_running')
	nn <silent> <leftmouse> :exe txbMouse.default()<cr>
else
	au VimResized * if exists('w:txbi') | call s:redraw() |sil call s:nav(eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')/2-&co/4,line('w0')-winheight(0)/4+winline()/2) | en
	nn <silent> <leftmouse> :exe txbMouse[has_key(txbMouse,&ttymouse)? &ttymouse : 'default']()<cr>
en

fun! TxbInit(seed)
	se noequalalways winwidth=1 winminwidth=0
	if empty(a:seed)
		let wdir=input("# Creating a new plane...\n? Working dir: ",getcwd(),'file')
		while !isdirectory(wdir)
			if empty(wdir)
				return 1
			en
			let wdir=input("\n# (Invalid directory)\n? Working dir: ",getcwd(),'file')
		endwhile
		let plane={'settings':{'working dir':fnamemodify(wdir,':p')}}
		exe 'cd' fnameescape(plane.settings['working dir'])
			let input=input("\n? Starting files (single file or filepattern, eg, '*.txt'): ",'','file')
			let plane.name=split(glob(input),"\n")
		silent cd -
		if empty(input)
			return 1
		en
	else
		let plane=type(a:seed)==4? deepcopy(a:seed) : type(a:seed)==3? {'name':copy(a:seed)} : {'name':split(glob(a:seed),"\n")}
		call filter(plane,'index(["depth","exe","map","name","settings","size"],v:key)!=-1')
	en
	let prompt=''
	for i in keys(plane.settings)
		if !exists("s:option[i]['save']")
			unlet plane.settings[i]
			continue
		en
		unlet! arg | let arg=plane.settings[i]
		exe get(s:option[i],'check','let msg=0')
		if msg is 0
			continue
		en
		unlet! arg | exe get(s:option[i],'getDef','let arg=""')
		let plane.settings[i]=arg
		let prompt.="\n# Invalid setting (reverting to default): ".i.": ".msg
	endfor
	for i in filter(keys(s:option),'get(s:option[v:val],"save") && !has_key(plane.settings,v:val)')
		unlet! arg | exe get(s:option[i],'getDef','let arg=""')
		let plane.settings[i]=arg
	endfor
	let plane.settings['working dir']=fnamemodify(plane.settings['working dir'],':p')
	let plane_save=deepcopy(plane)
	let plane.size=has_key(plane,'size')? extend(plane.size,repeat([plane.settings['split width']],len(plane.name)-len(plane.size))) : repeat([60],len(plane.name))
	let plane.map=has_key(plane,'map') && empty(filter(range(len(plane.map)),'type(plane.map[v:val])!=4'))? extend(plane.map,eval('['.join(repeat(['{}'],len(plane.name)-len(plane.map)),',').']')) : eval('['.join(repeat(['{}'],len(plane.name)),',').']')
	let plane.exe=has_key(plane,'exe')? extend(plane.exe,repeat([plane.settings.autoexe],len(plane.name)-len(plane.exe))) : repeat([plane.settings.autoexe],len(plane.name))
	let plane.depth=has_key(plane,'depth')? extend(plane.depth,repeat([0],len(plane.name)-len(plane.depth))) : repeat([0],len(plane.name))
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
		let initCmd=index(map(copy(plane.name),'bufnr(fnamemodify(v:val,":p"))'),bufnr(''))==-1? 'tabe' : ''
	cd -
	ec "\n#" len(plane.name) "readable:" join(plane.name,', ') "\n#" len(unreadable) "unreadable:" join(unreadable,', ') "\n# Working dir:" plane.settings['working dir'] prompt
	if empty(plane.name)
		ec "# No matches\n? (N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[-1]
	elseif !empty(unreadable)
		ec "# Unreadable files will be removed!\n? (R)emove unreadable files and ".(empty(initCmd)? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[82,114]
	else
		ec "? (enter) ".(empty(initCmd)? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[10,13]
	en
	let c=getchar()
	echon strtrans(type(c)? c : nr2char(c))
	if index(confirmKeys,c)!=-1
		exe initCmd
		let t:txb=plane
		let t:txbL=len(t:txb.name)
		let dict=t:txb.settings
		for i in keys(dict)
			exe get(s:option[i],'onInit','')
		endfor
		exe 'cd' fnameescape(plane.settings['working dir'])
			let t:bufs=map(copy(plane.name),'bufnr(fnamemodify(v:val,":p"),1)')
		cd -
		exe empty(a:seed)? g:txbCmd.M : 'redr'
		call s:getMapDis()
		call s:redraw()
		return 0
	elseif index([83,115],c)!=-1
		let plane=plane_save
		call s:settingsPager(plane.settings,['Global','hotkey','mouse pan speed','Plane','working dir'],s:option)
		return TxbInit(plane)
	elseif index([78,110],c)!=-1
		return TxbInit('')
	elseif c is "\<f1>"
		exe g:txbCmd[c]
		ec mes
	en
	return 1
endfun

let txbMouse={}
fun! txbMouse.default()
	if exists('w:txbi')
		let cpos=[line('.'),virtcol('.'),w:txbi]
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:setCursor(cpos[0],cpos[1],cpos[2])
			echon getwinvar(v:mouse_win,'txbi') '-' v:mouse_lnum
			return "keepj norm! \<leftmouse>"
		en
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
				sil let [x,xs]=x && nx? [x,s:nav(x-nx,l0)] : [x? x : nx,0]
				let [x,y]=[wrap? v:mouse_win>1? x : nx+xs : x, l0>0? y : y-l0+1]
				redr
				ec ecstr
			en
			let c=getchar()
			while c!="\<leftdrag>" && c!="\<leftrelease>"
				let c=getchar()
			endwhile
		endwhile
		call s:setCursor(cpos[0],cpos[1],cpos[2])
		echon w:txbi '-' line('.')
		return ''
	en
	let possav=[bufnr('')]+getpos('.')[1:]
	call feedkeys("\<leftmouse>")
	call getchar()
	exe v:mouse_win."winc w"
	if v:mouse_lnum>line('w$') || &wrap && v:mouse_col%winwidth(0)==1 || !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum==line('$')
		return line('$')==line('w0')? "keepj norm! \<c-y>\<leftmouse>" : "keepj norm! \<leftmouse>"
	en
	exe "norm! \<leftmouse>"
	redr!
	let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
	let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(exists('g:opt_device') && g:opt_device==?'droid4' && veon)? 'redr!':'redr']
	let c=getchar()
	if c!="\<leftdrag>"
		return "keepj norm! \<leftmouse>"
	en
	while c=="\<leftdrag>"
		let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
		let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
		call winrestview(v)
		exe redrexpr
		let c=getchar()
	endwhile
	let glide=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
	if str2float(reltimestr(reltime(tl[(fr+1)%4][0])))<0.2
		let [glv,glh,vc,hc]=[tl[0][1]+tl[1][1]+tl[2][1]+tl[3][1],tl[0][2]+tl[1][2]+tl[2][2]+tl[3][2],0,0]
		let [tlx,lnx,glv,lcx,cax,glh]=(glv>3? ['y*v.topline>1','y*v.lnum>1',glv*glv] : glv<-3? ['-(y*v.topline<'.line('$').')','-(y*v.lnum<'.line('$').')',glv*glv] : [0,0,0])+(glh>3? ['x*v.leftcol>0','x*v.coladd>0',glh*glh] : glh<-3? ['-x','-x',glh*glh] : [0,0,0])
		while !getchar(1) && glv+glh
			let [y,x,vc,hc]=[vc>get(glide,glv,1),hc>get(glide,glh,1),vc+1,hc+1]
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
	return ''
endfun

fun! txbMouse.sgr()
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
			let [s:pX,s:pY]=[0,0]
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let [s:pX,s:pY]=[0,0]
		nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
	en
	return ''
endfun
fun! txbMouse.xterm2()
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
			let [s:pX,s:pY]=[0,0]
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let [s:pX,s:pY]=[0,0]
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! txbMouse.xterm()
	return "norm! \<leftmouse>"
endfun

fun! <SID>doDragSGR()
	let k=map(split(join(map([getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
		if !exists('w:txbi')
		elseif k[1:]==[1,1]
			call TxbKey('o')
		else
			echon w:txbi '-' line('.')
		en
	elseif !(k[1] && k[2] && s:pX && s:pY)
	elseif exists('w:txbi')
		sil call s:nav(s:mps[s:pX-k[1]],line('w0')+s:mps[s:pY-k[2]])
		echon w:txbi '-' line('.')
	else
		exe 'norm!'.s:panYCmd[s:pY-k[2]].s:panXCmd[s:pX-k[1]]
	en
	let [s:pX,s:pY]=k[1:2]
	while getchar(0) isnot 0
	endwhile
endfun
fun! <SID>doDragXterm2()
	let M=getchar(0)
	let X=getchar(0)
	let Y=getchar(0)
	if M==35
		nunmap <esc>[M
		if !exists('w:txbi')
		elseif [X,Y]==[33,33]
			call TxbKey('o')
		else
			echon w:txbi '-' line('.')
		en
	elseif !(X && Y && s:pX && s:pY)
	elseif exists('w:txbi')
		sil call s:nav(s:mps[s:pX-X],line('w0')+s:mps[s:pY-Y])
		echon w:txbi '-' line('.')
	else
		exe 'norm!'.s:panYCmd[s:pY-Y].s:panXCmd[s:pX-X]
	en
	let s:pX=X
	let s:pY=Y
	while getchar(0) isnot 0
	endwhile
endfun

fun! s:formatPar(str,w,...)
	let trspace=repeat(' ',len(&brk))
	let spaces=repeat(' ',a:w+2)
	let ret=[]
	for par in split(a:str,"\n")
		let tick=0
		while tick<len(par)-a:w
			let ix=strridx(tr(par,&brk,trspace),' ',tick+a:w-1)
			if ix>tick
				call add(ret,a:0? par[tick :ix].spaces[1:a:w-ix+tick-1] : par[tick :ix])
				let tick=ix
				while par[tick] is ' '
					let tick+=1
				endwhile
			else
				call add(ret,strpart(par,tick,a:w))
				let tick+=a:w
			en
		endw
		call add(ret,a:0? par[tick :].spaces[1:a:w-len(par)+tick] : par[tick :])
	endfor
	return ret
endfun

"loadk()    ret Get setting and load into ret (required for settings ui)
"apply(arg) msg When setting is changed, apply; optionally return str msg (required for settings ui)
"doc            (str) What the setting does
"getDef()   arg Load default value into arg
"check(arg) msg Normalize arg (eg convert from str to num) return msg (str if error, else num 0)
"getInput() arg Overwrite default (let arg=input('New value:')) [c]hange behavior
"save           (bool) t:txb.setting[key] will always exist (via getDef(), or '' if getDef() is undefined); unsaved keys will be filtered out from t:txb.settings
"onInit()       Exe when loading plane
let s:option = {'hist': {'doc': 'Jump history',
		\'getDef': 'let arg=[1,[0,0]]',
		\'check': 'let msg=type(arg)!=3 || len(arg)<2 || type(arg[0]) || arg[0]>=len(arg)? "Badly formed history" : 0',
		\'onInit': "if len(dict.hist)<98\n
			\elseif dict.hist[0]>0 && dict.hist[0]<len(dict.hist)\n
				\let dict.hist=(dict.hist[0]>32? [32]+dict.hist[dict.hist[0]-32+1 : dict.hist[0]] : dict.hist[:dict.hist[0]])+dict.hist[dict.hist[0]+1 : (dict.hist[0]+32<len(dict.hist)-1? dict.hist[0]+32 : -1)]\n
			\else\n
				\let dict.hist=[48]+dict.hist[len(dict.hist)-48 :]\n
			\en\n
			\let t:jhist=dict.hist",
		\'save': 1},
	\'autoexe': {'doc': 'Command when splits are revealed (for new splits, (c)hange for prompt to apply to current splits)',
		\'loadk': 'let ret=dict.autoexe',
		\'getDef': "let arg='se nowrap scb cole=2'",
		\'save': 1,
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
		\'getInput':"exe t:cwd\n
			\let arg=input('(Use full path if not in working dir '.dict['working dir'].')\nEnter file (do not escape spaces): ',type(disp[key])==1? disp[key] : string(disp[key]),'file')\n
			\cd -",
		\'apply': "if !empty(arg)\n
				\exe t:cwd\n
				\let t:bufs[w:txbi]=bufnr(fnamemodify(arg,':p'),1)\n
				\let t:txb.name[w:txbi]=arg\n
				\cd -\n
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
		\'save': 1,
		\'apply': "if escape(maparg(g:TXB_HOTKEY),'|')==?s:hotkeyArg\n
				\exe 'silent! nunmap' g:TXB_HOTKEY\n
			\elseif escape(maparg('<f10>'),'|')==?s:hotkeyArg\n
				\silent! nunmap <f10>\n
			\en\n
			\let g:TXB_HOTKEY=arg\n
			\exe 'nn <silent>' g:TXB_HOTKEY s:hotkeyArg"},
	\'mouse pan speed': {'doc': 'Pan speed[N] steps for every N mouse steps (only applies in terminal and ttymouse=xterm2 or sgr)',
		\'loadk': 'let ret=g:TXBMPS',
		\'getDef': 'let arg=[0,1,2,4,7,10,15,21,24,27]',
		\'check': "if type(arg)==1\n
				\try\n
					\let temp=eval(arg)\n
				\catch\n
					\let temp=''\n
				\endtry\n
				\unlet! arg\n
				\let arg=temp\n
			\en\n
			\let msg=type(arg)!=3? 'Must evaluate to list, eg, [0,1,2,3]' : arg[0]? 'First element must be 0' : 0",
		\'apply': "let g:TXBMPS=arg\n
			\let s:mps=g:TXBMPS+repeat([g:TXBMPS[-1]],40)+repeat([-g:TXBMPS[-1]],40)+map(reverse(copy(g:TXBMPS[1:])),'-v:val')\n
			\let s:panYCmd=['']+map(copy(g:TXBMPS[1:]),'v:val.''\<c-e>''')+repeat([g:TXBMPS[-1].'\<c-e>'],40)+repeat([g:TXBMPS[-1].'\<c-y>'],40)+map(reverse(copy(g:TXBMPS[1:])),'v:val.''\<c-y>''')\n
			\let s:panXCmd=['g']+map(copy(g:TXBMPS[1:]),'v:val.''zl''')+repeat([g:TXBMPS[-1].'zl'],40)+repeat([g:TXBMPS[-1].'zh'],40)+map(reverse(copy(g:TXBMPS[1:])),'v:val.''zh''')"},
	\'label marker': {'doc': 'Regex for map marker, default ''txb:''. Labels are found via search(''^''.labelmark)',
		\'loadk': 'let ret=dict[''label marker'']',
		\'getDef': 'let arg=''txb:''',
		\'save': 1,
		\'getInput': "let newMarker=input('New label marker: ',disp[key])\n
			\let newAutotext=input('Label autotext (hotkey L; should be same as marker if marker doesn''t contain regex): ',newMarker)\n
			\if !empty(newMarker) && !empty(newAutotext)\n
				\let arg=newMarker\n
				\let dict['label autotext']=newAutotext\n
			\en",
		\'apply': 'let dict[''label marker'']=arg'},
	\'label autotext': {'doc': 'Text for insert label command (hotkey L)',
		\'getDef': 'let arg=''txb:''',
		\'save': 1},
	\'lines per map grid': {'doc': 'Lines mapped by each map line',
		\'loadk': 'let ret=dict[''lines per map grid'']',
		\'getDef': 'let arg=45',
		\'check': 'let arg=str2nr(arg)|let msg=arg>0? 0 : ''Lines per map grid must be > 0''',
		\'save': 1,
		\'apply': 'let dict[''lines per map grid'']=arg|call s:getMapDis()'},
	\'map cell width': {'doc': 'Display width of map column',
		\'loadk': 'let ret=dict[''map cell width'']',
		\'getDef': 'let arg=5',
		\'check': 'let arg=str2nr(arg)|let msg=arg>2? 0 : ''Map cell width must be > 2''',
		\'save': 1,
		\'onInit': 'let t:mapw=dict["map cell width"]',
		\'apply': 'let dict[''map cell width'']=arg|let t:mapw=arg|call s:getMapDis()'},
	\'split width': {'doc': 'Default split width (for appended splits, (c)hange for prompt to resize current splits)',
		\'loadk': 'let ret=dict[''split width'']',
		\'getDef': 'let arg=60',
		\'check': "let arg=str2nr(arg)|let msg=arg>2? 0 : 'Default split width must be > 2'",
		\'save': 1,
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
		\'save': 1,
		\'apply':'let dict[''writefile'']=arg'},
	\'working dir': {'doc': 'Directory assumed when loading splits with relative paths',
		\'loadk': 'let ret=dict["working dir"]',
		\'getDef': 'let arg=fnamemodify(getcwd(),":p")',
		\'check': "let [msg, arg]=isdirectory(arg)? [0,fnamemodify(arg,':p')] : ['Not a valid directory',arg]",
		\'onInit': 'let t:cwd="cd ".fnameescape(dict["working dir"])',
		\'save': 1,
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
							\exe t:cwd\n
							\call map(t:txb.name,'fnamemodify(v:val,'':p'')')\n
						\en\n
						\let dict['working dir']=arg\n
						\let t:cwd='cd '.fnameescape(arg)\n
						\exe t:cwd\n
						\let t:bufs=map(copy(t:txb.name),'bufnr(fnamemodify(v:val,'':p''),1)')\n
						\exe 'cd' fnameescape(curwd)\n
						\let msg='(Working dir changed)'\n
					\en\n
				\en\n
			\en"}}
let arg=exists('TXBMPS') && type(TXBMPS)==3 && TXBMPS[0]==0? TXBMPS : [0,1,2,4,7,10,15,21,24,27,30]
exe s:option['mouse pan speed'].apply

fun! s:settingsPager(dict,entry,attr)
	let applyCmd="if empty(arg)\n
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
	let case={68: "if !has_key(disp,key) || !has_key(a:attr[key],'getDef')\n
				\let msg='No default defined for this value'\n
			\else\n
				\unlet! arg\n
				\exe a:attr[key].getDef\n".applyCmd,
		\85: "if !has_key(disp,key) || !has_key(undo,key)\n
				\let msg='No undo defined for this value'\n
			\else\n
				\unlet! arg\n
				\let arg=undo[key]\n".applyCmd,
		\99: "if has_key(disp,key)\n
				\unlet! arg\n
				\exe get(a:attr[key],'getInput','let arg=input(''Enter new value: '',type(disp[key])==1? disp[key] : string(disp[key]))')\n".applyCmd,
		\113: "let continue=0",
		\27:  "let continue=0",
		\106: 'let s:spCursor+=1',
		\107: 'let s:spCursor-=1',
		\103: 'let s:spCursor=0',
		\71:  'let s:spCursor=entries-1'}
	call extend(case,{13:case.99,10:case.99})
	let dict=a:dict
	let entries=len(a:entry)
	let [chsav,&ch]=[&ch,entries+3>11? 11 : entries+3]
	let s:spCursor=!exists('s:spCursor')? 0 : s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
	let s:spOff=!exists('s:spOff')? 0 : s:spOff<0? 0 : s:spOff>entries-&ch? (entries-&ch>=0? entries-&ch : 0) : s:spOff
	let s:spOff=s:spOff<s:spCursor-&ch? s:spCursor-&ch : s:spOff>s:spCursor? s:spCursor : s:spOff
	let undo={}
	let disp={}
	for key in filter(copy(a:entry),'has_key(a:attr,v:val)')
		unlet! ret
		exe a:attr[key].loadk
		let disp[key]=ret
	endfor
	let [helpw,contentw]=&co>120? [60,60] : [&co/2,&co/2-1]
	let pad=repeat(' ',contentw)
	let msg=0
	let continue=1
	let settingshelp='jkgG:dn,up,top,bot (c)hange (U)ndo (D)efault (q)uit'
	let errlines=[]
	let doclines=s:formatPar(settingshelp,helpw)
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
				echon line[:&co-2]
			en
			echohl
		endfor
		let key=a:entry[s:spCursor]
		let validkey=1
		exe get(case,getchar(),'let validkey=0')
		let s:spCursor=s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
		let s:spOff=s:spOff<s:spCursor-&ch+1? s:spCursor-&ch+1 : s:spOff>s:spCursor? s:spCursor : s:spOff
		let errlines=msg is 0? [] : s:formatPar(msg,helpw)
		let doclines=errlines+s:formatPar(validkey? get(get(a:attr,a:entry[s:spCursor],{}),'doc',settingshelp) : settingshelp,helpw)
	endwhile
	let &ch=chsav
	redr
	echo
endfun

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
"mouse    leftdown leftdrag leftup  scrollup scrolldn
"xterm    32                35      96       97
"xterm2   32       64       35      96       97
"sgr      0M       32M      0m      64       65
"msStat   1        2        3       4        5         else 0
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
	let doff=a:0? a:1 : t:txb.size[sp]>&co? 0 : -(&co-t:txb.size[sp])/2
	let dsp=sp
	while doff<0
		let dsp=dsp>0? dsp-1 : t:txbL-1
		let doff+=t:txb.size[dsp-1]+1
	endwhile
	while doff>t:txb.size[dsp]
		let doff-=t:txb.size[dsp]+1
		let dsp=dsp>=t:txbL-1? 0 : dsp+1
	endwhile
	exe 'only|b'.t:bufs[dsp]
	let w:txbi=dsp
	if a:0
		exe 'norm! '.dln.(doff>0? 'zt0'.doff.'zl' : 'zt0')
		call s:redraw()
	else
		exe 'norm! 0'.(doff>0? doff.'zl' : '')
		call s:redraw()
		exe ((sp-getwinvar(1,'txbi')+1+t:txbL)%t:txbL).'wincmd w'
		let dif=line('w0')-(dln>winheight(0)/2? dln-winheight(0)/2 : 1)
		exe dif>0? 'norm! '.dif."\<c-y>".dln.'G' : dif<0? 'norm! '.-dif."\<c-e>".dln.'G' : dln
	en
	if t:jhist[t:jhist[0]][0]==sp && abs(t:jhist[t:jhist[0]][1]-dln)<23
	elseif t:jhist[0]<len(t:jhist)-1 && t:jhist[t:jhist[0]+1][0]==sp && abs(t:jhist[t:jhist[0]+1][1]-dln)<23
		let t:jhist[0]+=1
	else 
		call insert(t:jhist,[sp,dln],t:jhist[0]+1)
		let t:jhist[0]+=1
	en
endfun

let s:badSync=v:version<704 || v:version==704 && !has('patch131')
fun! s:redraw(...)
	if exists('w:txbi') && t:bufs[w:txbi]==bufnr('')
	elseif exists('w:txbi')
		exe 'b' t:bufs[w:txbi]
	elseif index(t:bufs,bufnr(''))==-1
		exe 'only|b' t:bufs[0]
		let w:txbi=0
	else
		let w:txbi=index(t:bufs,bufnr(''))
	en
	let win0=winnr()
	let pos=[bufnr(''),line('w0'),line('.'), virtcol('.')]
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
		let remain=&co-(split0>0? split0+1+t:txb.size[w:txbi] : min([winwidth(1),t:txb.size[w:txbi]]) )
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
		let remain=&co-max([2,t:txb.size[w:txbi]-offset])
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
			exe 'to vert sb' t:bufs[colt]
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
			exe 'bo vert sb' t:bufs[nextcol]
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
		exe 'b' t:bufs[ccol]
		let w:txbi=ccol
		exe t:txb.exe[ccol]
		if a:0
			let changedsplits[ccol]=1
			let t:txb.depth[ccol]=line('$')
			let t:txb.map[ccol]={}
			norm! 1G0
			let searchPat='^'.t:txb.settings['label marker'].'\zs'
			let line=search(searchPat,'Wc')
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
				let line=search(searchPat,'W')
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

fun! s:nav(N,L)
	let ei=&ei
	se ei=WinEnter,WinLeave,BufEnter,BufLeave
	let cBf=bufnr('')
	let cVc=virtcol('.')
	let cL0=line('w0')
	let cL=line('.')
	let align='norm! '.cL0.'zt'
	let resync=0
	let extrashift=0
	if a:N<0
		let N=-a:N
		if N<&co
			while winwidth(winnr('$'))<=N
				winc b
				let extrashift=(winwidth(0)==N)
				hide
			endw
		else
			winc t
			only
		en
		if winwidth(0)!=&co
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
			se nowfw scrollopt=jump
			while winwidth(0)>=t:txb.size[w:txbi]+2
				let nextcol=w:txbi? w:txbi-1 : t:txbL-1
				exe 'to' winwidth(0)-t:txb.size[w:txbi]-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if !&scb
				elseif line('$')<cL0
					let resync=1
				else
					exe align
				en
				winc l
				se wfw
				norm! 0
				winc t
			endwhile
			se wfw scrollopt=ver,jump
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
				exe 'b' t:bufs[tcol]
				let w:txbi=tcol
				exe t:txb.exe[tcol]
				if &scb
					if line('$')<cL0
						let resync=1
					else
						exe align
					en
				en
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&co-1
					let spaceremaining=&co-t:txb.size[tcol]+loff
					let nextcol=(tcol+1)%t:txbL
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bo' spaceremaining-1 'vsp|b' t:bufs[nextcol]
						let w:txbi=nextcol
						exe t:txb.exe[nextcol]
						if &scb
							if line('$')<cL0
								let resync=1
							elseif !resync
								exe align
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
		let loff=winwidth(1)==&co? (&wrap? (t:txb.size[tcol]>&co? t:txb.size[tcol]-&co+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0)
		let N=a:N
		let botalreadysized=0
		if N>=&co
			let loff=winwidth(1)==&co? loff+&co : winwidth(winnr('$'))
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%t:txbL
			en
			let toshift=N-&co
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
			exe 'b' t:bufs[tcol]
			let w:txbi=tcol
			exe t:txb.exe[tcol]
			if &scb
				if line('$')<cL0
					let resync=1
				else
					exe align
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
					let &ei=ei
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
		if ww1!=&co
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
				exe 'bo' winwidth(0)-t:txb.size[w:txbi]-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let resync=1
					elseif !resync
						exe align
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
		elseif &co-t:txb.size[tcol]+loff>=2
			let spaceremaining=&co-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let nextcol=(w:txbi+1)%t:txbL
				exe 'bo' spaceremaining-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let resync=1
					elseif !resync
						exe align
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
	if resync
		if s:badSync
			windo 1
		en
		silent exe "norm! :syncbind\<cr>"
	en
	exe cL
	let dif=line('w0')-a:L
	exe dif>0? 'norm! '.dif."\<c-y>" : dif<0? 'norm! '.-dif."\<c-e>" : ''
	let &ei=ei
	return extrashift
endfun

fun! s:getMapDis(...)
	let poscell=repeat(' ',t:mapw)
	let negcell=repeat('.',t:mapw)
	let gran=t:txb.settings["lines per map grid"]
	if !a:0
		let t:bgd=map(range(0,max(t:txb.depth)+gran,gran),'join(map(range(t:txbL),v:val.''>t:txb.depth[v:val]? "'.negcell.'" : "'.poscell.'"''),'''')')
		let t:deepR=len(t:bgd)-1
		let t:disTxt=copy(t:bgd)
		let t:disClr=eval('['.join(repeat(['[""]'],t:deepR+1),',').']')
		let t:disIx=eval('['.join(repeat(['[98989]'],t:deepR+1),',').']')
		let t:gridClr=eval('['.join(repeat(['{}'],t:txbL),',').']')
		let t:gridLbl=deepcopy(t:gridClr)
		let t:gridPos=deepcopy(t:gridClr)
		let t:oldDepth=copy(t:txb.depth)
	en
	let newR={}
	for sp in a:0? a:1 : range(t:txbL)
		let newD=t:txb.depth[sp]/gran
		while newD>len(t:bgd)-1
			call add(t:bgd,repeat('.',t:txbL*t:mapw))
			call add(t:disIx,[98989])
			call add(t:disClr,[''])
			call add(t:disTxt,'')
			let newR[len(t:bgd)-1]=1
		endwhile
		let i=t:oldDepth[sp]/gran
		let colIx=sp*t:mapw
		while i>newD
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].negcell.t:bgd[i][colIx+t:mapw :] : negcell.t:bgd[i][colIx+t:mapw :]
			let newR[i]=1
			let i-=1
		endwhile
		while i<=newD
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].poscell.t:bgd[i][colIx+t:mapw :] : poscell.t:bgd[i][colIx+t:mapw :]
			let newR[i]=1
			let i+=1
		endwhile
		let t:oldDepth[sp]=t:txb.depth[sp]
		let conflicts={}
		let splitLbl={}
		let splitClr={}
		let splitPos={}
		for j in keys(t:txb.map[sp])
			let r=j/gran
			if has_key(splitLbl,r)
				if has_key(conflicts,r)
				elseif splitLbl[r][0][0]=='!'
					let conflicts[r]=[splitLbl[r][0],splitPos[r][0]]
					let splitPos[r]=[]
				else
					let conflicts[r]=['$',0]
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
		call extend(newR,changed,'keep')
		let t:gridLbl[sp]=splitLbl
		let t:gridClr[sp]=splitClr
		let t:gridPos[sp]=splitPos
	endfor
	let t:deepR=len(t:bgd)-1
	for i in keys(newR)
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

fun! s:ecMap()
	let xe=s:mCoff+&co-2
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
endfun

fun! s:mapKeyHandler(c)
	if a:c != -1
		exe get(s:mCase,a:c,'let mapmes=" (0..9) count (f1) help (hjklyubn) move (HJKLYUBN) pan (c)enter (g)o (q)uit (z)oom (p)revious (P)Next"')
		if s:mExit==1
			call s:ecMap()
			ec (s:mC.'-'.s:mR*t:txb.settings['lines per map grid'].(s:mCount is '01'? '' : ' '.s:mCount).(exists('mapmes')? mapmes : ''))[:&co-2]
			call feedkeys("\<plug>TxbY")
			return
		en
		let [&ch,&more,&ls,&stal]=s:mSavSettings
		return s:mExit==2 && s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:txb.settings['lines per map grid']])[0])
	elseif s:msStat[0]==2 && s:mPrevCoor[0] && s:mPrevCoor[0]<3
		let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
		let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
		call s:ecMap()
	elseif s:msStat[0]>3
		let s:mRoff+=4*(s:msStat[0]==5)-2
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		cal s:ecMap()
	elseif s:msStat[0]!=3
	elseif s:msStat==[3,1,1]
		let [&ch,&more,&ls,&stal]=s:mSavSettings
		return
	elseif s:mPrevCoor[0]!=1
	elseif &ttymouse=='xterm' && s:mPrevCoor[1:]!=s:msStat[1:]
		let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
		let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
		call s:ecMap()
	else
		let s:mR=s:msStat[2]-&lines+&ch-1+s:mRoff
		let s:mC=(s:msStat[1]-1+s:mCoff)/t:mapw
		let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR
		let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC
		if [s:mR,s:mC]==s:mPrevClk
			let [&ch,&more,&ls,&stal]=s:mSavSettings
			call s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:txb.settings['lines per map grid']])[0])
			return
		en
		let s:mPrevClk=[s:mR,s:mC]
		call s:ecMap()
		echon s:mC '-' s:mR*t:txb.settings['lines per map grid']
	en
	let s:mPrevCoor=copy(s:msStat)
	call feedkeys("\<plug>TxbY")
endfun

let s:mCase={"\e":"let s:mExit=0|redr",
	\"\<f1>":'exe g:txbCmd["\<f1>"]|ec mes|cal getchar()|redr!',
	\'q':"let s:mExit=0",
	\'h':"let s:mC=s:mC>s:mCount? s:mC-s:mCount : 0",
	\'l':"let s:mC=s:mC+s:mCount<t:txbL? s:mC+s:mCount : t:txbL-1",
	\'j':"let s:mR=s:mR+s:mCount<t:deepR? s:mR+s:mCount : t:deepR",
	\'k':"let s:mR=s:mR>s:mCount? s:mR-s:mCount : 0",
	\'H':"let s:mCoff=s:mCoff>s:mCount*t:mapw? s:mCoff-s:mCount*t:mapw : 0|let s:mCount='01'",
	\'L':"let s:mCoff=s:mCoff+s:mCount*t:mapw<t:mapw*t:txbL? s:mCoff+s:mCount*t:mapw : t:mapw*t:txbL-1|let s:mCount='01'",
	\'J':"let s:mRoff=s:mRoff+s:mCount<t:deepR? s:mRoff+s:mCount : t:deepR|let s:mCount='01'",
	\'K':"let s:mRoff=s:mRoff>s:mCount? s:mRoff-s:mCount : 0|let s:mCount='01'",
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
		\let s:mC=(s:mCoff+&co/2)/t:mapw\n
		\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mC=s:mC>=t:txbL? t:txbL-1 : s:mC",
	\'C':"let s:mRoff=s:mR-(&ch-2)/2\n
		\let s:mCoff=s:mC*t:mapw-&co/2",
	\'z':"call s:ecMap()\n
		\let input=str2nr(input('File lines per map line (>=10): ',t:txb.settings['lines per map grid']))\n
		\let width=str2nr(input('Width of map column (>=1): ',t:mapw))\n
		\if input<1 || width<1\n
			\echoerr 'Granularity, width must be > 0'\n
			\sleep 500m\n
			\redr!\n
		\elseif input!=t:txb.settings['lines per map grid'] || width!=t:mapw\n
			\let s:mR=s:mR*t:txb.settings['lines per map grid']/input\n
			\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
			\let t:txb.settings['lines per map grid']=input\n
			\let t:txb.settings['lines per map grid']=input\n
			\let t:mapw=width\n
			\let s:mCoff=s:mC*t:mapw>&co/2? s:mC*t:mapw-&co/2 : 0\n
			\call s:getMapDis()\n
			\let s:mPrevClk=[0,0]\n
			\redr!\n
		\en\n",
	\'g':'let s:mExit=2',
	\'p':"let t:jhist[0]=max([t:jhist[0]-s:mCount,1])\n
		\let [s:mC,s:mR]=[t:jhist[t:jhist[0]][0],t:jhist[t:jhist[0]][1]/t:txb.settings['lines per map grid']]\n
		\let mapmes=' '.t:jhist[0].'/'.(len(t:jhist)-1)\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mCount='01'",
	\'P':"let t:jhist[0]=min([t:jhist[0]+s:mCount,len(t:jhist)-1])\n
		\let [s:mC,s:mR]=[t:jhist[t:jhist[0]][0],t:jhist[t:jhist[0]][1]/t:txb.settings['lines per map grid']]\n
		\let mapmes=' '.t:jhist[0].'/'.(len(t:jhist)-1)\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mCount='01'"}
call extend(s:mCase,
	\{'y':s:mCase.h.'|'.s:mCase.k, 'u':s:mCase.l.'|'.s:mCase.k, 'b':s:mCase.h.'|'.s:mCase.j, 'n':s:mCase.l.'|'.s:mCase.j,
	\ 'Y':s:mCase.H.'|'.s:mCase.K, 'U':s:mCase.L.'|'.s:mCase.K, 'B':s:mCase.H.'|'.s:mCase.J, 'N':s:mCase.L.'|'.s:mCase.J})
for i in split('h j k l y u b n p P C')
	let s:mCase[i].="\nlet s:mCount='01'\n
		\let s:mCoff=s:mCoff>=s:mC*t:mapw? s:mC*t:mapw : s:mCoff<s:mC*t:mapw-&co+t:mapw? s:mC*t:mapw-&co+t:mapw : s:mCoff\n
		\let s:mRoff=s:mRoff<s:mR-&ch+2? s:mR-&ch+2 : s:mRoff>s:mR? s:mR : s:mRoff"
endfor
call extend(s:mCase,{"\<c-m>":s:mCase.g,"\<right>":s:mCase.l,"\<left>":s:mCase.h,"\<down>":s:mCase.j,"\<up>":s:mCase.k," ":s:mCase.J,"\<bs>":s:mCase.K})

let s:count='03'
fun! TxbKey(cmd)
	let g:TxbKeyHandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:cmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:txbCmd,a:c,'let mes="(0..9) count (f1) help (hjklyubn) move (r)edraw (M)ap all (o)pen map (A)ppend (D)elete (L)abel (S)ettings (W)rite settings (q)uit"')
	if mes is ' '
		echon '? ' w:txbi '.' line('.') ' ' str2nr(s:count) ' ' strtrans(a:c)
		call feedkeys("\<plug>TxbZ")
	elseif !empty(mes)
		redr|echon '# ' mes
	en
endfun

let txbCmd={'S':"let mes=''\ncall call('s:settingsPager',exists('w:txbi')? [t:txb.settings,['Global','hotkey','mouse pan speed','Plane','split width','autoexe','lines per map grid','map cell width','working dir','label marker','Split '.w:txbi,'current width','current autoexe','current file'],s:option] : [{},['Global','hotkey','mouse pan speed'],s:option])",
	\'o':"let mes=''\n
		\let s:mCount='01'\n
		\let s:mSavSettings=[&ch,&more,&ls,&stal]\n
			\let [&more,&ls,&stal]=[0,0,0]\n
			\let &ch=&lines\n
		\let s:mPrevClk=[0,0]\n
		\let s:mPrevCoor=[0,0,0]\n
		\let s:mR=line('.')/t:txb.settings['lines per map grid']\n
		\call s:redraw(1)\n
		\redr!\n
		\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mC=w:txbi\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mExit=1\n
		\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
		\let s:mCoff=s:mC*t:mapw>&co/2? s:mC*t:mapw-&co/2 : 0\n
		\call s:ecMap()\n
		\let g:TxbKeyHandler=function('s:mapKeyHandler')\n
		\if t:jhist[t:jhist[0]][0]==s:mC && abs(t:jhist[t:jhist[0]][1]-line('.'))<23\n
		\elseif t:jhist[0]<len(t:jhist)-1 && t:jhist[t:jhist[0]+1][0]==s:mC && abs(t:jhist[t:jhist[0]+1][1]-line('.'))<23\n
			\let t:jhist[0]+=1\n
		\else\n
			\call insert(t:jhist,[s:mC,line('.')],t:jhist[0]+1)\n
			\let t:jhist[0]+=1\n
		\en\n
		\call feedkeys(\"\\<plug>TxbY\")\n",
	\'M':"if 'y'==?input('? Entirely build map by scanning all files? (Map always partially updates on (o)pening and (r)edrawing) (y/n): ')\n
			\let curwin=exists('w:txbi')? w:txbi : 0\n
			\let view=winsaveview()\n
			\for i in map(range(t:txbL),'(curwin+v:val)%t:txbL')\n
				\exe 'b' t:bufs[i]\n
				\let t:txb.depth[i]=line('$')\n
				\let t:txb.map[i]={}\n
				\exe 'norm! 1G0'\n
				\let searchPat='^'.t:txb.settings['label marker'].'\\zs'\n
				\let line=search(searchPat,'Wc')\n
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
					\let line=search(searchPat,'W')\n
				\endwhile\n
			\endfor\n
			\exe 'b' t:bufs[curwin]\n
			\call winrestview(view)\n
			\call s:getMapDis()\n
			\call s:redraw()\n
			\let mes='Plane remapped'\n
		\else\n
			\let mes='Plane remap cancelled'\n
		\en",
	\"\<f1>":"let warnings=(v:version<=703? '\n# Vim 7.4 is recommended.': '')
		\.(v:version<703 || v:version==703 && !has('patch30')?  '\n# Vim < 7.3.30: Plane can''t be automatically backed up in viminfo; use hotkey W instead.'
		\: empty(&vi) || stridx(&vi,'!')==-1? '\n# Put '':set viminfo+=!'' in your .vimrc file to remember plane between sessions (or write to file with hotkey W)' : '')
		\.(has('gui_running')? '\n# In gVim, auto-redrawing on resize is disabled because resizing occurs too frequently in gVim. Use hotkey r or '':call TxbKey(''r'')'' instead' : '')
		\.(has('gui_running') || !(has('unix') || has('vms'))? '\n# gVim and non-unix terminals do not support mouse in map mode'
		\: &ttymouse!=?'xterm2' && &ttymouse!=?'sgr'? '\n# '':set ttymouse=xterm2'' or ''sgr'' allows mouse panning in map mode.' : '')\n
		\let warnings=(empty(warnings)? 'WARNINGS       (none)' : 'WARNINGS '.warnings).'\n\nTIPS\n# Note the '': '' when both label anchor and title are supplied.\n
		\# The map is updated on hotkey o, r, or M. On update, displaced labels are reanchored by inserting or removing preceding blank lines. Anchoring failures are highlighted in the map.\n
		\# :call TxbKey(''S'') to access settings if the hotkey becomes inaccessible.\n
		\# When a title starts with ''!'' (eg, ''txb:321: !Title'') it will be shown instead of other labels occupying the same cell.\n
		\# Keyboard-free navigation: in normal mode, dragging to the top left corner opens the map and clicking the top left corner of the map closes it. (ttymouse=sgr or xterm2 only)\n
		\# Initializing a plane while the cursor is in a file in the plane will restore plane to that location.\n
		\# Label highlighting:\n:syntax match Title +^txb\\S*: \\zs.[^#\\n]*+ oneline display'\n
		\let commands='microViche 1.8.4.2 6/2014          HOTKEY        '.g:TXB_HOTKEY.'\n\n
		\HOTKEY COMMANDS                    MAP COMMANDS (hotkey o)\n
		\hjklyubn Pan (takes count)         hjklyubn      Move (takes count)\n
		\r / M    Redraw visible / all      HJKLYUBN      Pan (takes count)\n
		\A / D    Append / Delete split     g <cr> 2click Go\n
		\S / W    Settings / Write to file  click / drag  Select / pan\n
		\o        Open map                  z             Zoom\n
		\L        Label                     c / C         Center cursor / view\n
		\<f1>     Help                      <f1>          Help\n
		\q <esc>  Quit                      q <esc>       Quit\n
		\                                   p / P         Prev / next jump\n\n
		\LABEL marker(anchor)(:)( title)(#highlght)(#comment)\n
		\txb:345 bla bla            Anchor only\ntxb:345: Title#Visual      Anchor, title, color\n
		\txb: Title                 Title only\ntxb: Title##bla bla        Title only'\n
		\if &co>71+45\n
			\let blanks=repeat(' ',71)\n
			\let col1=s:formatPar(commands,71,1)\n
			\let col2=s:formatPar(warnings,&co-71-3>71? 71 : &co-71-3)\n
			\let mes='\n'.join(map(range(len(col1)>len(col2)? len(col1) : len(col2)),\"get(col1,v:val,blanks).get(col2,v:val,'')\"),'\n')\n
		\else\n
			\let mes='\n'.commands.'\n\n'.warnings\n
		\en",
	\'q':"let mes='  '",
	\-1:"let mes=''",
	\'null':'let mes=" "',
	\'h':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0'))|redrawstatus!",
	\'j':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(0,line('w0')+s:count)|redrawstatus!",
	\'k':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(0,line('w0')-s:count)|redrawstatus!",
	\'l':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0'))|redrawstatus!",
	\'y':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0')-s:count)|redrawstatus!",
	\'u':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0')-s:count)|redrawstatus!",
	\'b':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0')+s:count)|redrawstatus!",
	\'n':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0')+s:count)|redrawstatus!",
	\1:"let mes=' '|let s:count=s:count[0] is '0'? 1   : s:count.'1'",
	\2:"let mes=' '|let s:count=s:count[0] is '0'? 2   : s:count.'2'",
	\3:"let mes=' '|let s:count=s:count[0] is '0'? 3   : s:count.'3'",
	\4:"let mes=' '|let s:count=s:count[0] is '0'? 4   : s:count.'4'",
	\5:"let mes=' '|let s:count=s:count[0] is '0'? 5   : s:count.'5'",
	\6:"let mes=' '|let s:count=s:count[0] is '0'? 6   : s:count.'6'",
	\7:"let mes=' '|let s:count=s:count[0] is '0'? 7   : s:count.'7'",
	\8:"let mes=' '|let s:count=s:count[0] is '0'? 8   : s:count.'8'",
	\9:"let mes=' '|let s:count=s:count[0] is '0'? 9   : s:count.'9'",
	\0:"let mes=' '|let s:count=s:count[0] is '0'? '01': s:count.'0'",
	\'L':"let L=getline('.')\n
		\let mes='Labeled'\n
		\if -1==match(L,'^'.t:txb.settings['label autotext'])\n
			\let prefix=t:txb.settings['label autotext'].line('.').' '\n
			\call setline(line('.'),prefix.L)\n
			\call cursor(line('.'),len(prefix))\n
			\startinsert\n
		\elseif setline(line('.'),substitute(L,'^'.t:txb.settings['label autotext'].'\\zs\\d*\\ze',line('.'),''))\nen",
	\'D':"redr\n
		\if t:txbL==1\n
			\let mes='Cannot delete last split!'\n
		\elseif input('Really delete current column (y/n)? ')==?'y'\n
			\call remove(t:txb.name,w:txbi)\n
			\call remove(t:bufs,w:txbi)\n
			\call remove(t:txb.size,w:txbi)\n
			\call remove(t:txb.exe,w:txbi)\n
			\call remove(t:txb.map,w:txbi)\n
			\call remove(t:gridLbl,w:txbi)\n
			\call remove(t:txb.depth,w:txbi)\n
			\call remove(t:oldDepth,w:txbi)\n
			\call remove(t:gridClr,w:txbi)\n
			\call remove(t:gridPos,w:txbi)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:getMapDis()\n
			\winc W\n
			\let cpos=[line('.'),virtcol('.'),w:txbi]\n
			\call s:redraw()\n
			\let mes='Split deleted'\n
		\en\n
		\call s:setCursor(cpos[0],cpos[1],cpos[2])",
	\'A':"let cpos=[line('.'),virtcol('.'),w:txbi]\n
		\exe t:cwd\n
		\let file=input('(Use full path if not in working directory '.t:txb.settings['working dir'].')\nAppend file (do not escape spaces) : ',t:txb.name[w:txbi],'file')\n
		\if empty(file)\n
			\let mes='Cancelled'\n
		\else\n
			\let mes='[' . file . (index(t:txb.name,file)==-1? '] appended.' : '] (duplicate) appended.')\n
			\call insert(t:txb.name,file,w:txbi+1)\n
			\call insert(t:bufs,bufnr(fnamemodify(file,':p'),1),w:txbi+1)\n
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
		\cd -\n
		\call s:setCursor(cpos[0],cpos[1],cpos[2])",
	\'W':"exe t:cwd\n
		\let input=input('? Write plane to file (relative to '.t:txb.settings['working dir'].'): ',t:txb.settings.writefile,'file')\n
		\let [t:txb.settings.writefile,mes]=empty(input)? [t:txb.settings.writefile,'File write aborted'] : [input,writefile(['let TXB='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TxbInit(TXB)'],input)? 'Error: File not writable' : 'File written, '':source '.input.''' to restore']\n
		\cd -",
	\'r':"call s:redraw(1)|redr|let mes='Redraw complete'"}
call extend(txbCmd,{"\<right>":txbCmd.l,"\<left>":txbCmd.h,"\<down>":txbCmd.j,"\<up>":txbCmd.k,"\e":txbCmd.q})
