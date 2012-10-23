
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
end