"Global hotkey: press this key anywhere to begin
	let txb_key='<f10>'
"Grid panning speed: reduce for a smoother animation
	let s:hpanstep=9
	let s:vpanstep=2
"Grid dimensions: a small grid is 1 split and s:smHgrid lines, a big grid s:bigVgrid splits and s:bigHgrid lines
	let s:bigVgrid=3
	let s:smHgrid=15
	let s:bigHgrid=45
"Block dimensions for map
	let s:mapgridH=3
	let s:mapgridW=7

let txb_onloadcol='se scb cole=2 nowrap'
if &cp | se nocompatible | en
nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe exists('t:txb')? 'call TXBmouseNav()' : 'call TXBmousePanWin()'\|exe "keepj norm! \<lt>leftmouse>"<cr>
exe 'nn <silent> '.txb_key.' :if exists("t:txb") \| call TXBcmd() \| else \| call TXBstart()\| en<cr>'
let TXB_PREVPAT=exists("TXB_PREVPAT")? TXB_PREVPAT : ""
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

fun! s:PrintHelp()
	let helpmsg="\n\\CWelcome to the textabyss, mwahahaha...\n\\CJan 11, 2013 q335r49@gmail.com\n
	\\n    To start, press ".g:txb_key." and enter a file pattern. You can try \"*\" to for all files or something like \"pl*\" for a list that would include \"pl1\", \"plb\", \"planetary.txt\", etc
	\\n\n    Once loaded, drag the mouse to navigate or press ".g:txb_key." for various commands:\n
	\\n    f1        - show this message
	\\n    R r       - Redraw / redraw and return to normal mode
	\\n    hjkl      - cardinal motions along grid (HJKL for big grid)
	\\n    yubn      - diagonal motions along grid (YUBN for big grid)
	\\n    .         - Snap to big grid
	\\n    g         - Goto grid (eg, 'e3')
	\\n    D A       - Delete / append split
	\\n    E         - Edit split settings
	\\n    S         - Scrollbind toggle
	\\n    m         - go to bookmark
	\\n    ^X        - Delete hidden buffers (eg, if too many are loaded from panning)\n
	\\n    o         - Open map
	\\n    c         - in map: change grid name
	\\n    hjkl      - in map: cardinal motions
	\\n    yubn      - in map: diagonal motions
	\\n    g,<cr>    - in map: go to grid\n
	\\n    The vi keys (hjkl for cardinals and yubn for diagonals) will navigate the text by grid which provides a kind of spatial guide. Panning by small grid snaps the top corner to a split edge and a line multiple of ".s:smHgrid.". Panning by big grid (uppercase keys) snaps the top corner to a split multiple of ".s:bigVgrid." and to a line multiple by ".s:bigHgrid.".\n
	\\n    If the file list includes the current buffer, loading will redraw the plane there. This allows you to restore your previous position. If you have viminfo set to save global variables (:set viminfo+=!), the previous plane will automatically be saved (suggested when the hotkey is pressed for initialization in a new vim session).\n
	\\n    The map (o) provides yet another way to navigate the abyss. It will start out blank -- fill it in by naming (c) big grids. It is navigated the same way as the grid itself and will always start centered at the current block. You must set your viminfo to save global variables (:set viminfo+=!) to save the map between sessions.\n
	\\n    There are a few known limitations. Scrollbind desyncs if scrolling in a much longer split (press ".g:txb_key."r to redraw). Mouse events past column 253 go undetected. Horizontal splits are not supported and may interfere with redrawing. And for now, files are assumed to be in the current directory, so change to that directory beforehand (:cd ~/SomeDir). Other directories should work but this hasn't been thoroughly tested.\n\n\\C(Press enter to continue ... or input 'm' for monologue)"
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	redr|if input(FormatPar(helpmsg,width,(&columns-width)/2))==?'m'
	let helpmsg="\n\\C\"... into the abyss he slipped
	\\n\\CEndless fathoms to fall
	\\n\\CNe'er again homely hearth to linger
	\\n\\CNor warm hand to grasp!\"\n\n
	\\n    I've been thinking now for a long time how the usual memory technologies are pretty inadequate when it comes organizing thinking over a long period of time, since it seems to me that thoughts can't really be broken up into disrete projects or categories. So I don't think of this as a system primarily to be used for organizing -- that comes naturally -- though of course I did once think it would primarily be an aid towards that ends. But now, I don't think of this as another kind of mind mapping but rather more as a system of raw accumulation. There are some tools for organizing and layout but primarily the hope is maybe simply -- to descend!\n
	\\n    So what should one throw into the textabyss? Ideally, in my mind, everything: it seems to me that time itself is perhaps the only real category there is, and perhaps not even that. Thoughts of a certain period tend to relate to each other in a way that we can't forsee when we try to make sense of our thoughts.\n
	\\n    Vim is sort of a fascinating environment. Writing textabyss has been an pretty entertaining ... I tried above all to make use of inbuilt functions and to aim for speed. The coolest feeling in vim, to me, is, *removing* a feature that you've added because you realize that the developers have already anticipated the problem -- to realize other means of acheiving your ends, or to find that those ends aren't really worth pursuing. Vim was just about the only choice for me primarily because of how easy it is to install everywhere, especially on Android, and so the discovery that vim is well thought out comes as a kind of added bonus. I sort of hope that textabyss itself is the same way, that one would start by awkwardly incorporating it into one's workflow, realize its inadequacies and limitations, but also to also to slowly realize the workflow that it has imagined as in many ways sufficient.\n
	\\n    A note about scrollbinding splits of uneven lengths -- I've tried to smooth over this process but occasionally splits will still desync for this reason. Actually, just padding, say, 500 or 1000 blank lines to the end of every split would solve most problems with very little overhead. The main issue might then be that one would want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.\n
	\\n    There are some limitations on file names and locations that I've left as is, for the sake of simplicity and speed. File names, for example, shouldn't have spaces and should probably be located in the same directory. I originally planned for textabyss to be a reorganization of existing files but I think it makes much more sense not to pay attention to the names of splits at all, and instead to, for example, focus on the grid (eg, 'e5') as a way of orienting oneself. It's easy to snap to the grid, but perhaps the grid itself should be treated as a general kind of guide, and not as precise locations or 'blocks' of text. One knows vaguely where something is.\n
	\\n    One of the great things about vim is how easy it is to synergize various components -- well, sometimes with a bit of complex conditional scripting. For me, I feel like a lot of functions can be left out of this core script since they are easily added by the user. And I do hope that the entire textabyss fits fairly transparently into what one is already working with. One example, mentioned above, is the helpfulness of a 'goto last non-blank line' function. Another example would be the autocommands on loading new scripts -- one could, depending on one's needs, automatically perform initialization commands such as padding blank lines and adjusting various settings when a split is created or displayed with vim's inbuilt :autocommand feature.\n
	\\n    Thanks again for trying out textabyss!\n\n\\C                   - Leon Jan '14"
	cal input(FormatPar(helpmsg,width,(&columns-width)/2))
	en
