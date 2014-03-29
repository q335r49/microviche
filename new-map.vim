let map=[
\{14:['qerf','Title'],22:['rar','WarningMsg'],122:['abcdefghijklmnopqrstuvwxyz','r1_05'],222:['abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz','purp'],333:['abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz','violet']},
\{},
\{1:['k;mn','WarningMsg'], 121:['kkkk','r1_01'], 113:['kkkkk','ErrorMsg'], 412:['lmlmlmlmm','Visual']},
\{},
\{},
\{},
\{1:['one','red'],100:['one hundred','']},
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
		let colors=['EOL']
		let coords=['0']
		let leng=len(a:gridmap)-1
		if empty(a:gridmap[leng][i])
			let linestr=''
		else
			let linestr=a:gridmap[leng][i][0]
			call insert(coords,len(a:gridmap[leng][i][0]))
			call insert(colors,a:gridcolors[leng][i])
		en
		for j in range(leng-1,0,-1)
			if empty(a:gridmap[j][i])
				let padl+=a:w
			else
				let l=len(a:gridmap[j][i][0])
				if l>=padl
					let linestr=a:gridmap[j][i][0][:padl-1].linestr
					if a:gridcolors[j][i]==colors[0]
						let coords[0]+=padl
					else
						call insert(coords,padl)
						call insert(colors,a:gridcolors[j][i])
					en
				else
					let linestr=a:gridmap[j][i][0].pad[:padl-1-l].linestr
					if empty(colors[0])
						let coords[0]+=padl-l
					else
						call insert(coords,padl-l)
						call insert(colors,'')
					en
					if a:gridcolors[j][i]==colors[0]
						let coords[0]+=l
					else
						call insert(coords,l)
						call insert(colors,a:gridcolors[j][i])
					en
				en
				let padl=a:w
			en
		endfor
		if empty(a:gridmap[0][i])
			let padl-=a:w
			let linestr=pad[:padl-1].linestr
			if empty(colors[0])
				let coords[0]+=padl
			else
				call insert(coords,padl)
				call insert(colors,'')
			en
		en
		call remove(colors,-1)
		call remove(coords,-1)
		call add(g:lines,linestr)
		call add(g:colorarr,colors)
		call add(g:coordarr,coords)
	endfor
endfun

fun! DisplayMapCur(gridmap,lines,colors,coords,r,c,w,xb,xe,yb,ye)
	let h=len(a:gridmap[a:c][a:r])
	if h
		let curlb=a:r
		let curle=a:r+h-1
	else
		let curlb=a:r
		let curle=a:r
	en
	let blank=repeat(' ',a:w)
	for i in range(a:yb,a:ye)
		if i>=len(a:coords)
			echo ''
			continue
		elseif i<curlb || i>curle
			let ticker=0
			let j=0
			while ticker<a:xb
				let ticker+=a:coords[i][j]
				let j+=1
			endwhile
			if ticker!=a:xb
				exe 'echohl' a:colors[i][j-1]
				echon a:lines[i][a:xb : ticker-1]
			en
			for j in range(j,len(a:coords[i])-1)
				let nextticker=ticker+a:coords[i][j]
				if nextticker>=a:xe
					exe 'echohl' a:colors[i][j]
					echon a:lines[i][ticker : a:xe-1]
					break
				else
					exe 'echohl' a:colors[i][j]
					echon a:lines[i][ticker : ticker+a:coords[i][j]-1]
					let ticker=nextticker
				en
			endfor 
			echon "\n"
		else
			let b=a:c*a:w
			let l=len(a:gridmap[a:c][a:r][i-curlb])
			let e=b+l-1
			let ticker=0
			let curcoords=copy(a:coords[i])
			let curcolors=copy(a:colors[i])
			let j=0
			while j<len(curcoords)
				let nextticker=ticker+curcoords[j]
				if b==ticker
					let curcoords[j]=l
					let lastcolor=curcolors[j]
					let curcolors[j]='TxbMapSel'
					let j+=1
					let ticker=nextticker
					break
				elseif b<nextticker
					let curcoords[j]=b-ticker
					call insert(curcoords,l,j+1)
					call insert(curcolors,'TxbMapSel',j+1)
					let lastcolor=curcolors[j]
					let j+=1
					let ticker=nextticker
					break
				else
					let ticker=nextticker
				en
				let j+=1
			endw
			while j<len(curcoords)
				if e<ticker-1
					call insert(curcoords,ticker-e-1,j)
					call insert(curcolors,lastcolor,j)
					break
				elseif e==ticker-1
					break
				else
					let ticker+=remove(curcoords,j)
					let lastcolor=remove(curcolors,j)
				en
			endw
			
            call add(g:debug,curcoords)
            call add(g:debug,curcolors)

			let ticker=0
			let j=0
			while ticker<a:xb
				let ticker+=curcoords[j]
				let j+=1
			endwhile
			if ticker!=a:xb
				exe 'echohl' curcolors[j-1]
				echon a:lines[i][a:xb : ticker-1]
			en
			for j in range(j,len(curcoords)-1)
				let nextticker=ticker+curcoords[j]
				if nextticker>=a:xe
					exe 'echohl' curcolors[j]
					echon a:lines[i][ticker : a:xe-1]
					break
				else
					exe 'echohl' curcolors[j]
					echon a:lines[i][ticker : ticker+curcoords[j]-1]
					let ticker=nextticker
				en
			endfor 
			echon "\n"
		en
	endfor
	echohl
endfun

call ConvertToGrid(map,100,17)
call Grid2Str(gridmap,colormap,10,17)
echo ''
let debug=[]
call DisplayMapCur(gridmap,lines,colorarr,coordarr,1,0,10,0,100,1,20)
finish
