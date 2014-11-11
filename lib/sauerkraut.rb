require 'sauerkraut/version'
require 'colorize'

module Sauerkraut
  # DEFAULT OPTIONS
  @options = {
    :output => nil,
  }
  @banner = "\nUsage: sauerkraut FEATURE_FILE[:N][:M] [-o FILE]".cyan

  def self.display_help
    puts @banner
  end

  def self.exit_with_help(message)
    display_help
    puts message.red
    puts "\t(you specified " + "#{@args.join(" ")}".yellow + ")"
    exit
  end

  def self.get_output_file
    @args[(@args.find_index "-o") + 1]
  end

  def self.output_file?
    (
      (@args.include? "-o") &&
      (@args.last != "-o")
    )
  end

  def self.no_output_file_specified?
    (
      (@args.include? "-o") &&
      (@args.last == "-o")
    )
  end

  def self.no_feature_file?
    @args.count == 0
  end

  def self.invalid_feature_file?
    !(@args[0] =~ /\.feature(:\d+)?(:\d+)?/)
  end

  def self.feature_file_exists?
    File.file? @args.first.split(":").first
  end

  def self.no_line_number?
    !(@args[0].include? ":")
  end

  def self.invalid_range?
    (
      (@args[0] =~ /\.feature:\d+:/) &&
      !(@args[0] =~ /\.feature(:\d+)(:\d+)/)
    )
  end

  def self.range?
    @args[0] =~ /\.feature(:\d+)(:\d+)/
  end

  def self.is_line_scenario?(line)
    line =~ /Scenario/
  end


  def self.is_step_def?(line)
    line.strip =~ /^(Given|When|Then|And|But)/
  end

  def self.is_def?(line)
    line.strip =~ /^def /
  end

  def self.remove_first_word(line)
    a=line.split(" ")
    a.shift
    return a.join(" ")
  end

  def self.is_line_step_def?(line)
    line.strip =~ /^(Given|When|Then|And|But)/
  end

  def self.has_block_variables?(line)
    line.reverse.strip =~ /^\|/
  end

  def self.encomment(var)
    "# #{var}"
  end

  def self.enblank(var)
    ""
  end

  def self.array_trim(a)
    while (a.last.nil? or a.last.chomp == "")
      a.pop
    end
  end

  def self.enquote(var)
    "\"#{var}\""
  end


  def self.write_array_to_file(array, file)
    f = File.open(file,'w')
    array.each { |line| f.write "#{line.chomp}\n" }
    f.close
  end


  def self.colorize_output(output)
    output.map! do |line|
      if line =~ /^#/
        line.chomp.cyan
      else
        line
      end
    end
  end


  def self.highlight_bvar!(bvar, line)
    #line.gsub!(/([\W])(#{bvar})(\W)/) {|m| "#{$1}" + "#{bvar}".magenta + "#{$3}"}
    line.gsub!(/([\[\(-\/=\\& :\+\-])(#{bvar})([^\w]|\z)/) {|m| "#{$1}" + "#{bvar}".magenta + "#{$3}"}
  end

  def self.run(args)
    @args = args

    # PARSING
    exit_with_help("must specify a feature file") if no_feature_file?
    exit_with_help("must specify a valid feature file") if invalid_feature_file?
    exit_with_help("must specify an existing feature file") if !feature_file_exists?
    exit_with_help("specify range with :N:M") if invalid_range?

    exit_with_help("must specify an output file") if no_output_file_specified?
    @options[:output] = get_output_file if output_file?


    # get feature file
    if no_line_number?
      feature_file = @args[0]
      line_number = 0
      range_number = nil
    else
      feature_file = @args[0].split(":").first
      line_number = @args[0].split(":")[1].to_i
      range_number = range? ? (@args[0].split(":").last.to_i) : nil
    end
    feature_file_array = IO.readlines feature_file




    # if no lines, get entire file
    if no_line_number?
      steps = []
      feature_file_array[0..-1].each do |line|
        next if is_line_scenario?(line)
        steps << line.strip
      end
    else


      # if one line, get scenario
      if !range?
        exit_with_help("specify a line number that is a scenario") if !is_line_scenario?(feature_file_array[line_number-1])
        scenario = feature_file_array[line_number-1]
        steps = []
        feature_file_array[line_number..-1].each do |line|
          break if is_line_scenario?(line)
          steps << line.strip
        end
      end

      # if two lines, gather given when thens
      if range?
        steps = []
        feature_file_array[line_number..range_number].each do |line|
          next if is_line_scenario?(line)
          steps << line.strip
        end
      end

    end


    # get regexes
    pattern = /(?:Given|When|Then|And|But).+\/(.*)\/.+/
    pattern2 = /\/(.*)\//
    all_the_regexes = []
    stepfiles = File.join("**", "*steps.rb")
    Dir.glob(stepfiles) do |file|
      linenumber = 1
      File.open(file).each do |line|
        if line =~ pattern then
          regexstring = (line.scan pattern2).flatten.first
          regex = Regexp.new(regexstring)
          all_the_regexes << [regex, file, linenumber]
        end
        linenumber += 1
      end
    end


    # use stepfinder to find sources
    # compute block variables
    headlands = []
    steps.each do |step|
      next if !is_step_def?(step)
      all_the_regexes.each do |regexarr|
        if remove_first_word(step) =~ regexarr.first
          headlands << {
            :step => step,
            :sourcefile => regexarr[1],
            :lineno => regexarr[2],
            :block_vars => remove_first_word(step).scan(regexarr[0]).flatten,
          }
        end
      end
    end



    # get each code section from source
    headlands.each do |headland|

      # get code block
      patch = IO.readlines headland[:sourcefile]
      headland[:step_def] = patch[ headland[:lineno]-1]

      # get block variables
      if has_block_variables?( patch[headland[:lineno]-1])
        headland[:block_var_names] = patch[ headland[:lineno]-1].reverse.scan(/\|(.*?)\|/).flatten.first.reverse.split(",").map{|v| v.strip}
      else
        headland[:block_var_names] = nil
      end

      #step through until the next given when then,
      #  collecting the lines
      cabbage = []
      patch[ headland[:lineno]..-1].each do |line|
        break if (is_step_def?(line) || is_def?(line))
        cabbage << line
      end

      # comment bottoms of code sections
      end_reached = false
      cabbage.reverse!
      cabbage.map! do |line|
        break if end_reached
        if line =~ /end/
          end_reached = true
          #encomment(line)
          enblank(line)
        else
          line
        end
      end
      cabbage.reverse!
      array_trim(cabbage)
      headland[:cabbage] = cabbage

    end




    # display block variables
    # display cabbages

    output = []
    headlands.each do |headland|
      output <<  "#{encomment (headland[:sourcefile] + ":" + headland[:lineno].to_s)}"
      output <<  "#{encomment headland[:step_def]}"

      if headland[:block_var_names]
        output << "# block vars ------"
        headland[:block_var_names].each_with_index do |name,i|
          bvar = "#{name}"
          bvar = bvar.magenta if !@options[:output]
          line = bvar + " = #{enquote headland[ :block_vars][i]}"
          output << line
        end
        output << "# -----------------"
      end

      # search for block vars and highlight
      if !@options[:output] && headland[:block_var_names]
        cabbage = headland[:cabbage].map! do |line|
          headland[:block_var_names].each do |bvar|
            if line =~ /\W#{bvar}\W/
              highlight_bvar!(bvar, line)
            end
          end
          line
        end
      else
        cabbage = headland[:cabbage]
      end


      output += cabbage

      output <<  "\n"
    end




    # output to file
    if @options[:output]
      write_array_to_file(output, @options[:output])
      puts "output written to #{@options[:output]}"
    else
      puts colorize_output output
      #puts output
    end

  end


end
