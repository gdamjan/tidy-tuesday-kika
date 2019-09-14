# helper function: recursively find files
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

SRCDIR  := $(PWD)
SOURCES := $(call rwildcard,$(SRCDIR),*.Rmd)
HTMLS   := $(SOURCES:%.Rmd=%.html)
FILES   := $(SOURCES:%.Rmd=%_files)

TARGETS = $(HTMLS) $(FILES)

all: $(HTMLS)

deps:
	# this should probably handle comments in the file
	Rscript -e 'install.packages(read.table("Rdependencies")[,1])'

%.html : %.Rmd
	Rscript -e "rmarkdown::render('$<')"


clean:
	rm -rf $(TARGETS)

.PHONY: clean deps
