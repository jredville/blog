module RailsEnvironment
  %w{development staging production}.each do |env|
    method_str = <<-EOM
                  def #{env}?
                    RAILS_ENV == "#{env}"  
                  end
                EOM
    eval method_str, binding, __FILE__, __LINE__
  end
  
  def env_test?
    RAILS_ENV=='test'
  end
  
  def selenium?
    ENV["SELENIUM"]
  end
  
  def load_test?
    ENV["LOAD_TEST"]
  end
end