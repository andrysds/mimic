require 'sinatra'

USER_ACTIVITIES = [
  {type: 'view_product', pid: 108},
  {type: 'add_to_cart', pid: 108},
  {type: 'add_to_fav', pid: 108},
  {type: 'buy', pid: 108},
  {type: 'view_product', pid: 109},
  {type: 'add_to_cart', pid: 109},
  {type: 'add_to_fav', pid: 109},
  {type: 'view_product', pid: 110},
  {type: 'add_to_cart', pid: 110},
  {type: 'add_to_fav', pid: 110},
].freeze

set :port, (ENV['PORT'] || 4567)

before do
  content_type 'application/json'

  request.body.rewind
  @request_payload = JSON.parse request.body.read
  @edge_filter_values = @request_payload['edge_filter_values']
  @offset = @request_payload['offset'].to_i
  @limit = @request_payload['limit'] || 1
end

post '/_internal/griffin/vertex/search-adjacent-vertex' do
  build_activities(@edge_filter_values)
  vertex_edge_data = @activities.map{ |x| { product_id: x[:pid] } }
  {
    data: { vertex_edge_data: vertex_edge_data, eod: @eod },
    meta: { http_status: "200" }
  }.to_json
end

post '/_internal/griffin/vertex/search-adjacent-vertex-edge' do
  build_activities(@edge_filter_values&.first)
  vertex_edge_data = @activities.map{ |x| { user_actv_type: x[:type], product_id: x[:pid] } }
  {
    data: { vertex_edge_data: vertex_edge_data, eod: @eod },
    meta: { http_status: "200" }
  }.to_json
end

def build_activities(filters)
  @activities = USER_ACTIVITIES.select{ |x| filters.include?(x[:type]) }
  @eod = @offset + @limit >= @activities.length
  @activities = @activities.drop(@offset)
  @activities = @activities.take(@limit)
end
