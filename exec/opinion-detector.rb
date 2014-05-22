#!/usr/bin/env ruby

require 'opener/daemons'
require_relative '../lib/opener/opinion_detector'

options = Opener::Daemons::OptParser.parse!(ARGV)
daemon  = Opener::Daemons::Daemon.new(Opener::OpinionDetector, options)

daemon.start