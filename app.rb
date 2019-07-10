# frozen_string_literal: true

require 'sinatra'

USER_ACTIVITIES = [
  { type: 'view_product', pid: '201', created_at: Time.new(2019, 07, 10) },
  { type: 'view_product', pid: '202', created_at: Time.new(2019, 07, 10) },
  { type: 'view_product', pid: '203', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_cart', pid: '204', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_cart', pid: '205', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_cart', pid: '206', created_at: Time.new(2019, 07, 10) },
  { type: 'buy', pid: '207', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_fav', pid: '208', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_fav', pid: '209', created_at: Time.new(2019, 07, 10) },
  { type: 'add_to_fav', pid: '210', created_at: Time.new(2019, 07, 10) }
].freeze

set :port, (ENV['PORT'] || 4567)

before do
  content_type 'application/json'

  request.body.rewind
  @request_payload = JSON.parse request.body.read
  @edge_filter_values = @request_payload['edge_filter_values']
  @offset = @request_payload['offset'].to_i
  @limit = (@request_payload['limit'] || 1).to_i
end

post '/_internal/griffin/vertex/search-adjacent-vertex' do
  build_activities(@edge_filter_values)
  vertex_data = @activities.map { |x| { product_id: x[:pid] } }
  {
    data: { vertex_data: vertex_data, eod: @eod },
    meta: { http_status: '200' }
  }.to_json
end

post '/_internal/griffin/vertex/search-adjacent-vertex-edge' do
  build_activities(@edge_filter_values&.first)
  vertex_edge_data = @activities.map do |x|
    {
      user_actv_created_at: x[:created_at].to_i * 1000,
      user_actv_type: x[:type],
      product_id: x[:pid]
    }
  end
  {
    data: { vertex_edge_data: vertex_edge_data, eod: @eod },
    meta: { http_status: '200' }
  }.to_json
end

def build_activities(filters)
  @activities = USER_ACTIVITIES.select { |x| filters.include?(x[:type]) }
  @eod = @offset + @limit >= @activities.length
  @activities = @activities.drop(@offset)
  @activities = @activities.take(@limit)
end
