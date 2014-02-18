"Hosted at https://github.com/q335r49/textabyss
if &compatible|se nocompatible|en "[Do not change] Enable vim features, sets ttymouse

"User options
nn <silent> <f10> :if exists('t:txb')\|call TXBdoCmd('ini')\|else\|call <SID>initPlane()\|en<cr>
                                   "Load plane, activate keyboard commands
let s:hotkeyName='<f10>'           "String for help files
let s:sgridL=15                    "Lines panned with jk
let s:bgridS=3                     "Splits panned with HL
let s:bgridL=45                    "Lines panned with JK, also map grid height
let s:panSpeedMultiplier=2         "Mouse panning speed, only works when ttymouse is xterm2 or sgr
let s:mgridH=2                     "Map block display lines
let s:mgridW=5                     "Map block display columns
hi! link TXBmapSel Visual          "Highlight color for map cursor on label
hi! link TXBmapSelEmpty Search     "Highlight color for map cursor on empty grid
let s:pansteph=9                   "Keyboard panning animation step horizontal
let s:panstepv=2                   "Keyboard panning animation step vertical

"Changed internal settings:        Used for:
se noequalalways                  "[Do not change] For correct panning
se winwidth=1                     "[Do not change] For correct panning
se winminwidth=0                  "[Do not change] For correct panning
se sidescroll=1                   "For smoother panning
se nostartofline                  "Keeps cursor in the same position when panning
se mouse=a                        "Enables mouse
se lazyredraw                     "For less redraws
se virtualedit=all                "Makes leftmost split aligns correctly
se hidden                         "Suppress error messages when a modified buffer panns offscreen

nn <silent> <leftmouse> :exe get(TXBmsCmd,&ttymouse,TXBmsCmd.default)()<cr>
let TXBmsCmd={}
let TXBkyCmd={}
fun! s:printHelp()
	let helpmsg="\n\n\n\\CWelcome to Textabyss v1.6!
	\\n\\Cgithub.com/q335r49/textabyss
	\\n\nPress ".s:hotkeyName." to start. You will be prompted for a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single file and use ".s:hotkeyName."A to append additional splits.\n
	\\nOnce loaded, use the mouse to pan or press ".s:hotkeyName." followed by:
	\\n\n    hjklyubn    pan 1 split x ".s:sgridL." line grids
	\\n    HJKLYUBN    pan ".s:bgridS." splits x ".s:bgridL." line grids
	\\n    o           Open map (map grid: 1 split x ".s:bgridL." lines)
	\\n    r           Redraw
	\\n    .           Snap to the current big grid
	\\n    D A E       Delete split / Append split / Edit split settings
	\\n    <f1>        Show this message
	\\n    q <esc>     Abort
	\\n    ^X          Delete hidden buffers
	\\n\n\\CSettings
	\\n\nIf dragging the mouse doesn't pan, try ':set ttymouse=sgr' or ':set ttymouse=xterm2'. Most other modes should work but the panning speed multiplier will be disabled. 'xterm' does not report dragging and will disable mouse panning entirely.\n
	\\nSetting your viminfo to save global variables (:set viminfo+=!) is recommended as the plane will be suggested on ".s:hotkeyName." the next time you run vim. This will also save the map. You can also manually restore via ':let BACKUP=t:txb' and ':call TXBload(BACKUP)'.\n
	\\nKeyboard commands can be accessed via the TXBdoCmd(key) function in order to integrate textabyss into your workflow. For example 'nmap <2-leftmouse> :call TXBdoCmd(\"o\")<cr>' will activate the map with a double-click.
	\\n\n\\CPotential Problems
	\\n\nEnsuring a consistent starting directory is important because relative names are remembered (use ':cd ~/PlaneDir' to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.\n
	\\nRegarding scrollbinding splits of uneven lengths -- I've tried to smooth this over but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding about 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.
	\\n\nHorizontal splits aren't supported and may interfere with panning.
	\\n\n\\CRecent Changes
	\\n\n1.5.8     In house pager function to avoid terminates in vim's pager
	\\n1.5.7     Eliminate random cursor jitter during panning
	\\n1.5.6     Eliminate jitter in default panning
	\\n1.5.5     Main nav function now preserves cursor position
	\\n1.5.4     Removed grid corners commands, removed need to define hotkeyraw
	\\n1.5.3     Cursor during mouse panning should be more stable"
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	call s:pager(s:formatPar(helpmsg,width,(&columns-width)/2))
endfun

let TXB_PREVPAT=exists('TXB_PREVPAT')? TXB_PREVPAT : ''

fun! s:initDragXterm() "Placeholder; xterm not supported
	return "norm! \<leftmouse>"
endfun
let TXBmsCmd.xterm=function("s:initDragXterm")

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! s:initDragDefault()
	if exists('t:txb')
		call s:saveCursPos()
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			return "keepj norm! \<leftmouse>"
		else
			while c!="\<leftrelease>"
				if v:mouse_win!=w0
					let w0=v:mouse_win
					exe "norm! \<leftmouse>"
					if !exists('t:txb')
						return ''
					en
					let [b0,wrap]=[winbufnr(0),&wrap]
					let [x,y,offset,ix]=wrap? [wincol(),line('w0')+winline(),0,get(t:txb.ix,bufname(b0),-1)] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol(),get(t:txb.ix,bufname(b0),-1)]
					let s0=t:txb.ix[bufname(winbufnr(1))]|let ecstr=join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL))
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
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec join(t:txb.gridnames[s0 : s0+winnr('$')-1]).' _ '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL))
		call s:updateCursPos()
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
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:bgridL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')
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
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:bgridL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.sgr=function("s:initDragSGR")

