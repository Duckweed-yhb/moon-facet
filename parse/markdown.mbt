// parse/markdown.mbt — 从 Markdown 文本抽出标题与每节字数。
//
// 第一版只认 ATX 标题（`#` 到 `######`），要求 `#` 后跟空格或行尾。
// 字数口径：非空白字符数（空格、制表符、回车不计）。不做语义、不做分词。

/// 一节：标题级别、标题文本、本节正文的非空白字符数（不含子节）。
pub struct Section {
  level : Int
  title : String
  body_len : Int
}

pub fn Section::level(self : Section) -> Int {
  self.level
}

pub fn Section::title(self : Section) -> String {
  self.title
}

pub fn Section::body_len(self : Section) -> Int {
  self.body_len
}

fn chars_of(s : String) -> Array[Char] {
  let out : Array[Char] = []
  for c in s {
    out.push(c)
  }
  out
}

/// 标题级别：前导 `#` 的数量，1–6；不是标题返回 None。
pub fn heading_level(line : String) -> Int? {
  let chars = chars_of(line)
  let mut i = 0
  while i < chars.length() && chars[i] == '#' {
    i += 1
  }
  if i == 0 || i > 6 {
    return None
  }
  if i < chars.length() && chars[i] != ' ' && chars[i] != '\t' {
    return None
  }
  Some(i)
}

/// 标题文本：去掉前导 `#` 与空白，去掉行尾 `\r`。
pub fn heading_text(line : String) -> String {
  let chars = chars_of(line)
  let mut i = 0
  while i < chars.length() && chars[i] == '#' {
    i += 1
  }
  while i < chars.length() && (chars[i] == ' ' || chars[i] == '\t') {
    i += 1
  }
  let mut out = ""
  while i < chars.length() {
    let c = chars[i]
    if c != '\r' {
      out = out + c.to_string()
    }
    i += 1
  }
  out
}

/// 非空白字符数。
pub fn count_nonspace(line : String) -> Int {
  let mut n = 0
  for c in line {
    if c != ' ' && c != '\t' && c != '\r' {
      n += 1
    }
  }
  n
}

/// 按行解析，返回标题序列；标题之前的正文不计入任何节（写在标题外的引言，
/// 第一版直接忽略，由调用方决定是否单独处理）。
pub fn parse_sections(text : String) -> Array[Section] {
  let out : Array[Section] = []
  let mut cur_level = 0
  let mut cur_title = ""
  let mut cur_len = 0
  let mut has_cur = false
  for view in text.split("\n") {
    let line = view.to_owned()
    match heading_level(line) {
      Some(lv) => {
        if has_cur {
          out.push({ level: cur_level, title: cur_title, body_len: cur_len })
        }
        cur_level = lv
        cur_title = heading_text(line)
        cur_len = 0
        has_cur = true
      }
      None => {
        if has_cur {
          cur_len += count_nonspace(line)
        }
      }
    }
  }
  if has_cur {
    out.push({ level: cur_level, title: cur_title, body_len: cur_len })
  }
  out
}
