module Dimensions
  SIDE = 48
  PADDING = 64
  BORDER = 2
end

module PrimroseDrawer
  include Dimensions

  def update_screen
    s = @screen
    start = PADDING + BORDER 
    finish = PADDING + BORDER + SIDE - 1
    stride = SIDE + BORDER
    7.times do |x|
      7.times do |y|
        content = @primrose.field[y][x].content
        s.draw_box_s(
          [ start  + x * stride, start  + y * stride ],
          [ finish + x * stride, finish + y * stride ],
          Rubygame::Color[if content == :empty then :black else content end]
        )
    end; end
    s.draw_box_s( 
      [PADDING + 3*STRIDE + BORDER    , 2 * PADDING + 2*BORDER + 7*STRIDE    ],
      [PADDING + 4*STRIDE          - 1, 2 * PADDING +   BORDER + 8*STRIDE - 1],
      Rubygame::Color[@primrose.next]
    )
    s.draw_box_s( 
      [PADDING + 3*STRIDE + BORDER    , 2 * PADDING + 2*BORDER + 8*STRIDE    ],
      [PADDING + 4*STRIDE          - 1, 2 * PADDING +   BORDER + 9*STRIDE - 1],
      Rubygame::Color[if @primrose.next_next then @primrose.next_next else :black end]
    )
    draw_score
    @screen.flip
  end

  def draw_score
    @screen.draw_box_s [0,0], [200,40], [0,0,0]
    score = @primrose.score
    10.times do |i|
      score, digit = score.divmod 10
      @numerals.blit @screen, [180-20*i,0], [6,40*digit,20,40]
    end      
  end

  STOP = 7*SIDE+8*BORDER+PADDING-1
  STRIDE = SIDE + BORDER
  GREY = [192,192,192]

  def draw_borders
    s = @screen
    8.times do |i|
      s.draw_box_s [PADDING, PADDING+i*(STRIDE)], [STOP, PADDING+BORDER-1+i*(STRIDE)], GREY
      s.draw_box_s [PADDING+i*(STRIDE), PADDING], [PADDING+BORDER-1+i*(STRIDE), STOP], GREY
    end
    s.draw_box_s(
      [PADDING + 3*STRIDE             , 2 * PADDING +   BORDER + 7*STRIDE    ],
      [PADDING + 4*STRIDE + BORDER - 1, 2 * PADDING + 2*BORDER + 9*STRIDE - 1],
      GREY
    )
  end
end
