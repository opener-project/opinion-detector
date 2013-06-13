require 'sinatra/base'
require 'httpclient'

module Opener
  class OpinionDetector
    ##
    # Opinion Detector server powered by Sinatra.
    #
    class Server < Sinatra::Base
      configure do
        enable :logging
      end

      configure :development do
        set :raise_errors, true
        set :dump_errors, true
      end

      ##
      # Provides a page where you see a textfield and you can post stuff
      #
      get '/' do
        erb :index
      end

      ##
      # Detects opinion for a given text.
      #
      # @param [Hash] params The POST parameters.
      #
      # @option params [String] :text The text to be analyzed.
      # @option params [Array<String>] :callbacks A collection of callback URLs
      #  that act as a chain. The results are posted to the first URL which is
      #  then shifted of the list.
      # @option params [String] :error_callback Callback URL to send errors to
      #  when using the asynchronous setup.
      #
      post '/' do
        if !params[:text] or params[:text].strip.empty?
          logger.error('Failed to process the request: no text specified')

          halt(400, 'No text specified')
        end

        if params[:callbacks] and !params[:callbacks].strip.empty?
          process_async
        else
          process_sync
        end
      end

      private

      ##
      # Processes the request synchronously.
      #
      def process_sync
        output = opinion_detector_text(params[:text])

        content_type(:xml)

        body(output)
      rescue => error
        logger.error("Failed to analyze the text: #{error.inspect}")

        halt(500, error.message)
      end

      ##
      # Processes the request asynchronously.
      #
      def process_async
        callbacks = params[:callbacks]
        callbacks = [callbacks] unless callbacks.is_a?(Array)

        Thread.new do
          opinion_detector_async(params[:text], callbacks, params[:error_callback])
        end

        status(202)
      end

      ##
      # @param [String] text The text to be analyzed.
      # @return [String]
      # @raise RuntimeError Raised when the opinion detection process
      #  failed.
      #
      def opinion_detector_text(text)
        opinion_detector      = OpinionDetector.new
        output, error, status = opinion_detector.run(text)

        raise(error) unless status.success?

        return output
      end

      ##
      # Gives tags to the tokenized text and submits it to a callback URL.
      #
      # @param [String] text
      # @param [Array] callbacks
      # @param [String] error_callback
      #
      def opinion_detector_async(text, callbacks, error_callback = nil)
        begin
          kaf = opinion_detector_text(text)
        rescue => error
          logger.error("Failed to analyze the text: #{error.message}")

          submit_error(error_callback, error.message) if error_callback

          return
        end

        url = callbacks.shift

        logger.info("Submitting results to #{url}")

        begin
          process_callback(url, kaf, callbacks)
        rescue => error
          logger.error("Failed to submit the results: #{error.inspect}")

          submit_error(error_callback, error.message) if error_callback
        end
      end

      ##
      # @param [String] url
      # @param [String] kaf
      # @param [Array] callbacks
      #
      def process_callback(url, text, callbacks)
        HTTPClient.post(
          url,
          :body => {:text => text, :callbacks => callbacks}
        )
      end

      ##
      # @param [String] url
      # @param [String] message
      #
      def submit_error(url, message)
        HTTPClient.post(url, :body => {:error => message})
      end
    end # Server
  end # OpinionDetector
end # Opener
