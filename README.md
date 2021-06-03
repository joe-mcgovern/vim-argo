# vim-argo

vim-argo is intended to help making the development of [argo workflows](https://argoproj.github.io/argo-workflows/) easier. It provides a few useful commands such as:

* `ArgoLint` to lint workflow that's open in the current buffer.
* `ArgoSubmit` to submit the workflow in the current buffer and monitor its progress
in a new window.
* `ArgoNewWorkflow` to generate a new workflow for you from one of argo's [example workflows](https://github.com/argoproj/argo-workflows/tree/master/examples).
* And more! Run `help vim-argo` for more details

## Installation

Install using your favorite package manager, or use Vim's built-in package support:
```
mkdir -p ~/.vim/pack/joe-mcgovern/start
cd ~/.vim/pack/joe-mcgovern/start
git clone https://github.com/joe-mcgovern/vim-argo.git
vim -u NONE -c "helptags vim-argo/doc" -c q
```

This plugin has two dependencies that must be installed for it to work properly:
1. [Argo CLI](https://github.com/argoproj/argo-workflows/releases)
2. [Vim-dispatch](https://github.com/tpope/vim-dispatch)

# Developing

Install [vimdoc](https://github.com/google/vimdoc) to generate docs. They can 
be generated using `make docs`
