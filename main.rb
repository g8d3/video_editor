
defs = {
	c: :copy,
	i: nil,
}

# split 'file.mkv', from: '1:00', to: '2:00'
# split 'file.mkv', 60..120, 150..180
def split(file, *times)
	times.map do |time|
		start, length, final = range_to_avconv time
		
		out = "#{base(file)}_#{start}_#{final}#{ext(file)}"

		"avconv -i #{file} -ss #{start} -t #{length} #{out}"
	end
end

def base(file); file[/[^.]*/] end
def ext(file); File.extname file end

# 60..100 => '00:01:00', '00:00:40', '00:01:40'
def range_to_avconv(range)
	[
	int_to_avconv(range.begin),
	int_to_avconv(range.end - range.begin),
	int_to_avconv(range.end),
	]
end

def int_to_avconv(int)
	"%02i:%02i:%02i" % [int/3600, int/60 % 60, int % 60]
end

def split!(file, *times)
	split(file, *times).each do |part|
		puts part
		system part
	end
end

p range_to_avconv 60..100
p range_to_avconv 20..100
split! 'test.mkv', 1..3, 5..7


