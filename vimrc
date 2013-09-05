let g:mapleader=','
set ai et ts=2 sw=2 tw=0 exrc
nmap ,a :r !cat<CR>             " for pasting text from clipboard
nmap ,- 72i-<ESC>o              " draws a line of dashes
nmap ,_ <ESC>:r !date +\%F<CR>  " inserts the date


" Easily open hyperlinks in text editor:
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


func! s:pipeElinks(newTab)
  let command = "elinks -dump " . shellescape(s:find_href()) 
  let content = system(command)
  if a:newTab
    tabnew
    put=content
  else
    " should create a new page
    normal Go
    normal ,-
    let startLine = line('.')
    put=content
    call cursor(startLine, 0)
  endif
  call s:searchForContent()
endfunc

" Prompt user for a link number and then go to References section and
" open it.
func! s:openElinksReferenceNumber(textOnly)
  let a = str2nr(input("Follow link number: "))
  exec "/ ".a."\. "  
  if a:textOnly
    call s:pipeElinks(0)
  else
    call s:open_href_under_cursor()
  endif
endfunc

func! s:searchForContent()
  call search('^...\S.\{68,\}\n...\S.\{68,\}', '')
  normal k
  call feedkeys("z\<cr>")
endfunc

nnoremap <leader>O :call <SID>pipeElinks(0)<CR>
nnoremap <leader>OO :call <SID>pipeElinks(1)<CR>
nnoremap <leader>f :call <SID>openElinksReferenceNumber(0)<CR>
nnoremap <leader>F :call <SID>openElinksReferenceNumber(1)<CR>
nnoremap <leader>c :call <SID>searchForContent()<CR>
nnoremap <leader>d :sp ~/diary.txt<CR>G
autocmd BufNewFile,BufRead *.txt setlocal tw=72 hls
autocmd BufNewFile,BufRead *.md setlocal tw=72 hls  " markdown

func! s:openURL(url)
  let command = "elinks -dump " . shellescape(a:url) 
  let content = system(command)
  " should create a new page
  new!
  setlocal buftype=nofile
  silent put=content
  normal 1G
  call s:searchForContent()
endfunc
command! -bar -nargs=1 OpenURL :call <SID>openURL(<f-args>)<CR>

" open in vim buffer

func! s:comment_out() range
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    if line =~ '^#'
      " uncomment
      let newline = substitute(line, '^#', '', '')
    else
      " comment
      let newline = substitute(line, '^', '#', '')
    endif
    call setline(lnum, newline)
    let lnum += 1
  endwhile
endfunc
command! -bar -range Comment :<line1>,<line2>call s:comment_out()
command! -bar -range Uncomment :<line1>,<line2>call s:comment_out()

" convert test[:key] to test['key']
func! StringKeys() 
  %s/\[:\(\w\+\)\]/['\1']/g
endfunc

" autocmd BufNewFile,BufRead *.rb setlocal tw=0 hls nonu
" autocmd BufNewFile,BufRead *.md setlocal tw=72
" autocmd BufNewFile,BufRead *.markdown setlocal tw=72
" autocmd BufNewFile,BufRead NOTES setlocal tw=72
" autocmd BufNewFile,BufRead *.sh setlocal tw=0 hls nonu
" autocmd BufNewFile,BufRead *.erb setlocal tw=0 hls
" autocmd BufNewFile,BufRead *.txt setlocal tw=72 hls
autocmd BufNewFile,BufRead *.hs set ft=txt, tw=0

set hls
let g:netrw_http_cmd="el"

set nocursorline
set nonu
vmap Q gq
nmap Q gqap
colorscheme desert


command -complete=custom,FasterOpenFunc -nargs=1 OP call s:faster_open(<f-args>)
func! FasterOpenFunc(A,L,P)
  return system("find app test spec lib config db -name '".a:A."*' 2>/dev/null | awk -F / '{print $NF \" -> \" $0}'")
endfun

func! s:faster_open(a)
  let path = split(a:a, ' -> ')[1]
  exec "edit ".path
endfunc

func! s:osxprint() range
  exec a:firstline .",".a:lastline."w! ~/temp-print.txt "
  call system("~/temp.osa")
endfunc

command! -bar -range OSXPrint call s:osxprint()


" abbreviations
func! WrapModeOn()
  :set wrap
  :set linebreak
  :set nolist
  :set textwidth=0
endfunc

func! WrapModeOff()
  :set nowrap
  :set nolinebreak
  :set list
  :set textwidth=72
endfunc

syn off
set nonu
set tw=0




