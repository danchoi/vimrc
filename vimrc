let g:mapleader=','
colorscheme desert
set ai et ts=2 sw=2 tw=0 exrc nocursorline hls 
syn off                         " turn off syntax coloring
" for pasting text from clipboard
nmap ,a :r !cat<CR>
" draws a line of dashes
nmap ,- 72i-<ESC>o
" inserts the date
nmap ,_ <ESC>:r !date +\%F<CR>
" autocmd BufNewFile,BufRead *.txt setlocal tw=72 hls
" autocmd BufNewFile,BufRead *.md  setlocal tw=72 hls  

nnoremap ,, gqap
nnoremap ,d :split ~/diary.txt<CR>G


" Easily open hyperlinks in the current text buffer.
" Place cursor before or at the beginning of a URL that
" begins with http: or https: and press <leader>o

let s:http_link_pattern = 'https\?:[^ >)\]]\+'
let g:browser_command = 'open '
func! s:find_href()
  let res = search(s:http_link_pattern, 'cw')
  if res != 0
    let href = matchstr(expand("<cWORD>") , s:http_link_pattern)
    return href
  end
endfunc
func! s:open_href_under_cursor()
  let command = g:browser_command . " '" . shellescape(s:find_href()) . "' "
  call system(command)
endfunc
nnoremap <leader>o :call <SID>open_href_under_cursor()<CR>

" Home-brewed commenter and uncommenter
" :Comment and :Uncomment will comment out a given range of lines 
" or visual selection. 
" Comment marks will be placed at beginning of line, and only comment
" marks at the beginning of lines will be uncommented.
" Comment mark will dynamically determined to be '#', '//' or '--' depending
" on file extension of the file in buffer, and '#' if none can be detected.

func! s:commentMarker() 
  let ext = expand('%:e')
  if ext == 'js'
    return '//'
  elseif ext == 'hs' 
    return '--'
  else
    return '#'
  endif
endfunc
func! s:comment() range
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    let newline = substitute(line, '^', s:commentMarker() . ' ', '')      " comment out
    call setline(lnum, newline)
    let lnum += 1
  endwhile
endfunc
func! s:uncomment() range
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    let newline = substitute(line, '^'.s:commentMarker().'\s\?', '', '')   " uncomment
    call setline(lnum, newline)
    let lnum += 1
  endwhile
endfunc
command! -bar -range Comment :<line1>,<line2>call s:comment()
command! -bar -range Uncomment :<line1>,<line2>call s:uncomment()


" Dan's home-brewed Rails file-finder:
" Type :OP followed by a string fragment, and the app,test,spec,lib,config,db 
" directories will be searched for files that match that string.
" Press TAB or shift-TAB to move through matches, and ENTER to open the file
" shown.

command -complete=custom,FasterOpenFunc -nargs=1 OP call s:faster_open(<f-args>)
func! FasterOpenFunc(A,L,P)
  return system("find app test spec lib config db -name '*".a:A."*' 2>/dev/null | awk -F / '{print $NF \" -> \" $0}'")
endfun
func! s:faster_open(a)
  let path = split(a:a, ' -> ')[1]
  exec "edit ".path
endfunc


abbr uph Unix Philosophy


" Shortcut for finding all matches for keyword under cursor in a Rails project
func! s:vimgrep_shortcut()
  let w = expand("<cword>") 
  exec "vimgrep ".w." app/**/* lib/**/* "
  :cl
endfunc
nnoremap <leader>g :call <SID>vimgrep_shortcut()<CR>


" runs the line on bash and appends output after the line
func! RunBashAppend()
  let cmd=getline('.')
  let res=system(getline('.'))
  normal j
  silent! put! =res
endfunc
nnoremap <leader>b :call RunBashAppend()<CR>

nnoremap <leader>t :set tw=72<CR>
nnoremap <leader>T :set tw=0<CR>

