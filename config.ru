require ::File.dirname(__FILE__) + '/app'

require 'rubypython'
RubyPython.start(:python_exe => "python2.6")


set :run, false
set :environment, :production

run Preview::App
