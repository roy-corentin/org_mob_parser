module OrgMob
  TITLE_REGEX = /^\*+\s(.*)/im
  LIST_REGEX  = /^(-|\+|[0-9]\.|[0-9]\))\s(.*)/im

  REGEXS = [TITLE_REGEX]
end
