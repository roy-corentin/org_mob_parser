module OrgMob
  TITLE_REGEX = /^\*+\s(.*)/im
  LIST_REGEX  = /^(-|\+|([0-9]|[a-z]|[A-Z])(\.|\)))\s(.*)/im

  REGEXS = [TITLE_REGEX, LIST_REGEX]
end
