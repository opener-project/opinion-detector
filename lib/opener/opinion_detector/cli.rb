require 'opener/core/resource_switcher'

module Opener
  class OpinionDetector
    ##
    # CLI wrapper around {Opener::OpinionDetector} using OptionParser.
    #
    # @!attribute [r] options
    #  @return [Hash]
    # @!attribute [r] option_parser
    #  @return [OptionParser]
    #
    class CLI
      attr_reader :options, :option_parser, :resource_switcher

      ##
      # @param [Hash] options
      #
      def initialize(options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @resource_switcher = Opener::Core::ResourceSwitcher.new

        @option_parser = OptionParser.new do |opts|
          opts.program_name   = 'opinion-detector'
          opts.summary_indent = '  '

          resource_switcher.bind(opts, @options)

          opts.on('-h', '--help', 'Shows this help message') do
            show_help
          end

          opts.on('-v', '--version', 'Shows the current version') do
            show_version
          end

          opts.on('-l', '--log', 'Enables logging to STDERR') do
            @options[:logging] = true
          end
        end

        option_parser.parse!(options[:args])
        resource_switcher.install(@options)
      end

      ##
      # @param [String] input
      #
      def run(input)
        option_parser.parse!(options[:args])

        tagger = OpinionDetector.new(options)

        stdout, stderr, process = tagger.run(input)

        if process.success?
          puts stdout

          if options[:logging] and !stderr.empty?
            STDERR.puts(stderr)
          end
        else
          abort stderr
        end
      end

      private

      ##
      # Shows the help message and exits the program.
      #
      def show_help
        abort option_parser.to_s
      end

      ##
      # Shows the version and exits the program.
      #
      def show_version
        abort "#{option_parser.program_name} v#{VERSION} on #{RUBY_DESCRIPTION}"
      end
    end # CLI
  end # OpinionDetector
end # Opener
