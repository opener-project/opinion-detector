require 'opener/opinion_detectors/base'
require 'open3'
require 'nokogiri'
require 'optparse'

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
      :args     => [],
      :fallback => 'en'
    }.freeze

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args Collection of arbitrary arguments to pass
    #  to the individual tokenizer commands.
    #
    # @option options [String] :fallback When set this language will be used as
    #  a fallback language, otherwise an error is raised instead.
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
      language = language_from_kaf(input)

      unless valid_language?(language)
        if options[:fallback]
          language = options[:fallback]
        else
          raise ArgumentError, "The specified language (#{language}) is invalid"
        end
      end

      kernel = language_constant(language).new(:args => options[:args])

      return Open3.capture3(kernel.command, :stdin_data => input)
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
      return Opener::OpinionDetectors.const_defined?(language.upcase)
    end
  end # OpinionDetector
end # Opener
