
require 'ExchangeRate'

describe ExchangeRate do

	it "test update" do
		expect(ExchangeRate.update()).to eql("Updated Successfuly")
	end

	it "test exchange rate" do
		expect(ExchangeRate.at(Date.today,"GBP","USD")).to eql("")
	end

end
