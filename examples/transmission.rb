#!/usr/bin/env ruby

require_relative '../lib/sparkpost'

sp = SparkPost::Client.new() # gets api key from ENV
response = sp.transmission.send_message('RECIPIENT_EMAIL', 'SENDER_EMAIL', 'test email', '<h1>HTML message</h1>')

puts response