endfun

let s:pad=repeat(' ',100)
fun! s:GetMapDisp(map,w,h,H)
	let print=[]
	let pos=0
	let map={'w':(a:w),'h':(a:h)}
	let s=map(range(a:h),'[v:val*a:w,v:val*a:w+a:w-1]')
	let map.hlmap=map(range(a:H),'range(len(a:map))')
	for i in range(a:H)
		for j in range(a:h)
			call add(print,join(map(map(range(len(a:map)),'len(a:map[v:val])>i? a:map[v:val][i] : "[NUL]"'),'v:val[s[j][0] : s[j][1]].s:pad[1:(s[j][1]>=len(v:val)? (s[j][0]>=len(v:val)? a:w : a:w-len(v:val)+s[j][0]) : 0)]'))."\n")
		endfor
		let l=len(print[-1])
		for k in range(len(a:map))
			let map.hlmap[i][k]=map(range(a:h),"[pos+(a:w+1)*k+v:val*l,pos+(a:w+1)*k+a:w-1+v:val*l]")
		endfor
		let pos+=len(print[-1])*a:h+1
		call add(print,"\n")
	endfor
	let map.str=join(print,"")
	return map
endfun

fun! s:PrintHL(disp,r,c,trailer)
	let prev_stop=0
	for i in a:disp.hlmap[a:r][a:c]
		echohl NONE
		echon i[0]? a:disp.str[prev_stop : i[0]-1] : ''
		echohl visual
		echon a:disp.str[i[0]:i[1]]
		let prev_stop=i[1]+1
	endfor
	echohl NONE
	echon a:disp.str[prev_stop :].a:trailer
