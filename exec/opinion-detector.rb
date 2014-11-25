#!/usr/bin/env ruby

require 'opener/daemons'

require_relative '../lib/opener/opinion_detector'

daemon = Opener::Daemons::Daemon.new(Opener::OpinionDetector)

daemon.start
