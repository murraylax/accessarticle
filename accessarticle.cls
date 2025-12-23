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
% Accessible display math: redefine 'displaymath' to add tagging + optional alt text.
% Usage: \begin{displaymath}[Plain-language description] ... \end{displaymath}
% If optional argument omitted, no alt text is added.
\let\origdisplaymath\displaymath
\let\origenddisplaymath\enddisplaymath
\RenewDocumentEnvironment{displaymath}{ O{} }{%
  % Start original display math (sets up math mode)
  \origdisplaymath
  % Immediately open structure element so formula content is inside it
  \if\relax\detokenize{#1}\relax
    	\tagstructbegin{tag=Formula}% no alt text
  \else
    	\tagstructbegin{tag=Formula,alttext=\unexpanded{#1}}%
  \fi
}{%
  % Close structure before leaving display math environment
  \tagstructend
  \origenddisplaymath
}

% Accessible equation: redefine 'equation' to add tagging + optional alt text.
% Usage: \begin{equation}[Plain-language description] ... \end{equation}
% If optional argument omitted, no alt text is added.
\let\origequation\equation
\let\origendequation\endequation
\RenewDocumentEnvironment{equation}{ O{} }{%
  % Start original display math (sets up math mode)
  \origequation
  % Immediately open structure element so formula content is inside it
  \if\relax\detokenize{#1}\relax
    	\tagstructbegin{tag=Formula}% no alt text
  \else
    	\tagstructbegin{tag=Formula,alttext=\unexpanded{#1}}%
  \fi
}{%
  % Close structure before leaving display math environment
  \tagstructend
  \origendequation
}

\RequirePackage{fontspec}
\RequirePackage[english]{babel}