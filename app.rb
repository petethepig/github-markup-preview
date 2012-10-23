require ::File.dirname(__FILE__) +'/lib/preview/renderer'

require 'sinatra'
require 'sinatra/assetpack'

module Preview
  class App < Sinatra::Base
    register Sinatra::AssetPack

    assets {
      js :application, '/assets/application.js', [
          '/js/vendor/*','/js/application.js'
        ]

      css :application, '/assets/application.css', [
        '/css/vendor/*','/css/*'
      ]
    }

    get '/' do
      @example_url = params[:example_url] || 'example.md';
      @markup_type = params[:markup_type] || 'md';
      erb :index
    end


    post '/render' do
      type = params[:type] || :gfm
      return Renderer.render(type.to_sym, params[:markup])
    end

  end
end