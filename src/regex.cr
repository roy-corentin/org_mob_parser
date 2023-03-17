module OrgMob
  TITLE_REGEX     = /^\*+\s(?<title>.*)/im
  LIST_REGEX      = /^(-|\+|([0-9]|[a-z]|[A-Z])(\.|\)))\s(?<item>.*)/im
  CODE_REGEX      = /^#\+(begin|end)_src(.*)/im
  QUOTE_REGEX     = /^#\+(begin|end)_quote(.*)/im
  PROPERTY_REGEX  = /^#\+(?<keyword>\w+):(?<value>.*)/im
  NEW_LINE_REGEX  = /^$/im
  PARAGRAPH_REGEX = /(.)*/im

  REGEXS = [
    {type: :title, regex: TITLE_REGEX},
    {type: :list, regex: LIST_REGEX},
    {type: :code, regex: CODE_REGEX},
    {type: :quote, regex: QUOTE_REGEX},
    {type: :property, regex: PROPERTY_REGEX},
    {type: :new_line, regex: NEW_LINE_REGEX},
    {type: :paragraph, regex: PARAGRAPH_REGEX},
  ]
end
