module GnuplotCommands

  def xlabel=(text)
    send(%Q{se xl "#{text}"})
  end
  alias :x_label= :xlabel=


  def ylabel=(text)
    send(%Q{se yl "#{text}"})
  end
  alias :y_label= :ylabel=


  def y2label=(text)
    send(%Q{se y2l "#{text}"})
  end
  alias :y2_label= :y2label=


  def ytics=(args)
    send("se yti #{args[0]}, #{args[1]}")
  end


  def y2tics=(args)
    send("se y2ti #{args[0]}, #{args[1]}")
    send("se yti nomi")
  end


  def xrange=(args)
    send "se xr [#{args[0]}:#{args[1]}]"
  end
  alias :x_range= :xrange=


  def yrange=(args)
    send "se yr [#{args[0]}:#{args[1]}]"
  end
  alias :y_range= :yrange=

    def y2range=(args)
    send "se y2r [#{args[0]}:#{args[1]}]"
  end
  alias :y2_range= :y2range=


  def set_log(text)
    send("se log #{text}")
  end


  def unset_log(text = "")
    send("uns log #{text}")
  end


  def set(arg)
    send("se #{arg}")
  end


  def unset(arg)
    send("uns #{arg}")
  end


  def load(script)
    send(%Q{l "#{script}"})
  end


  def title=(t)
    send(%Q{se tit "#{t}"})
  end


  def replot
    send("re")
  end


  def pause(l = -1)
    send("pa #{l}")
  end


  def exit
    send("exit")
  end
end