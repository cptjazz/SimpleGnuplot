module GnuplotCommands

  def internal_set(k, v)
    send "se #{k} #{v}"
  end
  private :internal_set

  def escape(text)
    text.gsub('"', '\"')
  end

  def quote(text)
    %Q{"#{text}"}
  end

  def xlabel=(text)
    internal_set :xl, quote(escape(text))
  end
  alias :x_label= :xlabel=


  def ylabel=(text)
    internal_set :yl, quote(escape(text))
  end
  alias :y_label= :ylabel=


  def y2label=(text)
    internal_set :y2l, quote(escape(text))
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
    send(%Q{l "#{escape(script)}"})
  end


  def title=(t)
    internal_set :tit, quote(escape(t))
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


  def hold
    send "pa mouse"
  end
end