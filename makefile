SV_FILES = ${wildcard ./src/*.sv}
TB_FILES = ${wildcard ./tb/*.sv}
ALL_FILES = ${SV_FILES} ${TB_FILES}

TOP ?= tb_uart_tx

lint:
	@echo "Running lint checks..."
	verilator --lint-only -Wall --timing -Wno-UNUSED -Wno-CASEINCOMPLETE ${ALL_FILES}

build:
	verilator --binary ${SV_FILES} ./tb/$(TOP).sv --top $(TOP) -j 0 --trace -Wno-CASEINCOMPLETE

run: build
	obj_dir/V$(TOP)

wave: run
	gtkwave --dark dump.vcd

clean:
	@echo "Cleaning temp files..."
	rm dump.vcd
	rm obj_dir/*


.PHONY: compile run wave lint clean help