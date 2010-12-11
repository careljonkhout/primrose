require 'rubygems'
require 'rubygame'
require "#{File.dirname(__FILE__)}/primrose"
require "#{File.dirname(__FILE__)}/primrose_drawer"

class PrimroseMain
  include Dimensions     # SIDE, PADDING and BORDER
  include PrimroseDrawer

  def initialize
    @screen = Rubygame::Screen.new [7*SIDE+8*BORDER+2*PADDING,10*SIDE+13*BORDER+4*PADDING], 0, [Rubygame::SWSURFACE]
    @screen.title = "Primrose"
    (@queue = Rubygame::EventQueue.new).enable_new_style_events
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 30
    @primrose = Primrose.new
    @numerals = Rubygame::Surface.load "#{File.dirname(__FILE__)}/numeralsBig.tga"
    Rubygame::Color[:orange] = Rubygame::Color::ColorRGB.new_from_sdl_rgba([254,112,0  ,255])
    Rubygame::Color[:green ] = Rubygame::Color::ColorRGB.new_from_sdl_rgba([127,254,0  ,255])
    Rubygame::Color[:purple] = Rubygame::Color::ColorRGB.new_from_sdl_rgba([95, 0  ,190,255])
  end
 
  def run
    update_screen
    loop do
      update
      @clock.tick
      if @wait
        unless @wait == 0
          @wait -= 1
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
          if !@locked
            if ( x >= 0 ) && ( y >= 0 ) && ( x <= 6 ) && ( y <= 6 )
              puts "clicked on: #{x}, #{y}"
              if @primrose.move x, y
                update_screen
                handle_2nd_phase
              end
            elsif ( x == 7 ) && ( y == -1 )
              puts 'undo'
              @primrose.undo
              update_screen
            end
          end
        when Rubygame::Events::MouseMoved
          pos = []
          ev.pos.each_with_index do |coor,i|
            coor   = coor - ( PADDING + BORDER )
            pos[i] = coor / ( SIDE    + BORDER )
          end
          x = pos[0]; y = pos[1]
          if !@locked
            if ( x >= 0 ) && ( y >= 0 ) && ( x <= 6 ) && ( y <= 6 )
              @hover = pos
            else
              @hover = nil
            end
            update_screen
          end
      end
    end
  end
 
  def handle_2nd_phase
    if @primrose.second_phase_to_be_copied_onto_field
      @locked = true
      @wait = 15
      @primrose.copy_second_phase_onto_field_and_update_score
      @primrose.second_phase_to_be_copied_onto_field = false
    end
  end

  def update_screen_and_handle_secondary_effects
    update_screen
    @primrose.calculate_secondary_effects
    if @primrose.secondary_effects
      @locked = true
      @wait = 15
    else
      @locked = false
      @wait = nil
    end
  end

end

PrimroseMain.new.run
