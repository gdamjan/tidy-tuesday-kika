# helper function: recursively find files
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

DESTDIR := $(CURDIR)/public
SRCDIR  := $(CURDIR)
SOURCES := $(call rwildcard,$(SRCDIR),*.Rmd)
HTMLS   := $(SOURCES:%.Rmd=%.html)
FILES   := $(SOURCES:%.Rmd=%_files)

TARGETS = $(HTMLS) $(FILES)

all: $(HTMLS)

deps:
	# Assumes r-cran-devtools is installed
	Rscript -e 'devtools::install_deps(pkg=".", upgrade="never", repos="https://cloud.r-project.org/")'

%.html : %.Rmd
	Rscript -e "rmarkdown::render('$<')"

dist: $(HTMLS)
	@mkdir -p $(DESTDIR)
	cp -r -t $(DESTDIR) $(HTMLS)


clean:
	rm -rf $(TARGETS)

.PHONY: clean deps
