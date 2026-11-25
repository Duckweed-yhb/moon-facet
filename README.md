# moon-facet

A MoonBit prototype for keeping several outlines over a shared pool of nodes.
Each outline has its own parent links and order. A caller can record where a
known node occurs in another outline and look up that occurrence by ID.

The runnable example reads one Markdown document. It prints the heading tree,
section lengths and depths. For a standalone Markdown table of contents or a
section reader, see [md-outline](https://github.com/peter-jerry-ye/md-outline).

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

## Direction under consideration

A documentation maintainer may have two manuals that organize the same topics
differently. When the source manual gains a topic, the maintainer needs to know
whether the companion manual covers it. A possible next step is a coverage
report that uses explicit topic IDs and prints the file and heading path for
each occurrence. The current demo does not perform this comparison.

Before building it, we need a real pair of manuals and a known coverage gap.
If a list of IDs and a spreadsheet already answer the maintainer's question,
the extra hierarchy would add maintenance work without improving the result.

## License

MIT.
