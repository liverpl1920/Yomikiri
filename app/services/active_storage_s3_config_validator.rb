# frozen_string_literal: true

class ActiveStorageS3ConfigValidator
  REQUIRED_ENV_KEYS = %w[B2_ACCESS_KEY_ID B2_SECRET_ACCESS_KEY B2_REGION B2_BUCKET B2_ENDPOINT].freeze

  def self.missing_keys(env = ENV)
    REQUIRED_ENV_KEYS.select { |key| env[key].blank? }
  end

  def self.assert!(env = ENV)
    missing = missing_keys(env)
    return if missing.empty?

    raise KeyError, "Missing required Active Storage B2 env vars: #{missing.join(', ')}"
  end
end
