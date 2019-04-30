%% setup/ufscthesisx.sty
%%
%% Copyright 2017 Evandro Coan
%% Copyright 2012-2016 by abnTeX2 group at https://www.abntex.net.br/
%%
%% This work may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.3
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%   http://www.latex-project.org/lppl.txt
%% and version 1.3 or later is part of all distributions of LaTeX
%% version 2005/12/01 or later.
%%
%% This work has the LPPL maintenance status `maintained'.
%% The Current Maintainer of this work is the Evandro Coan.
%%
%% The last Maintainer of this work was the abnTeX2 team, led
%% by Lauro César Araujo. Further information are available on
%% https://www.abntex.net.br/
%%
%% This work consists of the file `abntex2-ufsc.sty` renamed as follows:
%% Renamed the `abntex2.cls, v-1.9.6 laurocesar` to `setup/ufscthesisx.sty`
%%

% Define versão necessária do LaTeX
\NeedsTeXFormat{LaTeX2e}

% Prove acesso a classe 'ufscthesisx'
\ProvidesClass{setup/ufscthesisx}[2016/11/15 setup/ufscthesisx]

% How can I properly resolve relative paths in `\usepackage`?
% https://tex.stackexchange.com/questions/123999/how-can-i-properly-resolve-relative-paths-in-usepackage
%
% Commenting this allow to use this as a relative package, with no warnings.
% \ProvidesPackage{ufscthesisx}[2017/08/28 v0.0.1 Evandro]


%----------------------------------------------------------------------------------------
%   PACKAGES AND OTHER DOCUMENT CONFIGURATIONS BEFORE LOADING abntex2
%----------------------------------------------------------------------------------------

% For web links and paths with \path{..} and \url{https://www.python.org/downloads/}
% ftp://tug.ctan.org/pub/tex-archive/macros/latex/contrib/hyperref/doc/options.pdf
% https://tex.stackexchange.com/questions/3033/forcing-linebreaks-in-url
% https://tex.stackexchange.com/questions/124049/applying-options-to-already-loaded-package
\PassOptionsToPackage{hyphens}{url}

% Use its macro adjustwidth* to extend tables out of outer text border.
% https://tex.stackexchange.com/questions/366155/how-to-write-a-table-a-little-larger-than-the-paragraphs-with-centered-columns
\PassOptionsToPackage{strict}{changepage}

% Linked footnotes are not supported inside environment `tabularx', because they
% uses the optional argument of \footnotetext
% http://ctan.sharelatex.com/tex-archive/macros/latex/contrib/hyperref/README.pdf
\PassOptionsToPackage{hyperfootnotes=false}{hyperref}

% The class `abntex2` loads the `enumitem` package with options.
% With the package option shortlabels you can use an enumerate-like syntax, where A, a, I, i and 1
% stand for \Alph*, \alph*, \Roman*, \roman* and \arabic*. This is intended mainly as a sort of
% compatibility mode with the enumerate package, and therefore the following special rule applies:
% if the very first option (at any level) is not recognized as a valid key, then it will be
% considered a label with the enumerate-like syntax.
% https://tex.stackexchange.com/questions/119919/no-spacing-between-enumerated-items-with-usepackageenumerate
\PassOptionsToPackage{shortlabels}{enumitem}

% Fixes `pdfTeX warning (ext4): destination with the same identifier (name{figure.1.1}) has been
% already used, duplicate ignored`.
%
% The `abntex2` package loads the `hyperref` package, however there are several packages which are
% required to be loaded after and before `hyperref`.
%
% https://tex.stackexchange.com/questions/1863/which-packages-should-be-loaded-after-hyperref-instead-of-before
% https://tex.stackexchange.com/questions/50846/hyperref-is-loaded-by-the-class-and-i-need-to-load-packages-that-are-supposed-t
% https://tex.stackexchange.com/questions/51094/using-beforepackage-to-load-a-package-before-hyperref-does-not-work
\RequirePackage{scrlfile}
\AfterClass{memoir}
{
    \RequirePackage{float}
}

% The class `abntex2` loads the package `enumitem`, but `paralist` must be loaded before it
% https://tex.stackexchange.com/questions/162799/compilation-error-when-including-enumitem-and-paralist-packages
\AfterClass{memoir}
{
    % How to make horizontal lists?
    % https://tex.stackexchange.com/questions/146306/how-to-make-horizontal-lists
    \RequirePackage{paralist}
}

