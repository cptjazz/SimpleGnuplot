require 'narray'
require 'thread'
require './NArray_Extensions.rb'
require './gnuplot_commands.rb'

class Gnuplot
  attr_accessor :replot

  def initialize(gnuplot_path = "pgnuplot", dump_file = nil)
    @gnuplot_path = gnuplot_path

    if dump_file
      @stream = File.new(dump_file, "w")
      @is_process = false
    else
      @stream = IO.popen(@gnuplot_path, "w")
      @is_process = true
    end

    @temp_files = []

    start_consumer
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


  def start_consumer
    @queue = Queue.new

    @consumer_thread = Thread.new do

      while(command = @queue.pop)
        @stream << command
        @stream.flush
      end
    end
  end

  include GnuplotCommands


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

  def get_plot_command
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
      send(%Q{#{get_plot_command} #{args[:f]} #{a}})
    else
      send(%Q{#{get_plot_command} "#{@temp_data ? '-' : @in_file}" #{a}})
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
    send(%Q{#{get_plot_command} "#{@temp_data ? '-' : @in_file}" #{a}})


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

  def send(command)
    @queue.push (command << "\n")
  end
  private :send


  def close
    while @queue.length > 0
      # waiting until all queued commands are processed
    end

    @stream.close
  end
end