"          TEXT-PLANE: An 2 dimensional text editing workspace in vim

"                             --- Basic usage ---

" CreatePlane(string filepattern) will create a plane, which can be loaded
"   with LoadPlane(), eg,
"    :call LoadPlane(CreatePlane('col-*'))
"   This will load a files matching 'col-*', eg, col-01, col-02, col-end

" Activate keyboard panning by calling KeyboardPan(), default mapped to
"   f3, then use the 'roguelike' keys (hjklyubn) to pan the plane. Or you can
"   pan with the mouse. (The existence of the variable t:mouse_pans_columns
"   determines whether the mouse pans columns or the current window)

" Restore a plane by opening any valid column (will load to that position) or
"   any window (such as a blank tab) and evoking
"    :call LoadPlane(CreatePlane('col-*'))

" Save a plane between sessions by storing it to a global variable
"    :let MY_PLANE=CreatePlane('col-*')
"   but keep in mind that MY_PLANE is a nested dictionary that will be
"   converted to a dictionary of strings when stored in a viminfo file in
"   between sessions, which will then have to be reinflated.

" Call LoadPlane() with no arguments to redraw and 'clean up' the
"   current plane according to the position of the currently active split.

"                               --- Upcoming ---

"Workflow videos +"memory excising, blocks" +jrpgs
"Line number anchors
"Insert / delete column (have redraw check file names) / edit settings
"OnResize autocommands
"GetPlanePos(), GoPlanePos()
"NormalizePlane(len) to make columns equal length / autonormalize
"or... an actual path, with corners?? or better... with leaps?
"Jumps: Remap `' / bookmarks <plane-006:111> or <*006:111>
"Changelist functionality

"                           --- Known issues ---

"Assumes no horizontal splits
"Vim unable to detect mouse events when absolute x cursor is greater than 253
"When number of columns > 9 vim's split resizing algorithm changes and a
"    slightly more sophisticated algorithm is needed
"When column lengths are unequal (greater than a screen height) the columns
"    may become misaligned. Use :syncbind or :call LoadPlane() to redraw
"Redrawing via LoadPlane() will always position cursor in middle of screen due
"    to hackish workaround to vim syncbind bug

"Email q335r49 at gmail dot com for any suggestions, bugs, etc.

nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
nn <f3> :call KeyboardPan()<cr>
nn <f5> :call LoadPlane()<cr>

fun! Pan(dx,dy)
	if a:dx>0
		call PanRight(a:dx)
	elseif a:dx<0
		call PanLeft(-a:dx)
	en
	if a:dy>0
		if line('w0')==line('$')


		en
		exe 'norm!' a:dy."\<c-e>"
	elseif a:dy<0
		exe 'norm!' (-a:dy)."\<c-y>"
	en
endfun
fun! KeyboardPan()
	if !exists('t:txP')
		throw "t:txP doesn't exist, initialize with LoadPlane(CreatePlane(string filepattern))"
	en
	let c=getchar()
	while c!=27 && c!="\<f3>"
		exe get(g:keypdict,c,'')
		redr
		let c=getchar()
	endwhile
endfun
let keypdict={104:'call Pan(-2,0)',106:'call Pan(0,2)',107:'call Pan(0,-2)',108:'call Pan(2,0)',
\121:'call Pan(-1,-1)',117:'call Pan(1,-1)',98:'call Pan(-1,1)',110:'call Pan(1,1)'}

fun! CreatePlane(name,...)
	let plane={}
	if type(a:name)==1
		let plane.name=split(glob(a:name),"\n")
    elseif type(a:name)==3
   		let plane.name=a:name
   	else
     	throw "Argument must be: (string filepattern or list Names, [list Sizes, list Settings])
	en
   	let plane.len=len(plane.name)
	let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
	let plane.exe=exists("a:2")? a:2 : repeat(['exe "norm! ".screentopline."Gzt" | se nowrap scb cole=2'],plane.len)
	let [plane.ix,i]=[{},0]
	for e in plane.name
		let [plane.ix[e],i]=[i,i+1]
	endfor
	let namew=min([&columns/2,max(map(range(plane.len),'len(plane.name[v:val])'))])
	let exew=&columns-namew-7
	echo "\n W -"." NAME -----------------------------------------------------------------------------------------------------------"[:namew]." AUTOEXE -----------------"[:exew]."\n".join(map(range(plane.len),'printf(" %-3d %-".namew.".".namew."S %.".exew."s",plane.size[v:val],plane.name[v:val],plane.exe[v:val])'),"\n")
	return plane
endfun

