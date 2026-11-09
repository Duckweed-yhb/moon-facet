// render/ascii.mbt — 把图渲染成终端可看的树。
//
// 输出形如：
//   第一章 [120]
//     1.1 背景 [80]
//   第二章 [200]
//
// 方括号里是节点自身正文字数，不含子节点。

fn indent_of(depth : Int) -> String {
  let mut s = ""
  let mut i = 0
  while i < depth {
    s = s + "  "
    i += 1
  }
  s
}

fn render_subtree(
  store : @model.NodeStore, graph : @model.Graph, node_id : Int, depth : Int
) -> String {
  let title = match store.get(node_id) {
    Some(n) => n.title()
    None => "(missing)"
  }
  let body = match store.get(node_id) {
    Some(n) => n.body_len()
    None => 0
  }
  let mut s = indent_of(depth) + title + " [" + body.to_string() + "]\n"
  for child in graph.children(node_id) {
    s = s + render_subtree(store, graph, child, depth + 1)
  }
  s
}

/// 整张图的 ASCII 树。多个根按追加顺序依次输出。
pub fn ascii_tree(store : @model.NodeStore, graph : @model.Graph) -> String {
  let mut out = ""
  for root in graph.roots() {
    out = out + render_subtree(store, graph, root, 0)
  }
  out
}
