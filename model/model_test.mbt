/// model 包单测：节点池、图的父子关系、深 qudu、对齐表。

test "store: add assigns increasing ids and keeps nodes" {
  let s = @model.NodeStore::new()
  let (s1, a) = s.add("A", 10)
  let (s2, b) = s1.add("B", 20)
  assert_eq(a, 0)
  assert_eq(b, 1)
  assert_eq(s2.len(), 2)
  match s2.get(1) {
    Some(n) => {
      assert_eq(n.title(), "B")
      assert_eq(n.body_len(), 20)
    }
    None => fail("node 1 should exist")
  }
  match s2.get(9) {
    None => ()
    Some(_) => fail("node 9 should not exist")
  }
}

test "graph: append builds parent links and children" {
  let g = @model.Graph::new(0, "book")
  match g.append(0, -1) {
    Ok(_) => ()
    Err(e) => fail(e.describe())
  }
  match g.append(1, 0) {
    Ok(_) => ()
    Err(e) => fail(e.describe())
  }
  match g.append(2, 0) {
    Ok(_) => ()
    Err(e) => fail(e.describe())
  }
  assert_eq(g.node_count(), 3)
  assert_eq(g.roots(), [0])
  assert_eq(g.children(0), [1, 2])
}

test "graph: duplicate node is rejected" {
  let g = @model.Graph::new(0, "book")
  let _ = g.append(0, -1)
  match g.append(0, -1) {
    Ok(_) => fail("expected NodeAlreadyInGraph")
    Err(@model.NodeAlreadyInGraph(0)) => ()
    Err(e) => fail(e.describe())
  }
}

test "graph: unknown parent is rejected" {
  let g = @model.Graph::new(0, "book")
  match g.append(1, 99) {
    Ok(_) => fail("expected UnknownParent")
    Err(@model.UnknownParent(99)) => ()
    Err(e) => fail(e.describe())
  }
}

test "graph: depth counts from root" {
  let g = @model.Graph::new(0, "book")
  let _ = g.append(0, -1)
  let _ = g.append(1, 0)
  let _ = g.append(2, 1)
  assert_eq(g.depth(0), Some(0))
  assert_eq(g.depth(1), Some(1))
  assert_eq(g.depth(2), Some(2))
  assert_eq(g.depth(9), None)
}

test "alignment:同一节点可以在两张图里各有一个位置" {
  let a0 = @model.Alignment::new()
  let a1 = a0.record(7, 0, 2)
  let a2 = a1.record(7, 1, 5)
  assert_eq(a2.locate(7, 0), Some(2))
  assert_eq(a2.locate(7, 1), Some(5))
  assert_eq(a2.graphs_of(7), [0, 1])
}

test "alignment: re-recording the same pair overwrites" {
  let a = @model.Alignment::new()
  let a1 = a.record(3, 0, 1)
  let a2 = a1.record(3, 0, 4)
  assert_eq(a2.locate(3, 0), Some(4))
  assert_eq(a2.graphs_of(3).length(), 1)
}
