require 'renee'
require 'json'
require 'slim'
require 'model'

class MyApp < Renee::Application
  app do
    var :integer do |id|
      halt 404 unless @post = Post.get(id)
      
    path('edit') { render! 'edit' }
      get          { render! 'show' }
    delete       { @post.destroy; halt :ok }
    put {
        @post.title    = request['title']    if request['title']
        @post.contents = request['contents'] if request['contents']
        halt @post.save ? :ok : :error
      }
    end

    post {
      if request['title'] && request['contents']
        Post.create(title: request['title'], contents: request['contents'])
        halt :created
      else
        halt :bad_request
      end
    }
    
    extension('json') { get { halt Post.all.map{ |p| {:contents => p.contents} }.to_json } }
    no_extension      { @posts = Post.all; get { render! 'index' } }
  end
  
  setup { views_path File.expand_path(File.dirname(__FILE__) + "/views") }
end
  