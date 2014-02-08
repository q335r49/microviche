"assume ve is on, remove all calls to cursor()
"move scrollopt outside of while loop
"switch mousenav loop back to <leftdrag> test
"test NavLeft / NavRight for &wrap
"replace norm zl with absolute shifts based on offset
"fun savenavpos restorenavpos > reset on resize, cleanup
"* optimization: pan without redrawing (easy)
"append(file, width, [position])
"fun SetToCurrent (size, settings)
"known bug: can't select far right columns when zoomed out

nno <silent> <c-j> :<c-u>call NavLeft(v:count? v:count : 5)<cr>
nno <silent> <c-k> :<c-u>call NavRight(v:count? v:count : 5)<cr>

fun! NavRight(N)
 	let N=a:N
	if N<winwidth(0)-wincol()
		call cursor(line('.'),1,virtcol('.')+N-1)
  	el
		let N-=winwidth(0)-wincol()
		let screenshift=winline()-1
		while N>=0
			let curwinnr=winnr()
			wincmd l
			if winnr()==curwinnr
				call PanRight(N)
				exe "norm! \<c-w>bH".(screenshift? screenshift.'gjg$' : 'g$')
				break
			elseif N<winwidth(0)
				norm! g0
				call cursor(line('w0'),1,&wrap? virtcol('.')%winwidth(0)+N-1 : virtcol('.')+N-1)
				if screenshift
					exe 'norm! '.screenshift.'gj'
				en
				break
			else
				let N-=winwidth(0)
			en
		endwhile
	en
endfun
fun! NavLeft(N)
 	let N=a:N
	if N<wincol()
		call cursor(line('.'),1,virtcol('.')-N-1)
	el
		let N-=wincol()
		let screenshift=winline()-1
		while N>=0
			let curwinnr=winnr()
			wincmd h
			if winnr()==curwinnr
				call PanLeft(N) 	
				exe "norm! \<c-w>tH".(screenshift? screenshift.'gjg0' : 'g0')
				break
			elseif N<winwidth(0)
				norm! g$
				call cursor(line('w0'),1,&wrap? virtcol('.')%winwidth(0)-N-1 : virtcol('.')-N-1)
				if screenshift
					exe 'norm! '.screenshift.'gj'
				en
				break
			else
				let N-=winwidth(0)
			en
		endw	
	en
endfun

fun! MouseNav()
	let win0=-1
	let frame=0
	while getchar()!="\<leftrelease>"
		let frame+=1
		if frame%3
			continue
		elseif v:mouse_win!=win0
			exe v:mouse_win."wincmd w"
			let [offset,win0]=[virtcol('.')-wincol(),v:mouse_win]
		   	let nx_expr=&wrap? "[(v:mouse_col-1)%winwidth(v:mouse_win),v:mouse_lnum]" : "[v:mouse_col-offset,v:mouse_lnum]"
			let [x,y]=eval(nx_expr)
		else
			let [nx,ny]=eval(nx_expr)
			if x && nx && x-nx
				let lcolprev=g:LCol
				if Pan{nx>x? "Left" : "Right"}(abs(nx-x))
			   		echoerr "Filename not found in NavNames; switching to pan window mode"
                   	call ToggleMousePanMode('pan')
				   	break
				en
				let x=g:extrashiftamt+(win0==1 && nx>x && g:LCol==lcolprev? g:LCol==lcolprev? nx : x-winwidth(1)-1 : x)
			elseif !x
				let x=nx
			en
   			if ny!=y
   				exe 'norm! '.(winnr()!=win0? win0."\<c-w>w" : "").(ny>y? (ny-y)."\<c-y>" : (y-ny)."\<c-e>")
			en
			redr | echo frame
		en
	endwhile
	exe v:mouse_win."wincmd w"
	call cursor(v:mouse_lnum,1,v:mouse_col)
endfun

fun! ToggleMousePanMode(...)
	if a:0>0
	 	let panmode=a:1
	else
		redir => panmode
			silent nn <leftmouse>
		redir END
		let panmode=panmode=~?'nav'? 'off' : panmode=~?'pan'? 'nav' : 'pan'
	en
	if panmode=~?'nav'
  		nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MouseNav()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
  		echo "Mouse drag navigates columns"
	elseif panmode=~?'pan'
	   	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	   	echo "Mouse drag pans window"
	else
   		nunmap <leftmouse>
   		echo "Mouse drag panning disabled"
	en
endfun

fun! GetPlanePos()
	let [g:LCol,g:RCol,g:LOff]=[get(g:NavDic,bufname(winbufnr(1)),-99999),get(g:NavDic,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? g:LOff : virtcol('.')-wincol()) : (g:NavSizes[g:LCol]>winwidth(1)? g:NavSizes[g:LCol]-winwidth(1) : 0)]
	return g:LCol+g:RCol<0
