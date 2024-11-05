#import "@preview/based:0.1.0": base64
#import "@preview/cmarker:0.1.1"
#import "@preview/mitex:0.2.4": mitex, mitext

#import "../util.typ": join

// Renders the given image data.
#let render-image(mime, data, metadata) = {
  let width = metadata.at("width", default: auto)
  let height = metadata.at("height", default: auto)

  // SVGs are given as text, raster images as base64 encoded bytes.
  let data = if mime == "image/svg+xml" {
    join(data)
  } else {
    base64.decode(data)
  }

  figure(image.decode(
    data,
    width: if width == auto { width } else { 1pt * width },
    height: if height == auto { height } else { 1pt * height }
  ))
}

// Renders the given plain text data.
#let render-plain(mime, data, metadata) = {
  raw(join(data).trim(at: end))
}

// Renders the given JSON data.
#let render-json(mime, data, metadata) = {
  raw(lang: "json", block: true, json.encode(data))
}

// Renders the given LaTeX data.
#let render-latex(mime, data, metadata) = {
  mitext(join(data))
}

// Renders the given Markdown data.
#let render-markdown(mime, data, metadata) = {
  set heading(numbering: none)
  cmarker.render(join(data), math: mitex)
}

// Renders the code cell output with the given MIME type.
//
// Supported MIME types:
// - `image/svg+xml`
// - `image/png`
// - `image/jpeg`
// - `image/gif`
// - `text/latex`
// - `text/markdown`
// - `text/plain`
// - `application/json`
#let render(mime, data, metadata) = {
  // NOTE: Also add in `util.sort-by-mime` when adding new MIME types.
  let render = (
    "image/svg+xml": render-image,
    "image/png": render-image,
    "image/jpeg": render-image,
    "image/gif": render-image,
    "text/latex": render-latex,
    "text/markdown": render-markdown,
    "text/plain": render-plain,
    "application/json": render-json
  ).at(mime, default: (..) => none)

  render(mime, data, metadata)
}
