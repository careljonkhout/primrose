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
  attr_accessor :field, :next, :next_next, :secondary_effects, :score
  def initialize
    @score = 0
    @i = 0 # for debugging
    @colors = [:purple, :green, :orange]
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
    if @field[y][x].content == :empty && ( @next_next || @previous[0] == x || @previous[1] == y || is_a_special_case? )
      @previous = [x,y] if @next_next
      clicked_on = @field[y][x]
      clicked_on.content = @next
      @borders = []; @groups = []
      clicked_on.surrounding_squares.push(clicked_on).each do |square|
        puts "Square: #{square}"
        evaluate_square square
      end
      update_field
      update_score
      update_colors
    end
  end

  def calculate_secondary_effects
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
      @score += group.count
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
    else # if @next_next == nil
      @next, @next_next = @colors[rand @colors.length], @colors[rand @colors.length]
#      @next, @next_next = @colors[@i], @colors[@i]; @i = @i + 1; @i = @i % 3
    end
  end

end
