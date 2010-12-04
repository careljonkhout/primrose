require 'rubygems'
require 'rubygame'
require 'primrose'
require 'primrose_drawer'

class PrimroseMain
  include Dimensions     # SIDE, PADDING and BORDER
  include PrimroseDrawer

  def initialize
    @screen = Rubygame::Screen.new [7*SIDE+8*BORDER+2*PADDING,9*SIDE+11*BORDER+3*PADDING], 0, [Rubygame::SWSURFACE]
    @screen.title = "Primrose"
    @queue = Rubygame::EventQueue.new
    @queue.enable_new_style_events
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 30
    @primrose = Primrose.new
    @numerals = Rubygame::Surface.load 'numeralsBig.tga'
    draw_borders
  end
 
  def run
    update_screen
    loop do
      update
      @clock.tick
      if @wait_time
        unless @wait_time == 0
          @wait_time -= 1
        else
          update_screen_and_handle_secondary_effects
        end
      end
    end
  end
 
  def update
    @queue.each do |ev|
      case ev
      when Rubygame::Events::QuitRequested
        Rubygame.quit
        exit
      
      when Rubygame::Events::MousePressed
        pos = []
        ev.pos.each_with_index do |coor,i|
          coor   = coor - ( PADDING + BORDER )
          pos[i] = coor / ( SIDE    + BORDER )
        end
        x = pos[0]; y = pos[1]

        puts @locked
        if ( x >= 0 ) && ( y >= 0 ) && ( x <= 6 ) && ( y <= 6 ) && !@locked
          puts "clicked on: #{x}, #{y}"
          @primrose.move x, y
          update_screen_and_handle_secondary_effects
        elsif ( x == 7 ) && ( y == -1 )
          puts 'undo'
          @primrose.undo
          update_screen
        end
      end
    end
  end
 
  def update_screen_and_handle_secondary_effects
    update_screen
    @primrose.calculate_secondary_effects
    if @primrose.secondary_effects
      @locked = true
      @wait_time = 15
    else
      @locked = false
      @wait_time = nil
    end
  end

end

PrimroseMain.new.run
