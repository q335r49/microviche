"need cleanup function: quit all non-visible buffers
"norm zl only for no wrap windows -- or, automatically taken care of!
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

fun! AppendPlane()
return

fun! ResetPlane()
return

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

call InitPlane()
