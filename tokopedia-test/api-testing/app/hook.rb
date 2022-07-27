Before do |scenario|
  $scenario = scenario.name
  @api_endpoint ||= DataMagic.load 'api_endpoint.yml'
  $base_url = ENV['BASE_URL']
  @step_list = []
  @count_step = 0
  scenario.test_steps.each { |x| @step_list << x.text unless x.text.include? 'hook' }
  p "Will run scenario #{$scenario} from feature #{$feature}"
  $current_step = @step_list[@count_step]
end

AfterStep do
  @count_step += 1
  $current_step = @step_list[@count_step]
end
