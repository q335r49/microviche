"account for resizing -- probably need a 'reset' function, or use marks
"optimize normal zl so there is no constant zeroing
"PanLeft1, Panright1


let g:PlaneCol=[['test-10',10],['test-20',20],['test-40',40],['test-80',80],['test-60',60],['test-150',150]]
let g:LCol=0
let g:LOff=0
fun! InitPlane()
	se wiw=1
	se wmw=0
	se ve=all
	exe 'tabe '.g:PlaneCol[g:LCol][0]
    exe 'norm! 0'.(g:LOff? g:LOff.'zl' : '')
	let spaceremaining=&columns-g:PlaneCol[g:LCol][1]-g:LOff
	let NextCol=(g:LCol+1)%len(g:PlaneCol)
	while spaceremaining>=2
		exe 'bot '.(spaceremaining-1).'vsp '.(g:PlaneCol[NextCol][0])
		norm! 0
		let spaceremaining-=g:PlaneCol[NextCol][1]+1
		let NextCol=(NextCol+1)%len(g:PlaneCol)
	endwhile
	let g:RCol=(NextCol-1)%len(g:PlaneCol)
	windo se wfw
endfun

fun! AppendPlane(filename, width)
endfun

fun! ResetPlane()
endfun

fun! CleanupPlane()
endfun

fun! PanLeft(N)
	let N=a:N
	if N>=&columns
		wincmd t | only
	el
		wincmd b
		while winwidth(0)<N
			hide
			let g:RCol=(g:RCol-1)%len(g:PlaneCol)
		endw
		if winwidth(0)==N
			hide
			let N+=1
			let g:RCol-=1
		en
	en
	let w0=winwidth(winnr('$'))
	let g:LOff-=N
	if w0!=&columns
		wincmd t
		exe N.'wincmd >'
		if w0-winwidth(winnr('$'))!=N
			wincmd b	
			exe (N-w0+winwidth(0)).'wincmd <'
			wincmd t
		en
		while winwidth(0)>=g:PlaneCol[g:LCol][1]+2
			let NextWindow=(g:LCol-1)%len(g:PlaneCol)
			se nowfw
			exe 'lefta '.(winwidth(0)-g:PlaneCol[g:LCol][1]-1).'vsp '.g:PlaneCol[NextWindow][0]
			norm 0
			wincmd l
			se wfw
			wincmd t
			se wfw
			let g:LCol=NextWindow
		endwhile
		if winwidth(0)<g:PlaneCol[g:LCol][1]
			exe 'norm! 0'.(g:PlaneCol[g:LCol][1]-winwidth(0)).'zl'
		en
		let g:LOff=g:PlaneCol[g:LCol][1]-winwidth(0)
		let g:LOff=g:LOff<0? 0 : g:LOff
	elseif g:LOff>=-1
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		while g:LOff<=-2
			let g:LCol=(g:LCol-1)%len(g:PlaneCol)
			let g:LOff+=g:PlaneCol[g:LCol][1]+1
		endwhile
		exe 'e '.g:PlaneCol[g:LCol][0]
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
		if g:PlaneCol[g:LCol][1]-g:LOff>=&columns-1
			let g:RCol=g:LCol
		else
			let spaceremaining=&columns-g:PlaneCol[g:LCol][1]+g:LOff
			let NextCol=(g:LCol+1)%len(g:PlaneCol)
			while spaceremaining>=2
				se nowfw
				exe 'bot '.(spaceremaining-1).'vsp '.(g:PlaneCol[NextCol][0])
				norm! 0
				wincmd h
				se wfw
				wincmd b
				se wfw
				let spaceremaining-=g:PlaneCol[NextCol][1]+1
				let NextCol=(NextCol+1)%len(g:PlaneCol)
			endwhile
			let g:RCol=(NextCol-1)%len(g:PlaneCol)
		en
	en
	"redr | ec g:LCol g:PlaneCol[g:LCol] g:RCol g:PlaneCol[g:RCol] g:LOff '*' dbm
endfun
nno <c-j> :<c-u>call PanLeft(v:count1)<cr>

fun! PanRight(N)
	let N=a:N
	if N>=&columns
		if winwidth(1)==&columns
        	let g:LOff+=&columns
		else
			let g:LOff=winwidth(winnr('$'))
			let g:LCol=g:RCol
		en
		if g:LOff>=g:PlaneCol[g:LCol][1]
			let g:LOff=0
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
		en
		let toshift=N-&columns
		if toshift>=g:PlaneCol[g:LCol][1]-g:LOff+1
			let toshift-=g:PlaneCol[g:LCol][1]-g:LOff+1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			while toshift>=g:PlaneCol[g:LCol][1]+1
				let toshift-=g:PlaneCol[g:LCol][1]+1
				let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			endwhile
			if toshift==g:PlaneCol[g:LCol][1]
				let N+=1
				let g:LCol=(g:LCol+1)%len(g:PlaneCol)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:PlaneCol[g:LCol][1]-g:LOff
			let N+=1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			let g:LOff=0
		else
			let g:LOff+=toshift	
		en
		exe 'e '.g:PlaneCol[g:LCol][0]
		only
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	else
		wincmd t
		let shifted=0
		while winwidth(0)<N
			hide
			let shifted+=winwidth(0)+1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			let g:LOff=0
		endw
		if winwidth(0)==N
			hide
			let N+=1
			let shifted+=winwidth(0)+1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
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
		let g:LOff=g:PlaneCol[g:LCol][1]-winwidth(1)
		let g:LOff=g:LOff<0? 0 : g:LOff
		while winwidth(0)>=g:PlaneCol[g:RCol][1]+2
			let NextWindow=(g:RCol+1)%len(g:PlaneCol)
			se nowfw
			exe 'rightb '.(winwidth(0)-g:PlaneCol[g:RCol][1]-1).'vsp '.g:PlaneCol[NextWindow][0]
			norm 0
			wincmd h
			se wfw
			wincmd b
			se wfw
			let g:RCol=NextWindow
		endwhile
	elseif &columns-g:PlaneCol[g:LCol][1]+g:LOff<2
		let g:RCol=g:LCol
	else
		let g:RCol=g:LCol
		let spaceremaining=&columns-g:PlaneCol[g:LCol][1]+g:LOff
		while spaceremaining>=2
			let g:RCol=(g:RCol+1)%len(g:PlaneCol)
			se nowfw
			exe 'bot '.(spaceremaining-1).'vsp '.(g:PlaneCol[g:RCol][0])
			norm! 0
			wincmd h
			se wfw
			wincmd b
			se wfw   "probably can optimize, since next loop undos this
			let spaceremaining-=g:PlaneCol[g:RCol][1]+1
		endwhile
	en
	"redr | ec g:LCol g:PlaneCol[g:LCol] g:RCol g:PlaneCol[g:RCol] g:LOff '*' dbm
endfun
nno <c-k> :<c-u>call PanRight(v:count1)<cr>
