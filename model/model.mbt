// model/model.mbt — 节点池、图与对齐表（纯计算，无 I/O）。
//
// 一个对象（书、笔记、目标）对应一张 Graph；Graph 里的条目只是节点 id，
// 节点本身存在全局 NodeStore 里。这样同一节点能出现在多张图中，
// 对齐表负责回答「同一个节点在每张图里是哪个位置」。

/// 节点：全局池中的一个条目。`body_len` 是该节点自己的正文字数，
/// 不含子节点；字数口径由解析层给定（非空白字符数）。
pub struct Node {
  id : Int
  title : String
  body_len : Int
}

pub fn Node::id(self : Node) -> Int {
  self.id
}

pub fn Node::title(self : Node) -> String {
  self.title
}

pub fn Node::body_len(self : Node) -> Int {
  self.body_len
}

/// 节点池。第一版用线性查找，几百个节点以内够用。
pub struct NodeStore {
  nodes : Array[Node]
}

pub fn NodeStore::new() -> NodeStore {
  { nodes: [] }
}

/// 追加一个节点，返回新的池与分配到的 id（从 0 递增）。
pub fn NodeStore::add(
  self : NodeStore, title : String, body_len : Int
) -> (NodeStore, Int) {
  let id = self.nodes.length()
  self.nodes.push({ id: id, title: title, body_len: body_len })
  (self, id)
}

/// 按 id 取节点，找不到返回 None。
pub fn NodeStore::get(self : NodeStore, id : Int) -> Node? {
  let mut i = 0
  while i < self.nodes.length() {
    if self.nodes[i].id == id {
      return Some(self.nodes[i])
    }
    i += 1
  }
  None
}

pub fn NodeStore::len(self : NodeStore) -> Int {
  self.nodes.length()
}

/// 图内的非法结构。
pub enum GraphErr {
  /// 同一个节点在一张图里出现两次。
  NodeAlreadyInGraph(Int)
  /// 父节点 id 不在这张图里（必须先追加父节点）。
  UnknownParent(Int)
}

pub fn GraphErr::describe(self : GraphErr) -> String {
  match self {
    NodeAlreadyInGraph(id) => "node " + id.to_string() + " already in graph"
    UnknownParent(id) => "unknown parent node " + id.to_string()
  }
}

/// 一张结构图：`order` 是节点出现的顺序，`parent` 是与它平行的父节点 id，
/// 根节点记 -1。第一版只支持树（每个节点至多一个父）。
pub struct Graph {
  id : Int
  name : String
  order : Array[Int]
  parent : Array[Int]
}

pub fn Graph::new(id : Int, name : String) -> Graph {
  { id: id, name: name, order: [], parent: [] }
}

pub fn Graph::graph_id(self : Graph) -> Int {
  self.id
}

pub fn Graph::name(self : Graph) -> String {
  self.name
}

pub fn Graph::node_count(self : Graph) -> Int {
  self.order.length()
}

/// 第 i 个节点的 id（按追加顺序）。
pub fn Graph::order_at(self : Graph, i : Int) -> Int {
  self.order[i]
}

/// 第 i 个节点的父 id，根为 -1。
pub fn Graph::parent_at(self : Graph, i : Int) -> Int {
  self.parent[i]
}

/// 按顺序追加一个节点。`parent_id` 为 -1 表示根。
/// 父节点必须已经在这张图里，否则返回 `UnknownParent`。
pub fn Graph::append(
  self : Graph, node_id : Int, parent_id : Int
) -> Result[Unit, GraphErr] {
  let mut i = 0
  while i < self.order.length() {
    if self.order[i] == node_id {
      return Err(NodeAlreadyInGraph(node_id))
    }
    i += 1
  }
  if parent_id != -1 {
    let mut found = false
    let mut j = 0
    while j < self.order.length() {
      if self.order[j] == parent_id {
        found = true
        break
      }
      j += 1
    }
    if !found {
      return Err(UnknownParent(parent_id))
    }
  }
  self.order.push(node_id)
  self.parent.push(parent_id)
  Ok(())
}

/// 某个父节点的直接子节点，按追加顺序。
pub fn Graph::children(self : Graph, parent_id : Int) -> Array[Int] {
  let out : Array[Int] = []
  let mut i = 0
  while i < self.parent.length() {
    if self.parent[i] == parent_id {
      out.push(self.order[i])
    }
    i += 1
  }
  out
}

/// 根节点（parent 为 -1 的节点）。
pub fn Graph::roots(self : Graph) -> Array[Int] {
  self.children(-1)
}

/// 节点在图中的下标，找不到返回 None。
pub fn Graph::index_of(self : Graph, node_id : Int) -> Int? {
  let mut i = 0
  while i < self.order.length() {
    if self.order[i] == node_id {
      return Some(i)
    }
    i += 1
  }
  None
}

/// 从根到该节点的层数，根为 0。节点不存在返回 None。
pub fn Graph::depth(self : Graph, node_id : Int) -> Int? {
  let mut cursor = node_id
  let mut depth = 0
  while cursor != -1 {
    let idx = match self.index_of(cursor) {
      Some(i) => i
      None => return None
    }
    cursor = self.parent[idx]
    if cursor != -1 {
      depth += 1
    }
  }
  Some(depth)
}

/// 对齐表：记录节点在某张图里的下标。
/// 同一节点在多张图里各有一条记录，就是「多视图叠加」的落点。
pub struct Alignment {
  entries : Array[(Int, Int, Int)]
}

pub fn Alignment::new() -> Alignment {
  { entries: [] }
}

/// 记录一次对齐。同一 (node, graph) 已存在时覆盖为最新位置。
pub fn Alignment::record(
  self : Alignment, node_id : Int, graph_id : Int, local_index : Int
) -> Alignment {
  let kept : Array[(Int, Int, Int)] = []
  for e in self.entries {
    let (n, g, _) = e
    if !(n == node_id && g == graph_id) {
      kept.push(e)
    }
  }
  kept.push((node_id, graph_id, local_index))
  { entries: kept }
}

/// 查某节点在某张图里的位置。
pub fn Alignment::locate(
  self : Alignment, node_id : Int, graph_id : Int
) -> Int? {
  for e in self.entries {
    let (n, g, idx) = e
    if n == node_id && g == graph_id {
      return Some(idx)
    }
  }
  None
}

/// 一个节点已经出现在哪些图里。
pub fn Alignment::graphs_of(self : Alignment, node_id : Int) -> Array[Int] {
  let out : Array[Int] = []
  for e in self.entries {
    let (n, g, _) = e
    if n == node_id {
      out.push(g)
    }
  }
  out
}
