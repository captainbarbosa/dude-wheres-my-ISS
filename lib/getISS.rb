# Encode http parameters for ISS API call

class GetISS
	attr_accessor :lat, :lon

	def initialize(lat, lon)
		@lat = lat
		@lon = lon
	end

	def encode_latlon
		"lat=#{@lat}&lon=#{@lon}"
	end
end