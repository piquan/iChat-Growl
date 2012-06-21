OSACOMPILE?= osacompile
OSACOMPILEFLAGS?=

all: Growl.scpt

.SUFFIXES: .scpt .applescript

.applescript.scpt:
	${OSACOMPILE} ${OSACOMPILEFLAGS} -o $@ $?
