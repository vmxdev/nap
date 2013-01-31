cc=cc
ld=cc

#cflags=-Wall -O2 -pedantic
#ldflags=-s

#debug
cflags=-Wall -O0 -pedantic -g
ldflags=

objs=nap.o grammar.o lexer.o
libs=
target=nap

all:		$(target)

$(target):	$(objs)
		$(ld) -o $(target) $(ldflags) $(objs) $(libs)

.c.o::
		$(cc) -c $(cflags) $<

lexer.c:	lexer.l nap.h grammar.h
		re2c --case-insensitive -s -b -o lexer.c lexer.l

grammar.c:	grammar.lem nap.h
		lemon -c grammar.lem

grammar.h:	grammar.lem
		lemon -c grammar.lem

-include .depend

.depend:
		$(cc) -MM *.c > .depend
		echo "grammar.o: grammar.c" >> .depend


clean::
		rm -f *\.o
		rm -f $(target)
		rm -f .depend
		rm -f lexer.o lexer.c
		rm -f grammar.out grammar.o grammar.h grammar.c
