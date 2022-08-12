class Checkout
  attr_reader :promotional_rules, :items, :applicable_discounts

  def initialize(promotional_rules)
    @promotional_rules = promotional_rules
    @items = []
    @applicable_discounts = []
  end

  def scan(product)
    self.items << Item.new(product)
  end

  # This doesn't look elegant. Initially I designed in such a way that the product related discounts
  # should be applied first and then the total price discounts. But an expectation in the specs
  # makes it seem like it's expecting the total price discount to be applied first and then the
  # product related discounts to maximize the discount. This is totally a business requirement and
  # I'm gonna comply with the specs for the purpose of this test.
  def total
    original_total_price = items.map(&:price).sum

    apply_product_count_promotional_rules
    apply_total_price_promotional_rules(original_total_price)
    apply_all_applicable_discounts(items.map(&:price).sum)
  end

  private

  def apply_all_applicable_discounts(discounted_price)
    applicable_discounts.each do |applicable_discount|
      discounted_price = discounted_price - applicable_discount
    end

    discounted_price
  end

  def apply_total_price_promotional_rules(original_total_price)
    promotional_rules_by(applicability: 'total_price').each do |total_price_promotional_rule|
      next unless original_total_price.public_send(
        total_price_promotional_rule['operator'],
        total_price_promotional_rule['applicable_value']
      )

      if total_price_promotional_rule['value_type'] == 'percentage'
        applicable_discounts << original_total_price * (total_price_promotional_rule['value'].to_f / 100.0)
      elsif total_price_promotional_rule['value_type'] == 'fixed'
        # implement
      else
        raise StandardError, 'Invalid value type'
      end
    end
  end

  def apply_product_count_promotional_rules
    promotional_rules_by(applicability: 'product_count').each do |product_count_promotional_rule|
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
        elsif product_count_promotional_rule['value_type'] == 'percentage'
          # implement
        else
          raise StandardError, 'Invalid value type'
        end
      end
    end
  end

  def promotional_rules_by(applicability:)
    promotional_rules.select do |promotional_rule|
      promotional_rule['applicability'] == applicability
    end
  end
end
