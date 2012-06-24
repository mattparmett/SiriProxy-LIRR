#Useful for siri query "When's the next train from ___ to ___?"
require 'rubygems'
require 'lirr.rb'

class Train
	def to_siri
		if self.has_transfer?
			"The next train from " + self.from_station_name + " to " + self.to_station_name + " leaves at " + self.dep_time + " and arrives at " + self.arr_time + ", with a transfer at " + self.trans_station_name + " at " + self.trans_time + "."

		else
			"The next train from " + self.from_station_name + " to " + self.to_station_name + " leaves at " + self.dep_time + " and arrives at " + self.arr_time + "."
		end
	end

	def to_timetable
		if self.has_transfer?
			self.dep_time + " - " + self.trans_time + " - " + self.arr_time
		else
			self.dep_time + " - " + self.arr_time
		end
	end
end

class SiriProxy::Plugin::LIRR < SiriProxy::Plugin
	attr_accessor :stations_csv_file

	def initialize(config = {})
		self.stations_csv_file = config['stations_csv_file']
	end

	def nextTrain(from_station_name, to_station_name)
		from_station = Station.new(from_station_name, self.stations_csv_file)
		to_station = Station.new(to_station_name, self.stations_csv_file)
		puts from_station.name
		puts to_station.name
		train = getNextTrain(from_station, to_station, self.stations_csv_file)
		
		if !(train == [])
			say train.to_siri
		else
			say "No trains found."
		end
	end

	def trainSchedule(from_station_name, to_station_name)
		from_station = Station.new(from_station_name, self.stations_csv_file)
		to_station = Station.new(to_station_name, self.stations_csv_file)		

		trains = getTrainTimes(from_station, to_station, getTime(), getAMPM(), getTodaysDate(), self.stations_csv_file)

		if trains == []
			say "Error: no trains found."
		else
			i = 0
			train_times = ""
			while i < 4
				train_times << trains[i].to_timetable + "\n"
				i = i + 1
			end
			if i = 4
				train_times << trains[i].to_timetable
			end
			say "Here are the train times for " + from_station.name + " to " + to_station.name + ":\n\n" + train_times, spoken: "Here are the train times for " + from_station.name + " to " + to_station.name + "."

		end
	end

	def trainSearch(from_station_name, to_station_name, time, am_pm, date)
		from_station = Station.new(from_station_name, self.stations_csv_file)
		to_station = Station.new(to_station_name, self.stations_csv_file)
		
		trains = getTrainTimes(from_station, to_station, time, am_pm, date, self.stations_csv_file)

		if trains == []
			say "Error: no trains found."
		else
			i = 0
			train_times = ""
			while i < 4 #i = 0-3
				train_times << trains[i].to_timetable + "\n"
				i = i + 1
			end
		
			train_times << trains[i].to_timetable #i = 4

			say "Here are the train times for " + from_station.name + " to " + to_station.name + " around " + time + " " + am_pm + ":\n\n" + train_times, spoken: "Here are the train times for " + from_station.name + " to " + to_station.name + " around " + time + " " + am_pm + "."

		end
	end


	listen_for /when is the next train from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}		
		nextTrain(from_station_name, to_station_name)
		request_completed
	end

	listen_for /when's the next train from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}
		nextTrain(from_station_name, to_station_name)
		request_completed
	end

	listen_for /get the train times for ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}	
		trainSchedule(from_station_name, to_station_name)
		request_completed	
	end

	listen_for /get the train times from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}	
		trainSchedule(from_station_name, to_station_name)
		request_completed	
	end

	listen_for /when are the trains from ([a-z ]*) to ([a-z ]*) at ([0-9,]*[0-9]):([0-9,]*[0-9]) ([a-z]*)/i do |from_station_name, to_station_name, hour, minutes, am_pm|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}
		
		#Convert hour to proper format
    		hour = hour.to_i
   		 if (hour < 10)
   		 	hour = hour.to_s()
   		 	hour = '0' + hour
		 else
  		  	hour = hour.to_s()
		end

		time = hour + ":" + minutes

		#Convert AM/PM to proper format
		am_pm = am_pm.upcase

		trainSearch(from_station_name, to_station_name, time, am_pm, getTodaysDate())
		request_completed
	end

	listen_for /when are the trains from ([a-z ]*) to ([a-z ]*) at ([0-9,]*[0-9]) ([a-z]*)/i do |from_station_name, to_station_name, hour, am_pm|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}
		
		#Convert hour to proper format
    		hour = hour.to_i
   		 if (hour < 10)
   		 	hour = hour.to_s()
   		 	hour = '0' + hour
		 else
  		  	hour = hour.to_s()
		end

		time = hour + ":00"

		#Convert AM/PM to proper format
		if am_pm = "o" #user said "# o'clock"
			am_pm = getAMPM().upcase
		else
			am_pm = am_pm.upcase
		end

		trainSearch(from_station_name, to_station_name, time, am_pm, getTodaysDate())
		request_completed
	end

	listen_for /when are the trains from ([a-z ]*) to ([a-z ]*) at ([0-9,]*[0-9])/i do |from_station_name, to_station_name, hour|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}
		
		#Convert hour to proper format
    		hour = hour.to_i
   		 if (hour < 10)
   		 	hour = hour.to_s()
   		 	hour = '0' + hour
		 else
  		  	hour = hour.to_s()
		end

		time = hour + ":00"

		#Convert AM/PM to proper format
		#am_pm = am_pm.upcase

		trainSearch(from_station_name, to_station_name, time, getAMPM(), getTodaysDate())
		request_completed
	end

	listen_for /when are the trains from ([a-z ]*) to ([a-z ]*) at ([0-9,]*[0-9]):([0-9,]*[0-9])/i do |from_station_name, to_station_name, hour, minutes|
		from_station_name = from_station_name.gsub(/\w+/) {|word|  word.capitalize}
		to_station_name = to_station_name.gsub(/\w+/) {|word|  word.capitalize}
		
		#Convert hour to proper format
    		hour = hour.to_i
   		 if (hour < 10)
   		 	hour = hour.to_s()
   		 	hour = '0' + hour
		 else
  		  	hour = hour.to_s()
		end

		time = hour + ":" + minutes

		#Convert AM/PM to proper format
		#am_pm = am_pm.upcase

		trainSearch(from_station_name, to_station_name, time, getAMPM(), getTodaysDate())
		request_completed
	end
end
