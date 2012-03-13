# prefer using trex 
# 		https://github.com/dh83/trex
# 		gem install trex
# 		trex view

PROJECT=paper

INPUT=$(PROJECT).tex
BIBINPUT=$(PROJECT).aux
OUTPUT=$(PROJECT).pdf
SOURCES=local.bib

BUILDER=pdflatex
BIBTEX=bibtex
VIEWER=evince
GARBAGE=aux log out bbl blg

all: $(OUTPUT)

$(OUTPUT): $(INPUT) $(SOURCES)
	$(BUILDER) $(INPUT)
	$(BIBTEX) $(BIBINPUT)
	$(BUILDER) $(INPUT)
	$(BUILDER) $(INPUT)

view: $(OUTPUT)
	$(VIEWER) $^ 2> /dev/null || gnome-open $^ || open $^

clean:
	@for i in $(GARBAGE); do rm -rf *.$$i; done
	@rm -rf $(OUTPUT)
