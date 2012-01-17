require 'rubygems'
require 'bundler'
require 'pathname'
require 'sinatra/json'
require 'sinatra/reloader'

Bundler.require

require 'stylus/tilt'
require 'stylus/import_processor'

unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
  abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
end

module AssetHelpers
  def asset_path(source)
    "/assets/" + settings.sprockets.find_asset(source).digest_path
  end
end

class App < Sinatra::Base
  set :root, Pathname(File.expand_path('../', __FILE__))
  set :raise_errors, true
  set :show_exceptions, true
  set :sprockets, Sprockets::Environment.new(root)
  set :precompile, [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
  set :facebook_scope, "publish_stream"
  
  enable :sessions

  configure do
    sprockets.append_path(root.join("assets", "javascripts"))
    sprockets.append_path(root.join("assets", "stylesheets"))
    
    sprockets.append_path(root.join("vendor", "assets", "javascripts"))
    sprockets.append_path(root.join("vendor", "assets", "stylesheets"))
    
    sprockets.register_engine '.styl', Tilt::StylusTemplate
    sprockets.register_preprocessor 'text/css', Stylus::ImportProcessor

    sprockets.context_class.instance_eval do
      include AssetHelpers
    end
  end

  before do
    # HTTPS redirect
    if settings.environment == :production && request.scheme != "https"
      redirect "https://#{request.env['HTTP_HOST']}"
    end
  end
  
  helpers Sinatra::JSON

  helpers do
    include AssetHelpers
    
    def url(path)
      base = "#{request.scheme}://#{request.env['HTTP_HOST']}"
      base + path
    end

    def post_to_wall_url
      "https://www.facebook.com/dialog/feed?redirect_uri=#{url("/close")}&display=popup&app_id=#{@app.id}";
    end

    def send_to_friends_url
      "https://www.facebook.com/dialog/send?redirect_uri=#{url("/close")}&display=popup&app_id=#{@app.id}&link=#{url('/')}";
    end

    def authenticator
      @authenticator ||= Mogli::Authenticator.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], url("/auth/facebook/callback"))
    end

    def first_column(item, collection)
      return ' class="first-column"' if collection.index(item) % 4 == 0
    end
    
    def client
      redirect "/auth/facebook" unless session[:at]
      @client ||= Mogli::Client.new(session[:at])      
    end
    
    def app
      @app ||= Mogli::Application.find(ENV["FACEBOOK_APP_ID"], client)
    end
    
    def user
      @user ||= Mogli::User.find("me", client)
    end
  end

  # the facebook session expired! reset ours and restart the process
  error(Mogli::Client::HTTPException) do
    session[:at] = nil
    redirect "/auth/facebook"
  end

  get "/" do

    # access friends, photos and likes directly through the user instance

    # for other data you can always run fql
    # @friends_using_app = @client.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")

    erb :index
  end
  
  get "/friends" do
    friends = user.friends.map {|friend|
      {
        name: friend.name.to_s,
        id:   friend.id,
        url:  "http://www.facebook.com/#{friend.id}",
        avatar_url: "https://graph.facebook.com/#{friend.id}/picture?type=square"
      }
    }
    json friends
  end
  
  post "/team" do
    "ok"
  end

  # used by Canvas apps - redirect the POST to be a regular GET
  post "/" do
    redirect "/"
  end

  # used to close the browser window opened to post to wall/send to friends
  get "/close" do
    "<body onload='window.close();'/>"
  end

  get "/auth/facebook" do
    session[:at] = nil
    redirect authenticator.authorize_url(:scope => settings.facebook_scope, :display => 'page')
  end

  get "/auth/facebook/callback" do
    client = Mogli::Client.create_from_code_and_authenticator(params[:code], authenticator)
    session[:at] = client.access_token
    redirect "/"
  end
  
  get "/logout" do
    session.clear
    "Logged out"
  end
end