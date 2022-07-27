When('user successfully create order') do
  request_body = TokopediaModel.generate_new_order
  response = ApiBaseHelper.post(@api_endpoint['create_order_endpoint'], request_body)
  $order_id = response.response['location'].gsub(/\D/, '') # to retrieve the created order id, and parsing it using gsub
  aggregate_failures('Verifying API response') do
    expect(response.code.to_i).to eql 201
  end
end

When('user successfully create order') do
  response = ApiBaseHelper.get(@api_endpoint['order_detail'] + $order_id)
  aggregate_failures('Verifying API response') do
    expect(response.body['id'].to_s).to eql $order_id
    expect(response.body['order_description']).to eql 'sample description'
    expect(response.body['order_status']).to eql 'New'
    expect(response.body['last_updated_timestamp']).to eql Time.now.strftime('%T')
    expect(response.body['special_order']).to eql 'false'
  end
end