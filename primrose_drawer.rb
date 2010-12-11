module Dimensions
  SIDE = 48
  PADDING = 48
  BORDER = 4
end

module PrimroseDrawer
  include Dimensions

  def PrimroseDrawer.gray number
    Rubygame::Color::ColorRGB.new_from_sdl_rgba [number,number,number,255]
  end

  def PrimroseDrawer.included mod
    Rubygame::Color[:dark_gray] = gray 32
  end

  def update_screen
    s = @screen
    start = PADDING + BORDER 
    finish = PADDING + BORDER + SIDE - 1
    stride = SIDE + BORDER
    7.times do |x|
      7.times do |y|
        s.draw_box_s(
          [ start  + x * stride, start  + y * stride ],
          [ finish + x * stride, finish + y * stride ],
          Rubygame::Color[map_empties_to_dark_gray @primrose.field[y][x].content]
        )
    end; end
    s.draw_box_s( 
      [PADDING + 3*STRIDE + BORDER    , 2 * PADDING + 2*BORDER + 7*STRIDE    ],
      [PADDING + 4*STRIDE          - 1, 2 * PADDING +   BORDER + 8*STRIDE - 1],
      Rubygame::Color[map_empties_to_dark_gray @primrose.next]
    )
    s.draw_box_s( 
      [PADDING + 3*STRIDE + BORDER    , 2 * PADDING + 2*BORDER + 8*STRIDE    ],
      [PADDING + 4*STRIDE          - 1, 2 * PADDING +   BORDER + 9*STRIDE - 1],
      Rubygame::Color[map_empties_to_dark_gray @primrose.next_next]
    )
    draw_score
    @screen.flip
  end

  def map_empties_to_dark_gray input; if input == :empty || input.nil? then :dark_gray else input end end

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
  GREY = [64,64,64]

  def draw_borders
    s = @screen
#   s.draw_box [PADDING-2, PADDING-2], [PADDING+7*STRIDE+BORDER-1,PADDING+7*STRIDE+BORDER-1], Rubygame::Color[:white]    
#   s.draw_box [PADDING  , PADDING  ], [PADDING+7*STRIDE+BORDER+1,PADDING+7*STRIDE+BORDER+1], Rubygame::Color[:black]
#    8.times do |i|
#      s.draw_box_s [PADDING, PADDING+i*(STRIDE)], [STOP, PADDING+BORDER-1+i*(STRIDE)], GREY
#      s.draw_box_s [PADDING+i*(STRIDE), PADDING], [PADDING+BORDER-1+i*(STRIDE), STOP], GREY
#    end
#    s.draw_box_s(
#      [PADDING + 3*STRIDE             , 2 * PADDING +   BORDER + 7*STRIDE    ],
#      [PADDING + 4*STRIDE + BORDER - 1, 2 * PADDING + 2*BORDER + 9*STRIDE - 1],
#      GREY
#    )
  end
end
