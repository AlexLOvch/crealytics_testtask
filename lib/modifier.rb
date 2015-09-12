require File.expand_path('combiner',File.dirname(__FILE__))
require 'csv'
require 'date'

class String
  def from_german_to_f
    self.gsub(',', '.').to_f
  end
end

class Float
  def to_german_s
    self.to_s.gsub('.', ',')
  end
end

class Modifier
  LINES_PER_FILE = 120000
  DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }

  KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
  LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
  LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
  INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks', 'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
  FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
  COMMISSION_VALUES =['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value', 'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value']
  NUMBER_OF_COMMISSIONS = ['number of commissions']


  def initialize(saleamount_factor, cancellation_factor, enumerator)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
    @enumerator = enumerator
  end

  def modify
    Enumerator.new do |yielder|
      while true
        begin
          list_of_rows = @enumerator.next
          merged = combine_hashes(list_of_rows.map{|r|r.nil? ? nil : r.headers}, list_of_rows.map{|r|r.nil? ? nil : r.fields})
          yielder.yield(combine_values(merged))
        rescue StopIteration
          break
        end
      end
    end
  end

  private

=begin
  def combine(merged)
    result = []
    merged.each do |_, hash|
      result << combine_values(hash)
    end
    result
  end
=end

  def combine_values(hash)
    LAST_VALUE_WINS.each do |key|
      hash[key] = hash[key].last
    end
    LAST_REAL_VALUE_WINS.each do |key|
      hash[key] = hash[key].select {|v| not (v.nil? or v == 0 or v == '0' or v == '')}.last
    end
    INT_VALUES.each do |key|
      hash[key] = hash[key][0].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key][0].from_german_to_f.to_german_s
    end
    NUMBER_OF_COMMISSIONS.each do |key|
      hash[key] = (@cancellation_factor * hash[key][0].from_german_to_f).to_german_s
    end
    COMMISSION_VALUES.each do |key|
      hash[key] = (@cancellation_factor * @saleamount_factor * hash[key][0].from_german_to_f).to_german_s
    end
    p ""
    p "combine_values(hash): result: #{hash}"
    p ""
    hash
  end

  def combine_hashes(headers, list_of_data)
    keys = []
    headers.each do |header|
      next if header.nil?
      header.each do |key|
        keys << key
      end
    end
    result = {}
    keys.each do |key|
      result[key] = []
      list_of_data.each_with_index do |data, i|
        result[key] << (data.nil? ? nil : data[headers[i].index(key)])
      end
    end
    p ""
    p "combine_hashes(headers, list_of_data) result: #{result}"
    p ""
    result
  end

end