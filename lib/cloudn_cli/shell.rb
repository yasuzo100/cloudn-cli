require "readline"
require "pp"
require "termcolor" # for simple colorize
require "coderay"   # for syntax highlight
require "rexml/document"
require "erb"
require "open-uri"
require "cgi"
require_relative "client"

module Cloudn
  class User
    def initialize(name, opt)
      @name       = name.freeze
      @api_key    = opt[:api_key].freeze
      @secret_key = opt[:secret_key].freeze
      url = opt[:url]
      @url = url.is_a?(URI::HTTP) ? url : URI.parse(url)
      @url.freeze      
      @api_location = opt[:api_location].freeze
      @access_token = opt[:access_token].freeze
    end

    attr_reader :name, :api_key, :secret_key, :url, :api_location, :access_token
  end

  class Shell
    class SyntaxError < StandardError; end

    def initialize(config_path)
      @config_path = config_path.freeze
      @xml_formatter = REXML::Formatters::Pretty.new(2)
      @xml_formatter.compact = true
      load_config
      create_client
      input_loop
    end
    
    attr_reader :config_path, :url, :json, :raw, :users, :current_user
    alias user current_user

    def json=(bool)
      @json = bool
      update_client
      return @json
    end
    
    def raw=(bool)
      @raw = bool
      update_client
      return @raw
    end

    def current_user=(user)
      user = user.to_sym
      @current_user = @users[user]
      update_client
      return @current_user
    end
    alias user= current_user=

    private

    def create_client
      @client = Cloudn::Client.new(
        url: @current_user.url,
        api_key: @current_user.api_key,
        secret_key: @current_user.secret_key,
        api_location: @current_user.api_location,
        access_token: @current_user.access_token,
        json: @json
      )
    end
    alias update_client create_client

    def load_config
      @config = YAML.load_file(@config_path)
      @url    = URI.parse(@config[:url])
      @json   = @config[:json]
      @raw    = @config[:raw_output]
      users   = @config[:users]
      @users  = {}
      users.each do |name_sym, opt|
        @users[name_sym] = User.new(name_sym.to_s, opt)
      end
      @current_user = @users.values.first
    end

    def make_param_hash(line)
      command, *params = line.split
      param_hash = { command: command }
      unless params.empty?
        opt_key_value = params.map do |param| 
          key, value = param.split("=", 2)
          raise SyntaxError, "Invalid Parameter: #{param}" unless value
          #[key.to_sym, CGI.escape(value)]
          [key.to_sym, value]
          #[key.to_sym, ERB::Util.u(value)]
        end
        opt_hash = Hash[opt_key_value]
        param_hash.merge!(opt_hash)
      end
      return param_hash
    end

    def syntax_highlight(str, lang)
      CodeRay.scan(str, lang).term
    end

    def raw_formatted_output(response_text)
      if @json
        response_hash = ::JSON.parse(response_text)
        pretty_json   = ::JSON.pretty_generate(response_hash)
        puts syntax_highlight(pretty_json, :json)
      else # XML
        response_xml  = ::REXML::Document.new(response_text)
        @xml_formatter.write(response_xml, formatted = "")
        puts syntax_highlight(formatted, :xml)
      end
    end

    def process_command(line)
      param_hash = make_param_hash(line)
      if @raw
        response_text = @client.get_raw(param_hash)
        raw_formatted_output(response_text)
      else
        response_hash  = @client.get(param_hash)
        PP.pp(response_hash, pretty_printed = "")
        puts syntax_highlight(pretty_printed, :ruby)
      end
    end

    def info(str)
      puts ::TermColor.colorize(str.to_s, :green)
    end

    def alert(str)
      warn ::TermColor.colorize(str.to_s, :red)
    end

    def change_format(format)
      case format
      when /json/i
        self.json = true
      when /xml/i
        self.json = false
      else
        raise ArgumentError, "undefined format: #{format}"
      end
    end

    def show_list_users
      @users.each do |name, user|
        if user == @current_user
          info "#{name} *"
        else
          info name
        end
      end
    end

    Usage = <<-EOS
