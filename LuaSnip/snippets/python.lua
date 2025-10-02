local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

-- All snippets in this file apply only to the "python" filetype
return {
  s("pyexec", {
    t({ "import sys", "print('Running with:', sys.executable)" }),
  }),
}
