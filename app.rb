require 'sinatra'
require 'sinatra/assetpack'

require 'yaml'
require 'github/markup'

module Preview

  class WordpressReadmeParser

    HEADERS = {
      'contributors'=>'Contributors',
      'donate_link'=>'Donate link',
      'tags'=>'Tags',
      'requires_at_least'=>'Requires at least',
      'tested_up_to'=>'Tested up to',
      'stable_tag'=>'Stable tag',
      'license'=>'License',
      'license_uri'=>'License URI'
    }

    def self.prerender data

      data = full_strip data

      headers_parsed=''

      regex = /(.*\=\=\=)$(.*?)^(\=\=.*)/m
      matches = data.match regex
      short_desc = ''
      
      if matches
        headers = matches[2]
        
        headers.each_line do |line|

          parts = line.split(':')
          header_name = HEADERS[parts[0].to_s.gsub(/\s/,'_').downcase]
          if(header_name)
            headers_parsed << "<strong>#{header_name}:</strong> #{parts[1,999].join(':')}<br>"
            short_desc = ''
          else
            short_desc << line+" " unless line.empty?
          end
        end


        data = matches[1]+"\n#{headers_parsed}\n\n\n#{short_desc}\n"+matches[3]
      end
      
      data.gsub! /^\=\=\=([^\=]*)\=\=\=$/, '#\1'
      data.gsub! /^\=\=([^\=]*)\=\=$/, '##\1'
      data.gsub! /^\=([^\=]*)\=$/, '###\1'
      data
    end

    protected
    def self.full_strip data
      tmp = ''
      data.each_line do |s|
        tmp << s.strip+"\n"
        s
      end
      tmp
    end
  end

  class Renderer
    def types
      @types ||= YAML::load(File.open("config/markups.yml"))
    end

    def render type, data
      if(type == :gfm)
        GitHub::Markdown.render_gfm(data)
      elsif(type == :wp)
        data = WordpressReadmeParser.prerender data
        GitHub::Markup.render("noname.markdown", data || '')
      else
        filename = "no-file.#{types[type.to_s]['ext']}"
        GitHub::Markup.render(filename, data)
      end
    end
  end

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

    renderer = Renderer.new

    post '/render' do
      type = params[:type] || :gfm
      return renderer.render(type.to_sym, params[:markup])
    end

  end
end