require ::File.dirname(__FILE__)+'/wordpress_readme_parser'

require 'yaml'

require 'github/markup'

module Preview
  class Renderer

    def types
      @types ||= YAML::load(File.open("config/markups.yml"))
    end

    def render type, data
      if(type == :gfm)
        GitHub::Markup.render("noname.markdown", data || '')
      elsif(type == :wp)
        data = WordpressReadmeParser.prerender data
        GitHub::Markup.render("noname.markdown", data || '')
      else
        filename = "no-file.#{types[type.to_s]['ext']}"
        GitHub::Markup.render(filename, data)
      end
    end

  end
end