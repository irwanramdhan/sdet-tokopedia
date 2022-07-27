module ApiBaseHelper
  private_class_method def self.execute(url, request, _request_body = nil)
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = 120
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request['apikey'] = $apikey
    request['content-type'] = 'application/json' unless url.request_uri.include? 'login'
    request['Authorization'] = $authheader
    request['Date'] = $authdate
    request['Digest'] = $authdigest
    request['X-Idempotency-Key'] = $authkey
    request['Cookie'] = $authcookie
    request['x-csrf-token'] = $authtoken

    # request.body = request_body.to_json unless request_body.nil?

    retries = 1
    begin
      response = http.request(request)
    rescue Exception => e
      p e.message
      retry if (retries += 1) < 5
      raise e.message if retries == 5
    end

    # response.body = JSON.parse(response.read_body) unless response.read_body.nil? || response.read_body.empty?
    # response

    begin
      response.body = JSON.parse(response.read_body)
      response
    rescue StandardError
      p 'response is not json'
      response
    end
  end

  def post(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Post.new(url)
    request.body = request_body.to_json unless request_body.nil?
    send(:execute, url, request, request_body)
  end

  def get(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Get.new(url)
    send(:execute, url, request, request_body)
  end

  def put(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Put.new(url)
    send(:execute, url, request, request_body)
  end

  def patch(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Patch.new(url)
    request.body = request_body.to_json unless request_body.nil?
    send(:execute, url, request, request_body)
  end

  def delete(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Delete.new(url)
    request.body = request_body.to_json unless request_body.nil?
    send(:execute, url, request, request_body)
  end

  def post_form_data(endpoint, request_body = nil)
    url = URI($base_url.to_s + endpoint)
    request = Net::HTTP::Post.new(url)
    request.set_form_data(request_body)
    send(:execute, url, request, request_body)
  end

  def update_testrail(credential, endpoint, request_body = nil)
    url = URI(credential['url'].to_s + endpoint)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request.basic_auth credential['user_name'], credential['access_key']
    request['content-type'] = 'application/json'
    request.body = request_body.to_json unless request_body.nil?
    response = http.request(request)
    response.body = JSON.parse(response.read_body) unless response.body.nil?
    response
  end

  def execute_payment(method, endpoint, request_body = nil)
    url = URI((ENV['BASE_URL_API_JP']).to_s + endpoint)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    case method
    when 'post'
      request = Net::HTTP::Post.new(url)
    when 'get'
      request = Net::HTTP::Get.new(url)
    when 'put'
      request = Net::HTTP::Put.new(url)
    when 'delete'
      request = Net::HTTP::Delete.new(url)
    when 'patch'
      request = Net::HTTP::Patch.new(url)
    end

    if $feature.downcase.include? 'jurnal pay'.downcase
      request['access-token'] = ENV['APIKEY_JP']
      request['Authorization'] = ENV['APIKEY_JP']
      request['content-type'] = 'application/json'
    else
      request['api-key'] = $apikey
    end
    request.body = request_body.to_json unless request_body.nil?
    response = http.request(request)

    response.body = JSON.parse(response.read_body) unless response.read_body.nil?

    response
  end

  def execute_xendit(method, virtual_account_id, request_body = nil)
    temp_url = ENV['BASE_URL_API_XENDIT'].gsub('va_id', virtual_account_id)
    url = URI(temp_url.to_s)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    case method
    when 'post'
      request = Net::HTTP::Post.new(url)
    when 'get'
      request = Net::HTTP::Get.new(url)
    when 'put'
      request = Net::HTTP::Put.new(url)
    when 'delete'
      request = Net::HTTP::Delete.new(url)
    when 'patch'
      request = Net::HTTP::Patch.new(url)
    end

    user_name = 'xnd_development_IM7csyG4m3cyPOUbpPm6UNu0z3ZkAesFGwgmucuy84PQKSRKlnYGe6Yj2Ja5UmB'

    request.basic_auth user_name, nil
    request['content-type'] = 'application/json'
    request.body = request_body.to_json unless request_body.nil?

    response = http.request(request)
    response.body = JSON.parse(response.read_body) unless response.read_body.nil?

    response
  end

  def parse_url(url, params)
    # Example:
    # stored url: https://my.jurnal.id/api/v1/module_name/{your_parameter}/action
    # params: 12345 or [12345] (use array for multiple parameters)
    #
    # Output: https://my.jurnal.id/api/v1/module_name/12345/action
    parsed_url = url
    if params.respond_to? :to_ary
      match = url.scan(/{.+?}/)
      params.each_with_index { |_p, index| parsed_url = parsed_url.gsub(match[index], params[index].to_s) }
    else
      parsed_url = url.gsub(/{.+}/, params.to_s)
    end
    parsed_url
  end

  def params_url(url, params)
    # Add ? in url as parameters in end of your line
    # Example: https://klikpajak-dev5.cd.jurnal.id/main/api/efaktur/out/initial_data
    # Params: issuedYear=2021
    # Output: https://klikpajak-dev5.cd.jurnal.id/main/api/efaktur/out/initial_data?issuedYear=2021
    parsed_url = url + '?' + params.to_s
    parsed_url
  end

  def init_report_automation_json_file
    @report_automation_json_root ||= File.absolute_path('./report/report_dashboard')
    @report_automation_json_file ||= File.absolute_path(@report_automation_json_root + "/report_automation#{ENV['TEST_ENV_NUMBER']}.json")

    return if File.file? @report_automation_json_file

    puts "=====:: Create report automation file #{@report_automation_json_file}"
    File.new(@report_automation_json_file, 'w+')
    json_format = { 'test_run_results' => [] }
    File.open(@report_automation_json_file, 'w') { |f| f.write(JSON.pretty_generate(json_format)) } if File.read(@report_automation_json_file).empty?
  end

  def update_report_automation_json(case_ids, status)
    array = JSON.parse(File.read(@report_automation_json_file)) unless File.read(@report_automation_json_file).empty?
    case_ids = case_ids.split(',')

    case_ids.each do |x|
      c_index = array['test_run_results'].index { |h| h['case_id'] == x }
      array['test_run_results'].delete_at(c_index) unless c_index.nil?
      hash = { 'case_id' => x, 'status' => status }
      array['test_run_results'] << hash
    end

    File.open(@report_automation_json_file, 'w') { |f| f.write(JSON.pretty_generate(array)) }
  end

  def execute_moka(method, endpoint, request_body = nil)
    url = if $scenario.include? 'ecoboard'
            URI("#{$base_url}v2/#{endpoint}")
          else
            URI("#{$base_url}v1/#{endpoint}")
          end
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    case method
    when 'post'
      request = Net::HTTP::Post.new(url)
    when 'get'
      request = Net::HTTP::Get.new(url)
    when 'put'
      request = Net::HTTP::Put.new(url)
    when 'delete'
      request = Net::HTTP::Delete.new(url)
    when 'patch'
      request = Net::HTTP::Patch.new(url)
    end

    request['jurnal-access-token'] = $access_token
    request['content-type'] = 'application/json'
    request.body = request_body.to_json unless request_body.nil?
    response = http.request(request)

    response.body = JSON.parse(response.read_body) if !response.body.nil? && validate_json(response.body)

    response
  end
end
