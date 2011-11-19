require 'json'
require 'compass'
require 'sinatra/base'
require "sinatra/namespace"
require 'slim'
require 'sass'

require 'model'

class Vamma < Sinatra::Base
  get('/login') { halt "Access denied, please <a href='/login'>login</a>." }
end


class MyApp < Sinatra::Base
  use Vamma
  register Sinatra::Namespace
  configure do
    set :slim, {:pretty => true} #, :sections => true}
    #enable :inline_templates
    enable :method_override
    Compass.add_project_configuration(File.join(root, 'config', 'compass.config'))
  end

  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
  end

  get('/styles.css'){ content_type 'text/css', :charset => 'utf-8' ; scss :styles }


  namespace %r{^/(?<id>[\d]+)(?:/.*)?} do |id|

    before do
      id=params["id"]
      halt(404, "Nothing found with id #{id}") unless @post = Post[id]
    end

    get('/edit/?') { @post.to_form("/#{@post.id}", "put") }

    get('/?')      { slim :show }

    put('/?') do
      if @post.update_fields(params["model"].symbolize_keys, [:title, :contents])
        redirect(to("/#{@post.id}"))
      else
        @post.to_form("/#{@post.id}", "put")
      end
    end

    delete('/?') do
      @post.destroy
      redirect to("/")
    end

  end

  post('/') do
    @post=Post.new
    if @post.update_fields(params["model"].symbolize_keys, [:title, :contents]) 
      redirect(to("/#{@post.id}"))
    else
      @post.to_form("/#{@post.id}", "put")
    end
  end

  get('/') do
    @posts = Post.all
    slim :index
  end

end

