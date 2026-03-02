local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- rock-solid minipage
  s({ trig = "lmp", wordTrig = true, regTrig = false, priority = 2000, desc = "minipage block" }, {
    t("\\begin{minipage}{"),
    i(1, "0.5\\textwidth"),
    t("}"),
    t({ "", "  " }),
    i(0),
    t({ "", "\\end{minipage}" }),
  }),

  -- env: lists (+ figure/table for convenience)
  s("env", {
    t("\\begin{"),
    c(1, { t("enumerate"), t("itemize"), t("description"), t("list"), t("figure"), t("table") }),
    t("}\n"),
    f(function(args)
      local env = args[1][1]
      if env == "enumerate" or env == "itemize" then
        return "\t\\item "
      elseif env == "description" then
        return "\t\\item[] "
      else
        return "\t"
      end
    end, { 1 }),
    i(0),
    t("\n\\end{"),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t("}"),
  }),

  -- quick test snippet
  s("xx", { t("SNIP OK") }),
}
