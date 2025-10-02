local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
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

  -- mp: minipage helper
  s("mp", {
    t("\\begin{minipage}{"),
    i(1, "0.5\\textwidth"),
    t("}\n\t"),
    i(0),
    t("\n\\end{minipage}"),
  }),
}