fun! s:initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists("t:txb")
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:bgridL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')
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
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:bgridL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.xterm2=function("s:initDragXterm2")

let s:panstep=[0,1,2,4,8,16]
fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? s:panSpeedMultiplier*get(s:panstep,a:dy,16)."\<c-y>" : a:dy<0? s:panSpeedMultiplier*get(s:panstep,-a:dy,16)."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -s:panSpeedMultiplier*get(s:panstep,a:dx,16) : s:panSpeedMultiplier*get(s:panstep,-a:dx,16))
	let l0=max([1,a:dy>0? s:nav_state[0]-s:panSpeedMultiplier*get(s:panstep,a:dy,16) : s:nav_state[0]+s:panSpeedMultiplier*get(s:panstep,-a:dy,16)])
	exe 'norm! '.l0.'zt'
	exe 'norm! '.(s:nav_state[1]<line('w0')? 'H' : line('w$')<s:nav_state[1]? 'L' : s:nav_state[1].'G')
	let s:nav_state=[l0,line('.'),t:txb.ix[bufname('')],s:nav_state[2],s:nav_state[3]!=s:nav_state[2]? t:txb.gridnames[s:nav_state[2]].s:nav_state[1]/s:bgridL.get(get(t:txb.map,s:nav_state[2],[]),s:nav_state[1]/s:bgridL,'') : s:nav_state[4]]
    echon s:nav_state[4]
endfun

