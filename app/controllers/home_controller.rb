require 'github/markup'
class HomeController < ApplicationController
  @@types = {:rdoc=>'rdoc', :markdown => 'md', :textile=>'textile', :mediawiki=>'wiki', :org=>'org', :creole=>'creole'}
  
  def index
    @markup = "" #File.read("README.rdoc")
    @content = "" #render_data :rdoc, @markup
    @types = @@types.keys
  end

  def renderr
    type = params[:type] || 'rdoc'
    render :text => render_data(type.to_sym, params[:content])
  end

  def readme
    render :text => File.read("README.rdoc")
  end

  private
    def render_data type, data
      filename = "no-file.#{@@types[type]}"
      logger.info filename
      GitHub::Markup.render(filename, data)
    end
end