fun! LoadPlane(...)
    if a:0
    	let t:txP=a:1
		se sidescroll=1 mouse=a lz noea nosol wiw=1 wmw=0 ve=all
	 	let t:mouse_pans_columns=1
	elseif !exists("t:txP")
    	throw "Plane not yet loaded, call LoadPlane(CreatePlane(string filepattern))"
	en
	let [col0,win0]=[get(t:txP.ix,bufname(winbufnr(0)),a:0? 'reload' : 'abort'),winnr()]
	if col0 is 'abort'
   		throw "Current window not registered in t:txP.ix"
	elseif col0 is 'reload'
   		let col0=0
		only
   		exe 'e' t:txP.name[0] 
	en
	norm! M
	let screentopline=line('w0')
	let possav=[bufnr('%'),screentopline,line('.'),virtcol('.')]
	se scrollopt=jump
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0%t:txP.len,0]
	let remain=split0
	while remain>=1
		let remain-=t:txP.size[colt]+1
		let colt=(colt-1)%len(t:txP.size)
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%len(t:txP.size),&columns-(split0>0? split0+1+t:txP.size[col0] : min([winwidth(1),t:txP.size[col0]])),1]
	while remain>=2
		let remain-=t:txP.size[colb]+1
		let colb=(colb+1)%len(t:txP.size)
		let colsRight+=1
	endwhile
	let colbw=t:txP.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%len(t:txP.size)
		for i in range(dif)
			let colt=(colt-1)%len(t:txP.size)
			exe 'top vsp '.t:txP.name[colt]
			exe t:txP.exe[colt]
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
		let colb=(col0+colsRight-1-dif)%len(t:txP.size)
		for i in range(dif)
			let colb=(colb+1)%len(t:txP.size)
			exe 'bot vsp '.t:txP.name[colb]
			exe t:txP.exe[colb]
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
	let [bot,cwin]=[winnr(),0]
	while winnr()!=cwin
		se wfw
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txP.len]
		if expand('%:p')!=#fnamemodify(t:txP.name[ccol],":p")
	   		call input('Reloading file '.t:txP.name[ccol].' in window number '.winnr())
			exe 'e' t:txP.name[ccol] 
			exe t:txP.exe[ccol]
		elseif a:0
			exe t:txP.exe[ccol]
		en
		if cwin==1
			let offset=t:txP.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(cwin==bot? colbw : t:txP.size[ccol])-winwidth(cwin)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		wincmd h
	endw
	exe bufwinnr(possav[0]).'wincmd w|norm! '.possav[1].'Gzt'.possav[2].'G'.possav[3].'|'
	se scrollopt=ver,jump
	syncbind
endfun

fun! DeleteHiddenBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' buf
    endfor
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
		if !exists('t:txP')
			throw "t:txP doesn't exist, initialize with LoadPlane(CreatePlane(string filepattern))"
		el
			ec 'Panning...'
		en
		let win0=-1
		while getchar()!="\<leftrelease>"
			if v:mouse_win!=win0
				let win0=v:mouse_win
				exe v:mouse_win."wincmd w"
				let nx_expr=&wrap? "[(v:mouse_col-1)%".winwidth(v:mouse_win).",v:mouse_lnum]" : "[v:mouse_col-".(virtcol('.')-wincol()).",v:mouse_lnum]"
				let [x,y]=eval(nx_expr)
				let tcol=get(t:txP.ix,bufname(winbufnr(1)),-99999)
			else
				let [nx,ny]=eval(nx_expr)
				if x && nx && x-nx
					let lcolprev=tcol
					let possav=[bufnr('%'),line('w0'),line('.'),virtcol('.')]
					call Pan{nx>x? "Left" : "Right"}(abs(nx-x))
					exe bufwinnr(possav[0]).'wincmd w|norm! '.possav[1].'Gzt'.possav[2].'G'.possav[3].'|'
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

