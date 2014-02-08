"simply need to pause when mouse switches windows instead of stay at the same window?
"...and activiate the current window
"append(file, width, [position])
"account for when an additional column is gained N->N+1
"/ later 
"try to get absolute coordinates for mouse
"map arrow keys to navigation for now?
"small pan
"init plane on startup (easy, just use all caps)
"need to optimize window movements first, maybe a return value based on whether restoring cursor position is possible
"restore window positions after panning with mouse!!!
"synergize with mousecursor / Navmode settings
"... the only problem here is changing windows ... but that shouldn't happen.
"/later
"bookmarks / goto file-line-column
"scb flag
"resize (by setcurrentsize)
"clean up plane / save
"optimizations: exe wrapcmd
"helpful fail messages for InitPlane
"SwitchNavMode
"PanLeft1, Panright1


fun! MouseNav()
	exe v:mouse_win."wincmd w"
	let winorig=v:mouse_win
	let offset=virtcol('.')-wincol()
	let [x,y]=[&wrap? (v:mouse_col-1)%winwidth(0) : v:mouse_col-offset,v:mouse_lnum]
	"let winoffset=winorig==1? 0 : eval(join(map(range(1,winorig-1),'winwidth(v:val)'),'+'))
	while getchar()=="\<leftdrag>"
		if v:mouse_win!=winorig
			exe v:mouse_win."wincmd w"
			let winorig=v:mouse_win
			let offset=virtcol('.')-wincol()
			let [x,y]=[&wrap? (v:mouse_col-1)%winwidth(0) : v:mouse_col-offset,v:mouse_lnum]
			"let winoffset=winorig==1? 0 : eval(join(map(range(1,winorig-1),'winwidth(v:val)'),'+'))
		else
			let [nx,ny]=[&wrap? (v:mouse_col-1)%winwidth(0) : v:mouse_col-offset,v:mouse_lnum]
			if !x
				let [x,y]=[nx,ny]
			elseif x && nx
				let [dx,dy]=[nx-x,ny-y]
				if dx>0
					call PanLeft(dx)
				elseif dx<0
					call PanRight(-dx)
				en
				if winorig==1
                	let [x,y]=[nx,ny]
				en
				redr | ec [x,y,nx,ny,dx,dy]
			en
		en
	endwhile
endfun
"nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MouseNav()==1? "keepj norm! \<lt>leftmouse>":"")<cr>

let g:NavNames=['test-10','test-20','test-40','test-80','test-60','test-150']
let g:NavDic={'test-10':0,'test-20':1,'test-40':2,'test-80':3,'test-60':4,'test-150':5}
let g:NavSizes=['10','20','40','80','60','150']
let [g:LCol,g:LOff]=[0,0]

fun! GetPlanePos()
	let g:LCol=g:NavDic[bufname(winbufnr(1))]
	let g:RCol=g:NavDic[bufname(winbufnr('$'))]
	let g:LOff=winwidth(1)==&columns? (&wrap? g:LOff : virtcol('.')-wincol()) : (g:NavSizes[g:LCol]>winwidth(1)? g:NavSizes[g:LCol]-winwidth(1) : 0)
endfun

fun! InitPlane(...)
	if exists("a:1")
		if type(a:1)==1 	"(string name, [int min, int max, list Sizes])
			let g:NavNames=split(glob(a:1),"\n")
	   		let min=exists("a:2")? a:2 : 0
			let max=exists("a:3")? a:3>0 && a:3<=len(g:NavNames)? a:3 : len(g:NavNames) : len(g:NavNames)
			let g:NavNames=g:NavNames[min : max]
            let g:NavSizes=exists("a:4")? a:4 : repeat([60],len(g:NavNames))
		elseif type(a:1)==3 "(list Names, list Sizes,[int leftcol, int offset])
			let g:NavNames=a:1
            let g:NavSizes=exists("a:2")? a:2 : repeat([60],len(g:NavNames))
			let g:LCol=exists("a:3")? a:3 : g:LCol
			let g:LOff=exists("a:4")? a:4 : g:LOff
		en
	en
  	let g:NavDic=IndexDic(g:NavNames)
	let [g:NavDic,i]=[{},0]
	for e in g:NavNames
		let [g:NavDic[e],i]=[i,i+1]
	endfor
	se wiw=1
	se wmw=0
	se ve=all
	exe 'tabe '.g:NavNames[g:LCol]
    exe 'norm! 0'.(g:LOff? g:LOff.'zl' : '')
	let spaceremaining=&columns-g:NavSizes[g:LCol]-g:LOff
	let NextCol=(g:LCol+1)%len(g:NavNames)
	while spaceremaining>=2
		exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[NextCol])
		norm! 0
		let spaceremaining-=g:NavSizes[NextCol]+1
		let NextCol=(NextCol+1)%len(g:NavNames)
	endwhile
	let g:RCol=(NextCol-1)%len(g:NavNames)
	windo se wfw
	let t:NavPlane=1
	let t:MouseNav=1
