require File.expand_path('lib/combiner',File.dirname(__FILE__))
require File.expand_path('lib/modifier',File.dirname(__FILE__))
require 'csv'
require 'date'

def latest(name)
  files = Dir["#{ ENV["HOME"] }/workspace/*#{name}*.txt"]

  files.sort_by! do |file|
    last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
    last_date = last_date.to_s.match /\d+-\d+-\d+/

    date = DateTime.parse(last_date.to_s)
    date
  end

  throw RuntimeError if files.empty?

  files.last
end

class Processor
  LINES_PER_FILE = 120000
	DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }

	KEYWORD_UNIQUE_ID = 'Keyword Unique ID'

	def initialize(saleamount_factor, cancellation_factor)
		@saleamount_factor = saleamount_factor
		@cancellation_factor = cancellation_factor
	end

	def process(output, input)
		input = sort(input)

		input_enumerator = lazy_read(input)

		combiner = Combiner.new do |value|
			value[KEYWORD_UNIQUE_ID]
		end.combine(input_enumerator)

		merger = Modifier.new(@saleamount_factor, @cancellation_factor, combiner).modify

    done = false
    file_index = 0
    file_name = output.gsub('.txt', '')
    while not done do
		  CSV.open(file_name + "_#{file_index}.txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
			  headers_written = false
        line_count = 0
			  while line_count < LINES_PER_FILE
				  begin
					  merged = merger.next
					  if not headers_written
						  csv << merged.keys
						  headers_written = true
              line_count +=1
					  end
					  csv << merged
            line_count +=1
				  rescue StopIteration
            done = true
					  break
				  end
			  end
        file_index += 1
		  end
    end
	end

	private

	def parse(file)
		CSV.read(file, DEFAULT_CSV_OPTIONS)
	end

	def lazy_read(file)
		Enumerator.new do |yielder|
			CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
				yielder.yield(row)
			end
		end
	end

	def write(content, headers, output)
		CSV.open(output, "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
			csv << headers
			content.each do |row|
				csv << row
			end
		end
	end

	public
	def sort(file)
		output = "#{file}.sorted"
		content_as_table = parse(file)
		headers = content_as_table.headers
		index_of_key = headers.index('Clicks')
		content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
		write(content, headers, output)
		return output
	end
end

#modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
input = 'sample.txt'
modified = 'result.txt'
modification_factor = 1
cancellaction_factor = 0.4
processor = Processor.new(modification_factor, cancellaction_factor)
processor.process(modified, input)

puts "DONE processing"
