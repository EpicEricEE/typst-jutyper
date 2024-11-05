#import "properties.typ": *

// The execution number of a cell or its output.
//
// - number (integer): The execution number.
// - error (boolean): Whether the number is for an error output.
// - kind (string): The kind of the mark, either "input" or "output".
#let execution-mark(number, error: false, kind: "input") = {
  let fill = if error { execution-mark-fill-error } else { execution-mark-fill }
  let number = if number == none { " " } else { str(number) }
  text(fill: fill, raw("[" + number + "]:"))
}

// A plain text output to the `stdout` or `stderr` stream.
//
// The output stream is encoded in the body's `lang` field.
#let output(body) = context {
  if measure(body).height == 0pt { return body }
  if body.lang != "stderr" { return body }

  let fill = code-fill-error
  block(
    width: 100%,
    fill: code-fill-error,
    radius: code-radius,
    outset: (left: -1pt), // Correct for stroke width.
    inset: code-inset,
    stroke: (left: execution-mark-fill-error + 2pt),
    body
  )
}

// A code cell.
//
// - source (string): The source code of the cell.
// - number (integer): The execution number of the cell.
// - error (boolean): Whether the cell errored during execution.
// - line-numbers (boolean): Whether to display line numbers.
// - line-wrap (boolean): Whether to wrap code lines instead of clipping them.
#let code(
  source,
  number: none,
  error: false,
  line-wrap: false,
  line-numbers: false,
) = {
  show raw.where(block: true): set par(justify: false)
  show raw.where(block: true): set block(width: 100%)

  show raw.where(block: true): it => {
    show raw.line: line => context {
      // Create line number and calculate some properties.
      let fill = if error { line-number-fill-error } else { line-number-fill }
      let number-width = measure(str(it.lines.len())).width
      let number = if line-numbers { text(fill: fill, str(line.number)) }
      let inset = if line-numbers { line-number-gap + number-width } else { 0pt }

      // Get available width and the line's indent for wrapping.
      let width = if line-wrap { auto } else { float.inf * 1pt }
      let indent = {
        let pos = line.text.clusters().position(c => c != " ")
        if pos != none { measure(" ").width * pos } else { 0pt }
      }

      box(width: width, inset: (left: inset), {
        // Place line number if available.
        if number != none {
          place(top + left, dx: -inset, align(end, box(width: number-width, number)))
        }

        // Add a zero-width space if the line is empty, so that the height of
        // the line is preserved for the line number. Set hanging indent to
        // keep the indent after wrapping.
        if line.body == [] { sym.zws } else { par(hanging-indent: indent, line) }
      })
    }

    it
  }

  context {
    let inner = raw(lang: "py", block: true, source)
    if measure(inner).height == 0pt { return none }

    let fill = if error { code-fill-error } else { code-fill }
    block(
      width: 100%,
      fill: fill,
      stroke: fill.darken(20%) + 0.5pt,
      radius: code-radius,
      inset: code-inset,
      {
        // Place execution number mark if available.
        let mark = execution-mark(number, error: error, kind: "in")
        place(top + left, dx: -execution-mark-gap - code-inset,
          align(end, box(width: 0pt, mark))
        )

        // Inner block required for clipping, as otherwise the execution mark
        // would be clipped as well.
        block(
          radius: code-radius,
          outset: (right: 0pt, rest: code-inset), // TODO: typst/typst#5293
          clip: true,
          inner
        )
      }
    )
  }
}
