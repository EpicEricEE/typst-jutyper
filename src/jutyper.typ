#import "@preview/cmarker:0.1.1"

#import "render/cell.typ": render
#import "util.typ": join

// Renders the given jupyter notebook.
// 
// Each cell with an execution number is labeled with `jutyper:cell:<num>`.
// Similarly, the input and output are labeled with `jutyper:input:<num>` and
// `jutyper:output:<num>`, respectively. These can be used to exclude specific
// cells from the final document via show rules.
// 
// If the `title` parameter is set to `auto`, the first level-1 heading in the
// notebook is set as the document title. The heading is removed from the rest
// of the content, and any higher-level headings are promoted by one level. The
// title is placed at the top of the document, together with the authors if
// they are set in the document context, and is labeled with `jutyper:title`.
//
// - title (content | none | auto): The title of the document. If `auto`, the
//   first level-1 heading in the notebook is set as the document title.
// - line-wrap (boolean): Whether to wrap code lines instead of clipping them.
// - line-numbers (boolean): Whether code lines should be numbered.
// - output-limit (number): Maximum number of lines to display for each output.
// - data (dictionary): JSON-decoded content of the `.ipynb` file.
#let notebook(
  title: auto,
  line-wrap: false,
  line-numbers: false,
  output-limit: 50,
  data
) = {
  // Validate parameters.
  assert(
    type(title) in (content, type(auto), type(none)),
    message: "title must be content, auto, or none"
  )
  assert.eq(type(line-wrap), bool, message: "line-wrap must be a boolean")
  assert.eq(type(line-numbers), bool, message: "line-numbers must be a boolean")
  assert.eq(type(output-limit), int, message: "output-limit must be an integer")
  assert.eq(type(data), dictionary, message: "data must be a dictionary")
  
  // Compress arguments into a context dictionary.
  let ctx = (
    title: title,
    line-wrap: line-wrap,
    line-numbers: line-numbers,
    output-limit: output-limit
  )

  // Extract level-1 heading to set as document title (if requested).
  // The heading will be removed from the content in a later step.
  let title = if title != auto { title } else {
    context {
      let encountered = false
      let title = for cell in data.cells {
        if cell.cell_type != "markdown" { continue }
        if cell.source.len() == 0 { continue }

        let content = cmarker.render(join(cell.source))
        if content.func() != [].func() { continue }

        let heading = content.children.find(child => {
          child.func() == heading and child.depth == 1
        })

        if heading != none {
          assert(
            not encountered,
            message: "multiple level-1 headings found in the notebook."
          )

          encountered = true
          heading.body
        }
      }

      set document(title: title) if title != none
      title
    }
  }

  // Place document title and authors if requested and available.
  if title != none [
    #align(center, context {
      text(size: 1.8em, title)
      v(1em, weak: true)
      text(
        style: "oblique",
        size: 1.2em,
        document.author.join(", ", last: if document.author.len() > 2 { "," } + " and ")
      )
      v(3em, weak: true)
    }) <jutyper:title>
  ]

  // Render notebook cells.
  data.cells.map(render.with(ctx)).join()
}
