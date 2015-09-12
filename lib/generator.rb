require File.expand_path('modifier', File.dirname(__FILE__))
require 'csv'

class Generator
  FIELDS = (Modifier.constants - [:LINES_PER_FILE, :DEFAULT_CSV_OPTIONS]).map{|c| Modifier.const_get(c)}.flatten.uniq
  FLOAT_FIELDS = Modifier::FLOAT_VALUES + Modifier::COMMISSION_VALUES + Modifier::NUMBER_OF_COMMISSIONS
  INT_FIELDS = Modifier::INT_VALUES + [Modifier::KEYWORD_UNIQUE_ID]

  def initialize(file_name, lines_cnt)
    @file_name, @lines_cnt = file_name, lines_cnt
  end

  def self.get_field_type(field)
    @field_types ||= {}
    @field_types[field] ||= FLOAT_FIELDS.include?(field) ? 'Float' : INT_FIELDS.include?(field) ? 'Integer' : 'String'
  end

  def self.get_random(klass)
  	case klass
      when 'Float'
      	(rand*rand(100)).to_german_s
  	 	when 'Integer'
  	 		rand(10)
			else
				(0..rand(10)).map{('a'..'z').to_a[rand(26)]}.join
  	end
  end

  def self.generate_line
    line = []
    FIELDS.each do |field|
      line << get_random(get_field_type(field))
    end
    line
  end

  def self.generate_line_hash
    Hash[FIELDS.zip generate_line]
  end

  def self.generate_CSV_line
    CSV::Row.new(FIELDS, generate_line)
  end


  def generate
    CSV.open(@file_name + ".txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
      csv << FIELDS
      @lines_cnt.times do
        csv << self.class.generate_line
      end
    end
  end
end


=begin
generator = Generator.new('sample1', 10)
generator.generate
p 'done'
=end
