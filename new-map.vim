let map=[
\{14:['qerf','Visual'],22:['rar','WarningMsg'],122:['abcdefghijklmnopqrstuvwxyz',''],222:['abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz','purp'],333:['abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz','violet']},
\{},
\{1:['k;mn','WarningMsg'], 121:['kkkk','red'], 113:['kkkkk','ErrorMsg'], 412:['lmlmlmlmm','Visual']},
\{},
\{},
\{},
\{1:['one','red'],100:['one hundred','NONE']},
\{},
\{},
\{1:['tessssst','Visual'],101:['aaaaaaaaaaarrrrr','ErrorMsg']},
\{1:['finalllllllllllllllllllllllllll','Visual'],701:['corneaaaaaaaaaaaaaaarrrrr','ErrorMsg']}]

fun! ConvertToGrid(map,gran,maxlen)
	let g:gridmap=range(len(a:map))
	let g:colormap=range(len(a:map))
	for i in copy(g:gridmap)
		let g:gridmap[i]=eval('['.repeat('[],',a:maxlen-1).'[]]')
		let g:colormap[i]=repeat([''],a:maxlen)
		for j in keys(a:map[i])
			call add(g:gridmap[i][j/a:gran],a:map[i][j][0])
			if empty(g:colormap[i][j/a:gran])
				let g:colormap[i][j/a:gran]=a:map[i][j][1]
			en
		endfor
	endfor
endfun

fun! Grid2Str(gridmap,gridcolors,w,maxlen)
	let pad=repeat(' ',&columns+20)
	let g:lines=[]
	let g:colorarr=[]
	let g:coordarr=[]
	for i in range(a:maxlen)
		let padl=a:w
		let colors=[]
		let coords=[]
		let leng=len(a:gridmap)-1
		if empty(a:gridmap[leng][i])
			let linestr=''
		else
			let linestr=a:gridmap[leng][i][0]
			call insert(colors,a:gridcolors[leng][i])
			call insert(coords,len(a:gridmap[leng][i][0]))
		en
		for j in range(leng-1,0,-1)
			if empty(a:gridmap[j][i])
				let padl+=a:w
			else
				let l=len(a:gridmap[j][i][0])
				if l>=padl
					let linestr=a:gridmap[j][i][0][:padl-1].linestr
					call insert(coords,padl)
					call insert(colors,a:gridcolors[j][i])
				else
					let linestr=a:gridmap[j][i][0].pad[:padl-1-l].linestr
					call insert(coords,padl-l)
					call insert(colors,'NONE')
					call insert(coords,l)
					call insert(colors,a:gridcolors[j][i])
				en
				let padl=a:w
			en
		endfor
		if empty(a:gridmap[0][i])
			let padl-=a:w
			let linestr=pad[:padl-1].linestr
			call insert(coords,padl)
			call insert(colors,'NONE')
		en
		call add(g:lines,linestr)
		call add(g:colorarr,colors)
		call add(g:coordarr,coords)
	endfor
endfun

fun! DisplayMapCur(gridmap,lines, colors, coords,r,c,w)
	let h=len(a:gridmap[a:c][a:r])
    if h
		let curlb=a:r
		let curle=a:r+h-1
	else
		let curlb=a:r
		let curle=a:r
	en
	let blank=repeat(' ',a:w)
	for i in range(len(a:coords))
		if i>=curlb && i<=curle
			let ix=i-curlb
			let b=a:w*a:c
			if empty(a:gridmap[a:c][a:r])
				let e=b+a:w-1
				let content=blank
			else
				let e=b+len(a:gridmap[a:c][a:r][ix])-1
				let content=a:gridmap[a:c][a:r][ix][:e-b]
			en
			let e=e>&columns-1? &columns-1 : e
			let ticker=0
			let j=0
			let cl=len(a:coords[i])
			while j<cl
				let nextticker=ticker+a:coords[i][j]
			  	if nextticker>=b
					exe 'echohl' (empty(a:colors[i][j])? 'NONE' : a:colors[i][j])
					echon b? a:lines[i][ticker : b-1] : ''
					echohl TxbMapSel
					echon content
					while ticker<e && j<cl
						let ticker+=a:coords[i][j]
						let j+=1
					endwhile
					if j!=cl
						exe 'echohl' (empty(a:colors[i][j-1])? 'NONE' : a:colors[i][j-1])
						echon a:lines[i][e+1 : ticker-1]
					en
					break
				else
					exe 'echohl' (empty(a:colors[i][j])? 'NONE' : a:colors[i][j])
					echon a:lines[i][ticker : ticker+a:coords[i][j]-1]
					let ticker+=a:coords[i][j]
					let j+=1
				en
			endwhile
			while j<cl
				exe 'echohl' (empty(a:colors[i][j])? 'NONE' : a:colors[i][j])
				echon a:lines[i][ticker : ticker+a:coords[i][j]-1]
				let ticker+=a:coords[i][j]
				let j+=1
			endwhile
			echon "\n"
			echohl NONE
		else
			let ticker=0
			for j in range(len(a:coords[i]))
				exe 'echohl' (empty(a:colors[i][j])? 'NONE' : a:colors[i][j])
				echon a:lines[i][ticker : ticker+a:coords[i][j]-1]
				let ticker+=a:coords[i][j]
			endfor 
			echon "\n"
			echohl NONE
		en
	endfor
endfun

call ConvertToGrid(map,100,17)
call Grid2Str(gridmap,colormap,10,17)
echo ''
"call DisplayMap(lines, colorarr, coordarr)
call DisplayMapCur(gridmap,lines,colorarr,coordarr,7,0,10)
finish





fun! DisplayMap(lines, colors, coords)
	for i in range(len(a:coords))
		let ticker=0
		for j in range(len(a:coords[i]))
			exe 'echohl' empty(a:colors[i][j])? 'NONE' : a:colors[i][j]
			echon a:lines[i][ticker : ticker+a:coords[i][j]-1]
			let ticker+=a:coords[i][j]
		endfor 
		echon "\n"
		echohl NONE
	endfor
endfun

