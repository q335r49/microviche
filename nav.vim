"Check www.vim.org/scripts/script.php?script_id=4835 for previous versions
"Global hotkey: press to begin.
	let s:hotkeyName='<f10>'
	let s:hotkeyRaw="\<f10>"
"Grid panning animation step
	let s:pansteph=9
	let s:panstepv=2
"Small grid: 1 split x s:sgridL lines
	let s:sgridL=15
"Big grid: s:bgridS splits x s:bgridL lines; Map grid: 1 split x s:bgridL lines
	let s:bgridS=3
	let s:bgridL=45
"Mouse panning speed (only works when &ttymouse==xterm2 or sgr)
	let s:panSpeedMultiplier=2
"Explanation of changed settings

	if &compatible|se nocompatible|en "Enable vim features, sets ttymouse [Do not change]
	se noequalalways                  "Needed for correct panning [Do not change]
	se winwidth=1                     "Needed for correct panning [Do not change]
	se winminwidth=0                  "Needed for correct panning [Do not change]
	se sidescroll=1                   "Needed for smooth panning
	se mouse=a                        "Enable mouse
	se lazyredraw                     "Less redraws
	se nostartofline                  "Prevents cursor from jumping to start of line when scrolling up and down
	se virtualedit=all                "Prevents for leftmost split from being drawn incorrectly
	se hidden                         "Suppresses error messages when modified buffer is panned offscreen


