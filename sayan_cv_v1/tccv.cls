% Copyright (C) 2012-2021  Nicola Fontana <ntd at entidi.it>
%
% This program can be redistributed and/or modified under
% the terms of the LaTeX Project Public License, either
% version 1.3 of this license or (at your option) any later
% version. The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all LaTeX distributions
% version 2005/12/01 or later.
%
% Based on the original idea by Alessandro Plasmati found at
% http://www.latextemplates.com/template/two-column-one-page-cv
%
% The most relevant changes from his work are:
%
% * this is a class, not a template document;
% * tccv is based on scrartcl (from Koma-script), not on article;
% * the fonts are selected from the PSNFSS collection, so no
%   custom font installation should be required;
% * heavily based the implementation on custom environments and
%   macros, so the document is much easier to read (and customize);
% * it is plain LaTeX/Koma-script, so the CV can be compiled
%   with the usual tools, latex and pdflatex included.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tccv}
	      [2021/12/16 v1.3.1
	       Two Column Curriculum Vitae]

\LoadClassWithOptions{scrartcl}

\setcounter{secnumdepth}{-1}
\RequirePackage[hmargin=1.25cm,vmargin=1.25cm,twocolumn,columnsep=1.25cm]{geometry}
\RequirePackage{etoolbox,needspace,pifont,tabularx,xcolor}
\RequirePackage{hyperref}

% Use fontspec on lualatex and bookman on pdflatex
\@ifundefined{directlua}%
    {\RequirePackage{bookman}}%
    {\RequirePackage{fontspec}\setmainfont{TeX Gyre Bonum}}


