"Please email q335r49@gmail.com for any suggestions / bugs / etc.
"(1) Initialize plane
":call InitPlane("file*")    "this will load "file0, file1, filea, fileA, etc
"(2) pan with mouse, or with c-j / c-k
"(3) Toggle mouse behavior with
":call TogglePanMode()
"
"Recent changes:
"Major optimizations for mouse panning, frame skip no longer needed
"New InitPlane() loading message
"PanMode now local to tab
"No longer flickers when scrolling near the end of document
"Restore from previous state (eg, mksession) by calling TogglePanMode(1) (if NAV_NAMES,NAV_SIZE,NAV_IX,NAV_EXE are still valid, such as from storing in viminfo)
"Readjust() to restore plane based on currently active column
"
"Bugs:
"[nav] scrollbinding bug on TogglePanMode() restoration
"(Perhaps only when buffer is already open?) panning left right after InitPlane will fuck up scb
"
"Upcoming:
"change lefta rightb to topleft botright?
" ...  weird scrollbinding bugs
" ...  use new 'general' method for all offset determination (ie, calculating offset, ve, etc.)
" ...  test cases: make sure it works with wrap windows longer than winwidth
" ...  A more robust version of readjust that is ok with horizontal splits
" ...  adjust current column before panning
" ...  differentiate TogglePan and Reinitialize
" ...  Add columns (on next scroll? No! "InsertHere")
"[nav] Modal Panning: " ...  hjklyubnHJKLYUBN navigation with or without fixed cursor, center cursor, zs cursor
" ...  Center cursor on resize
"[nav] qb functionality / implement Plane* autocommands?
" ...  remap `' when tabscroll is on / bookmarks <plane-006:111> or <*006:111> / jump back / account for line('$')
"[nav] <line number> and autoadjust
"[nav] painting
"[nav] Workflow videos
"[nav] fix panning idiosyncracies when number of columns>9
"
"Known issues:
"when very zoomed out, vim may be unable to detect mouse events when absolute cursor position is greater than 200ish
"when columns are of uneven lenght, there may be some graphical jiterring near the end
"when number of columns > 9, vim's resizing algorithm changes, and panning needs a more sophisticated algorithm
"when number of columns > 9, vim's resizing algorithm changes, and Readjust() needs a more sophisticated algorthm


nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>

