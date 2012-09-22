Spree::Promotion.class_eval do
  def order_activatable?(order)
    # debugger
    order &&
    # created_at.to_i < order.created_at.to_i &&
    !Spree::Promotion::UNACTIVATABLE_ORDER_STATES.include?(order.state)
  end
end