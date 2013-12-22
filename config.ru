require ::File.dirname(__FILE__) + '/app'

set :run, false
set :environment, :production

run Preview::App
