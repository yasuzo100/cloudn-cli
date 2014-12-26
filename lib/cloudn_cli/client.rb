require "open-uri"
require "openssl"
require "base64"
require "json" #XXX: should i use Crack::JSON?
require "crack"

module Cloudn
  class Client
    def initialize(opt)
      @api_key    = opt[:api_key].freeze
      @secret_key = opt[:secret_key].freeze
      url = opt[:url]
      @url = url.is_a?(URI::HTTP) ? url : URI.parse(url)
      @url.freeze      
      @api_location = opt[:api_location].freeze
      @access_token = opt[:access_token].freeze
      @json       = opt[:json].freeze
    end

    attr_reader :json, :api_location, :access_token

    def get_raw(param_hash)
      param_str = make_param_str(param_hash)
      url = @url.dup
      url.query = param_str
      begin
        response_text = OpenURI.open_uri(url,
	:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
        "User-Agent" => "Cloudn_cli/#{RUBY_VERSION}",
        "X-api-location" => @api_location,
        "Authorization" => @access_token
        ).read
      rescue OpenURI::HTTPError => ex
        raise ex.exception("status: #{ex.message} desc: #{ex.io.meta["x-description"]}") # update error message in detail
      end
      return response_text
    end

    def get(param_hash)
      response_text = get_raw(param_hash)
      response = @json ? JSON.parse(response_text) : Crack::XML.parse(response_text)
      command = param_hash.fetch(:command).to_s
      command.downcase!
      key = command + "response"
      begin
        result = response.fetch(key)
      rescue KeyError => ex
        case key
        when "restorevirtualmachineresponse"
          key = "restorevmresponse"
        else
          raise ex
        end
        retry
      end
      return result
    end

    private

    def hash_to_param_str(param_hash)
      sorted_params = param_hash.sort_by(&:first) # sort by key
      param_str = sorted_params.flat_map {|k, v| "#{k}=#{v}" }.join("&")
      #return param_str
      string = URI.encode(param_str)
      #string = CGI::escape(param_str)
      string = string.gsub("/","%2f")
      string = string.gsub(":","%3a")
      string = string.gsub("[","%5b")
      string = string.gsub("]","%5d")
      pp string
      return string
    end

    def string_to_sign(param_hash)
      param_hash = param_hash.merge(apikey: @api_key)
      param_str = hash_to_param_str(param_hash)
      param_str.downcase!
      return param_str
    end

    def sign(param_hash)
      param_str = string_to_sign(param_hash)
      hmac = ::OpenSSL::HMAC::digest(::OpenSSL::Digest::SHA1.new, @secret_key, param_str)
      base64 = Base64.encode64(hmac).chomp
      return URI.encode(base64, "+=")
    end

    def make_param_str(param_hash)
      param_hash.merge!(response: :json) if @json
      signature = sign(param_hash)
      param_str = hash_to_param_str(param_hash)
      param_str.concat("&apiKey=#{@api_key}&signature=#{signature}")
      return param_str
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require "pp"

  config = YAML.load_file("config.yml")
  cs = Cloudn::Client.new(config)
  pp cs.get(command: :listServiceOfferings)
end
