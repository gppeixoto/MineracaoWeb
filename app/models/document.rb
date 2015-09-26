require 'elasticsearch/model'

class Document < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english', index_options: 'offsets'
      indexes :text, analyzer: 'english'
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'text']
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            title: {},
            text: {}
          }
        }
      }
    )
  end

end

# Delete the previous documents index in Elasticsearch
Document.__elasticsearch__.client.indices.delete index: Document.index_name rescue nil

# Create the new index with the new mapping
Document.__elasticsearch__.client.indices.create \
  index: Document.index_name,
  body: { settings: Document.settings.to_hash, mappings: Document.mappings.to_hash }

# Index all document records from the DB to Elasticsearch
Document.import