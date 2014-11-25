require 'open3'

require 'nokogiri'
require 'slop'
require 'opener/opinion_detectors/base'

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
    # @param [Hash] options
    #
    # @see [Opener::OpinionDetectors::Base#initialize]
    #
    def initialize(options = {})
      @options = options
    end

    ##
    # Processes the input KAF document and returns a new KAF document containing
    # the results.
    #
    # @param [String] input
    # @return [String]
    #
    def run(input)
      language = language_from_kaf(input)

      unless valid_language?(language)
        raise ArgumentError, "The specified language (#{language}) is invalid"
      end

      kernel = language_constant(language).new(kernel_options)

      return kernel.run(input)
    end

    protected

    ##
    # Returns the options to use for the kernel.
    #
    # @return [Hash]
    #
    def kernel_options
      return options.merge(:resource_path => models_path)
    end

    ##
    # Returns the path to the models to use.
    #
    # @return [String]
    #
    def models_path
      return options[:resource_path] || ENV['RESOURCE_PATH'] ||
        ENV['OPINION_DETECTOR_MODELS_PATH']
    end

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
