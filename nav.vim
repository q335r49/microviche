"Email me at q335r49 at gmail dot com for any suggestions / bugs / etc.
"Basic setup:
"1) Initialize plane with a file pattern
"    :call InitPlane('file*')
"2) Pan with mouse (keyboard panning to come)
"
" --- Recent changes:
"ReinitPlane() restores plane from current file (or saved session) if NAV_NAMES,NAV_SIZE,NAV_IX,NAV_EXE are still valid (such as from storing in viminfo)
"ReinitPlane(1) redraws plane based on currently active column
"Major optimizations for mouse panning, frame skip no longer needed
"InitPlane() loading message
"
" --- Upcoming:
"make NAV_ variables into a dictionary
"have reinitplane take plane dict argument
"Modal roguelike navigation: hjklyubnHJKLYUBN, with 'scrolloff'
"... center cursor / zs
"... OnResize autocommands
"GetPlanePos(), GoPlanePos(), animations
"... NormalizePlane(len) to make sure all columns are of equal length / autonormalize
"... or... an actual path, with corners?? or better... with leaps?
"... Jumps: Remap `' when tabscroll is on / bookmarks <plane-006:111> or <*006:111>
"... Changelist functionality
"Line number anchors
"Insert column command, delete column command (have redraw check file names) / edit settings
"Workflow videos +"memory excising, blocks" +jrpgs
"map of bookmarks (html?) / print
"
" --- Known issues:
"Assumes no horizontal splits
"Vim unable to detect mouse events when absolute x cursor position is greater than 253
"When columns are of uneven length, there may be some graphical jittering near the end of file
"When number of columns > 9 vim's split resizing algorithm changes and panning, more sophisticated algorithm needed

nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
nno <f5> :call ReinitPlane(1)<cr>

"todo: LAST_PLANE global variable
"InitPlane returns dictionary that can be saved, or optionally save t:textplane
fun! InitPlane(names,...)
	let g:opt_disable_syntax_while_panning=1
	tabe 
	let t:textplane={}
	se sidescroll=1 mouse=a lz noea nosol wiw=1 wmw=0 ve=all
	if type(a:names)==1 	"(string filepattern, [list Sizes, list Settings])
		let g:NAV_NAMES=split(glob(a:1),"\n")
	elseif type(a:names1)==3 "(list Names, [list Sizes, list Settings])
		let g:NAV_NAMES=a:1
	else
		echoerr "Argument must be string (file pattern) or list (of file names)"
		return 1
	en
	let tcol=0
	let g:LOff=0
	let g:NAV_SIZE=exists("a:1")? a:1 : repeat([60],len(g:NAV_NAMES))
	let g:NAV_EXE=exists("a:2")? a:2 : repeat(['exe "norm! ".screentopline."Gzt" | se nowrap scb cole=2'],len(g:NAV_NAMES))
	let [g:NAV_IX,i]=[{},0]
	for e in g:NAV_NAMES
		let [g:NAV_IX[e],i]=[i,i+1]
	endfor
	exe 'tabe '.g:NAV_NAMES[tcol]
	let screentopline=1
	exe g:NAV_EXE[tcol]
    exe 'norm! 0'.(g:LOff? g:LOff.'zl' : '')
	let spaceremaining=&columns-g:NAV_SIZE[tcol]-g:LOff
	let NextCol=(tcol+1)%len(g:NAV_NAMES)
	se scrollopt=jump
	while spaceremaining>=2
		let screentopline=line('w0')
		exe 'bot '.(spaceremaining-1).'vsp '.(g:NAV_NAMES[NextCol])
		exe g:NAV_EXE[NextCol]
		norm! 0
		let spaceremaining-=g:NAV_SIZE[NextCol]+1
		let NextCol=(NextCol+1)%len(g:NAV_NAMES)
	endwhile
   	se scrollopt=ver,jump
	windo se wfw
	let t:mouse_pans_columns=1
	let namew=min([&columns/2,max(map(range(len(g:NAV_NAMES)),'len(g:NAV_NAMES[v:val])'))])
	let exew=&columns-namew-7
	echo "\n W -"." NAME -----------------------------------------------------------------------------------------------------------"[:namew]." AUTOEXE -----------------"[:exew]."\n".join(map(range(len(g:NAV_NAMES)),'printf(" %-3d %-".namew.".".namew."S %.".exew."s",g:NAV_SIZE[v:val],g:NAV_NAMES[v:val],g:NAV_EXE[v:val])'),"\n")
endfun

