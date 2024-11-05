#import "../src/lib.typ": notebook

// Source for example notebook:
// https://jupyter-notebook.readthedocs.io/en/stable/examples/Notebook/Running%20Code.html

#set page(
  fill: none,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

// Scale down page from A4 to A6, but keep relative sizes.
#set page(paper: "a6", numbering: "1")
#set text(size: 0.5em)

#set document(author: "Jupyter Development Team")
#set par(justify: true)
#set heading(numbering: "1.")

#notebook(
  line-numbers: true,
  json("example.ipynb")
)