endfun

fun! InitPlane(...)
	se scrollopt=ver,jump
	if exists("a:1")
		if type(a:1)==1 	"(string name, [int min, int max, list Sizes, list Settings, LCol, LOff])
			let g:NavNames=split(glob(a:1),"\n")
	   		let min=exists("a:2")? a:2 : 0
			let max=exists("a:3")? a:3>0 && a:3<=len(g:NavNames)? a:3 : len(g:NavNames) : len(g:NavNames)
			let g:NavNames=g:NavNames[min : max]
            let g:NavSizes=exists("a:4")? a:4 : repeat([60],len(g:NavNames))
			let g:LCol=exists("a:6")? a:6 : 0
			let g:LOff=exists("a:7")? a:7 : 0
		elseif type(a:1)==3 "(list Names, list Sizes,[int leftcol, int offset, list Settings])
			let g:NavNames=a:1
            let g:NavSizes=exists("a:2")? a:2 : repeat([60],len(g:NavNames))
			let g:LCol=exists("a:3")? a:3 : 0
			let g:LOff=exists("a:4")? a:4 : 0
		en
		let g:NavSettings=exists("a:5")? a:5 : repeat(['exe "norm! ".screentopline."Gzt" | se nowrap scb'],len(g:NavNames))
	en
	let [g:NavDic,i]=[{},0]
	for e in g:NavNames
		let [g:NavDic[e],i]=[i,i+1]
	endfor
	se wiw=1 wmw=0 ve=all
	exe 'tabe '.g:NavNames[g:LCol]
	let screentopline=1
	exe g:NavSettings[g:LCol]
    exe 'norm! 0'.(g:LOff? g:LOff.'zl' : '')
	let spaceremaining=&columns-g:NavSizes[g:LCol]-g:LOff
	let NextCol=(g:LCol+1)%len(g:NavNames)
	while spaceremaining>=2
		se scrollopt=
		let screentopline=line('w0')
		exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[NextCol])
		exe g:NavSettings[NextCol]
		se scrollopt=ver,jump
		norm! 0
		let spaceremaining-=g:NavSizes[NextCol]+1
		let NextCol=(NextCol+1)%len(g:NavNames)
	endwhile
	windo se wfw
	let t:NavPlane=1
	let t:MouseNav=1
endfun

fun! PanLeft(N)
	let [g:LCol,g:LOff]=[get(g:NavDic,bufname(winbufnr(1)),-1),winwidth(1)==&columns? (&wrap? g:LOff : virtcol('.')-wincol()) : (g:NavSizes[g:LCol]>winwidth(1)? g:NavSizes[g:LCol]-winwidth(1) : 0)]
	if g:LCol<0
		return 1
	en
   	let [N,g:extrashiftamt]=[a:N,0]
	if N>=&columns
		wincmd t | only
	el
		wincmd b
		while winwidth(0)<N
			hide
		endw
		if winwidth(0)==N
			hide
			let [N,g:extrashiftamt]=[N+1,1]
		en
	en
	let [w0,g:LOff]=[winwidth(0),g:LOff-N]
	if w0!=&columns
		wincmd t
		exe N.'wincmd >'
		if w0-winwidth(winnr('$'))!=N
			wincmd b	
			exe (N-w0+winwidth(0)).'wincmd <'
			wincmd t
		en
		while winwidth(0)>=g:NavSizes[g:LCol]+2
			let NextWindow=(g:LCol-1)%len(g:NavNames)
			se nowfw scrollopt=
			let screentopline=line('w0')
			exe 'lefta '.(winwidth(0)-g:NavSizes[g:LCol]-1).'vsp '.g:NavNames[NextWindow]
			exe g:NavSettings[NextWindow]
			se scrollopt=ver,jump
			wincmd l
			se wfw
			norm 0
			wincmd t
			se wfw
			let g:LCol=NextWindow
		endwhile
		exe 'norm! 0'.(winwidth(0)<g:NavSizes[g:LCol]? g:NavSizes[g:LCol]-winwidth(0).'zl' : '')
		let g:LOff=max([0,g:NavSizes[g:LCol]-winwidth(0)])
	elseif g:LOff>=-1
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		while g:LOff<=-2
			let g:LCol=(g:LCol-1)%len(g:NavNames)
			let g:LOff+=g:NavSizes[g:LCol]+1
		endwhile
		se scrollopt=
		let screentopline=line('w0')
		exe 'e '.g:NavNames[g:LCol]
   		exe g:NavSettings[g:LCol]
		se scrollopt=ver,jump
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
		if g:NavSizes[g:LCol]-g:LOff<&columns-1
			let spaceremaining=&columns-g:NavSizes[g:LCol]+g:LOff
			let NextCol=(g:LCol+1)%len(g:NavNames)
			while spaceremaining>=2
				se nowfw scrollopt=
				let screentopline=line('w0')
				exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[NextCol])
		   		exe g:NavSettings[NextCol]
			    se scrollopt=ver,jump
				norm! 0
				let spaceremaining-=g:NavSizes[NextCol]+1
				let NextCol=(NextCol+1)%len(g:NavNames)
			endwhile
			windo se wfw
		en
	en
