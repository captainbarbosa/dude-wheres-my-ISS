#--------------------------------------------------------------
# Purpose: Geocodes an address and uses resulting output to 
# determine the next time the ISS will fly over the corresponding 
# lat/long location. Created by Nadia Barbosa.
#--------------------------------------------------------------

require 'rest-client'
require 'json'

require_relative 'lib/GetAddress'
require_relative 'lib/GetISS'

puts "--------\nWelcome!\n--------\nEnter your address below to determine the next time the ISS will fly over your location...\n\n"


# Address parameter methods
def get_street
	puts "· Street name:"
	street = gets.chomp
end

def get_city
	puts "· City:"
	city = gets.chomp
end

def get_state
	puts "· State:"
	state = gets.chomp
end

# Geocoding process
def get_geocode
	# Create one string from address parameters
	address = GetAddress.new(get_street, get_city, get_state)
	address_string = address.to_s


	# Encode URL using previous string
	encoded_address = address_string.gsub!(" ", "+")


	# Append encoded address URL with HTTP request & parse result
	get_location = RestClient.get("http://maps.googleapis.com/maps/api/geocode/json?address="+encoded_address)
	geocode = JSON.parse(get_location)


	# Repeat input if address cannot be geocoded
	while geocode["status"] == "ZERO_RESULTS" or geocode["status"] == "INVALID_REQUEST"
		puts "Your address could not be geocoded.\nVerify that your address is correct and try again."
		geocode = get_geocode
	end


	# Return a verified geocoded location
	geocode

end

geocode = get_geocode




# Get lat and long from geocoded location
lat = geocode["results"][0]["geometry"]["location"]["lat"]
lon = geocode["results"][0]["geometry"]["location"]["lng"]




# Encode second URL with lat/long
get_latlon = GetISS.new(lat, lon)
encoded_latlon = get_latlon.encode_latlon




# Append encoded lat/long URL with HTTP request & parse result
get_iss_location = RestClient.get("http://api.open-notify.org/iss-pass.json?"+encoded_latlon)
iss_location = JSON.parse(get_iss_location)




# Retrieve flyover information from above output
iss_verification = iss_location["message"]
iss_overhead_unixtime = iss_location["response"][0]["risetime"]
iss_overhead_duration = iss_location["response"][0]["duration"]

iss_overhead_datetime = Time.at(iss_overhead_unixtime)



# Printout method, including time formatting
def printout(latitude, longitude, time, duration)
	puts "Latutude: #{latitude} Longitude: #{longitude}"
	puts "ISS scheduled to be overhead on #{time.strftime("%A")}, #{time.strftime("%B %d")} at #{time.strftime("%I:%M:%S %p")} for a total of #{duration} seconds."
	puts "* Note that overhead is defined as 10° in elevation for the observer."
end


# Call printout method if ISS estimate succeeds
if iss_verification == "success"
	puts printout(lat, lon, iss_overhead_datetime, iss_overhead_duration)

else
	puts "Could not retrieve ISS information. Try again later."
end
