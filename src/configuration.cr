module OrgMobParser
  private class Configuration
    getter todo_keywords : Array(String)

    def initialize(todo_keywords : Array(String) = ["TODO", "[ ]"], done_keywords : Array(String) = ["DONE", "[X]"])
      @todo_keywords = todo_keywords
      @done_keywords = done_keywords
    end

    def todo_keywords=(new_todo_keywords)
      @todo_keywords = format_keywords(new_todo_keywords).reverse
    end

    def done_keywords=(new_done_keywords)
      @done_keywords = format_keywords(new_done_keywords)
    end

    def keywords
      (@todo_keywords + @done_keywords).join("|")
    end

    private def format_keywords(todo_keywords)
      return todo_keywords.map { |keyword| Regex.escape(keyword) }
    end
  end
end
