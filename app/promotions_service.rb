class PromotionsService
  attr_reader :applicable_discounts, :promotional_rules

  def initialize(promotional_rules)
    @promotional_rules = promotional_rules
    @applicable_discounts = []
  end

  def apply_total_price_promotional_rules(original_total_price)
    promotional_rules_by(applicability: 'total_price').each do |total_price_promotional_rule|
      next unless total_price_meets_criteria?(
        original_total_price,
        total_price_promotional_rule['operator'],
        total_price_promotional_rule['applicable_value'] 
      )

      calculate_all_applicable_discounts(total_price_promotional_rule, original_total_price)
    end
  end

  def apply_product_count_promotional_rules(checkout)
    promotional_rules_by(applicability: 'product_count').each do |product_count_promotional_rule|
      items_matching_promotional_rule = checkout.items.select do |item|
        item.product_code == product_count_promotional_rule['applicable_product_code']
      end

      next if items_matching_promotional_rule.empty?

      next unless applicable_items_meet_quantity_criteria?(
        items_matching_promotional_rule,
        product_count_promotional_rule['operator'],
        product_count_promotional_rule['applicable_value']
      )

      apply_discounts_on_applicable_items(items_matching_promotional_rule, product_count_promotional_rule)
    end
  end

  private

  def calculate_all_applicable_discounts(promotional_rule, original_total_price)
    if promotional_rule['value_type'] == 'percentage'
      applicable_discounts << original_total_price * (promotional_rule['value'].to_f / 100.0)
    elsif promotional_rule['value_type'] == 'fixed'
      # implement
    else
      raise StandardError, 'Invalid value type'
    end
  end

  def apply_discounts_on_applicable_items(applicable_items, promotional_rule)
    applicable_items.each do |item|
      if promotional_rule['value_type'] == 'fixed'
        discounted_price = item.price - promotional_rule['value']
        item.price = discounted_price
      elsif promotional_rule['value_type'] == 'percentage'
        # implement
      else
        raise StandardError, 'Invalid value type'
      end
    end
  end

  def applicable_items_meet_quantity_criteria?(
    applicable_items, promotional_rule_operator, promotional_rule_applicable_value
  )
    applicable_items.count.public_send(promotional_rule_operator, promotional_rule_applicable_value)
  end

  def total_price_meets_criteria?(
    original_total_price,
    promotional_rule_operator,
    promotional_rule_applicable_value
  )
    original_total_price.public_send(promotional_rule_operator, promotional_rule_applicable_value)
  end

  def promotional_rules_by(applicability:)
    promotional_rules.select do |promotional_rule|
      promotional_rule['applicability'] == applicability
    end
  end
end