% Capitalize words of at least a minimum length (default to 3 chars).
% The text is capitalized before being expanded.
%
% This macro uses Lua to do the job but fails gracefully (that is,
% return the text as is) if \directlua is not available.
%
%     \ucwords
%         [optional: miminum length]{text}
\newcommand\ucwords[2][3]{%
    % Fails gracefully if not in LuaLaTeX
    \providecommand\directlua[1]{#2}%
    \directlua{%
	local minlen = tonumber("#1")
	local src = "\luaescapestring{\unexpanded{#2}}"
	local dst = {}
	% Put a % inside \directlua is tricky as hell. Use char(37)
	% instead: still no plans for supporting non-ASCII platforms.
	for w in src:gmatch(string.char(37) .. "S+") do
	    if w:len() >= minlen then
		table.insert(dst, w:sub(1,1):upper() .. w:sub(2))
	    else
		table.insert(dst, w)
	    end
	end
	tex.print(dst)}}

% Default color theme
\definecolor{foregound}{HTML}{303030}
\definecolor{url}{HTML}{506060}
\definecolor{link}{HTML}{506060}
\definecolor{header}{HTML}{801010}
\definecolor{personal}{HTML}{F5DD9D}

% Allow the resume's theme to be B/W only
\DeclareOption{blackwhite}{%
    \definecolor{header}{HTML}{1C1C1C}%
    \definecolor{personal}{HTML}{F7F7F7}}

\ProcessOptions\relax

\pagestyle{empty}
\setlength\parindent{0pt}
\color{foregound} % Default foreground color
\hypersetup{colorlinks,breaklinks,urlcolor=url,linkcolor=link}
\setkomafont{disposition}{\color{header}}
\setkomafont{section}{\scshape\Large\mdseries}
\newkomafont{cv}{%
    \@ifundefined{directlua}%
	{\fontfamily{pzc}\selectfont\Huge}%
	{\itshape\huge}}

% In tccv \part must contain the subject of the curriculum vitae.
% The command will start a new page and output in onecolumn the
% subject (first and last name) with the text from the optional
% argument underneath it
\renewcommand\part[2][Curriculum Vitae]{%
    \twocolumn[%
    \begin{center}
	\vskip-\lastskip%
	{\usekomafont{part} #2} \medskip\\
	{\usekomafont{cv} #1}
	\bigskip
    \end{center}]}

% Overrides the \section command to capitalize every
% word for cosmetic purposes and draws a rule under it.
\let\old@section\section
\renewcommand\section[2][]{%
    \old@section[#1]{\ucwords{#2}}%
    \newdimen\raising%
    \raising=\dimexpr-0.7\baselineskip\relax%
    \vskip\raising\hrule height 0.4pt\vskip-\raising}

% Allow conditionals based on the job name. This can usually be set
% from a command-line argument: check fausto.en.tex for an example.
%
%     \ifjob
%         {jobname}
%         {content if matches}
%         {content if does not match}
\newcommand\ifjob[3]{%
    \edef\JOBNAME{\jobname}%
    \edef\PIVOT{\detokenize{#1}}%
    \ifdefstrequal{\JOBNAME}{\PIVOT}{#2}{#3}}

% Creates an unordered list of keys (optionals) and values (i.e. a
% description text) inside a colored box. See the `\personal` command
% for a real use case.
%
%     \begin{keyvaluelist}{color}
%         \item[key text] value text...
%         ...
%     \end{keyvaluelist}
\newcounter{KEYVALUECOUNTER}%
\newenvironment{keyvaluelist}[1]{%
    \newcommand\KEYVALUECOLOR{#1}%
    \renewcommand\item[1][]{%
	\stepcounter{KEYVALUECOUNTER}%
	\ifnumequal{\value{KEYVALUECOUNTER}}{1}{}{\smallskip\cr}%
	##1 & }%
    \newdimen\boxwidth\boxwidth=\dimexpr\linewidth-2\fboxsep\relax%
    % Tried to use \savebox and lrbox environment without success:
    % both fail complaining about some phantom } missing. I'm too
    % tired to guess what LaTeX wants... falling back to TeX here.
    \setbox0=\hbox\bgroup%
    \tabularx{\boxwidth}{c|X}}
    {\endtabularx\egroup\colorbox{\KEYVALUECOLOR}{\box0}%
     \setcounter{KEYVALUECOUNTER}{0}}

% Renders a personal data box:
%
%     \personal
%         [url without scheme, i.e. no http:// prefix]
%         {address}
%         {phone number}
%         {email}
\newcommand\personal[4][]{%
    \newcommand\SYMBOL[1]{\raisebox{-2pt}{\Large\ding{##1}}}%
    \needspace{0.5\textheight}%
    \begin{keyvaluelist}{personal}
	\item[\SYMBOL{45}] #2
	\item[\SYMBOL{37}] #3
	\item[\SYMBOL{41}] \href{mailto:#4}{#4}
	\ifstrempty{#1}{}{\item[\SYMBOL{218}] \href{https://#1}{#1}}
    \end{keyvaluelist}}

% Every \item can be followed by one or more paragraphs
% of description:
%
%     \item
%         {date range}
%         {company}
%         {role}
%     One or more paragraphs describing what achieved during this application.
\newenvironment{eventlist}{%
    \newcommand*\inskip{}
    \renewcommand\item[3]{%
	\inskip%
	{\raggedleft\textsc{##1}\\[1pt]}
	\ifstrempty{##2}{}{##2\\[2pt]}
	{\Large\textit{##3}}
	\medskip
	\renewcommand\inskip{\bigskip}}}
    {\bigskip}

% Use only \item inside this environment, no other macros
% are allowed:
%
%     \item
%         [what has been achieved]
%         {years}
%         {subject}
%         {notes}
\newenvironment{yearlist}{%
    \renewcommand\item[4][]{%
	\textsc{##2} & \textbf{##3} \\
	\ifstrempty{##1}{}{& \textsc{##1} \\}
	& \textit{##4}\medskip\\}
    \tabularx{\linewidth}{rX}}
    {\endtabularx}


% Use only \item inside this environment: no other macros
% are allowed:
%
%     \item
%         {fact}
%         {description}
\newenvironment{factlist}{%
    \newdimen\unbaseline
    \unbaseline=\dimexpr-\baselinestretch\baselineskip\relax
    \renewcommand\item[2]{%
	\textsc{##1} & {\raggedright ##2\medskip\\}\\[\unbaseline]}
    \tabularx{\linewidth}{rX}}
    {\endtabularx}

% Avoid dealing with starred sections
% See the following question for further details:
% http://tex.stackexchange.com/questions/223607/does-the-bibliography-command-specify-a-section-anywhere
\KOMAoption{bibliography}{totocnumbered}

\AtEndPreamble{%
    \@ifpackageloaded{biblatex}{%
	\defbibheading{bibliography}[\refname]{\section{#1}}}{}}
%%
%% End of file `tccv.cls'.