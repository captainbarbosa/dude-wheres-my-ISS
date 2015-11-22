# Get & format address input

class GetAddress

	attr_accessor :street, :city, :state

	def initialize(street, city, state)
		@street = street
		@city = city
		@state = state
	end

	def to_s
		"#{@street}, #{@city}, #{@state}"
	end
end