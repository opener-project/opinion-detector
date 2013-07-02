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

      ##
      # @see Opener::Webservice#analyze
      #
      def analyze(*args)
        begin
          super
        # ArgumentErrors are used for invalid languages. These happen too often
        # so we'll supress them for now.
        rescue ArgumentError => error
          halt(400, error.message.strip)
        end
      end
    end # Server
  end # OpinionDetector
end # Opener
