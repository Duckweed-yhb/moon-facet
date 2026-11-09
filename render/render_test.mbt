/// render 包单测：缩进、字数标注、多根顺序。

test "ascii: nested tree with body lengths" {
  let s = @model.NodeStore::new()
  let (s1, a) = s.add("A", 30)
  let (s2, b) = s1.add("B", 10)
  let (s3, c) = s2.add("C", 60)
  let g = @model.Graph::new(0, "g")
  let _ = g.append(a, -1)
  let _ = g.append(b, a)
  let _ = g.append(c, a)
  assert_eq(@render.ascii_tree(s3, g), "A [30]\n  B [10]\n  C [60]\n")
}

test "ascii: multiple roots render in append order" {
  let s = @model.NodeStore::new()
  let (s1, a) = s.add("A", 1)
  let (s2, b) = s1.add("B", 2)
  let g = @model.Graph::new(0, "g")
  let _ = g.append(a, -1)
  let _ = g.append(b, -1)
  assert_eq(@render.ascii_tree(s2, g), "A [1]\nB [2]\n")
}

test "ascii: empty graph gives empty string" {
  let s = @model.NodeStore::new()
  let g = @model.Graph::new(0, "empty")
  assert_eq(@render.ascii_tree(s, g), "")
}
