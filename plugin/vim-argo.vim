" Vim global plugin to make developing argo workflows a bit easier

" if exists("g:loaded_argo")
"     finish
" endif

" let g:loaded_argo = 1

let s:namespace = "argo"
if exists("g:argo_namespace")
    s:namespace = g:argo_namespace
endif
if exists("b:argo_namespace")
    s:namespace = b:argo_namespace
endif

let s:argo_bin = "argo"
if exists("g:argo_executable")
    s:argo_bin = g:argo_executable
endif
if exists("b:argo_executable")
    s:argo_bin = b:argo_executable
endif

function s:argoLint()
    let s:path = expand("%:p")
    let s:lines = getbufline(bufnr("%"), 1, "$")
    let s:cmd = ""
    for s:line in s:lines
        if stridx(s:line, "kind: ") >= 0
            if s:line == "kind: ClusterWorkflowTemplate"
                let s:cmd = "cluster-template lint"
            elseif s:line == "kind: WorkflowTemplate"
                let s:cmd = "template lint"
            elseif s:line == "kind: Workflow"
                let s:cmd = "lint"
            endif
            break
        endif
    endfor
    if s:cmd == ""
        echoerr "Not a valid resource. Expected kind to be of type [Workflow, WorkflowTemplate, ClusterWorkflowTemplate]"
    else
        execute "Dispatch -wait=never " . s:argo_bin . " " . s:cmd . " " . s:path . " -n " . s:namespace
    endif
endfunction

function s:argoSubmit()
    let s:path = expand("%:p")
    execute "Start -wait=always " . s:argo_bin . " submit " . s:path . " -n " . s:namespace . " --watch"
endfunction

function s:argoNewWorkflow(...)
    let s:name = "hello-world"
    if a:0 == 1
        let s:name = a:1
    endif
    let s:dir = "/tmp/vim-argo-templates"
    silent execute "!mkdir -p " . s:dir
    let s:path = s:dir . "/" . s:name . ".yaml"
    if !filereadable(s:path)
        let s:url = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/" . s:name . ".yaml"
        echom "Fetching template " . s:url
        silent execute "!curl ". s:url . " -o " . s:path
    endif
    silent execute "%!cat " . s:path
endfunction

function s:ArgoNewClusterWorkflowTemplate(...)
    let s:name = "REPLACE-ME"
    if a:0 == 1
        let s:name = a:1
    endif

    let s:yaml = "
            \apiVersion: argoproj.io/v1alpha1\n
            \kind: ClusterWorkflowTemplate\n
            \metadata:\n
            \  name: " . s:name . "\n
            \spec:\n
            \  entrypoint: main\n
            \  templates:\n
            \    - name: main\n
            \      inputs:\n
            \        parameters:\n
            \          - name: name\n
            \      container:\n
            \        image: alpine:3.6\n
            \        command: [echo, 'hello, {{inputs.parameters.name}}!']"
    call setline('.', split(s:yaml, '\n'))

endfunction


command! ArgoLint :call s:argoLint()
command! ArgoSubmit :call s:argoSubmit()
command! -nargs=? ArgoNewWorkflow call s:argoNewWorkflow(<f-args>)
command! -nargs=? ArgoNewClusterWorkflowTemplate call s:ArgoNewClusterWorkflowTemplate(<f-args>)
