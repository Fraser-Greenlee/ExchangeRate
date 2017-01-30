
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
		File.open("rates.json","w") do |f|
	  	f.write(ratesByDate.to_json)
		end
		"Updated Successfuly"
	end

	# Call to get exchange rate
	def self.at(date, base, counter)
		date = date.to_s
		# load rates
		File.open("rates.json","r") do |f|
			rates = JSON.parse(f.read())
			# return base*counter for date
			rates[date][base]*rates[date][counter]
		end
	end
end
