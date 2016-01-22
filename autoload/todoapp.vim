let s:save_cpo = &cpo
set cpo&vim
let s:file = expand('~').'/.todo/todo.sqlite'

function! todoapp#add(content)
  let time = localtime()
  let cmd = 'sqlite '.s:file.' "INSERT INTO todo (created, modified, status, content)'
        \.' VALUES('.s:values(time, time, s:quote('pending'), s:quote(a:content)).')"'
  let res = s:system(cmd)
  if res != -1 | echo 'done' | endif
endfunction

function! todoapp#init()
  let cmd = 'sqlite '.s:file.' ''CREATE TABLE IF NOT EXISTS'
        \.' todo(id INTEGER PRIMARY KEY AUTOINCREMENT, created INTEGER, modified INTEGER, status, content)'''
  let res = s:system(cmd)
  if res != -1 | echo 'done' | endif
endfunction

function! todoapp#todoLoad(id)
  let cmd = 'sqlite '.s:file.' "SELECT content,status FROM todo where id = '.a:id.' "'
  let output = s:system(cmd)
  if output == -1 | return -1 | endif
  return {'id': a:id,
        \ 'content': substitute(output, '\v\|[^|]{-}$', '', ''),
        \ 'status': matchstr(output, '\v\w*$'),
        \}
endfunction

function! todoapp#read(path)
  let id = matchstr(a:path, '\v\d+$')
  let data = todoapp#todoLoad(id)
  call setline(1, data.content)
  call setbufvar(a:path, 'status', data.status)
  setl nomod nobuflisted bufhidden=wipe
  nnoremap <buffer>q :x!<CR>
endfunction

function! todoapp#save(path)
  let path = empty(a:path) ? expand('%') : a:path
  let id = matchstr(path, '\v\d+$')
  let content = join(getbufline(path, 0, '$'), '\n')
  let cmd = 'sqlite '.s:file.' "UPDATE todo set'
          \.' content='.s:quote(content).', modified='.localtime().' where id = '.id.' "'
  let output = s:system(cmd)
  setl nomod
  if output != -1 | echo 'done' | endif
endfunction

function! s:system(cmd)
  let output = system(a:cmd)
  if v:shell_error && output !=# ""
    echohl Error | echon output | echohl None
    return -1
  endif
  return output
endfunction

function! s:quote(val)
  return "'".escape(a:val, "'\"")."'"
endfunction

function! s:values(...)
  let args = deepcopy(a:000)
  return join(args, ',')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
