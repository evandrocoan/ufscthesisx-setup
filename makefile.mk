#!/usr/bin/make -f
# https://stackoverflow.com/questions/7123241/makefile-as-an-executable-script-with-shebang
ECHOCMD:=/bin/echo -e
SHELL := /bin/bash

# The main latex file
THESIS_MAIN_FILE := main

# This will be the pdf generated
THESIS_OUTPUT_NAME := thesis

# This is the directory where the temporary files are going to be
CACHE_DIRECTORY := setup/cache
THESIS_MAIN_FILE_PATH := ${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.pdf

# Find all files ending with `main.tex`
LATEX_SOURCE_FILES := $(wildcard *main.tex)

# Create a new variable within all `LATEX_SOURCE_FILES` file names ending with `.pdf`
LATEX_PDF_FILES := ${LATEX_SOURCE_FILES:.tex=.pdf}

# https://stackoverflow.com/questions/24005166/gnu-make-silent-by-default
MAKEFLAGS += --silent

# https://stackoverflow.com/questions/55642491/how-to-check-whether-a-file-exists-outside-a-makefile-rule
FIND_EXEC := $(if $(wildcard /bin/find),,/usr)/bin/find

# https://stackoverflow.com/questions/55662085/how-to-print-text-in-a-makefile-outside-a-target
ifeq (,$(shell tex --version >/dev/null 2>&1 || (echo "Your command failed with $$?")))
	useless := $(shell printf 'Success: latex is installed!\n' 1>&2)
else
	useless := $(error Error: latex was not installed!)
endif

# https://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile
ifeq (,$(shell latexmk --version >/dev/null 2>&1 || (echo "Your command failed with $$?")))
	useless := $(shell printf 'Success: latexmk is installed!\n' 1>&2)
else
	useless := $(shell printf 'Warning: latexmk is not found installed!\n' 1>&2)
endif

# https://stackoverflow.com/questions/55681576/how-to-send-input-on-stdin-to-a-python-script-defined-inside-a-makefile
define NEWLINE


endef

define LATEX_VERSION_CODE
import re, sys;
match = re.search(r"Copyright (\d+)", """$(shell tex --version)""");
if match:
	if int( match.group(1) ) >= 0:
		sys.stdout.write("1");
	else:
		sys.stdout.write(match.group(1));
else:
	sys.stdout.write("0");
endef

# https://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile
ifeq (,$(shell python --version >/dev/null 2>&1 || (echo "Your command failed with $$?")))
	useless := $(shell printf 'Success: python is installed!\n' 1>&2)

	# https://stackoverflow.com/questions/55681576/how-to-send-input-on-stdin-to-a-python-script-defined-inside-a-makefile
	LATEX_VERSION := $(shell echo \
		'$(subst ${NEWLINE},@NEWLINE@,${LATEX_VERSION_CODE})' | \
		sed 's/@NEWLINE@/\n/g' | python -)
else
	useless := $(shell printf 'Warning: python is not found installed!\n' 1>&2)
	LATEX_VERSION := 0
endif

LATEXMK_THESIS := thesis
LATEXMK_VERBOSE := verbose
LATEXMK_REPLACEMENT := latexmk

ifeq (${LATEX_VERSION}, 1)
	useless := $(shell printf 'Success: Your latex version is compatible!\n' 1>&2)
else
	ifneq (${LATEX_VERSION}, 0)
		useless := $(shell printf '\n' 1>&2)
		useless := $(shell printf 'Warning: Your latex installation is Tex Live from %s which is very bugged!\n' "${LATEX_VERSION}" 1>&2)
		useless := $(shell printf '         See more informations about this on: https://tex.stackexchange.com/questions/484878\n' 1>&2)
		useless := $(shell printf '\n' 1>&2)
# 		LATEXMK_THESIS := thesis_disabled
# 		LATEXMK_VERBOSE := verbose_disabled
# 		LATEXMK_REPLACEMENT := thesis verbose
	endif
endif

# https://stackoverflow.com/questions/55642491/how-to-check-whether-a-file-exists-outside-a-makefile-rule
ifneq (,$(wildcard .gitignore))
	GITIGNORE_PATH := .gitignore
else
	GITIGNORE_PATH := ../.gitignore
endif

# Keep updated our copy of the .gitignore
useless := $(shell cp -vr "${GITIGNORE_PATH}" ./setup/)

.PHONY: all help latex thesis verbose clean biber index start_timer biber_hook biber_hook1 \
biber_hook2 pdflatex_hook pdflatex_hook1 pdflatex_hook2 pdflatex_hook3 pdflatex_hook4 pdflatex_hook5

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
##   latexmk    build the main file with pdflatex biber pdflatex pdflatex
##              pdflatex makeindex biber pdflatex
##   thesis     completely build the main file with minimum output logs
##   verbose    completely build the main file with maximum output logs
##   clean      remove all cache directories and generated pdf files
##   veryclean  same as `clean`, but searches for all generated files outside
##              the cache directories.
##

# Print the usage instructions
# https://gist.github.com/prwhite/8168133
help:
	@fgrep -h "##" ${MAKEFILE_LIST} | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


# https://tex.stackexchange.com/questions/91592/where-to-find-official-and-extended-documentation-for-tex-latexs-commandlin
# https://tex.stackexchange.com/questions/52988/avoid-linebreaks-in-latex-console-log-output-or-increase-columns-in-terminal
PDF_LATEX_COMMAND = pdflatex --synctex=1 -halt-on-error -file-line-error
PDF_LATEX_COMMAND += $(if $(shell pdflatex --help | grep time-statistics),--time-statistics,)
PDF_LATEX_COMMAND += $(if $(shell pdflatex --help | grep max-print-line),--max-print-line=10000,)

# MAIN LATEXMK RULE
#
# -pdf tells latexmk to generate PDF directly (instead of DVI).
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
# https://tex.stackexchange.com/questions/258814/what-is-the-difference-between-interaction-nonstopmode-and-halt-on-error
# https://tex.stackexchange.com/questions/25267/what-reasons-if-any-are-there-for-compiling-in-interactive-mode
LATEXMK_COMMAND := latexmk \
	--pdf \
	--output-directory="${CACHE_DIRECTORY}" \
	--aux-directory="${CACHE_DIRECTORY}" \
	--pdflatex="${PDF_LATEX_COMMAND} --interaction=nonstopmode"

LATEX =	${PDF_LATEX_COMMAND} --interaction=batchmode
LATEX += $(if $(shell pdflatex --help | grep aux-directory),-aux-directory="${CACHE_DIRECTORY}",)
LATEX += $(if $(shell pdflatex --help | grep output-directory),-output-directory="${CACHE_DIRECTORY}",)

# Copies the PDF to the current directory
# https://stackoverflow.com/questions/55671541/how-define-a-makefile-condition-and-reuse-it-in-several-build-rules/
define copy_resulting_pdf=
	if [[ -f "${THESIS_MAIN_FILE_PATH}" ]]; \
	then \
		printf 'Coping PDF...\n'; \
		cp "${THESIS_MAIN_FILE_PATH}" "${current_dir}/${THESIS_OUTPUT_NAME}.pdf"; \
	else \
		printf '\nError: The PDF %s was not generated!\n' "${THESIS_MAIN_FILE_PATH}"; \
		exit 1; \
	fi
endef

# Calculate the elapsed seconds and print them to the screen
define print_results =
	. ./setup/scripts/timer_calculator.sh
	showTheElapsedSeconds "${current_dir}"
	printf '%s/main.log:10000000 \n' "${CACHE_DIRECTORY}"
endef

# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
DIRECTORIES_TO_CREATE := $(shell "${FIND_EXEC}" -not -path "./**.git**" -not -path "./pictures**" -type d -not -path "./setup**" -type d)

# https://tex.stackexchange.com/questions/323820/i-cant-write-on-file-foo-aux
# https://stackoverflow.com/questions/11469989/how-can-i-strip-first-x-characters-from-string-using-sed
define setup_envinronment =
	. ./setup/scripts/timer_calculator.sh
	$(eval current_dir := $(shell pwd)) echo ${current_dir} > /dev/null

	printf '\n';
	readarray -td' ' DIRECTORIES_TO_CREATE_ARRAY <<<"${DIRECTORIES_TO_CREATE} "; \
	unset 'DIRECTORIES_TO_CREATE_ARRAY[-1]'; \
	declare -p DIRECTORIES_TO_CREATE_ARRAY; \
	for directory_name in "$${DIRECTORIES_TO_CREATE_ARRAY[@]}"; \
	do \
		full_cache_directory="${CACHE_DIRECTORY}/$${directory_name:2}"; \
		printf 'Creating %s\n' "$${full_cache_directory}"; \
		mkdir -p "$${full_cache_directory}"; \
	done
	printf '\n';
endef


# https://tex.stackexchange.com/questions/98204/index-not-working
index:
	makeindex "${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.idx"


# Run pdflatex, biber, pdflatex
biber: start_timer biber_hook index pdflatex_hook
	${copy_resulting_pdf}
	${print_results}


# https://stackoverflow.com/questions/46135614/how-to-call-makefile-recipe-rule-multiple-times
${LATEXMK_REPLACEMENT}: start_timer pdflatex_hook1 biber_hook1 pdflatex_hook2 pdflatex_hook3 index pdflatex_hook4 biber_hook2 pdflatex_hook5
	${print_results}


start_timer:
	${setup_envinronment}


# Call biber to process the bibliography and does not attempt to show the elapsed time
# https://www.mankier.com/1/biber --debug
biber_hook biber_hook1 biber_hook2:
	printf 'Running biber quietly...\n'
	biber --quiet --input-directory="${CACHE_DIRECTORY}" --output-directory="${CACHE_DIRECTORY}" ${THESIS_MAIN_FILE}.bcf


# https://stackoverflow.com/questions/46135614/how-to-call-makefile-recipe-rule-multiple-times
pdflatex_hook pdflatex_hook1 pdflatex_hook2 pdflatex_hook3 pdflatex_hook4 pdflatex_hook5:
	@${LATEX} ${LATEX_SOURCE_FILES}


# This rule will be called for every latex file and pdf associated
latex: start_timer ${LATEX_PDF_FILES}
	${print_results}


# Dynamically generated recipes for all PDF and latex files
%.pdf: start_timer %.tex
	@${LATEX} $<
	${print_results}


# MAIN LATEXMK RULE
${LATEXMK_THESIS}:
	${setup_envinronment}
	${LATEXMK_COMMAND} --silent ${THESIS_MAIN_FILE}.tex

	${copy_resulting_pdf}
	${print_results}


${LATEXMK_VERBOSE}:
	${setup_envinronment}
	${LATEXMK_COMMAND} ${THESIS_MAIN_FILE}.tex

	${copy_resulting_pdf}
	${print_results}


clean:
	${RM} -rv ${CACHE_DIRECTORY}
	${RM} -v ${THESIS_OUTPUT_NAME}.pdf


# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
DIRECTORIES_TO_CLEAN := $(shell "${FIND_EXEC}" -not -path "./**.git**" -not -path "./pictures**" -type d)

# https://stackoverflow.com/questions/55527923/how-to-stop-makefile-from-expanding-my-shell-output
RAW_GITIGNORE_CONTENTS := $(shell while read -r line; do printf "$$line "; done < "${GITIGNORE_PATH}")
GITIGNORE_CONTENTS := $(shell echo "${RAW_GITIGNORE_CONTENTS}" | sed -E $$'s/[^\#]+\# //g')

# https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
# https://stackoverflow.com/questions/11289551/argument-list-too-long-error-for-rm-cp-mv-commands
# https://stackoverflow.com/questions/55545253/how-to-expand-wildcard-inside-shell-code-block-in-a-makefile
veryclean: veryclean_hidden clean
veryclean_hidden:
	readarray -td' ' GARBAGE_DIRECTORIES <<<"${DIRECTORIES_TO_CLEAN} "; \
	unset 'GARBAGE_DIRECTORIES[-1]'; \
	declare -p GARBAGE_DIRECTORIES; \
	readarray -td' ' GARBAGE_EXTENSIONS <<<"${GITIGNORE_CONTENTS} "; \
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