endfun

fun! s:NavigateMap(array,c_ini,r_ini)
	let [more,&more]=[&more,0]
	let &ch=&lines-1
	let r=a:r_ini
	let c=a:c_ini
	let r_screen=(&lines-1)/(s:mapgridH+1)
	let r_remainder=&lines-r_screen*(s:mapgridH+1)
	let whitespace=repeat("\n",r_remainder-1).' '
	let c_screen=&columns/(s:mapgridW+1)
	let r_off=max([r-r_screen/2,0])
	let c_off=max([c-c_screen/2,0])
	let subarray=map(range(c_off,c_off+c_screen-1),'map(range(r_off,r_off+r_screen-1),"exists(\"a:array[".v:val."][v:val]\")? a:array[".v:val."][v:val] : \"\"")')
	let disp=s:GetMapDisp(subarray,s:mapgridW,s:mapgridH,r_screen)
	let k=0
	let update=0
	let cmd=0
	while k!=27
		redr!
		call s:PrintHL(disp,r-r_off,c-c_off,whitespace.nr2char(c+65)." ".r)
		let k=getchar()
		exe get(s:mapdict,k,'')
		let [r_offnew,c_offnew]=[r<r_off? r : r>=r_off+r_screen? r-r_screen+1 : r_off,c<c_off? c : c>=c_off+c_screen? c-c_screen+1 : c_off]
		if [r_off,c_off]!=[r_offnew,c_offnew] || update
			let [r_off,c_off]=[r_offnew,c_offnew]
			let subarray=map(range(c_off,c_off+c_screen-1),'map(range(r_off,r_off+r_screen-1),"exists(\"a:array[".v:val."][v:val]\")? a:array[".v:val."][v:val] : \"\"")')
			let disp=s:GetMapDisp(subarray,s:mapgridW,s:mapgridH,r_screen)
			let update=0
		en
	endwhile
	let &ch=1
	let &more=more
endfun
let s:mapdict={}
let s:mapdict.106="let r+=1"
let s:mapdict.107="let r=r>0? r-1 : r"
let s:mapdict.108="let c+=1"
let s:mapdict.104="let c=c>0? c-1 : c"
let s:mapdict.121="let c=c>0? c-1 : c|let r=r>0? r-1 : r"
let s:mapdict.117="let c+=1|let r=r>0? r-1 : r"
let s:mapdict.98 ="let c=c>0? c-1 : c|let r+=1"
let s:mapdict.110="let c+=1|let r+=1"
let s:mapdict.99 ="let input=input('Change: ',exists('a:array[c][r]')? a:array[c][r] : '')\n
\if !empty(input)\n
 	\if c>=len(a:array)\n
		\call extend(a:array,eval('['.join(repeat(['[]'],c+1-len(a:array)),',').']'))\n
	\en\n
	\if r>=len(a:array[c])\n
		\call extend(a:array[c],repeat([''],r+1-len(a:array[c])))\n
	\en\n
	\let a:array[c][r]=input\n
	\let update=1\n
\en\n"
let s:mapdict.103="call s:GotoBlock(nr2char(65+c).r)|let k=27"
let s:mapdict.13=s:mapdict.103
let TXBcmds.111='let grid=s:GetGrid()|cal s:NavigateMap(t:txb.map,grid[0],grid[1])|let continue=0'

fun! DeleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
let TXBcmds.24='cal DeleteHiddenBuffers()|let continue=0'

