require 'dm-core'
require 'dm-migrations' 
require 'dm-timestamps'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{File.dirname(__FILE__)}/project.db")

class Post
  include DataMapper::Resource
  
  property :id,         Serial  
  property :title,      String  
  property :contents,   Text    
  timestamps :at
end

# DataMapper.auto_migrate! #destructive
DataMapper.auto_upgrade! #non-destructive
