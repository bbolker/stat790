all: docs/assignments/README.html docs/index.html docs/stat790_bib.html docs/software/README.html docs/honesty.html
## allnotes docs/assignments/midterm-topics.html

## see also: mk_all
allnotes:
	./mkallnotes

## these must come FIRST so we don't trash .md files by moving
## them to docs!
## FIXME: rebuilds html files in docs unnecessarily
docs/%: %
	mkdir -p docs
	mv $< docs

docs/notes/%: notes/%
	mkdir -p docs/notes
	cp $< docs/$<

docs/assignments/%: assignments/%
	mkdir -p docs/assignments
	mv $< docs/$<

docs/software/%: software/%
	mkdir -p docs/software
	mv $< docs/$<

%.html: %.rmd
	Rscript  -e "rmarkdown::render('$<')"

%.slides.html: %.qmd
## @F = file: https://stackoverflow.com/questions/59446839/get-filename-from-in-makefile
	cd notes; quarto render $(<F) --to revealjs -o $(@F)
## mv $(@F) docs/notes


%.html: %.qmd
## @F = file: https://stackoverflow.com/questions/59446839/get-filename-from-in-makefile
	cd notes; quarto render $(<F)

## %.html: %.qmd
## 	quarto render $< --to revealjs

## https://stackoverflow.com/questions/5178828/how-to-replace-all-lines-between-two-points-and-subtitute-it-with-some-text-in-s
## FIXME, sed -r doesn't work on MacOS
## https://stackoverflow.com/questions/42646316/what-does-d-mean-in-shell-script
## @D = directory of traget
%.docx: %.qmd
##	sed -r '/::::: \{#special .spoiler/,/:::::/c\**SPOILER**\n' < $< > $(@D)/tmp.rmd
	cp $< $(@D)/tmp.qmd
	quarto render $(@D)/tmp.qmd --to docx --toc   
	mv $(@D)/tmp.docx $*.docx


%.html: %.md
	Rscript  -e "rmarkdown::render('$<')"

%.pdf: %.rmd
	Rscript -e "rmarkdown::render('$<', output_format = tufte::tufte_handout())" ## , params = list('latex-engine'='xelatex'))"

%.pdf: %.qmd
	quarto render $< --to pdf --toc   

%.pdf: %.tex
	pdflatex $<

%.pdf: %.md
	Rscript -e "rmarkdown::render('$<', output_format = tufte::tufte_handout())"

index.html: index.rmd sched.csv
	Rscript  -e "rmarkdown::render('$<')"

stat790_bib.html: stat790_bib.md stat790.bib
	Rscript  -e "rmarkdown::render('$<')"


