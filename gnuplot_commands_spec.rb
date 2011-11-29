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
	end
	
	it "should set y-axis labels" do
		helper.ylabel = "Asdf"
		helper.last_command.should == 'se yl "Asdf"'
		
		helper.y_label = "Bsdf"
		helper.last_command.should == 'se yl "Bsdf"'
	end
	
	it "should set y2-axis labels" do
		helper.y2label = "Asdf"
		helper.last_command.should == 'se y2l "Asdf"'
		
		helper.y2_label = "Bsdf"
		helper.last_command.should == 'se y2l "Bsdf"'
	end
	
	
end