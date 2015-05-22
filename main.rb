# split 'file.mkv', 1..5, 10..15 { |command| start command }
def split(file, *times, &block)
	times.map  do |time|
		start  = int_to_avconv time.begin
		length = int_to_avconv(time.end - time.begin)
		out    = split_name file, time
		if block_given?
			yield "avconv -i #{file} -ss #{start} -t #{length} #{out}", out
		end
	end
end


def split_name(file, time)
	start = int_to_avconv time.begin
	final = int_to_avconv time.end
	"#{base(file)}_#{start}_#{final}#{ext(file)}"
end

def merge_name(file, *times)
	"#{base(file)}_#{times.join '_'}#{ext(file)}"
end

def base(file); file[/[^.]*/] end
def ext(file); File.extname file end

def int_to_avconv(int)
	"%02i:%02i:%02i" % [int/3600, int/60 % 60, int % 60]
end

def split!(file, *times, &block)
	split file, *times do |command, out|
		puts command
		system command
		yield out if block_given?
	end
end

# merge 'file.mkv', 60..120, 150..180
def merge(file, *times)
	parts = []
	split! file, *times do |out|
		parts << out 
	end
	parts = parts.join ' + '
	out   = merge_name(file, *times)
	system "mkvmerge -o #{out} #{parts}"
end

merge 'test.mkv', 1..3, 5..7
