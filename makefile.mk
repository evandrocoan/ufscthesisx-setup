#!/usr/bin/make -f
# https://stackoverflow.com/questions/7123241/makefile-as-an-executable-script-with-shebang
#
#   Copyright 2017-2019 @ Evandro Coan
#   Helper functions and classes
#
#  Redistributions of source code must retain the above
#  copyright notice, this list of conditions and the
#  following disclaimer.
#
#  Redistributions in binary form must reproduce the above
#  copyright notice, this list of conditions and the following
#  disclaimer in the documentation and/or other materials
#  provided with the distribution.
#
#  Neither the name Evandro Coan nor the names of any
#  contributors may be used to endorse or promote products
#  derived from this software without specific prior written
#  permission.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; either version 3 of the License, or ( at
#  your option ) any later version.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
ECHOCMD:=/bin/echo -e
SHELL := /bin/bash

# http://stackoverflow.com/questions/1789594/how-do-i-write-the-cd-command-in-a-makefile
.ONESHELL:

# https://stackoverflow.com/questions/34369500/makefile-match-any-target-task
.PHONY: all

# https://stackoverflow.com/questions/24005166/gnu-make-silent-by-default
MAKEFLAGS += --silent

# https://stackoverflow.com/questions/20582006/force-makefile-to-execute-script-after-building-any-target-just-before-exiting
%:
	. ./setup/scripts/timer_calculator.sh
	$(eval current_dir := $(shell pwd)) echo ${current_dir} > /dev/null

	printf 'Calling setup/makerules.mk %s\n\n' "${@}"
	make -f setup/makerules.mk $@

	showTheElapsedSeconds "${current_dir}";
