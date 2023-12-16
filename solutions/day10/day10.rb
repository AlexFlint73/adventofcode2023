require 'pry'
# This was implemented for debug purposes, but it's really satisfying
# so I'll just leave this here
class MapDrawer
  def self.call(map)
    sleep 0.01
    print "\e[0;0H"  # Move the cursor to the top-left corner position
    print "\e[2J"   # Clear the entire screen
    print map.map { |x| x.join(" ") }.join("\n")
  end
end

class InitialMapBuilder
  def self.call
    raw_data = File.read("test_data")

    raw_data.split("\n").map do |raw_row|
      raw_row.split("")
    end
  end
end

module MoveLegality
  MOVES = {
    up: ->(x, y) { [x, y - 1]},
    down: ->(x, y) { [x, y + 1]},
    left: ->(x, y) { [x - 1, y] },
    right: ->(x, y) { [x + 1, y ]}
  }
  POSSIBLE_MOVES = %i[up down left right]


  LEGALITY_BY_SOURCE = {
    up: %w[| L J],
    down: %w[| F 7],
    left: %w[- J 7],
    right: %w[- F L]
  }

  LEGALITY_BY_DESTINATION = {
    up: %w[| 7 F],
    down: %w[| L J],
    left: %w[- L F],
    right: %w[- J 7]
  }

  private

  def legal_move?(current_position, move_type, map)
    x,y = current_position
    current_tile = map[y][x]
    current_tile = @starting_tile if current_tile == 'S'

    return false unless LEGALITY_BY_SOURCE[move_type].include?(current_tile)

    dest_x, dest_y = MOVES[move_type].call(x, y)

    return false if [dest_x, dest_y].any?(&:negative?)

    !map[dest_y][dest_x].nil?
  end

  def legal_move_by_destination?(destination, move_type, map)
    x, y = destination

    return false if [x, y].any?(&:negative?)

    destination_tile = map.dig(y, x)

    return false if destination_tile.nil?

    LEGALITY_BY_DESTINATION[move_type].include?(destination_tile)
  end
end


class MapTraverser
  include MoveLegality

  def initialize(map)
    @map = map

    # Fill manually
    @starting_tile = 'J'

    @starting_position = find_starting_position
    @traversed_map = @map.map do |row|
      row.dup
    end
  end

  def call
    traverse_map(0, @starting_position)

    @traversed_map
  end

  private

  def traverse_map(counter, position)
    queue = [[counter, position]]

    while !queue.empty?
      current_counter, current_position = queue.shift
      x, y = current_position

      current_value = @traversed_map[y][x]

      next if current_value.is_a?(Integer) && current_value <= current_counter

      @traversed_map[y][x] = current_counter

      legal_moves = find_legal_moves(current_position)

      legal_moves.each do |destination|
        queue.push([current_counter + 1, destination])
      end
    end
  end

  def find_legal_moves(current_position)
    x, y = current_position

    moves = POSSIBLE_MOVES.filter do |move_type|
      legal_move?(current_position, move_type, @map)
    end

    moves.map { |move_type| MOVES[move_type].call(x, y)}
  end

  def find_starting_position
    @map.each_with_index do |row, y|
      row.each_with_index do |value, x|
        next unless value == 'S'

        return [x, y]
      end
    end
  end
end

class MapNormalizer
  def self.call(map, traversed_map)
    new_map = map.map { |row| row.dup }

    traversed_map.each_with_index do |row, y|
      row.each_with_index do |value, x|
        next if value.is_a?(Integer)

        new_map[y][x] = '.'
      end
    end

    new_map
  end
end

class MapExtender
  include MoveLegality

  def initialize(map)
    @map = map
  end

  def call
    row_length = @map.first.length * 2 + 1

    @map = @map.flat_map do |row|
      [
        ['.'] * row_length,
        row.flat_map.flat_map { |value| ['.', value] }.push('.')
      ]
    end.push(['.'] * row_length)


    @map.map.with_index do |row, y|
      row.map.with_index do |value, x|
        next value unless value == '.'

        legal_move = %i[up down left right].find do |move_type|
          destination = MOVES[move_type].call(x, y)

          legal_move_by_destination?(destination, move_type, @map)
        end

        case legal_move
        when nil
          '.'
        when :up, :down
          '|'
        when :left, :right
          '-'
        end
      end
    end
  end
end

class MapFlattener
  def self.call(map)
    new_map = []
    map.each_with_index do |row, index|
      next if index.even?

      new_row = []
      row.each_with_index do |value, index|
        next if index.even?

        new_row << value
      end

      new_map << new_row
    end

    new_map
  end
end

class WhiteSpaceTraverser
  include MoveLegality

  def initialize(map)
    @map = map
    @starting_position = [0, 0]
  end

  def call
    traverse_map(@starting_position)

    @map
  end

  private

  def traverse_map(position)
    queue = [position]

    while !queue.empty?
      current_position = queue.shift
      x, y = current_position

      current_value = @map[y][x]

      next if current_value == 0

      @map[y][x] = 0

      legal_moves = find_legal_moves(current_position)

      legal_moves.each do |destination|
        queue.push(destination)
      end
    end
  end

  def find_legal_moves(position)
    x, y = position

    moves = POSSIBLE_MOVES.map do |move_type|
      destination = MOVES[move_type].call(x, y)

      destination
    end

    moves.each_with_object([]) do |destination, memo|
      next unless legal_non_path_move?(destination)

      memo << destination
    end
  end

  def legal_non_path_move?(destination)
    x, y = destination

    return false if [x, y].any?(&:negative?)

    destination_tile = @map.dig(y, x)

    return false if destination_tile.nil?

    destination_tile == '.'
  end
end


map = InitialMapBuilder.call
traversed_map = MapTraverser.new(map).call

max_value = 0
traversed_map.each do |row|
  row.each do |value|
    next unless value.is_a?(Integer)

    max_value = value if max_value < value
  end
end

puts "First answer is #{max_value}"

normalized_map = MapNormalizer.call(map, traversed_map)
extended_map = MapExtender.new(normalized_map).call

traversed_empty_map = WhiteSpaceTraverser.new(extended_map).call
flattened_map = MapFlattener.call(traversed_empty_map)

counter = 0
flattened_map.each do |row|
  row.each do |value|
    counter += 1 if value == '.'
  end
end

puts "Second answer is #{counter}"

