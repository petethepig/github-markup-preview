require 'github/markup'
module Gollum
  class Wiki
    def preview_page(name, data, format)
      page = @page_class.new(self)
      ext  = @page_class.format_to_ext(format.to_sym)
      name = @page_class.cname(name) + '.' + ext
      blob = OpenStruct.new(:name => name, :data => data)
      page.populate(blob)
      page.version = @access.commit('master')
      page
    end
  end
end



class Renderer

	def self.types
  	@@types
  end
  @@types = YAML::load(File.open("#{Rails.root}/config/markups.yml"))

  @@wiki = Gollum::Wiki.new('.', {})
  
  def self.render type, data
    if(type != :gfm)
      filename = "no-file.#{@@types[type.to_s]['ext']}"
      GitHub::Markup.render(filename, data)
    else
      page = @@wiki.preview_page("no-file", data, :markdown)
      page.formatted_data
    end
  end

end