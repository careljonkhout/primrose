class Square
  attr_accessor :u, :d, :l, :r, :row, :column, :content

  def initialize row, column
    @row = row; @column = column
    @content = :empty
  end

  def empty?
    content == :empty || content == :allowed
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

  def set_content_if content, content_if
    @content = content if @content == content_if
  end

  def to_s; "[#{row}, #{column}] " end
end

class Primrose
  attr_accessor :field, :next, :next_next, :secondary_effects, :score, :second_phase_to_be_copied_onto_field
  attr_accessor :color_collection
  def initialize
    @move_counter = 0
    @undo_stack = []
    @score = 0
    @i = 0 # for debugging
    @color_collection = [:purple, :green, :orange]
    @color_history = []
    update_colors
    f = @field = []
    @field_array = []
    7.times do |i|
      row = f[i] = Array.new
      7.times do |j|
         @field_array << row[j] = Square.new(i,j)
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
    (0..6).all? { |i| ( not @field[@previous[1]][i].empty? ) and ( not @field[i][@previous[0]].empty? ) }
  end

  def move x, y
    if @field[y][x].empty? &&
        ( @next_next || @previous[0] == x || @previous[1] == y || is_a_special_case? )
      @move_counter += 1
      push_field
      @iteration = 1
      @previous = [x,y] if @next_next
      clicked_on = @field[y][x]
      clicked_on.content = @next
      @borders = []; @groups = []
      clicked_on.surrounding_squares.push(clicked_on).each do |square|
        evaluate_square square
      end
      @second_phase_to_be_copied_onto_field = ( @borders != [] )
#      if @next_next
#        (0..6).each { |i| 
#          s = @field[@previous[1]][i];
#          s.content = :allowed if s.content == :empty
#          s = @field[i][@previous[0]];
#          s.content = :allowed if s.content == :empty
#        }
#      else
#        @field_array.each { |s| s.set_content_if :empty, :allowed }
#      end
      update_colors
      manage_color_collection
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
    case @move_counter
      when  96 then @color_collection << :red
      when 144 then @color_collection << :dark_green # 144 =  96 + 48
      when 168 then @color_collection << :pink       # 168 = 144 + 24
      when 180 then @color_collection << :gray       # 180 = 168 + 12
      when 186 then @color_collection[0] = nil
      when 194 then @color_collection[1] = nil
      when 200 then @color_collection[2] = nil
      when 206 then @color_collection[3] = nil
      when 212 then @color_collection[4] = nil
      when 218 then @color_collection[5] = nil
    end
  end

  def push_field
    squares = []
    @field.each do |row| row.each do |square|
      squares << square.content
    end; end
    @undo_stack << squares
  end

  def undo
    return unless @move_counter >= 1  
    @move_counter -= 1
    squares = @undo_stack.pop
    i = 0; @field.each do |row| row.each do |square|
      square.content = squares[i]; i += 1
    end; end
    update_colors
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
      @score += size * group_score_factor * @iteration ** 4
    end
  end

  def evaluate_square square
    unless square.content == :empty
      stack = [square];
      group, border = [], []
      while stack != []
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
    if @color_history.size == @move_counter
      if @next_next
        @next, @next_next = @next_next, nil
      else # if @next_next.nil?
        @next, @next_next = @color_collection.random, @color_collection.random
  #      @next, @next_next = @colors[@i], @colors[@i]; @i += 1; @i %= 3
      end
      @color_history << [@next, @next_next]
    else
      @next, @next_next = @color_history[@move_counter]
    end
  end

end

class Array
  def random
    compact = self.compact
    compact[rand compact.length]
  end
end

