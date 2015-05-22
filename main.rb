# TODO organize methods... too sleepy now

# split 'file.mkv', from: '1:00', to: '2:00'
# split 'file.mkv', 60..120, 150..180
def split(file, *times)
	times.map do |time|
		out = split_name file, time

		split_one file, time, out
	end
end
	
def split_one(file, time, out)
	start, length, final = range_to_avconv time
	"avconv -i #{file} -ss #{start} -t #{length} #{out}"
end

def split_name(file, start, final)
	"#{base(file)}_#{start}_#{final}#{ext(file)}"
end

def merge_name(file, *times)
	"#{base(file)}_#{times.join '_'}#{ext(file)}"
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
	split(file, *times).map do |part|
		puts part
		system part
		split_name
	end
end

def merge(file, *times)
	parts = split!(file, *times)
	out   = merge_name(file, *times)
	system "mkvmerge -o #{out} #{parts}"
end

p range_to_avconv 60..100
p range_to_avconv 20..100
split! 'test.mkv', 1..3, 5..7


