/// moon-facet 示例：把一段 Markdown 的书结构展开成树，打印字数与占比。
///
/// 运行：
///   moon run examples/demo --target native

/// 用标题级别把扁平的分节序列还原成树。
/// parents[level] 记录当前层级最近一个节点，跨级标题回溯到最近的浅层父节点。
fn build_tree(
  secs : Array[@parse.Section]
) -> (@model.NodeStore, @model.Graph) {
  let mut store = @model.NodeStore::new()
  let graph = @model.Graph::new(0, "demo-book")
  let parents : Array[Int] = [-1, -1, -1, -1, -1, -1, -1]
  for sec in secs {
    let lv = sec.level()
    let mut parent = -1
    if lv > 1 {
      let mut k = lv - 1
      while k >= 1 {
        if parents[k] != -1 {
          parent = parents[k]
          break
        }
        k -= 1
      }
    }
    let (next_store, id) = store.add(sec.title(), sec.body_len())
    store = next_store
    let _ = graph.append(id, parent)
    parents[lv] = id
    let mut j = lv + 1
    while j < 7 {
      parents[j] = -1
      j += 1
    }
  }
  (store, graph)
}

fn main {
  let md = "# 第一章 总论\n" +
    "本书讨论结构分析的基本问题，全文约四百字。\n" +
    "## 1.1 为什么需要结构\n" +
    "线性阅读容易丢失全局，结构视图先给出骨架。\n" +
    "## 1.2 结构分析的边界\n" +
    "只处理可度量的层级，不猜测语义。\n" +
    "# 第二章 方法\n" +
    "介绍节点池、图与对齐三件事。\n" +
    "## 2.1 节点池\n" +
    "节点属于池，不属于图。\n" +
    "### 2.1.1 共享\n" +
    "同一节点可以被多张图引用。\n" +
    "## 2.2 对齐\n" +
    "对齐表回答同一节点在每张图里的位置。\n" +
    "# 第三章 实践\n" +
    "以一本书和一个目标为例。\n"
  let secs = @parse.parse_sections(md)
  let (store, graph) = build_tree(secs)
  println(@render.ascii_tree(store, graph))
  println("total body chars: " + @metric.total_body_len(store, graph).to_string())
  println("max depth: " + @metric.max_depth(store, graph).to_string())
  let m = @metric.metrics(store, graph)
  println("nodes: " + m.length().to_string())
  for item in m {
    let title = match store.get(item.node_id()) {
      Some(n) => n.title()
      None => "?"
    }
    println(
      "  " + title + " share=" +
      (item.share() * 100.0).to_string() + "% depth=" + item.depth().to_string(),
    )
  }
}
