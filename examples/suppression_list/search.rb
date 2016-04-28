#!/usr/bin/env ruby

require_relative '../../lib/sparkpost'

sp = SparkPost::Client.new # pass api key or get api key from ENV
response = sp.suppression_list.search

puts response
