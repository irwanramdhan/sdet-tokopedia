Given('user visit tokopedia as {string}') do |tokopedia_credential|
  # load user credential first
  DataMagic.load 'tokopedia_credential.yml'
  @tokopedia_credential = credential
  $user = (data_for "tokopedia_credential/#{tokopedia_credential}").with_indifferent_access
  $username = $user['username']
  $password = $user['password']

  if $current_user != $user['username']
    $authcookie = ''
    body = { 'username' => $username, 'password' => $password}
    $authcookie = response_login_process.response['Set-Cookie']
    visit_home = ApiBaseHelper.get(@api_endpoint['dashboard'])
    @token_homepage = visit_home.body.scan(/meta name="token" content=\"(.*)\"/)[0][0].to_s
    $authtoken = @token_homepage
  end
  $current_user = $user['username']
end