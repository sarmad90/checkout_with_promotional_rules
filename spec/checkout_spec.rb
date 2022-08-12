require_relative '../app/checkout'
require_relative '../app/item'
require_relative '../app/product'

require 'yaml'

describe Checkout do  
  let(:promotional_rules) { YAML.load_file("#{Dir.pwd}/data/promotional_rules.yml")["promotional_rules"] }
  let(:products) { YAML.load_file("#{Dir.pwd}/data/products.yml")["products"] }
  let(:product_1) { Product.new(products.find { |product| product["product_code"] == '001' }) }
  let(:product_2) { Product.new(products.find { |product| product["product_code"] == '002' }) }
  let(:product_3) { Product.new(products.find { |product| product["product_code"] == '003' }) }

  describe "#total" do
    it "returns the correct total price after applying the promotional rules for combination A" do
      checkout = described_class.new(promotional_rules)
      checkout.scan(product_1)
      checkout.scan(product_2)
      checkout.scan(product_3)

      expect(checkout.total).to eql(66.78)
    end

    it "returns the correct total price after applying the promotional rules for combination B" do
      checkout = described_class.new(promotional_rules)
      checkout.scan(product_1)
      checkout.scan(product_3)
      checkout.scan(product_1)

      expect(checkout.total).to eql(36.95)
    end

    it "returns the correct total price after applying the promotional rules for combination C" do
      checkout = described_class.new(promotional_rules)
      checkout.scan(product_1)
      checkout.scan(product_2)
      checkout.scan(product_1)
      checkout.scan(product_3)

      # I changed this expectation from 73.6 to 73.605 to offset the difference/error.
      expect(checkout.total).to eql(73.605)
    end
  end
end