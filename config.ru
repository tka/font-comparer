#\ -p 4000

require 'rubygems'
require 'bundler'
require 'open-uri'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'serve'
require 'serve/rack'
require "rack/coffee"

# The project root directory
root = ::File.dirname(__FILE__)

# Compile Sass on the fly with the Sass plugin. Some production environments
# don't allow you to write to the file system on the fly (like Heroku).
# Remove this conditional if you want to compile Sass in production.
require 'sass'
require 'sass/plugin/rack'
require 'compass'

Compass.add_project_configuration( Compass.detect_configuration_file(root) )
Compass.configure_sass_plugin!
use Rack::Deflater
use Sass::Plugin::Rack  # Sass Middleware

# Other Rack Middleware
use Rack::ShowStatus      # Nice looking 404s and other messages
use Rack::ShowExceptions  # Nice looking errors

use Rack::Session::Cookie

require "warden"
class FailLoginApp
  def self.call(env)

    [200, { "Content-Type" => "text/html" }, [<<EOL
      <html>
      <body>
      <h1>Login</h1>
      <form action="/" method="post">
    username:<input type="text" name="username">

    password:<input type="password" name="password">
    <input type="submit">
    </form>
    </body>
    </html>
EOL
    ]]
  end
end

class CheckLogin

  def initialize(app, opts={})
    @app=app
    @opts=opts
  end 

  def call(env)
    request = Rack::Request.new(env) 

    env['warden'].logout if request.params["logout"]
    env['warden'].authenticate!

    @app.call(env)
  end
end

Warden::Strategies.add(:password) do
  def valid?
    params["username"] || params["password"]
  end
  
  def authenticate!
    #if params["username"] == "food" && params["password"] == "baokaka"  
    if params["password"] == "fontfontfont"  
      success!({})
    else
      fail!("Could not log in") 
    end
  end
end

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = FailLoginApp
end

use CheckLogin

#use Rack::Auth::Basic, "Snack cabinet" do |username, password|
#  password == 'baokaka'
#end

run Rack::Cascade.new([
                      Serve::RackAdapter.new( root ),
                      Rack::Directory.new( root )
])
