require 'opener/opinion_detectors/base'
require 'open3'
require 'nokogiri'
require 'optparse'
require 'opener/core'

require_relative 'opinion_detector/version'
require_relative 'opinion_detector/cli'

module Opener
  ##
  # Primary opinion detector class that delegates work to the various opinion
  # detector kernels.
  #
  # @!attribute [r] options
  #  @return [Hash]
  #
  class OpinionDetector
    attr_reader :options

    ##
    # Hash containing the default options to use.
    #
    # @return [Hash]
    #
    DEFAULT_OPTIONS = {
      :args => []
    }.freeze

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args Collection of arbitrary arguments to pass
    #  to the individual tokenizer commands.
    #
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
    end

    ##
    # Processes the input and returns an array containing the output of STDOUT,
    # STDERR and an object containing process information.
    #
    # @param [String] input
    # @return [Array]
    #
    def run(input)
      begin
        language = language_from_kaf(input)

        unless valid_language?(language)
          raise ArgumentError, "The specified language (#{language}) is invalid"
        end

        kernel = language_constant(language).new(:args => options[:args])
        stdout, stderr, process = kernel.run(input)
        raise stderr unless process.success?
        return stdout
        
      rescue Exception => error
        return Opener::Core::ErrorLayer.new(input, error.message, self.class).add
      end
    end

    protected

    ##
    # Extracts the language from a KAF document.
    #
    # @param [String] input
    # @return [String]
    #
    def language_from_kaf(input)
      reader = Nokogiri::XML::Reader(input)

      return reader.read.lang
    end

    ##
    # @param [String] language
    # @return [Class]
    #
    def language_constant(language)
      Opener::OpinionDetectors.const_get(language.upcase)
    end

    ##
    # @return [TrueClass|FalseClass]
    #
    def valid_language?(language)
      if language
        return Opener::OpinionDetectors.const_defined?(language.upcase)
      else
        return false
      end
    end
  end # OpinionDetector
end # Opener
