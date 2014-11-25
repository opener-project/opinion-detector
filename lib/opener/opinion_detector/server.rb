require 'opener/webservice'

module Opener
  class OpinionDetector
    ##
    # Opinion Detector server powered by Sinatra.
    #
    class Server < Webservice::Server
      set :views, File.expand_path('../views', __FILE__)

      self.text_processor  = OpinionDetector
      self.accepted_params = [:input]
    end # Server
  end # OpinionDetector
end # Opener