fun! PanLeft(N)
	let [extrashift,tcol]=[0,get(t:txP.ix,bufname(winbufnr(1)),-1)]
	if tcol<0
   		throw bufname(winbufnr(1))." not registered in t:txP.ix, call LoadPlane(CreatePlane(string filepattern))"
	elseif a:N<&columns
		while winwidth(winnr('$'))<=a:N
	   		wincmd b
			let extrashift=(winwidth(0)==a:N)
			hide
		endw
	el
		wincmd t
		only
	en
	if winwidth(0)!=&columns
		wincmd t	
		if winwidth(winnr('$'))<=a:N+3+extrashift
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
			en
			se wfw
		else
			exe 'vert res+'.(a:N+extrashift)
		en
		while winwidth(0)>=t:txP.size[tcol]+2
			se nowfw scrollopt=jump
			let [nextcol,screentopline]=[(tcol-1)%t:txP.len,line('w0')]
			exe 'top '.(winwidth(0)-t:txP.size[tcol]-1).'vsp '.t:txP.name[nextcol]
			exe t:txP.exe[nextcol]
			wincmd l
			se wfw
			norm! 0
			wincmd t
			let tcol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
		let offset=t:txP.size[tcol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (t:txP.size[tcol]>winwidth(1)? t:txP.size[tcol]-winwidth(1) : 0)-a:N-extrashift
		if loff>=-1
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			while loff<=-2
				let tcol=(tcol-1)%t.txP.len
				let loff+=t:txP.size[tcol]+1
			endwhile
			se scrollopt=jump
			let screentopline=line('w0')
			exe 'e '.t:txP.name[tcol]
			exe t:txP.exe[tcol]
			se scrollopt=ver,jump
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
			if t:txP.size[tcol]-loff<&columns-1
				let spaceremaining=&columns-t:txP.size[tcol]+loff
				let NextCol=(tcol+1)%len(t:txP.name)
				se nowfw scrollopt=jump
				while spaceremaining>=2
					let screentopline=line('w0')
					exe 'bot '.(spaceremaining-1).'vsp '.(t:txP.name[NextCol])
					exe t:txP.exe[NextCol]
					norm! 0
					let spaceremaining-=t:txP.size[NextCol]+1
					let NextCol=(NextCol+1)%len(t:txP.name)
				endwhile
				se scrollopt=ver,jump
				windo se wfw
			en
		en
	en
	return extrashift
endfun

fun! PanRight(N)
	let tcol=get(t:txP.ix,bufname(winbufnr(1)),-99999)
	let [bcol,loff,extrashift,N]=[get(t:txP.ix,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? 0 : virtcol('.')-wincol()) : (t:txP.size[tcol]>winwidth(1)? t:txP.size[tcol]-winwidth(1) : 0),0,a:N]
	if tcol+bcol<0
		throw bufname(winbufnr(1))." or ".bufname(winbufnr('$'))." not registered in t:txtPln.ix"
	elseif N>=&columns
		if winwidth(1)==&columns
        	let loff+=&columns
		else
			let loff=winwidth(winnr('$'))
			let bcol=tcol
		en
		if loff>=t:txP.size[tcol]
			let loff=0
			let tcol=(tcol+1)%len(t:txP.name)
		en
		let toshift=N-&columns
		if toshift>=t:txP.size[tcol]-loff+1
			let toshift-=t:txP.size[tcol]-loff+1
			let tcol=(tcol+1)%len(t:txP.name)
			while toshift>=t:txP.size[tcol]+1
				let toshift-=t:txP.size[tcol]+1
				let tcol=(tcol+1)%len(t:txP.name)
			endwhile
			if toshift==t:txP.size[tcol]
				let N+=1
   				let extrashift=-1
				let tcol=(tcol+1)%len(t:txP.name)
				let loff=0
			else
				let loff=toshift
			en
		elseif toshift==t:txP.size[tcol]-loff
			let N+=1
   			let extrashift=-1
			let tcol=(tcol+1)%len(t:txP.name)
			let loff=0
		else
			let loff+=toshift	
		en
		let screentopline=line('w0')
		se scrollopt=jump
		exe 'e '.t:txP.name[tcol]
		exe t:txP.exe[tcol]
		se scrollopt=ver,jump
		only
		exe 'norm! 0'.(loff>0? loff.'zl' : '')
	else
		let shifted=0
		while winwidth(1)<=N
			let extrashift=winwidth(1)==N
			wincmd t
			hide
			let shifted+=winwidth(0)+1
			let tcol=(tcol+1)%len(t:txP.name)
			let loff=0
		endw
   		let N+=extrashift
		let loff+=N-shifted
	en
	let wf=winwidth(1)-N
	if wf+N!=&columns
		wincmd b
		exe 'vert res+'.N
		wincmd t	
		if winwidth(1)!=wf
			exe 'vert res'.wf
		en
		let offset=t:txP.size[tcol]-winwidth(1)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		while winwidth(winnr('$'))>=t:txP.size[bcol]+2
			wincmd b
			se nowfw scrollopt=jump
			let nextcol=(bcol+1)%len(t:txP.name)
			let screentopline=line('w0')
			exe 'rightb vert '.(winwidth(0)-t:txP.size[bcol]-1).'split '.t:txP.name[nextcol]
			exe t:txP.exe[nextcol]
			wincmd h
			se wfw
			wincmd b
			norm! 0
			let bcol=nextcol
			se wfw scrollopt=ver,jump
		endwhile
	elseif &columns-t:txP.size[tcol]+loff>=2
		let bcol=tcol
		let spaceremaining=&columns-t:txP.size[tcol]+loff
		se nowfw scrollopt=jump
		while spaceremaining>=2
			let bcol=(bcol+1)%len(t:txP.name)
			let screentopline=line('w0')
			exe 'bot '.(spaceremaining-1).'vsp '.(t:txP.name[bcol])
			exe t:txP.exe[bcol]
			norm! 0
			let spaceremaining-=t:txP.size[bcol]+1
		endwhile
		se scrollopt=ver,jump
		windo se wfw
	en
	return extrashift
endfun
