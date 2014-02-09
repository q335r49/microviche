"Check www.vim.org/scripts/script.php?script_id=4835 for previous versions
"Global hotkey: press to begin.
	let txb_key='<f10>'
	let txb_rawkey="\<f10>"
"Grid panning animation step
	let s:pansteph=9
	let s:panstepv=2
"Small grid: 1 split x s:sgridL lines
	let s:sgridL=15
"Big grid: s:bgridS splits x s:bgridL lines; Map grid: 1 split x s:bgridL lines
	let s:bgridS=3
	let s:bgridL=45
"Mouse panning speed (only works when &ttymouse==xterm2 or sgr)
	let TXBpanSpeed=2

if &compatible|se nocompatible|en "Enable vim features, changes &ttymouse
se sidescroll=1                   "Needed for smooth panning
se mouse=a                        "Enable mouse
se lazyredraw                     "Less redraws
se noequalalways                  "Needed for correct panning
se nostartofline                  "Cursor remains at column when moving up and down
se winwidth=1                     "Needed for correct panning
se winminwidth=0                  "Needed for correct panning
se virtualedit=all                "Needed for leftmost split to be drawn correctly
se hidden                         "Prevents error messages when modified buffer is panned offscreen

fun! TXBSetMouseMode()
	if exists('s:TXBcmdUnmap')
		exe s:TXBcmdUnmap
	en
	if &ttymouse=="xterm"
		echoerr "Warning! Your &ttymouse is set to 'xterm', which does not support mouse drag messages. Try ':set ttymouse=xterm2' or ':set ttymouse=sgr' and reloading the plane to enable mouse panning."
		nmap <silent> <plug>TxbY<esc>[M :call TXBProcChar(-1)<cr>
		let s:TXBcmdUnmap='nunmap <plug>TxbY<esc>[M'
	elseif &ttymouse==?"xterm2"
		nn <silent> <leftmouse> :call InitDragXterm2(exists("t:txb")? "TXBNavCol" : "TXBPanWin")<cr>
		nmap <silent> <plug>TxbY<esc>[M :call TXBProcChar(-1)<cr>
		let s:TXBcmdUnmap='nunmap <plug>TxbY<esc>[M'
	elseif &ttymouse==?"sgr"
		nn <silent> <leftmouse> :call InitDragSGR(exists("t:txb")? "TXBNavCol" : "TXBPanWin")<cr>
		nmap <silent> <plug>TxbY<esc>[< :call TXBProcChar(-1)<cr>
		let s:TXBcmdUnmap='nunmap <plug>TxbY<esc>[<'
	else
   		echoerr "Warning! For better mouse panning performance, try setting ttymouse to xterm2 (se ttymouse=xterm2) or sgr (se ttymouse=sgr). Your current setting is: ".&ttymouse
		nn <silent> <leftmouse> :exe TXBmouse{exists('t:txb')? "Nav" : "TXBPanWin"}()? "keepj norm! \<lt>leftmouse>" : ""<cr>
		nmap <silent> <plug>TxbY<esc>[M :call TXBProcChar(-1)<cr>
		let s:TXBcmdUnmap='nunmap <plug>TxbY<esc>[M'
	en
endfun

exe 'nn <silent> '.txb_key.' :if exists("t:txb")\|call TXBcmd("ini")\|else\|call TXBstart()\|en<cr>'
let TXBcmds={}
fun! s:PrintHelp()
let helpmsg="\n\\CWelcome to Textabyss v1.3!\n
\\nPress ".g:txb_key." to start. You will be prompted for a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single file and use ".g:txb_key."A to append additional splits.\n
\\nOnce loaded, use the mouse to pan or press ".g:txb_key." followed by:
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
\\nIf mousedragging doesn't pan, try setting 'ttymouse'  to 'sgr' or 'xterm2' and reloading the plane. Most other modes are supported but will disable some advanced features. 'xterm', however, does not report dragging and will disable mouse panning entirely.\n
\\nEnsuring a consistent starting directory is important because relative names are remembered (use ':cd ~/PlaneDir' to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.\n
\\nSetting your viminfo to save global variables (:set viminfo+=!) is highly recommended as the previously used plane and the map will be saved and suggested when the hotkey is first pressed.\n
\\nHorizontal splits aren't supported and may interfere with mouse panning. \n\nPress enter to continue ... (or input 'm' for a monologue, 'c' for changelog)"
let width=&columns>80? min([&columns-10,80]) : &columns-2
redr
let input=input(s:FormatPar(helpmsg,width,(&columns-width)/2))
if input==?'m'
let helpmsg="\n\n\\C~\n\\C\"... into the abyss he slipped
\\n\\CEndless fathoms he fell
\\n\\CNe'er in homely hearth to linger
\\n\\CNor warm hand to grasp!\"\n\\C~\n
\\n    In a time when memory capacity is growing exponentially, memory storage and retrieval, especially when it comes to prose, still seems quite undeveloped. It makes very little sense, to me, to have a massive hard drive when, in terms of text, actual production might be on the order of kilobytes per year. Depending on how prolific you are as a writer, you may have thousands or tens of thousands of pages in mysteriously named folders on old hard drives (say, since 5th grade). So the problem is one of organization, retreival, and accessibility rather than availability of space. There are various efforts in this regard, including desktop indexing and personal wikis. It might not even be a bad idea to simply print out and keep as a hard copy everything written over the course of a month.\n
\\n    The textabyss is yet another solution to this problem. It presents a plane that one can append to endlessly with very little overhead. It provides means to navigate and, either at the moment of writing or retrospectively, map out. Ideally, you would be able to scan over the map and easily access writings from last night, a month ago, or even 5 to 10 years earlier. It presents some unique advantages over both indexing and hyperlinked or hierarchical organizing.\n
\\n    A note about scrollbinding splits of uneven lengths -- I've tried to smooth over this process but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding, say, 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.\n
\\n\\RThanks for trying out Textabyss!\n\n\\RLeon, q335r49@gmail.com"
cal input(s:FormatPar(helpmsg,width,(&columns-width)/2))
elseif input==?'c'
let helpmsg="\n
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
\\n1.2.3  - FormatPar for help dialogs now has option to align right
\\n1.2.2  - Minor bug where the rightmost split will overshift on PanRight
\\n"
cal input(s:FormatPar(helpmsg,width,(&columns-width)/2))
en
endfun

let TXB_PREVPAT=exists('TXB_PREVPAT')? TXB_PREVPAT : ''

fun! TXBmouseNav()
	let possav=[bufnr('%')]+getpos('.')[1:]
	let [c,w0]=[getchar(),-1]
	if c!="\<leftdrag>"
		return 1
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
	call s:RestoreCursPos(possav)
endfun

let glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! TXBmousePanWin()
	let possav=[bufnr('%')]+getpos('.')[1:]
	call feedkeys("\<leftmouse>")
	call getchar()
	exe v:mouse_win."wincmd w"
	if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
		if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
		return 1 | en
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
		return 1
	en
	if str2float(reltimestr(reltime(tl[(fr+1)%4][0])))<0.2
		let [glv,glh,vc,hc]=[tl[0][1]+tl[1][1]+tl[2][1]+tl[3][1],tl[0][2]+tl[1][2]+tl[2][2]+tl[3][2],0,0]
		let [tlx,lnx,glv,lcx,cax,glh]=(glv>3? ['y*v.topline>1','y*v.lnum>1',glv*glv] : glv<-3? ['-(y*v.topline<'.line('$').')','-(y*v.lnum<'.line('$').')',glv*glv] : [0,0,0])+(glh>3? ['x*v.leftcol>0','x*v.coladd>0',glh*glh] : glh<-3? ['-x','-x',glh*glh] : [0,0,0])
		while !getchar(1) && glv+glh
			let [y,x,vc,hc]=[vc>get(g:glidestep,glv,1),hc>get(g:glidestep,glh,1),vc+1,hc+1]
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
endfun

fun! InitDragSGR(funcname)
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let g:TXB_prevcoord=[0,0,0]
			let g:TXB_DragHandler=a:funcname
			nno <silent> <esc>[< :call ProcessDragSGR()<cr>
		en
	else
		let g:TXB_prevcoord=[0,0,0]
		let g:TXB_DragHandler=a:funcname
		nno <silent> <esc>[< :call ProcessDragSGR()<cr>
	en
endfun
fun! ProcessDragSGR()
	let code=[getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)]
	while getchar(0) isnot 0
	endwhile
	let k=map(split(join(map(code,'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
	elseif k[1] && k[2] && g:TXB_prevcoord[1] && g:TXB_prevcoord[2]
		call {g:TXB_DragHandler}(k[1]-g:TXB_prevcoord[1],k[2]-g:TXB_prevcoord[2])
	en
	let g:TXB_prevcoord=k
endfun

fun! InitDragXterm2(funcname)
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let g:TXB_prevcoord=[0,0,0]
			let g:TXB_DragHandler=a:funcname
			nno <silent> <esc>[M :call ProcessDragXterm2()<cr>
		en
	else
		let g:TXB_prevcoord=[0,0,0]
		let g:TXB_DragHandler=a:funcname
		nno <silent> <esc>[M :call ProcessDragXterm2()<cr>
	en
endfun
fun! ProcessDragXterm2()
	let k=[getchar(0),getchar(0),getchar(0)]
	while getchar(0) isnot 0
	endwhile
	if k[0]==35
		nunmap <esc>[M
	elseif k[1] && k[2] && g:TXB_prevcoord[1] && g:TXB_prevcoord[2]
		call {g:TXB_DragHandler}(k[1]-g:TXB_prevcoord[1],k[2]-g:TXB_prevcoord[2])
	en
	let g:TXB_prevcoord=k
endfun

let s:panstep=[0,1,2,4,8,16,16]
fun! TXBPanWin(dx,dy)
	exe "norm! ".(a:dy>0? g:TXBpanSpeed*get(s:panstep,a:dy,16)."\<c-y>" : a:dy<0? g:TXBpanSpeed*get(s:panstep,-a:dy,16)."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! TXBNavCol(dx,dy)
	let possav=s:SaveCursPos()
	if a:dx>0
		call s:PanLeft(g:TXBpanSpeed*get(s:panstep,a:dx,16))
	elseif a:dx<0
		call s:PanRight(g:TXBpanSpeed*get(s:panstep,-a:dx,16))
	en
	exe "norm! ".(a:dy>0? g:TXBpanSpeed*get(s:panstep,a:dy,16)."\<c-y>" : a:dy<0? g:TXBpanSpeed*get(s:panstep,-a:dy,16)."\<c-e>" : 'g')
	call s:RestoreCursPos(possav)
	let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL))
endfun

fun! s:MakeGridNameList(len)
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

let s:bksizes=[[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9]]
let TXBcmds.o='let g:txbc.continue=0|let grid=s:GetSmallGrid()|cal s:NavigateMap(t:txb.map,grid[0],grid[1])'
let s:pad=repeat(' ',100)
fun! s:GetMapDisp(map,w,h,H)
	let [s,l]=[map(range(a:h),'[v:val*a:w,v:val*a:w+a:w-1]'),len(a:map)*a:w+1]
	return {'str':join(map(range(a:h*a:H),'join(map(map(range(len(a:map)),''len(a:map[v:val])>''.v:val/a:h.''? a:map[v:val][''.v:val/a:h.''] : "[NUL]"''),''v:val[s[''.v:val%a:h.''][0] : s[''.v:val%a:h.''][1]].s:pad[1:(s[''.v:val%a:h.''][1]>=len(v:val)? (s[''.v:val%a:h.''][0]>=len(v:val)? a:w : a:w-len(v:val)+s[''.v:val%a:h.''][0]) : 0)]''),'''')."\n"'),''),'hlmap':map(range(a:H),'map(range(len(a:map)),''map(range(a:h),"''.v:val.''*l*a:h+(a:w)*".v:val."+v:val*l")'')'),'w':(a:w)}
endfun
fun! s:PrintMapDisp(disp,r,c)
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
fun! s:NavigateMap(array,c_ini,r_ini)
	let settings=[&ch,&more,&ls,&stal]
	let &ch=&lines
	let g:ms={'array':(a:array),'settings':settings,'msg':'','r':(a:r_ini),'c':(a:c_ini),'rows':(&ch-1)/s:bksizes[t:txb.zoom][0],'cols':(&columns-1)/s:bksizes[t:txb.zoom][1],'pad':repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0]).' ','continue':1,'redr':1}
	let g:ms.roff=max([g:ms.r-g:ms.rows/2,0])
	let g:ms.coff=max([g:ms.c-g:ms.cols/2,0])
	let [&more,&ls,&stal]=[0,0,0]
   	let g:ms.disp=s:GetMapDisp(map(range(g:ms.coff,g:ms.coff+g:ms.cols-1),'map(range(g:ms.roff,g:ms.roff+g:ms.rows-1),"exists(\"a:array[".v:val."][v:val]\")? a:array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],g:ms.rows)
	call s:PrintMapDisp(g:ms.disp,g:ms.r-g:ms.roff,g:ms.c-g:ms.coff)
	echon g:ms.pad.get(t:txb.gridnames,g:ms.c,'--').(g:ms.r).(g:ms.msg)
	let g:GC_ProcChar="NavMapHandleKeys"
	call TXBGetChar()
endfun
fun! NavMapHandleKeys(c)
	if a:c is -1
		let g:ms.msg=string(g:GC_MouseCmd)
	else
		exe get(s:mapdict,a:c,'let g:ms.msg="   Press f1 for help"')
	en
	if g:ms.continue==1
		let [roffn,coffn]=[g:ms.r<g:ms.roff? g:ms.r : g:ms.r>=g:ms.roff+g:ms.rows? g:ms.r-g:ms.rows+1 : g:ms.roff,g:ms.c<g:ms.coff? g:ms.c : g:ms.c>=g:ms.coff+g:ms.cols? g:ms.c-g:ms.cols+1 : g:ms.coff]
		if [g:ms.roff,g:ms.coff]!=[roffn,coffn] || g:ms.redr
			let [g:ms.roff,g:ms.coff,g:ms.redr]=[roffn,coffn,0]
			let g:ms.disp=s:GetMapDisp(map(range(g:ms.coff,g:ms.coff+g:ms.cols-1),'map(range(g:ms.roff,g:ms.roff+g:ms.rows-1),"exists(\"g:ms.array[".v:val."][v:val]\")? g:ms.array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],g:ms.rows)
		en
		redr!
		call s:PrintMapDisp(g:ms.disp,g:ms.r-g:ms.roff,g:ms.c-g:ms.coff)
		echon (g:ms.pad).get(t:txb.gridnames,g:ms.c,'--').(g:ms.r).(g:ms.msg)
		let g:ms.msg=''
		call TXBGetChar()
	elseif g:ms.continue==2
		let [&ch,&more,&ls,&stal]=g:ms.settings
		cal TXB_GotoPos(g:ms.c,s:bgridL*g:ms.r)
	else
		let [&ch,&more,&ls,&stal]=g:ms.settings
	en
endfun
let s:mapdict={"\e":"let g:ms.continue=0|redr",
\"\<f1>":'let width=&columns>80? min([&columns-10,80]) : &columns-2|cal input(s:FormatPar("\n\n\\C~~ Map help ~~
\\nhjkl     Move cardinally
\\nyubn     Move diagonally
\\nx p      Cut block / Put block
\\nc i      Change block
\\ng        Goto block (and exit map)
\\n+ -      Increase / decrease block size
\\nI D      Insert / delete column
\\nq        Quit
\\n\n\\C(Press enter to continue)",width,(&columns-width)/2))',
\"j":"let g:ms.r+=1",
\"q":"let g:ms.continue=0",
\"jj":"let g:ms.r+=2",
\"jjj":"let g:ms.r+=3",
\"k":"let g:ms.r=g:ms.r>0? g:ms.r-1 : g:ms.r",
\"kk":"let g:ms.r=g:ms.r>1? g:ms.r-2 : g:ms.r",
\"kkk":"let g:ms.r=g:ms.r>2? g:ms.r-3 : g:ms.r",
\"l":"let g:ms.c+=1",
\"ll":"let g:ms.c+=2",
\"lll":"let g:ms.c+=3",
\"h":"let g:ms.c=g:ms.c>0? g:ms.c-1 : g:ms.c",
\"hh":"let g:ms.c=g:ms.c>1? g:ms.c-2 : g:ms.c",
\"hhh":"let g:ms.c=g:ms.c>2? g:ms.c-3 : g:ms.c",
\"y":"let [g:ms.r,g:ms.c]=[g:ms.r>0? g:ms.r-1 : g:ms.r,g:ms.c>0? g:ms.c-1 : g:ms.c]",
\"u":"let [g:ms.r,g:ms.c]=[g:ms.r>0? g:ms.r-1 : g:ms.r,g:ms.c+1]",
\"b":"let [g:ms.r,g:ms.c]=[g:ms.r+1,g:ms.c>0? g:ms.c-1 : g:ms.c]",
\"n":"let [g:ms.r,g:ms.c]=[g:ms.r+1,g:ms.c+1]",
\"x":"if exists('g:ms.array[g:ms.c][g:ms.r]')|let @\"=g:ms.array[g:ms.c][g:ms.r]|let g:ms.array[g:ms.c][g:ms.r]=''|let g:ms.redr=1|en",
\"p":"if g:ms.c>=len(g:ms.array)\n
	\call extend(g:ms.array,eval('['.join(repeat(['[]'],g:ms.c+1-len(g:ms.array)),',').']'))\n
\en\n
\if g:ms.r>=len(g:ms.array[g:ms.c])\n
	\call extend(g:ms.array[g:ms.c],repeat([''],g:ms.r+1-len(g:ms.array[g:ms.c])))\n
\en\n
\let g:ms.array[g:ms.c][g:ms.r]=@\"\n
\let g:ms.redr=1\n",
\"c":"let input=input((g:ms.disp.str).\"\nChange: \",exists('g:ms.array[g:ms.c][g:ms.r]')? g:ms.array[g:ms.c][g:ms.r] : '')\n
\if !empty(input)\n
 	\if g:ms.c>=len(g:ms.array)\n
		\call extend(g:ms.array,eval('['.join(repeat(['[]'],g:ms.c+1-len(g:ms.array)),',').']'))\n
	\en\n
	\if g:ms.r>=len(g:ms.array[g:ms.c])\n
		\call extend(g:ms.array[g:ms.c],repeat([''],g:ms.r+1-len(g:ms.array[g:ms.c])))\n
	\en\n
	\let g:ms.array[g:ms.c][g:ms.r]=input\n
	\let g:ms.redr=1\n
\en\n",
\"g":'let g:ms.continue=2',
\"+":'let t:txb.zoom=min([t:txb.zoom+1,len(s:bksizes)-1])|let [g:ms.redr,g:ms.rows,g:ms.cols,g:ms.pad]=[1,(&ch-1)/s:bksizes[t:txb.zoom][0],(&columns-1)/s:bksizes[t:txb.zoom][1],repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0])." "]',
\"-":'let t:txb.zoom=max([t:txb.zoom-1,0])|let [g:ms.redr,g:ms.rows,g:ms.cols,g:ms.pad]=[1,(&ch-1)/s:bksizes[t:txb.zoom][0],(&columns-1)/s:bksizes[t:txb.zoom][1],repeat("\n",(&ch-1)%s:bksizes[t:txb.zoom][0])." "]',
\"I":'if g:ms.c<len(g:ms.array)|call insert(g:ms.array,[],g:ms.c)|let g:ms.redr=1|let g:ms.msg=" Col ".(g:ms.c)." inserted"|en',
\"D":'if g:ms.c<len(g:ms.array) && input("Really delete column? (y/n)")==?"y"|call remove(g:ms.array,g:ms.c)|let redr=1|let g:ms.msg=" Col ".(g:ms.c)." deleted"|en'}
let s:mapdict.i=s:mapdict.c
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! DeleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBcmds["\<c-x>"]='cal DeleteHiddenBuffers()|let [g:txbc.msg,g:txbc.continue]=["Hidden Buffers Deleted",0]'

fun! s:FormatPar(str,w,pad)
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

fun! TXB_GotoPos(col,row)
	wincmd t
	only
	let name=get(t:txb.name,a:col,t:txb.name[0])
	if name!=#expand('%')
		exe 'e '.escape(name,' ')
	en
	exe 'norm!' (a:row? a:row : 1).'zt'
	call TXBLoadPlane()
endfun

fun! s:GotoBlock(str)
	let [col,row]=['','']
	for i in range(len(a:str)-1,0,-1)
		if a:str[i]>0 || a:str[i] is '0'
			let row=a:str[i].row
		else
			let col=a:str[i].col
		en
	endfor
	let line=index(t:txb.gridnames,col,0,1)*s:bgridS
	call TXB_GotoPos(index(t:txb.gridnames,col,0,1)*s:bgridS,s:bgridL*row)
endfun

fun! s:BlockPan(dx,y,...)
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
let s:Y1='let g:txbc.y=g:txbc.y/s:sgridL*s:sgridL+s:sgridL|'
let s:Ym1='let g:txbc.y=max([1,g:txbc.y/s:sgridL*s:sgridL-s:sgridL])|'
	let TXBcmds.h='cal s:BlockPan(-1,g:txbc.y)'
	let TXBcmds.j=s:Y1.'cal s:BlockPan(0,g:txbc.y)'
	let TXBcmds.k=s:Ym1.'cal s:BlockPan(0,g:txbc.y)'
	let TXBcmds.l='cal s:BlockPan(1,g:txbc.y)'
	let TXBcmds.y=s:Ym1.'cal s:BlockPan(-1,g:txbc.y)'
	let TXBcmds.u=s:Ym1.'cal s:BlockPan(1,g:txbc.y)'
	let TXBcmds.b =s:Y1.'cal s:BlockPan(-1,g:txbc.y)'
	let TXBcmds.n=s:Y1.'cal s:BlockPan(1,g:txbc.y)'
let s:DXm1='map([t:txb.ix[bufname(winbufnr(1))]],"winwidth(1)<=t:txb.size[v:val]? (v:val==0? t:txb.len-t:txb.len%s:bgridS : (v:val-1)-(v:val-1)%s:bgridS) : v:val-v:val%s:bgridS")[0]'
let s:DX1='map([t:txb.ix[bufname(winbufnr(1))]],"v:val>=t:txb.len-t:txb.len%s:bgridS? 0 : v:val-v:val%s:bgridS+s:bgridS")[0]'
let s:Y1='let g:txbc.y=g:txbc.y/s:bgridL*s:bgridL+s:bgridL|'
let s:Ym1='let g:txbc.y=max([1,g:txbc.y%s:bgridL? g:txbc.y-g:txbc.y%s:bgridL : g:txbc.y-g:txbc.y%s:bgridL-s:bgridL])|'
	let TXBcmds.H='cal s:BlockPan('.s:DXm1.',g:txbc.y,-1)'
	let TXBcmds.J=s:Y1.'cal s:BlockPan(0,g:txbc.y)'
	let TXBcmds.K=s:Ym1.'cal s:BlockPan(0,g:txbc.y)'
	let TXBcmds.L='cal s:BlockPan('.s:DX1.',g:txbc.y,1)'
	let TXBcmds.Y=s:Ym1.'cal s:BlockPan('.s:DXm1.',g:txbc.y,-1)'
	let TXBcmds.U=s:Ym1.'cal s:BlockPan('.s:DX1.',g:txbc.y,1)'
	let TXBcmds.B=s:Y1.'cal s:BlockPan('.s:DXm1.',g:txbc.y,-1)'
	let TXBcmds.N=s:Y1.'cal s:BlockPan('.s:DX1.',g:txbc.y,1)'
unlet s:DX1 s:DXm1 s:Y1 s:Ym1

fun! s:GridCorners(dx,dy)
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
		   	call s:BlockPan(-1,desty)
		elseif winnr()<=ix-destix
			call s:BlockPan(destix,desty,-1)
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
	let TXBcmds["\<c-y>"]='cal s:GridCorners(-1,-1)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-u>"]='cal s:GridCorners( 1,-1)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-b>"]='cal s:GridCorners(-1, 1)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-n>"]='cal s:GridCorners( 1, 1)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-h>"]='cal s:GridCorners(-1, 0)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-l>"]='cal s:GridCorners( 1, 0)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-j>"]='cal s:GridCorners( 0, 1)|let g:txbc.possav=s:SaveCursPos()'
	let TXBcmds["\<c-k>"]='cal s:GridCorners( 0,-1)|let g:txbc.possav=s:SaveCursPos()'

fun! s:GetSmallGrid()
	return [t:txb.ix[expand('%')],line('.')/s:bgridL]
endfun
fun! s:SnapToGrid()
	let [ix,l0]=[t:txb.ix[bufname(winbufnr(1))],line('w0')]
	let [sd,dir]=(ix%s:bgridS>s:bgridS/2 && ix+s:bgridS-ix%s:bgridS<t:txb.len-1)? [ix+s:bgridS-ix%s:bgridS,1] : [ix-ix%s:bgridS,-1]
	call s:BlockPan(sd,l0%s:bgridL>s:bgridL/2? l0+s:bgridL-l0%s:bgridL : l0-l0%s:bgridL,dir)
endfun
fun! s:SnapToCursorGrid()
	let [ix,l0]=[t:txb.ix[expand('%')],line('.')]
 	let [x,dir]=winnr()>ix%s:bgridS+1? [ix-ix%s:bgridS,1] : winnr()==ix%s:bgridS+1 && t:txb.size[ix-ix%s:bgridS]<=winwidth(1)? [0,0] : [ix-ix%s:bgridS,-1]
	"exe PRINT('ix|l0|x|dir')
	call s:BlockPan(x,l0-l0%s:bgridL,dir)
endfun
	let TXBcmds['.']='let g:txbc.possav=SaveCursPos()|call s:SnapToCursorGrid()|let g:txbc.continue=0'
	let TXBcmds['.']='call s:SnapToCursorGrid()|let g:txbc.continue=0'

nmap <silent> <plug>TxbY :call TXBGetChar()<cr>
nmap <silent> <plug>TxbZ :call TXBGetChar()<cr>
fun! TXBGetChar()
	if getchar(1) is 0
		sleep 1m
		call feedkeys("\<plug>TxbY")
	else
		call TXBProcChar(getchar())
	en
endfun
fun! TXBProcChar(c)
	if a:c==-1
		let g:GC_MouseCmd=[getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)]
		call {g:GC_ProcChar}(-1)	
	else
		let [k,c]=['',a:c]
		while c isnot 0
			let k.=type(c)==0? nr2char(c) : c
			let c=getchar(0)
		endwhile
		call {g:GC_ProcChar}(k)
	en
endfun

fun! TXBcmd(...)
	if a:0
		let g:txbc={'y':line('w0'),'continue':1,'msg':'','possav':(s:SaveCursPos())}
		exe get(g:TXBcmds,a:1,'let g:txbc.msg="Press f1 for help"')
		call s:RestoreCursPos(g:txbc.possav)
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(g:txbc.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : g:txbc.msg
	en
	if g:txbc.continue
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(g:txbc.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).'  '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : g:txbc.msg
		let g:txbc.msg=''
		let g:GC_ProcChar="TXBcmdPC"
		call feedkeys("\<plug>TxbZ") 
	en
endfun
fun! TXBcmdPC(c)
	exe get(g:TXBcmds,a:c,'let g:txbc.msg="Press f1 for help"')
   	call s:RestoreCursPos(g:txbc.possav)
	if g:txbc.continue
		call feedkeys(g:txb_rawkey)
	else
		let s0=t:txb.ix[bufname(winbufnr(1))]|redr|ec empty(g:txbc.msg)? join(t:txb.gridnames[s0 : s0+winnr('$')-1]).' _ '.join(range(line('w0')/s:bgridL,(line('w0')+winheight(0))/s:bgridL)) : g:txbc.msg
	en
endfun

let TXBcmds.ini=""
let TXBcmds.D="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb.ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call TXBDeleteCol(ix)\n
		\wincmd W\n
		\call TXBLoadPlane(t:txb)\n
		\let g:txbc.msg='col '.ix.' removed'\n
	\else\n
		\let g:txbc.msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en\n
\let g:txbc.continue=0"
let TXBcmds.A="let ix=get(t:txb.ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append : ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\let error=s:AppendCol(ix,file)\n
	\if empty(error)\n
		\try\n
			\call TXBLoadPlane(t:txb)\n
			\let g:txbc.msg='col '.(ix+1).' appended'\n
		\catch\n
			\call TXBDeleteCol(ix)\n
			\let g:txbc.msg='Error detected while loading plane: file append aborted'\n
		\endtry\n
	\else\n
		\let g:txbc.msg='Error: '.error\n
	\en\n
\else\n
	\let g:txbc.msg='Current buffer not in plane'\n
\en\n
\let g:txbc.continue=0"
let TXBcmds["\e"]="let g:txbc.continue=0"
let TXBcmds.q="let g:txbc.continue=0"
let TXBcmds.r="call TXBLoadPlane(t:txb)|redr|let g:txbc.msg='(redrawn)'|let g:txbc.continue=0"
let TXBcmds["\<f1>"]='call s:PrintHelp()|let g:txbc.continue=0'
let TXBcmds.E='call s:EditSettings()|let g:txbc.continue=0'

fun! TXBstart(...)                                          
	call TXBSetMouseMode()            "Sets mouse panning mode
	let preventry=a:0 && a:1 isnot 0? a:1 : exists("g:TXB") && type(g:TXB)==4? g:TXB : exists("g:TXB_PREVPAT")? g:TXB_PREVPAT : ''
	let plane=type(preventry)==1? s:CreatePlane(preventry) : type(preventry)==4? preventry : {'name':''}
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
		call TXBLoadPlane(plane)
	elseif c is "\<f1>"
		call s:PrintHelp() 
	else
		let input=input("> Enter file pattern or type HELP: ", g:TXB_PREVPAT)
		if empty(input)
			redr|ec "(aborted)"
		elseif input==?'help'
			call s:PrintHelp()
		else
			call TXBstart(input)
		en
	en
endfun

fun! s:EditSettings()
   	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input(' < Column width: ',t:txb.size[ix])
		if empty(input) | return | en
    	let t:txb.size[ix]=input
		redr
    	let input=input(" < Autoexecute on load:
			\\n * scb should always be set so that one can toggle global scrollbind via <hotkey>S
			\\n * wrap defaults to 'wrap' if not set\n",t:txb.exe[ix])
		if empty(input) | return | en
		let t:txb.exe[ix]=input
		redr
    	let input=input(' < Column position (0-'.(t:txb.len-1).'): ',ix)
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
		call TXBLoadPlane(t:txb)
	en
endfun

fun! s:CreatePlane(name,...)
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
		let [plane.ix,i]=[{},0]
		let plane.map=[[]]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		let plane.gridnames=s:MakeGridNameList(plane.len+50)
		return plane
	en
endfun

fun! s:AppendCol(index,file,...)
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
		let t:txb.gridnames=s:MakeGridNameList(t:txb.len+50)
	endif
endfun
fun! TXBDeleteCol(index)
	call remove(t:txb.name,a:index)	
	call remove(t:txb.size,a:index)	
	call remove(t:txb.exe,a:index)	
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
endfun

fun! TXBLoadPlane(...)
	if a:0
		let t:txb=a:1
	elseif !exists("t:txb")
		ec "\n> No plane initialized..."
		call TXBstart()
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
		let colt=(colt-1)%len(t:txb.size)
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%t:txb.len,&columns-(split0>0? split0+1+t:txb.size[col0] : min([winwidth(1),t:txb.size[col0]])),1]
	while remain>=2
		let remain-=t:txb.size[colb]+1
		let colb=(colb+1)%len(t:txb.size)
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
		let colb=(col0+colsRight-1-dif)%len(t:txb.size)
		for i in range(dif)
			let colb=(colb+1)%len(t:txb.size)
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
		let t:txb.gridnames=s:MakeGridNameList(t:txb.len+50)
	en
endfun

fun! s:SaveCursPos()
	return [bufnr('%')]+getpos('.')[1:]
endfun
fun! s:RestoreCursPos(possav)
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
