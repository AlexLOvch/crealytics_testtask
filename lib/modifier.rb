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



class Merger
  def initialize(enumerator, fields_for_last, fields_for_last_real)
    @enumerator = enumerator
    @fields_for_last = fields_for_last
    @fields_for_last_real = fields_for_last_real
  end

  def merge
    Enumerator.new do |yielder|
      while true
        begin
          list_of_rows = @enumerator.next
          merged = merge_hashes(list_of_rows.map{|r|r.nil? ? nil : r.headers}, list_of_rows.map{|r|r.nil? ? nil : r.fields})
          yielder.yield(merged)
        rescue StopIteration
          break
        end
      end
    end
  end

  def merge_values(key, value_arr)
    if @fields_for_last.include?(key)
      value_arr.last
    elsif @fields_for_last_real.include?(key)
      value_arr.reject{|v| [0, '0', nil, ''].include?(v) }.last
    else
      value_arr[0]
    end
  end


  def merge_hashes(headers, list_of_datas)
    keys = headers.map{|h| h.nil? ? nil :  h}.compact.flatten.uniq
    result = {}
    keys.each do |key|
      result[key] = []
      list_of_datas.each_with_index do |data, i|
        result[key] << (data.nil? ? nil : data[headers[i].index(key)])
      end
      result[key] = merge_values(key, result[key])
    end
    result
  end
end


class Modifier
  KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
  LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
  LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
  INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks', 'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
  FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
  COMMISSION_VALUES = ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value', 'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value']
  NUMBER_OF_COMMISSIONS = ['number of commissions']


  def initialize(saleamount_factor, cancellation_factor, enumerator)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
    @enumerator = enumerator
  end

  def modify
    merger = Merger.new(@enumerator, LAST_VALUE_WINS, LAST_REAL_VALUE_WINS).merge

    Enumerator.new do |yielder|
      while true
        begin
          merged = merger.next
          yielder.yield(modify_values(merged))
        rescue StopIteration
          break
        end
      end
    end
  end

  private

  def modify_values(hash)
    INT_VALUES.each do |key|
      hash[key] = hash[key].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key].from_german_to_f.to_german_s
    end
    NUMBER_OF_COMMISSIONS.each do |key|
      hash[key] = (@cancellation_factor * hash[key].from_german_to_f).to_german_s
    end
    COMMISSION_VALUES.each do |key|
      hash[key] = (@cancellation_factor * @saleamount_factor * hash[key].from_german_to_f).to_german_s
    end
    hash
  end
end