# require 'forwardable'

class Item
  # extend Forwardable

  # def_delegators :@product, :product_code, :name, :price

  attr_accessor :price
  attr_reader :product_code, :name

  def initialize(product)
    @product_code = product.product_code
    @name = product.name
    @price = product.price
  end
end
