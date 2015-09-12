require File.expand_path('spec_helper', File.dirname(__FILE__))
require File.expand_path('../lib/merger', File.dirname(__FILE__))
require File.expand_path('../lib/modifier', File.dirname(__FILE__))
#require File.expand_path('../lib/generator', File.dirname(__FILE__))
require File.expand_path('modifier_fixtures', File.dirname(__FILE__))

describe Modifier do
	#let!(:input_enumerator) { ([].tap{|a| 2.times{a << [Generator.generate_CSV_line, nil,  Generator.generate_CSV_line]}}).each }
	let!(:input_enumerator) { ModifierFixtures.csv_source.each }
	let(:modifier) { 

	  KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
	  LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
	  LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
	  INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks', 'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
	  FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
	  COMMISSION_VALUES = ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value', 'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value']
	  NUMBER_OF_COMMISSIONS = ['number of commissions']

    merger = Merger.new(input_enumerator, LAST_VALUE_WINS, LAST_REAL_VALUE_WINS).merge
    saleamount_factor = 1
    cancellation_factor = 0.4
		modifier_params = { stringify: INT_VALUES,
			multiply: [
				{ keys: COMMISSION_VALUES, by: (cancellation_factor * saleamount_factor)},
				{ keys: NUMBER_OF_COMMISSIONS, by: cancellation_factor}
			]
		}
		Modifier.new(merger, modifier_params)
	}

	context "#modify" do
		subject { modifier.modify.to_a }

		context "should be processed as expected" do
			it {	should ==(ModifierFixtures::RESULT)	}
		end

	end
end
