module Opener
  class OpinionDetector
    ##
    # CLI wrapper around {Opener::OpinionDetector} using Slop.
    #
    # @!attribute [r] parser
    #  @return [Slop]
    #
    class CLI
      attr_reader :parser

      def initialize
        @parser = configure_slop
      end

      ##
      # @param [Array] argv
      #
      def run(argv = ARGV)
        parser.parse(argv)
      end

      ##
      # @return [Slop]
      #
      def configure_slop
        return Slop.new(:strict => false, :indent => 2, :help => true) do
          banner 'Usage: opinion-detector [OPTIONS]'

          separator <<-EOF.chomp

About:

    Machine learning based opinion detection for various languages such as Dutch
    and English. This command reads input from STDIN.

Example:

    cat some_file.kaf | opinion-detector
          EOF

          separator "\nOptions:\n"

          on :v, :version, 'Shows the current version' do
            abort "opinion-detector v#{VERSION} on #{RUBY_DESCRIPTION}"
          end

          on :d=, :domain=, 'The domain to use for the models',
            :as      => String,
            :default => 'hotel'

          run do |opts, args|
            detector = OpinionDetector.new(
              :args   => args,
              :domain => opts[:domain]
            )

            input = STDIN.tty? ? nil : STDIN.read

            puts detector.run(input)
          end
        end
      end
    end # CLI
  end # OpinionDetector
end # Opener
