fun! PanRight(N)
	let N=a:N
	if N>=&columns
		if winwidth(1)==&columns
        	let g:LOff+=&columns
		else
			let g:LOff=winwidth(winnr('$'))
			let g:LCol=g:RCol
		en
		if g:LOff>=g:PlaneCol[g:LCol[1]]
			let g:LOff=0
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
		en
		let toshift=N-&columns
		if toshift>=g:PlaneCol[g:LCol[1]]-g:LOff+1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			let toshift-=g:PlaneCol[g:LCol[1]]-g:LOff+1
			while toshift>=g:PlaneCol[g:LCol[1]]+1
				let toshift-=g:PlaneCol[g:LCol[1]]+1
				let g:LCol=(g:LCol+1)%len(g:PlaneCol)
			endwhile
			if toshift==g:PlaneCol[g:LCol[1]]
				let N+=1
				let g:LCol=(g:LCol+1)%len(g:PlaneCol)
				let g:LOff=0
			else
				let g:LOff=toshift
			en
		elseif toshift==g:PlaneCol[g:LCol[1]]-g:LOff
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
		endw
		if winwidth(0)==N
			hide
			let N+=1
			let shifted+=winwidth(0)+1
			let g:LCol=(g:LCol+1)%len(g:PlaneCol)
		en
		let g:LOff=N-shifted
		exe 'norm! 0'.(g:LOff>0? g:LOff.'zl' : '')
	en
	let w0=winwidth(1)
	if w0!=&columns
		wincmd b
		exe N.'wincmd >'
		if w0-winwidth(1)!=N
			wincmd t	
			exe (N-w0+winwidth(0)).'wincmd <'
			wincmd b
		en
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
			exe 'bot '.(spaceremaining-1).'vsp '.(g:PlaneCol[NextCol][0])
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
