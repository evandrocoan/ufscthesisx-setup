#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

####################### Licensing #######################################################
#
#   Copyright 2019 @ Evandro Coan
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
#########################################################################################
#

import re
import os
import sys
import unittest

try:
    import pushdown
    import debug_tools

except:
    print("Please, install the Python 3 packages `pushdown` and `debug_tools`!")
    print("You can run these commands:")
    print("    pip3 install pushdown")
    print("    pip3 install debug_tools")
    print("")
    exit(1)

from pushdown import Lark
from pushdown import Tree

from debug_tools import getLogger
from debug_tools.utilities import wrap_text

log = getLogger(3)

def main():
    sys.setrecursionlimit(10000)
    # unittest.main()

    current_directory = os.path.dirname( os.path.realpath( __file__ ) )
    parent_directory = os.path.dirname( current_directory )
    parse_all_files( parent_directory )


class BasicUnitTests(unittest.TestCase):

    def test_simplest_valid_input(self):
        results = remove_lang_tag( r"\lang{some}{thing}" )
        self.assertEqual( wrap_text(
        """
        + thing
        """ ), results )

    def test_valid_input_with_nested_langs(self):
        results = remove_lang_tag( r"\lang{some\lang{invalide}{stuff}more}{think\lang{stuff}{invalide}lang}" )
        self.assertEqual( wrap_text(
        r"""
        + think\lang{stuff}{invalide}lang
        """ ), results )

    def test_simplest_invalid_input(self):
        with self.assertRaisesRegex( pushdown.exceptions.UnexpectedToken, "Unexpected token Token" ):
            remove_lang_tag( r"\lang{some{}{thing}" )

    def test_invalid_input_with_nested_langs(self):
        with self.assertRaisesRegex( pushdown.exceptions.UnexpectedToken, "Unexpected token Token" ):
            remove_lang_tag( r"\lang{some\lang{{invalide}{stuff}more}{think\lang{stuff}{invalide}lang}" )

    def test_big_paragraphs(self):
        results = remove_lang_tag( wrap_text( r"""
        \preambulo{\lang%
            {%
                \imprimirtipotrabalho~submitted to the \imprimirprograma~of
                \imprimirinstituicao~for degree acquirement in \imprimirformacao.%
            }{%
                \imprimirtipotrabalho~submetido ao \imprimirprograma~da
                \imprimirinstituicao~para a obtenção do Grau de \imprimirformacao.%
            }%
        }
        """ ) )
        self.assertEqual( wrap_text(
        r"""
        + \preambulo{%
        +         \imprimirtipotrabalho~submetido ao \imprimirprograma~da
        +         \imprimirinstituicao~para a obtenção do Grau de \imprimirformacao.%
        +     %
        + }
        """ ), results )


parser = Lark(r'''
start: THINGS_UP_TO_SLASH lang_token_name do_lang_start | THINGS_UP_TO_LANG_NO_SLASH start | THINGS_UP_TO_NO_SLASH?

lang_token_name: LANG_TOKEN
LANG_TOKEN: "lang"

THINGS_UP_TO_SLASH: /[^\\]*\\/

THINGS_UP_TO_NO_SLASH: /[^\\]+/

THINGS_UP_TO_LANG_NO_SLASH: /[^\\]*\\(?!lang)/

do_lang_start: SPACES? english_open_brace recursive_english english_close_brace SPACES? portuguese_open_brace recursive_porguese portuguese_close_brace start
               | "}" start

english_open_brace: OPEN_BRACE
english_close_brace: CLOSE_BRACE

portuguese_open_brace: OPEN_BRACE
portuguese_close_brace: CLOSE_BRACE

recursive_english: recursive
recursive_porguese: recursive

recursive: ANYTHINGNONE?
            | ANYTHINGNONE? OPEN_BRACE recursive CLOSE_BRACE ANYTHINGNONE?
            | recursive OPEN_BRACE recursive CLOSE_BRACE recursive

SPACES: /\s+/
ANYTHINGNONE: /[^{}]+/

OPEN_BRACE: "{"
CLOSE_BRACE: "}"
''',
parser='lalr', lexer='contextual'
)


