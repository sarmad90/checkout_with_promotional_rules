class Product
  attr_reader :product_code, :name, :price

  def initialize(product)
    @product_code = product['product_code']
    @name = product['name']
    @price = product['price']
  end
end
