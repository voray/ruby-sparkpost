#!/usr/bin/env ruby

require_relative '../lib/sparkpost'

transmission = SparkPost::Transmission.new()
response = transmission.transmit('RECIPIENT_EMAIL', 'SENDER_EMAIL', 'test email', '<h1>HTML message</h1>')

puts response