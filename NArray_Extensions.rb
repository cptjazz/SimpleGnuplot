require 'NArray'

class NArray
  def to_s
    s = "["
    self.each do |el|
      s << el.to_s + ", "
    end
    s.chop!.chop!
    s << "]"

    s
  end

  def to_gplot
    height = self.shape[1] || 1
    width = self.shape[0]
    s = ""

    height.times do |h|
      offset = h*width

      width.times do |w|
        s << self[offset + w].to_s + " "
      end
      s << "\n"
    end

    s
  end
end