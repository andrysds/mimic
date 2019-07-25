# frozen_string_literal: true

require 'sinatra'
require 'pry'

PRODUCT_CATEGORIES = {
  '201' => '8',
  '202' => '125'
}.freeze

USER_ACTIVITIES = [
  { type: 'view_product', pid: '201', created_at: Time.new(2019, 7, 10) },
  { type: 'view_product', pid: '202', created_at: Time.new(2019, 7, 10) },
  { type: 'view_product', pid: '203', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_cart', pid: '204', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_cart', pid: '205', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_cart', pid: '206', created_at: Time.new(2019, 7, 10) },
  { type: 'buy', pid: '207', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_fav', pid: '208', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_fav', pid: '209', created_at: Time.new(2019, 7, 10) },
  { type: 'add_to_fav', pid: '210', created_at: Time.new(2019, 7, 10) }
].freeze

set :port, (ENV['PORT'] || 4567)

before do
  content_type 'application/json'

  request.body.rewind
  request_payload = JSON.parse request.body.read
  vertex_start_filters = request_payload['vertex_start_filters']
  @vertex_start_filter_key = vertex_start_filters.first['key']
  @vertex_start_filter_value = vertex_start_filters.first['value']
  @offset = request_payload['offset'].to_i
  @limit = (request_payload['limit'] || 1).to_i
end

post '/_internal/griffin/vertex/search-adjacent-v' do
  vertex_data = []
  if @vertex_start_filter_key == 'product_id'
    cid = PRODUCT_CATEGORIES[@vertex_start_filter_value] || '0'
    vertex_data = [{ category_id: cid }]
    @eod = true
  else
    build_activities
    vertex_data = @activities.map { |x| { product_id: x[:pid] } }
  end
  {
    data: { vertex_data: vertex_data, eod: @eod },
    meta: { http_status: '200' }
  }.to_json
end

post '/_internal/griffin/vertex/search-adjacent-ve' do
  build_activities
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

def build_activities
  @activities = USER_ACTIVITIES.select do |x|
    @edge_filter_value.include?(x[:type])
  end
  @eod = @offset + @limit >= @activities.length
  @activities = @activities.drop(@offset)
  @activities = @activities.take(@limit)
end
