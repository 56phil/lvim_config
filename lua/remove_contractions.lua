local M = {}

-- Contractions (after normalizing apostrophes to straight quote)
local contractions = {
  ["[Cc]an't"] = function(m)
    return m:sub(1, 1):match("%u") and "Cannot" or "cannot"
  end,
  ["[Ww]on't"] = function(m)
    return m:sub(1, 1):match("%u") and "Will not" or "will not"
  end,
  ["[Dd]on't"] = function(m)
    return m:sub(1, 1):match("%u") and "Do not" or "do not"
  end,
  ["[Dd]oesn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Does not" or "does not"
  end,
  ["[Dd]idn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Did not" or "did not"
  end,
  ["[Ii]sn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Is not" or "is not"
  end,
  ["[Aa]ren't"] = function(m)
    return m:sub(1, 1):match("%u") and "Are not" or "are not"
  end,
  ["[Ww]asn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Was not" or "was not"
  end,
  ["[Ww]eren't"] = function(m)
    return m:sub(1, 1):match("%u") and "Were not" or "were not"
  end,
  ["[Hh]aven't"] = function(m)
    return m:sub(1, 1):match("%u") and "Have not" or "have not"
  end,
  ["[Hh]asn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Has not" or "has not"
  end,
  ["[Hh]adn't"] = function(m)
    return m:sub(1, 1):match("%u") and "Had not" or "had not"
  end,
  ["[Ii]'m"] = function(_)
    return "I am"
  end,
  ["[Yy]ou're"] = function(m)
    return m:sub(1, 1):match("%u") and "You are" or "you are"
  end,
  ["[Tt]hey're"] = function(m)
    return m:sub(1, 1):match("%u") and "They are" or "they are"
  end,
  ["[Ww]e're"] = function(m)
    return m:sub(1, 1):match("%u") and "We are" or "we are"
  end,
  ["[Hh]e's"] = function(m)
    return m:sub(1, 1):match("%u") and "He is" or "he is"
  end,
  ["[Ss]he's"] = function(m)
    return m:sub(1, 1):match("%u") and "She is" or "she is"
  end,
  ["[Ii]t's"] = function(m)
    return m:sub(1, 1):match("%u") and "It is" or "it is"
  end,
  ["[Tt]hat's"] = function(m)
    return m:sub(1, 1):match("%u") and "That is" or "that is"
  end,
  ["[Tt]here's"] = function(m)
    return m:sub(1, 1):match("%u") and "There is" or "there is"
  end,
  ["[Ww]ho's"] = function(m)
    return m:sub(1, 1):match("%u") and "Who is" or "who is"
  end,
  ["[Ww]hat's"] = function(m)
    return m:sub(1, 1):match("%u") and "What is" or "what is"
  end,
  ["[Ll]et's"] = function(m)
    return m:sub(1, 1):match("%u") and "Let us" or "let us"
  end,
}

-- Normalize curly quotes to straight ASCII apostrophe
local function normalize_apostrophes(line)
  -- Normalize curly quotes to straight ones
  line = line
    :gsub("[‘’‛´`ʼʾʿˊˋ]", "'") -- smart apostrophes to '
    :gsub("[“”]", '"') -- smart double quotes to "

  -- Collapse quote clusters
  line = line:gsub("['\"]+", "'")

  -- Fix: word ' → word'
  line = line:gsub("(%w) +'([^%w])", "%1'%2")
  line = line:gsub("(%w) +'(%w)", "%1'%2")

  -- Ensure spacing after quote before a word
  line = line:gsub("'(%w)", "' %1")

  return line
end

local function remove_unprintables(line)
  -- Define a conservative whitelist pattern:
  -- Keep: basic Latin, Latin-1, typographic punctuation, en/em dash
  return line:gsub(
    "[^\x20-\x7E" -- printable ASCII
      .. "\xA0-\xFF" -- Latin-1 supplement
      .. "\u{2018}-\u{201F}" -- smart quotes, narrow no-break, etc.
      .. "\u{2000}-\u{200D}" -- thin space, zero-width space
      .. "\u{2020}-\u{2023}" -- dagger, bullet
      .. "\u{2030}-\u{203E}" -- per mille, quotes, overline
      .. "\u{2044}" -- fraction slash
      .. "\u{20AC}" -- Euro
      .. "\u{2212}" -- minus sign
      .. "\u{00B0}" -- degree
      .. "]",
    " "
  )
end

-- Process a single buffer
local function process_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false, 0, {}
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  if not vim.bo[bufnr].modifiable then
    return false, 0, {}
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if not name:match("%.tex$") then
    return false, 0, {}
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local count = 0
  local modified = false
  local unmatched = {}

  for i, line in ipairs(lines) do
    local original = line
    line = normalize_apostrophes(line)
    line = remove_unprintables(line)
    for pattern, repl in pairs(contractions) do
      local n = 0
      line, n = line:gsub(pattern, repl)
      if n == 0 and original:match(pattern) then
        unmatched[pattern] = true
      else
        count = count + n
        modified = true
      end
    end
    lines[i] = line
  end

  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end

  local unmatched_list = vim.tbl_keys(unmatched)
  return modified, count, unmatched_list
end

-- Main command
function M.remove_contractions(opts)
  local target = opts.args or ""
  local total_buffers = 0
  local total_replacements = 0
  local all_unmatched = {}

  if target == "all" then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      local changed, count, unmatched = process_buffer(bufnr)
      if changed then
        total_buffers = total_buffers + 1
        total_replacements = total_replacements + count
      end
      for _, pat in ipairs(unmatched) do
        all_unmatched[pat] = true
      end
    end
    print(string.format("✔ Removed %d contraction(s) across %d buffer(s).", total_replacements, total_buffers))
  else
    local changed, count, unmatched = process_buffer(vim.api.nvim_get_current_buf())
    if changed then
      print(string.format("✔ Removed %d contraction(s) in current buffer.", count))
    else
      print("No contractions found in current buffer.")
    end
    for _, pat in ipairs(unmatched) do
      all_unmatched[pat] = true
    end
  end

  local unmatched_list = vim.tbl_keys(all_unmatched)
  if #unmatched_list > 0 then
    table.sort(unmatched_list)
    print("⚠️ Patterns matched but not replaced:")
    for _, pat in ipairs(unmatched_list) do
      print("  " .. pat)
    end
  end
end

return M
