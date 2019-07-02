require 'sinatra'

set :port, (ENV['PORT'] || 4567)

before do
  content_type 'application/json'
end

get '/*' do
  reply request
end

post '/*' do
  reply request
end

put '/*' do
  reply request
end

patch '/*' do
  reply request
end

delete '/*' do
  reply request
end

options '/*' do
  reply request
end

link '/*' do
  reply request
end

unlink '/*' do
  reply request
end

def reply(req)
  fpath = req.request_method + req.path_info
  fpath += 'index' if req.path_info == '/'
  if response_exist? fpath
    reply_with fpath
  else
    status 404
    reply_with 'not_found'
  end
end

def response_exist?(fpath)
  File.exist? "responses/#{fpath}.json"
end

def reply_with(fpath)
  File.read "responses/#{fpath}.json"
end
