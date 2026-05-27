# frozen_string_literal: true

class ActiveStorageS3ConfigValidator
  REQUIRED_ENV_KEYS = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_S3_BUCKET].freeze

  def self.missing_keys(env = ENV)
    REQUIRED_ENV_KEYS.select { |key| env[key].blank? }
  end

  def self.assert!(env = ENV)
    missing = missing_keys(env)
    return if missing.empty?

    raise KeyError, "Missing required Active Storage S3 env vars: #{missing.join(', ')}"
  end
end
