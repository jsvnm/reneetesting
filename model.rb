require 'sequel'

Sequel::Model.plugin :schema
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :crushyform

DB = Sequel.connect('sqlite://test.db')

class Class
  def method_to_instance(*names)
    names.each{|name|
      meth = method(name)
      self.send(:define_method, name, meth.to_proc)
    }
  end
end

class Post < Sequel::Model
  set_schema do
    primary_key :id
    varchar     :title
    String      :contents
    timestamp   :created_at
    timestamp   :updated_at
  end
  create_table unless table_exists?

  def self.columns_rw; [:title, :contents]; end

  def self.create_from_hash(arg)
    data = arg.inject({}) { |h,(k,v)| k=k.to_sym; h[k]=v if columns_rw.include?(k); h }
    self.create(data)
  end

  def to_form(action=nil, meth='POST')
    fields = columns_rw.inject("") { |out,c| out+crushyfield(c.to_sym)+"\n" }
    return fields if action.nil?
    enctype = fields.match(/type='file'/) ? "enctype='multipart/form-data'" : ''
    ["<form action='#{action}' method='POST' #{enctype}>",
     fields,
     "<input type='hidden' name='_method' value='#{meth}' />",
     "<input type='submit' value='Submit' />",
     "</form>\n"
    ].join("\n")
  end

  method_to_instance :columns_rw
end

