if &cp | se nocompatible | en
"Global hotkey: press to begin
	let txb_key='<f10>'
"Grid panning animation step
	let s:pansteph=9
	let s:panstepv=2
"Small grid: 1 split x s:sgridL lines
	let s:sgridL=15
"Big grid: s:bgridS splits x s:bgridL lines
	let s:bgridS=3
	let s:bgridL=45
"Map: block sizes for various zooms
	let s:bksizes=[[2,6],[3,7],[4,10],[5,12],[6,14],[7,17],[8,20],[9,25]]

fun! s:PrintHelp()
let helpmsg="\n\\CWelcome to Textabyss v1.2!\n
\\nTo start, press ".g:txb_key." and enter a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single fine and use ".g:txb_key."A to append additional splits.
\\n    Setting your viminfo to save global variables (:set viminfo+=!) is highly recommended as the previously used plane (and the map, below) will be saved and suggested when the hotkey is pressed.\n
\\nOnce loaded, use the mouse to pan or press ".g:txb_key." again:
\\n    hjklyubn  - pan small grid
\\n    HJKLYUBN  - pan big grid
\\n    r         - redraw
\\n    .         - Snap to the big grid cursor is in
\\n    ^H^J^K^L
\\n    ^Y^U^B^N  - cursor to edges and corners of current big grid
\\n    D A E     - Delete split / Append split / Edit split settings
\\n    ^X        - Delete hidden buffers (eg, if too many are loaded from panning)
\\nSmall gridlines are at every split and lines divisible by ".s:sgridL." while big gridlines are at splits divisible by ".s:bgridS." and lines divisible by ".s:bgridL.".\n
\\nYou can also press 'o' (after pressing ".g:txb_key.") to enter a map:
\\n    o         - 'Open grid' (map mode)
\\n    hjklyubn  - navigate map
\\n    g <cr>    - go to grid
\\n    c         - change name
\\n    + -       - zoom
\\n    I D       - Insert / Delete column
\\nThe map will start out blank, so fill it in by changing (c) big grid names. The map is for bookmarking only, changing the map will not change the plane in any way.\n
\\nI haven't done a lot of testing with exotic file names, so to be on the safe side, files names shouldn't contain spaces and should be in the current directory (change to that directory beforehand with :cd ~/SomeDir). And horizontal splits aren't supported and may interfere with mouse panning. \n\nPress enter to continue ... (or input 'm' for a monologue, 'c' for changelog)"
let width=&columns>80? min([&columns-10,80]) : &columns-2
redr
let input=input(s:FormatPar(helpmsg,width,(&columns-width)/2))
if input==?'m'
let helpmsg="\n\n\\C\"... into the abyss he slipped
\\n\\CEndless fathoms he fell
\\n\\CNe'er in homely hearth to linger
\\n\\CNor warm hand to grasp!\"\n
\\n    I've been thinking for awhile now how most programs are pretty inadequate at organizing thinking over a long period of time, since what we think we're talking about often changes greatly on retrospection. It seems to me that time itself is the only real way to make sense of things. So I don't think of this as another kind of mind mapping but rather more as a means of raw accumulation. There are of course tools for organizing and layout but primarily one perhaps simply ... descends!\n
\\n    Vim is certainly a fascinating environment to work in. For me, there's a great pleasure that comes from removing a feature that I've added upon realizing that it was already baked in -- and this may involve realizing other means of acheiving an ends or settling for alternative ends. I hope that the experience with textabyss is sort of similar, ie, that one starts by awkwardly incorporating it into one's workflow, realizing its inadequacies and limitations, but also realizing the workflow that it has imagined to be in many ways sufficient.\n
\\n    A note about scrollbinding splits of uneven lengths -- I've tried to smooth over this process but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding, say, 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.\n
\\n    One of the great things about vim is how easy it is to synergize components -- well, sometimes with a bit of scripting. So I feel that the textabyss script itself can be kept fairly simple. For example, automatically padding blank lines and adjusting various settings when a split is appended can be done with vim's inbuilt :autocommand * BufNewFile feature.\n
\\n\n\\RThanks for trying out Textabyss!\n\n\\RLeon Q335r49@gmail.com"
cal input(s:FormatPar(helpmsg,width,(&columns-width)/2))
elseif input==?'c'
let helpmsg="\n\n1.2.2 - Minor bug where the rightmost split will overshift on PanRight
\\n1.2.3 - FormatPar for help dialogs now has option to align right
\\n1.2.4 - Minor bug with map when horizontal block size divides columns
\\n1.2.5 - Cursor behaves more predictably (Curor won't move on panning / clicking without dragging relocates cursor)
\\n1.2.5 - Echo confirmation for various commands
\\n1.2.6 - Ctrl-YUBNHJKL jumps to grid corners
\\n1.2.7 - Minor updates to grid corners
\\n1.2.8 - Snap to grid now snaps to the grid the cursor is currently in
\\n\n\\CUpcoming
\\n1.3.0 - Mouse panning for map
\\n"
cal input(s:FormatPar(helpmsg,width,(&columns-width)/2))
en
endfun

nn <silent> <leftmouse> :exe TXBmouse{exists('t:txb')? "Nav" : "PanWin"}()? "keepj norm! \<lt>leftmouse>" : ""<cr>
exe 'nn <silent> '.txb_key.' :call TXB{exists("t:txb")? "cmd" : "start"}()<cr>'
let TXB_PREVPAT=exists('TXB_PREVPAT')? TXB_PREVPAT : ''
let TXBcmds={}

fun! s:MakeGridNameList(len)
	let alpha=map(range(65,90),'nr2char(v:val)')
	let powers=[26,676,17576]
	let array1=map(range(powers[0]),'alpha[v:val%26]')
	if a:len<=powers[0]
		return array1
	elseif a:len<=powers[0]+powers[1]
		return extend(array1,map(range(a:len-powers[0]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
   	else
		call extend(array1,map(range(powers[1]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
		return extend(array1,map(range(a:len-len(array1)),'alpha[v:val/powers[1]%26].alpha[v:val/powers[0]%26].alpha[v:val%26]'))
	en
endfun

let s:pad=repeat(' ',100)
fun! s:GetMapDisp(map,w,h,H)
	let [s,l]=[map(range(a:h),'[v:val*a:w,v:val*a:w+a:w-1]'),len(a:map)*a:w+1]
	return {'str':join(map(range(a:h*a:H),'join(map(map(range(len(a:map)),''len(a:map[v:val])>''.v:val/a:h.''? a:map[v:val][''.v:val/a:h.''] : "[NUL]"''),''v:val[s[''.v:val%a:h.''][0] : s[''.v:val%a:h.''][1]].s:pad[1:(s[''.v:val%a:h.''][1]>=len(v:val)? (s[''.v:val%a:h.''][0]>=len(v:val)? a:w : a:w-len(v:val)+s[''.v:val%a:h.''][0]) : 0)]''),'''')."\n"'),''),'hlmap':map(range(a:H),'map(range(len(a:map)),''map(range(a:h),"''.v:val.''*l*a:h+(a:w)*".v:val."+v:val*l")'')'),'w':(a:w)}
endfun
fun! s:PrintMapDisp(disp,r,c)
	let ticker=0
	for i in a:disp.hlmap[a:r][a:c]
		echon i? a:disp.str[ticker : i-1] : ''
		echohl visual
		let ticker=i+a:disp.w
		echon a:disp.str[i : ticker-1]
		echohl NONE
	endfor
	echon a:disp.str[ticker :]
endfun
fun! s:NavigateMap(array,c_ini,r_ini)
	let [msg,settings,&ch,&more,r,c,rows,cols,pad,continue,redr]=['',[&ch,&more],&lines-1,0,a:r_ini,a:c_ini,(&lines-1)/s:bksizes[t:txb.zoom][0],(&columns-1)/s:bksizes[t:txb.zoom][1],repeat("\n",(&lines-1)%s:bksizes[t:txb.zoom][0]).' ',1,1]
	let [roff,coff]=[max([r-rows/2,0]),max([c-cols/2,0])]
	while continue
		let [roffn,coffn]=[r<roff? r : r>=roff+rows? r-rows+1 : roff,c<coff? c : c>=coff+cols? c-cols+1 : coff]
		if [roff,coff]!=[roffn,coffn] || redr
			let [roff,coff,redr]=[roffn,coffn,0]
			let disp=s:GetMapDisp(map(range(coff,coff+cols-1),'map(range(roff,roff+rows-1),"exists(\"a:array[".v:val."][v:val]\")? a:array[".v:val."][v:val] : \"\"")'),s:bksizes[t:txb.zoom][1],s:bksizes[t:txb.zoom][0],rows)
		en
		redr!
		call s:PrintMapDisp(disp,r-roff,c-coff)
		echon pad.get(t:txb.gridnames,c,'--').r.msg
		exe get(s:mapdict,getchar(),'let msg=" hjklyubn|motion +-|zoom I|nsertCol D|eleteCol c|hange g|oto"')
	endwhile
	let [&ch,&more]=settings
endfun
let s:mapdict={27:"let continue=0"}
let s:mapdict.106="let r+=1"
let s:mapdict.107="let r=r>0? r-1 : r"
let s:mapdict.108="let c+=1"
let s:mapdict.104="let c=c>0? c-1 : c"
let s:mapdict.121="let [r,c]=[r>0? r-1 : r,c>0? c-1 : c]"
let s:mapdict.117="let [r,c]=[r>0? r-1 : r,c+1]"
let s:mapdict.98 ="let [r,c]=[r+1,c>0? c-1 : c]"
let s:mapdict.110="let [r,c]=[r+1,c+1]"
let s:mapdict.99 ="let input=input('Change: ',exists('a:array[c][r]')? a:array[c][r] : '')\n
\if !empty(input)\n
 	\if c>=len(a:array)\n
		\call extend(a:array,eval('['.join(repeat(['[]'],c+1-len(a:array)),',').']'))\n
	\en\n
	\if r>=len(a:array[c])\n
		\call extend(a:array[c],repeat([''],r+1-len(a:array[c])))\n
	\en\n
	\let a:array[c][r]=input\n
	\let redr=1\n
\en\n"
let s:mapdict.105=s:mapdict.99
let s:mapdict.103="let [&ch,&more]=settings|cal s:GotoBlock(t:txb.gridnames[c].r)|return"
let s:mapdict.13=s:mapdict.103
let s:mapdict.43='let t:txb.zoom=min([t:txb.zoom+1,len(s:bksizes)-1])|let [redr,rows,cols,pad]=[1,(&lines-1)/s:bksizes[t:txb.zoom][0],&columns/s:bksizes[t:txb.zoom][1],repeat("\n",(&lines-1)%s:bksizes[t:txb.zoom][0])." "]'
let s:mapdict.61=s:mapdict.43
let s:mapdict.45='let t:txb.zoom=max([t:txb.zoom-1,0])|let [redr,rows,cols,pad]=[1,(&lines-1)/s:bksizes[t:txb.zoom][0],&columns/s:bksizes[t:txb.zoom][1],repeat("\n",(&lines-1)%s:bksizes[t:txb.zoom][0])." "]'
let s:mapdict.95=s:mapdict.45
let s:mapdict.73='if c<len(a:array)|call insert(a:array,[],c)|let redr=1|let msg=" Col ".c." inserted"|en'
let s:mapdict.68='if c<len(a:array) && input("Really delete column? (y/n)")==?"y"|call remove(a:array,c)|let redr=1|let msg=" Col ".c." deleted"|en'
	let TXBcmds.111='let grid=s:GetGrid()|cal s:NavigateMap(t:txb.map,grid[0],grid[1])|let continue=0'

fun! DeleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBcmds.24='cal DeleteHiddenBuffers()|let [msg,continue]=["Hidden Buffers Deleted",0]'

fun! s:FormatPar(str,w,pad)
	let [pars,pad,bigpad,spc]=[split(a:str,"\n",1),repeat(" ",a:pad),repeat(" ",a:w+10),repeat(' ',len(&brk))]
	for k in range(len(pars))
		if pars[k][0]==#'\'
			let format=pars[k][1]
   			let pars[k]=pars[k][(format=='\'? 1 : 2):]
		else
			let format=''
		en
		let seg=[0]
		while seg[-1]<len(pars[k])-a:w
			let ix=(a:w+strridx(tr(pars[k][seg[-1]:seg[-1]+a:w-1],&brk,spc),' '))%a:w
			call add(seg,seg[-1]+ix-(pars[k][seg[-1]+ix=~'\s']))
			let ix=seg[-2]+ix+1
			while pars[k][ix]==" "
				let ix+=1
			endwhile
			call add(seg,ix)
		endw
		call add(seg,len(pars[k])-1)
		let pars[k]=pad.join(map(range(len(seg)/2),format==#'C'? 'bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : format==#'R'? 'bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : 'pars[k][seg[2*v:val]:seg[2*v:val+1]]'),"\n".pad) 
	endfor
	return join(pars,"\n")
endfun

fun! TXB_GotoPos(col,row)
	let name=t:txb.name[a:col]
	wincmd t
	only
	exe 'e '.name
	exe 'norm!' (a:row? a:row : 1).'zt'
	call s:LoadPlane()
endfun

fun! s:GotoBlock(str)
	let [col,row]=['','']
	for i in range(len(a:str)-1,0,-1)
		if a:str[i]>0 || a:str[i] is '0'
			let row=a:str[i].row
		else
			let col=a:str[i].col
		en
	endfor
	let line=index(t:txb.gridnames,col,0,1)*s:bgridS
	call TXB_GotoPos(index(t:txb.gridnames,col,0,1)*s:bgridS,s:bgridL*row)
endfun

fun! s:BlockPan(dx,y,...)
	let cury=line('w0')
	let absolute_x=exists('a:1')? a:1 : 0
	let dir=absolute_x? absolute_x : a:dx
	let y=a:y>cury?  (a:y-cury-1)/s:sgridL+1 : a:y<cury? -(cury-a:y-1)/s:sgridL-1 : 0
   	let update_ydest=y>=0? 'let y_dest=!y? cury : cury/'.s:sgridL.'*'.s:sgridL.'+'.s:sgridL : 'let y_dest=!y? cury : cury>'.s:sgridL.'? (cury-1)/'.s:sgridL.'*'.s:sgridL.' : 1'
	let pan_y=(y>=0? 'let cury=cury+'.s:panstepv.'<y_dest? cury+'.s:panstepv.' : y_dest' : 'let cury=cury-'.s:panstepv.'>y_dest? cury-'.s:panstepv.' : y_dest')."\n
		\if cury>line('$')\n
			\let longlinefound=0\n
			\for i in range(winnr('$')-1)\n
				\wincmd w\n
				\if line('$')>=cury\n
					\exe 'norm!' cury.'zt'\n
					\let longlinefound=1\n
					\break\n
				\en\n
			\endfor\n
			\if !longlinefound\n
				\exe 'norm! Gzt'\n
			\en\n
		\else\n
			\exe 'norm!' cury.'zt'\n
		\en"
	if dir>0
		let i=0
		let continue=1
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			while winwidth(1)>s:pansteph
				call s:PanRight(s:pansteph)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:PanRight(winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i+=1
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i<a:dx
		endwhile
	elseif dir<0
		let i=0
		let continue=!map([t:txb.ix[bufname(winbufnr(1))]],'absolute_x && v:val==a:dx && winwidth(1)>=t:txb.size[v:val]')[0]
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			let ix=t:txb.ix[bufname(buf0)]
			if winwidth(1)>=t:txb.size[ix]
				call s:PanLeft(4)
				let buf0=winbufnr(1)
			en
			while winwidth(1)<t:txb.size[ix]-s:pansteph
				call s:PanLeft(s:pansteph)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:PanLeft(t:txb.size[ix]-winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i-=1
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i>a:dx
		endwhile
	en
	while y
		exe update_ydest
		while cury!=y_dest
			exe pan_y
			redr
		endwhile
		let y+=y>0? -1 : y<0? 1 : 0
	endwhile
endfun
let s:Y1='let y=y/s:sgridL*s:sgridL+s:sgridL|'
let s:Ym1='let y=max([1,y/s:sgridL*s:sgridL-s:sgridL])|'
	let TXBcmds.104='cal s:BlockPan(-1,y)'
	let TXBcmds.106=s:Y1.'cal s:BlockPan(0,y)'
	let TXBcmds.107=s:Ym1.'cal s:BlockPan(0,y)'
	let TXBcmds.108='cal s:BlockPan(1,y)'
	let TXBcmds.121=s:Ym1.'cal s:BlockPan(-1,y)'
	let TXBcmds.117=s:Ym1.'cal s:BlockPan(1,y)'
	let TXBcmds.98 =s:Y1.'cal s:BlockPan(-1,y)'
	let TXBcmds.110=s:Y1.'cal s:BlockPan(1,y)'
let s:DXm1='map([t:txb.ix[bufname(winbufnr(1))]],"winwidth(1)<=t:txb.size[v:val]? (v:val==0? t:txb.len-t:txb.len%s:bgridS : (v:val-1)-(v:val-1)%s:bgridS) : v:val-v:val%s:bgridS")[0]'
let s:DX1='map([t:txb.ix[bufname(winbufnr(1))]],"v:val>=t:txb.len-t:txb.len%s:bgridS? 0 : v:val-v:val%s:bgridS+s:bgridS")[0]'
let s:Y1='let y=y/s:bgridL*s:bgridL+s:bgridL|'
let s:Ym1='let y=max([1,y%s:bgridL? y-y%s:bgridL : y-y%s:bgridL-s:bgridL])|'
	let TXBcmds.72='cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.74=s:Y1.'cal s:BlockPan(0,y)'
	let TXBcmds.75=s:Ym1.'cal s:BlockPan(0,y)'
	let TXBcmds.76='cal s:BlockPan('.s:DX1.',y,1)'
	let TXBcmds.89=s:Ym1.'cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.85=s:Ym1.'cal s:BlockPan('.s:DX1.',y,1)'
	let TXBcmds.66=s:Y1.'cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.78=s:Y1.'cal s:BlockPan('.s:DX1.',y,1)'
unlet s:DX1 s:DXm1 s:Y1 s:Ym1

fun! s:GridCorners(dx,dy)
	if a:dy<0
		let cursory=max([line('.')/s:bgridL*s:bgridL,1])
		let desty=min([cursory,line('w0')])
	elseif a:dy>0
		let cursory=line('.')/s:bgridL*s:bgridL+s:bgridL-1
		let desty=max([cursory-winheight(0),line('w0')])
	else
		let cursory=line('.')/s:bgridL*s:bgridL+s:bgridL/2
		let desty=cursory>=line('.')? max([cursory-winheight(0),line('w0')]) : min([cursory,line('w0')])
	en
	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1 | return 300 | en
	if a:dx<0
 		let destix=ix/s:bgridS*s:bgridS
		let eval='"norm! '.cursory.'G0"'
	elseif a:dx>0
		let destix=min([ix/s:bgridS*s:bgridS+s:bgridS-1,t:txb.len-1])
		let eval='"norm! '.cursory.'Gg$"'
	else
    	let destix=min([ix-ix%s:bgridS+s:bgridS/2,t:txb.len-1])
		let eval='"norm! '.cursory.'G".(winwidth(0)/2)."|"'
	en
	if destix<ix || destix==ix && winnr()==1
		if winnr()-ix+destix==1 && winwidth(1)<t:txb.size[destix]
		   	call s:BlockPan(-1,desty)
		elseif winnr()<=ix-destix
			call s:BlockPan(destix,desty,-1)
		en
	elseif destix>ix || destix==ix && winnr()==winnr('$')
   		while t:txb.ix[bufname(winbufnr(winnr('$')))]<destix
   			call s:PanRight(s:pansteph)
   		endwhile
		let win=bufwinnr(bufnr(t:txb.name[destix]))
   		exe win==-1? 'return 200' : win."wincmd w"
		if winnr()==winnr('$') && winwidth(0)<t:txb.size[destix]
			while t:txb.size[destix]-winwidth(winnr('$'))>s:pansteph
				call s:PanRight(s:pansteph)
			endwhile
			call s:PanRight(t:txb.size[destix]-winwidth(winnr('$')))
		en
		exe 'norm! '.desty.'zt'
	en
	let win=bufwinnr(bufnr(t:txb.name[destix]))
	exe win==-1? 'return 100' : win."wincmd w"
	exe eval(eval)
endfun
	let TXBcmds.25='cal s:GridCorners(-1,-1)|let possav=s:SaveCursPos()'
	let TXBcmds.21='cal s:GridCorners( 1,-1)|let possav=s:SaveCursPos()'
	let TXBcmds.2 ='cal s:GridCorners(-1, 1)|let possav=s:SaveCursPos()'
	let TXBcmds.14='cal s:GridCorners( 1, 1)|let possav=s:SaveCursPos()'
	let TXBcmds.8 ='cal s:GridCorners(-1, 0)|let possav=s:SaveCursPos()'
	let TXBcmds.12='cal s:GridCorners( 1, 0)|let possav=s:SaveCursPos()'
	let TXBcmds.10='cal s:GridCorners( 0, 1)|let possav=s:SaveCursPos()'
	let TXBcmds.11='cal s:GridCorners( 0,-1)|let possav=s:SaveCursPos()'

fun! s:GetGrid()
	let [ix,l0]=[t:txb.ix[bufname(winbufnr(1))],line('w0')]
	let [sd,dir]=(ix%s:bgridS>s:bgridS/2 && ix+s:bgridS-ix%s:bgridS<t:txb.len-1)? [ix+s:bgridS-ix%s:bgridS,1] : [ix-ix%s:bgridS,-1]
	return [sd/3,(l0%s:bgridL>s:bgridL/2? l0+s:bgridL-l0%s:bgridL : l0-l0%s:bgridL)/s:bgridL]
endfun
fun! s:SnapToGrid()
	let [ix,l0]=[t:txb.ix[bufname(winbufnr(1))],line('w0')]
	let [sd,dir]=(ix%s:bgridS>s:bgridS/2 && ix+s:bgridS-ix%s:bgridS<t:txb.len-1)? [ix+s:bgridS-ix%s:bgridS,1] : [ix-ix%s:bgridS,-1]
	call s:BlockPan(sd,l0%s:bgridL>s:bgridL/2? l0+s:bgridL-l0%s:bgridL : l0-l0%s:bgridL,dir)
endfun
fun! s:SnapToCursorGrid()
	let [ix,l0]=[t:txb.ix[expand('%')],line('.')]
 	let [x,dir]=winnr()>ix%s:bgridS+1? [ix-ix%s:bgridS,1] : winnr()==ix%s:bgridS+1 && t:txb.size[ix-ix%s:bgridS]>=winwidth(1)? [0,0] : [ix-ix%s:bgridS,-1]
	call s:BlockPan(x,l0-l0%s:bgridL,dir)
endfun
	let TXBcmds.46='call s:SnapToCursorGrid()|let continue=0'

fun! TXBcmd(...)
	let [y,continue,msg]=[line('w0'),1,'']
	let possav=s:SaveCursPos()
	if a:0 | exe get(g:TXBcmds,a:1,'let msg="Press f1 for help"') | en
	while continue
		call s:RestoreCursPos(possav)
		let possav=s:SaveCursPos()
		let matchID=matchadd("Visual",'\%#')
		let s0=t:txb.ix[bufname(winbufnr(1))]
		redr|ec empty(msg)? join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bgridS)? t:txb.gridnames[v:val/s:bgridS] : "."')).' - '.join(map(range(line('w0'),line('w$'),s:sgridL),'!v:key || v:val%(s:bgridL)<s:sgridL? v:val/s:bgridL : "."')) : msg
		let [msg,c]=['',getchar()]
		call matchdelete(matchID)
		exe get(g:TXBcmds,c,'let msg="Press f1 for help"')
	endwhile
    let s0=t:txb.ix[bufname(winbufnr(1))]
   	call s:RestoreCursPos(possav)
	redr|ec empty(msg)? join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bgridS)? t:txb.gridnames[v:val/s:bgridS] : "."')).' _ '.join(map(range(line('w0'),line('w$'),s:sgridL),'!v:key || v:val%(s:bgridL)<s:sgridL? v:val/s:bgridL : "."')) : msg
endfun
let TXBcmds.68="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb.ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call s:DeleteCol(ix)\n
		\wincmd W\n
		\call s:LoadPlane(t:txb)\n
		\let msg='col '.ix.' removed'\n
	\else\n
		\let msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en"
let TXBcmds.65="let ix=get(t:txb.ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append (between : ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\if !empty(file)\n
		\call s:AppendCol(ix,file)\n
		\call s:LoadPlane(t:txb)\n
		\let msg='col '.(ix+1).' appended'\n
	\else\n
		\let msg='(aborted)'\n
	\en\n
\else\n
	\let msg='Current buffer not in plane'\n
\en"
let TXBcmds.27="let continue=0|redr|ec ''"
let TXBcmds.114="call s:LoadPlane(t:txb)|redr|ec ' (redrawn)'|let continue=0"
let TXBcmds["\<leftmouse>"]="call TXBmouseNav()|let y=line('w0')|let continue=0|redr"
let TXBcmds["\<f1>"]='call s:PrintHelp()|let continue=0'
let TXBcmds.69='call s:EditSettings()|let continue=0'

fun! TXBstart(...)                                          
	let preventry=a:0 && a:1 isnot 0? a:1 : exists("g:TXB") && type(g:TXB)==4? g:TXB : exists("g:TXB_PREVPAT")? g:TXB_PREVPAT : ''
	let plane=type(preventry)==1? s:CreatePlane(preventry) : type(preventry)==4? preventry : {'name':''}
	if !empty(plane.name)
		ec "\n" (a:0 && a:1 isnot 0? "This" : "Previous") (type(preventry)==4? "plane has:" : "pattern matches:")
		let curbufix=index(plane.name,expand('%'))
		ec join(map(copy(plane.name),'(curbufix==v:key? " -> " : "    ").v:val'),"\n")
		ec " ..." plane.len "files to be loaded in" (curbufix!=-1? "THIS tab" : "NEW tab")
		ec "(Press ENTER to load, ESC to try something else, or F1 for help)"
		let c=getchar()
	else
		let c=0
	en
	if c==13 || c==10
		if curbufix==-1 | tabe | en
		let [g:TXB,g:TXB_PREVPAT]=[plane,type(preventry)==1? preventry : g:TXB_PREVPAT]
		call s:LoadPlane(plane)
	elseif c is "\<f1>"
		call s:PrintHelp() 
	else
		let input=input("> Enter file pattern or type HELP: ", g:TXB_PREVPAT)
		if empty(input)
			redr|ec "(aborted)"
		elseif input==?'help'
			call s:PrintHelp()
		else
			call TXBstart(input)
		en
	en
endfun

fun! s:EditSettings()
   	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input(' < Column width: ',t:txb.size[ix])
		if empty(input) | return | en
    	let t:txb.size[ix]=input
		redr
    	let input=input(" < Autoexecute on load:
			\\n * scb should always be set so that one can toggle global scrollbind via <hotkey>S
			\\n * wrap defaults to 'wrap' if not set\n",t:txb.exe[ix])
		if empty(input) | return | en
		let t:txb.exe[ix]=input
		redr
    	let input=input(' < Column position (0-'.(t:txb.len-1).'): ',ix)
		if empty(input) | return | en
		let newix=input
		if newix>=0 && newix<t:txb.len && newix!=ix
			let item=remove(t:txb.name,ix)
			call insert(t:txb.name,item,newix)
			let item=remove(t:txb.size,ix)
			call insert(t:txb.size,item,newix)
			let item=remove(t:txb.exe,ix)
			call insert(t:txb.exe,item,newix)
			let [t:txb.ix,i]=[{},0]
			for e in t:txb.name
				let [t:txb.ix[e],i]=[i,i+1]
			endfor
		en
		call s:LoadPlane(t:txb)
	en
endfun

fun! s:CreatePlane(name,...)
	let plane={}
	let plane.name=type(a:name)==1? map(split(glob(a:name)),'escape(v:val," ")') : type(a:name)==3? a:name : 'INV'
	if plane.name is 'INV'
     	throw 'First argument ('.string(a:name).') must be string (filepattern) or list (list of files)'
	else
		let plane.len=len(plane.name)
		let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
		let plane.exe=exists("a:2")? a:2 : repeat(['se scb cole=2 nowrap'],plane.len)
		let plane.scrollopt='ver,jump'
		let plane.zoom=min([2,len(s:bksizes)])
		let [plane.ix,i]=[{},0]
		let plane.map=[[]]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		let plane.gridnames=s:MakeGridNameList(plane.len+50)
		return plane
	en
endfun

fun! s:AppendCol(index,file,...)
	call insert(t:txb.name,a:file,a:index+1)
	call insert(t:txb.size,exists('a:1')? a:1 : 60,a:index+1)
	call insert(t:txb.exe,'se nowrap scb cole=2',a:index+1)
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:MakeGridNameList(t:txb.len+50)
	endif
endfun
fun! s:DeleteCol(index)
	call remove(t:txb.name,a:index)	
	call remove(t:txb.size,a:index)	
	call remove(t:txb.exe,a:index)	
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
endfun

fun! s:LoadPlane(...)
	if a:0
		let t:txb=a:1
		se sidescroll=1 mouse=a lz noea nosol wiw=1 wmw=0 ve=all
	elseif !exists("t:txb")
		ec "\n> No plane initialized..."
		call TXBstart()
		return
	en
	let [col0,win0]=[get(t:txb.ix,bufname(""),a:0? -1 : -2),winnr()]
	if col0==-2
		ec "> Current buffer not registered in in plane..."
		return
	elseif col0==-1
		let col0=0
		only
		exe 'e' t:txb.name[0] 
	en
	let pos=[bufnr('%'),line('w0')]
	exe winnr()!=1? "norm! mt0" : "norm! mt"
	let alignmentcmd="norm! 0".pos[1]."zt"
	se scrollopt=jump
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0,0]
	let remain=split0
	while remain>=1
		let colt=(colt-1)%len(t:txb.size)
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%t:txb.len,&columns-(split0>0? split0+1+t:txb.size[col0] : min([winwidth(1),t:txb.size[col0]])),1]
	while remain>=2
		let remain-=t:txb.size[colb]+1
		let colb=(colb+1)%len(t:txb.size)
		let colsRight+=1
	endwhile
	let colbw=t:txb.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%t:txb.len
		for i in range(dif)
			let colt=(colt-1)%t:txb.len
			exe 'top vsp '.t:txb.name[colt]
			exe alignmentcmd
			exe t:txb.exe[colt]
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
		let colb=(col0+colsRight-1-dif)%len(t:txb.size)
		for i in range(dif)
			let colb=(colb+1)%len(t:txb.size)
			exe 'bot vsp '.t:txb.name[colb]
			exe alignmentcmd
			exe t:txb.exe[colb]
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
	let [bot,cwin]=[winnr(),-1]
	while winnr()!=cwin
		se wfw
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txb.len]
		let k=t:txb.name[ccol]
		if expand('%:p')!=#fnamemodify(t:txb.name[ccol],":p")
			exe 'e' t:txb.name[ccol] 
			exe alignmentcmd
			exe t:txb.exe[ccol]
		elseif a:0
			exe alignmentcmd
			exe t:txb.exe[ccol]
		en
		if cwin==1
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(cwin==bot? colbw : t:txb.size[ccol])-winwidth(cwin)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		wincmd h
	endw
	let &scrollopt=t:txb.scrollopt
	try
		exe "silent norm! :syncbind\<cr>"
	catch
	endtry
   	exe "norm!" bufwinnr(pos[0])."\<c-w>w".pos[1]."zt`t"
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:MakeGridNameList(t:txb.len+50)
	en
endfun

let glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! TXBmousePanWin()
	let possav=[bufnr('%')]+getpos('.')[1:]
	call feedkeys("\<leftmouse>")
	call getchar()
	exe v:mouse_win."wincmd w"
	if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
		if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
		return 1 | en
	exe "norm! \<leftmouse>"
	redr!
	let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
	let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(exists('g:opt_device') && g:opt_device==?'droid4' && veon)? 'redr!':'redr']
	let c=getchar()
	if c=="\<leftdrag>"
		while c=="\<leftdrag>"
			let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
			let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
			call winrestview(v)
			exe redrexpr
			let c=getchar()
		endwhile
	else
		return 1
	en
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
	exe min([max([line('w0'),possav[1]]),line('w$')])
	let firstcol=virtcol('.')-wincol()+1
	let lastcol=firstcol+winwidth(0)-1
	let possav[3]=min([max([firstcol,possav[2]+possav[3]]),lastcol])
	exe "norm! ".possav[3]."|"
endfun

fun! s:SaveCursPos()
	return [bufnr('%')]+getpos('.')[1:]
endfun
fun! s:RestoreCursPos(possav)
	let win=bufwinnr(a:possav[0])
	if win==-1
		let ix=[get(t:txb.ix,bufname(a:possav[0]),-1),get(t:txb.ix,bufname(''),-1)]
		if ix[0]!=-1 && ix[1]!=-1
			if ix[0]>ix[1]
				wincmd b
				exe min([max([line('w0'),a:possav[1]]),line('w$')])
				exe winnr()==1? "" : "norm! 0g$"
			else
				wincmd t
				exe min([max([line('w0'),a:possav[1]]),line('w$')])
				norm! g0
			en
		en
	else
		exe win.'wincmd w'
   		exe min([max([line('w0'),a:possav[1]]),line('w$')])
		exe winnr()==1? ("norm! ".min([max([virtcol('.')-wincol()+1,a:possav[2]+a:possav[3]]),virtcol('.')-wincol()+winwidth(0)])."|") : ("norm! 0".min([max([1,a:possav[2]+a:possav[3]]),winwidth(0)])."|")
	en
endfun

fun! TXBmouseNav()
	let possav=[bufnr('%')]+getpos('.')[1:]
	let [c,w0]=[getchar(),-1]
	if c!="\<leftdrag>"
		return 1
	else
		while c!="\<leftrelease>"
			if v:mouse_win!=w0
				let w0=v:mouse_win
				exe "norm! \<leftmouse>"
				if !exists('t:txb')
					return
				en
				let [b0,wrap]=[winbufnr(0),&wrap]
				let [x,y,offset,ix]=wrap? [wincol(),line('w0')+winline(),0,get(t:txb.ix,bufname(b0),-1)] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol(),get(t:txb.ix,bufname(b0),-1)]
				let s0=t:txb.ix[bufname(winbufnr(1))]
				let ecstr=join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bgridS)? t:txb.gridnames[v:val/s:bgridS] : "."'))." ' ".join(map(range(line('w0'),line('w$'),s:sgridL),'!v:key || v:val%(s:bgridL)<s:sgridL? v:val/s:bgridL : "."'))
			else
				if wrap
					exe "norm! \<leftmouse>"
					let [nx,l0]=[wincol(),y-winline()]
				else
					let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
				en
				let [x,xs]=x && nx? [x,nx>x? -s:PanLeft(nx-x) : s:PanRight(x-nx)] : [x? x : nx,0]
				exe 'norm! '.bufwinnr(b0)."\<c-w>w".(l0>0? l0 : 1).'zt'
				let [x,y]=[wrap? v:mouse_win>1? x : nx+xs : x, l0>0? y : y-l0+1]
				redr
				ec ecstr
			en
			let c=getchar()
			while c!="\<leftdrag>" && c!="\<leftrelease>"
				let c=getchar()
			endwhile
		endwhile
	en
	let s0=t:txb.ix[bufname(winbufnr(1))]
	redr|ec join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bgridS)? t:txb.gridnames[v:val/s:bgridS] : "."')).' , '.join(map(range(line('w0'),line('w$'),s:sgridL),'!v:key || v:val%(s:bgridL)<s:sgridL? v:val/s:bgridL : "."'))
	call s:RestoreCursPos(possav)
endfun

fun! s:PanLeft(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let [extrashift,tcol]=[0,get(t:txb.ix,bufname(winbufnr(1)),-1)]
	if tcol<0
		throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txb.name)
	elseif a:N<&columns
		while winwidth(winnr('$'))<=a:N
			wincmd b
			let extrashift=(winwidth(0)==a:N)
			hide
		endw
	elseif a:N>0
		wincmd t
		only
	else
		return
	en
	if winwidth(0)!=&columns
		wincmd t	
		if winwidth(winnr('$'))<=a:N+3+extrashift || winnr('$')>=9
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
			else
				exe 'vert res+'.(a:N+extrashift)
			en
			se wfw
		else
			exe 'vert res+'.(a:N+extrashift)
		en
		while winwidth(0)>=t:txb.size[tcol]+2
			se nowfw scrollopt=jump
			let nextcol=(tcol-1)%t:txb.len
			exe 'top '.(winwidth(0)-t:txb.size[tcol]-1).'vsp '.t:txb.name[nextcol]
			exe alignmentcmd
			exe t:txb.exe[nextcol]
			wincmd l
			se wfw
			norm! 0
			wincmd t
			let tcol=nextcol
			se wfw scrollopt=ver,jump
			let &scrollopt=t:txb.scrollopt
		endwhile
		let offset=t:txb.size[tcol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=&wrap? -a:N-extrashift : virtcol('.')-wincol()-a:N-extrashift
		if loff>=0
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
			while loff<=-2
				let tcol=(tcol-1)%t:txb.len
				let loff+=t:txb.size[tcol]+1
			endwhile
			se scrollopt=jump
			exe 'e '.t:txb.name[tcol]
			exe alignmentcmd
			exe t:txb.exe[tcol]
			let &scrollopt=t:txb.scrollopt
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
			if t:txb.size[tcol]-loff<&columns-1
				let spaceremaining=&columns-t:txb.size[tcol]+loff
				let NextCol=(tcol+1)%len(t:txb.name)
				se nowfw scrollopt=jump
				while spaceremaining>=2
					exe 'bot '.(spaceremaining-1).'vsp '.(t:txb.name[NextCol])
					exe alignmentcmd
					exe t:txb.exe[NextCol]
					norm! 0
					let spaceremaining-=t:txb.size[NextCol]+1
					let NextCol=(NextCol+1)%len(t:txb.name)
				endwhile
				let &scrollopt=t:txb.scrollopt
				windo se wfw
			en
		en
	en
	return extrashift
endfun

fun! s:PanRight(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let tcol=get(t:txb.ix,bufname(winbufnr(1)),-1)
	let [bcol,loff,extrashift,N]=[get(t:txb.ix,bufname(winbufnr(winnr('$'))),-1),winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0),0,a:N]
	let nobotresize=0
	if tcol<0 || bcol<0
		throw (tcol<0? bufname(winbufnr(1)) : '').(bcol<0? ' '.bufname(winbufnr(winnr('$'))) : '')." not contained in current plane: ".string(t:txb.name)
	elseif N>=&columns
		if winwidth(1)==&columns
			let loff+=&columns
		else
			let loff=winwidth(winnr('$'))
			let bcol=tcol
		en
		if loff>=t:txb.size[tcol]
			let loff=0
			let tcol=(tcol+1)%len(t:txb.name)
		en
		let toshift=N-&columns
		if toshift>=t:txb.size[tcol]-loff+1
			let toshift-=t:txb.size[tcol]-loff+1
			let tcol=(tcol+1)%len(t:txb.name)
			while toshift>=t:txb.size[tcol]+1
				let toshift-=t:txb.size[tcol]+1
				let tcol=(tcol+1)%len(t:txb.name)
			endwhile
			if toshift==t:txb.size[tcol]
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%len(t:txb.name)
				let loff=0
			else
				let loff=toshift
			en
		elseif toshift==t:txb.size[tcol]-loff
			let N+=1
			let extrashift=-1
			let tcol=(tcol+1)%len(t:txb.name)
			let loff=0
		else
			let loff+=toshift	
		en
		se scrollopt=jump
		exe 'e '.t:txb.name[tcol]
		exe alignmentcmd
		exe t:txb.exe[tcol]
		let &scrollopt=t:txb.scrollopt
		only
		exe 'norm! 0'.(loff>0? loff.'zl' : '')
	elseif N>0
		if winwidth(1)==1
			wincmd t
			hide
			let N-=2
			if N<=0
				return
			en
		en
		let shifted=0
		while winwidth(1)<=N
			let w2=winwidth(2)
			let extrashift=winwidth(1)==N
			let shifted+=winwidth(1)+1
			wincmd t
			hide
			if winwidth(1)==w2
				let nobotresize=1
			en
			let tcol=(tcol+1)%len(t:txb.name)
			let loff=0
		endw
		let N+=extrashift
		let loff+=N-shifted
	else
		return
	en
	let wf=winwidth(1)-N
	if wf+N!=&columns
		if !nobotresize
			wincmd b
			exe 'vert res+'.N
			if virtcol('.')!=wincol()
				norm! 0
			en
			wincmd t	
			if winwidth(1)!=wf
				exe 'vert res'.wf
			en
		else
			wincmd t
		en
		let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
		exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		while winwidth(winnr('$'))>=t:txb.size[bcol]+2
			wincmd b
			se nowfw scrollopt=jump
			let nextcol=(bcol+1)%len(t:txb.name)
			exe 'rightb vert '.(winwidth(0)-t:txb.size[bcol]-1).'split '.t:txb.name[nextcol]
			exe alignmentcmd
			exe t:txb.exe[nextcol]
			wincmd h
			se wfw
			wincmd b
			norm! 0
			let bcol=nextcol
			let &scrollopt=t:txb.scrollopt
		endwhile
	elseif &columns-t:txb.size[tcol]+loff>=2
		let bcol=tcol
		let spaceremaining=&columns-t:txb.size[tcol]+loff
		se nowfw scrollopt=jump
		while spaceremaining>=2
			let bcol=(bcol+1)%len(t:txb.name)
			exe 'bot '.(spaceremaining-1).'vsp '.(t:txb.name[bcol])
			exe alignmentcmd
			exe t:txb.exe[bcol]
			norm! 0
			let spaceremaining-=t:txb.size[bcol]+1
		endwhile
		let &scrollopt=t:txb.scrollopt
		windo se wfw
	else
		let offset=loff-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	en
	return extrashift
endfun
