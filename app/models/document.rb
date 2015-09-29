require 'elasticsearch/model'

class Document < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: {
  "number_of_shards": 1,
  "number_of_replicas": 0,
  "analysis": {
    "filter": {
      "english_stemmer": {
        "type":       "stemmer",
        "language":   "english"
      }
    },
    "analyzer": {
      "eng": {
        "tokenizer":  "standard",
        "filter": ["lowercase","english_stemmer"]
      }
    }
  }
} do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'eng', index_options: 'offsets'
      indexes :text, analyzer: 'eng'
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        size: 50,
        min_score: 0.01 ,
        query: {
          multi_match: {
            query: query,
            fields: ['title', 'text']
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