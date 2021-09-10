#!/usr/bin/env wolframscript
(* ::Package:: *)

Clear[citedkeys, bibdatabase, apsrevbibstyle, exporttex]
citedkeys[texpath_String]:=
Module[{raw, tidied},
	raw = StringCases[RegularExpression["\\\\cite\\{(.+?)\\}"]->"$1"][Import[texpath,"Text"]];
	DeleteDuplicates[Join@@(StringSplit[#,","]&/@raw)]
];
bibdatabase[bibpath_String]:=
Module[{rawstrings,types,keys,otherfields},
	rawstrings=(StringSplit[#,RegularExpression["\n\\@"]]&@Import[bibpath,"Text"])[[2;;-2]];
	types="type"->First[#]&/@StringCases[RegularExpression["(^[A-Z]\\w+?)(?=\\{)"]->"$1"]/@rawstrings;
	keys=StringCases[RegularExpression["(?<=\\{)(\\w+?)(?=\\,)"]->"$1"]/@rawstrings;
	otherfields=StringCases[RegularExpression[" (\\w+) +\\= +\\{(.+)\\}\\,\n"]->("$1"->"$2")]/@rawstrings;
	Association@Thread[Flatten[keys]->(Association/@Join[{types,"key"->First[#]&/@keys}\[Transpose],otherfields,2])]
];
apsrevbibstyle[key:(_String|_Integer), bibdb_, hyperlink:(True|False):False]:=
Module[{item=If[Head[key]===String,bibdb[key],bibdb[[key]]],authorabbr,author,pages,article,book,phdthesis,givennamepattern},
	givennamepattern=RegularExpression["(?<=[[:upper:]])[[:lower:]]+(?!= )"];
	authorabbr=StringRiffle[#," "]&/@(MapAt[StringReplace[givennamepattern->"."],{{1},{-2}}]@StringSplit[#," "]&/@StringSplit[item["author"]," and "]);
	author=Which[Length[#]==1,#[[1]],
				Length[#]==2,StringRiffle[#," and "],
				True,StringRiffle[MapAt[StringTemplate["and ``"],#,-1],", "]
			]&[authorabbr];
	item["author"]=author;
	If[KeyExistsQ[item,"pages"],pages=StringReplace[item["pages"],RegularExpression["(?<=\\d)\\D.+"]->""];item["pages"]=pages;];
	article[False]=StringTemplate["\t\t\\bibitem{`key`} `author`, `journal` \\textbf{`volume`}, `pages` (`year`)."];
	book[False]=StringTemplate["\t\t\\bibitem{`key`} `author`, \\emph{`title`}, `edition` ed. (`publisher`, `address`, `year`)."];
	phdthesis[False]=StringTemplate["\t\t\\bibitem{`key`} `author`, `language`, \\emph{`title`}, `type`, `school`, (`year`)."];
	article[True]=StringTemplate["\t\t\\bibitem{`key`} `author`, \\href{http://dx.doi.org/`doi`}{`journal` \\textbf{`volume`}, `pages` (`year`)}."];
	book[True]=StringTemplate["\t\t\\bibitem{`key`} `author`, \\href{`url`}{\\emph{`title`}}, `edition` ed. (`publisher`, `address`, `year`)."];
	phdthesis[True]=StringTemplate["\t\t\\bibitem{`key`} `author`, `language`, \\href{`url`}{\\emph{`title`}}, `type`, `school`, (`year`)."];
	Which[
		#["type"]=="Article",article[hyperlink][#],
		#["type"]=="Book",book[hyperlink][#],
		#["type"]=="phdthesis",phdthesis[hyperlink][#]
	]&[item]
];
exporttex[texpath_String, bibpath_String, outname_String:"bib.tex", hyperlink:(True|False):False]:=
Module[{keys=citedkeys[texpath],bibdb=bibdatabase[bibpath],finalstring,n,itemlist,asso},
	itemlist=apsrevbibstyle[#,bibdb,hyperlink]&/@keys;n=Length[keys];
	finalstring=StringTemplate["\t\\begin{thebibliography}{``}\n``\n\t\\end{thebibliography}"][n,StringRiffle[itemlist,"\n"]];
	Export[FileNameJoin[{FileNameDrop[texpath,-1],outname}],finalstring,"TEXT"]
]


{texpath, bibpath} = Rest @ $ScriptCommandLine;
exporttex[texpath, bibpath]
