" ---- User Settings ----
"Panning mode hotkey, as name rather than raw characters (ie, '<f3>' and not "\<f3>" or ^V<f3>):
	let txpHotkey=exists("txpHotkey")? txpHotkey : '<f3>'
"Execute on opening a new column. Edit for a particular file by using <hotkey>E
"Note: scb (scrollbind) should always be set, toggle scrollbinding by using <hotkey>S instead
	let txpDefaultExe='se scb nowrap cole=2'
                      
nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe exists('t:txP')? 'call MousePanCol()' : 'call MousePanWin()'\|exe "keepj norm! \<lt>leftmouse>"<cr>
exe 'nn <silent> '.g:txpHotkey.' :if exists("t:txP") \| call KbdPan() \| else \| call TxpPrompt()\| en<cr>'
fun! TxpPrompt(...)                                          
	let filepattern=a:0? a:1 : exists("g:TXPPREVPAT")? g:TXPPREVPAT : ''
	if a:0 && a:1 is 0
		redr|ec "
		\\n      ------------ TextPlane (Updated Dec 26 '13) -----------
		\\n Welcome to TextPlane, a panning workspace for vim! To begin, press
		\\n     ".printf("%-10s",g:txpHotkey)."- TextPlane initialize hotkey"."
		\\n and enter a file pattern with a wildcard character to bring up 
		\\n a list of files, eg:
		\\n     file*     - file0, file1, file-new etc in current directory
		\\n     *         - all files in current directory
		\\n
		\\n If the current buffer is a part of the plane, the plane will load
		\\n at the current buffer position. Otherwise, it will load in a new
		\\n tab. Once loaded:
		\\n     f1        - show this message
		\\n     leftmouse - Pan with mouse
		\\n     ".printf("%-10s",g:txpHotkey)."- Panning mode hotkey
		\\n In panning mode:
		\\n     r         - Redraw
		\\n     ".printf("%-10s",g:txpHotkey)."- Redraw and go back to normal mode
		\\n     hjklyubn  - pan
		\\n     HJKLYUBN  - pan faster
		\\n     <tab>     - Go back in changelist
		\\n     <space>   - go foward in changelist
		\\n     D         - Delete this column
		\\n     A         - Append column here
		\\n     g         - follow text linke of the form file@line
		\\n     p[X]      - put a link to bookmark X here
		\\n     S         - Scrollbind toggle
		\\n     s         - 'slide' to bookmark
		\\n     E         - Edit current buffer settings
		\\n
		\\n                        Additional Comments:
		\\n - Assumes no horizontal splits
		\\n - For now, Textplane assumes the files are in the current directory
		\\n   (ie, :cd ~/SomeDir). Adding files from another directory shouldn't
		\\n   be a big issue but hasn't been thoroughly tested.
		\\n - Scroll binding may desync if you are scrolling a column much
		\\n   longer than the others. Press ".g:txpHotkey." twice to redraw.
		\\n - Turning off or simplifying statusbar may improve speed
		\\n - Vim can't detect cursor mouseclicks beyond column 253
		\\n - Set g:txpHotkey either in the source file or before sourcing
		\\n   TextPlane to set the the global hotkey. Use the name rather than
		\\n   the raw key, ie, '<f3>' and not \"\\<f3>\" or ^V<F3>. For example:
		\\n     :let g:txpHotkey='<f1>'  
		\\n     :source TextPlane.vim
		\\n - Pass on any bugs or suggestions to q335r49@gmail.com"
		let [filepattern,plane]=['',{'name':''}]
	else
		let plane=CreatePlane(filepattern)
		if !empty(plane.name)
			let g:TXPPREVPAT=filepattern
			let curbufix=index(plane.name,expand('%'))
			ec (a:0? "\n> Pattern \"" : "\n> Last used pattern \"").filepattern.'" matches:'
			ec join(map(copy(plane.name),'(curbufix==v:key? " -> " : "    ").v:val'),"\n")
			ec " ..." plane.len "files to be loaded in" (curbufix!=-1? "THIS tab" : "NEW tab")
		else
			ec a:0? "\n(No matches found)" : ''
		en
	en
	let input=input(empty(plane.name)? "> Enter file pattern for new plane (or type 'help' for help): " : "> Press ENTER to load plane or try another pattern (type 'help' for help): ", filepattern)
	if empty(input)
		redr|ec "(aborted)"
	elseif input==?'help'
		call TxpPrompt(0)
	elseif !empty(plane.name) && input==#filepattern
		if curbufix==-1 | tabe | en
		call LoadPlane(plane)
	else
		call TxpPrompt(input)
	en
endfun

let keypdict={}
fun! KbdPan()
	let [y,continue,msg]=[line('w0'),1,'nav']
	while continue
		redr|ec (" < ".msg." > ")[:&columns-2]
		let msg=&ls==0? join(map(tabpagebuflist(),'bufname(v:val)'),' / ') : 'nav'
		exe get(g:keypdict,getchar(),'let msg="Press f1 for help"')
	endwhile
endfun
let keypdict.68="redr
\\n	let confirm=input(' < Really delete current column (y/n)? ')
\\n	if confirm==?'y'
\\n		let ix=get(t:txP.ix,bufname(winbufnr(0)),-1)
\\n		if ix!=-1
\\n			call DeleteColumn(ix)
\\n			wincmd W
\\n			call LoadPlane(t:txP)
\\n			let msg='col '.ix.' removed'
\\n		else
\\n			let msg='Current buffer not in plane; deletion failed'
\\n		en
\\n	en"
let keypdict.65="let ix=get(t:txP.ix,bufname(winbufnr(0)),-1)
\\n	if ix!=-1
\\n	    redr
\\n		let file=input(' < File to append: ','','file')
\\n		if !empty(file)
\\n			call AppendColumn(ix,file)
\\n			call LoadPlane(t:txP)
\\n			let msg='col '.(ix+1).' appended'
\\n		else
\\n			let msg='aborted'
\\n		en
\\n	else
\\n		let msg='Current buffer not in plane; append failed'
\\n	en"
let keypdict.103="let marker=split(expand('<cWORD>'),'@')
\\n let continue=0
\\n if len(marker)>=2
\\n		let [i,l]=[get(t:txP.ix,marker[0],-1),marker[1]==0? 0 : marker[1]]
\\n		if i!=-1
\\n			call CenterPos(i,l,1,3)
\\n			let msg='slide'
\\n		else
\\n			let msg='link must be of form file@line'
\\n		en
\\n else
\\n		let msg='link must be of form file@line'
\\n	en"
let keypdict.112="redr|ec ' < register: '|let [continue,pos]=[0,getpos(\"'\".nr2char(getchar()))]|exe 'norm! i'.bufname(pos[0]).'@'.pos[1]"
let keypdict.115='redr|ec " < mark >"|call CenterBookMark(nr2char(getchar()))|let continue=0'
let keypdict.27="let continue=0|redr|ec ''"
let keypdict.104='cal Pan(-2,y)'
let keypdict.72 ='cal Pan(-6,y)'
let keypdict.106='let y=Pan(0,y+2)'
let keypdict.74 ='let y=Pan(0,y+6)'
let keypdict.107='let y=Pan(0,y-2)'
let keypdict.75 ='let y=Pan(0,y-6)'
let keypdict.108='cal Pan(2,y)'
let keypdict.76 ='cal Pan(6,y)'
let keypdict.121='let y=Pan(-1,y-1)'
let keypdict.89 ='let y=Pan(-3,y-3)'
let keypdict.117='let y=Pan(1,y-1)'
let keypdict.85 ='let y=Pan(3,y-3)'
let keypdict.98 ='let y=Pan(-1,y+1)'
let keypdict.66 ='let y=Pan(-3,y+3)'
let keypdict.110='let y=Pan(1,y+1)'
let keypdict.78 ='let y=Pan(3,y+3)'
let keypdict[len(eval('"\'.txpHotkey.'"'))>1? eval('"\'.txpHotkey.'"') : char2nr(eval('"\'.txpHotkey.'"'))]="call LoadPlane(t:txP)|redr|ec ' (redrawn)'|let continue=0"
let keypdict[114]="call LoadPlane(t:txP)|let msg='redrawn'"
let keypdict["\<leftmouse>"]="call MousePanCol()|let y=line('w0')|redr"
let keypdict.83='let [msg,t:txP.scrollopt]=t:txP.scrollopt=="ver,jump"? [" Scrollbind off","jump"] : [" Scrollbind on","ver,jump"] | call LoadPlane() | echon msg'
let keypdict["\<f1>"]='call TxpPrompt(0)'
let keypdict[69]='call TXPEditSettings()|let continue=0'

fun! TXPEditSettings()
   	let ix=get(t:txP.ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input(' < Column width: ',t:txP.size[ix])
    	let t:txP.size[ix]=empty(input)? t:txP.size[ix] : input
		redr
    	let input=input(" < Autoexecute on load:
			\\n * scb should always be set so that one can toggle global scrollbind via <hotkey>S
			\\n * wrap defaults to 'wrap' if not set\n",t:txP.exe[ix])
		let t:txP.exe[ix]=empty(input)? t:txP.exe[ix] : input
		redr
    	let input=input(' < Column position (0-'.(t:txP.len-1).'): ',ix)
		let newix=empty(input)? ix : input
		if newix>=0 && newix<t:txP.len && newix!=ix
			let item=remove(t:txP.name,ix)
			call insert(t:txP.name,item,newix)
			let item=remove(t:txP.size,ix)
			call insert(t:txP.size,item,newix)
			let item=remove(t:txP.exe,ix)
			call insert(t:txP.exe,item,newix)
			let [t:txP.ix,i]=[{},0]
			for e in t:txP.name
				let [t:txP.ix[e],i]=[i,i+1]
			endfor
		en
		call LoadPlane(t:txP)
	en
endfun

augroup txP
	autocmd!
	au InsertLeave * call TXPOnInsert()
augroup END
fun! TXPOnInsert()
	if exists("t:txP")
		if t:txP.changelistmarker<-1 && len(t:txP.changelist)>=-t:txP.changelistmarker
			call remove(t:txPchangelist,t:txP.changelistmarker,-1)
		en
		let pos=[bufname('%'),line('.'),col('.')]
		if empty(t:txP.changelist) || pos[0] isnot t:txP.changelist[-1][0] || abs(pos[1]-t:txP.changelist[-1][1])>5
			let t:txP.changelist+=[pos]
		en
		let t:txP.changelistmarker=0
	en
endfun
let keypdict.9="if !empty(t:txP.changelist)
\\n		let t:txP.changelistmarker=max([t:txP.changelistmarker-1,-len(t:txP.changelist)])
\\n		let ix=get(t:txP.ix,t:txP.changelist[t:txP.changelistmarker][0],-1)
\\n		while ix==-1
\\n			call remove(t:txP.changelist,t:txP.changelistmarker)
\\n			let t:txP.changelistmarker=max([t:txP.changelistmarker,-len(t:txP.changelist)])
\\n			let ix=empty(t:txP.changelist)? -2 : get(t:txP.ix,t:txP.changelist[t:txP.changelistmarker][0],-1)
\\n		endwhile
\\n		if ix!=-2
\\n			call CenterPos(ix,t:txP.changelist[t:txP.changelistmarker][1],t:txP.changelist[t:txP.changelistmarker][2])
\\n		en
\\n	en"
let keypdict.32="if !empty(t:txP.changelist)
\\n		let t:txP.changelistmarker=min([t:txP.changelistmarker+1,-1])
\\n		let ix=get(t:txP.ix,t:txP.changelist[t:txP.changelistmarker][0],-1)
\\n		while ix==-1
\\n			call remove(t:txP.changelist,t:txP.changelistmarker)
\\n			let t:txP.changelistmarker=min([t:txP.changelistmarker+1,-1])
\\n			let ix=empty(t:txP.changelist)? -2 : get(t:txP.ix,t:txP.changelist[t:txP.changelistmarker][0],-1)
\\n		endwhile
\\n		if ix!=-2
\\n			call CenterPos(ix,t:txP.changelist[t:txP.changelistmarker][1],t:txP.changelist[t:txP.changelistmarker][2])
\\n		en
\\n	en"

fun! CenterBookMark(mark,...)
	let [bufnr,line,col,off]=getpos("'".a:mark)
	let colix=get(t:txP.ix,bufname(bufnr? bufnr : bufnr('%')),-1)
	if colix==-1
	    ec "Mark '".a:mark." not on current plane"
		return 2
	elseif line==0
		ec 'Mark '.a:mark." not set"
		return 1
	else
		call CenterPos(colix,line,col,exists('a:1')? a:1 : 1)
	en
endfun

fun! CenterPos(targcol,...)
   	let cursor=[exists("a:1")? a:1 : line('.'),exists("a:2")? a:2 : 1]
	let [offset,tcol]=[(&columns-t:txP.size[a:targcol])/2,a:targcol]
	while offset>0
		let tcol=(tcol-1)%t:txP.len
		let offset-=t:txP.size[tcol]
	endwhile
	let tcol=tcol<0? tcol+t:txP.len : tcol
	let cur_tcol=get(t:txP.ix,bufname(winbufnr(1)),-1)
	if cur_tcol==-1
		throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txP.name)
	en
	if tcol>cur_tcol && cur_tcol+t:txP.len-tcol<tcol-cur_tcol
		call ShiftView(tcol-t:txP.len, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	elseif tcol<cur_tcol && tcol+t:txP.len-cur_tcol<cur_tcol-tcol
		call ShiftView(tcol+t:txP.len, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	else
		call ShiftView(tcol, max([1,cursor[0]-&lines/2]),-offset,exists("a:3")? a:3 : 3)
	en
	let targwin=bufwinnr(t:txP.name[a:targcol])
	if targwin==-1
		wincmd t
		call LoadPlane()
		let targwin=bufwinnr(t:txP.name[a:targcol])
	en
	if targwin==-1
		throw "Badly formed columns"
	else
		exe targwin.'wincmd w'
		cal cursor(cursor)
	en
endfun

fun! ShiftView(targcol,...)
	let sizes=t:txP.size+t:txP.size
	let [tcol,targline,offset,speed]=[!a:targcol,exists('a:1')? a:1 : line('w0'),exists('a:2')? a:2 : 0,exists('a:3')? a:3 : 3]
	while tcol!=a:targcol
		let [new_tcol,l0]=[get(t:txP.ix,bufname(winbufnr(1)),-1),line('w0')]
		if new_tcol==-1
			throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txP.name)
		en
		let tcol=new_tcol<tcol && tcol<a:targcol? new_tcol+t:txP.len : new_tcol>tcol && tcol>a:targcol? new_tcol-t:txP.len : new_tcol
		let x_dist0=a:targcol==tcol? -max([sizes[a:targcol]-winwidth(1),0])+offset : a:targcol>tcol? winwidth(1)+(a:targcol-tcol>1? eval(join(sizes[(tcol+1):(a:targcol-1)],'+')) : 0)+offset : -(max([0,sizes[tcol]-winwidth(1)])+(tcol-a:targcol>0? eval(join(sizes[(a:targcol+t:txP.len) : (tcol-1+t:txP.len)],'+')) : 0))+offset
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
			call Pan(dx,l0)
			redr
		endwhile
	endwhile
endfun

fun! Pan(dx,y)
	exe a:dx>0? 'call PanRight(a:dx)' : 'call PanLeft(-a:dx)'
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

fun! CreatePlane(name,...)
	let plane={}
	let plane.name=type(a:name)==1? map(glob(a:name,0,1),'escape(v:val," ")') : type(a:name)==3? a:name : 'INV'
	if plane.name is 'INV'
     	throw 'First argument ('.string(name).') must be string (filepattern) or list (list of files)'
	else
		let plane.len=len(plane.name)
		let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
		let plane.exe=exists("a:2")? a:2 : repeat([g:txpDefaultExe],plane.len)
		let plane.scrollopt='ver,jump'
		let plane.changelist=[[0,0,0,0]]
		let plane.changelistmarker=0
		let [plane.ix,i]=[{},0]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		return plane
	en
endfun

fun! AppendColumn(index,file,...)
	call insert(t:txP.name,a:file,a:index+1)
	call insert(t:txP.size,exists('a:1')? a:1 : 60,a:index+1)
	call insert(t:txP.exe,'se nowrap scb cole=2',a:index+1)
	let t:txP.len=len(t:txP.name)
	let [t:txP.ix,i]=[{},0]
	for e in t:txP.name
		let [t:txP.ix[e],i]=[i,i+1]
	endfor
endfun
fun! DeleteColumn(index)
	call remove(t:txP.name,a:index)	
	call remove(t:txP.size,a:index)	
	call remove(t:txP.exe,a:index)	
	let t:txP.len=len(t:txP.name)
	let [t:txP.ix,i]=[{},0]
	for e in t:txP.name
		let [t:txP.ix[e],i]=[i,i+1]
	endfor
endfun

fun! LoadPlane(...)
	if a:0
		let t:txP=a:1
		se sidescroll=1 mouse=a lz noea nosol wiw=1 wmw=0 ve=all
	elseif !exists("t:txP")
		ec "\n> No plane initialized..."
		call TxpPrompt()
		return
	en
	let [col0,win0]=[get(t:txP.ix,bufname(winbufnr(0)),a:0? -1 : -2),winnr()]
	if col0==-2
		ec "> Current buffer not registered in in plane..."
		return
	elseif col0==-1
		let col0=0
		only
		exe 'e' t:txP.name[0] 
	en
	let pos=[bufnr('%'),line('w0')]
	exe winnr()==1? "norm! mt0" : "norm! mt"
	let alignmentcmd="norm! ".pos[1]."zt"
	se scrollopt=jump
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0%t:txP.len,0]
	let remain=split0
	while remain>=1
		let remain-=t:txP.size[colt]+1
		let colt=(colt-1)%len(t:txP.size)
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0%len(t:txP.size),&columns-(split0>0? split0+1+t:txP.size[col0] : min([winwidth(1),t:txP.size[col0]])),1]
	while remain>=2
		let remain-=t:txP.size[colb]+1
		let colb=(colb+1)%len(t:txP.size)
		let colsRight+=1
	endwhile
	let colbw=t:txP.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%len(t:txP.size)
		for i in range(dif)
			let colt=(colt-1)%len(t:txP.size)
			exe 'top vsp '.t:txP.name[colt]
			exe alignmentcmd
			exe t:txP.exe[colt]
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
		let colb=(col0+colsRight-1-dif)%len(t:txP.size)
		for i in range(dif)
			let colb=(colb+1)%len(t:txP.size)
			exe 'bot vsp '.t:txP.name[colb]
			exe alignmentcmd
			exe t:txP.exe[colb]
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
	let [bot,cwin]=[winnr(),0]
	while winnr()!=cwin
		se wfw
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txP.len]
		if expand('%:p')!=#fnamemodify(t:txP.name[ccol],":p")
			exe 'e' t:txP.name[ccol] 
			exe alignmentcmd
			exe t:txP.exe[ccol]
		elseif a:0
			exe alignmentcmd
			exe t:txP.exe[ccol]
		en
		if cwin==1
			let offset=t:txP.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(cwin==bot? colbw : t:txP.size[ccol])-winwidth(cwin)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		wincmd h
	endw
	let &scrollopt=t:txP.scrollopt
	try
		exe "silent norm! :syncbind\<cr>"
	catch
	endtry
   	exe "norm!" bufwinnr(pos[0])."\<c-w>w".pos[1]."zt`t"
endfun

fun! DeleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun

let glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
if !exists('g:opt_device') "for compatibility
	let opt_device=''
en
fun! MousePanWin()
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

fun! MousePanCol()
	let [c,b0]=[100,-1]
	while c!="\<leftrelease>"
		if winbufnr(v:mouse_win)!=b0
			exe "norm! \<leftmouse>"
			let [b0,wrap,ix]=[winbufnr(0),&wrap,get(t:txP.ix,bufname(b0),-1)]
			let [x,y,offset]=wrap? [wincol(),line('w0')+winline(),0] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol()]
			let ecstr=&ls? ' '.v:mouse_lnum.' , '.v:mouse_col : (' '.(t:txP.name[(ix-2)%t:txP.len]).' < '.(t:txP.name[(ix-1)%t:txP.len]).' << '.(t:txP.name[ix]).' >> '.(t:txP.name[(ix+1)%t:txP.len]).' > '.(t:txP.name[(ix+2)%t:txP.len]))[:&columns-2]
		else
			if wrap
				exe "norm! \<leftmouse>"
				let [nx,l0]=[wincol(),y-winline()]
			else
				let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
			en
			let [x,xs]=x && nx? [x,nx>x? -PanLeft(nx-x) : PanRight(x-nx)] : [x? x : nx,0]
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
endfun

fun! PanLeft(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let [extrashift,tcol]=[0,get(t:txP.ix,bufname(winbufnr(1)),-1)]
	if tcol<0
		throw bufname(winbufnr(1))." not contained in current plane: ".string(t:txP.name)
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
		while winwidth(0)>=t:txP.size[tcol]+2
			se nowfw scrollopt=jump
			let nextcol=(tcol-1)%t:txP.len
			exe 'top '.(winwidth(0)-t:txP.size[tcol]-1).'vsp '.t:txP.name[nextcol]
			exe alignmentcmd
			exe t:txP.exe[nextcol]
			wincmd l
			se wfw
			norm! 0
			wincmd t
			let tcol=nextcol
			se wfw scrollopt=ver,jump
			let &scrollopt=t:txP.scrollopt
		endwhile
		let offset=t:txP.size[tcol]-winwidth(0)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	else
		let loff=&wrap? -a:N-extrashift : virtcol('.')-wincol()-a:N-extrashift
		if loff>=0
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
			while loff<=-2
				let tcol=(tcol-1)%t:txP.len
				let loff+=t:txP.size[tcol]+1
			endwhile
			se scrollopt=jump
			exe 'e '.t:txP.name[tcol]
			exe alignmentcmd
			exe t:txP.exe[tcol]
			let &scrollopt=t:txP.scrollopt
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
			if t:txP.size[tcol]-loff<&columns-1
				let spaceremaining=&columns-t:txP.size[tcol]+loff
				let NextCol=(tcol+1)%len(t:txP.name)
				se nowfw scrollopt=jump
				while spaceremaining>=2
					exe 'bot '.(spaceremaining-1).'vsp '.(t:txP.name[NextCol])
					exe alignmentcmd
					exe t:txP.exe[NextCol]
					norm! 0
					let spaceremaining-=t:txP.size[NextCol]+1
					let NextCol=(NextCol+1)%len(t:txP.name)
				endwhile
				let &scrollopt=t:txP.scrollopt
				windo se wfw
			en
		en
	en
	return extrashift
endfun

fun! PanRight(N,...)
	let alignmentcmd="norm! ".(a:0? a:1 : line('w0'))."zt"
	let tcol=get(t:txP.ix,bufname(winbufnr(1)),-1)
	let [bcol,loff,extrashift,N]=[get(t:txP.ix,bufname(winbufnr(winnr('$'))),-1),winwidth(1)==&columns? (&wrap? (t:txP.size[tcol]>&columns? t:txP.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txP.size[tcol]>winwidth(1)? t:txP.size[tcol]-winwidth(1) : 0),0,a:N]
	if tcol<0 || bcol<0
		throw (tcol<0? bufname(winbufnr(1)) : '').(bcol<0? ' '.bufname(winbufnr(winnr('$'))) : '')." not contained in current plane: ".string(t:txP.name)
	elseif N>=&columns
		if winwidth(1)==&columns
			let loff+=&columns
		else
			let loff=winwidth(winnr('$'))
			let bcol=tcol
		en
		if loff>=t:txP.size[tcol]
			let loff=0
			let tcol=(tcol+1)%len(t:txP.name)
		en
		let toshift=N-&columns
		if toshift>=t:txP.size[tcol]-loff+1
			let toshift-=t:txP.size[tcol]-loff+1
			let tcol=(tcol+1)%len(t:txP.name)
			while toshift>=t:txP.size[tcol]+1
				let toshift-=t:txP.size[tcol]+1
				let tcol=(tcol+1)%len(t:txP.name)
			endwhile
			if toshift==t:txP.size[tcol]
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%len(t:txP.name)
				let loff=0
			else
				let loff=toshift
			en
		elseif toshift==t:txP.size[tcol]-loff
			let N+=1
			let extrashift=-1
			let tcol=(tcol+1)%len(t:txP.name)
			let loff=0
		else
			let loff+=toshift	
		en
		se scrollopt=jump
		exe 'e '.t:txP.name[tcol]
		exe alignmentcmd
		exe t:txP.exe[tcol]
		let &scrollopt=t:txP.scrollopt
		only
		exe 'norm! 0'.(loff>0? loff.'zl' : '')
	elseif N>0
		let shifted=0
		while winwidth(1)<=N
			let extrashift=winwidth(1)==N
			wincmd t
			hide
			let shifted+=winwidth(0)+1
			let tcol=(tcol+1)%len(t:txP.name)
			let loff=0
		endw
		let N+=extrashift
		let loff+=N-shifted
	else
		return
	en
	let wf=winwidth(1)-N
	if wf+N!=&columns
		wincmd b
		exe 'vert res+'.N
		wincmd t	
		if winwidth(1)!=wf
			exe 'vert res'.wf
		en
		let offset=t:txP.size[tcol]-winwidth(1)-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		while winwidth(winnr('$'))>=t:txP.size[bcol]+2
			wincmd b
			se nowfw scrollopt=jump
			let nextcol=(bcol+1)%len(t:txP.name)
			exe 'rightb vert '.(winwidth(0)-t:txP.size[bcol]-1).'split '.t:txP.name[nextcol]
			exe alignmentcmd
			exe t:txP.exe[nextcol]
			wincmd h
			se wfw
			wincmd b
			norm! 0
			let bcol=nextcol
			let &scrollopt=t:txP.scrollopt
		endwhile
	elseif &columns-t:txP.size[tcol]+loff>=2
		let bcol=tcol
		let spaceremaining=&columns-t:txP.size[tcol]+loff
		se nowfw scrollopt=jump
		while spaceremaining>=2
			let bcol=(bcol+1)%len(t:txP.name)
			exe 'bot '.(spaceremaining-1).'vsp '.(t:txP.name[bcol])
			exe alignmentcmd
			exe t:txP.exe[bcol]
			norm! 0
			let spaceremaining-=t:txP.size[bcol]+1
		endwhile
		let &scrollopt=t:txP.scrollopt
		windo se wfw
	else
		let offset=loff-virtcol('.')+wincol()
		exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
	en
	return extrashift
endfun
