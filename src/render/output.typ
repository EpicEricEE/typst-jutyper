#import "@preview/ansi-render:0.6.1": ansi-render, terminal-themes

#import "mime.typ": render as render-mime
#import "../style/element.typ": output as output-elem
#import "../util.typ": join, sort-by-mime

// Renders the contents of an output stream.
#let render-stream(output) = {
  output-elem(raw(
    block: true,
    lang: output.name,
    join(output.text).trim(at: end)
  ))
}

// Renders the given output data.
#let render-data(output) = {
  for (mime, data) in output.data.pairs().sorted(key: sort-by-mime) {
    let metadata = output.metadata.at(mime, default: (:))
    let result = render-mime(mime, data, metadata)
    if result != none {
      return result
    }
  }
}

// Renders the given execution error.
#let render-error(output) = {
  // TODO: find a better way around the weird line spacing.
  show block: set par(leading: 0.35em)

  ansi-render(
    font: none,
    theme: (..terminal-themes.vscode-light, default-bg: none),
    join(output.traceback, sep: "\n").trim(at: end)
  )
}

// Renders the given output of a cell.
//
// The output is rendered based on its type.
// - `stream`: Text output.
// - `display_data`: Image, text, or JSON data.
// - `execute_result`: Same as `display_data`.
// - `error`: Execution error.
#let render(ctx, output) = context {
  let font = text.font
  let size = text.size

  let render = (
    "stream": render-stream,
    "display_data": render-data,
    "execute_result": render-data,
    "error": render-error
  ).at(output.output_type, default: (..) => none)

  // Truncate output if it exceeds the limit.
  show raw.where(block: true): it => {
    let trailing = calc.min(int(ctx.output-limit / 2), 4)
    if it.lines.len() <= ctx.output-limit + 1 {
      return it
    }

    let lines = it.lines.map(line => line.text).slice(0, ctx.output-limit)
    let skipped = it.lines.len() - lines.len()

    let fields = it.fields()
    let _ = fields.remove("text")
    let _ = fields.remove("lines")

    context {
      // Use same text size as the original element.
      show raw: set text(size: text.size)
      raw(..fields, lines.slice(0, -trailing).join("\n"))
      text(style: "italic", fill: text.fill.lighten(50%))[\... (Skipped #skipped more lines)]
      raw(..fields, it.lines.map(line => line.text).slice(-trailing).join("\n"))
    }
  }

  block(width: 100%, render(output))
}