Usage: command [parameter1=value2 parameter2=value2 ...]

Cloudn Cli Command:
  exit|quit:
    exit the shell
  config:
    show current config
  doc ${api_name}:
    show description for the API
  format (xml|json)?:
    show or change current format
  raw (true|false)?:
    enable/disable raw output
  user ${user_name}:
    switch user
  users:
    show users
  eval { # ruby code }:
    eval ruby code in Cloudn::Client instance context
    EOS

    NON_WHITESPACE_REGEXP = %r![^\s#{[0x3000].pack("U")}]!

    def process_line(line)
      return if line !~ NON_WHITESPACE_REGEXP # ignore bland line
      case line
      when "help"
        info Usage
      when "exit", "quit"
        exit
      when "config"
        PP.pp(@config, pretty_printed = "")
        puts syntax_highlight(pretty_printed, :ruby)
      when /^doc (.+)$/
        query = $1
        raise ArgumentError, "command not specified" unless query
        regexp = /^#{query}/i
        commands = APIList.select {|command| regexp =~ command }
        commands.each do |command|
          info command
          info APIParams[command][1]
          puts
        end
      when /^format ?(.+)?$/
        format_to_change = $1
        change_format(format_to_change.to_s) if format_to_change
        info "Current format is: #{@json ? "JSON" : "XML"}"
      when /^raw ?(.+)?$/
        raw = $1
        self.raw = (raw == "true") if raw
        info (@raw ? "Raw Output" : "Ruby's Hash Output")
      when /^user (.+)?$/
        user_to_change = $1
        self.user = $1 if $1
        info "Current user is: #{@current_user.name}"
      when "users"
        show_list_users
      when /^eval \{(.+)\}$/
        raise ArgumentError, "code is not specified" unless $1
        code = $1
        instance_eval(code)
      else
        process_command(line)
      end
    end

    # API infomation for completion
    APIParamsPath = File.expand_path("../api_list.json", __FILE__).freeze
    APIParams     = JSON.parse(File.read(APIParamsPath)).freeze
    APIList       = APIParams.keys.freeze
  
    # libedit(editline) in Mac OS X is broken.
    # its #line_buffer(rl_line_buffer) is not line buffer but a mere last line.
    CompletionProc = lambda do |line|
      words = line.split
      word  = words.last 
    
      case words.size
      when 0, 1 # command completion
        Readline.completion_append_character = " "
        regexp = /^#{word}/i
        return APIList.select {|key| regexp =~ key }
      else      # params completion
        Readline.completion_append_character = "="
        command          = words.first
        completing_param = words.pop
        regexp           = /^#{completing_param}/i
        api_params       = APIParams[command]
        return nil unless api_params
        no_required_params = api_params.first
        completed_params   = no_required_params.select {|param| regexp =~ param }
        return completed_params.map {|param| (words + [param]).join(" ") }
      end
    end

    def init_readline_completion
      Readline.basic_word_break_characters = "" # disable readline's word break
      Readline.completion_proc = CompletionProc
    end
   
    STTY = `stty -g`.chomp rescue nil
    TrapINT = lambda do |signum|
      trap(:INT) do
        (system("stty", STTY) rescue nil) if STTY # reset stty
        exit
      end
      puts "Interrupt again to exit"
    end

    def register_trap
      trap(:INT, &TrapINT)
    end

    PaddingLen = 10
    Padding = (" " * PaddingLen).freeze

    def input_loop
      init_readline_completion
      register_trap
      while line = Readline.readline("> ", true)
        register_trap if trap(:INT, nil) != TrapINT
        begin
          process_line(line)
        rescue => ex
          alert "Exception #{ex.class}: #{ex.message}"
          ex.backtrace.each {|trace| alert(Padding + trace) }
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  p Cloudn::Shell.new("../../config.yml")
end
