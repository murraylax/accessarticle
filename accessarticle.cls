% This file is part of Access Article. 
%
% Copyright (C) 2025 James M. Murray
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, version 3 of the License.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{accessarticle}[2025/12/23 v1.0 Access Article Class]

% Pass all options to the article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Load the article class
\LoadClass{article}

% --- PDF tagging core ---
\RequirePackage{hyperref}
\hypersetup{
  pdfencoding=auto,
  pdflang={en-US},
  pdfdisplaydoctitle=true,
  colorlinks=true,
  urlcolor=blue
}

% Redefine \title to also set pdftitle in hyperref
\let\origtitle\title
\renewcommand{\title}[1]{%
  \origtitle{#1}%
  \hypersetup{pdftitle={#1}}%
} 

\RequirePackage{tagpdf}
\tagpdfsetup{
  activate-all,
  interwordspace = true,
  tabsorder      = structure,
  paratagging    = true
}
\RequirePackage{bookmark}
\bookmarksetup{open,numbered}

% --- Fonts (configurable) ---
\RequirePackage{fontspec}

% Unicode math (proper ToUnicode mappings)
\RequirePackage{unicode-math}

% --- Graphics: decorative vs accessible ---
\RequirePackage{graphicx}

% Save original \includegraphics before redefining
\let\origincludegraphics\includegraphics

% Purely decorative graphics (marked as artifact, ignored by AT)
% Usage: \decographics[<includegraphics options>]{<file>}
% Default width is \linewidth if you omit options.
\NewDocumentCommand{\decographics}{O{width=\linewidth} m}{%
  \par\noindent
  \tagmcbegin{artifact}%
    \begin{center}
      \origincludegraphics[#1]{#2}%
    \end{center}
  \tagmcend
  \par
}

% Redefine \includegraphics to be accessible by default
% Usage: \includegraphics[<options>]{<alt text>}{<file>}
% Default width is \linewidth if you omit options.
\RenewDocumentCommand{\includegraphics}{O{width=\linewidth} m m}{%
  \par\noindent
  \tagstructbegin{tag=Figure,alttext=\unexpanded{#2}}% Put alttext on the Figure structure element
    \tagmcbegin{tag=Figure}% No alttext needed on marked content
        \begin{center}
        \origincludegraphics[#1]{#3}%        
        \end{center}
    \tagmcend
  \tagstructend
  \par
}

% Backwards compatibility: \accgraphics is now an alias for \includegraphics
% Usage: \accgraphics[<options>]{<alt text>}{<file>}
\NewDocumentCommand{\accgraphics}{O{width=\linewidth} m m}{%
  \includegraphics[#1]{#2}{#3}%
}

% --- Accessible display/equation with optional alt text ---
% With testphase=latest, latex-lab already tags math environments automatically.
% The accmath and acceqn environments add alt text support.
%
% Usage: \begin{accmath}[Plain-language description] ... \end{accmath}
% Usage: \begin{acceqn}[Plain-language description] ... \end{acceqn}
%
% Standard displaymath and equation are left for latex-lab to handle natively.

\makeatletter
% Save catcode-3 (math shift) $ tokens to bypass latex-lab's active-$ hooks
\begingroup
\catcode`\$=3\relax
\gdef\accessarticle@mathopen{$}%
\gdef\accessarticle@mathclose{$}%
\endgroup

% Accessible displaymath: manually tag with alt text
% Uses inline $\displaystyle...$ with catcode-3 $ to bypass latex-lab hooks,
% centered via \hfil to simulate display math.
\ExplSyntaxOn
\NewDocumentEnvironment{accmath}{ O{} }{%
  \par\addvspace{\abovedisplayskip}%
  \if\relax\detokenize{#1}\relax
    \tagstructbegin{tag=Formula}%
  \else
    \tagstructbegin{tag=Formula,alttext={#1}}%
  \fi
  \tagmcbegin{tag=Formula}%
  \noindent\hfil
  \bool_set_true:N \l__math_collected_bool
  \accessarticle@mathopen\displaystyle
}{%
  \accessarticle@mathclose
  \hfil\null
  \tagmcend
  \tagstructend
  \par\addvspace{\belowdisplayskip}%
}

% Accessible equation (numbered): same approach with equation number
\newcounter{accessarticleeqn}
\NewDocumentEnvironment{acceqn}{ O{} }{%
  \stepcounter{accessarticleeqn}%
  \par\addvspace{\abovedisplayskip}%
  \if\relax\detokenize{#1}\relax
    \tagstructbegin{tag=Formula}%
  \else
    \tagstructbegin{tag=Formula,alttext={#1}}%
  \fi
  \tagmcbegin{tag=Formula}%
  \noindent\hfil
  \bool_set_true:N \l__math_collected_bool
  \accessarticle@mathopen\displaystyle
}{%
  \accessarticle@mathclose
  \hfil(\theaccessarticleeqn)%
  \tagmcend
  \tagstructend
  \par\addvspace{\belowdisplayskip}%
}
\ExplSyntaxOff
\makeatother

\RequirePackage{fontspec}
\RequirePackage[english]{babel}

% --- List formatting ---
% Redefine itemize/enumerate to support per-environment enumitem options
% (e.g., [leftmargin=1pc]) which latex-lab tagging otherwise blocks.
\RequirePackage{enumitem}

\makeatletter
% Storage for list options
\newlength{\accessarticle@listmargin}

% Define keys for list options
\define@key{accesslist}{leftmargin}{\setlength{\accessarticle@listmargin}{#1}}

% Save original environments before latex-lab modifies them
\let\accessarticle@origitemize\itemize
\let\accessarticle@endorigitemize\enditemize
\let\accessarticle@origenumerate\enumerate
\let\accessarticle@endorigenumerate\endenumerate

\AtBeginDocument{%
  % Now save the latex-lab tagged versions
  \let\accessarticle@taggeditemize\itemize
  \let\accessarticle@endtaggeditemize\enditemize
  \let\accessarticle@taggedenumerate\enumerate
  \let\accessarticle@endtaggedenumerate\endenumerate
  
  % Redefine itemize to accept leftmargin option
  \renewenvironment{itemize}[1][]{%
    \setlength{\accessarticle@listmargin}{0pt}%
    \setkeys{accesslist}{#1}%
    \ifdim\accessarticle@listmargin>0pt
      \setlength{\leftmargini}{\accessarticle@listmargin}%
    \fi
    \accessarticle@taggeditemize
  }{%
    \accessarticle@endtaggeditemize
  }%
  
  % Redefine enumerate to accept leftmargin option
  \renewenvironment{enumerate}[1][]{%
    \setlength{\accessarticle@listmargin}{0pt}%
    \setkeys{accesslist}{#1}%
    \ifdim\accessarticle@listmargin>0pt
      \setlength{\leftmargini}{\accessarticle@listmargin}%
    \fi
    \accessarticle@taggedenumerate
  }{%
    \accessarticle@endtaggedenumerate
  }%
}
\makeatother