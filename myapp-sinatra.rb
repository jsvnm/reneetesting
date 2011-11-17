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
    enable :inline_templates
    enable :method_override
  end

  get('/styles.css'){ content_type 'text/css', :charset => 'utf-8' ; scss :styles }


  before %r{^/([\d]+)(?:/.*)*} do |id|
    halt(404, "Nothing found with id #{id}") unless @post = Post[id]
  end

  get %r{^/([\d]+)/edit} do
    slim :edit
  end

  get %r{^/([\d]+)} do
    slim :show
  end
  
  put %r{^/([\d]+)/?} do
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
  
__END__
@@layout
doctype html
html
  head
    meta charset="utf-8"
    title= @title || "sinatra > renee"
    /  /// link rel="shortcut icon" href="/fav.ico" 
    link rel="stylesheet" media="screen, projection" href="/styles.css"
    /[if lt IE 9]
      script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
  body
    == yield


@@index
- if @posts.empty?
  p No posts, create some!
- for post in @posts do
  p 
    | Title:
    a href=url("/#{post.id}") = post.title
    br
    = post.contents
br
form action=url("/") method="post"
  | Title
  input name="title"
  br
  textarea name="contents"
  br
  input type="submit" value="Create"


@@edit
form action="/#{@post.id}" method="post"
  input type="hidden" name="_method" value="put"
  | Title
  input name="title" value=@post.title
  br
  textarea name="contents" = @post.contents
  br
  input type="submit" value="Update"


@@show
h1 = @post.title        
p = @post.contents      
a href=url("/") See all posts


@@styles
html,body,div,span,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote, pre,abbr,address,cite,code,del,dfn,em,img,ins,kbd,q,samp,small,strong,sub,sup,var,b,i,dl,dt, dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article, aside, canvas, details,figcaption,figure,footer,header,hgroup,menu,nav,section, summary,time,mark,audio,video{margin:0;padding:0;border:0;outline:0;font-size:100%;vertical-align:baseline;background:transparent;line-height:1;}
body{font: 13px/27px Arial,sans-serif;}

#logo{width:280px;display:block;margin:10px auto;}

h1{font-size:28px;color:blue;line-height:2;}

form{width:280px;margin:0 auto;}
#page{width:480px;margin:0 auto;}

#google{background:#2d2d2d;overflow:hidden;
li{float:left;display:inline;list-style-type:none;margin:0;line-height:27px;}
li a,li a:link{padding:0 5px;text-decoration:none;display:block;
color:white;border-top:2px solid transparent;}
li a:hover{background:#4d4d4d;}
li a.current{font-weight:bold;border-top-color:#DD4B39;}}

#footer{
overflow:hidden;;padding:10px;width:300px;margin:100px auto 0;
li{float:left;display:inline;list-style-type:none;margin:0;font-weight:bold;color:#DD4B39;}
li a,li a:link{padding:0 5px;text-decoration:none;display:block;
color:blue;font-weight:normal;}
li a:hover{text-decoration:underline;}}