def remove_lang_tag(fulltext):
    newtext = fulltext

    # Remove comments because they may have broken \lang{ tags and we are not parsing this
    for match in re.finditer(r"%.*", fulltext):
        size = match.end() - match.start()
        log( 4, 'start', match.start(), 'end', match.end(), 'removing', newtext[match.start():match.end()] )
        newtext = newtext[:match.start()] + " " * size + newtext[match.end():]

    log( 4, 'newtext', newtext)
    tree = parser.parse(newtext)

    # print( tree.pretty() )
    english_open_brace = -1
    portuguese_open_brace = -1

    save_ranges = []
    delete_ranges = []

    def parse_tree(tree, level, children_count):
        level_name = tree.data
        global english_open_brace
        global portuguese_open_brace

        for node in tree.children:

            if isinstance( node, Tree ):
                log( 4, "level: %s, level_name: %-25s children: %s", level, level_name, children_count )
                parse_tree( node, level+1, len( node.children ) )

            else:
                log( 4, "level: %s, level_name: %-25s node: %-8s %s", level, level_name, "`" + str( node ) + "`", node.__class__.__name__ )

                if level_name == 'lang_token_name':
                    english_open_brace = node.pos_in_stream - 1

                if level_name == 'portuguese_open_brace':
                    portuguese_open_brace = node.pos_in_stream + 1

                if level_name == 'english_close_brace':
                    english_close_brace = node.pos_in_stream + 1
                    delete_ranges.append( (english_open_brace, english_close_brace) )
                    log( 2, 'saving delete_ranges', '{:<16}'.format(str(delete_ranges[-1])), '%r' % newtext[english_open_brace:english_close_brace])

                if level_name == 'portuguese_close_brace':
                    portuguese_close_brace = node.pos_in_stream + 1
                    save_ranges.append( (portuguese_open_brace, portuguese_close_brace) )
                    log( 2, 'saving save_ranges', '{:<16}'.format(str(save_ranges[-1])), '%r' % newtext[portuguese_open_brace:portuguese_close_brace])

    parse_tree( tree, 0, len( tree.children ) )

    if save_ranges:
        log.clean(2, "")
        save_ranges = list(reversed(save_ranges))
        delete_ranges = list(reversed(delete_ranges))

        log( 2, 'Saving all Portuguese \\langs...' )
        for index, thing in enumerate(save_ranges):
            start, end = thing
            saved = fulltext[start:end-1]
            log( 2, 'start', start, 'end', end, 'saving', saved )

            start, _ = delete_ranges[index]
            deleted = fulltext[start:end]

            log( 2, 'start', start, 'end', end, 'deleting', fulltext[start:end] )
            fulltext = fulltext[:start] + saved + fulltext[end:]

    # log( 2, 'Remove all English \\langs...' )
    # for first, second in reversed(save_ranges):
    #     log( 2, 'start', first, 'end', second, 'removing', fulltext[first], fulltext[second] )
    #     fulltext = fulltext[:first] + " " + fulltext[first+1:]
    #     fulltext = fulltext[:second] + " " + fulltext[second+1:]

    # for start, end in reversed(delete_ranges):
    #     size = end - start
    #     log( 2, 'start', start, 'end', end, 'removing', fulltext[start:end] )
    #     fulltext = fulltext[:start] + fulltext[end:]

    return fulltext


def parse_all_files(current_directory):
    log( 2, "Packing files on %s" % current_directory )

    for direcory_name, dirs, files in os.walk(current_directory, followlinks=True):

        for filename in files:
            filepath = os.path.join( direcory_name, filename )

            if ".git" in filepath or not filepath.endswith( ".tex" ):
                continue

            with open(filepath, 'rb') as file:
                contents = file.read().decode('utf-8')

            newcontents = remove_lang_tag(contents)
            if newcontents != contents:
                log.clean("")
                log.clean("")
                log.clean("")
                log( 2, 'Processing file', filepath)

                with open(filepath, 'wb') as file:
                    file.write(newcontents.encode())

    log(1, "Done!" )


if __name__ == "__main__":
    main()

