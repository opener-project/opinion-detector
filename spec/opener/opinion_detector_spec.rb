require 'spec_helper'

describe Opener::OpinionDetector do
  before do
    @invalid_language = <<-EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<KAF xml:lang="bacon" version="v1.opener"></KAF>
    EOF
  end

  context '#run' do
    example 'raise UnsupportedLanguageError for unsupported languages' do
      detector = described_class.new
      block    = -> { detector.run(@invalid_language) }

      block.should raise_error(
        Opener::Core::UnsupportedLanguageError,
        /The language "bacon"/
      )
    end
  end

  context '#language_from_kaf' do
    example 'return the language of a KAF document' do
      described_class.new.language_from_kaf(@invalid_language).should == 'bacon'
    end

    example 'return nil if the KAF document does not have a language' do
      input = '<KAF version="v1.opener"></KAF>'

      described_class.new.language_from_kaf(input).should be_nil
    end
  end
end