nno <c-d> :call Readjust()<cr>
fun! Readjust()
	let [col0,win0]=[get(g:NAV_IX,bufname(winbufnr(0)),-1),winnr()]
   	let screentopline=line('w0')
	if col0==-1
		echoer "Current window not registered in NAV_IX"
		return
	en
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,(col0-1)%len(g:NAV_SIZE),0]
	let remain=split0
	while remain>=1
		let remain-=g:NAV_SIZE[colt]+1
		let colt=(colt-1)%len(g:NAV_SIZE)
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[(col0+1)%len(g:NAV_SIZE),&columns-(split0>0? split0+1+g:NAV_SIZE[col0] : min([winwidth(1),g:NAV_SIZE[col0]])),1]
	while remain>=2
		let remain-=g:NAV_SIZE[colb]+1
		let colb=(colb+1)%len(g:NAV_SIZE)
		let colsRight+=1
	endwhile
	let colbw=g:NAV_SIZE[colb]+remain
	echon "L,R,$:" colsLeft '/' colsRight '/' winnr('$') ' split0:' split0
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%len(g:NAV_SIZE)
		for i in range(dif)
			let colt=(colt-1)%len(g:NAV_SIZE)
			exe 'topl vsp '.g:NAV_NAMES[colt]
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
	echon " difL:" dif
	if dif>0
		let colb=(col0+colsRight-1-dif)%len(g:NAV_SIZE)
		for i in range(dif)
			let colb=(colb+1)%len(g:NAV_SIZE)
			exe 'botr vsp '.g:NAV_NAMES[colb]
			exe g:NAV_EXE[colb]
			se wfw
		endfor
	elseif dif<0
		wincmd b
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	echon " difR:" dif " exp/actual winnr:" colsRight+colsLeft '/' winnr('$')
	windo se nowfw
    wincmd b
	if g:NAV_SIZE[colb]!=colbw
		exe 'vert res' colbw
	en
	se wfw
	let curwinnr=winnr()
	wincmd h
	while winnr()!=curwinnr
		se wfw
		let curwinnr=winnr()
		if curwinnr==1
			let offset=g:NAV_SIZE[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		elseif g:NAV_SIZE[(colt+curwinnr-1)%len(g:NAV_SIZE)]!=winwidth(curwinnr)
			exe curwinnr 'wincmd w'
			exe 'vert res' g:NAV_SIZE[(colt+curwinnr-1)%len(g:NAV_SIZE)]
			norm! 0
		en
		wincmd h
	endw
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
				let g:LCol=get(g:NAV_IX,bufname(winbufnr(1)),-99999)
			else
				let [nx,ny]=eval(nx_expr)
				if x && nx && x-nx
					let lcolprev=g:LCol
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
	ec "Panning complete"
endfun

fun! GetPlanePos()
	let [g:LCol,g:RCol,g:LOff]=[get(g:NAV_IX,bufname(winbufnr(1)),-99999),get(g:NAV_IX,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? g:LOff : virtcol('.')-wincol()) : (g:NAV_SIZE[g:LCol]>winwidth(1)? g:NAV_SIZE[g:LCol]-winwidth(1) : 0)]
	return g:LCol+g:RCol<0
endfun

fun! TogglePanMode(...)
	if a:0>0
		if a:1 && exists('t:mouse_pans_columns')
    		unlet t:mouse_pans_columns
		elseif !a:1
			let t:mouse_pans_columns=1
		en
	en
	if !exists('t:mouse_pans_columns')
		let t:mouse_pans_columns=1
		windo se wfw
		se sidescroll=1 mouse=a lz noea nosol scrollopt=ver,jump wiw=1 wmw=0 ve=all
		wincmd t
		let prev_winnr=0
		let screentopline=line('w0')
		while winnr()!=prev_winnr
		   let col=get(g:NAV_IX,bufname(winbufnr(winnr())),-1)
		   if col==-1
				echohl WarningMsg
		   		ec "ERROR: ".bufname(winbufnr(winnr()))." not registered in NAV_NAMES; column panning disabled"
				echohl None
				unlet t:mouse_pans_columns
				return
		   en
		   exe g:NAV_EXE[col]
		   let screentopline=line('w0')
		   let prev_winnr=winnr()
		   wincmd l
		endwhile
		echo "Column panning enabled"
	else
		unlet t:mouse_pans_columns
		echo "Column panning disabled"
	en
endfun
fun! InitPlane(...)
	let g:opt_disable_syntax_while_panning=1
	se sidescroll=1 mouse=a lz noea nosol scrollopt=ver,jump wiw=1 wmw=0 ve=all
	if exists("a:1")
		if type(a:1)==1 	"(string name, [int min, int max, list Sizes, list Settings, LCol, LOff])
			let g:NAV_NAMES=split(glob(a:1),"\n")
	   		let min=exists("a:2")? a:2 : 0
			let max=exists("a:3")? a:3>0 && a:3<=len(g:NAV_NAMES)? a:3 : len(g:NAV_NAMES) : len(g:NAV_NAMES)
			let g:NAV_NAMES=g:NAV_NAMES[min : max]
            let g:NAV_SIZE=exists("a:4")? a:4 : repeat([60],len(g:NAV_NAMES))
			let g:LCol=exists("a:6")? a:6 : 0
			let g:LOff=exists("a:7")? a:7 : 0
		elseif type(a:1)==3 "(list Names, list Sizes,[int leftcol, int offset, list Settings])
			let g:NAV_NAMES=a:1
            let g:NAV_SIZE=exists("a:2")? a:2 : repeat([60],len(g:NAV_NAMES))
			let g:LCol=exists("a:3")? a:3 : 0
			let g:LOff=exists("a:4")? a:4 : 0
		en
		let g:NAV_EXE=exists("a:5")? a:5 : repeat(['exe "norm! ".screentopline."Gzt" | se nowrap scb cole=2'],len(g:NAV_NAMES))
	en
	let [g:NAV_IX,i]=[{},0]
	for e in g:NAV_NAMES
		let [g:NAV_IX[e],i]=[i,i+1]
	endfor
	exe 'tabe '.g:NAV_NAMES[g:LCol]
	let screentopline=1
	exe g:NAV_EXE[g:LCol]
    exe 'norm! 0'.(g:LOff? g:LOff.'zl' : '')
	let spaceremaining=&columns-g:NAV_SIZE[g:LCol]-g:LOff
	let NextCol=(g:LCol+1)%len(g:NAV_NAMES)
	while spaceremaining>=2
		se scrollopt=
		let screentopline=line('w0')
		exe 'bot '.(spaceremaining-1).'vsp '.(g:NAV_NAMES[NextCol])
		exe g:NAV_EXE[NextCol]
		se scrollopt=ver,jump
		norm! 0
		let spaceremaining-=g:NAV_SIZE[NextCol]+1
		let NextCol=(NextCol+1)%len(g:NAV_NAMES)
	endwhile
	windo se wfw
	let t:mouse_pans_columns=1
	let namew=min([&columns/2,max(map(range(len(g:NAV_NAMES)),'len(g:NAV_NAMES[v:val])'))])
	let exew=&columns-namew-7
	echo "\n W -"." NAME -----------------------------------------------------------------------------------------------------------"[:namew]." AUTOEXE -----------------"[:exew]."\n".join(map(range(len(g:NAV_NAMES)),'printf(" %-3d %-".namew.".".namew."S %.".exew."s",g:NAV_SIZE[v:val],g:NAV_NAMES[v:val],g:NAV_EXE[v:val])'),"\n")
endfun

fun! PanLeft(N)
	let [g:extrashiftamt,g:LCol]=[0,get(g:NAV_IX,bufname(winbufnr(1)),-1)]
	if g:LCol<0
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
		while winwidth(0)>=g:NAV_SIZE[g:LCol]+2
			se nowfw scrollopt=jump
			let [nextcol,screentopline]=[(g:LCol-1)%len(g:NAV_NAMES),line('w0')]
			exe 'lefta '.(winwidth(0)-g:NAV_SIZE[g:LCol]-1).'vsp '.g:NAV_NAMES[nextcol]
			exe g:NAV_EXE[nextcol]
			wincmd l
			se wfw
			norm! 0
			wincmd t
			let g:LCol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
		let offset=g:NAV_SIZE[g:LCol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (g:NAV_SIZE[g:LCol]>winwidth(1)? g:NAV_SIZE[g:LCol]-winwidth(1) : 0)-a:N-g:extrashiftamt
		if loff>=-1
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			while loff<=-2
				let g:LCol=(g:LCol-1)%len(g:NAV_NAMES)
				let loff+=g:NAV_SIZE[g:LCol]+1
			endwhile
			se scrollopt=jump
			let screentopline=line('w0')
			exe 'e '.g:NAV_NAMES[g:LCol]
			exe g:NAV_EXE[g:LCol]
			se scrollopt=ver,jump
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
			if g:NAV_SIZE[g:LCol]-loff<&columns-1
				let spaceremaining=&columns-g:NAV_SIZE[g:LCol]+loff
				let NextCol=(g:LCol+1)%len(g:NAV_NAMES)
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
	let [g:LCol,g:RCol,g:LOff,g:extrashiftamt,N]=[get(g:NAV_IX,bufname(winbufnr(1)),-99999),get(g:NAV_IX,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (g:NAV_SIZE[g:LCol]>winwidth(1)? g:NAV_SIZE[g:LCol]-winwidth(1) : 0),0,a:N]
	if g:LCol+g:RCol<0
		return 1
	elseif N>=&columns
		if winwidth(1)==&columns
        	let g:LOff+=&columns
		else
			let g:LOff=winwidth(winnr('$'))
			let g:RCol=g:LCol
		en
		if g:LOff>=g:NAV_SIZE[g:LCol]
			let g:LOff=0
			let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
		en
		let toshift=N-&columns
		if toshift>=g:NAV_SIZE[g:LCol]-g:LOff+1
			let toshift-=g:NAV_SIZE[g:LCol]-g:LOff+1
			let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
			while toshift>=g:NAV_SIZE[g:LCol]+1
				let toshift-=g:NAV_SIZE[g:LCol]+1
				let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
			endwhile
			if toshift==g:NAV_SIZE[g:LCol]
				let N+=1
   				let g:extrashiftamt=-1
				let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:NAV_SIZE[g:LCol]-g:LOff
			let N+=1
   			let g:extrashiftamt=-1
			let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
			let g:LOff=0
		else
			let g:LOff+=toshift	
		en
		let screentopline=line('w0')
		se scrollopt=jump
		exe 'e '.g:NAV_NAMES[g:LCol]
		exe g:NAV_EXE[g:LCol]
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
			let g:LCol=(g:LCol+1)%len(g:NAV_NAMES)
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
		let offset=g:NAV_SIZE[g:LCol]-winwidth(1)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		while winwidth(winnr('$'))>=g:NAV_SIZE[g:RCol]+2
			wincmd b
			se nowfw scrollopt=jump
			let nextcol=(g:RCol+1)%len(g:NAV_NAMES)
			let screentopline=line('w0')
			exe 'rightb vert '.(winwidth(0)-g:NAV_SIZE[g:RCol]-1).'split '.g:NAV_NAMES[nextcol]
			exe g:NAV_EXE[nextcol]
			wincmd h
			se wfw
			wincmd b
			norm! 0
			let g:RCol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
	elseif &columns-g:NAV_SIZE[g:LCol]+g:LOff>=2
		let g:RCol=g:LCol
		let spaceremaining=&columns-g:NAV_SIZE[g:LCol]+g:LOff
		se nowfw scrollopt=jump
		while spaceremaining>=2
			let g:RCol=(g:RCol+1)%len(g:NAV_NAMES)
			let screentopline=line('w0')
			exe 'bot '.(spaceremaining-1).'vsp '.(g:NAV_NAMES[g:RCol])
			exe g:NAV_EXE[g:RCol]
			norm! 0
			let spaceremaining-=g:NAV_SIZE[g:RCol]+1
		endwhile
		se scrollopt=ver,jump
		windo se wfw
	en
endfun
