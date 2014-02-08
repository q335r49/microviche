"need cleanup function: quit all non-visible buffers
"norm zl only for no wrap windows -- no, assume no wrap?

fun! NewPlane()
	tabe
	e dev-003
	vsp dev-002
	vsp dev-001
	vsp dev-000
	wincmd =
	windo se wfw
	call InitPlane()
	se ve=all
endfun

fun! InitPlane()
	se wiw=1
	se wmw=0
	let g:PlaneCols=[['dev-000',60],['dev-001',60],['dev-002',60],['dev-003',60],['dev-000',60],['dev-001',60],['dev-002',60],['dev-003',60]]
	let g:RCol=3
	let g:LCol=0
	let g:LOff=0
endfun

"will RCol, LCol, LOff autocorrect?
fun! PanLeft(N)
	"Verify Postcons: Rightmost, Leftmost, LOff
	let N=a:N
	if N>=&columns
		wincmd t | only
	el
		wincmd b
		while winwidth(0)<N
			hide
			let g:RCol-=1
		endw
		if winwidth(0)==N
			hide
			let N+=1
			let g:RCol-=1
		en
	en
	let w0=winwidth(0)
	let g:LOff-=N
	if w0!=&columns
		wincmd t
		exe N.'wincmd >'
		wincmd b	
		if w0-winwidth(0)!=N
			exe (N-w0+winwidth(0)).'wincmd <'
		en
		wincmd t
		while winwidth(0)>g:PlaneCols[g:LCol][1]
		"is ther a +1 factor here??????
			let NextWindow=(g:LCol-1)%len(g:PlaneCols)
			exe 'lefta '.(winwidth(0)-g:PlaneCols[g:LCol][1]).'vsp '.g:PlaneCols[NextWindow][0]
			norm! 0
			se wfw
		endwhile
		if winwidth(0)<g:PlaneCols[g:LCol][1]
			exe 'norm! '.(g:PlaneCols[g:LCol][1]-winwidth(0)).'zl'
		en
		let g:LCol=NextWindow
		let g:LOff=PlaneCols[g:LOff][1]-winwidth(0)
	else
		while g:LOff<0
			let g:LCol=(g:LCol-1)%len(g:PlaneCols)
			let g:LOff+=g:PlaneCols[g:LCol][1]+1
		endwhile
		exe 'norm! 0'.(g:LOff).'zl'
		if g:PlaneCols[g:LCol][1]-g:LOff>=&columns-1
			let g:RCol=g:LCol
		else
			let spaceremaining=&columns-g:PlaneCols[g:LCol][1]-g:LOff
			let NextCol=(g:LCol+1)%len(g:PlaneCols)
			while spaceremaining>=1
				exe 'bot '.(spaceremaining-1).'vsp '.(g:PlaneCols[NextCol][0])
				norm! 0
				let spaceremaining-=g:PlaneCols[NextCol][1]+1
				let NextCol=(g:LCol+1)%len(g:PlaneCols)
			endwhile
			let g:RCol=(NextCol-1)%len(g:PlaneCols)
		en
	en
endfun
