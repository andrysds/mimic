require 'sinatra'

before do
  content_type 'application/json'
end

get '/*' do
  if response_exist? request.path_info
    reply_with request.path_info
  else
    status 404
    reply_with '/not_found'
  end
end

def response_exist?(fpath)
  File.exist? "responses#{fpath}.json"
end

def reply_with(fpath)
  File.read "responses#{fpath}.json"
end
