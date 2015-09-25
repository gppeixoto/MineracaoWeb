require 'elasticsearch/model'

class Document < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
end
Document.import
