require 'sinatra/base'
require 'json'
require 'slim'

require 'model'

class MyApp < Sinatra::Base
  before %r{^/([\d]+)(?:/.*)*} do |id|
    halt(404, "Nothing found with id #{id}") unless @post = Post[id]
  end

  get %r{^/([\d]+)/edit} do
    slim :edit
  end

  get %r{^/([\d]+)} do
    slim :show
  end
  
  post %r{^/([\d]+)/?} do
    @post.title    = request['title']    if request['title']
    @post.contents = request['contents'] if request['contents']
    @post.save     ? redirect(to("/#{@post.id}")) 
                   : redirect(back)
  end
  
  delete %r{^/([\d]+)/?} do
    @post.destroy
    redirect to("/")
  end
  
  post '/' do
    if(request['title'] && request['contents'])
      p=Post.create(title: request['title'], contents: request['contents'])
      redirect to("/#{p.id}"), :ok
    else
      redirect to("/"), "Error when creating"
    end
  end
    
  get "/" do
    @posts = Post.all
    slim :index
  end

end
  
