module OrgMobParser
  class Exception < ::Exception
    getter json_content : String

    def initialize(message)
      @json_content = {error: message}.to_json
    end
  end
end
