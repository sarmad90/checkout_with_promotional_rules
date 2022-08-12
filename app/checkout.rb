class Checkout
  attr_reader :promotional_rules, :items

  def initialize(promotional_rules)
    @promotional_rules = promotional_rules
    @items = []
  end

  def scan(product)
    self.items << Item.new(product)
  end

  def total
    original_total_price = items.map(&:price).sum
    apply_promotional_rules

    applicable_discounts = []

    total_price_promotional_rules.each do |total_price_promotional_rule|
      next unless original_total_price.public_send(
        total_price_promotional_rule['operator'],
        total_price_promotional_rule['applicable_value']
      )

      if total_price_promotional_rule['value_type'] == 'percentage'
        applicable_discounts <<  original_total_price * (total_price_promotional_rule['value'].to_f / 100.0)
      else
        # implement
      end
    end
    
    discounted_price = items.map(&:price).sum

    applicable_discounts.each do |applicable_discount|
      discounted_price = discounted_price - applicable_discount
    end

    discounted_price
  end

  # def total_price
  #   result = items.map(&:price).sum

  #   total_price_promotional_rules.each do |total_price_promotional_rule|
  #     next unless result.public_send(
  #       total_price_promotional_rule['operator'],
  #       total_price_promotional_rule['applicable_value']
  #     )

  #     if total_price_promotional_rule['value_type'] == 'percentage'
  #       result = result - (result * (total_price_promotional_rule['value'].to_f / 100.0))
  #     else
  #       # implement
  #     end
  #   end

  #   result
  # end

  def apply_promotional_rules
    product_count_promotional_rules.each do |product_count_promotional_rule|
      items_matching_promotional_rule = items.select do |item|
        item.product_code == product_count_promotional_rule['applicable_product_code']
      end

      next if items_matching_promotional_rule.empty?
      next unless items_matching_promotional_rule.count
        .public_send(product_count_promotional_rule['operator'], product_count_promotional_rule['applicable_value'])

      items_matching_promotional_rule.each do |item_matching_promotional_rule|
        if product_count_promotional_rule['value_type'] == 'fixed'
          discounted_price = item_matching_promotional_rule.price - product_count_promotional_rule['value']
          item_matching_promotional_rule.price = discounted_price
        else
          # implement
        end
      end

      # items.each do |item|
      #   puts "#{item.name} #{item.price}"
      # end
    end

    # total_price_promotional_rules.each do |total_price_promotional_rule|
    #   next unless total
    # end
  end

  def total_price_promotional_rules
    promotional_rules.select do |promotional_rule|
      promotional_rule['applicability'] == 'total_price'
    end
  end

  def product_count_promotional_rules
    promotional_rules.select do |promotional_rule|
      promotional_rule['applicability'] == 'product_count'
    end
  end
end
