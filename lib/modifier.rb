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
    # params[:stringify] - array of keys name
    # params[:multiply] array of hashes {keys=>[], by=>value}
  def initialize(enumerator, params={})
    @params = { stringify: [], multiply: [{}] }
    @params.merge!(params)
    @enumerator = enumerator
  end

  def modify
    Enumerator.new do |yielder|
      while true
        begin
          merged = @enumerator.next
          yielder.yield(modify_values(merged))
        rescue StopIteration
          break
        end
      end
    end
  end

  private

  def modify_values(hash)
    @params[:stringify].each do |key|
      hash[key] = hash[key].to_s
    end

    @params[:multiply].each do |multiplyer|
      multiplyer[:keys].each do |key|
        hash[key] = (multiplyer[:by] * hash[key].from_german_to_f).to_german_s
      end
    end
    hash
  end
end