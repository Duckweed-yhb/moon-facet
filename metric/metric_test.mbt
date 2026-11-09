/// metric 包单测：总数、占比、深度、空图。

fn approx_eq(x : Double, y : Double) -> Bool {
  (x - y).abs() < 0.000000001
}

test "metrics: share, children and depth" {
  let s = @model.NodeStore::new()
  let (s1, a) = s.add("A", 30)
  let (s2, b) = s1.add("B", 10)
  let (s3, c) = s2.add("C", 60)
  let g = @model.Graph::new(0, "g")
  let _ = g.append(a, -1)
  let _ = g.append(b, a)
  let _ = g.append(c, a)
  assert_eq(@metric.total_body_len(s3, g), 100)
  let m = @metric.metrics(s3, g)
  assert_eq(m.length(), 3)
  assert_eq(m[0].body_len(), 30)
  assert_true(approx_eq(m[0].share(), 0.3))
  assert_eq(m[0].child_count(), 2)
  assert_eq(m[0].depth(), 0)
  assert_eq(m[1].depth(), 1)
  assert_true(approx_eq(m[2].share(), 0.6))
}

test "metrics: empty graph is safe" {
  let s = @model.NodeStore::new()
  let g = @model.Graph::new(0, "empty")
  assert_eq(@metric.total_body_len(s, g), 0)
  assert_eq(@metric.metrics(s, g).length(), 0)
  assert_eq(@metric.max_depth(s, g), 0)
}

test "max_depth: nested chain" {
  let s = @model.NodeStore::new()
  let (s1, a) = s.add("A", 1)
  let (s2, b) = s1.add("B", 1)
  let (_s3, c) = s2.add("C", 1)
  let g = @model.Graph::new(0, "chain")
  let _ = g.append(a, -1)
  let _ = g.append(b, a)
  let _ = g.append(c, b)
  assert_eq(@metric.max_depth(_s3, g), 2)
}
