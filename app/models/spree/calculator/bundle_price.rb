module Spree
  class Calculator::BundlePrice < Calculator
    # preference :flat_percent, :decimal, :default => 0
        preference :taxon, :string, :default => ''
        preference :bundle_prices, :string
    # has_many :bundle_price_groups
        
    #     
    #     attr_accessible :preferred_flat_percent, :preferred_taxon
    attr_accessible :preferred_taxon, :preferred_bundle_prices
    # 
        def self.description
          I18n.t('bundle_price')
        end
    
    def compute(object)
      # debugger
      return unless object.present? and object.line_items.present?
      bundle_prices = preferred_bundle_prices.scan(/([0-9]+):([0-9]+(?:\.[0-9])?),?/).collect{ |match| [match[0].to_i, match[1].to_f]}
      return if bundle_prices.nil?
      
      item_count = 0
      total_price = 0.00
      item_price = nil
      object.line_items.each do |line_item|
        if line_item.product.taxons.where(:name => preferred_taxon).present?
          item_count += line_item.quantity
          total_price += line_item.price * line_item.quantity
          item_price = line_item.price if item_price.nil?
        end
      end
      
      return if item_count == 0 or total_price == 0
      
      # debugger
      discounts = []
      bundle_prices.sort_by{|p| p[1] }.reverse.each do |match|
        gSize = match[0]
        gPrice = match[1]
        
        num_bundles = item_count / gSize
        next if num_bundles <= 0
        bundle_discount = [((item_price * gSize) - gPrice) * num_bundles, 0].max
        discounts.push << bundle_discount
        item_count -= num_bundles * gSize
      end
      
      # hundreds = item_count / 100
      #       hundreds_discount = [((item_price * 100) - 100) * hundreds, 0].max
      #       
      #       item_count -= (100 * hundreds)
      #       
      #       sixes = item_count / 6
      #       six_discount = [((item_price * 6) - 50) * sixes, 0].max
      #       
      #       item_count -= (6 * sixes)
      #       
      #       threes = item_count / 3
      #       threes_discount = [((item_price * 3) - 30) * threes, 0].max
      
      discounts.sum.round.to_f
      
      # item_total = 0.0
      # object.line_items.each do |line_item|
      #   item_total += line_item.amount if line_item.product.taxons.where(:name => preferred_taxon).present?
      # end
      # value = item_total * BigDecimal(self.preferred_flat_percent.to_s) / 100.0
      # (value * 100).round.to_f / 100
    end
  end
  
  private
    BULK_PRICES = { 3 => 10.0, 6 => 50.0, 13 => 100.0}
end
