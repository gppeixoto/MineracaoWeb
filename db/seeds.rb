# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# require 'elasticsearch/client'

directory = './20_newsgroups_crypt_space-sample10/sci.crypt/'
Dir.foreach(directory) do |file_name|
  next if file_name == '.' or file_name == '..'
  data = File.read(directory + file_name)
  Document.create(name: file_name, text: data)
  # client.indices.create(name: file_name, text: data)
end  
