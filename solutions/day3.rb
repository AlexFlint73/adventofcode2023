# Class definitions

class SchemaParser
  def initialize(raw_data)
    @raw_data = raw_data
  end

  def self.call(raw_data)
    new(raw_data).call
  end

  def call
    @raw_data.split("\n").map do |raw_row|
      raw_row.each_char.map do |char|
        next char if char.to_i.to_s == char
        next nil if char == '.'
    
        char == '*' ? '*' : "#" # ignore anything except chars we're interested in
      end
    end
  end
end

class Sequence
  def initialize(schema, y)
    @schema = schema
    @y = y

    @value = ''
    @x_list = []
    @has_adjacent_symbol = false
  end

  def add(char, x)
    raise if char.is_a?(Integer)
    @x_list << x
    @value << char
  end

  def to_i
    @value.to_i
  end

  def valid?
    @has_adjacent_symbol
  end

  def analyze
    min_x, max_x = @x_list.minmax
  
    coords_to_check = 
      ((min_x - 1..max_x + 1).to_a).
        product((@y - 1..@y + 1).to_a).
        then { |coords| filter_valid_coords(coords) }

    coords_to_check.each do |check_x, check_y|
      process_char(@schema.data[check_y][check_x], check_x, check_y)
    end
  end

  private

  def filter_valid_coords(coords)
    coords.reject do |(check_x, check_y)|
      check_y == @y && @x_list.include?(check_x) ||
        check_x.negative? ||
        check_y.negative? ||
        check_x > @schema.max_x ||
        check_y > @schema.max_y
    end
  end

  def process_char(char, x, y)
    return if char.nil? || char.to_i.to_s == char

    @has_adjacent_symbol = true

    if char == '*' && @schema.gears.dig(x, y).is_a?(Gear)
      @schema.gears.dig(x, y).add(self)
    end
  end
end

class Gear
  def initialize
    @sequences = []
  end

  def add(sequence)
    @sequences << sequence
  end

  def valid?
    @sequences.count == 2
  end
  
  def gear_ratio
    return unless valid?

    @sequences[0].to_i * @sequences[1].to_i
  end
end


class Schema
  attr_reader :max_x, :max_y, :data, :gears

  def initialize(data)
    @data = data
    @max_x = data.first.length - 1
    @max_y = data.length - 1

    @sequences = []
    @gears = {}

    analyze
  end

  def self.init_from_raw_data(raw_data)
    new(SchemaParser.new(raw_data).call)
  end

  def sequences_sum
    @sequences.filter(&:valid?).map(&:to_i).sum
  end

  def gear_ratio_sum
    @gears.values.flat_map(&:values).filter(&:valid?).map(&:gear_ratio).sum
  end

  private

  def analyze
    current_sequence = nil

    @data.each_with_index do |row, y|
      row.each_with_index do |char, x|
        if char == '*'
          @gears[x] ||= {}
          @gears[x][y] = Gear.new
        end

        if char.to_i.to_s == char
          current_sequence ||= Sequence.new(self, y)
          current_sequence.add(char, x)
        end

        if char.to_i.to_s != char || x == @max_x
          next unless current_sequence
          
          @sequences << current_sequence
          current_sequence = nil
          
          next
        end
      end 
    end

    @sequences.each(&:analyze)
  end
end

# Solution

raw_data = File.read("tmp/test_data")
schema = Schema.init_from_raw_data(raw_data)

first_answer = schema.sequences_sum
second_answer = schema.gear_ratio_sum
