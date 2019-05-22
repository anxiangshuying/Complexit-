MdT:MdT.tab.o lex.yy.o
	gcc -o MdT MdT.tab.o lex.yy.o -ll -lm
MdT.tab.o:MdT.tab.c MdT.h
	gcc -c MdT.tab.c
MdT.tab.c:MdT.y
	bison -d MdT.y
lex.yy.o:lex.yy.c MdT.tab.h
	gcc -c lex.yy.c
lex.yy.c:MdT.l
	flex MdT.l

clean:
	rm *.o
	rm *.tab.c
	rm *.tab.h
	rm lex.yy.c

archive:
	tar -zcvf ../MdT.tar.gz MdT.y MdT.l MdT.h MdT_Lisezmoi_utf8.txt div2.quad makefile
