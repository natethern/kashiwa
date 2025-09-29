all: core/libcore.a builtin/libbuiltin.a

core/libcore.a:
	$(MAKE) -C core

builtin/libbuiltin.a:
	$(MAKE) -C builtin

compiler/compile-racket.scm:
	cd compiler
	cat racket-prelude.scm compile.scm cps.scm gen.scm macro.scm utilities.scm > compile-racket.scm
	cd ..

clean:
	$(MAKE) -C core clean
	$(MAKE) -C builtin clean

