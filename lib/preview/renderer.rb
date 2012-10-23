require ::File.dirname(__FILE__)+'/wordpress_readme_parser'

require 'gollum'
require 'yaml'

module Preview
  class Renderer

    def self.types
      @@types
    end
    @@types = YAML::load(File.open("config/markups.yml"))

    @@wiki = Gollum::Wiki.new('.', {})
    
    def self.render type, data
      if(type == :gfm)
        page = @@wiki.preview_page("no-file", data, :markdown)
        page.formatted_data
      elsif(type == :wp)
        data = WordpressReadmeParser.prerender data
        GitHub::Markup.render("noname.md", data || '')
      else
        filename = "no-file.#{@@types[type.to_s]['ext']}"
        GitHub::Markup.render(filename, data)
      end
    end

  end
end