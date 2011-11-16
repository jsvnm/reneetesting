require 'renee'
require 'json'
require 'slim'
require 'model'

class MyApp < Renee::Application
  app do
    var :integer do |id|
      puts "id is #{id}"
      halt 404 unless @post = Post[id]
      
      path('edit') { render! 'edit' }
      get          { render! 'show' }
      delete       { @post.destroy; halt :ok }
      post {
        puts  "inputputput"
        @post.title    = request['title']    if request['title']
        @post.contents = request['contents'] if request['contents']
        halt @post.save ? :ok : :error
      }
    end

    post {
      puts "in post!"
      if request['title'] && request['contents']
        p=Post.create(title: request['title'], contents: request['contents'])
        redirect "/#{p.id}"
      else
        halt :bad_request
      end
    }
    
    extension('json') { get { halt Post.all.map{ |p| {:contents => p.contents} }.to_json } }
    no_extension      { @posts = Post.all; get { render! 'index' } }
  end
  
  setup { views_path File.expand_path(File.dirname(__FILE__) + "/views") }
end
  