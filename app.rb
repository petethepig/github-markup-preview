require 'sinatra'
require 'sinatra/assetpack'

require 'github/markup'
require 'redcarpet/compat'

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
    TYPES = {
      markdown: {
        ext: "md", 
        name: "Simple Markdown"
      }, 
      wp: {
        ext: "wp", 
        name: "WordPress Flavored Readme"
      }, 
      rdoc: {
        ext: "rdoc", 
        name: "RDoc"
      }, 
      textile: {
        ext: "textile", 
        name: "Textile"
      }, 
      mediawiki: {
        ext: "wiki", 
        name: "MediaWiki"
      }, 
      gfm: {
        ext: "md", 
        name: "Github Flavored Markdown"
      }, 
      org: {
        ext: "org", 
        name: "Org"
      }, 
      creole: {
        ext: "creole", 
        name: "Creole"
      }
    }

    def render type, data
      data ||= ""
      case type
      when :gfm
        GitHub::Markdown.render_gfm(data)
      when :wp
        data = WordpressReadmeParser.prerender data
        RedcarpetCompat.new(data).to_html
      when :md
        RedcarpetCompat.new(data).to_html
      else
        filename = "no-file.#{TYPES[type.to_sym][:ext]}"
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