fun! FormatPar(str,w,pad)
	let [output,pad,bigpad,spc]=["",repeat(" ",a:pad),repeat(" ",a:w+10),repeat(' ',len(&brk))]
	for line in split(a:str,"\n",1)
		let [center,seg]=[line[0:1]==#'\C',[0]]
		if center
			let line=line[2:]
		en
		while seg[-1]<len(line)-a:w
			let ix=(a:w+strridx(tr(line[seg[-1]:seg[-1]+a:w-1],&brk,spc),' '))%a:w
			call add(seg,seg[-1]+ix-(line[seg[-1]+ix=~'\s']))
			let ix=seg[-2]+ix+1
			while line[ix]==" "
				let ix+=1
			endwhile
			call add(seg,ix)
		endw
		call add(seg,len(line)-1)
		let output.=center? pad.join(map(range(len(seg)/2),'bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].line[seg[2*v:val]:seg[2*v:val+1]]'),"\n".pad)."\n" : pad.join(map(range(len(seg)/2),'line[seg[2*v:val]:seg[2*v:val+1]]'),"\n".pad)."\n"
	endfor
	return output
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
	let line=index(t:txb.gridnames,col,0,1)*3
	call TXB_GotoPos(index(t:txb.gridnames,col,0,1)*3,row*45)
endfun

fun! s:BlockPan(dx,y,...)
	let cury=line('w0')
	let absolute_x=exists('a:1')? a:1 : 0
	let dir=absolute_x? absolute_x : a:dx
	let y=a:y>cury?  (a:y-cury-1)/s:smHgrid+1 : a:y<cury? -(cury-a:y-1)/s:smHgrid-1 : 0
   	let update_ydest=y>=0? 'let y_dest=!y? cury : cury/'.s:smHgrid.'*'.s:smHgrid.'+'.s:smHgrid : 'let y_dest=!y? cury : cury>'.s:smHgrid.'? (cury-1)/'.s:smHgrid.'*'.s:smHgrid.' : 1'
	let pan_y=(y>=0? 'let cury=cury+'.s:vpanstep.'<y_dest? cury+'.s:vpanstep.' : y_dest' : 'let cury=cury-'.s:vpanstep.'>y_dest? cury-'.s:vpanstep.' : y_dest')."\n
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
			while winwidth(1)>s:hpanstep
				call PanRight(s:hpanstep)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call PanRight(winwidth(1))
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
			while winwidth(1)<t:txb.size[ix]-s:hpanstep
				call s:PanLeft(s:hpanstep)
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
let s:Y1='let y=y/s:smHgrid*s:smHgrid+s:smHgrid|'
let s:Ym1='let y=max([1,y/s:smHgrid*s:smHgrid-s:smHgrid])|'
	let TXBcmds.104='cal s:BlockPan(-1,y)'
	let TXBcmds.106=s:Y1.'cal s:BlockPan(0,y)'
	let TXBcmds.107=s:Ym1.'cal s:BlockPan(0,y)'
	let TXBcmds.108='cal s:BlockPan(1,y)'
	let TXBcmds.121=s:Ym1.'cal s:BlockPan(-1,y)'
	let TXBcmds.117=s:Ym1.'cal s:BlockPan(1,y)'
	let TXBcmds.98 =s:Y1.'cal s:BlockPan(-1,y)'
	let TXBcmds.110=s:Y1.'cal s:BlockPan(1,y)'
let s:DXm1='map([t:txb.ix[bufname(winbufnr(1))]],"winwidth(1)<=t:txb.size[v:val]? (v:val==0? t:txb.len-t:txb.len%s:bigVgrid : (v:val-1)-(v:val-1)%s:bigVgrid) : v:val-v:val%s:bigVgrid")[0]'
let s:DX1='map([t:txb.ix[bufname(winbufnr(1))]],"v:val>=t:txb.len-t:txb.len%s:bigVgrid? 0 : v:val-v:val%s:bigVgrid+s:bigVgrid")[0]'
let s:Y1='let y=y/s:bigHgrid*s:bigHgrid+s:bigHgrid|'
let s:Ym1='let y=max([1,y/s:bigHgrid*s:bigHgrid-s:bigHgrid])|'
	let TXBcmds.72='cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.74=s:Y1.'cal s:BlockPan(0,y)'
	let TXBcmds.75=s:Ym1.'cal s:BlockPan(0,y)'
	let TXBcmds.76='cal s:BlockPan('.s:DX1.',y,1)'
	let TXBcmds.89=s:Ym1.'cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.85=s:Ym1.'cal s:BlockPan('.s:DX1.',y,1)'
	let TXBcmds.66=s:Y1.'cal s:BlockPan('.s:DXm1.',y,-1)'
	let TXBcmds.78=s:Y1.'cal s:BlockPan('.s:DX1.',y,1)'
unlet s:DX1 s:DXm1 s:Y1 s:Ym1

fun! s:GetGrid()
	let [ix,l0]=[t:txb.ix[bufname(winbufnr(1))],line('w0')]
	let [sd,dir]=(ix%s:bigVgrid>s:bigVgrid/2 && ix+s:bigVgrid-ix%s:bigVgrid<t:txb.len-1)? [ix+s:bigVgrid-ix%s:bigVgrid,1] : [ix-ix%s:bigVgrid,-1]
	return [sd/3,(l0%s:bigHgrid>s:bigHgrid/2? l0+s:bigHgrid-l0%s:bigHgrid : l0-l0%s:bigHgrid)/s:bigHgrid]
endfun
fun! s:SnapToGrid()
	let [ix,l0]=[t:txb.ix[bufname(winbufnr(1))],line('w0')]
	let [sd,dir]=(ix%s:bigVgrid>s:bigVgrid/2 && ix+s:bigVgrid-ix%s:bigVgrid<t:txb.len-1)? [ix+s:bigVgrid-ix%s:bigVgrid,1] : [ix-ix%s:bigVgrid,-1]
	call s:BlockPan(sd,l0%s:bigHgrid>s:bigHgrid/2? l0+s:bigHgrid-l0%s:bigHgrid : l0-l0%s:bigHgrid,dir)
endfun
let TXBcmds.46='call s:SnapToGrid()|let continue=0'

fun! TXBcmd(...)
	let [y,continue,msg]=[line('w0'),1,'']
	let pos=[winnr(),winline(),wincol()]
	if a:0 | exe get(g:TXBcmds,a:1,'let msg="Press f1 for help"') | en
	while continue
		let s0=t:txb.ix[bufname(winbufnr(1))]
		redr|ec empty(msg)? join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bigVgrid)? t:txb.gridnames[v:val/s:bigVgrid] : "."')).' - '.join(map(range(line('w0'),line('w$'),s:smHgrid),'!v:key || v:val%(s:bigHgrid)<s:smHgrid? v:val/s:bigHgrid : "."')) : msg
		let [msg,c]=['',getchar()]
		exe get(g:TXBcmds,c,'let msg="Press f1 for help"')
	endwhile
    let s0=t:txb.ix[bufname(winbufnr(1))]
	exe pos[0].'wincmd w'
	call setpos('.',[0,line('w0')+pos[1],min([pos[2],winwidth(0)]),0])
	redr|ec join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bigVgrid)? t:txb.gridnames[v:val/s:bigVgrid] : "."')).' _ '.join(map(range(line('w0'),line('w$'),s:smHgrid),'!v:key || v:val%(s:bigHgrid)<s:smHgrid? v:val/s:bigHgrid : "."'))
