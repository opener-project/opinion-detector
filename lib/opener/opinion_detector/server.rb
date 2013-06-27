require 'sinatra/base'
require 'httpclient'
require 'opener/webservice'

module Opener
  class OpinionDetector
    ##
    # Opinion Detector server powered by Sinatra.
    #
    class Server < Webservice
      set :views, File.expand_path('../views', __FILE__)
      text_processor OpinionDetector
      accepted_params :input
    end # Server
  end # OpinionDetector
end # Opener
