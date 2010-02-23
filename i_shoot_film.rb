require 'sinatra'
require 'flickraw'
require 'haml'

# Sinatra !!

configure do
  # Set API Key
  FlickRaw.api_key = '2b5c553e493e6c9729509bf699ffbfc9'
  
  # use HTML5 when generating HTML
  set :haml, :format => :html5

  # set the last mod time to now, when the app starts up. Updated via /update/now
  @@last_mod_time = Time.now
  
  # grab my user id
  @@user_id = flickr.people.findByUsername(:username => 'funkaoshi').id
  
  # for google analytics
  @@analytics_token = 'UA-2675737-9'
end

before do
  unless request.path_info =~ /update/
    expires 300, :public, :must_revalidate  # always cache for 5 minutes ...
    last_modified(@@last_mod_time)          # ... and rely on 304 query after that
  end
end

helpers do
  def get_film_rolls(get_bw=false)
    search_params = { :user_id => @user_id,
                      :machine_tags => 'funkaoshi:roll=',
                      :extras => "machine_tags, tags, url_sq",
                      :per_page => '500',
                      :page => '1' }  
    photos = flickr.photos.search(search_params)

    bw_film_rolls, colour_film_rolls = {}, {}
    photos.each do |photo|
      roll_no = photo.machine_tags.match(/funkaoshi:roll=([0-9]*)/)[1].to_i
      roll_map = photo.tags.match(/byobw/) ? bw_film_rolls : colour_film_rolls
      if !roll_map.has_key?(roll_no)
        roll_map[roll_no] = []
      end
      roll_map[roll_no] << photo
    end
    @bw_film_rolls = bw_film_rolls.to_a.sort
    @colour_film_rolls = colour_film_rolls.to_a.sort
  end
  
  def get_film_dev_info(photo)
    if photo.machine_tags =~ /filmdev:recipe=([0-9]+)/
      "<span class='small'><a href='http://filmdev.org/recipe/show/#{$~[1]}'>development receipe #{$~[1]}</a></span>"
    end
  end
end

# Routes

get '/' do
  get_film_rolls  
  haml :index
end

# Lame web-cache thing which I don't think really works.

get '/update/now' do
  @@last_mod_time = Time.now
end

get '/update/show' do
  "Last-Update: #{@@last_mod_time}"
end

# Error Handlers in Production

not_found do
  haml :wtf
end

error do
  haml :wtf
end
