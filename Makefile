# helper function: recursively find files
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

DESTDIR := $(CURDIR)/public
SRCDIR  := $(CURDIR)
SOURCES := $(call rwildcard,$(SRCDIR),*.Rmd)
HTMLS   := $(patsubst $(CURDIR)/%.Rmd,$(DESTDIR)/%.html,$(SOURCES))

TARGETS = $(HTMLS)

all: $(HTMLS)

deps:
	# Assumes r-cran-devtools is installed
	Rscript -e 'devtools::install_deps(pkg=".", upgrade="never", repos="https://cloud.r-project.org/")'

$(DESTDIR)/%.html : $(CURDIR)/%.Rmd $(DESTDIR)
	Rscript -e "rmarkdown::render('$<', output_dir='$(dir $@)', output_file='index.html')"

$(DESTDIR):
	@mkdir -p $(DESTDIR)

dist: $(HTMLS)

clean:
	rm -rf $(TARGETS)

.PHONY: clean deps
