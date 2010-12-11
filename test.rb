module B
  def B.included
    puts "B was included"
  end
end


class A
  include B
end


