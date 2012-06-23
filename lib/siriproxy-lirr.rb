#Useful for siri query "When's the next train from ___ to ___?"
require 'rubygems'
require 'lirr.rb'

class SiriProxy::Plugin::LIRR < SiriProxy::Plugin
	def initialize(config)
	end


	listen_for /when is the next train from ([a-z ]*) to ([a-z ]*) /i do |from_station_name, to_station_name|
		stations_csv_file = "/home/matt/git repos/SiriProxy-LIRR/stations.csv"		
		from_station = Station.new(from_station_name, stations_csv_file)
		to_station = Station.new(to_station_name, stations_csv_file)
		puts from_station.name
		puts to_station.name
		train = getNextTrain(from_station, to_station, stations_csv_file)
		
		if !(train == [])
			if train.has_transfer?
				say "The next train from " + train.from_station_name + " to " + train.to_station_name + " leaves at " + train.dep_time + " and arrives at " + train.arr_time + ", with a transfer at " + train.trans_station_name + " at " + train.trans_time + "."

			else
				say "The next train from " + train.from_station_name + " to " + train.to_station_name + " leaves at " + train.dep_time + " and arrives at " + train.arr_time + "."
			end

		else
			say "No trains found."
		end
	request_completed
	end
end
