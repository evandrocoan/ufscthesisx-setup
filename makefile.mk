#!/usr/bin/make -f
# https://stackoverflow.com/questions/7123241/makefile-as-an-executable-script-with-shebang
ECHOCMD:=/bin/echo -e

# The main latex file
THESIS_MAIN_FILE := main

# This will be the pdf generated
THESIS_OUTPUT_NAME := thesis

# This is the folder where the temporary files are going to be
CACHE_FOLDER := setup/cache

# Find all files ending with `main.tex`
LATEX_SOURCE_FILES := $(wildcard *main.tex)

# Create a new variable within all `LATEX_SOURCE_FILES` file names ending with `.pdf`
LATEX_PDF_FILES := $(LATEX_SOURCE_FILES:.tex=.pdf)

# https://stackoverflow.com/questions/24005166/gnu-make-silent-by-default
MAKEFLAGS += --silent
GITIGNORE_PATH := .gitignore
.PHONY: all help biber start_timer biber_hook pdflatex_hook1 pdflatex_hook2 latex thesis verbose clean

# http://stackoverflow.com/questions/1789594/how-do-i-write-the-cd-command-in-a-makefile
.ONESHELL:

# Default target
all: thesis


##
## Usage:
##   make <target>
##
## Targets:
##   all        call the `thesis` make rule
##   biber      build the main file with bibliography pass
##   latex      build the main file with no bibliography pass
##   thesis     completely build the main file with minimum output logs
##   verbose    completely build the main file with maximum output logs
##   clean      remove all cache folders and generated pdf files
##   veryclean  same as `clean`, but searches for all generated files outside
##              the cache folders.
##

# Print the usage instructions
# https://gist.github.com/prwhite/8168133
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


# https://tex.stackexchange.com/questions/91592/where-to-find-official-and-extended-documentation-for-tex-latexs-commandlin
# https://tex.stackexchange.com/questions/52988/avoid-linebreaks-in-latex-console-log-output-or-increase-columns-in-terminal
PDF_LATEX_COMMAND = pdflatex --time-statistics --synctex=1 -halt-on-error -file-line-error --max-print-line=10000
LATEX =	$(PDF_LATEX_COMMAND)\
--interaction=batchmode\
-output-directory="$(CACHE_FOLDER)"\
-aux-directory="$(CACHE_FOLDER)"


# Copies the PDF to the current folder
define copy_resulting_pdf=
cp $(CACHE_FOLDER)/$(THESIS_MAIN_FILE).pdf $(current_dir)/$(THESIS_OUTPUT_NAME).pdf
cp $(CACHE_FOLDER)/$(THESIS_MAIN_FILE).pdf /cygdrive/D/User/Downloads/$(THESIS_OUTPUT_NAME).pdf
endef

# Calculate the elapsed seconds and print them to the screen
define print_results =
. ./setup/scripts/timer_calculator.sh
showTheElapsedSeconds "$(current_dir)"
echo "$(CACHE_FOLDER)/main.log:10000000 "
endef

define setup_envinronment =
. ./setup/scripts/timer_calculator.sh
$(eval current_dir := $(shell pwd)) echo $(current_dir) > /dev/null
endef

# Run pdflatex, biber, pdflatex
biber: start_timer biber_hook pdflatex_hook2
	$(setup_envinronment)
	$(copy_resulting_pdf)
	$(print_results)


start_timer:
	# Start counting the elapsed seconds to print them to the screen later
	. ./setup/scripts/timer_calculator.sh


# Internally called rule which does not attempt to show the elapsed time
biber_hook:
	$(setup_envinronment)

	# Enters to the thesis folder to build the files
	cd ./$(THESIS_FOLDER)

	# Call biber to process the bibliography
	echo "Running biber quietly..."

	# https://www.mankier.com/1/biber --debug
	biber --quiet --input-directory="$(CACHE_FOLDER)" --output-directory="$(CACHE_FOLDER)" $(THESIS_MAIN_FILE).bcf


# https://stackoverflow.com/questions/46135614/how-to-call-makefile-recipe-rule-multiple-times
pdflatex_hook1 pdflatex_hook2:
	@$(LATEX) $(LATEX_SOURCE_FILES)


# This rule will be called for every latex file and pdf associated
latex: $(LATEX_PDF_FILES)
	$(setup_envinronment)

	# Calculate the elapsed seconds and print them to the screen
	$(print_results)


