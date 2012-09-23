require 'gollum'

module Preview
  class Renderer

    def self.types
      @@types
    end
    @@types = YAML::load(File.open("config/markups.yml"))

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
end


require 'sinatra'
require 'sinatra/assetpack'

module Preview
  class App < Sinatra::Base
    register Sinatra::AssetPack

    assets {
      js :application, './assets/application.js', [
          '/js/vendor/*','/js/application.js'
        ]

      css :application, './assets/application.css', [
        '/css/vendor/*','/css/*'
      ]
    }

    get '/' do
      #@markup = "" 
      #@preview = "" 
      #@types = []
      #Renderer.types.keys.each do |key|
      #  @types << [Renderer.types[key]['name'], key]
      #end
      erb :index
    end


    post '/render' do
      type = params[:type] || :gfm
      return Renderer.render(type.to_sym, params[:markup])
    end

  end
end