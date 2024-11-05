#import "@preview/cmarker:0.1.1"
#import "@preview/mitex:0.2.4": mitex, mi

#import "output.typ": render as render-output
#import "../style/element.typ": code
#import "../util.typ": join

// Renders the given code cell including any of its outputs.
//
// If a cell has an execution number, a label is attached to the input code,
// the output sequence, and the cell itself. The labels are of the form
// `jutyper:input:<num>`, `jutyper:output:<num>`, or `jutyper:cell:<num>`,
// where `<num>` is the execution number of the cell.
#let render-code(ctx, cell) = {
  if cell.source.len() == 0 and cell.outputs.len() == 0 {
    // Skip empty code cells.
    return
  }

  let label(kind) = if cell.execution_count != none {
    std.label("jutyper:" + kind + ":" + str(cell.execution_count))
  }

  let input = [
    #code(
      number: cell.execution_count,
      error: cell.outputs.any(output => output.output_type == "error"),
      line-wrap: ctx.line-wrap,
      line-numbers: ctx.line-numbers,
      join(cell.source)
    )
    #label("input")
  ]

  let output = [
    #cell.outputs.map(render-output.with(ctx)).join()
    #label("output")
  ]

  [#{input + output} #label("cell")]
}

// Renders the given markdown cell using the `cmarker` package.
//
// Math expressions are parsed and rendered using the `mitex` package.
#let render-markdown(ctx, cell) = {
  let content = cmarker.render(join(cell.source), math: mitex)
  if ctx.title != auto { return content }
  if content.func() != [].func() { return content }

  // Decrease heading depths by one and delete level-1 headings.
  for child in content.children {
    if child.func() != heading { child + continue }
    if child.depth == 1 { continue }
    
    let fields = child.fields()
    let body = fields.remove("body")
    let depth = fields.remove("depth") - 1
    heading(..fields, depth: depth, body)
  }
}

// Renders the given cell based on its type. Currently supports the cell types:
//
// - `markdown`: A markdown cell with math support.
// - `code`: A python code cell, including outputs.
#let render(ctx, cell) = {
  let render = (
    "markdown": render-markdown,
    "code": render-code
  ).at(cell.cell_type, default: (..) => none)

  render(ctx, cell)
}
