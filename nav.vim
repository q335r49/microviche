"synergize with mousecursor / Navmode settings
"... the only problem here is changing windows ... but that shouldn't happen.
"/later
"optimize normal zl so there is no constant zeroing
"bookmarks / goto file-line-column
"scb flag
"resize (by setcurrentsize)
"clean up plane / save
"optimizations: exe wrapcmd
"PanLeft1, Panright1
"helpful fail messages for InitPlane



let g:NavNames=['test-10','test-20','test-40','test-80','test-60','test-150']
let g:NavSizes=['10','20','40','80','60','150']
let [g:LCol,g:LOff]=[0,0]

fun! GetPlanePos()
	let [LeftColName,RightColName]=[bufname(winbufnr(1)),bufname(winbufnr('$'))]
	if g:NavNames[g:LCol]!=LeftColName
		let found=index(g:NavNames,LeftColName)
		if found!=-1
        	let g:LCol=found
		en
	en
	if g:NavNames[g:RCol]!=RightColName
		let found=index(g:NavNames,RightColName)
		if found!=-1
        	let g:RCol=found
		en
	en
	if winwidth(1)==&columns && !&wrap
		let g:LOff=virtcol('.')-wincol()+1
	else
		let g:LOff=g:NavSizes[g:LCol]>winwidth(1)? g:NavSizes[g:LCol]-winwidth(1) : 0
	en
endfun

fun! InitPlane(...)
	if exists("a:1")
		if type(a:1)==1 	"(string name, [int min, int max, list Sizes])
			let g:NavNames=split(glob(a:1),"\n")
	   		let min=exists("a:2")? a:2 : 0
			let max=exists("a:3")? a:3>0 && a:3<=len(g:NavNames)? a:3 : len(g:NavNames) : len(g:NavNames)
            let g:NavSizes=exists("a:4")? a:4 : repeat([60],len(g:NavNames))
		elseif type(a:1)==3 "(list Names, list Sizes,[int leftcol, int offset])
			let g:NavNames=a:1
            let g:NavSizes=exists("a:2")? a:2 : repeat([60],len(g:NavNames))
			let g:LCol=exists("a:3")? a:3 : g:LCol
			let g:LOff=exists("a:4")? a:4 : g:LOff
		en
	en
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
		while winwidth(0)>=g:NavSizes[g:LCol]+2
			let NextWindow=(g:LCol-1)%len(g:NavNames)
			se nowfw
			exe 'lefta '.(winwidth(0)-g:NavSizes[g:LCol]-1).'vsp '.g:NavNames[NextWindow]
			norm 0
			wincmd l
			se wfw
			wincmd t
			se wfw
			let g:LCol=NextWindow
		endwhile
		if winwidth(0)<g:NavSizes[g:LCol]
			exe 'norm! 0'.(g:NavSizes[g:LCol]-winwidth(0)).'zl'
		en
		let g:LOff=g:NavSizes[g:LCol]-winwidth(0)
		let g:LOff=g:LOff<0? 0 : g:LOff
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
				wincmd h
				se wfw
				wincmd b
				se wfw
				let spaceremaining-=g:NavSizes[NextCol]+1
				let NextCol=(NextCol+1)%len(g:NavNames)
			endwhile
			let g:RCol=(NextCol-1)%len(g:NavNames)
		en
	en
	"redr | ec g:LCol g:NavNames[g:LCol] g:RCol g:NavNames[g:RCol] g:LOff '*' dbm
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
			wincmd h
			se wfw
			wincmd b
			se wfw   "probably can optimize, since next loop undos this
			let spaceremaining-=g:NavSizes[g:RCol]+1
		endwhile
	en
	"redr | ec g:LCol g:NavNames[g:LCol] g:RCol g:NavNames[g:RCol] g:LOff '*' dbm
endfun
nno <c-k> :<c-u>call PanRight(v:count1)<cr>
