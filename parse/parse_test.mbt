/// parse 包单测：标题识别、层级、字数口径、空输入。

test "heading_level: 1 to 6 hashes" {
  assert_eq(@parse.heading_level("# a"), Some(1))
  assert_eq(@parse.heading_level("### abc"), Some(3))
  assert_eq(@parse.heading_level("###### x"), Some(6))
}

test "heading_level: rejects non headings" {
  assert_eq(@parse.heading_level("####### seven"), None)
  assert_eq(@parse.heading_level("#no-space"), None)
  assert_eq(@parse.heading_level("plain text"), None)
  assert_eq(@parse.heading_level(""), None)
}

test "heading_text: strips hashes and spaces" {
  assert_eq(@parse.heading_text("## 项目简介"), "项目简介")
  assert_eq(@parse.heading_text("#  A  B "), "A  B ")
}

test "count_nonspace: ignores spaces and tabs" {
  assert_eq(@parse.count_nonspace("aa bb"), 4)
  assert_eq(@parse.count_nonspace("  \t"), 0)
}

test "parse_sections: builds sections with body length" {
  let text = "# A\naa bb\n## B\nccc\n# C\n"
  let secs = @parse.parse_sections(text)
  assert_eq(secs.length(), 3)
  assert_eq(secs[0].level(), 1)
  assert_eq(secs[0].title(), "A")
  assert_eq(secs[0].body_len(), 4)
  assert_eq(secs[1].level(), 2)
  assert_eq(secs[1].title(), "B")
  assert_eq(secs[1].body_len(), 3)
  assert_eq(secs[2].title(), "C")
  assert_eq(secs[2].body_len(), 0)
}

test "parse_sections: text before first heading is ignored" {
  let secs = @parse.parse_sections("intro line\n# A\nx")
  assert_eq(secs.length(), 1)
  assert_eq(secs[0].body_len(), 1)
}

test "parse_sections: empty input yields no sections" {
  assert_eq(@parse.parse_sections("").length(), 0)
}
