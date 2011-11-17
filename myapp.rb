require 'json'
require 'slim'
require 'sass'
require 'sinatra/base'
require "sinatra/namespace"

require 'model'

class MyApp < Sinatra::Base
  register Sinatra::Namespace
  configure do
    set :slim, :pretty => true
    #enable :inline_templates
    enable :method_override
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
      (@post.update_fields(params["model"].symbolize_keys, [:title, :contents]) \
       ? redirect(to("/#{@post.id}"))
       : redirect(back))
    end

    delete('/?') do
      @post.destroy
      redirect to("/")
    end

  end


  post '/' do
    p=Post.create_from_hash(params["post"])
    p ? redirect(to("/#{p.id}"), :ok)
      : redirect(to("/"), "Error when creating")
  end

  get "/" do
    @posts = Post.all
    slim :index
  end

end

