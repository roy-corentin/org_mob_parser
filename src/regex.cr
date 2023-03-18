module OrgMob
  TITLE_REGEX     = /^\*+\s(?<title>.*)/i
  LIST_REGEX      = /^(-|\+|([0-9]|[a-z])(\.|\)))\s(?<item>.*)/i
  CODE_REGEX      = /^#\+(begin|end)_src(.*)/i
  QUOTE_REGEX     = /^#\+(begin|end)_quote(.*)/i
  KEYWORD_REGEX   = /^#\+(?<keyword>\w+):(?<value>.+)/i
  PROPERTY_REGEX  = /^:(?<property>\w+):\s*(?<value>.*)/i
  NEW_LINE_REGEX  = /^$/i
  PARAGRAPH_REGEX = /(.)*/i

  REGEXS = [
    {type: :title, regex: TITLE_REGEX},
    {type: :list, regex: LIST_REGEX},
    {type: :code, regex: CODE_REGEX},
    {type: :quote, regex: QUOTE_REGEX},
    {type: :keyword, regex: KEYWORD_REGEX},
    {type: :property, regex: PROPERTY_REGEX},
    {type: :new_line, regex: NEW_LINE_REGEX},
    {type: :paragraph, regex: PARAGRAPH_REGEX},
  ]
end
