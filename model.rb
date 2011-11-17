require 'sequel'

Sequel::Model.plugin :schema
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :crushyform

DB = Sequel.connect('sqlite://test.db')

class Post < Sequel::Model
  set_schema do
    primary_key :id
    varchar     :title
    String      :contents
    timestamp   :created_at
    timestamp   :updated_at
  end
  create_table unless table_exists?

  def self.columns_rw
    [:title, :contents]
  end

  def self.create_from_hash(arg)
    data = arg.inject({}) { |h,(k,v)| k=k.to_sym; h[k]=v if columns_rw.include?(k); h }
    self.create(data)
  end
end

