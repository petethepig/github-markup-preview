require 'github/markup'
class HomeController < ApplicationController
  @@types = {:rdoc=>'rdoc', :markdown => 'md', :textile=>'textile', :mediawiki=>'wiki', :org=>'org', :creole=>'creole'}
  
  def index
    @markup = "" #File.read("README.rdoc")
    @preview = "" #render_markup :rdoc, @markup
    @types = @@types.keys
  end

  def renderr
    type = params[:type] || 'rdoc'
    render :text => render_markup(type.to_sym, params[:markup])
  end

  private
    def render_markup type, data
      filename = "no-file.#{@@types[type]}"
      logger.info filename
      GitHub::Markup.render(filename, data)
    end
end
