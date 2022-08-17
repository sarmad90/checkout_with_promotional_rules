class PromotionsService
  attr_reader :applicable_discounts, :promotional_rules

  def initialize(promotional_rules)
    @promotional_rules = promotional_rules
    @applicable_discounts = []
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
    applicable_discounts
  end

  def apply_product_count_promotional_rules(checkout)
    promotional_rules_by(applicability: 'product_count').each do |product_count_promotional_rule|
      items_matching_promotional_rule = checkout.items.select do |item|
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

  private

  def promotional_rules_by(applicability:)
    promotional_rules.select do |promotional_rule|
      promotional_rule['applicability'] == applicability
    end
  end
end
