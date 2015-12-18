require "./html"
require "http/client"

url = "http://robacarp.com"

searcher = Html::LinkSearcher.new HTTP::Client.get(url).body
searcher.search
