require 'json'
require 'compass'
require 'sinatra/base'
require "sinatra/namespace"
require 'slim'
require 'sass'

require 'model'

class MyApp < Sinatra::Base
  register Sinatra::Namespace
  configure do
    set :slim, :pretty => true
    #enable :inline_templates
    enable :method_override
    Compass.add_project_configuration(File.join(root, 'config', 'compass.config'))
  end

  helpers do
    def render_each(template, collection, as=:item)
      buf = []
      collection.each { |item| buf << slim(template, layout:false, locals:{as => item}) }
      buf.join("\n")
    end
  end

  get('/stylesheets/:name.css') do
    content_type('text/css', :charset => 'utf-8')
    scss(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
  end


  namespace %r{^/(?<id>[\d]+)(?:/.*)?} do |id|

    before do
      id=params["id"]
      halt(404, "Nothing found with id #{id}") unless @post ||= Post[id]
      puts @post.inspect
    end

    get('/edit/?') { @post.to_form("/#{@post.id}", "put") }

    get('/?')      { slim :show }

    put('/?') do
      @post.update_fields(params["model"].symbolize_keys, [:title, :contents]) \
       ? redirect(to("/#{@post.id}"))
       : halt(@post.to_form("/#{@post.id}", "put"))
    end

    delete('/?') do
      @post.destroy
      redirect to("/")
    end

  end


  post '/' do
    @post = Post.new
    @post.update(params["post"]) ? redirect(to("/#{@post.id}"), :ok)
                                 : halt(@post.to_form())
  end

  get "/" do
    @posts = Post.all
    slim :index
  end

end

