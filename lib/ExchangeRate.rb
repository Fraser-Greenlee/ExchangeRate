
require "version"

require "nokogiri"
require "json"

module ExchangeRate
	# Call to update data
	def self.update()
		# (Currently reloading all values every time since the process is fast and all page data would be loaded anyway)
		# get page xml
		url = URI.parse('http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		# parse xml
		doc = Nokogiri::XML(res.body)
		doc.remove_namespaces!
		days = doc.xpath('//Cube/Cube[@time]')
		# format data
		# ratesByDate = {date => {currency => rate} }
		ratesByDate = {}
		days.each do |dayData|
			date = dayData.xpath("@time")[0].value
			# create rate dictionary
			ratesData = dayData.xpath("Cube[@currency]")
			rates = {}
			ratesData.each do |rateData|
				# rates["USD"] = rate of USD
				rates[rateData.values[0]] = rateData.values[1].to_f
			end
			# add to ratesByDate
			ratesByDate[date] = rates
		end
		# save ratesByDate to rates.json
		File.open("ExchangeRate/rates.json","w") do |f|
	  	f.write(ratesByDate.to_json)
		end
		"Updated Successfuly"
	end

	# Get currencies included
	def self.currencies()
		File.open("ExchangeRate/rates.json","r") do |f|
			rates = JSON.parse(f.read())
			return rates[rates.keys[0]].keys
		end
	end

	# Get last date updated
	def self.lastupdated()
		File.open("ExchangeRate/rates.json","r") do |f|
			rates = JSON.parse(f.read())
			return rates.keys[0]
		end
	end

	# Call to get exchange rate
	def self.at(date, base, counter)
		# can send string or Date value
		date = date.to_s
		# load rates
		File.open("ExchangeRate/rates.json","r") do |f|
			rates = JSON.parse(f.read())
			# find values
			if rates.key?(date) then
				ratesOnDay = rates[date]
				puts ratesOnDay
				if ratesOnDay.key?(base) then
					baseV = ratesOnDay[base]
				else
					return "Error: No values found for "+base
				end
				if ratesOnDay.key?(counter) then
					counterV = ratesOnDay[counter]
				else
					return "Error: No values found for "+counter
				end
			else
				return "Error: No values found for "+date
			end
			# return base*counter for date
			return baseV/counterV
		end
	end
end