% https://tex.stackexchange.com/questions/6529/newline-linebreak-in-message
% https://tex.stackexchange.com/questions/383054/biblatex-error-incompatible-backref-package
% https://tex.stackexchange.com/questions/115828/backreferencing-in-classicthesis-package-does-not-work
% https://tex.stackexchange.com/questions/390349/why-my-biblatex-document-is-not-accepting-utf-8-on-the-bibliography
% https://tex.stackexchange.com/questions/55478/how-to-print-out-to-log-without-affecting-anything-else-lua-print-equiv
% https://tex.stackexchange.com/questions/483570/how-to-detect-whether-passoptionstopackage-was-already-called
\ifcsname opt@biblatex.sty\endcsname
    \message{Have options been passed for biblatex? YES!^^J}
\else
    \message{Have options been passed for biblatex? NO!^^J}
    \PassOptionsToPackage{style=abnt,repeatfields=true,backend=biber,backref=true}{biblatex}
\fi

\AfterClass{memoir}
{
    \RequirePackage{biblatex}
}

% Package longtable must be put before hyperref and arydshln, hyperref after arydshln generates an error
% http://ctan.sharelatex.com/tex-archive/macros/latex/contrib/hyperref/README.pdf
\AfterClass{memoir}
{
    \RequirePackage{longtable}
}

% https://tex.stackexchange.com/questions/391993/how-to-silence-memoir-class-warning-against-the-use-of-caption-package
\RequirePackage{silence}
\WarningFilter*{memoir}{You are using the caption package with the memoir class}

