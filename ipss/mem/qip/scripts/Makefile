ch   ?= 4
xbar ?= true
hbm  ?= 0:8 1:8

all: hbm qsys

hbm: hbm_ss.tcl
	$(eval hbm_tcl :=)
	@for item in $(hbm); do \
		loc=$${item%%:*}; \
		ch=$${item#*:}; \
		hbm_tcl="$${hbm_tcl}{ {$$loc} {$$ch} } "; \
	done; \
	qsys-script --cmd="set sys_channels { $$hbm_tcl }; set en_xbar $(xbar)" --script=hbm_ss.tcl

qsys: hbm_ss.qsys
	qsys-generate --synthesis=VERILOG -qpf=hbm_ss -c=hbm_ss hbm_ss.qsys

clean:
	rm -fr *qpf *qsf *qsys *qsys.legacy .qsys_edit/ hbm_ss/ ip/ *~ qdb/ dni/ board.info
