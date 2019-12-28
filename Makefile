# helper function: recursively find files
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

DESTDIR := $(PWD)/public
SRCDIR  := $(PWD)
SOURCES := $(call rwildcard,$(SRCDIR),*.Rmd)
HTMLS   := $(SOURCES:%.Rmd=%.html)
FILES   := $(SOURCES:%.Rmd=%_files)

TARGETS = $(HTMLS) $(FILES)

all: $(HTMLS)

deps:
	# this should probably handle comments in the file
	R CMD INSTALL --no-docs --no-multiarch `<Rdependencies`

%.html : %.Rmd
	Rscript -e "rmarkdown::render('$<')"

dist: $(HTMLS)
	@mkdir -p $(DESTDIR)
	cp -r -t $(DESTDIR) $(TARGETS)


clean:
	rm -rf $(TARGETS)

.PHONY: clean deps
