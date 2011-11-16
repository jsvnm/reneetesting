require 'sequel'

Sequel::Model.plugin :schema
Sequel::Model.plugin :timestamps

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
end

