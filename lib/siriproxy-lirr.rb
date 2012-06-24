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

	def trainSchedule(from_station_name, to_station_name, stations_csv_file)
		from_station = Station.new(from_station_name, stations_csv_file)
		to_station = Station.new(to_station_name, stations_csv_file)		
			
		trains = getTrainTimes(from_station, to_station, getTime(), getAMPM(), getTodaysDate(), stations_csv_file)
		
		say trains[0].to_timetable + "\n" + trains[1].to_timetable + "\n" + trains[2].to_timetable + "\n" + trains[3].to_timetable + "\n" + trains[4].to_timetable + "\n", spoken: "Here are the train times for " + from_station.name + " to " + to_station.name + "."
	end


	listen_for /when is the next train from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|	
		nextTrain(from_station_name, to_station_name)
		request_completed
	end

	listen_for /when's the next train from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|	
		nextTrain(from_station_name, to_station_name)
		request_completed
	end

	listen_for /get the train times for ([a-z ]*) to ([a-z]*) /i do |from_station_name, to_station_name|
		trainSchedule(from_station_name, to_station_name, self.stations_csv_file)
		request_completed	
	end
end
