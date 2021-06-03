# vim-argo

This vim plugin is designed to assist in the development of argo workflows. It
depends on the argo CLI (link).

## Usecases

### Generate a new workflow

Call `:ArgoNewWorkflow` to replace the current buffer with a hello-world workflow
(This could accept an optional parameter that would download the example workflow by name)

### Lint a workflow

Call `:ArgoLint` to lint the workflow in the current file

### Submit a workflow

Call `:ArgoSubmit` to submit the current workflow to argo
(default --watch)


## Configuration

* `argo_namespace`
* `argo_executable`
