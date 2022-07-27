def generate_new_order
  load
  data = JsonHelper.data_for 'order'

  data['id'] = $order_id

  data
end