nn <silent> <leftmouse> :exe get(TXBmsCmd,&ttymouse,TXBmsCmd.default)()<cr>
exe 'nn <silent> '.s:hotkeyName.' :if exists("t:txb")\|call TXBdoCmd("ini")\|else\|call <SID>initPlane()\|en<cr>'
let TXBmsCmd={}
let TXBdoCmdExe={}
fun! s:printHelp()
	let helpmsg="\n\\CWelcome to Textabyss v1.3!\n
	\\nPress ".s:hotkeyName." to start. You will be prompted for a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single file and use ".s:hotkeyName."A to append additional splits.\n
	\\nOnce loaded, use the mouse to pan or press ".s:hotkeyName." followed by:
	\\nhjklyubn  - pan small grid  (1 split x ".s:sgridL." lines)
	\\nHJKLYUBN  - pan big grid    (".s:bgridS." splits x ".s:bgridL." lines)
	\\n^hjklyubn - Cursor to edges and corners of current big grid
	\\no         - Open map        (1 split x ".s:bgridL." lines)
	\\nr         - redraw
	\\n.         - Snap to the current big grid
	\\nD A E     - Delete split / Append split / Edit split settings
	\\n<f1>      - Show this message
	\\nq <esc>   - Abort
	\\n^X        - Delete hidden buffers (eg, if too many are loaded from panning)\n
	\\nIf dragging the mouse doesn't pan, try ':set ttymouse=sgr' or ':set ttymouse=xterm2'. Most other modes should work but the panning speed multiplier will be disabled. 'xterm' does not report dragging and will disable mouse panning entirely.\n
	\\nEnsuring a consistent starting directory is important because relative names are remembered (use ':cd ~/PlaneDir' to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.\n
	\\nSetting your viminfo to save global variables (:set viminfo+=!) is highly recommended as the plane will be suggested on ".s:hotkeyName." the next time you run vim. You can also manually restore via ':let BACKUP=t:txb' and ':call TXBload(BACKUP)'.\n
	\\nKeyboard commands can be accessed via the TXBdoCmd(key) in order to integrate textabyss into your workflow. For example 'nmap <2-leftmouse> :call TXBdoCmd(\"o\")<cr>' will activate the map with a double-click.\n
	\\nHorizontal splits aren't supported and may interfere with panning. \n\nPress enter to continue ... (or input 'm' for a monologue, 'c' for changelog)"
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	redr
	let input=input(s:formatPar(helpmsg,width,(&columns-width)/2))
	if input==?'m'
		let helpmsg="\n\n\\C~\n\\C\"... into the abyss he slipped
		\\n\\CEndless fathoms he fell
		\\n\\CNe'er in homely hearth to linger
		\\n\\CNor warm hand to grasp!\"\n\\C~\n
		\\n    In a time when memory capacity is growing exponentially, memory storage and retrieval, especially when it comes to prose, still seems quite undeveloped. It makes very little sense, to me, to have a massive hard drive when, in terms of text, actual production might be on the order of kilobytes per year. Depending on how prolific you are as a writer, you may have thousands or tens of thousands of pages in mysteriously named folders on old hard drives (say, since 5th grade). So the problem is one of organization, retreival, and accessibility rather than availability of space. There are various efforts in this regard, including desktop indexing and personal wikis. It might not even be a bad idea to simply print out and keep as a hard copy everything written over the course of a month.\n
		\\n    The textabyss is yet another solution to this problem. It presents a plane that one can append to endlessly with very little overhead. It provides means to navigate and, either at the moment of writing or retrospectively, map out. Ideally, you would be able to scan over the map and easily access writings from last night, a month ago, or even 5 to 10 years earlier. It presents some unique advantages over both indexing and hyperlinked or hierarchical organizing.\n
		\\n    A note about scrollbinding splits of uneven lengths -- I've tried to smooth over this process but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding, say, 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.\n
		\\n\\RThanks for trying out Textabyss!\n\n\\RLeon, q335r49@gmail.com"
		cal input(s:formatPar(helpmsg,width,(&columns-width)/2))
	elseif input==?'c'
		let helpmsg="\n
		\\n\\CRoadmap:
		\\n1.5    - Prettier formatting / syntax for map\n
		\\n\\CChangelog:
		\\n1.4.6  - added 'm' in map mode to toggle display
		\\n1.4.5  - map label display initial
		\\n1.4.4  - make sure xterm dragging doesn't interefere with clicking
		\\n1.4.3  - divide by zero bug in zoomlevel
		\\n1.4.2  - map drag for ttymouse=xterm
		\\n1.4.1  - Map panning speed matches zoom speed
		\\n1.4.0  - Mouse support for map
		\\n1.3.17 - Code refactor, reduce global var 'pollution'
		\\n1.3.16 - Minor bug with map-delete column not redrawing
		\\n1.3.15 - Removed outdated Edit Split message
		\\n1.3.14 - Cursor now responds as needed to ttymouse setting without reloading plane
		\\n1.3.13 - Prevent reloading of split (and subsequent error message if changed)
		\\n1.3.12 - Safer append column function (check for duplicate, bad file names)
		\\n1.3.11 - 'se hidden' to prevent error messages
		\\n1.3.10 - Support &ttymouse=sgr
		\\n1.3.9  - Allows drag splits to resize when not in plane
		\\n1.3.8  - File names can now contain spaces / message about consistent starting directory
		\\n1.3.7  - Grid system reworked & simplified, only small grids named
		\\n1.3.6  - Map now corresponds to single split, not big grid splits
		\\n1.3.5  - Monologue changed to focus on intention
		\\n1.3.4  - Help message added to map, map supports cut / paste
		\\n1.3.1  - Cursor remains visible during global hotkey. Known issue: bug in vim (fixed: 7.4.169) misdisplays cursor when using grid corner commands.
		\\n1.3.0  - When &ttymouse==xterm2, new mousepanning method that uses raw keycodes and allows for accelerated motions
		\\n1.2.8  - Snap to grid now snaps to the grid the cursor is currently in (and not the one that occupies the majority of the screen)
		\\n1.2.7  - Minor updates to grid corners
		\\n1.2.6  - Feature: Ctrl-YUBNHJKL jumps to grid corners
		\\n1.2.5  - Echo confirmation for various commands
		\\n1.2.5  - Curor won't move on panning. Clicking without dragging relocates cursor
		\\n1.2.4  - Minor bug with map when horizontal block size divides columns
		\\n1.2.3  - formatPar for help dialogs now has option to align right
		\\n1.2.2  - Minor bug where the rightmost split will overshift on PanRight\n"
		cal input(s:formatPar(helpmsg,width,(&columns-width)/2))
	en
endfun

let TXB_PREVPAT=exists('TXB_PREVPAT')? TXB_PREVPAT : ''

fun! s:initDragXterm() "Placeholder; not supported
	return "norm! \<leftmouse>"
endfun
let TXBmsCmd.xterm=function("s:initDragXterm")

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! s:initDragDefault()
	if exists('t:txb')
		let possav=[bufnr('%')]+getpos('.')[1:]
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			return "keepj norm! \<lt>leftmouse>"
		else
			while c!="\<leftrelease>"
				if v:mouse_win!=w0
					let w0=v:mouse_win
					exe "norm! \<leftmouse>"
					if !exists('t:txb')
						return
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
					let [x,xs]=x && nx? [x,nx>x? -s:PanLeft(nx-x) : s:PanRight(x-nx)] : [x? x : nx,0]
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
		call s:restoreCursPos(possav)
	else
		let possav=[bufnr('%')]+getpos('.')[1:]
		call feedkeys("\<leftmouse>")
		call getchar()
		exe v:mouse_win."wincmd w"
		if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
			if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
			return "keepj norm! \<lt>leftmouse>" | en
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
			return "keepj norm! \<lt>leftmouse>"
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
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=exists("t:txb")? function("s:navPlane") : function("s:panWin")
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:dragHandler=exists("t:txb")? function("s:navPlane") : function("s:panWin")
		nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
	en
	return ''
endfun
fun! <SID>doDragSGR()
	let code=[getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)]
	while getchar(0) isnot 0
	endwhile
	let k=map(split(join(map(code,'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
endfun
let TXBmsCmd.sgr=function("s:initDragSGR")

fun! s:initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=exists("t:txb")? function("s:navPlane") : function("s:panWin")
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:dragHandler=exists("t:txb")? function("s:navPlane") : function("s:panWin")
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! <SID>doDragXterm2()
	let k=[getchar(0),getchar(0),getchar(0)]
	while getchar(0) isnot 0
	endwhile
	if k[0]==35
		nunmap <esc>[M
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
endfun
let TXBmsCmd.xterm2=function("s:initDragXterm2")

let s:panstep=[0,1,2,4,8,16,16]
fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? s:panSpeedMultiplier*get(s:panstep,a:dy,16)."\<c-y>" : a:dy<0? s:panSpeedMultiplier*get(s:panstep,-a:dy,16)."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	let possav=s:saveCursPos()
	if a:dx>0
		call s:PanLeft(s:panSpeedMultiplier*get(s:panstep,a:dx,16))
	elseif a:dx<0
		call s:PanRight(s:panSpeedMultiplier*get(s:panstep,-a:dx,16))
	en
	exe "norm! ".(a:dy>0? s:panSpeedMultiplier*get(s:panstep,a:dy,16)."\<c-y>" : a:dy<0? s:panSpeedMultiplier*get(s:panstep,-a:dy,16)."\<c-e>" : 'g')
	call s:restoreCursPos(possav)
	let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL))
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

let s:bksizes=[0,[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9]]
let TXBdoCmdExe.o='let s:cmdS.continue=0|let grid=s:getMapGrid()|cal s:navMap(t:txb.map,grid[0],grid[1])'
let s:pad=repeat(' ',400)
fun! s:getMapDispCell(map,w,h,H)
	let [s,l]=[map(range(a:h),'[v:val*a:w,v:val*a:w+a:w-1]'),len(a:map)*a:w+1]
	return {'str':join(map(range(a:h*a:H),'join(map(map(range(len(a:map)),''len(a:map[v:val])>''.v:val/a:h.''? a:map[v:val][''.v:val/a:h.''] : "[NUL]"''),''v:val[s[''.v:val%a:h.''][0] : s[''.v:val%a:h.''][1]].s:pad[1:(s[''.v:val%a:h.''][1]>=len(v:val)? (s[''.v:val%a:h.''][0]>=len(v:val)? a:w : a:w-len(v:val)+s[''.v:val%a:h.''][0]) : 0)]''),'''')."\n"'),''),'hlmap':map(range(a:H),'map(range(len(a:map)),''map(range(a:h),"''.v:val.''*l*a:h+(a:w)*".v:val."+v:val*l")'')'),'w':(a:w)}
endfun
fun! s:getMapDispLabel(map,w,h,H)          
	let hlist_prototype=repeat([''],a:h)
	let mapl=len(a:map)
	let strarray=[]
	let l=len(a:map)*a:w+1
	for i in range(a:H)
		let occ=copy(hlist_prototype)
		for j in range(mapl)
			if !empty(a:map[j][i])
				let row=min(map(copy(hlist_prototype),'len(occ[v:key])*100+v:key'))
				let [val,ix]=[row/100,row%100]
				if val<j*a:w
					let occ[ix].=s:pad[:j*a:w-val-1].'+'.a:map[j][i]
				elseif val>=j*a:w+a:w
					let occ[ix]=occ[ix][:j*a:w+a:w-2].'+'.a:map[j][i]
				else
					let occ[ix].='+'.a:map[j][i]
				en
			en
		endfor
		let strarray+=map(occ,'len(v:val)<mapl*a:w? v:val.s:pad[:mapl*a:w-len(v:val)-1]."\n" : v:val[:mapl*a:w-1]."\n"')
	endfor
	return {'str':join(strarray,''),'hlmap':map(range(a:H),'map(range(len(a:map)),''map(range(a:h),"''.v:val.''*l*a:h+(a:w)*".v:val."+v:val*l")'')'),'w':(a:w)}
endfun
fun! s:printMapDisp(disp,r,c)
	let ticker=0
	for i in a:disp.hlmap[a:r][a:c]
		echon i? a:disp.str[ticker : i-1] : ''
		echohl visual
		let ticker=i+a:disp.w
		echon a:disp.str[i : ticker-1]
		echohl NONE
	endfor
	echon a:disp.str[ticker :]
endfun
fun! s:navMapKeyHandler(c)
	if a:c is -1
		if g:TXBmsmsg[0]==1
			let s:ms.prevcoord=copy(g:TXBmsmsg)
		elseif g:TXBmsmsg[0]==2
			if s:ms.prevcoord[1] && s:ms.prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
        		let [s:ms.roff,s:ms.coff,s:ms.redr]=[max([0,s:ms.roff-(g:TXBmsmsg[2]-s:ms.prevcoord[2])/t:txb.zoom]),max([0,s:ms.coff-(g:TXBmsmsg[1]-s:ms.prevcoord[1])/t:txb.zoom]),0]
				let [s:ms.r,s:ms.c]=[s:ms.r<s:ms.roff? s:ms.roff : s:ms.r>=s:ms.roff+s:ms.rows? s:ms.roff+s:ms.rows-1 : s:ms.r,s:ms.c<s:ms.coff? s:ms.coff : s:ms.c>=s:ms.coff+s:ms.cols? s:ms.coff+s:ms.cols-1 : s:ms.c]
				let s:ms.disp={t:txb.mapdisplaymode}(map(range(s:ms.coff,s:ms.coff+s:ms.cols-1),'map(range(s:ms.roff,s:ms.roff+s:ms.rows-1),"exists(\"s:ms.array[".v:val."][v:val]\")? s:ms.array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],s:ms.rows)
				redr!
				call s:printMapDisp(s:ms.disp,s:ms.r-s:ms.roff,s:ms.c-s:ms.coff)
				echon s:ms.pad.get(t:txb.gridnames,s:ms.c,'--').s:ms.r.s:ms.msg
				let s:ms.msg=''
			en
			let s:ms.prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms.prevcoord[1])%t:txb.zoom,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms.prevcoord[2])%t:txb.zoom]
		elseif g:TXBmsmsg[0]==3
			if g:TXBmsmsg==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:ms.settings
				return
			elseif s:ms.prevcoord[0]==1
				if &ttymouse=='xterm' && s:ms.prevcoord[1]!=g:TXBmsmsg[1] && s:ms.prevcoord[2]!=g:TXBmsmsg[2] 
					if s:ms.prevcoord[1] && s:ms.prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
						let [s:ms.roff,s:ms.coff,s:ms.redr]=[max([0,s:ms.roff-(g:TXBmsmsg[2]-s:ms.prevcoord[2])/t:txb.zoom]),max([0,s:ms.coff-(g:TXBmsmsg[1]-s:ms.prevcoord[1])/t:txb.zoom]),0]
						let [s:ms.r,s:ms.c]=[s:ms.r<s:ms.roff? s:ms.roff : s:ms.r>=s:ms.roff+s:ms.rows? s:ms.roff+s:ms.rows-1 : s:ms.r,s:ms.c<s:ms.coff? s:ms.coff : s:ms.c>=s:ms.coff+s:ms.cols? s:ms.coff+s:ms.cols-1 : s:ms.c]
						let s:ms.disp={t:txb.mapdisplaymode}(map(range(s:ms.coff,s:ms.coff+s:ms.cols-1),'map(range(s:ms.roff,s:ms.roff+s:ms.rows-1),"exists(\"s:ms.array[".v:val."][v:val]\")? s:ms.array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],s:ms.rows)
						redr!
						call s:printMapDisp(s:ms.disp,s:ms.r-s:ms.roff,s:ms.c-s:ms.coff)
						echon s:ms.pad.get(t:txb.gridnames,s:ms.c,'--').s:ms.r.s:ms.msg
						let s:ms.msg=''
					en
					let s:ms.prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms.prevcoord[1])%t:txb.zoom,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms.prevcoord[2])%t:txb.zoom]
				else
					let s:ms.r=(g:TXBmsmsg[2]-&lines+&ch-1)/s:bksizes[t:txb.zoom][0]+s:ms.roff
					let s:ms.c=(g:TXBmsmsg[1]-1)/s:bksizes[t:txb.zoom][1]+s:ms.coff
					if [s:ms.r,s:ms.c]==s:ms.prevclick
						let [&ch,&more,&ls,&stal]=s:ms.settings
						cal s:gotoPos(s:ms.c,s:bgridL*s:ms.r)
						return
					en
					let s:ms.prevclick=[s:ms.r,s:ms.c]
					let s:ms.prevcoord=[0,0,0]
					let [roffn,coffn]=[s:ms.r<s:ms.roff? s:ms.r : s:ms.r>=s:ms.roff+s:ms.rows? s:ms.r-s:ms.rows+1 : s:ms.roff,s:ms.c<s:ms.coff? s:ms.c : s:ms.c>=s:ms.coff+s:ms.cols? s:ms.c-s:ms.cols+1 : s:ms.coff]
					if [s:ms.roff,s:ms.coff]!=[roffn,coffn] || s:ms.redr
						let [s:ms.roff,s:ms.coff,s:ms.redr]=[roffn,coffn,0]
						let s:ms.disp=t:txb.mapdisplaymode(map(range(s:ms.coff,s:ms.coff+s:ms.cols-1),'map(range(s:ms.roff,s:ms.roff+s:ms.rows-1),"exists(\"s:ms.array[".v:val."][v:val]\")? s:ms.array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],s:ms.rows)
					en
					redr!
					call s:printMapDisp(s:ms.disp,s:ms.r-s:ms.roff,s:ms.c-s:ms.coff)
					echon (s:ms.pad).get(t:txb.gridnames,s:ms.c,'--').(s:ms.r).(s:ms.msg)
					let s:ms.msg=''
				en
			en
		en
		call <SID>getchar()
	else
		exe get(s:mapdict,a:c,'let s:ms.msg="   Press f1 for help or q to quit"')
		if s:ms.continue==1
			let [roffn,coffn]=[s:ms.r<s:ms.roff? s:ms.r : s:ms.r>=s:ms.roff+s:ms.rows? s:ms.r-s:ms.rows+1 : s:ms.roff,s:ms.c<s:ms.coff? s:ms.c : s:ms.c>=s:ms.coff+s:ms.cols? s:ms.c-s:ms.cols+1 : s:ms.coff]
			if [s:ms.roff,s:ms.coff]!=[roffn,coffn] || s:ms.redr
				let [s:ms.roff,s:ms.coff,s:ms.redr]=[roffn,coffn,0]
				let s:ms.disp={t:txb.mapdisplaymode}(map(range(s:ms.coff,s:ms.coff+s:ms.cols-1),'map(range(s:ms.roff,s:ms.roff+s:ms.rows-1),"exists(\"s:ms.array[".v:val."][v:val]\")? s:ms.array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],s:ms.rows)
			en
			redr!
			call s:printMapDisp(s:ms.disp,s:ms.r-s:ms.roff,s:ms.c-s:ms.coff)
			echon (s:ms.pad).get(t:txb.gridnames,s:ms.c,'--').(s:ms.r).(s:ms.msg)
			let s:ms.msg=''
			call <SID>getchar()
		elseif s:ms.continue==2
			let [&ch,&more,&ls,&stal]=s:ms.settings
			cal s:gotoPos(s:ms.c,s:bgridL*s:ms.r)
		else
			let [&ch,&more,&ls,&stal]=s:ms.settings
		en
	en
endfun
fun! s:navMap(array,c_ini,r_ini)
	let settings=[&ch,&more,&ls,&stal]
	let &ch=&lines
	let s:ms={'prevclick':[0,0],'prevcoord':[0,0,0],'array':(a:array),'settings':settings,'msg':'','r':(a:r_ini),'c':(a:c_ini),'rows':(&ch-1)/s:bksizes[t:txb.zoom][0],'cols':(&columns-1)/s:bksizes[t:txb.zoom][1],'pad':repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0]).' ','continue':1,'redr':1}
	let s:ms.roff=max([s:ms.r-s:ms.rows/2,0])
	let s:ms.coff=max([s:ms.c-s:ms.cols/2,0])
	let [&more,&ls,&stal]=[0,0,0]
   	let s:ms.disp={t:txb.mapdisplaymode}(map(range(s:ms.coff,s:ms.coff+s:ms.cols-1),'map(range(s:ms.roff,s:ms.roff+s:ms.rows-1),"exists(\"a:array[".v:val."][v:val]\")? a:array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],s:ms.rows)
	call s:printMapDisp(s:ms.disp,s:ms.r-s:ms.roff,s:ms.c-s:ms.coff)
	echon s:ms.pad.get(t:txb.gridnames,s:ms.c,'--').(s:ms.r).(s:ms.msg)
	let g:TXBkeyhandler=function("s:navMapKeyHandler")
	call <SID>getchar()
endfun
let s:mapdict={"\e":"let s:ms.continue=0|redr",
\"\<f1>":'let width=&columns>80? min([&columns-10,80]) : &columns-2|cal input(s:formatPar("\n\n\\CKeyboard:
\\nhjkl        Move cardinally
\\nyubn        Move diagonally
\\nx p         Cut block / Put block
\\nc i         Change block
\\ng <cr>      Goto block (and exit map)
\\n+ -         Increase / decrease block size
\\nI D         Insert / delete column
\\nm           Toggle display mode between cell / label
\\nq           Quit
\\n\\CMouse:
\\ndoubleclick             Goto block
\\ndrag                    Pan
\\ntop left corner click   Quit
\\n\n\\C(Press enter to continue)",width,(&columns-width)/2))',
\"j":"let s:ms.r+=1",
\"m":"let t:txb.mapdisplaymode=t:txb.mapdisplaymode==#'s:getMapDispLabel'? 's:getMapDispCell' : 's:getMapDispLabel'|let s:ms.redr=1",
\"q":"let s:ms.continue=0",
\"jj":"let s:ms.r+=2",
\"jjj":"let s:ms.r+=3",
\"k":"let s:ms.r=s:ms.r>0? s:ms.r-1 : s:ms.r",
\"kk":"let s:ms.r=s:ms.r>1? s:ms.r-2 : s:ms.r",
\"kkk":"let s:ms.r=s:ms.r>2? s:ms.r-3 : s:ms.r",
\"l":"let s:ms.c+=1",
\"ll":"let s:ms.c+=2",
\"lll":"let s:ms.c+=3",
\"h":"let s:ms.c=s:ms.c>0? s:ms.c-1 : s:ms.c",
\"hh":"let s:ms.c=s:ms.c>1? s:ms.c-2 : s:ms.c",
\"hhh":"let s:ms.c=s:ms.c>2? s:ms.c-3 : s:ms.c",
\"y":"let [s:ms.r,s:ms.c]=[s:ms.r>0? s:ms.r-1 : s:ms.r,s:ms.c>0? s:ms.c-1 : s:ms.c]",
\"u":"let [s:ms.r,s:ms.c]=[s:ms.r>0? s:ms.r-1 : s:ms.r,s:ms.c+1]",
\"b":"let [s:ms.r,s:ms.c]=[s:ms.r+1,s:ms.c>0? s:ms.c-1 : s:ms.c]",
\"n":"let [s:ms.r,s:ms.c]=[s:ms.r+1,s:ms.c+1]",
\"x":"if exists('s:ms.array[s:ms.c][s:ms.r]')|let @\"=s:ms.array[s:ms.c][s:ms.r]|let s:ms.array[s:ms.c][s:ms.r]=''|let s:ms.redr=1|en",
\"p":"if s:ms.c>=len(s:ms.array)\n
	\call extend(s:ms.array,eval('['.join(repeat(['[]'],s:ms.c+1-len(s:ms.array)),',').']'))\n
\en\n
\if s:ms.r>=len(s:ms.array[s:ms.c])\n
	\call extend(s:ms.array[s:ms.c],repeat([''],s:ms.r+1-len(s:ms.array[s:ms.c])))\n
\en\n
\let s:ms.array[s:ms.c][s:ms.r]=@\"\n
\let s:ms.redr=1\n",
\"c":"let input=input((s:ms.disp.str).\"\nChange: \",exists('s:ms.array[s:ms.c][s:ms.r]')? s:ms.array[s:ms.c][s:ms.r] : '')\n
\if !empty(input)\n
 	\if s:ms.c>=len(s:ms.array)\n
		\call extend(s:ms.array,eval('['.join(repeat(['[]'],s:ms.c+1-len(s:ms.array)),',').']'))\n
	\en\n
	\if s:ms.r>=len(s:ms.array[s:ms.c])\n
		\call extend(s:ms.array[s:ms.c],repeat([''],s:ms.r+1-len(s:ms.array[s:ms.c])))\n
	\en\n
	\let s:ms.array[s:ms.c][s:ms.r]=input\n
	\let s:ms.redr=1\n
\en\n",
\"g":'let s:ms.continue=2',
\"+":'let t:txb.zoom=min([t:txb.zoom+1,len(s:bksizes)-1])|let [s:ms.redr,s:ms.rows,s:ms.cols,s:ms.pad]=[1,(&ch-1)/s:bksizes[t:txb.zoom][0],(&columns-1)/s:bksizes[t:txb.zoom][1],repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0])." "]',
\"-":'let t:txb.zoom=max([t:txb.zoom-1,1])|let [s:ms.redr,s:ms.rows,s:ms.cols,s:ms.pad]=[1,(&ch-1)/s:bksizes[t:txb.zoom][0],(&columns-1)/s:bksizes[t:txb.zoom][1],repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0])." "]',
\"I":'if s:ms.c<len(s:ms.array)|call insert(s:ms.array,[],s:ms.c)|let s:ms.redr=1|let s:ms.msg=" Col ".(s:ms.c)." inserted"|en',
\"D":'if s:ms.c<len(s:ms.array) && input(s:ms.disp.str."\nReally delete column? (y/n)")==?"y"|call remove(s:ms.array,s:ms.c)|let s:ms.redr=1|let s:ms.msg=" Col ".(s:ms.c)." deleted"|en'}
let s:mapdict.i=s:mapdict.c
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBdoCmdExe["\<c-x>"]='cal s:deleteHiddenBuffers()|let [s:cmdS.msg,s:cmdS.continue]=["Hidden Buffers Deleted",0]'

fun! s:formatPar(str,w,pad)
	let [pars,pad,bigpad,spc]=[split(a:str,"\n",1),repeat(" ",a:pad),repeat(" ",a:w+10),repeat(' ',len(&brk))]
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
		let pars[k]=pad.join(map(range(len(seg)/2),format==#'C'? 'bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : format==#'R'? 'bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : 'pars[k][seg[2*v:val]:seg[2*v:val+1]]'),"\n".pad) 
	endfor
	return join(pars,"\n")
endfun

fun! s:gotoPos(col,row)
	wincmd t
	only
	let name=get(t:txb.name,a:col,t:txb.name[0])
	if name!=#expand('%')
		exe 'e '.escape(name,' ')
	en
	exe 'norm!' (a:row? a:row : 1).'zt'
	call TXBload()
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
				call s:PanRight(s:pansteph)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:PanRight(winwidth(1))
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
				call s:PanLeft(4)
				let buf0=winbufnr(1)
			en
			while winwidth(1)<t:txb.size[ix]-s:pansteph
				call s:PanLeft(s:pansteph)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:PanLeft(t:txb.size[ix]-winwidth(1))
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
let s:Y1='let s:cmdS.y=s:cmdS.y/s:sgridL*s:sgridL+s:sgridL|'
let s:Ym1='let s:cmdS.y=max([1,s:cmdS.y/s:sgridL*s:sgridL-s:sgridL])|'
	let TXBdoCmdExe.h='cal s:blockPan(-1,s:cmdS.y)'
	let TXBdoCmdExe.j=s:Y1.'cal s:blockPan(0,s:cmdS.y)'
	let TXBdoCmdExe.k=s:Ym1.'cal s:blockPan(0,s:cmdS.y)'
	let TXBdoCmdExe.l='cal s:blockPan(1,s:cmdS.y)'
	let TXBdoCmdExe.y=s:Ym1.'cal s:blockPan(-1,s:cmdS.y)'
	let TXBdoCmdExe.u=s:Ym1.'cal s:blockPan(1,s:cmdS.y)'
	let TXBdoCmdExe.b =s:Y1.'cal s:blockPan(-1,s:cmdS.y)'
	let TXBdoCmdExe.n=s:Y1.'cal s:blockPan(1,s:cmdS.y)'
let s:DXm1='map([t:txb.ix[bufname(winbufnr(1))]],"winwidth(1)<=t:txb.size[v:val]? (v:val==0? t:txb.len-t:txb.len%s:bgridS : (v:val-1)-(v:val-1)%s:bgridS) : v:val-v:val%s:bgridS")[0]'
let s:DX1='map([t:txb.ix[bufname(winbufnr(1))]],"v:val>=t:txb.len-t:txb.len%s:bgridS? 0 : v:val-v:val%s:bgridS+s:bgridS")[0]'
let s:Y1='let s:cmdS.y=s:cmdS.y/s:bgridL*s:bgridL+s:bgridL|'
let s:Ym1='let s:cmdS.y=max([1,s:cmdS.y%s:bgridL? s:cmdS.y-s:cmdS.y%s:bgridL : s:cmdS.y-s:cmdS.y%s:bgridL-s:bgridL])|'
	let TXBdoCmdExe.H='cal s:blockPan('.s:DXm1.',s:cmdS.y,-1)'
	let TXBdoCmdExe.J=s:Y1.'cal s:blockPan(0,s:cmdS.y)'
	let TXBdoCmdExe.K=s:Ym1.'cal s:blockPan(0,s:cmdS.y)'
	let TXBdoCmdExe.L='cal s:blockPan('.s:DX1.',s:cmdS.y,1)'
	let TXBdoCmdExe.Y=s:Ym1.'cal s:blockPan('.s:DXm1.',s:cmdS.y,-1)'
	let TXBdoCmdExe.U=s:Ym1.'cal s:blockPan('.s:DX1.',s:cmdS.y,1)'
	let TXBdoCmdExe.B=s:Y1.'cal s:blockPan('.s:DXm1.',s:cmdS.y,-1)'
	let TXBdoCmdExe.N=s:Y1.'cal s:blockPan('.s:DX1.',s:cmdS.y,1)'
unlet s:DX1 s:DXm1 s:Y1 s:Ym1

fun! s:gotoGridCorners(dx,dy)
	if a:dy<0
		let cursory=max([line('.')/s:bgridL*s:bgridL,1])
		let desty=min([cursory,line('w0')])
	elseif a:dy>0
		let cursory=line('.')/s:bgridL*s:bgridL+s:bgridL-1
		let desty=max([cursory-winheight(0),line('w0')])
	else
		let cursory=line('.')/s:bgridL*s:bgridL+s:bgridL/2
		let desty=cursory>=line('.')? max([cursory-winheight(0),line('w0')]) : min([cursory,line('w0')])
	en
	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1 | return 300 | en
	if a:dx<0
 		let destix=ix/s:bgridS*s:bgridS
		let eval='"norm! '.cursory.'G0"'
	elseif a:dx>0
		let destix=min([ix/s:bgridS*s:bgridS+s:bgridS-1,t:txb.len-1])
		let eval='"norm! '.cursory.'Gg$"'
	else
    	let destix=min([ix-ix%s:bgridS+s:bgridS/2,t:txb.len-1])
		let eval='"norm! '.cursory.'G".(winwidth(0)/2)."|"'
	en
	if destix<ix || destix==ix && winnr()==1
		if winnr()-ix+destix==1 && winwidth(1)<t:txb.size[destix]
		   	call s:blockPan(-1,desty)
		elseif winnr()<=ix-destix
			call s:blockPan(destix,desty,-1)
		en
	elseif destix>ix || destix==ix && winnr()==winnr('$')
   		while t:txb.ix[bufname(winbufnr(winnr('$')))]<destix
   			call s:PanRight(s:pansteph)
   		endwhile
		let win=bufwinnr(bufnr(t:txb.name[destix]))
   		exe win==-1? 'return 200' : win."wincmd w"
		if winnr()==winnr('$') && winwidth(0)<t:txb.size[destix]
			while t:txb.size[destix]-winwidth(winnr('$'))>s:pansteph
				call s:PanRight(s:pansteph)
			endwhile
			call s:PanRight(t:txb.size[destix]-winwidth(winnr('$')))
		en
		exe 'norm! '.desty.'zt'
	en
	let win=bufwinnr(bufnr(t:txb.name[destix]))
	exe win==-1? 'return 100' : win."wincmd w"
	exe eval(eval)
endfun
	let TXBdoCmdExe["\<c-y>"]='cal s:gotoGridCorners(-1,-1)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-u>"]='cal s:gotoGridCorners( 1,-1)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-b>"]='cal s:gotoGridCorners(-1, 1)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-n>"]='cal s:gotoGridCorners( 1, 1)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-h>"]='cal s:gotoGridCorners(-1, 0)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-l>"]='cal s:gotoGridCorners( 1, 0)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-j>"]='cal s:gotoGridCorners( 0, 1)|let s:cmdS.possav=s:saveCursPos()'
	let TXBdoCmdExe["\<c-k>"]='cal s:gotoGridCorners( 0,-1)|let s:cmdS.possav=s:saveCursPos()'

fun! s:getMapGrid()
	return [t:txb.ix[expand('%')],line('.')/s:bgridL]
endfun
fun! s:snapToCursorGrid()
	let [ix,l0]=[t:txb.ix[expand('%')],line('.')]
 	let [x,dir]=winnr()>ix%s:bgridS+1? [ix-ix%s:bgridS,1] : winnr()==ix%s:bgridS+1 && t:txb.size[ix-ix%s:bgridS]<=winwidth(1)? [0,0] : [ix-ix%s:bgridS,-1]
	"exe PRINT('ix|l0|x|dir')
	call s:blockPan(x,l0-l0%s:bgridL,dir)
endfun
	let TXBdoCmdExe['.']='let s:cmdS.possav=saveCursPos()|call s:snapToCursorGrid()|let s:cmdS.continue=0'
	let TXBdoCmdExe['.']='call s:snapToCursorGrid()|let s:cmdS.continue=0'

nmap <silent> <plug>TxbY<esc>[ :call <SID>dochar(-1)<cr>
nmap <silent> <plug>TxbY :call <SID>getchar()<cr>
nmap <silent> <plug>TxbZ :call <SID>getchar()<cr>
fun! <SID>getchar()
	if getchar(1) is 0
		sleep 1m
		call feedkeys("\<plug>TxbY")
	else
		call <SID>dochar(getchar())
	en
endfun
"mouse    leftdown leftdrag leftup
"xterm    32                35
"xterm2   32       64       35
"sgr      0M       32M      0m 
"TXBmsmsg 1        2        3            else 0
fun! <SID>dochar(c)
	if a:c==-1
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
	else
		let [k,c]=['',a:c]
		while c isnot 0
			let k.=type(c)==0? nr2char(c) : c
			let c=getchar(0)
		endwhile
		call g:TXBkeyhandler(k)
	en
endfun

fun! TXBdoCmd(...)
	if a:0
		let s:cmdS={'y':line('w0'),'continue':1,'msg':'','possav':(s:saveCursPos())}
		exe get(g:TXBdoCmdExe,a:1,'let s:cmdS.msg="Press f1 for help"')
		call s:restoreCursPos(s:cmdS.possav)
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(s:cmdS.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : s:cmdS.msg
	en
	if s:cmdS.continue
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(s:cmdS.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : s:cmdS.msg
		let s:cmdS.msg=''
		let g:TXBkeyhandler=function("s:doCmdKeyhandler")
		call feedkeys("\<plug>TxbZ") 
	en
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:TXBdoCmdExe,a:c,'let s:cmdS.msg="Press f1 for help"')
   	call s:restoreCursPos(s:cmdS.possav)
	if s:cmdS.continue
		call feedkeys(s:hotkeyRaw)
	else
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(s:cmdS.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).' _ '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : s:cmdS.msg
	en
endfun

let TXBdoCmdExe.ini=""
let TXBdoCmdExe.D="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb.ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call TXBdeleteCol(ix)\n
		\wincmd W\n
		\call TXBload(t:txb)\n
		\let s:cmdS.msg='col '.ix.' removed'\n
	\else\n
		\let s:cmdS.msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en\n
\let s:cmdS.continue=0"
let TXBdoCmdExe.A="let ix=get(t:txb.ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append : ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\let error=s:appendSplit(ix,file)\n
	\if empty(error)\n
		\try\n
			\call TXBload(t:txb)\n
			\let s:cmdS.msg='col '.(ix+1).' appended'\n
		\catch\n
			\call TXBdeleteCol(ix)\n
			\let s:cmdS.msg='Error detected while loading plane: file append aborted'\n
		\endtry\n
	\else\n
		\let s:cmdS.msg='Error: '.error\n
	\en\n
\else\n
	\let s:cmdS.msg='Current buffer not in plane'\n
\en\n
\let s:cmdS.continue=0"
let TXBdoCmdExe["\e"]="let s:cmdS.continue=0"
let TXBdoCmdExe.q="let s:cmdS.continue=0"
let TXBdoCmdExe.r="call TXBload(t:txb)|redr|let s:cmdS.msg='(redrawn)'|let s:cmdS.continue=0"
let TXBdoCmdExe["\<f1>"]='call s:printHelp()|let s:cmdS.continue=0'
let TXBdoCmdExe.E='call s:editSplitSettings()|let s:cmdS.continue=0'

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
		let plane.scrollopt='ver,jump'
		let plane.zoom=min([2,len(s:bksizes)])
		let plane.mapdisplaymode="s:getMapDispLabel"
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
		ec "> Current buffer not registered in in plane..."
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
	let &scrollopt=t:txb.scrollopt
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
	return [bufnr('%')]+getpos('.')[1:]
endfun
fun! s:restoreCursPos(possav)
	let win=bufwinnr(a:possav[0])
	if win==-1
		let ix=[get(t:txb.ix,bufname(a:possav[0]),-1),get(t:txb.ix,bufname(''),-1)]
		if ix[0]!=-1 && ix[1]!=-1
			if ix[0]>ix[1]
				wincmd b
				exe min([max([line('w0'),a:possav[1]]),line('w$')])
				exe winnr()==1? "" : "norm! 0g$"
			else
				wincmd t
				exe min([max([line('w0'),a:possav[1]]),line('w$')])
				norm! g0
			en
		en
	else
		exe win.'wincmd w'
   		exe min([max([line('w0'),a:possav[1]]),line('w$')])
		exe winnr()==1? ("norm! ".min([max([virtcol('.')-wincol()+1,a:possav[2]+a:possav[3]]),virtcol('.')-wincol()+winwidth(0)])."|") : ("norm! 0".min([max([1,a:possav[2]+a:possav[3]]),winwidth(0)])."|")
	en
endfun

fun! s:PanLeft(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let [extrashift,tcol]=[0,get(t:txb.ix,bufname(winbufnr(1)),-1)]
	if tcol<0
		throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txb.name)
	elseif a:N<&columns
		while winwidth(winnr('$'))<=a:N
			wincmd b
			let extrashift=(winwidth(0)==a:N)
			hide
		endw
	elseif a:N>0
		wincmd t
		only
	else
		return
	en
	if winwidth(0)!=&columns
		wincmd t	
		if winwidth(winnr('$'))<=a:N+3+extrashift || winnr('$')>=9
			se nowfw
			wincmd b
			exe 'vert res-'.(a:N+extrashift)
			wincmd t
			if winwidth(1)==1
				wincmd l
				se nowfw
				wincmd t 
				exe 'vert res+'.(a:N+extrashift)
				wincmd l
				se wfw
				wincmd t
			else
				exe 'vert res+'.(a:N+extrashift)
			en
			se wfw
		else
			exe 'vert res+'.(a:N+extrashift)
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
			let &scrollopt=t:txb.scrollopt
		endwhile
		let offset=t:txb.size[tcol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=&wrap? -a:N-extrashift : virtcol('.')-wincol()-a:N-extrashift
		if loff>=0
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
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
			let &scrollopt=t:txb.scrollopt
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
				let &scrollopt=t:txb.scrollopt
				windo se wfw
			en
		en
	en
	return extrashift
endfun

fun! s:PanRight(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let tcol=get(t:txb.ix,bufname(winbufnr(1)),-1)
	let [bcol,loff,extrashift,N]=[get(t:txb.ix,bufname(winbufnr(winnr('$'))),-1),winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0),0,a:N]
	let nobotresize=0
	if tcol<0 || bcol<0
		throw (tcol<0? bufname(winbufnr(1)) : '').(bcol<0? ' '.bufname(winbufnr(winnr('$'))) : '')." not contained in current plane: ".string(t:txb.name)
	elseif N>=&columns
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
		let &scrollopt=t:txb.scrollopt
		only
		exe 'norm! 0'.(loff>0? loff.'zl' : '')
	elseif N>0
		if winwidth(1)==1
			wincmd t
			hide
			let N-=2
			if N<=0
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
	else
		return
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
		else
			wincmd t
		en
		let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
		exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
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
			let &scrollopt=t:txb.scrollopt
		endwhile
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
		let &scrollopt=t:txb.scrollopt
		windo se wfw
	else
		let offset=loff-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	en
	return extrashift
endfun
