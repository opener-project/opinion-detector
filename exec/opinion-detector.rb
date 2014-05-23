#!/usr/bin/env ruby

require 'opener/daemons'
require 'opener/core/resource_switcher'

require_relative '../lib/opener/opinion_detector'

switcher      = Opener::Core::ResourceSwitcher.new
switcher_opts = {}

parser = Opener::Daemons::OptParser.new do |opts|
  switcher.bind(opts, switcher_opts)
end

options = parser.parse!(ARGV)
daemon  = Opener::Daemons::Daemon.new(Opener::OpinionDetector, options)

switcher.install(switcher_opts)
daemon.start
