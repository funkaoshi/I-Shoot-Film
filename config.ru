require 'dreamhost.rb' # loads rubygems on Dreamhost.

require 'sinatra'
Sinatra::Base.set(:run, false)
Sinatra::Base.set(:env, :production);

require 'rack/cache'
use Rack::Cache,
    :verbose => true,
    :metastore => "file:cache/meta",
    :entitystore => "file:cache/body"

require 'i_shoot_film.rb'
run Sinatra::Application
