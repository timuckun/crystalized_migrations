module Html
  class LinkSearcher
    def initialize data : String
      @data = data
      @offset = 0
      @links = [] of Link
    end

    def search
      while find_link
      end
    end

    def find_link
      link_reg = /<a [^>]*href=("|')?([^ >"']+)("|')?[^>]*>/mi
      match = link_reg.match @data, @offset

      if match
        @links << build_link(match)
        @offset = match.end
        true
      else
        false
      end
    end

    def build_link match : Regex::MatchData
      Link.new url: match[2]
    end
  end
end
