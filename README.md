# Bibliography_Generation
dddd

Well, a wierd functionality.

## `*.bbl` to `*.tex`

I use [JabRef](https://www.jabref.org/) to generate and manage `*.bib` database file, from which for every single reference, relevant pieces of information would be extracted according to the order and the style written in the main text file `*.tex` by `bibtex`, and a `*.bbl` file would be automatically generated.

The function `exporttotex` in the notebook then can extract the corresponding information in that `*.bbl` to generate an `apsrev`-style `thebibliography` environment.

## `*.bib` to `*.tex`

I personally prefer this second solution.

This time the function `exporttotex` does the similar job, according to the cited keys with the correct order in `\cite{*}` in the `*.tex` file, but from the original reference database `*.bib`.