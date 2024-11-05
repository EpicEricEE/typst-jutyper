// Joins given children, but returns a zero width space if the array
// is empty (instead of none).
#let join(children, sep: none) = if children.len() == 0 {
  str(sym.zws)
} else {
  children.join(sep)
}

// Sorts the given output data by MIME type priority.
#let sort-by-mime((mime, _)) = {
  let mimes = (
    "image/svg+xml",
    "image/png",
    "image/jpeg",
    "image/gif",
    "text/latex",
    "text/markdown",
    "text/plain",
    "application/json"
  )
  
  if mime in mimes { mimes.position(m => m == mime) } else { float.inf }
}
