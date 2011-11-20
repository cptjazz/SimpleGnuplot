require 'narray'
require './NArray_Extensions.rb'

class Gnuplot
  attr_accessor :synchronize
  attr_accessor :debug
  attr_accessor :replot

  def initialize(gnuplot_path = "pgnuplot", dump_file = nil)
    @gnuplot_path = gnuplot_path

    if dump_file
      @stream = File.new(dump_file, "w")
      @is_process = false
    else
      @stream = IO.popen(@gnuplot_path, "w")
      @is_process = true
      @stream.sync = true
    end

    @temp_files = []
    sleep 0.5
  end

  def Gnuplot.open(gnuplot_path = "gnuplot", &lambda)
    g = Gnuplot.new(gnuplot_path)

    if block_given?
      lambda.call(g)
      g.close
    end

    g
  end

  def Gnuplot.open_interactive(gnuplot_path = "pgnuplot", &lambda)
    g = Gnuplot.new(gnuplot_path)

    if block_given?
      lambda.call(g)
      g.close
    end

    g
  end

  def Gnuplot.dump_script_to(filename, &lambda)
    g = Gnuplot.new(nil, filename)

    if block_given?
      lambda.call(g)
      g.close
    end

    g
  end

  def load(script)
    send(%Q{l "#{script}"})
  end

  def terminal=(args)
    if args.length == 2
      send("se t #{args[0]} #{args[1]}")
    else
      send("se t #{args}")
    end

    @replot_not_first_plot = false
  end

  def output=(filename)
    send(%Q{se out "#{filename}"})
    @replot_not_first_plot = false
  end

  def xlabel=(text)
    send(%Q{se xl "#{text}"})
  end

  def ylabel=(text)
    send(%Q{se yl "#{text}"})
  end

  def y2label=(text)
    send(%Q{se y2l "#{text}"})
  end

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

  def yrange=(args)
    send "se yr [#{args[0]}:#{args[1]}]"
  end

  def y2range=(args)
    send "se y2r [#{args[0]}:#{args[1]}]"
  end

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

  def title=(t)
    send(%Q{se tit "#{t}"})
  end

  def pause(l = -1)
    send("pa #{l}")
  end

  def unset_output
    send("uns out")
    @stream.flush
    @replot_not_first_plot = false
  end
  alias :flush :unset_output

  def reset
    send("reset")
  end

  def with_file(in_file)
    @in_file = in_file
    self
  end

  def with_data(data)
    s = ""

    if data.is_a?(NArray)
      if data.dim == 1
        data.each do |x|
          s << x.to_s << "\n"
        end
      else
        s = data.to_gplot
      end
    else
      s = data.to_s
    end

    @temp_data = s
    self
  end

  def prepare_plot_command(args)
    local_args = args.clone

    if local_args.has_key? :title
      local_args[:title] = %Q{"#{args[:title]}"}
    end

    if local_args.has_key? :f
      local_args.delete :f
    end

    a = local_args.inject("") { |res, elem| res << elem[0].to_s << " " << elem[1].to_s << " " }
    a.gsub('title ""', 'notitle')
  end
  private :prepare_plot_command

  def _plot_command
    if @replot
      cmd = @replot_not_first_plot ? 'rep' : 'p'
      @replot_not_first_plot = true

      cmd
    else
      'p'
    end
  end

  def plot(args)
    a = prepare_plot_command(args)

    if args.has_key? :f
      send(%Q{#{_plot_command} #{args[:f]} #{a}})
    else
      send(%Q{#{_plot_command} "#{@temp_data ? '-' : @in_file}" #{a}})
    end

    if @temp_data
      send(%Q{#{@temp_data}\ne\n})
      @temp_data = nil
    end
  end

  def multiplot(arr)
    a = arr.collect do |args|
      prepare_plot_command args
    end

    a = a.join(', "" ')
    send(%Q{#{_plot_command} "#{@temp_data ? '-' : @in_file}" #{a}})


    arr.length.times do
      if @temp_data
        send(%Q{#{@temp_data}\ne\n})
      end
    end

    @temp_data = nil
  end

  def splot(args)
    a = prepare_plot_command(args)
    send(%Q{sp "#{@temp_data ? '-' : @in_file}" #{a}})

    if @is_process and @synchronize
      send("pr 1")
      tmp = @stream.readpartial(1)
      puts tmp
    end
  end

  def multisplot(arr)
    a = arr.collect do |args|
      prepare_plot_command args
    end

    a = a.join(%Q{, "#{@temp_data ? '-' : @in_file}" })
    send(%Q{sp "#{@temp_data ? '-' : @in_file}" #{a}})

    arr.length.times do
      if @temp_data
        send(%Q{#{@temp_data}\ne\n})
      end
    end

    @temp_data = nil
  end

  def replot
    send("re")
  end

  def send(command)
    @stream << (command << "\n")
  end
  private :send

  def hold
    send "pa mouse"
  end

  def close
    send("exit")
    @stream.close
  end
end