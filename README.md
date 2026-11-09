# moon-facet

Multi-view hierarchical structure model for MoonBit.

A **facet** is one view of a structure: a book's chapters, the notes you took
while reading it, the plan you derived from it. They are different graphs over
**the same node pool**. `moon-facet` owns the pool, the graphs, and the
alignment table that says "this node is here in graph A and there in graph B".

It is **not** a mind-map tool, not a note-taking vault, and not a summarizer.
It computes structure and metrics; drawing and interaction are left to the
caller (`Milky2018/diago` renders graphs, if you need SVG).

## Why not `md-outline`?

`md-outline` reads one Markdown file and gives you its section tree. That is a
single view. `moon-facet` is about several views of one object: nodes are
shared, graphs can be nested, and the alignment table keeps them consistent.
If you only need a table of contents, use `md-outline`.

## Model

```text
NodeStore   global pool: id, title, body_len
Graph       one view: ordered node ids + parent links (a tree)
Alignment   (node, graph) -> local index, the "same node in several views" record
```

Two invariants the first version enforces:

- a node belongs to the pool, not to a graph; a graph only holds ids;
- a parent must already be in the graph when a child is appended.

## Quick start

```sh
moon run examples/demo --target native
```

The demo parses a small Markdown "book", builds the tree, and prints body
lengths, share of the whole, depth, and an ASCII tree:

```text
第二章 方法 [14]
  2.1 节点池 [11]
    2.1.1 共享 [13]
  2.2 对齐 [18]
```

## Packages

| Package | Responsibility |
|---|---|
| `model/` | node pool, graph, alignment table, structural validation |
| `parse/` | Markdown ATX headings -> sections with non-space body length |
| `metric/` | per-node body length, share, child count, depth, max depth |
| `render/` | ASCII tree output |
| `examples/demo` | runnable end-to-end example |

## Status (2026-11-09)

- 20 tests, `moon check --target wasm-gc --deny-warn` clean.
- Implemented: pool/graph/alignment, Markdown parsing, metrics, ASCII render.
- Planned: multi-graph alignment demo, nested graphs, serializable intermediate
  format, EPUB/PDF outline parsing (not before the above), interactive HTML
  export (pan/zoom) — none of these are claimed as done.

## License

MIT.