fun! s:getGridNames(len)
	let alpha=map(range(65,90),'nr2char(v:val)')
	let powers=[26,676,17576]
	let array1=map(range(powers[0]),'alpha[v:val%26]')
	if a:len<=powers[0]
		return array1
	elseif a:len<=powers[0]+powers[1]
		return extend(array1,map(range(a:len-powers[0]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
   	else
		call extend(array1,map(range(powers[1]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
		return extend(array1,map(range(a:len-len(array1)),'alpha[v:val/powers[1]%26].alpha[v:val/powers[0]%26].alpha[v:val%26]'))
	en
endfun

let TXBkyCmd.o='let s:cmdS__continue=0|cal s:navMap(t:txb.map,t:txb.ix[expand("%")],line(".")/s:bgridL)'
let s:pad=repeat(' ',300)
fun! s:getMapDisp()          
	let s:disp__r=s:ms__cols*s:mgridW+1
	let l=s:disp__r*s:mgridH
	let templist=repeat([''],s:mgridH)
	let last_entry_colored=copy(templist)
	let s:disp__selmap=map(range(s:ms__rows),'repeat([0],s:ms__cols)')
	let dispLines=[]
	let s:disp__color=[]
	let s:disp__colorv=[]
	let extend_color='call extend(s:disp__color,'.join(map(templist,'"colorix[".v:key."]"'),'+').')'
	let extend_colorv='call extend(s:disp__colorv,'.join(map(templist,'"colorvix[".v:key."]"'),'+').')'
	let let_colorix='let colorix=['.join(map(templist,'"[]"'),',').']'
	let let_colorvix=let_colorix[:8].'v'.let_colorix[9:]
	let let_occ='let occ=['.repeat("'',",s:mgridH)[:-2].']'
	for i in range(s:ms__rows)
		exe let_occ
		exe let_colorix
		exe let_colorvix
		for j in range(s:ms__cols)
			if !exists("s:ms__array[s:ms__coff+j][s:ms__roff+i]") || empty(s:ms__array[s:ms__coff+j][s:ms__roff+i])
				let s:disp__selmap[i][j]=[i*l+j*s:mgridW,0]
				continue
			en
			let k=0
			let cell_border=(j+1)*s:mgridW
			while k<s:mgridH && len(occ[k])>=cell_border
				let k+=1
			endw
			let parsed=split(s:ms__array[s:ms__coff+j][s:ms__roff+i],'#')
			if k==s:mgridH
				let k=min(map(templist,'len(occ[v:key])*30+v:key'))%30
				if last_entry_colored[k]
	                let colorix[k][-1]-=len(occ[k])-(cell_border-1)
				en
				let occ[k]=occ[k][:cell_border-2].parsed[0]
				let s:disp__selmap[i][j]=[i*l+k*s:disp__r+cell_border-1,len(parsed[0])]
			else
				let [s:disp__selmap[i][j],occ[k]]=len(occ[k])<j*s:mgridW? [[i*l+k*s:disp__r+j*s:mgridW,1],occ[k].s:pad[:j*s:mgridW-len(occ[k])-1].parsed[0]] : [[i*l+k*s:disp__r+j*s:mgridW+(len(occ[k])%s:mgridW),1],occ[k].parsed[0]]
			en
			if len(parsed)>1
				call extend(colorix[k],[s:disp__selmap[i][j][0],s:disp__selmap[i][j][0]+len(parsed[0])])
				call extend(colorvix[k],['echoh NONE','echoh '.parsed[1]])
				let last_entry_colored[k]=1
			else
				let last_entry_colored[k]=0
			en
		endfor
		exe extend_color
		exe extend_colorv
		let dispLines+=map(occ,'len(v:val)<s:ms__cols*s:mgridW? v:val.s:pad[:s:ms__cols*s:mgridW-len(v:val)-1]."\n" : v:val[:s:ms__cols*s:mgridW-1]."\n"')
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
		let endmark=sel+s:mgridW
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
	echon get(t:txb.gridnames,s:ms__c,'--') s:ms__r s:ms__msg
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
		let len=s:mgridW
		echohl TXBmapSelEmpty
		echon s:disp__str[i : i+len-1]
	en
	echohl NONE
	echon s:disp__str[i+len :] get(t:txb.gridnames,s:ms__c,'--') s:ms__r s:ms__msg
	let s:ms__msg=''
endfun

fun! s:navMapKeyHandler(c)
	if a:c is -1
		if g:TXBmsmsg[0]==1
			let s:ms__prevcoord=copy(g:TXBmsmsg)
		elseif g:TXBmsmsg[0]==2
			if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
        		let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/s:mgridH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/s:mgridW]),0]
				let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
				call s:getMapDisp()
				call s:ms__displayfunc()
			en
			let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%s:mgridW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%s:mgridH]
		elseif g:TXBmsmsg[0]==3
			if g:TXBmsmsg==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:ms__settings
				return
			elseif s:ms__prevcoord[0]==1
				if &ttymouse=='xterm' && s:ms__prevcoord[1]!=g:TXBmsmsg[1] && s:ms__prevcoord[2]!=g:TXBmsmsg[2] 
					if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
						let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/s:mgridH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/s:mgridW]),0]
						let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
						call s:getMapDisp()
						call s:ms__displayfunc()
					en
					let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%s:mgridW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%s:mgridH]
				else
					let s:ms__r=(g:TXBmsmsg[2]-&lines+&ch-1)/s:mgridH+s:ms__roff
					let s:ms__c=(g:TXBmsmsg[1]-1)/s:mgridW+s:ms__coff
					if [s:ms__r,s:ms__c]==s:ms__prevclick
						let [&ch,&more,&ls,&stal]=s:ms__settings
						call s:doSyntax(s:gotoPos(s:ms__c,s:bgridL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#'),2,''))
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
			call s:doSyntax(s:gotoPos(s:ms__c,s:bgridL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#'),2,''))
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
	let com={'s':0,'r':0,'R':0,'j':0,'k':0,'l':0,'C':0,'M':0}
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
	exe 'norm! '.(com.j>com.k? (com.j-com.k).'j' : com.j<com.k? (com.k-com.j).'k' : '').(com.l>winwidth(0)? 'g$' : com.l? com.l .'l' : '').(com.M>0? 'zz' : com.r>com.R? (com.r-com.R)."\<c-e>" : com.r<com.R? (com.R-com.r)."\<c-y>" : 'g')
	if com.C
	   call s:nav(wincol()-&columns/2)
	elseif com.s
		call s:nav(-min([eval(join(map(range(s:ms__c-1,s:ms__c-com.s,-1),'1+t:txb.size[(v:val+t:txb.len)%t:txb.len]'),'+')),&columns-wincol()]))
	en
endfun

fun! s:navMap(array,c_ini,r_ini)
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
	let s:ms__rows=(&ch-1)/s:mgridH
	let s:ms__cols=(&columns-1)/s:mgridW
	let s:ms__roff=max([s:ms__r-s:ms__rows/2,0])
	let s:ms__coff=max([s:ms__c-s:ms__cols/2,0])
	let s:ms__displayfunc=function('s:printMapDisp')
   	call s:getMapDisp()
	call s:ms__displayfunc()
	let g:TXBkeyhandler=function("s:navMapKeyHandler")
	call feedkeys("\<plug>TxbY")
endfun
let s:mapdict={"\e":"let s:ms__continue=0|redr",
\"\<f1>":'let width=&columns>80? min([&columns-10,80]) : &columns-2|cal s:pager(s:formatPar("\n\n\\CMap Help\n\nKeyboard: (Each map grid is 1 split x ".s:bgridL." lines)
\\n\n    hjklyubn                  move 1 block
\\n    HJKLYUBN                  move 3 blocks
\\n    x p                       Cut label / Put label
\\n    c i                       Change label
\\n    g <cr>                    Goto block (and exit map)
\\n    I D                       Insert / delete column
\\n    z                         Adjust map block size
\\n    T                         Toggle color
\\n    q                         Quit
\\n\nMouse:
\\n\n    doubleclick               Goto block
\\n    drag                      Pan
\\n    click at topleft corner   Quit
\\n    drag to topleft corner    Show map
\\n\nMouse clicks are associated with the very first letter of the label, so it might be helpful to prepend a marker, eg, ''+ Chapter 1'', so you can aim your mouse at the ''+''. To facilitate navigating with the mouse only, the map can be activated with a mouse drag that ends at the top left corner; it can be closed by a click at the top left corner.
\\n\nMouse commands only work when ttymouse is set to xterm2 or sgr. When ttymouse is xterm, a limited set of features will work.
\\n\n\\CAdvanced - Map Label Syntax
\\n\nSyntax is provided for map labels in order to (1) color labels and (2) allow for additional positioning after jumping to the target block. Syntax hints will can also optionally be shown during the change label input (''c'' or ''i''). The ''#'' character is reserved to designated syntax regions and, unfortunately, can never be used in the label itself.
\\n\nColoring:
\\n\nColor a label via the syntax ''label_text#highlightgroup''. For example, ''^ Danger!#WarningMsg'' should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the ''T'' command.
\\n\nPositioning:
\\n\nBy default, jumping to the target grid will put the cursor at the top left corner and the split as the leftmost split. The commands following the second ''#'' character can change this. To shift the view but skip highlighting use two ''#'' characters. For example, ''^ Danger!##CM'' will [C]enter the cursor horizontally and put it in the [M]iddle of the screen. The full command list is:
\\n\n    jkl    Move the cursor as in vim 
\\n    s      Shift view left 1 split
\\n    r      Shift view down 1 row (1 line)
\\n    R      Shift view up 1 Row (1 line)
\\n    C      Shift view so that cursor is Centered horizontally
\\n    M      Shift view so that cursor is at the vertical Middle of the screen
\\n\nThese commands work much like normal mode commands. For example, ''^ Danger!#WarningMsg#sjjj'' or ''^ Danger!#WarningMsg#s3j'' will both shift the view left by one split and move the cursor down 3 lines. The order of the commands does not matter.
\\n\nShifting the view horizontally will never cause the cursor to move offscreen. For example, ''45s'' will not actually pan left 45 splits but only enough to push the cursor right edge."
\,width,(&columns-width)/2))',
\"q":"let s:ms__continue=0",
\"l":"let s:ms__c+=1",
\"ll":"let s:ms__c+=2",
\"lll":"let s:ms__c+=3",
\"h":"let s:ms__c=max([s:ms__c-1,0])",
\"hh":"let s:ms__c=max([s:ms__c-2,0])",
\"hhh":"let s:ms__c=max([s:ms__c-3,0])",
\"j":"let s:ms__r+=1",
\"jj":"let s:ms__r+=2",
\"jjj":"let s:ms__r+=3",
\"k":"let s:ms__r=max([s:ms__r-1,0])",
\"kk":"let s:ms__r=max([s:ms__r-2,0])",
\"kkk":"let s:ms__r=max([s:ms__r-3,0])",
\"L":"let s:ms__c+=3",
\"LL":"let s:ms__c+=6",
\"LLL":"let s:ms__c+=9",
\"H":"let s:ms__c=max([s:ms__c-3,0])",
\"HH":"let s:ms__c=max([s:ms__c-6,0])",
\"HHH":"let s:ms__c=max([s:ms__c-9,0])",
\"J":"let s:ms__r+=3",
\"JJ":"let s:ms__r+=6",
\"JJJ":"let s:ms__r+=9",
\"K":"let s:ms__r=max([s:ms__r-3,0])",
\"KK":"let s:ms__r=max([s:ms__r-6,0])",
\"KKK":"let s:ms__r=max([s:ms__r-9,0])",
\"T":"let s:ms__displayfunc=s:ms__displayfunc==function('s:printMapDisp')? function('s:printMapDispNoHL') : function('s:printMapDisp')",
\"y":"let [s:ms__r,s:ms__c]=[max([s:ms__r-1,0]),max([s:ms__c-1,0])]",
\"u":"let [s:ms__r,s:ms__c]=[max([s:ms__r-1,0]),s:ms__c+1]",
\"b":"let [s:ms__r,s:ms__c]=[s:ms__r+1,max([s:ms__c-1,0])]",
\"n":"let [s:ms__r,s:ms__c]=[s:ms__r+1,s:ms__c+1]",
\"Y":"let [s:ms__r,s:ms__c]=[max([s:ms__r-3,0]),max([s:ms__c-3,0])]",
\"U":"let [s:ms__r,s:ms__c]=[max([s:ms__r-3,0]),s:ms__c+3]",
\"B":"let [s:ms__r,s:ms__c]=[s:ms__r+3,max([s:ms__c-3,0])]",
\"N":"let [s:ms__r,s:ms__c]=[s:ms__r+3,s:ms__c+3]",
\"x":"if exists('s:ms__array[s:ms__c][s:ms__r]')|let @\"=s:ms__array[s:ms__c][s:ms__r]|let s:ms__array[s:ms__c][s:ms__r]=''|let s:ms__redr=1|en",
\"p":"if s:ms__c>=len(s:ms__array)\n
	\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
\en\n
\if s:ms__r>=len(s:ms__array[s:ms__c])\n
	\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
\en\n
\let s:ms__array[s:ms__c][s:ms__r]=@\"\n
\let s:ms__redr=1\n",
\"c":"let input=input((s:disp__str).\"\nChange: \",exists('s:ms__array[s:ms__c][s:ms__r]')? s:ms__array[s:ms__c][s:ms__r] : '')\n
\if !empty(input)\n
 	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\if s:ms__r>=len(s:ms__array[s:ms__c])\n
		\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
	\en\n
	\let s:ms__array[s:ms__c][s:ms__r]=strtrans(input)\n
	\let s:ms__redr=1\n
\en\n",
\"g":'let s:ms__continue=2',
\"z":'let s:mgridW=min([10,max([1,input(s:disp__str."\nBlock width (1-10): ",s:mgridW)])])|let s:mgridH=min([10,max([1,input("\nBlock height (1-10): ",s:mgridH)])])|let [s:ms__redr,s:ms__rows,s:ms__cols]=[1,(&ch-1)/s:mgridH,(&columns-1)/s:mgridW]',
\"I":'if s:ms__c<len(s:ms__array)|call insert(s:ms__array,[],s:ms__c)|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." inserted"|en',
\"D":'if s:ms__c<len(s:ms__array) && input(s:disp__str."\nReally delete column? (y/n)")==?"y"|call remove(s:ms__array,s:ms__c)|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." deleted"|en'}
let s:mapdict.i=s:mapdict.c
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBkyCmd["\<c-x>"]='cal s:deleteHiddenBuffers()|let [s:cmdS__msg,s:cmdS__continue]=["Hidden Buffers Deleted",0]'

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

fun! s:pager(list)
	let more=&more
	se nomore
	let [pos,next,bot,continue]=[-1,0,max([len(a:list)-&lines+1,0]),1]
	while continue
		if pos!=next
			let pos=next
			redr|echo join(a:list[pos : pos+&lines-1],"\n")."\nSPACE/d/j:down, b/u/k: up, g/G:top/bottom, q:quit"
		en
		exe get(s:pagercom,getchar(),'')
	endwhile
	redr
	let &more=more
endfun
let s:pagercom={113:'let continue=0',27:'let continue=0',
\32:'let next=pos+&lines/2<bot? pos+&lines/2 : bot',
\100:'let next=pos+&lines/2<bot? pos+&lines/2 : bot',
\106:'let next=pos<bot? pos+1 : pos',
\107:'let next=pos>0? pos-1 : pos',
\98:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\117:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\103:'let next=0',
\71:'let next=bot'}

fun! s:gotoPos(col,row)
	let name=get(t:txb.name,a:col,-1)
	if name==-1
		echoerr "Split ".a:col." does not exist."
		return 1
	elseif name!=#expand('%')
		wincmd t
		exe 'e '.escape(name,' ')
	en
	only
	call TXBload()
	exe 'norm!' (a:row? a:row : 1).'zt0'
endfun

fun! s:blockPan(dx,y,...)
	let cury=line('w0')
	let absolute_x=exists('a:1')? a:1 : 0
	let dir=absolute_x? absolute_x : a:dx
	let y=a:y>cury?  (a:y-cury-1)/s:sgridL+1 : a:y<cury? -(cury-a:y-1)/s:sgridL-1 : 0
   	let update_ydest=y>=0? 'let y_dest=!y? cury : cury/'.s:sgridL.'*'.s:sgridL.'+'.s:sgridL : 'let y_dest=!y? cury : cury>'.s:sgridL.'? (cury-1)/'.s:sgridL.'*'.s:sgridL.' : 1'
	let pan_y=(y>=0? 'let cury=cury+'.s:panstepv.'<y_dest? cury+'.s:panstepv.' : y_dest' : 'let cury=cury-'.s:panstepv.'>y_dest? cury-'.s:panstepv.' : y_dest')."\n
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
			while winwidth(1)>s:pansteph
				call s:nav(s:pansteph)
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
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i<a:dx
		endwhile
	elseif dir<0
		let i=0
		let continue=!map([t:txb.ix[bufname(winbufnr(1))]],'absolute_x && v:val==a:dx && winwidth(1)>=t:txb.size[v:val]')[0]
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			let ix=t:txb.ix[bufname(buf0)]
			if winwidth(1)>=t:txb.size[ix]
				call s:nav(-4)
				let buf0=winbufnr(1)
			en
			while winwidth(1)<t:txb.size[ix]-s:pansteph
				call s:nav(-s:pansteph)
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
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i>a:dx
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
let s:Y1='let s:cmdS__y=s:cmdS__y/s:sgridL*s:sgridL+s:sgridL|'
let s:Ym1='let s:cmdS__y=max([1,s:cmdS__y/s:sgridL*s:sgridL-s:sgridL])|'
	let TXBkyCmd.h='cal s:blockPan(-1,s:cmdS__y)'
	let TXBkyCmd.j=s:Y1.'cal s:blockPan(0,s:cmdS__y)'
	let TXBkyCmd.k=s:Ym1.'cal s:blockPan(0,s:cmdS__y)'
	let TXBkyCmd.l='cal s:blockPan(1,s:cmdS__y)'
	let TXBkyCmd.y=s:Ym1.'cal s:blockPan(-1,s:cmdS__y)'
	let TXBkyCmd.u=s:Ym1.'cal s:blockPan(1,s:cmdS__y)'
	let TXBkyCmd.b =s:Y1.'cal s:blockPan(-1,s:cmdS__y)'
	let TXBkyCmd.n=s:Y1.'cal s:blockPan(1,s:cmdS__y)'
let s:DXm1='map([t:txb.ix[bufname(winbufnr(1))]],"winwidth(1)<=t:txb.size[v:val]? (v:val==0? t:txb.len-t:txb.len%s:bgridS : (v:val-1)-(v:val-1)%s:bgridS) : v:val-v:val%s:bgridS")[0]'
let s:DX1='map([t:txb.ix[bufname(winbufnr(1))]],"v:val>=t:txb.len-t:txb.len%s:bgridS? 0 : v:val-v:val%s:bgridS+s:bgridS")[0]'
let s:Y1='let s:cmdS__y=s:cmdS__y/s:bgridL*s:bgridL+s:bgridL|'
let s:Ym1='let s:cmdS__y=max([1,s:cmdS__y%s:bgridL? s:cmdS__y-s:cmdS__y%s:bgridL : s:cmdS__y-s:cmdS__y%s:bgridL-s:bgridL])|'
	let TXBkyCmd.H='cal s:blockPan('.s:DXm1.',s:cmdS__y,-1)'
	let TXBkyCmd.J=s:Y1.'cal s:blockPan(0,s:cmdS__y)'
	let TXBkyCmd.K=s:Ym1.'cal s:blockPan(0,s:cmdS__y)'
	let TXBkyCmd.L='cal s:blockPan('.s:DX1.',s:cmdS__y,1)'
	let TXBkyCmd.Y=s:Ym1.'cal s:blockPan('.s:DXm1.',s:cmdS__y,-1)'
	let TXBkyCmd.U=s:Ym1.'cal s:blockPan('.s:DX1.',s:cmdS__y,1)'
	let TXBkyCmd.B=s:Y1.'cal s:blockPan('.s:DXm1.',s:cmdS__y,-1)'
	let TXBkyCmd.N=s:Y1.'cal s:blockPan('.s:DX1.',s:cmdS__y,1)'
unlet s:DX1 s:DXm1 s:Y1 s:Ym1

fun! s:snapToGrid()
	let [ix,l0]=[t:txb.ix[expand('%')],line('.')]
 	let [x,dir]=winnr()>ix%s:bgridS+1? [ix-ix%s:bgridS,1] : winnr()==ix%s:bgridS+1 && t:txb.size[ix-ix%s:bgridS]<=winwidth(1)? [0,0] : [ix-ix%s:bgridS,-1]
	call s:blockPan(x,l0-l0%s:bgridL,dir)
endfun
	let TXBkyCmd['.']='call s:snapToGrid()|let s:cmdS__continue=0'

nmap <silent> <plug>TxbY<esc>[ :call <SID>getmouse()<cr>
nmap <silent> <plug>TxbY :call <SID>getchar()<cr>
nmap <silent> <plug>TxbZ :call <SID>getchar()<cr>
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
		let g:TXBmsmsg=[str2nr(g:TXBmsmsg[0]).g:TXBmsmsg[2][len(g:TXBmsmsg[2])-1],str2nr(g:TXBmsmsg[1]),str2nr(g:TXBmsmsg[2])]
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
   	let s:cmdS__y=line('w0')
	let s:cmdS__continue=1
	let s:cmdS__msg=''
	call s:saveCursPos()
	let g:TXBkeyhandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:inicmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:TXBkyCmd,a:c,'let s:cmdS__msg="Press f1 for help"')
	call s:updateCursPos()
	if s:cmdS__continue
		let s0=get(t:txb.ix,bufname(''),-1)
		let t_r=line('.')/s:bgridL
		echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')
		call feedkeys("\<plug>TxbZ") 
	elseif !empty(s:cmdS__msg)
		ec s:cmdS__msg
	en
endfun

let TXBkyCmd[-1]='let s:cmdS__continue=0|call feedkeys("\<leftmouse>")'
let TXBkyCmd.ini=""
let TXBkyCmd.D="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb.ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call TXBdeleteCol(ix)\n
		\wincmd W\n
		\call TXBload(t:txb)\n
		\let s:cmdS__msg='col '.ix.' removed'\n
	\else\n
		\let s:cmdS__msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en\n
\let s:cmdS__continue=0"
let TXBkyCmd.A="let ix=get(t:txb.ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append : ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\let error=s:appendSplit(ix,file)\n
	\if empty(error)\n
		\try\n
			\call TXBload(t:txb)\n
			\let s:cmdS__msg='col '.(ix+1).' appended'\n
		\catch\n
			\call TXBdeleteCol(ix)\n
			\let s:cmdS__msg='Error detected while loading plane: file append aborted'\n
		\endtry\n
	\else\n
		\let s:cmdS__msg='Error: '.error\n
	\en\n
\else\n
	\let s:cmdS__msg='Current buffer not in plane'\n
\en\n
\let s:cmdS__continue=0"
let TXBkyCmd["\e"]="let s:cmdS__continue=0"
let TXBkyCmd.q="let s:cmdS__continue=0"
let TXBkyCmd.r="call TXBload(t:txb)|redr|let s:cmdS__msg='(redrawn)'|let s:cmdS__continue=0"
let TXBkyCmd["\<f1>"]='call s:printHelp()|let s:cmdS__continue=0'
let TXBkyCmd.E='call s:editSplitSettings()|let s:cmdS__continue=0'

fun! <SID>initPlane(...)                                          
	if &ttymouse==?"xterm"
		echoerr "Warning: ttymouse is set to 'xterm', which doesn't report mouse dragging. Try ':set ttymouse=xterm2' or ':set ttymouse=sgr'"
	elseif &ttymouse!=?"xterm2" && &ttymouse!=?"sgr"
   		echoerr "Warning: For better mouse panning performance, try ':set ttymouse=xterm2' or 'set ttymouse=sgr'. Your current setting is: ".&ttymouse
	en
	let preventry=a:0 && a:1 isnot 0? a:1 : exists("g:TXB") && type(g:TXB)==4? g:TXB : exists("g:TXB_PREVPAT")? g:TXB_PREVPAT : ''
	let plane=type(preventry)==1? s:makePlane(preventry) : type(preventry)==4? preventry : {'name':''}
	if !empty(plane.name)
		ec "\n" (a:0 && a:1 isnot 0? "This" : "Previous") (type(preventry)==4? "plane has:" : "pattern matches:")
		let curbufix=index(plane.name,expand('%'))
		ec join(map(copy(plane.name),'(curbufix==v:key? " -> " : "    ").v:val'),"\n")
		ec " ..." plane.len "files to be loaded in" (curbufix!=-1? "THIS tab" : "NEW tab")
		ec "(Press ENTER to load, ESC to try something else, or F1 for help)"
		let c=getchar()
	else
		let c=0
	en
	if c==13 || c==10
		if curbufix==-1 | tabe | en
		let [g:TXB,g:TXB_PREVPAT]=[plane,type(preventry)==1? preventry : g:TXB_PREVPAT]
		call TXBload(plane)
	elseif c is "\<f1>"
		call s:printHelp() 
	else
		let input=input("> Enter file pattern or type HELP: ", g:TXB_PREVPAT)
		if empty(input)
			redr|ec "(aborted)"
		elseif input==?'help'
			call s:printHelp()
		else
			call <SID>initPlane(input)
		en
	en
endfun

fun! s:editSplitSettings()
   	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input('Column width: ',t:txb.size[ix])
		if empty(input) | return | en
    	let t:txb.size[ix]=input
    	let input=input("Autoexecute on load: ",t:txb.exe[ix])
		if empty(input) | return | en
		let t:txb.exe[ix]=input
    	let input=input('Column position (0-'.(t:txb.len-1).'): ',ix)
		if empty(input) | return | en
		let newix=input
		if newix>=0 && newix<t:txb.len && newix!=ix
			let item=remove(t:txb.name,ix)
			call insert(t:txb.name,item,newix)
			let item=remove(t:txb.size,ix)
			call insert(t:txb.size,item,newix)
			let item=remove(t:txb.exe,ix)
			call insert(t:txb.exe,item,newix)
			let [t:txb.ix,i]=[{},0]
			for e in t:txb.name
				let [t:txb.ix[e],i]=[i,i+1]
			endfor
		en
		call TXBload(t:txb)
	en
endfun

fun! s:makePlane(name,...)
	let plane={}
	let plane.name=type(a:name)==1? map(split(glob(a:name)),'escape(v:val," ")') : type(a:name)==3? a:name : 'INV'
	if plane.name is 'INV'
     	throw 'First argument ('.string(a:name).') must be string (filepattern) or list (list of files)'
	else
		let plane.len=len(plane.name)
		let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
		let plane.exe=exists("a:2")? a:2 : repeat(['se scb cole=2 nowrap'],plane.len)
		let [plane.ix,i]=[{},0]
		let plane.map=[[]]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		let plane.gridnames=s:getGridNames(plane.len+50)
		return plane
	en
endfun

fun! s:appendSplit(index,file,...)
	if empty(a:file)
		return 'File name is empty'
	elseif has_key(t:txb.ix,a:file)
		return 'Duplicate entries not allowed'
	en
	call insert(t:txb.name,a:file,a:index+1)
	call insert(t:txb.size,exists('a:1')? a:1 : 60,a:index+1)
	call insert(t:txb.exe,'se nowrap scb cole=2',a:index+1)
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:getGridNames(t:txb.len+50)
	endif
endfun
fun! TXBdeleteCol(index)
	call remove(t:txb.name,a:index)	
	call remove(t:txb.size,a:index)	
	call remove(t:txb.exe,a:index)	
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
endfun

fun! TXBload(...)
	if a:0
		let t:txb=a:1
	elseif !exists("t:txb")
		ec "\n> No plane initialized..."
		call <SID>initPlane()
		return
	en
	let [col0,win0]=[get(t:txb.ix,bufname(""),a:0? -1 : -2),winnr()]
	if col0==-2
		ec "Current buffer not registered in in plane, use ".s:hotkeyName."A to add"
		return
	elseif col0==-1
		let col0=0
		only
		let name=t:txb.name[0]
		if name!=#expand('%')
			exe 'e '.escape(name,' ')
		en
	en
	let pos=[bufnr('%'),line('w0')]
	exe winnr()!=1? "norm! mt0" : "norm! mt"
	let alignmentcmd="norm! 0".pos[1]."zt"
	se scrollopt=jump
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0,0]
	let remain=split0
	while remain>=1
		let colt=(colt-1)%t:txb.len
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%t:txb.len,&columns-(split0>0? split0+1+t:txb.size[col0] : min([winwidth(1),t:txb.size[col0]])),1]
	while remain>=2
		let remain-=t:txb.size[colb]+1
		let colb=(colb+1)%t:txb.len
		let colsRight+=1
	endwhile
	let colbw=t:txb.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%t:txb.len
		for i in range(dif)
			let colt=(colt-1)%t:txb.len
			exe 'top vsp '.escape(t:txb.name[colt],' ')
			exe alignmentcmd
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
		let colb=(col0+colsRight-1-dif)%t:txb.len
		for i in range(dif)
			let colb=(colb+1)%t:txb.len
			exe 'bot vsp '.escape(t:txb.name[colb],' ')
			exe alignmentcmd
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
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txb.len]
		let k=t:txb.name[ccol]
		if expand('%:p')!=#fnamemodify(t:txb.name[ccol],":p")
			exe 'e' escape(t:txb.name[ccol],' ')
			exe alignmentcmd
			exe t:txb.exe[ccol]
		elseif a:0
			exe alignmentcmd
			exe t:txb.exe[ccol]
		en
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
	endtry
   	exe "norm!" bufwinnr(pos[0])."\<c-w>w".pos[1]."zt`t"
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:getGridNames(t:txb.len+50)
	en
