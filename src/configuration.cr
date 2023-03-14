module OrgMob
  private class Configuration
    getter todo_keywords : Array(String)

    def initialize(todo_keywords : Array(String) = ["TODO"])
      @todo_keywords = todo_keywords
    end

    def todo_keywords=(new_todo_keywords)
      @todo_keywords = format_todo_keywords(new_todo_keywords)
    end

    private def format_todo_keywords(todo_keywords)
      return todo_keywords.map { |keyword| Regex.escape(keyword) }
    end
  end
end
