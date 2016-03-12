# load 'google_cloud_vision.rb'
# api = GoogleCloudVision.new
# api.upload_file('sample.jpg') # file name under images folder

require 'dotenv'
require 'google/apis/drive_v2'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'base64'

class GoogleCloudVision

  Dotenv.load
  SERVICE_ACCOUNT_EMAIL = ENV['SERVICE_ACCOUNT_EMAIL']
  SERVICE_ACCOUNT_KEY = ENV['SERVICE_ACCOUNT_KEY']
  BROWSER_API_KEY = ENV['BROWSER_API_KEY']
  REQUEST_FILE_NAME = 'request.txt'
  FILE_FOLDER = 'images/'

  def initialize
  end

  def upload_file(file_name = 'sample.jpg')
    file_path = "#{FILE_FOLDER}#{file_name}"
    process_image_file(file_path, REQUEST_FILE_NAME)

    api_url = URI("https://vision.googleapis.com/v1/images:annotate?key=#{BROWSER_API_KEY}")
    http = Net::HTTP.new(api_url.host, api_url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(api_url)
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request.body = File.read(REQUEST_FILE_NAME)
    response = http.request(request)
    if response.code.start_with?('20')
      process_result(response.read_body)
    else
      fail "FAILED: #{response.read_body}"
    end
  end

  def process_image_file(file_path, request_file_name)
    image_file = Base64.encode64( File.open(file_path, 'rb') {|file| file.read } ).strip
    request_json = JSON.generate("requests" => [{
                                              "image" => { "content" => "#{image_file}" },
                                              "features" => [{ "type" => "LABEL_DETECTION", "maxResults" => 1 }]
                                            }])
    File.open(request_file_name,"w") do |f|
      f.write(request_json)
    end
  end

  def process_result(response_read_body)
    result = JSON.parse(response_read_body).to_hash
    description = result['responses'].first['labelAnnotations'].first['description']
    score = result['responses'].first['labelAnnotations'].first['score']
    puts "description: #{description}"
    puts "score: #{score}"
  end

end