endfun

fun! PanRight(N)
	let [g:LCol,g:RCol,g:LOff]=[get(g:NavDic,bufname(winbufnr(1)),-99999),get(g:NavDic,bufname(winbufnr(winnr('$'))),-99999),winwidth(1)==&columns? (&wrap? g:LOff : virtcol('.')-wincol()) : (g:NavSizes[g:LCol]>winwidth(1)? g:NavSizes[g:LCol]-winwidth(1) : 0)]
	if g:LCol+g:RCol<0
		return 1
	en
   	let g:extrashiftamt=0
	let N=a:N
	if N>=&columns
		if winwidth(1)==&columns
        	let g:LOff+=&columns
		else
			let g:LOff=winwidth(winnr('$'))
			let g:LCol=g:RCol
		en
		if g:LOff>=g:NavSizes[g:LCol]
			let g:LOff=0
			let g:LCol=(g:LCol+1)%len(g:NavNames)
		en
		let toshift=N-&columns
		if toshift>=g:NavSizes[g:LCol]-g:LOff+1
			let toshift-=g:NavSizes[g:LCol]-g:LOff+1
			let g:LCol=(g:LCol+1)%len(g:NavNames)
			while toshift>=g:NavSizes[g:LCol]+1
				let toshift-=g:NavSizes[g:LCol]+1
				let g:LCol=(g:LCol+1)%len(g:NavNames)
			endwhile
			if toshift==g:NavSizes[g:LCol]
				let N+=1
   				let g:extrashiftamt=-1
				let g:LCol=(g:LCol+1)%len(g:NavNames)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:NavSizes[g:LCol]-g:LOff
			let N+=1
   			let g:extrashiftamt=-1
			let g:LCol=(g:LCol+1)%len(g:NavNames)
			let g:LOff=0
		else
			let g:LOff+=toshift	
		en
		let screentopline=line('w0')
		se scrollopt=
		exe 'e '.g:NavNames[g:LCol]
		exe g:NavSettings[g:LCol]
		se scrollopt=ver,jump
		only
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		wincmd t
		let shifted=0
		while winwidth(0)<N
			hide
			let shifted+=winwidth(0)+1
			let g:LCol=(g:LCol+1)%len(g:NavNames)
			let g:LOff=0
		endw
		if winwidth(0)==N
			hide
			let N+=1
   			let g:extrashiftamt=-1
			let shifted+=winwidth(0)+1
			let g:LCol=(g:LCol+1)%len(g:NavNames)
			let g:LOff=0
		en
		let g:LOff+=N-shifted
	en
	let w0=winwidth(1)
	if w0!=&columns
		wincmd b
		exe N.'wincmd >'
		wincmd t	
		if w0-winwidth(1)!=N
			exe (N-w0+winwidth(0)).'wincmd <'
		en
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
		wincmd b
		let g:LOff=max([0,g:NavSizes[g:LCol]-winwidth(1)])
		while winwidth(0)>=g:NavSizes[g:RCol]+2
			let NextWindow=(g:RCol+1)%len(g:NavNames)
			se nowfw scrollopt=
			let screentopline=line('w0')
			exe 'rightb vert '.(winwidth(0)-g:NavSizes[g:RCol]-1).'split '.g:NavNames[NextWindow]
			exe g:NavSettings[NextWindow]
			se scrollopt=ver,jump
			wincmd h
			se wfw
			wincmd b
			se wfw
			norm 0
			let g:RCol=NextWindow
		endwhile
	elseif &columns-g:NavSizes[g:LCol]+g:LOff>=2
		let g:RCol=g:LCol
		let spaceremaining=&columns-g:NavSizes[g:LCol]+g:LOff
		while spaceremaining>=2
			let g:RCol=(g:RCol+1)%len(g:NavNames)
			se nowfw scrollopt=
			let screentopline=line('w0')
			exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[g:RCol])
			exe g:NavSettings[g:RCol]
			se scrollopt=ver,jump
			norm! 0
			let spaceremaining-=g:NavSizes[g:RCol]+1
		endwhile
		windo se wfw
	en
endfun
