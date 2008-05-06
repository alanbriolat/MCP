all: report.tex
	pdflatex -shell-escape $<
	pdflatex -shell-escape $<

wordcount:
	grep -A2000 "\\\begin{document}" report.tex | detex -e array,eqnarray,equation,figure,picture,table,verbatim,nowordcount | wc
