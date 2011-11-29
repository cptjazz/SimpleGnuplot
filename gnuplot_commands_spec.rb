require './gnuplot_commands.rb'


class GnuplotCommandsHelper
	attr_reader :last_command
	
	include GnuplotCommands
	
	def send(command)
		@last_command = command
	end
end



helper = GnuplotCommandsHelper.new



describe "GnuplotCommands" do

	it "should set x-axis labels" do
		helper.xlabel = "Asdf"
		helper.last_command.should == 'se xl "Asdf"'
		
		helper.x_label = "Bsdf"
		helper.last_command.should == 'se xl "Bsdf"'
		
		helper.xlabel = 'I has "quotes"'
		helper.last_command.should == 'se xl "I has \"quotes\""'
	end
	
	it "should set y-axis labels" do
		helper.ylabel = "Asdf"
		helper.last_command.should == 'se yl "Asdf"'
		
		helper.y_label = "Bsdf"
		helper.last_command.should == 'se yl "Bsdf"'
		
		helper.ylabel = 'I has "quotes"'
		helper.last_command.should == 'se yl "I has \"quotes\""'
	end
	
	it "should set y2-axis labels" do
		helper.y2label = "Asdf"
		helper.last_command.should == 'se y2l "Asdf"'
		
		helper.y2_label = "Bsdf"
		helper.last_command.should == 'se y2l "Bsdf"'
		
		helper.y2label = 'I has "quotes"'
		helper.last_command.should == 'se y2l "I has \"quotes\""'
	end
	
	it "should set plot title" do
		helper.title = "Asdf"
		helper.last_command.should == 'se ti "Asdf"'
		
		helper.title = 'I has "quotes"'
		helper.last_command.should == 'se ti "I has \"quotes\""'
	end
	
	def _set_tics_helper(axis)
		pending("has to be re-implemented")
		
		
		helper.send "#{axis}tics!"
		helper.last_command.should == "se #{axis}ti"
		
		helper.send "#{axis}tics=", 2
		helper.last_command.should == "se #{axis}titi 2"
		
		helper.send "#{axis}tics=", [0, 2]
		helper.last_command.should == "se #{axis}titi 2,0"
		
		helper.send "#{axis}tics=", [0, 2, 10]
		helper.last_command.should == "se #{axis}titi 0,2,10"
		
		helper.send "#{axis}tics=", nil
		helper.last_command.should == 'uns yti'
	end

	it "should set y tics" do
		_set_tics_helper :y
	end
	
	it "should set x tics" do
		_set_tics_helper :x
	end
	
	it "should set z tics" do
		_set_tics_helper :z
	end
	
	it "should set x2 tics" do
		_set_tics_helper :x2
	end
	
	it "should set y2 tics" do
		_set_tics_helper :y2
	end
	
	it "should send replot command" do
		helper.replot
		helper.last_command.should == 're'
	end
	
	it "should send pause command" do
		helper.pause
		helper.last_command.should == 'pa -1'
		
		helper.pause 3
		helper.last_command.should == 'pa 3'
		
		helper.pause 9
		helper.last_command.should == 'pa 9'
	end
	
	it "should send exit command" do
		helper.exit
		helper.last_command.should == 'exit'
	end
	
	
end