endfun
let TXBcmds.68="redr
\\n	let confirm=input(' < Really delete current column (y/n)? ')
\\n	if confirm==?'y'
\\n		let ix=get(t:txb.ix,expand('%'),-1)
\\n		if ix!=-1
\\n			call s:DeleteCol(ix)
\\n			wincmd W
\\n			call s:LoadPlane(t:txb)
\\n			let msg='col '.ix.' removed'
\\n		else
\\n			let msg='Current buffer not in plane; deletion failed'
\\n		en
\\n	en"
let TXBcmds.65="let ix=get(t:txb.ix,expand('%'),-1)
\\n	if ix!=-1
\\n	    redr
\\n		let file=input(' < File to append: ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')
\\n		if !empty(file)
\\n			call s:AppendCol(ix,file)
\\n			call s:LoadPlane(t:txb)
\\n			let msg='col '.(ix+1).' appended'
\\n		else
\\n			let msg='(aborted)'
\\n		en
\\n	else
\\n		let msg='Current buffer not in plane'
\\n	en"
let TXBcmds.27="let continue=0|redr|ec ''"
let TXBcmds.114="call s:LoadPlane(t:txb)|redr|ec ' (redrawn)'|let continue=0"
let TXBcmds.82="call s:LoadPlane(t:txb)|let msg='redrawn'"
let TXBcmds["\<leftmouse>"]="call TXBmouseNav()|let y=line('w0')|let continue=0|redr"
let TXBcmds.83='let [msg,t:txb.scrollopt]=t:txb.scrollopt=="ver,jump"? ["Scrollbind off","jump"] : [" < Scrollbind on >","ver,jump"] | call s:LoadPlane()'
let TXBcmds["\<f1>"]='call s:PrintHelp()|let continue=0'
let TXBcmds.69='call s:EditSettings()|let continue=0'
let TXBcmds.103="let input=input('Goto block: ')|if !empty(input)|call s:GotoBlock(input)|en|let continue=0"

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
	elseif c=="\<f1>"
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

