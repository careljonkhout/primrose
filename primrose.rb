class Square
  attr_accessor :u, :d, :l, :r, :row, :column, :content

  def initialize row, column
    @row = row; @column = column
    @content = :empty
  end

  def surrounding_squares
    if block_given?
      [u, d, l, r].each do |adjacent|
        yield adjacent if adjacent
      end
    else # if not block_given?
      [u, d, l, r].reject { |s| !s }
    end
  end

  def to_s; "[#{row}, #{column}] " end
end

class Primrose
  attr_accessor :field, :next, :next_next, :secondary_effects, :score, :second_phase_to_be_copied_onto_field
  def initialize
    @move_counter = 0
    @undo_stack = []
    @score = 0
    @i = 0 # for debugging
    @color_collection = [:purple, :green, :orange]
    update_colors
    f = @field = []

    7.times do |i|
      row = f[i] = Array.new
      7.times do |j|
        row[j] = Square.new(i,j)
      end
    end
    
    7.times do |i|
      row = f[i]
      6.times do |j|
        row[j].r = row[j+1]
        row[j+1].l = row[j]

        f[j][i].d = f[j+1][i]
        f[j+1][i].u = f[j][i]
      end
    end

  end

  def is_a_special_case?
    (0..6).all? { |i| ( @field[@previous[1]][i] != :empty ) and ( @field[i][@previous[0]] != :empty ) }
  end

  def move x, y
    if @field[y][x].content == :empty &&
        ( @next_next || @previous[0] == x || @previous[1] == y || is_a_special_case? )
      push_field
      @iteration = 1
      @previous = [x,y] if @next_next
      clicked_on = @field[y][x]
      clicked_on.content = @next
      @borders = []; @groups = []
      clicked_on.surrounding_squares.push(clicked_on).each do |square|
        puts "Square: #{square}"
        evaluate_square square
      end
      update_colors
      manage_color_collection
      @second_phase_to_be_copied_onto_field = ( @borders != [] )
      return true
    else
      return false
    end
  end
  
  def copy_second_phase_onto_field_and_update_score
    update_field
    update_score
  end
  
  def manage_color_collection
    @move_counter += 1
    if @move_counter == 96
      @color_collection << :red
    end  
  end

  def push_field
    squares = []
    @field.each do |row| row.each do |square|
      squares << square.content
    end; end
    @undo_stack << squares
    puts @undo_stack
  end

  def undo
    squares = @undo_stack.pop; i = 0
    @field.each do |row| row.each do |square|
      square.content = squares[i]; i += 1
    end; end
  end

  def calculate_secondary_effects
    @iteration += 1
    @borders, @groups = [], []
    @field.each { |row| row.each { |square| evaluate_square square } }
    update_field
    update_score
    @secondary_effects = ( @borders != [] )
  end

  def update_field
    @borders.each { |border| border[:squares].each { |s| s.content = border[:new_color] } }
    @groups.each { |g| g.each { |s| s.content = :empty } } # this must happen after borders.each { ... }
  end

  def update_score
    @groups.uniq!
    @groups.each do |group|
      size = group.count
      group_score_factor = (if size < 11 then 10 * size ** 0.5 else size + 21 end).round
      @score += group_score_factor * @iteration ** 4
    end
  end

  def evaluate_square square
    unless square.content == :empty
      stack = [square];
      group, border = [], []
      while stack != []
        puts "Stack: #{stack}"
        top_of_stack = stack.pop
        group << top_of_stack
        top_of_stack.surrounding_squares do |surrounding|
          if surrounding.content == top_of_stack.content
            stack << surrounding unless group.include? surrounding
          else border << surrounding end
        end
      end
      border.uniq!
      content_of_border = if border.first then border.first.content else nil end
      surrounded = content_of_border != :empty &&
                   ( border.all? { |s| s.content == content_of_border } )
      puts "Group:  #{group}"
      puts "Border: #{border}"
      puts surrounded
      if surrounded
        @borders << { :squares => border, :new_color => square.content }
        @groups << group
      end
    end
  end

  def game_over?
    @field.all? { |row| row.all? { |square| square.content != :empty } }
  end

  def update_colors
    if @next_next
      @next, @next_next = @next_next, nil
    else # if @next_next.nil?
      @next, @next_next = @color_collection.random, @color_collection.random
#      @next, @next_next = @colors[@i], @colors[@i]; @i += 1; @i %= 3
    end
  end

end

class Array
  def random
    self[rand length]
  end
end

