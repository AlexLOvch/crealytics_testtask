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