fun! ReinitPlane(...)
	let redraw_only=a:0? a:1 : 0
	let [col0,win0]=[get(g:NAV_IX,bufname(winbufnr(0)),redraw_only? 'abort' : 'reload'),winnr()]
	if col0 is 'abort'
   		echoer "Current window not registered in NAV_IX"
   		return 1
	elseif col0 is 'reload'
   		let col0=0
   		exe 'e' g:NAV_NAMES[0] 
	en
	if !redraw_only
		se sidescroll=1 mouse=a lz noea nosol wiw=1 wmw=0 ve=all
	 	let t:mouse_pans_columns=1
	 	echo "Column panning enabled"
	en
	let screentopline=line('w0')
	let possav=[bufnr('%'),screentopline,line('.'),virtcol('.')]
	se scrollopt=jump
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0%len(g:NAV_SIZE),0]
	let remain=split0
	while remain>=1
		let remain-=g:NAV_SIZE[colt]+1
		let colt=(colt-1)%len(g:NAV_SIZE)
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%len(g:NAV_SIZE),&columns-(split0>0? split0+1+g:NAV_SIZE[col0] : min([winwidth(1),g:NAV_SIZE[col0]])),1]
	while remain>=2
		let remain-=g:NAV_SIZE[colb]+1
		let colb=(colb+1)%len(g:NAV_SIZE)
		let colsRight+=1
	endwhile
	let colbw=g:NAV_SIZE[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%len(g:NAV_SIZE)
		for i in range(dif)
			let colt=(colt-1)%len(g:NAV_SIZE)
			exe 'top vsp '.g:NAV_NAMES[colt]
			exe g:NAV_EXE[colt]
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
		let colb=(col0+colsRight-1-dif)%len(g:NAV_SIZE)
		for i in range(dif)
			let colb=(colb+1)%len(g:NAV_SIZE)
			exe 'bot vsp '.g:NAV_NAMES[colb]
			exe g:NAV_EXE[colb]
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
	se wfw
	if expand('%:p')!=#fnamemodify(g:NAV_NAMES[(colt+winnr()-1)%len(g:NAV_SIZE)],":p")
	   ec 'Reloading file' g:NAV_NAMES[colt+winnr()-1] 'in window number ' winnr()
	   sleep 1
       exe 'e' g:NAV_NAMES[(colt+winnr()-1)%len(g:NAV_SIZE)] 
	en
	if !redraw_only
		exe g:NAV_EXE[(colt+winnr()-1)%len(g:NAV_SIZE)]
	en
	let dif=colbw-winwidth(winnr())
	if dif!=0
		exe 'vert res'.(dif>0? '+'.dif : dif)
	en
	let curwinnr=winnr()
	wincmd h
	while winnr()!=curwinnr
		se wfw
		let curwinnr=winnr()
		if expand('%:p')!=#fnamemodify(g:NAV_NAMES[(colt+winnr()-1)%len(g:NAV_SIZE)],":p")
		   ec 'Reloading file' g:NAV_NAMES[colt+winnr()-1] 'in window number ' winnr()
		   sleep 1
		   exe 'e' g:NAV_NAMES[(colt+winnr()-1)%len(g:NAV_SIZE)] 
		en
		if !redraw_only
			exe g:NAV_EXE[(colt+winnr()-1)%len(g:NAV_SIZE)]
		en
		if curwinnr==1
			let offset=g:NAV_SIZE[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=g:NAV_SIZE[(colt+curwinnr-1)%len(g:NAV_SIZE)]-winwidth(curwinnr)
			if dif!=0
				exe 'vert res'.(dif>0? '+'.dif : dif)
			en
			norm! 0
		en
		wincmd h
	endw
	se scrollopt=ver,jump
   	exe bufwinnr(possav[0]).'wincmd w|norm! '.possav[1].'Gzt'.possav[2].'G'.possav[3].'|'
endfun

fun! DeleteHiddenBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' buf
    endfor
endfun

fun! NavRight(N)
	if a:N<=winwidth(0)-wincol()
		exe 'norm! '.a:N.'l'
		return
  	en
	let [N,winline]=[a:N-winwidth(0)+wincol(),winline()]
	while N>0
		let curwinnr=winnr()
		wincmd l
		if winnr()==curwinnr
			call PanRight(N)
			exe "norm! \<c-w>b".winline.'Hg$'
			return
		elseif N<winwidth(0)
			exe 'norm! '.winline.'Hg0'.N.'l'
			return
		en
		let N-=winwidth(0)
	endwhile
endfun
fun! NavLeft(N)
	if a:N<wincol()
		exe 'norm! '.a:N.'h'
		return
	en
	let [N,winline]=[a:N-wincol(),winline()]
	while N>=0
		let curwinnr=winnr()
		wincmd h
		if winnr()==curwinnr
			call PanLeft(N) 	
			exe "norm! \<c-w>t".winline.'Hg0'
			return
		elseif N<winwidth(0)
			exe "norm! ".winline.'Hg$'.N.'h'
			return
		en
		let N-=winwidth(0)
	endw	
endfun

let glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
if !exists('g:opt_device') "for compatibility
	let opt_device=''
en
fun! MousePan()
	ec 'Panning...'
	if !exists('t:mouse_pans_columns')
		if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
			if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
			return 1 | en
		exe "norm! \<leftmouse>"
		let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
		let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(g:opt_device==?'droid4' && veon)? 'redr!':'redr']
		while getchar()=="\<leftdrag>"
			let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
			let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
			call winrestview(v)
			exe redrexpr
		endwhile
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
	else
		let win0=-1
		while getchar()!="\<leftrelease>"
			if v:mouse_win!=win0
				let win0=v:mouse_win
				exe v:mouse_win."wincmd w"
				let nx_expr=&wrap? "[(v:mouse_col-1)%".winwidth(v:mouse_win).",v:mouse_lnum]" : "[v:mouse_col-".(virtcol('.')-wincol()).",v:mouse_lnum]"
				let [x,y]=eval(nx_expr)
				let tcol=get(g:NAV_IX,bufname(winbufnr(1)),-99999)
			else
				let [nx,ny]=eval(nx_expr)
				if x && nx && x-nx
					let lcolprev=tcol
					if Pan{nx>x? "Left" : "Right"}(abs(nx-x))
						echohl WarningMsg
							ec bufname(winbufnr(1))." not registered in NAV_NAMES; switching to pan window mode"
						echohl None
						sleep 2
						call TogglePanMode()
						break
					en
				elseif !x
					let x=nx
				en
				if ny!=y
					exe 'norm! '.(winnr()!=win0? win0."\<c-w>w" : "").(ny>y? (ny-y)."\<c-y>" : (y-ny)."\<c-e>")
				en
			en
			redr
		endwhile
		exe "norm! \<leftmouse>"
	en
	redr|ec "Panning complete"
endfun

fun! TogglePanMode(...)
	if a:0>0
		if a:1 && exists('t:mouse_pans_columns')
    		unlet t:mouse_pans_columns
			echo "Column panning disabled"
		elseif !a:1
			let t:mouse_pans_columns=1
			echo "Column panning enabled"
		en
	elseif !exists('t:mouse_pans_columns')
		let t:mouse_pans_columns=1
		echo "Column panning enabled"
	else
		unlet t:mouse_pans_columns
		echo "Column panning disabled"
	en
endfun

fun! PanLeft(N)
	let [g:extrashiftamt,tcol]=[0,get(g:NAV_IX,bufname(winbufnr(1)),-1)]
	if tcol<0
		return 1
	elseif a:N<&columns
		while winwidth(winnr('$'))<=a:N
	   		wincmd b
			let g:extrashiftamt=(winwidth(0)==a:N)
			hide
		endw
	el
		wincmd t
		only
	en
	if winwidth(0)!=&columns
		wincmd t	
		if winwidth(winnr('$'))<=a:N+3+g:extrashiftamt
			se nowfw
			wincmd b
			exe 'vert res-'.(a:N+g:extrashiftamt)
			wincmd t
			if winwidth(1)==1
            	wincmd l
				se nowfw
				wincmd t 
				exe 'vert res+'.(a:N+g:extrashiftamt)
				wincmd l
				se wfw
				wincmd t
			en
			se wfw
		else
			exe 'vert res+'.(a:N+g:extrashiftamt)
		en
		while winwidth(0)>=g:NAV_SIZE[tcol]+2
			se nowfw scrollopt=jump
			let [nextcol,screentopline]=[(tcol-1)%len(g:NAV_NAMES),line('w0')]
			exe 'top '.(winwidth(0)-g:NAV_SIZE[tcol]-1).'vsp '.g:NAV_NAMES[nextcol]
			exe g:NAV_EXE[nextcol]
			wincmd l
			se wfw
			norm! 0
			wincmd t
			let tcol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
		let offset=g:NAV_SIZE[tcol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (g:NAV_SIZE[tcol]>winwidth(1)? g:NAV_SIZE[tcol]-winwidth(1) : 0)-a:N-g:extrashiftamt
		if loff>=-1
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			while loff<=-2
				let tcol=(tcol-1)%len(g:NAV_NAMES)
				let loff+=g:NAV_SIZE[tcol]+1
			endwhile
			se scrollopt=jump
			let screentopline=line('w0')
			exe 'e '.g:NAV_NAMES[tcol]
			exe g:NAV_EXE[tcol]
			se scrollopt=ver,jump
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
			if g:NAV_SIZE[tcol]-loff<&columns-1
				let spaceremaining=&columns-g:NAV_SIZE[tcol]+loff
				let NextCol=(tcol+1)%len(g:NAV_NAMES)
				se nowfw scrollopt=jump
				while spaceremaining>=2
					let screentopline=line('w0')
					exe 'bot '.(spaceremaining-1).'vsp '.(g:NAV_NAMES[NextCol])
					exe g:NAV_EXE[NextCol]
					norm! 0
					let spaceremaining-=g:NAV_SIZE[NextCol]+1
					let NextCol=(NextCol+1)%len(g:NAV_NAMES)
				endwhile
				se scrollopt=ver,jump
				windo se wfw
			en
		en
	en
endfun

fun! PanRight(N)
	let tcol=get(g:NAV_IX,bufname(winbufnr(1)),-99999)
	let [bcol,g:LOff,g:extrashiftamt,N]=[get(g:NAV_IX,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (g:NAV_SIZE[tcol]>winwidth(1)? g:NAV_SIZE[tcol]-winwidth(1) : 0),0,a:N]
	if tcol+bcol<0
		return 1
	elseif N>=&columns
		if winwidth(1)==&columns
        	let g:LOff+=&columns
		else
			let g:LOff=winwidth(winnr('$'))
			let bcol=tcol
		en
		if g:LOff>=g:NAV_SIZE[tcol]
			let g:LOff=0
			let tcol=(tcol+1)%len(g:NAV_NAMES)
		en
		let toshift=N-&columns
		if toshift>=g:NAV_SIZE[tcol]-g:LOff+1
			let toshift-=g:NAV_SIZE[tcol]-g:LOff+1
			let tcol=(tcol+1)%len(g:NAV_NAMES)
			while toshift>=g:NAV_SIZE[tcol]+1
				let toshift-=g:NAV_SIZE[tcol]+1
				let tcol=(tcol+1)%len(g:NAV_NAMES)
			endwhile
			if toshift==g:NAV_SIZE[tcol]
				let N+=1
   				let g:extrashiftamt=-1
				let tcol=(tcol+1)%len(g:NAV_NAMES)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:NAV_SIZE[tcol]-g:LOff
			let N+=1
   			let g:extrashiftamt=-1
			let tcol=(tcol+1)%len(g:NAV_NAMES)
			let g:LOff=0
		else
			let g:LOff+=toshift	
		en
		let screentopline=line('w0')
		se scrollopt=jump
		exe 'e '.g:NAV_NAMES[tcol]
		exe g:NAV_EXE[tcol]
		se scrollopt=ver,jump
		only
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		let shifted=0
		while winwidth(1)<=N
			let g:extrashiftamt=winwidth(1)==N
			wincmd t
			hide
			let shifted+=winwidth(0)+1
			let tcol=(tcol+1)%len(g:NAV_NAMES)
			let g:LOff=0
		endw
   		let N+=g:extrashiftamt
		let g:LOff+=N-shifted
	en
	let wf=winwidth(1)-N
	if wf+N!=&columns
		wincmd b
		exe 'vert res+'.N
		wincmd t	
		if winwidth(1)!=wf
			exe 'vert res'.wf
		en
		let offset=g:NAV_SIZE[tcol]-winwidth(1)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		while winwidth(winnr('$'))>=g:NAV_SIZE[bcol]+2
			wincmd b
			se nowfw scrollopt=jump
			let nextcol=(bcol+1)%len(g:NAV_NAMES)
			let screentopline=line('w0')
			exe 'rightb vert '.(winwidth(0)-g:NAV_SIZE[bcol]-1).'split '.g:NAV_NAMES[nextcol]
			exe g:NAV_EXE[nextcol]
			wincmd h
			se wfw
			wincmd b
			norm! 0
			let bcol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
	elseif &columns-g:NAV_SIZE[tcol]+g:LOff>=2
		let bcol=tcol
		let spaceremaining=&columns-g:NAV_SIZE[tcol]+g:LOff
		se nowfw scrollopt=jump
		while spaceremaining>=2
			let bcol=(bcol+1)%len(g:NAV_NAMES)
			let screentopline=line('w0')
			exe 'bot '.(spaceremaining-1).'vsp '.(g:NAV_NAMES[bcol])
			exe g:NAV_EXE[bcol]
			norm! 0
			let spaceremaining-=g:NAV_SIZE[bcol]+1
		endwhile
		se scrollopt=ver,jump
		windo se wfw
	en
endfun
