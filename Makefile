.PHONY: docs
docs:
	rm -rf doc && vimdoc plugin && mv plugin/doc doc && mv doc/plugin.txt doc/vim-argo.txt
