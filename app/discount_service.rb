class DiscountService
  def self.apply_applicable_discounts(discounted_price, promotions_service)
    promotions_service.applicable_discounts.each do |applicable_discount|
      discounted_price = discounted_price - applicable_discount
    end

    discounted_price
  end
end
