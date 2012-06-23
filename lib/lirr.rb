#Useful for siri query "When's the next train from ___ to ___?"
require 'rubygems'
require 'mechanize'
require 'csv'
require 'time'

###
#Begin Classes

class Time
  def round(seconds = 60)
    Time.at((self.to_f / seconds).round * seconds)
  end

  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end
  
  def ceiling(seconds = 60)
	t = self.floor(seconds)
	t + seconds
  end
end

class StationError < StandardError
end

class Station
	attr_accessor :name, :id
	
	#args = [name/id, stations_csv_file]
	def initialize(*args)
		if args[1].is_a? String
			data = CSV.read(args[1])
		else
			data = CSV.read("stations.csv")
		end
		
		#If argument passed is name, assign name and get id. If id, assign id and get name.
		if args[0].is_a? String
			data.each do |d|
				if d[1] == args[0]
					@id = d[0]
					@name = args[0]
				elsif d[0] == args[0]
					@name = d[1]
					@id = args[0]
				end
			end
		else
			raise StationError, "Station not found."
		end
	end

end

class Train
	attr_accessor :dep_time, :from_station, :from_station_name, :from_station_id, :arr_time, :to_station, :to_station_name, :to_station_id, :trans_station, :trans_station_name, :trans_station_id, :trans_time, :duration, :peak
	
	def initialize(dep_time, from_station, arr_time, to_station, trans_station, trans_time, duration, peak)
		#from, to, and trans_station should all be Station objects.  Therefore, need to catch StationError.
		begin
			@dep_time = dep_time
			@from_station = from_station
				@from_station_name = @from_station.name
				@from_station_id = @from_station.id
			@arr_time = arr_time
			@to_station = to_station
				@to_station_name = @to_station.name
				@to_station_id = @to_station.id
			if trans_station.is_a? Station
				@trans_station = trans_station
					@trans_station_name = @trans_station.name
					@trans_station_id = @trans_station.id
			end
			@trans_time = trans_time
			@duration = duration
			@peak = peak
		rescue StationError => e
			puts "Station invalid."
		end
	end
	
	def has_transfer?
		if @trans_station_name.length > 1 and @trans_time.length > 1
			true
		else
			false
		end
	end
	
	def peak?
		if @peak == "Peak"
			true
		else
			false
		end
	end
end

#End Classes
###

###
#Begin methods

#Takes station name and converts it to numerical ID, returned as a string
def convertStationToID(station_name, station_csv_file = "stations.csv")
	data = CSV.read("stations.csv")
	data.each do |d|
		if d[1] == station_name
			return d[0]
		end
	end
	raise StationError, "Station not found."
end

def getTodaysDate()
	time = Time.new
	
	#Get correctly formatted month string
	if time.month < 10
		month_string = "0" + time.month.to_s
	else
		month_string = time.month.to_s
	end
	
	#Get correctly formatted day string
	if time.day < 10
		day_string = "0" + time.day.to_s
	else
		day_string = time.day.to_s
	end
	
	#Combine into one super date string
	date_string = month_string + "/" + day_string + "/" + time.year.to_s
	
	return date_string
end

def getTime()
	time = Time.new
	return time.strftime("%I:%M")
end

def getAMPM()
	time = Time.new
	return time.strftime("%p")
end

#Takes search parameters and writes search result timetable to 'results.csv'
#Returns an array of 5 arrays, each of which represents an individual train. Each of the 5 arrays includes [departure time, arrival time, transfer location, transfer time, duration, peak/off peak]
#args = [from_station, to_station, request_time_value, request_am_pm_value, request_date, station_csv_file]
def getTrainTimes(*args)
	#Assign more useful variable names to args
	if args[5] != 0
		station_csv_file = args[5]
	else
		station_csv_file = "stations.csv"
	end
	
	begin
		from_station_id = args[0].id
	rescue StationError => e
		abort("Invalid departure station: " + args[0] + ".")
	end
	
	begin
		to_station_id = args[1].id
	rescue StationError => e
		abort("Invalid destination station: " + args[1] + ".")
	end
	
	if args[2] != 0
		request_time_value = args[2]
	else
		request_time_value = getTime()
	end
	
	if args[3] != 0
		request_am_pm_value = args[3]
	else
		request_am_pm_value = getAMPM()
	end
	
	if args[4] != 0
		request_date_value = args[4]
	else
		request_date_value = getTodaysDate()
	end
	
	#Create mechanize agent
	a = Mechanize.new
	
	#Get lirr schedule search page
	search = a.get("http://lirr42.mta.info/")
	
	#Select search form
	search_form = search.form_with(:name => 'index')
	
	#Set search form parameters
	#Make sure stations are valid!
	search_form['FromStation'] = from_station_id
	search_form['ToStation'] = to_station_id
	search_form['RequestTime'] = request_time_value
	search_form['RequestAMPM'] = request_am_pm_value
	search_form['RequestDate'] = request_date_value

	#Select submit button for schedules
	button = search_form.button_with(:name => 'schedules')

	#Submit search form
	results = a.submit(search_form, button)
	
	#Select table elements in the results page, and put the html and inner text into an array
	td = results.search("//tr//td")
	elements = []
	td.each do |t|
		if t.attr('class') == "schedulesTD"
			elements << t
		end
	end
		
	#Write heaaders to csv file
	# results_file.write("Depart,Arrive,Transfer,Leaves,Duration,Status\n")
	
	#Loop to iterate through results and extract and write the inner text elements to the csv file
	i = 1
	trains = []
	train_info = []
	elements.each do |t|
		if i <= 1 or i == 4 or i == 8
			i = i + 1
		elsif i < 9
			text = t.inner_text()
			
			train_info << text
			i = i + 1
		elsif i == 9
			text = t.inner_text()
			
			train_info << text
			
			#Finished with train info, so create Train object, add it to result array, and reset train info array
			begin
				train = Train.new(train_info[0], Station.new(from_station_id), train_info[1], Station.new(to_station_id), Station.new(train_info[2]), train_info[3], train_info[4], train_info[5])
			rescue StationError => e
				puts "Station invalid."
			end
			trains << train
			train_info = []
			i = 1
		end
	end
	
	#Close csv file
	# puts "Train times retrieved."
	
	#Create and return array of relevant train 
	return trains
end

#Takes a pair of stations and returns the next Train object that makes the specified trip.
#args = [from_station, to_station, station_csv_file]
def getNextTrain(*args)
	#Set args
	if !(args[0].is_a? Station) or !(args[1].is_a? Station)
		abort("Invalid station specifed for getNextTrain.")
	else
		from_station = args[0]
		to_station = args[1]
	end
	
	if args[2].is_a? String
		station_csv_file = args[2]
	else
		station_csv_file = "stations.csv"
	end
	
	#Get current time, rounded to the next 15 mins for search purposes
	time = Time.now.ceiling(15*60).strftime("%I:%M")
	# puts "Seaching for trains at " + time
	
	#Run train search to find 5 trains around the current rounded time
	begin
		trains = getTrainTimes(from_station, to_station, time, getAMPM(), getTodaysDate(), station_csv_file)
	rescue StationError => e
		puts e.message
		puts e.backtrace
	end
	
	#Get and return the next train!
	trains.each do |train|
		departure_time = Time.parse(train.dep_time)
		if departure_time > Time.now
			return train #Returns the first train with departure time after current time
		end
	end
	
	return [] #No trains found
	
end

#End Methods
###

###
#Begin code body


#End code body
###