endfun

fun! s:saveCursPos()
	let s:cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun
fun! s:updateCursPos()
	let win=bufwinnr(s:cPos[0])
	if win!=-1
		if winnr('$')==1 || win==1
			winc t
			let offset=virtcol('.')-wincol()+1
			let width=offset+winwidth(0)-3
			exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(s:cPos[2]<offset? offset : width<=s:cPos[2]? width : s:cPos[2]).'|'
		elseif win!=1
			exe win.'winc w'
			exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(s:cPos[2]>winwidth(win)? '0g$' : s:cPos[2].'|')
		en
	elseif t:txb.ix[bufname(s:cPos[0])]>t:txb.ix[bufname('')]
		winc b
		exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(winnr('$')==1? 'g$' : '0g$')
	else
		winc t
		exe "norm! ".(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').'g0'
	en
	let s:cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun

fun! s:nav(N)
	let c_bf=bufnr('')
	let c_vc=virtcol('.')
	let alignmentcmd='norm! '.line('w0').'zt'
	if a:N<0
		let N=-a:N
		let extrashift=0
		let tcol=t:txb.ix[bufname(winbufnr(1))]
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
				else
					exe 'vert res+'.(N+extrashift)
				en
				se wfw
			else
				exe 'vert res+'.(N+extrashift)
			en
			while winwidth(0)>=t:txb.size[tcol]+2
				se nowfw scrollopt=jump
				let nextcol=(tcol-1)%t:txb.len
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
					let tcol=(tcol-1)%t:txb.len
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
					let NextCol=(tcol+1)%len(t:txb.name)
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bot '.(spaceremaining-1).'vsp '.escape(t:txb.name[NextCol],' ')
						exe alignmentcmd
						exe t:txb.exe[NextCol]
						norm! 0
						let spaceremaining-=t:txb.size[NextCol]+1
						let NextCol=(NextCol+1)%len(t:txb.name)
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
		let tcol=t:txb.ix[bufname(winbufnr(1))]
		let [bcol,loff,extrashift,N]=[t:txb.ix[bufname(winbufnr(winnr('$')))],winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0),0,a:N]
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
				let tcol=(tcol+1)%len(t:txb.name)
			en
			let toshift=N-&columns
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%len(t:txb.name)
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%len(t:txb.name)
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%len(t:txb.name)
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%len(t:txb.name)
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
				let tcol=(tcol+1)%len(t:txb.name)
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
				let nextcol=(bcol+1)%len(t:txb.name)
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
				let bcol=(bcol+1)%len(t:txb.name)
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