% https://tex.stackexchange.com/questions/402676/can-i-silence-a-warning-which-is-coming-from-a-file-like-bigfoot-sty
\WarningFilter*{hyperref}{Option `hyperfootnotes' has already been used}



%
% Repassa todos os parâmetros a classe abntex2,
\DeclareOption*{%
    \PassOptionsToClass{\CurrentOption}{abntex2}%
}

% Now we'll execute any options passed in
\ProcessOptions\relax
\LoadClass{abntex2}

% Custom list throw LaTeX Error: Command \mycustomfiction already defined?
% https://tex.stackexchange.com/questions/388489/custom-list-throw-latex-error-command-mycustomfiction-already-defined
\RequirePackage{morewrites}

% Package csquotes Warning: Load 'inputenc' before 'csquotes'
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

% Package biblatex Warning: 'babel/polyglossia' detected but 'csquotes' missing
% https://tex.stackexchange.com/questions/229638/package-biblatex-warning-babel-polyglossia-detected-but-csquotes-missing
\RequirePackage{csquotes}

% Indent the first section paragraphs
% https://tex.stackexchange.com/questions/39227/no-indent-in-the-first-paragraph-in-a-section
\RequirePackage{indentfirst}

% Is it possible to keep my translation together with original text?
% https://tex.stackexchange.com/questions/5076/is-it-possible-to-keep-my-translation-together-with-original-text
\RequirePackage{comment}

% Please tutor the usage of patchcmd and xpatch
% https://tex.stackexchange.com/questions/152773/please-tutor-the-usage-of-patchcmd-and-xpatch
\RequirePackage{xpatch}

% Why the environment ttfamily is hyphenated, but macro ttfamily is not hyphenating?
% https://tex.stackexchange.com/questions/387678/why-the-environment-ttfamily-is-hyphenated-but-macro-ttfamily-is-not-hyphenatin
\RequirePackage{letltxmacro}

% Theorem packages: which to use, which conflict?
% https://tex.stackexchange.com/questions/5599/theorem-packages-which-to-use-which-conflict
\RequirePackage{amsthm}

% Why is the ifthen package obsolete? (It is used by the abntex2 class)
% https://tex.stackexchange.com/questions/13866/why-is-the-ifthen-package-obsolete
\RequirePackage{ifthen}

% How to make section name uppercase in ToC?
% https://tex.stackexchange.com/questions/156916/how-to-make-section-name-uppercase-in-toc
\RequirePackage{textcase}

% The class memoir already provides these functionalities: Caption package and Memoir
% https://groups.google.com/forum/#!topic/comp.text.tex/RzpI2ATMev0
% https://tex.stackexchange.com/questions/18931/memoir-class-with-subcaption-and-hyperref-packages
% \RequirePackage{caption}
% \RequirePackage{subfig}
% \RequirePackage{etoolbox}

% The package `layouts` causes the: Warning: layout scale set to 0.5 on input line
% https://tex.stackexchange.com/questions/299372/warning-layout-scale-set-to-0-5-on-input-line
% \RequirePackage{layouts}

% Always use it as should improve full justification
% https://tex.stackexchange.com/questions/10377/texttt-overfull-hbox-problem
% https://tex.stackexchange.com/questions/66052/should-i-load-microtype-with-pdflatex
\RequirePackage{microtype}

% https://tex.stackexchange.com/questions/482886/how-to-add-babel-captions-to-newfloat-package-environments
\RequirePackage{newfloat}

% How to auto adjust my last table column width, and why is there Underfull \vbox badness on this table?
% https://tex.stackexchange.com/questions/387238/how-to-auto-adjust-my-last-table-column-width-and-why-is-there-underfull-vbox/387251
%
% Why ltablex package breaks the changepage package?
% https://tex.stackexchange.com/questions/404339/why-ltablex-package-breaks-the-changepage-package
\RequirePackage{ltablex}\keepXColumns


% CONFIGURAÇÕES DE PACOTES
\newcommand{\ifnotempty}[2]{\ifthenelse{\not\equal{#1}{}}{#2}{}}
\newcommand{\ifnotdefined}[3]{\ifdefined #1 #3 \else #2 \fi}

% Comandos de dados - programa
\providecommand{\imprimirprograma}{}
\newcommand{\programa}[1]{\renewcommand{\imprimirprograma}{#1}}

\providecommand{\imprimirformacao}{}
\newcommand{\formacao}[1]{\renewcommand{\imprimirformacao}{#1}}

\providecommand{\imprimirarea}{}
\newcommand{\area}[1]{\renewcommand{\imprimirarea}{#1}}

\providecommand{\imprimirbiblioteca}{}
\newcommand{\biblioteca}[1]{\renewcommand{\imprimirbiblioteca}{#1}}

\providecommand{\imprimirinstituicaosigla}{}
\newcommand{\instituicaosigla}[1]{\renewcommand{\imprimirinstituicaosigla}{#1}}

\providecommand{\imprimirano}{}
\newcommand{\ano}[1]{\renewcommand{\imprimirano}{#1}}

% Comandos de dados - Coordenador
\newcommand{\coordenadorname}{Coordenador}
\providecommand{\imprimircoordenadorRotulo}{}
\providecommand{\imprimircoordenador}{}
\newcommand{\coordenador}[2][\coordenadorname]%
  {\renewcommand{\imprimircoordenadorRotulo}{#1}%
   \renewcommand{\imprimircoordenador}{#2}}

% inclui subtitulo na capa, folha de rosto e ficha catalografica
% https://github.com/lrsantos11/abntex2-ufsc/commit/fd30245353dcc49e193d281c78104afe54df9fe7
%
% Cria o comando \subtitulo. A norma define que o TITULO deve ser em caixa alta
% negrito, mas o subtitulo deve ser em caixa baixa.
\providecommand{\imprimirsubtitulo}{}
\newcommand{\subtitulo}[1]{\renewcommand{\imprimirsubtitulo}{#1}}

\newcounter{ufscthesisx@assuntos}
\providecommand{\listaassuntos}{}
\providecommand{\imprimirassuntos}
{%
    \setcounter{ufscthesisx@assuntos}{1}
    \@for\assunto:={\listaassuntos}\do
    {%
        \arabic{ufscthesisx@assuntos}.\assunto. %
        \addtocounter{ufscthesisx@assuntos}{1}
    }
}
\newcommand{\assuntos}[1]{\renewcommand{\listaassuntos}{#1}}

\providecommand{\imprimircentro}{}
\newcommand{\centro}[1]{\renewcommand{\imprimircentro}{#1}}


\newtheorem{axioma}{Axioma}[chapter]
\newtheorem{postulado}{Postulado}[chapter]
\newtheorem{teorema}{Teorema}[chapter]
\newtheorem{conjectura}{Conjectura}[chapter]
\newtheorem{corolario}[teorema]{Corol\'ario}
\newtheorem{lema}[teorema]{Lema}
\newtheorem{proposicao}[teorema]{Proposi\c{c}\~ao}


% Commonly used in definitions, conditions, problems and examples.
\theoremstyle{definition}
\newtheorem{definicao}{Defini\c{c}\~ao}[chapter]
\newtheorem{exemplo}{Exemplo}[section]
\newtheorem{exercicio}{Exerc\'icio}[section]
\newtheorem{condicao}{Condi\c{c}\~ao}[chapter]


\theoremstyle{remark}
\newtheorem{observacao}{Observa\c{c}\~ao}

\renewcommand{\qedsymbol}{$\blacksquare$}



% Margens
\setlrmarginsandblock{2.5cm}{1.5cm}{*}
\setulmarginsandblock{2cm}{1.5cm}{*}
\checkandfixthelayout

% Fontes dos títulos e seções
% Tamanho da fonte padrão do 'ABNTEX'
\renewcommand{\normalsize}{\fontsize{10.5pt}{11pt}}

% Caption package and Memoir
% https://groups.google.com/forum/#!topic/comp.text.tex/RzpI2ATMev0
% https://tex.stackexchange.com/questions/18931/memoir-class-with-subcaption-and-hyperref-packages
% \DeclareCaptionFont{small}{\fontsize{9.5pt}{10.5pt}}

% Set caption font size in memoir
% https://tex.stackexchange.com/questions/58943/set-caption-font-size-in-memoir
\newcommand{\ufsccaptionsize}{\fontsize{9.5pt}{10.5pt}\selectfont}
\captionnamefont{\ufsccaptionsize}
\captiontitlefont{\ufsccaptionsize}

% Set the UFSC epigrafe font size
%
% Changing font size in an example environment
% https://tex.stackexchange.com/questions/123528/changing-font-size-in-an-example-environment
\expandafter\def\expandafter\epigrafe\expandafter{\epigrafe\ufsccaptionsize}

% Fonte padrão utilizada no texto
% http://tug.org/fonts/
%
% The three default family font variables and the \familydefault variable should not be confused with their respective switch:
% http://www.forkosh.com/pstex/latexcommands.htm
%
% variable value activated by
\renewcommand{\familydefault}{cmr}

%\encodingdefault   OT1 \normalfont, \textnormal{}
%\familydefault \rmdefault  \normalfont, \textnormal{}
%\rmdefault cmr \rmfamily, \textrm{}
%\ttdefault cmtt    \ttfamily, \texttt{}
%\sfdefault cmss    \sffamily, \textsf{}
%\seriesdefault m   \normalfont, \textnormal{}
%\mddefault m   \mdseries, \textmd{}
%\bfdefault bx  \bfseries, \textbf{}
%\shapedefault  n   \normalfont, \textnormal{}
%\updefault n   \upshape, \textup{}
%\itdefault it  \itshape, \textit{}
%\scdefault sc  \scshape, \textsc{}
%\sldefault sl  \slshape, \textsl{}


% Selects a roman (i.e., serifed) font family
\renewcommand{\rmdefault}{cmr}

% Fontes padroes de part, chapter, section, subsection e subsubsection
\renewcommand{\ABNTEXchapterfont}{\usefont{T1}{cmr}{bx}{n}}
\renewcommand{\ABNTEXchapterfontsize}{\fontsize{10.5pt}{12pt}}

\renewcommand{\ABNTEXpartfont}{\usefont{T1}{cmr}{bx}{n}}
\renewcommand{\ABNTEXpartfontsize}{\fontsize{15pt}{18pt}}

\renewcommand{\ABNTEXsectionfont}{\usefont{T1}{cmr}{m}{n}}
\renewcommand{\ABNTEXsectionfontsize}{\fontsize{10.5pt}{12pt}}

\renewcommand{\ABNTEXsubsectionfont}{\usefont{T1}{cmr}{b}{n}}
\renewcommand{\ABNTEXsubsectionfontsize}{\fontsize{10.5pt}{12pt}}

\renewcommand{\ABNTEXsubsubsectionfont}{\usefont{T1}{cmr}{m}{n}}
\renewcommand{\ABNTEXsubsubsectionfontsize}{\fontsize{10.5pt}{12pt}}

\renewcommand{\ABNTEXsubsubsubsectionfont}{\usefont{T1}{cmr}{m}{it}}
\renewcommand{\ABNTEXsubsubsubsectionfontsize}{\fontsize{10.5pt}{12pt}}


% Comando que simula a finalizacao de uma parte no bookmark e
% adiciona espaco de \part no sumario
\renewcommand{\phantompart}
{%
    \bookmarksetup{startatroot}%
    \phantomsection%
    \addtocontents{toc}{\vspace{0em}}
}

% TOC Spacing in Memoir
% https://tex.stackexchange.com/questions/60317/toc-spacing-in-memoir
\setlength{\cftbeforechapterskip}{12pt}


% Fontes das entradas do sumario
%
% How to make the table of contents section title upper case without messing with the space between the chapter and section?
% https://tex.stackexchange.com/questions/399828/how-to-make-the-table-of-contents-section-title-upper-case-without-messing-with
%
% How to make section name uppercase in ToC?
% https://tex.stackexchange.com/questions/156916/how-to-make-section-name-uppercase-in-toc
\let\oldcontentsline\contentsline
\def\contentsline#1#2{%
  \expandafter\ifx\csname l@#1\endcsname\l@section
    \expandafter\@firstoftwo
  \else
    \expandafter\@secondoftwo
  \fi
  {%
    \oldcontentsline{#1}{\MakeTextUppercase{#2}}%
  }{%
    \oldcontentsline{#1}{#2}%
  }%
}


% No caso de Sumario (TOC) UFSC
%
% Memoir has another mechanism for the job: \cftsetindents{‹kind›}{indent}{numwidth}. Here kind is
% chapter, section, or whatever; the indent specifies the ‘margin’ before the entry starts; and the
% width is of the box into which the number is typeset (so needs to be wide enough for the largest
% number, with the necessary spacing to separate it from what comes after it in the line.
% http://www.tex.ac.uk/FAQ-tocloftwrong.html
%
% memoir: indentation of unnumbered sections in table of contents
% https://tex.stackexchange.com/questions/264668/memoir-indentation-of-unnumbered-sections-in-table-of-contents
%
% Memoir ToC: indent the second line by number+space width in the previous line OR set standard
% https://tex.stackexchange.com/questions/394227/memoir-toc-indent-the-second-line-by-numberspace

% `\cftlastnumwidth` and these `\cftsetindents` are defined by the abntex2 class,
% obeying the `ABNTEXsumario-abnt-6027-2012`. \newlength{\cftlastnumwidth}
\setlength{\cftlastnumwidth}{\cftsubsubsectionnumwidth}
\addtolength{\cftlastnumwidth}{1em}

% http://www.tex.ac.uk/FAQ-tocloftwrong.html
% Use \setlength\cftsectionnumwidth{4em} to override all these values
\cftsetindents{part}         {0em}{\cftlastnumwidth}
\cftsetindents{chapter}      {0em}{\cftlastnumwidth}
\cftsetindents{section}      {0em}{\cftlastnumwidth}
\cftsetindents{subsection}   {0em}{\cftlastnumwidth}
\cftsetindents{subsubsection}{0em}{\cftlastnumwidth}
\cftsetindents{paragraph}    {0em}{\cftlastnumwidth}
\cftsetindents{subparagraph} {0em}{\cftlastnumwidth}

\newlength{\cftnumberboxnumberwidth}
\setlength{\cftnumberboxnumberwidth}{2em}
\renewcommand{\tocprintchapter}
{%
    \addtocontents{toc}{\cftsetindents{chapter}{0em}{\cftlastnumwidth}}
}
%
\renewcommand{\tocinnonumchapter}
{%
    \addtocontents{toc}{\cftsetindents{chapter}{\cftlastnumwidth}{\cftnumberboxnumberwidth}}%
    \cftinserthook{toc}{A}
}
\renewcommand{\tocprintchapternonum}
{%
    \addtocontents{toc}{\cftsetindents{chapter}{\cftlastnumwidth}{\cftnumberboxnumberwidth}}
}
%
\renewcommand{\tocpartapendices}
{%
    \addtocontents{toc}{\cftsetindents{chapter}{\cftlastnumwidth}{\cftnumberboxnumberwidth}}
    \cftinserthook{toc}{A}
}
%
\renewcommand{\tocpartanexos}
{%
    \addtocontents{toc}{\cftsetindents{chapter}{\cftlastnumwidth}{\cftnumberboxnumberwidth}}
    \cftinserthook{toc}{A}
}

\renewcommand{\cftpartfont}{\ABNTEXpartfont}
\renewcommand{\cftpartpagefont}{\cftpartfont}

\renewcommand{\cftchapterfont}{\ABNTEXchapterfont}
\renewcommand{\cftchapterpagefont}{\cftchapterfont}

\renewcommand{\cftsectionfont}{\ABNTEXsectionfont}
\renewcommand{\cftsectionpagefont}{\cftsectionfont}

\renewcommand{\cftsubsectionfont}{\ABNTEXsubsectionfont}
\renewcommand{\cftsubsectionpagefont}{\cftsubsectionfont}

\renewcommand{\cftsubsubsectionfont}{\ABNTEXsubsubsectionfont}
\renewcommand{\cftsubsubsectionpagefont}{\cftsubsubsectionfont}

\renewcommand{\cftparagraphfont}{\ABNTEXsubsubsubsectionfont}
\renewcommand{\cftparagraphpagefont}{\cftparagraphfont}

% Ajusta entrada Referencias
\renewcommand{\bibsection}
{%
    \chapter*{\bibname}
    \bibmark
    \ifnobibintoc\else
    \phantomsection
    \addcontentsline{toc}{chapter}{\uppercase{\bibname}}
    \fi
    \prebibhook
}


% Caption package and Memoir
% https://groups.google.com/forum/#!topic/comp.text.tex/RzpI2ATMev0
% https://tex.stackexchange.com/questions/18931/memoir-class-with-subcaption-and-hyperref-packages
%
% \captionsetup[table]{
%   %  name=Tabela,
%   %  listformat=empty,
%   %  justification=justified,
%   %  labelsep=colon,
%   %   position=above,
%   %   skip=\onelineskip,
%   %  width=\linewidth,
%   labelfont={normalsize},
%   textfont={small},
%   font={normalsize}
% }

% Caption package and Memoir
% https://groups.google.com/forum/#!topic/comp.text.tex/RzpI2ATMev0
% https://tex.stackexchange.com/questions/18931/memoir-class-with-subcaption-and-hyperref-packages
%
% \captionsetup[figure]{
%   %  name=Tabela,
%   %  listformat=empty,
%   %  justification=justified,
%   %  labelsep=colon,
%   %   position=above,
%   %   skip=\onelineskip,
%   %  width=\linewidth,
%   labelfont={normalsize},
%   textfont={small},
%   font={normalsize}
% }


% Espaçamento depois do título
\setlength{\afterchapskip}{0.38cm}

% Controle do espaçamento entre um parágrafo e outro. Tente também \onelineskip
\setlength{\parskip}{0.0cm}

% O tamanho do parágrafo é dado por
\setlength{\parindent}{1.0cm}

% Comando para inverter sobrenome e nome
\newcommand{\ufscthesisx@inverter}[1]
{%
    \StrBehind{#1}{{}},
    \StrBefore{#1}{{}}
}

% Comandos auxiliares
\newcommand{\showfont}
{%
    (\foreignlanguage{english}
    {%
        encoding: \f@encoding{},
        family: \f@family{},
        series: \f@series{},
        shape: \f@shape{},
        size: \f@size{},
        baseline: \f@baselineskip{}
    })
}

% Comandos auxiliares
\newcommand{\justshowfont}
{%
    (\foreignlanguage{english}
    {%
        \f@encoding{},
        \f@family{},
        \f@series{},
        \f@shape{},
        \f@size{},
        \f@baselineskip{}
    })
}

%Numeração dos floats por capítulo
\counterwithin{figure}{chapter}
\counterwithin{table}{chapter}


% Macros for Cross-reference
\newcommand{\figref}[1]{Figura~\ref{#1}}   % Cross-reference of figures
\newcommand{\tabref}[1]{Tabela~\ref{#1}}    % Cross-reference of tables
\newcommand{\eqnref}[1]{\eqref{#1}}      % Cross-reference of equations
\newcommand{\secref}[1]{Seção~\ref{#1}}  % Cross-reference of equations
\newcommand{\defref}[1]{Definição~\ref{#1}} %


\renewenvironment{resumo}[1][\resumoname]
{%
    % Fixed double bookmark entries as `\pretextualchapter` bellow is already calling `\PRIVATEbookmarkthis`
    % \PRIVATEbookmarkthis{#1}
    % \renewcommand{\abstractnamefont}{\chaptitlefont}
    % \renewcommand{\abstractname}{\ABNTEXchapterupperifneeded{#1}}
    \pretextualchapter{#1}
}
{%
    \PRIVATEclearpageifneeded
}

% Fix the resumo environment, which does not accept paragraphs on ufscthesisx
%
% Changing font size in an example environment
% https://tex.stackexchange.com/questions/123528/changing-font-size-in-an-example-environment
%
% How to disable automatic indentation on new paragraphs?
% https://tex.stackexchange.com/questions/14375/how-to-disable-automatic-indentation-on-new-paragraphs
%
% How to disable paragraphs inside my environment with \let\par\relax?
% https://tex.stackexchange.com/questions/388369/how-to-disable-paragraphs-inside-my-environment-with-let-par-relax
\xapptocmd{\resumo}{\setlength{\parindent}{0pt}\let\parOriginal\par\let\par\relax}{}{}
\xpretocmd{\endresumo}{\endgraf}{}{}

% \imprimirpalavraschave{Palavras-chaves}{latex. abntex. editoração de texto.}
\makeatletter
\newcommand{\imprimirpalavraschave}[2]{%
    \@ifundefined{parOriginal}{}{\parOriginal}\vspace{\onelineskip}\textbf{#1}: #2
}
\makeatother

% Create a list of things like (\usepackage{paralist})
%   \palavraschaveufsc{englishkeywordslist}{keyword 1}
%   \palavraschaveufsc{englishkeywordslist}{keyword 2}
%   \begin{inparaitem}[]\englishkeywordslist\end{inparaitem}
%   \begin{inparaenum}\englishkeywordslist\end{inparaenum}
%
% https://tex.stackexchange.com/questions/61811/how-to-define-inparaenum-in-the-preamble
% https://tex.stackexchange.com/questions/468862/lonely-item-perhaps-a-missing-list-environment-missing-package
% https://tex.stackexchange.com/questions/188476/how-do-you-define-one-macro-with-arguments-inside-another
% https://tex.stackexchange.com/questions/191266/defining-macros-with-arguments
% https://tex.stackexchange.com/questions/65780/macro-defining-macro
% https://tex.stackexchange.com/questions/20456/removing-a-backslash-when-passing-arguments-to-newcommand
\makeatletter
\newcommand{\palavraschaveufsc}[2]{%
    \@ifundefined{#1}{%
        \message{palavraschaveufsc #1 is undefined}
        \expandafter\newcommand\csname#1\endcsname{}
    }{%
        \message{palavraschaveufsc #1 is defined}
    }
    {\expandafter\g@addto@macro\csname#1\endcsname{\item #2. }}
}
\makeatother

% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% Configura layout
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
%% criar um novo estilo incluindo logos da UFSC
% ------------------------------------------------------------------------

% Configura layout para elementos textuais, redefining the ABNT command `\textual`.
% Delete his to restore the ABNT default behavior.
\renewcommand{\textual}
{%
    % Estilo original do Abntex2
    \pagestyle{abntheadings}

    % Remove a numeração das páginas no início dos capítulos.
    % ABNT default value `{chapter}{abntchapfirst}`
    \aliaspagestyle{chapter}{empty}

    \nouppercaseheads
    \bookmarksetup{startatroot}
}


% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% Comandos e ambientes de editoracao APENDICES e ANEXOS
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% ---
% Imprime uma pagina de divisao no estilo parte
\renewcommand{\partpage}
{%
    % \phantomsection
    % \addcontentsline{toc}{part}{\appendixtocname}
    \appendixpage*
}


% ---
% Impressão da Capa
\renewcommand{\imprimircapa}
{%
    \begin{capa}%

        \center
        {%
            \ABNTEXchapterfont\ufsccaptionsize\MakeTextUppercase{\imprimirinstituicao}
            \par\MakeTextUppercase{\imprimirautor}
        }


        \vfill
        {%
        \center
            {\ABNTEXchapterfont\MakeUppercase{\imprimirtitulo}}
            \ifnotempty{\imprimirsubtitulo}{{\ABNTEXchapterfont\!:} \par \imprimirsubtitulo}
        }
        \vfill

        {%
            \ufsccaptionsize
            \imprimirlocal

            \imprimirano
        }
        \vspace*{1cm}

    \end{capa}
}
% ---


% Conteúdo padrao da Folha de Rosto
%
% Underfull \hbox (badness 10000) message
% https://tex.stackexchange.com/questions/199635/underfull-hbox-badness-10000-message
%
% Underfull \hbox (badness …) in paragraph at lines x-y
% https://tex.stackexchange.com/questions/356110/underfull-hbox-badness-in-paragraph-at-lines-x-y
%
% How to add an empty line between paragraphs?
% https://tex.stackexchange.com/questions/135134/how-to-add-an-empty-line-between-paragraphs
\makeatletter
\renewcommand{\folhaderostocontent}
{%
    \begin{center}
        {\ABNTEXchapterfont\ufsccaptionsize\imprimirautor}

        \vspace*{\fill}\vspace*{\fill}
        \begin{center}

            {\ABNTEXchapterfont\MakeUppercase{\imprimirtitulo}}
            \abntex@ifnotempty{\imprimirsubtitulo}{{\ABNTEXchapterfont\!:} \\ \imprimirsubtitulo}

        \end{center}
        \vspace*{\fill}

        \abntex@ifnotempty{\imprimirpreambulo}
        {%
            \hspace{.45\textwidth}
            \begin{minipage}{5,5cm}

                \SingleSpacing
                {\ufsccaptionsize\imprimirpreambulo}
                \bigskip

                {
                    \ufsccaptionsize\textbf{\imprimirorientadorRotulo:}~\imprimirorientador\par
                    \abntex@ifnotempty{\imprimircoorientador}
                    {
                        {\textbf{\imprimircoorientadorRotulo:}~\imprimircoorientador}%
                    }
                }

            \end{minipage}
            \vspace*{\fill}
        }

        \vspace*{\fill}

        {%
            \ufsccaptionsize
            \imprimirlocal

            \imprimirano
        }

    \end{center}
}
\makeatother

% If document class is equal to something then do not use package
% https://tex.stackexchange.com/questions/46223/if-document-class-is-equal-to-something-then-do-not-use-package
\makeatletter
\@ifclassloaded{abntex2}
{
    % Package hyperref Warning: Token not allowed in a PDF string?
    % https://tex.stackexchange.com/questions/384885/package-hyperref-warning-token-not-allowed-in-a-pdf-string
    \pdfstringdefDisableCommands{\let\uppercase\relax}
}{}
\makeatother


% https://tex.stackexchange.com/questions/329631/creating-new-captions-and-caption-counters
\def\listofquadrosname{List of Frames}
\DeclareFloatingEnvironment[fileext=loq,placement={!hbtp},name=Frame,within=chapter,listname=\listofquadrosname]{quadro}

% https://tex.stackexchange.com/questions/176418/remove-list-of-newfloat-from-toc
\makeatletter
\newcommand{\AdjustForMemoir}[1]{%
  \csletcs{kept@listof#1}{listof#1}%
  \csdef{listof#1}{%
    \@ifstar
     {\csappto{newfloat@listof#1@hook}{\append@star}%
      \csuse{kept@listof#1}}%
     {\csuse{kept@listof#1}}%
  }
}
\def\append@star#1{#1*}
\makeatother
\AdjustForMemoir{quadro}
\newlistentry{quadro}{loq}{0}

% Patch the `abntex2` citacao environment removing the extra space from its top
% https://tex.stackexchange.com/questions/300340/topsep-itemsep-partopsep-and-parsep-what-does-each-of-them-mean-and-wha
\xpatchcmd{\citacao}
{\list{}}
{\list{}{\topsep=0pt}}
{}
{\PackageWarning{ufscthesisx}{Citation \topsep is not patched. The 'citacao' environment must be
patched with 'topsep=0pt' but it failed. This is probably due an update on the main class 'abnTeX2',
therefore the \topsep patch must need to be updated accordingly}}

% Backward compatibility with `abntex2cite` package `\citeonline` command with the new `biblatex` package
% https://tex.stackexchange.com/questions/655/what-is-the-difference-between-def-and-newcommand
\let\citeonline\textcite

% Ao contrario da norma abnt-6027-2012, que as figuras estejam listadas na Lista de
% Ilustrações,  a UFSC pede que as figuras estejam na Lista de Figuras.
%
% Remove the colon appended to variables by 'abntex2' because they show up on places they shouldn't
%
% https://tex.stackexchange.com/questions/485830/why-latex-does-not-tell-me-which-command-is-undefined
% https://tex.stackexchange.com/questions/482886/how-to-add-babel-captions-to-newfloat-package-environments
% https://tex.stackexchange.com/questions/482523/how-to-override-command-on-my-preamble-after-its-redefinition-by-my-class-with
\makeatletter
\@ifpackageloaded{babel}{\@ifpackagewith{babel}{brazil}{\addto\captionsbrazil{%
    \renewcommand{\orientadorname}{Orientador}
    \renewcommand{\coorientadorname}{Coorientador}
    \renewcommand{\quadroname}{Quadro}
    \renewcommand{\listofquadrosname}{Lista de Quadros}
    \renewcommand{\listfigurename}{Lista de Figuras}
    \renewcommand{\tableautorefname}{Tabela}
    \renewcommand{\figureautorefname}{Figura}
    \renewcommand{\chapterautorefname}{Capítulo}
    \renewcommand{\equationautorefname}{Equação}
}}{}}{}
\makeatother

\makeatletter
\@ifpackageloaded{babel}{\@ifpackagewith{babel}{english}{\addto\captionsenglish{%
    \renewcommand{\orientadorname}{Supervisor}
    \renewcommand{\coorientadorname}{Co\hyp{}supervisor}
    \renewcommand{\listfigurename}{List of Figures}
    \renewcommand{\tableautorefname}{Table}
    \renewcommand{\figureautorefname}{Figure}
    \renewcommand{\chapterautorefname}{Chapter}
    \renewcommand{\equationautorefname}{Equation}
}}{}}{}
\makeatother

