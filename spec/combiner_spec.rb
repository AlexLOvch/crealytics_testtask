require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'combiner'

describe Combiner do
	let(:key_extractor) { Proc.new {|arg| arg} }
	let(:input_enumerators) { [] }
	let(:combiner) { Combiner.new(&key_extractor) }

	context "#combine" do
		subject { combiner.combine(*input_enumerators) }
	
		context "when an empty set of enumerators are combined" do
			let(:input_enumerators) { [] }
			it { should be_empty }
		end

		context "when all enumerators are empty" do
			let(:input_enumerators) { [enumerator_for(), enumerator_for()] }
			it { should be_empty }
		end

		context "when all enumerators have one element with the same key" do
			let(:input_enumerators) { [enumerator_for(1), enumerator_for(1)] }
			it { should_not be_empty }
			it "should return an array with the key-identical elements" do
				should return_elements [1,1]
			end
		end

		context "when all enumerators have a sequence of elements with the same key" do
			let(:input_enumerators) { [enumerator_for(1,2), enumerator_for(1,2)] }
			it { should_not be_empty }
			it "should return arrays with the key-identical elements" do
				should return_elements [1,1],[2,2]
			end
		end

		context "when all enumerators have a sequence of elements with the same key, but one is longer" do
			let(:input_enumerators) { [enumerator_for(1,2), enumerator_for(1,2,3)] }
			it { should_not be_empty }
			it "should return arrays with the key-identical elements" do
				should return_elements [1,1],[2,2],[nil,3]
			end
		end

		context "when all enumerators have same length but different elements" do
			let(:input_enumerators) { [enumerator_for(2), enumerator_for(1)] }
			it { should_not be_empty }
			it "should return arrays with the key-identical elements in the correct order" do
				should return_elements [nil,1],[2,nil]
			end
		end

		context "for a complex example using a key extractor" do
			let(:input_enumerators) { [enumerator_for(5,3,2,0), enumerator_for(5,4,3,1),enumerator_for(5,4)] }
			let(:key_extractor) { Proc.new {|number| -number} }
			it { should_not be_empty }
			it "should return arrays with the key-identical elements in the correct order" do
				should return_elements [5,5,5],[nil,4,4],[3,3,nil],[2,nil,nil],[nil,1,nil],[0,nil,nil]
			end
		end
	end
end
