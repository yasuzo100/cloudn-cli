module ShellHelpers
  def capture(command)
    Open3.capture3(script, stdin_data: command + "\n")
  end
  
  def capture_out(command)
    out, = capture(command)
    return out.chomp
  end

  def capture_err(command)
    _, err = capture(command)
    return err.chomp
  end
    
  def info(str)
    TermColor.colorize(str, :green)
  end

  def alert(str)
    TermColor.colorize(str, :red)
  end
  
  def decolorize(colorized_text)
    colorized_text.gsub(/\033\[(?:\d+(?:;\d+)*)*m/, "")
  end
end