# Dynamically generated recipes for all PDF and latex files
%.pdf: %.tex
	$(setup_envinronment)

	@$(LATEX) $<
	$(copy_resulting_pdf)


# MAIN LATEXMK RULE
#
# -pdf tells latexmk to generate PDF directly (instead of DVI).
#
# -pdflatex="" tells latexmk to call a specific backend with specific options.
#
# -use-make tells latexmk to call make for generating missing files. When after a run of latex or
# pdflatex, there are warnings about missing files (e.g., as requested by the LaTeX \input,
# \include, and \includgraphics commands), latexmk tries to make them by a custom dependency. If no
# relevant custom dependency with an appropriate source file is found, and if the -use-make option
# is set, then as a last resort latexmk will try to use the make program to try to make the missing
# files.
#
# -interaction=nonstopmode keeps the pdflatex backend from stopping at a missing file reference and
# interactively asking you for an alternative.
#
# https://www.ctan.org/pkg/latexmk
# http://docs.miktex.org/manual/texfeatures.html#auxdirectory
thesis:
	$(setup_envinronment)

	# https://tex.stackexchange.com/questions/258814/what-is-the-difference-between-interaction-nonstopmode-and-halt-on-error
	# https://tex.stackexchange.com/questions/25267/what-reasons-if-any-are-there-for-compiling-in-interactive-mode
	latexmk \
	--pdf \
	--silent \
	--output-directory="$(CACHE_FOLDER)" \
	--aux-directory="$(CACHE_FOLDER)" \
	--pdflatex="$(PDF_LATEX_COMMAND) --interaction=batchmode" \
	$(THESIS_MAIN_FILE).tex

	$(copy_resulting_pdf)
	$(print_results)


verbose:
	$(setup_envinronment)

	# https://tex.stackexchange.com/questions/258814/what-is-the-difference-between-interaction-nonstopmode-and-halt-on-error
	# https://tex.stackexchange.com/questions/25267/what-reasons-if-any-are-there-for-compiling-in-interactive-mode
	latexmk \
	--pdf \
	--output-directory="$(CACHE_FOLDER)" \
	--aux-directory="$(CACHE_FOLDER)" \
	--pdflatex="$(PDF_LATEX_COMMAND) --interaction=nonstopmode" \
	$(THESIS_MAIN_FILE).tex

	$(copy_resulting_pdf)
	$(print_results)


clean:
	$(RM) -rv $(CACHE_FOLDER)
	$(RM) -v $(THESIS_OUTPUT_NAME).pdf


# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
DIRECTORIES_TO_CLEAN := $(shell /bin/find -not -path "./**.git**" -not -path "./pictures**" -type d)

# https://stackoverflow.com/questions/55527923/how-to-stop-makefile-from-expanding-my-shell-output
RAW_GITIGNORE_CONTENTS := $(shell while read -r line; do printf "$$line "; done < "$(GITIGNORE_PATH)")
GITIGNORE_CONTENTS := $(shell echo "$(RAW_GITIGNORE_CONTENTS)" | sed -E $$'s/[^\#]+\# //g')

# https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
# https://stackoverflow.com/questions/11289551/argument-list-too-long-error-for-rm-cp-mv-commands
# https://stackoverflow.com/questions/55545253/how-to-expand-wildcard-inside-shell-code-block-in-a-makefile
veryclean: veryclean_hidden clean
veryclean_hidden:
	readarray -td' ' GARBAGE_DIRECTORIES <<<"$(DIRECTORIES_TO_CLEAN) "; \
	unset 'GARBAGE_DIRECTORIES[-1]'; \
	declare -p GARBAGE_DIRECTORIES; \
	readarray -td' ' GARBAGE_EXTENSIONS <<<"$(GITIGNORE_CONTENTS) "; \
	unset 'GARBAGE_EXTENSIONS[-1]'; \
	declare -p GARBAGE_EXTENSIONS; \
	for filename in "$${GARBAGE_DIRECTORIES[@]}"; \
	do \
		arraylength="$${#GARBAGE_EXTENSIONS[@]}"; \
		printf 'Cleaning %s extensions on %s\n' "$${arraylength}" "$$filename"; \
		for extension in "$${GARBAGE_EXTENSIONS[@]}"; \
		do \
			[[ ! -z "$$filename" ]] || continue; \
			[[ ! -z "$$extension" ]] || continue; \
			full_expression="$${filename}/$${extension}" ;\
			rm -vf $${full_expression}; \
		done; \
	done;

