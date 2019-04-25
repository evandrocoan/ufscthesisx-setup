#!/usr/bin/make -f
# https://stackoverflow.com/questions/7123241/makefile-as-an-executable-script-with-shebang
ECHOCMD:=/bin/echo -e
SHELL := /bin/bash

# The main latex file
THESIS_MAIN_FILE := main

# Uncomment this if you have problems or call `make latex debug=1`
# ENABLE_DEBUG_MODE := true
ifdef debug
	ENABLE_DEBUG_MODE := true
endif

# This will be the pdf generated
THESIS_OUTPUT_NAME := main

# This is the directory where the temporary files are going to be
CACHE_DIRECTORY := setup/cache
THESIS_MAIN_FILE_PATH := ${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.pdf

# Find all files ending with `main.tex`
LATEX_SOURCE_FILES := $(wildcard *main.tex)

# Create a new variable within all `LATEX_SOURCE_FILES` file names ending with `.pdf`
LATEX_PDF_FILES := ${LATEX_SOURCE_FILES:.tex=.pdf}

# https://stackoverflow.com/questions/24005166/gnu-make-silent-by-default
ifeq (,${ENABLE_DEBUG_MODE})
	MAKEFLAGS += --silent
endif

# https://stackoverflow.com/questions/55642491/how-to-check-whether-a-file-exists-outside-a-makefile-rule
FIND_EXEC := $(if $(wildcard /bin/find),,/usr)/bin/find

LATEXMK_THESIS := thesis
LATEXMK_VERBOSE := verbose
LATEXMK_REPLACEMENT := latexmk

# https://stackoverflow.com/questions/55642491/how-to-check-whether-a-file-exists-outside-a-makefile-rule
ifneq (,$(wildcard .gitignore))
	GITIGNORE_PATH := .gitignore
else
	GITIGNORE_PATH := ../.gitignore
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

ifneq (,${ENABLE_DEBUG_MODE})
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

	ifeq (${LATEX_VERSION}, 1)
		useless := $(shell printf 'Success: Your latex version is compatible!\n' 1>&2)
	else
		ifneq (${LATEX_VERSION}, 0)
			useless := $(shell printf '\n' 1>&2)
			useless := $(shell printf 'Warning: Your latex installation is Tex Live from %s which is very bugged!\n' "${LATEX_VERSION}" 1>&2)
			useless := $(shell printf '         See more informations about this on: https://tex.stackexchange.com/questions/484878\n' 1>&2)
			useless := $(shell printf '\n' 1>&2)
		endif
	endif
endif

.PHONY: all help latex thesis verbose clean biber index start_timer biber_hook1 \
biber_hook2 pdflatex_hook1 pdflatex_hook2 pdflatex_hook3 pdflatex_hook4 pdflatex_hook5

# http://stackoverflow.com/questions/1789594/how-do-i-write-the-cd-command-in-a-makefile
.ONESHELL:

# Default target
all: thesis

##
## Usage:
##   make <target> [debug=1]
##
## Use debug=1 to run make in debug mode. Use this if something does not work!
## Examples:
##   make debug=1
##   make latex debug=1
##   make thesis debug=1
##
## If you are using Windows Command Prompt `cmd.exe`, you must use this
## command like this:
##  set "debug=1" && make
##  set "debug=1" && make latex
##  set "debug=1" && make thesis
##
## Targets:
##   all        call the `thesis` make rule
##   index      build the main file with index pass
##   biber      build the main file with bibliography pass
##   latex      build the main file with no bibliography pass
##   pdflatex   the same as latex rule, i.e., an alias for it
##   latexmk    build the main file with pdflatex biber pdflatex pdflatex
##              pdflatex makeindex biber pdflatex
##
##   thesis     completely build the main file with minimum output logs
##   verbose    completely build the main file with maximum output logs
##   clean      remove all cache directories and generated pdf files
##   veryclean  same as `clean`, but searches for all generated files outside
##              the cache directories.
##
##   release version=1.1   creates the zip file `1.1.zip` on the root of this
##        project, within all latex required files. This is useful to share or
##        public your thesis source files with others.
##        If you are using Windows Command Prompt `cmd.exe`, you must use this
##        command like this: set "version=1.1" && make release
##
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

ifeq (,${ENABLE_DEBUG_MODE})
	PDF_LATEX_COMMAND +=  --interaction=nonstopmode
endif

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
	--pdflatex="${PDF_LATEX_COMMAND}"

LATEX =	${PDF_LATEX_COMMAND}
LATEX += $(if $(shell pdflatex --help | grep aux-directory),-aux-directory="${CACHE_DIRECTORY}",)
LATEX += $(if $(shell pdflatex --help | grep output-directory),-output-directory="${CACHE_DIRECTORY}",)

ifeq (,${ENABLE_DEBUG_MODE})
	LATEX += --interaction=batchmode
endif

# biber settings
BIBER_FLAGS := --input-directory="${CACHE_DIRECTORY}" --output-directory="${CACHE_DIRECTORY}"

ifeq (,${ENABLE_DEBUG_MODE})
	BIBER_FLAGS += --quiet
endif

# Calculate the elapsed seconds and print them to the screen
define print_results =
	. ./setup/scripts/timer_calculator.sh
	showTheElapsedSeconds "${current_dir}"
	printf '%s/main.log:10000000 \n' "${CACHE_DIRECTORY}"
endef

# Copies the PDF to the current directory
# https://stackoverflow.com/questions/55671541/how-define-a-makefile-condition-and-reuse-it-in-several-build-rules/
define copy_resulting_pdf=
	${print_results}
	if [[ -f "${THESIS_MAIN_FILE_PATH}" ]]; \
	then \
		printf 'Coping PDF...\n'; \
		cp "${THESIS_MAIN_FILE_PATH}" "${current_dir}/${THESIS_OUTPUT_NAME}.pdf"; \
	else \
		printf '\nError: The PDF %s was not generated!\n' "${THESIS_MAIN_FILE_PATH}"; \
		exit 1; \
	fi
endef

# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
# https://tex.stackexchange.com/questions/323820/i-cant-write-on-file-foo-aux
# https://stackoverflow.com/questions/11469989/how-can-i-strip-first-x-characters-from-string-using-sed
define setup_envinronment =
	. ./setup/scripts/timer_calculator.sh
	$(eval current_dir := $(shell pwd)) echo ${current_dir} > /dev/null

	printf '\n';
	readarray -td' ' DIRECTORIES_TO_CREATE <<<"$(shell "${FIND_EXEC}" \
			-not -path "./**.git**" \
			-not -path "./pictures**" -type d \
			-not -path "./setup**" -type d) "; \
	unset 'DIRECTORIES_TO_CREATE[-1]'; \
	declare -p DIRECTORIES_TO_CREATE; \
	for directory_name in "$${DIRECTORIES_TO_CREATE[@]}"; \
	do \
		full_cache_directory="${CACHE_DIRECTORY}/$${directory_name:2}"; \
		printf 'Creating %s\n' "$${full_cache_directory}"; \
		mkdir -p "$${full_cache_directory}"; \
	done
	printf '\n';
endef


# Keep updated our copy of the .gitignore
"${GITIGNORE_PATH}":
# 	printf 'Copying %s file...\n' "${GITIGNORE_PATH}"
	cp -r "${GITIGNORE_PATH}" ./setup/


start_timer: "${GITIGNORE_PATH}"
	${setup_envinronment}


# https://tex.stackexchange.com/questions/98204/index-not-working
index: $(if $(wildcard ${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.idx),,pdflatex_hook1)
	makeindex "${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.idx"
	printf '\n'


# Run pdflatex, biber, pdflatex
biber: start_timer biber_hook1 index pdflatex_hook2
	${copy_resulting_pdf}


# https://stackoverflow.com/questions/46135614/how-to-call-makefile-recipe-rule-multiple-times
${LATEXMK_REPLACEMENT}: start_timer pdflatex_hook1 biber_hook1 pdflatex_hook2 pdflatex_hook3 index pdflatex_hook4 biber_hook2 pdflatex_hook5
	${copy_resulting_pdf}


# Call biber to process the bibliography and does not attempt to show the elapsed time
# https://www.mankier.com/1/biber --debug
# https://stackoverflow.com/questions/35552028/gnu-make-add-a-file-as-a-dependency-only-if-it-doesnt-exist-yet
biber_hook1 biber_hook2: $(if $(wildcard ${CACHE_DIRECTORY}/${THESIS_MAIN_FILE}.bcf),,pdflatex_hook1)
	printf 'Running biber...\n'
	biber ${BIBER_FLAGS} "${THESIS_MAIN_FILE}.bcf"
	printf '\n'


# https://stackoverflow.com/questions/46135614/how-to-call-makefile-recipe-rule-multiple-times
pdflatex_hook1 pdflatex_hook2 pdflatex_hook3 pdflatex_hook4 pdflatex_hook5:
	@${LATEX} ${LATEX_SOURCE_FILES}


# This rule will be called for every latex file and pdf associated
latex pdflatex: start_timer ${LATEX_PDF_FILES}
	${copy_resulting_pdf}


# Dynamically generated recipes for all PDF and latex files
%.pdf: %.tex
	@${LATEX} $<


# MAIN LATEXMK RULE
${LATEXMK_THESIS}:
	${setup_envinronment}
	${LATEXMK_COMMAND} --silent ${THESIS_MAIN_FILE}.tex
	${copy_resulting_pdf}


${LATEXMK_VERBOSE}:
	${setup_envinronment}
	${LATEXMK_COMMAND} ${THESIS_MAIN_FILE}.tex
	${copy_resulting_pdf}


clean:
	${RM} -rv ${CACHE_DIRECTORY}
	${RM} -v ${THESIS_OUTPUT_NAME}.pdf


# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
# https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
# https://stackoverflow.com/questions/11289551/argument-list-too-long-error-for-rm-cp-mv-commands
# https://stackoverflow.com/questions/55527923/how-to-stop-makefile-from-expanding-my-shell-output
# https://stackoverflow.com/questions/55545253/how-to-expand-wildcard-inside-shell-code-block-in-a-makefile
veryclean: veryclean_hidden clean
veryclean_hidden:
	readarray -td' ' DIRECTORIES_TO_CLEAN <<<"$(shell "${FIND_EXEC}" -not -path "./**.git**" -not -path "./pictures**" -type d) "; \
	unset 'DIRECTORIES_TO_CLEAN[-1]'; \
	declare -p DIRECTORIES_TO_CLEAN; \
	readarray -td' ' GITIGNORE_CONTENTS <<<"$(shell echo \
		"$(shell while read -r line; do printf "$$line "; done < "${GITIGNORE_PATH}")" \
		| sed -E $$'s/[^\#]+\# //g' \
		| sed -E 's/\r//g') "; \
	unset 'GITIGNORE_CONTENTS[-1]'; \
	declare -p GITIGNORE_CONTENTS; \
	for filename in "$${DIRECTORIES_TO_CLEAN[@]}"; \
	do \
		arraylength="$${#GITIGNORE_CONTENTS[@]}"; \
		printf 'Cleaning %s extensions on %s\n' "$${arraylength}" "$$filename"; \
		for extension in "$${GITIGNORE_CONTENTS[@]}"; \
		do \
			[[ ! -z "$$filename" ]] || continue; \
			[[ ! -z "$$extension" ]] || continue; \
			full_expression="$${filename}/$${extension}" ;\
			rm -vf $${full_expression}; \
		done; \
	done;


# https://stackoverflow.com/questions/39767904/create-zip-archive-with-multiple-files
# https://stackoverflow.com/questions/47588379/zip-multiple-files-with-multiple-result-in-python
# https://stackoverflow.com/questions/16091904/python-zip-how-to-eliminate-absolute-path-in-zip-archive-if-absolute-paths-for
define RELEASE_CODE
from __future__ import print_function
import os
import zipfile

version = "${version}"
if not version:
	print( "Error: You need pass the release version. For example: make release version=1.1", end="@NEWNEWLINE@" )
	exit(1)

CURRENT_DIRECTORY = os.path.dirname( os.path.realpath( __file__ ) )
print( "Packing files on %s" % CURRENT_DIRECTORY, end="@NEWNEWLINE@" )

file_names = []
initial_file_names = [
	"Makefile",
	"build.bat",
	"fc-portuges.def",
	os.path.join("setup", "makefile.mk"),
	os.path.join("setup", "ufscthesisx.sty"),
	os.path.join("setup", "ufscthesisx.sublime-project"),
	os.path.join("setup", "scripts", "timer_calculator.sh"),
]

for direcory_name, dirs, files in os.walk(CURRENT_DIRECTORY):

	if ".git" in direcory_name:
		continue

	for filename in files:
		filepath = os.path.join( direcory_name, filename )

		if ".git" in filepath or not ( filepath.endswith( ".tex" )
				or filepath.endswith( ".bib" )
				or filepath.endswith( ".pdf" ) ):
			continue

		file_names.append( filepath )

for filename in initial_file_names:
	filepath = os.path.join( CURRENT_DIRECTORY, filename )
	file_names.append( filepath )

zipfilepath = os.path.join( CURRENT_DIRECTORY, version + ".zip" )
zipfileobject = zipfile.ZipFile(zipfilepath, mode="w")
zipfilepathreduced = os.path.dirname( os.path.dirname( zipfilepath ) )

try:
	for filename in file_names:
		relative_filename = filename.replace( zipfilepathreduced, "" )
		print( relative_filename, end="@NEWNEWLINE@" )
		zipfileobject.write( filename, relative_filename, compress_type=zipfile.ZIP_DEFLATED )

except Exception as error:
	print( "", end="@NEWNEWLINE@" )
	print( "An error occurred: %s" % error, end="@NEWNEWLINE@" )
	exit(1)

finally:
	zipfileobject.close()

print( "", end="@NEWNEWLINE@" )
print( "Successfully created the release version on:@NEWNEWLINE@  %s!" % zipfilepath , end="" )
endef

# https://stackoverflow.com/questions/55839773/how-to-get-the-exit-status-and-the-output-of-a-shell-command-before-make-4-2
release:
	printf '%s\n' "$(shell echo \
		'$(subst ${NEWLINE},@NEWLINE@,${RELEASE_CODE})' | \
		sed 's/@NEWLINE@/\n/g' | python - || \
		( printf 'Error: Could not create the zip file!\n'; exit 1 ) )" | sed 's/@NEWNEWLINE@/\n/g'
	exit "${.SHELLSTATUS}"