fun! s:Pan(dx,y)
	exe a:dx>0? 'call PanRight(a:dx)' : 'call s:PanLeft(-a:dx)'
	if a:y>line('$')
		for i in range(winnr('$')-1)
			wincmd w
			if line('$')>=a:y
				break
			en
		endfor
	en
	exe 'norm!' a:y.'zt'
	return line('w0')
endfun

fun! s:ShiftView(targcol,...)
	let [tcol,targline,offset,speed]=[!a:targcol,exists('a:1')? a:1 : line('w0'),exists('a:2')? a:2 : 0,exists('a:3')? a:3 : 3]
	let sizes=t:txb.size+t:txb.size
	while tcol!=a:targcol
		let [new_tcol,l0]=[get(t:txb.ix,bufname(winbufnr(1)),-1),line('w0')]
		if new_tcol==-1
			throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txb.name)
		en
		let tcol=new_tcol<tcol && tcol<a:targcol? new_tcol+t:txb.len : new_tcol>tcol && tcol>a:targcol? new_tcol-t:txb.len : new_tcol
		let x_dist0=a:targcol==tcol? -max([sizes[a:targcol]-winwidth(1),0])+offset : a:targcol>tcol? winwidth(1)+(a:targcol-tcol>1? eval(join(sizes[(tcol+1):(a:targcol-1)],'+')) : 0)+offset : -(max([0,sizes[tcol]-winwidth(1)])+(tcol-a:targcol>0? eval(join(sizes[(a:targcol+t:txb.len) : (tcol-1+t:txb.len)],'+')) : 0))+offset
		let y_dist0=targline-l0
		let curbuf=winbufnr(1)
		let [x_dist,y_dist,x_t,y_t]=[x_dist0,y_dist0,0,0]
		while winbufnr(1)==curbuf && (x_dist || y_dist)
   			if abs(y_dist)>abs(x_dist)
				let dy=y_dist>=0? min([speed,y_dist]) : max([-speed,y_dist])
              	let dx={x_dist>=0? 'min' : 'max'}([(y_t+dy)*x_dist0/y_dist0-x_t,x_dist])
			else
				let dx=x_dist>=0? min([speed,x_dist]) : max([-speed,x_dist])
              	let dy={y_dist>=0? 'min' : 'max'}([(x_t+dx)*y_dist0/x_dist0-y_t,y_dist])
			en
			let [y_t,x_t,l0]=[y_t+dy,x_t+dx,l0+dy]
			let [x_dist,y_dist]=[x_dist-dx,targline-l0]
			call s:Pan(dx,l0)
			redr
		endwhile
	endwhile
endfun

