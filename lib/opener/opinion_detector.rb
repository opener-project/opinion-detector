require_relative "opinion_detector/version"
require "opener/opinion_detectors/base"
require "open3"

module Opener
  class OpinionDetector
    attr_reader :args
    attr_accessor :options
        
    def tag(text)
      language               = get_kaf_language(text)      
      opinion_detector       = opinion_detector_for_language(language)
      output, error, process = Open3.capture3(opinion_detector_text.command, :stdin_data=>text)
    end
    
    alias :run :tag
    
    protected

    def opinion_detector_for_language(language)
      Opener::OpinionDetectors.const_get(language.upcase).new
    end
    
    def get_kaf_language(text)
      reader = Nokogiri::XML::Reader(text)
      language = reader.read.lang
      check_language_support(language)
      return language
    end
    
    def check_language_support(language)
      abort "'#{language}' language is not supported." if !language_list.include?(language.downcase)
    end
      
    def language_list
      ['en', 'nl']
    end
  end
end
