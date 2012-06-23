require 'rubygems'
require './lirr.rb'

stations_csv_file = "/home/matt/git repos/SiriProxy-LIRR/stations.csv"		
from_station = Station.new(from_station_name, stations_csv_file)
to_station = Station.new(to_station_name, stations_csv_file)
train = getNextTrain(from_station, to_station, stations_csv_file)

if train.has_transfer?
	say "The next train from " + train.from_station_name + " to " + train.to_station_name + " leaves at " + train.dep_time + " and arrives at " + train.arr_time + ", with a transfer at " + train.trans_station_name + " at " + train.trans_time + "."

else
	say "The next train from " + train.from_station_name + " to " + train.to_station_name + " leaves at " + train.dep_time + " and arrives at " + train.arr_time + "."
end