fun! s:CenterPos(targcol,...)
   	let cursor=[exists("a:1")? a:1 : line('.'),exists("a:2")? a:2 : 1]
	let [offset,tcol]=[(&columns-t:txb.size[a:targcol])/2,a:targcol]
	while offset>0
		let tcol=(tcol-1)%t:txb.len
		let offset-=t:txb.size[tcol]
	endwhile
	let tcol=tcol<0? tcol+t:txb.len : tcol
	let cur_tcol=get(t:txb.ix,bufname(winbufnr(1)),-1)
	if cur_tcol==-1
		throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txb.name)
	en
	if tcol>cur_tcol && cur_tcol+t:txb.len-tcol<tcol-cur_tcol
		call s:ShiftView(tcol-t:txb.len, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	elseif tcol<cur_tcol && tcol+t:txb.len-cur_tcol<cur_tcol-tcol
		call s:ShiftView(tcol+t:txb.len, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	else
		call s:ShiftView(tcol, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	en
	let targwin=bufwinnr(t:txb.name[a:targcol])
	if targwin==-1
		wincmd t
		call s:LoadPlane()
		let targwin=bufwinnr(t:txb.name[a:targcol])
	en
	if targwin==-1
		throw "Badly formed columns"
	else
		exe targwin.'wincmd w'
		cal cursor(cursor)
	en
endfun

fun! s:CenterBookmark(mark,...)
	let [bufnr,line,col,off]=getpos("'".a:mark)
	let colix=get(t:txb.ix,bufname(bufnr? bufnr : bufnr('%')),-1)
	if colix==-1
	    ec "Mark '".a:mark." not on current plane"
		return 2
	elseif line==0
		ec 'Mark '.a:mark." not set"
		return 1
	else
		call s:CenterPos(colix,line,col,exists('a:1')? a:1 : 1)
	en
endfun
let TXBcmds.109='redr|ec " < mark >"|call TXBoninsert()|call s:CenterBookmark(nr2char(getchar()))|let continue=0'

fun! s:CreatePlane(name,...)
	let plane={}
	let plane.name=type(a:name)==1? map(split(glob(a:name)),'escape(v:val," ")') : type(a:name)==3? a:name : 'INV'
	if plane.name is 'INV'
     	throw 'First argument ('.string(a:name).') must be string (filepattern) or list (list of files)'
	else
		let plane.len=len(plane.name)
		let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
		let plane.exe=exists("a:2")? a:2 : repeat([g:txb_onloadcol],plane.len)
		let plane.scrollopt='ver,jump'
		let plane.gridnames=[]
		let [plane.ix,i]=[{},0]
		let plane.map=[[]]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		if len(t:txb.gridnames)<plane.len
			let t:txb.gridnames=s:MakeGridNameList(plane.len+50)
		en
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
if !exists('g:opt_device') "for compatibility
	let opt_device=''
en
fun! TXBmousePanWin()
	if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
		if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
		return 1 | en
	exe "norm! \<leftmouse>"
	let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
	let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(g:opt_device==?'droid4' && veon)? 'redr!':'redr']
	while getchar()=="\<leftdrag>"
		let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
		let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
		call winrestview(v)
		exe redrexpr
	endwhile
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
endfun

fun! TXBmouseNav()
	let [c,w0]=[100,-1]
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
			let ecstr=join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bigVgrid)? t:txb.gridnames[v:val/s:bigVgrid] : "."'))." ' ".join(map(range(line('w0'),line('w$'),s:smHgrid),'!v:key || v:val%(s:bigHgrid)<s:smHgrid? v:val/s:bigHgrid : "."'))
		else
			if wrap
				exe "norm! \<leftmouse>"
				let [nx,l0]=[wincol(),y-winline()]
			else
				let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
			en
			let [x,xs]=x && nx? [x,nx>x? -s:PanLeft(nx-x) : PanRight(x-nx)] : [x? x : nx,0]
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
	let s0=t:txb.ix[bufname(winbufnr(1))]
	redr|ec join(map(s0+winnr('$')>t:txb.len-1? range(s0,t:txb.len-1)+range(0,s0+winnr('$')-t:txb.len) : range(s0,s0+winnr('$')-1),'!v:key || !(v:val%s:bigVgrid)? t:txb.gridnames[v:val/s:bigVgrid] : "."')).' , '.join(map(range(line('w0'),line('w$'),s:smHgrid),'!v:key || v:val%(s:bigHgrid)<s:smHgrid? v:val/s:bigHgrid : "."'))
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

fun! PanRight(N,...)
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
			wincmd t	
			if winwidth(1)!=wf
				exe 'vert res'.wf
			en
		en
		wincmd t
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
