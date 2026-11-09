// metric/metric.mbt — 结构度量。
//
// 只算能客观数出来的量：节点自身正文字数、它占全图的比例、直接子节点数、深度。
// 不做「重要性」判断——那是调用方或人来做的事。

/// 单个节点的度量。
pub struct NodeMetric {
  node_id : Int
  body_len : Int
  share : Double
  child_count : Int
  depth : Int
}

pub fn NodeMetric::node_id(self : NodeMetric) -> Int {
  self.node_id
}

pub fn NodeMetric::body_len(self : NodeMetric) -> Int {
  self.body_len
}

/// 占全图正文总量的比例，0.0–1.0。
pub fn NodeMetric::share(self : NodeMetric) -> Double {
  self.share
}

pub fn NodeMetric::child_count(self : NodeMetric) -> Int {
  self.child_count
}

pub fn NodeMetric::depth(self : NodeMetric) -> Int {
  self.depth
}

/// 图中所有节点的正文字数之和。
pub fn total_body_len(store : @model.NodeStore, graph : @model.Graph) -> Int {
  let mut total = 0
  let mut i = 0
  while i < graph.node_count() {
    let id = graph.order_at(i)
    match store.get(id) {
      Some(n) => total += n.body_len()
      None => ()
    }
    i += 1
  }
  total
}

/// 按图的节点顺序给出每节点度量。
pub fn metrics(
  store : @model.NodeStore, graph : @model.Graph
) -> Array[NodeMetric] {
  let total = total_body_len(store, graph)
  let out : Array[NodeMetric] = []
  let mut i = 0
  while i < graph.node_count() {
    let id = graph.order_at(i)
    let body = match store.get(id) {
      Some(n) => n.body_len()
      None => 0
    }
    let share = if total > 0 {
      body.to_double() / total.to_double()
    } else {
      0.0
    }
    let child_count = graph.children(id).length()
    let depth = match graph.depth(id) {
      Some(d) => d
      None => 0
    }
    out.push(
      {
        node_id: id,
        body_len: body,
        share: share,
        child_count: child_count,
        depth: depth,
      },
    )
    i += 1
  }
  out
}

/// 最大深度（根为 0；空图为 0）。
pub fn max_depth(store : @model.NodeStore, graph : @model.Graph) -> Int {
  ignore(store)
  let mut max_d = 0
  let mut i = 0
  while i < graph.node_count() {
    match graph.depth(graph.order_at(i)) {
      Some(d) => {
        if d > max_d {
          max_d = d
        }
      }
      None => ()
    }
    i += 1
  }
  max_d
}
