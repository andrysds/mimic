require 'sinatra'
Dir["services/*.rb"].each {|file| require "./#{file}" }

before do
  content_type 'application/json'
end

get '/' do
  res 'index'
end

not_found do
  status 404
  res 'not_found'
end

def res(path)
  File.read("responses/#{path}.json")
end
