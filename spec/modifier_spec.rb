require File.expand_path('spec_helper', File.dirname(__FILE__))
require File.expand_path('../lib/modifier', File.dirname(__FILE__))
require File.expand_path('../lib/generator', File.dirname(__FILE__))
require File.expand_path('modifier_fixtures', File.dirname(__FILE__))

describe Modifier do
	#let!(:input_enumerator) { ([].tap{|a| 2.times{a << [Generator.generate_CSV_line, nil,  Generator.generate_CSV_line]}}).each }
	let!(:input_enumerator) { ModifierFixtures.csv_source.each }
	let(:modifier) { Modifier.new(1, 0.4, input_enumerator) }

	context "#modify" do
		subject { modifier.modify.to_a }

		context "should be processed as expected" do
			it {	should ==(ModifierFixtures::RESULT)	}
		end

	end
end
