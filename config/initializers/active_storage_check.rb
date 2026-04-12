if Rails.env.production?
  %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET].each do |key|
    raise "Missing required environment variable: #{key}" unless ENV[key].present?
  end
end
