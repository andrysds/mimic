require 'sinatra'
Dir["services/*.rb"].each {|file| require "./#{file}" }

before do
  content_type 'application/json'
end

get '/' do
  reply_with 'index'
end

not_found do
  status 404
  reply_with 'not_found'
end

def reply_with(path)
  File.read("responses/#{path}.json")
end
