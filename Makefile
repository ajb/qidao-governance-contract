.PHONY: test

test:
	forge test --fork-url $(POLYGON_ARCHIVE_RPC_HTTP) --fork-block-number 30977800 -vv
