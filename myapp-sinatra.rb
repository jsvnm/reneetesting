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


  namespace %r{^/(?<id>[\d]+)(?:/.*)?} do |id|

    before do
      id=params["id"]
      halt(404, "Nothing found with id #{id}") unless @post = Post[id]
    end
    
    get('/edit/?') { slim :edit }
    get('/?')      { slim :show }
    
    put('/?') do
      @post.title    = request['title']    if request['title']
      @post.contents = request['contents'] if request['contents']
      @post.save     ? redirect(to("/#{@post.id}")) 
                     : redirect(back)
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
  
__END__
@@layout
doctype html
html
  head
    meta charset="utf-8"
    title= @title || "sinatra > renee"
    /  /// link rel="shortcut icon" href="/fav.ico" 
    link rel="stylesheet" media="screen, projection" href="/styles.css"
    script src="http://rightjs.org/hotlink/right.js"
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
    a.showpost href=url("/#{post.id}") = post.title
    br
    = post.contents
br
#post
form action=url("/") method="post"
  label for="post[title]" Title
  input name="post[title]"
  br
  label for="post[contents]" Contents
  textarea name="post[contents]"
  br
  input type="submit" value="Create"
javascript:
  ".showpost".onClick(function(event) {
    event.stop();
    $('post').load(this.get('href'));
  });


@@edit
form#form action="/#{@post.id}" method="post"
  input type="hidden" name="_method" value="put"
  | Title
  input name="title" value=@post.title
  br
  textarea name="contents" = @post.contents
  br
  input type="submit" value="Update"
javascript:
  $('form').remotize();

@@show
h1 = @post.title        
p = @post.contents      
a href=url("/") See all posts


@@styles
html,body,div,span,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote, pre,abbr,address,cite,code,del,dfn,em,img,ins,kbd,q,samp,small,strong,sub,sup,var,b,i,dl,dt, dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article, aside, canvas, details,figcaption,figure,footer,header,hgroup,menu,nav,section, summary,time,mark,audio,video{margin:0;padding:0;border:0;outline:0;font-size:100%;vertical-align:baseline;background:transparent;line-height:1;}
body{font: 13px/27px Arial,sans-serif;}

#logo{width:280px;display:block;margin:10px auto;}

h1{font-size:28px;color:blue;line-height:2;}

form{width:400px;margin:0 auto;}
form label {float:left; font-size:13px; width:110px; }

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
