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

  def == content; @content == content end
end

class Primrose
  attr_accessor :field, :next, :next_next, :secondary_effects
  def initialize
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

  def to_s; 'Primrose' end

  def move x, y
    if @field[y][x] == :empty && ( @next_next || @previous[0] == x || @previous[1] == y )
      @previous = [x,y] if @next_next
      # sco: square clicked on
      sco = @field[y][x]
      sco.content = @next
      # ssosco's: surrounding square of square clicked on; includes sco
      @borders = []; @group_squares = []
      sco.surrounding_squares.push(sco).each do |ssosco|
        puts "Square: #{ssosco}"
        evaluate_square ssosco   
      end # of s.surrounding_squares.push(s).each do |s|
      update_field
      update_colors
    end # of if @field[y][x] == :empty
  end

  def calculate_secondary_effects
    @borders, @group_squares = [], []
    @field.each do |row| row.each do |square|
      evaluate_square square
    end; end
    @secondary_effects = ( @borders != [] )
    update_field
  end

  def update_field
    @borders.each do |border|
      border[:squares].each { |s| s.content = border[:new_color] }
    end
    @group_squares.each { |s| s.content = :empty } # this must happen after borders.each do ... end
  end

  def evaluate_square square
    unless square.content == :empty
      stack = [square];
      group, border = [], []
      while stack != []
        puts "Stack: #{stack}"
        # sotos: square on top of stack
        sotos = stack.pop
        group << sotos
        # ssosotos: surrounding squares of square on top of stack
        sotos.surrounding_squares do |ssosotos|
          if ssosotos.content == sotos.content
            stack << ssosotos unless group.include? ssosotos
          else border << ssosotos end
        end
      end
      border.uniq!
      content_of_border = nil
      content_of_border = border.first.content if border.first
      surrounded = 
        content_of_border != :empty &&
        content_of_border != square.content &&
        ( border.all? { |s| s.content == content_of_border } )
      puts "Group:  #{group}"
      puts "Border: #{border}"
      puts surrounded
      if surrounded
        @borders << { :squares => border, :new_color => square.content }
        @group_squares = @group_squares + group
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
      #@next, @next_next = @colors[rand @colors.length], @colors[rand @colors.length]
      @next, @next_next = @colors[@i], @colors[@i]
      @i = @i + 1
      @i = @i % 3
    end
  end

end
