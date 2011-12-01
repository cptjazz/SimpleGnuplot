# Simple Gnuplot

## Prerequisites
You need to have Gnuplot installed and the path to Gnuplot must be in your PATH environment variable.

`gem install narray`

SimpleGnuplot has built-in support for NArray data sets.
As of today, narray is always required. This may change in the future.

## Usages

### Using built-in functions
```ruby
Gnuplot.open do |gnuplot|
	gnuplot.xrange = [0, 2 * Math::PI]
	gnuplot.yrange = [-1, 1]
	
	gnuplot.title = "Sine wave"
	
	gnuplot.plot f: "sin(x)", with: :lines, linewidth: 2
	
	# Freeze the plot window until it is clicked
	gnuplot.hold
end
```

### Using a data set
```ruby
Gnuplot.open do |gnuplot|
	gnuplot.xrange = [0, 6]
	gnuplot.yrange = [0, 30]
	
	gnuplot.title = "Plot from data set"
	
	# Construct a data set.
	# Provide it in a format, Gnuplot is able to read.
	data = <<E
0 0
1 1
2 4
3 9
4 16
5 25
E
	
	gnuplot.with_data(data).plot using: "1:2", with: :lines
	
	# Freeze the plot window until it is clicked
	gnuplot.hold
end
```

### Using a NArray data set
```ruby
Gnuplot.open do |gnuplot|
	gnuplot.xrange = [0, 6]
	gnuplot.yrange = [0, 30]
	
	gnuplot.title = "Plot from NArray data set"
	
	array = NArray.float(2, 10).indgen

# Yields the following array:
#  [ [ 0.0, 1.0 ],
#    [ 2.0, 3.0 ],
#    [ 4.0, 5.0 ],
#    [ 6.0, 7.0 ],
#    [ 8.0, 9.0 ],
#    [ 10.0, 11.0 ],
#    [ 12.0, 13.0 ],
#    [ 14.0, 15.0 ],
#    [ 16.0, 17.0 ],
#    [ 18.0, 19.0 ] ]
  
	gnuplot.with_data(array).plot using: "1:2", with: :lines
	
	# Freeze the plot window until it is clicked
	gnuplot.hold
end
```