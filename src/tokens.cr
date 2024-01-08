module OrgMob
  HEADER_REGEX    = /^(?<stars>\*+)\s(?<title>.*)/i
  LIST_REGEX      = /^(?<bullet>-|\+|([0-9]|[a-z])(\.|\)))\s(?<item>.*)/i
  CODE_REGEX      = /^#\+(begin|end)_src(.*)/i
  QUOTE_REGEX     = /^#\+(begin|end)_quote(.*)/i
  KEYWORD_REGEX   = /^#\+(?<key>\w+):(?<value>.+)/i
  PROPERTY_REGEX  = /^:(?<property>\w+):\s*(?<value>.*)/i
  NEW_LINE_REGEX  = /^$/i
  PARAGRAPH_REGEX = /(.)*/i

  TEXT_WITH_BOLD_CONTENT      = /(?<before>.*?)\*(?<inside>[^*]+)\*(?<after>.*)/
  TEXT_WITH_ITALIC_CONTENT    = /(?<before>.*?)\/(?<inside>[^\/]+)\/(?<after>.*)/
  TEXT_WITH_UNDERLINE_CONTENT = /(?<before>.*?)_(?<inside>[^_]+)_(?<after>.*)/
  TEXT_WITH_VERBATIM_CONTENT  = /(?<before>.*?)=(?<inside>[^=]+)=(?<after>.*)/
  TEXT_WITH_CODE_CONTENT      = /(?<before>.*?)~(?<inside>[^~]+)~(?<after>.*)/
  TEXT_WITH_STRIKE_CONTENT    = /(?<before>.*?)\+(?<inside>[^\+]+)\+(?<after>.*)/

  TOKENS = [
    {type: :header, regex: HEADER_REGEX},
    {type: :list, regex: LIST_REGEX},
    {type: :code, regex: CODE_REGEX},
    {type: :quote, regex: QUOTE_REGEX},
    {type: :keyword, regex: KEYWORD_REGEX},
    {type: :property, regex: PROPERTY_REGEX},
    {type: :new_line, regex: NEW_LINE_REGEX},
    {type: :paragraph, regex: PARAGRAPH_REGEX},
  ]
end