endfun

fun! PanLeft(N)
	call GetPlanePos()
	let N=a:N
	if N>=&columns
		wincmd t | only
	el
		wincmd b
		while winwidth(0)<N
			hide
			let g:RCol=(g:RCol-1)%len(g:NavNames)
		endw
		if winwidth(0)==N
			hide
			let N+=1
			let g:RCol-=1
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
			se nowfw
			exe 'lefta '.(winwidth(0)-g:NavSizes[g:LCol]-1).'vsp '.g:NavNames[NextWindow]
			wincmd l
			se wfw
			wincmd t
			se wfw
			norm 0
			let g:LCol=NextWindow
		endwhile
		if winwidth(0)<g:NavSizes[g:LCol]
			exe 'norm! 0'.(g:NavSizes[g:LCol]-winwidth(0)).'zl'
		en
		let g:LOff=max([0,g:NavSizes[g:LCol]-winwidth(0)])
	elseif g:LOff>=-1
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		while g:LOff<=-2
			let g:LCol=(g:LCol-1)%len(g:NavNames)
			let g:LOff+=g:NavSizes[g:LCol]+1
		endwhile
		exe 'e '.g:NavNames[g:LCol]
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
		if g:NavSizes[g:LCol]-g:LOff>=&columns-1
			let g:RCol=g:LCol
		else
			let spaceremaining=&columns-g:NavSizes[g:LCol]+g:LOff
			let NextCol=(g:LCol+1)%len(g:NavNames)
			while spaceremaining>=2
				se nowfw
				exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[NextCol])
				norm! 0
				let spaceremaining-=g:NavSizes[NextCol]+1
				let NextCol=(NextCol+1)%len(g:NavNames)
			endwhile
			windo se wfw
			let g:RCol=(NextCol-1)%len(g:NavNames)
		en
	en
endfun
nno <c-j> :<c-u>call PanLeft(v:count1)<cr>

fun! PanRight(N)
	call GetPlanePos()
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
				let g:LCol=(g:LCol+1)%len(g:NavNames)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:NavSizes[g:LCol]-g:LOff
			let N+=1
			let g:LCol=(g:LCol+1)%len(g:NavNames)
			let g:LOff=0
		else
			let g:LOff+=toshift	
		en
		exe 'e '.g:NavNames[g:LCol]
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
		let g:LOff=g:NavSizes[g:LCol]-winwidth(1)
		let g:LOff=g:LOff<0? 0 : g:LOff
		while winwidth(0)>=g:NavSizes[g:RCol]+2
			let NextWindow=(g:RCol+1)%len(g:NavNames)
			se nowfw
			exe 'rightb '.(winwidth(0)-g:NavSizes[g:RCol]-1).'vsp '.g:NavNames[NextWindow]
			norm 0
			wincmd h
			se wfw
			wincmd b
			se wfw
			let g:RCol=NextWindow
		endwhile
	elseif &columns-g:NavSizes[g:LCol]+g:LOff<2
		let g:RCol=g:LCol
	else
		let g:RCol=g:LCol
		let spaceremaining=&columns-g:NavSizes[g:LCol]+g:LOff
		while spaceremaining>=2
			let g:RCol=(g:RCol+1)%len(g:NavNames)
			se nowfw
			exe 'bot '.(spaceremaining-1).'vsp '.(g:NavNames[g:RCol])
			norm! 0
			let spaceremaining-=g:NavSizes[g:RCol]+1
		endwhile
		windo se wfw
	en
endfun
nno <c-k> :<c-u>call PanRight(v:count1)<cr>
