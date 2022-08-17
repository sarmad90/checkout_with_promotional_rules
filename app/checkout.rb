require_relative 'promotions_service'
require_relative 'discount_service'

class Checkout
  attr_reader :promotions_service, :items

  def initialize(promotional_rules)
    @items = []
    @promotions_service = PromotionsService.new(promotional_rules)
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

    promotions_service.apply_product_count_promotional_rules(self)
    promotions_service.apply_total_price_promotional_rules(original_total_price)
    DiscountService.apply_applicable_discounts(items.map(&:price).sum, promotions_service)
  end
end
