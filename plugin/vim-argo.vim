""
" @section Introduction
" This is a global plugin that makes developing argo workflows a bit easier.
"
" This plugin has two dependencies:
" 1. The Argo CLI: https://github.com/argoproj/argo-workflows/releases
" 2. The vim dispatch plugin: https://github.com/tpope/vim-dispatch
"
" @stylized vim-argo
" @order introduction config commands

""
" @setting g:argo_namespace
" The namespace where argo is deployed. Defaults to 'argo'

let s:namespace = "argo"
if exists("g:argo_namespace")
    let s:namespace = g:argo_namespace
endif

""
" @setting b:argo_namespace
" The namespace where argo is deployed, customized to the current buffer.
" Defaults to 'argo'

if exists("b:argo_namespace")
    let s:namespace = b:argo_namespace
endif

""
" @setting g:argo_executable
" Path to the argo executable. Defaults to 'argo'

let s:argo_bin = "argo"
if exists("g:argo_executable")
    let s:argo_bin = g:argo_executable
endif

""
" @setting b:argo_executable
" Path to the argo executable in the current buffer. Defaults to 'argo'

if exists("b:argo_executable")
    let s:argo_bin = b:argo_executable
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

""
" @section Commands

""
" Lint the argo workflow in the current buffer. This will automatically
" detect what kind of workflow this is (e.g. workflow, workflow template,
" cluster workflow template) and invoke the appropriate linter accordingly.
command! ArgoLint :call s:argoLint()

""
" Submit the current workflow to argo and monitor its progress in a new
" window.
command! ArgoSubmit :call s:argoSubmit()

""
" Replace the current buffer with a new workflow. This accepts an optional
" example workflow [name] listed in argo's example workflows:
" https://github.com/argoproj/argo-workflows/tree/master/examples
" The [name] must not include a file extension.
" If no [name] is provided, it will use the hello-world example workflow.
command! -nargs=? ArgoNewWorkflow call s:argoNewWorkflow(<f-args>)

""
" Inject a basic cluster workflow template in the current buffer at the
" current cursor position. This accepts an optional [name] that will be
" supplied as the cluster workflow template's name.
command! -nargs=? ArgoNewClusterWorkflowTemplate call s:ArgoNewClusterWorkflowTemplate(<f-args>)
