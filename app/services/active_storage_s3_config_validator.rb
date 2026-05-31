# frozen_string_literal: true

require 'uri'

class ActiveStorageS3ConfigValidator
  REQUIRED_ENV_KEYS = %w[B2_ACCESS_KEY_ID B2_SECRET_ACCESS_KEY B2_REGION B2_BUCKET B2_ENDPOINT].freeze

  def self.missing_keys(env = ENV)
    REQUIRED_ENV_KEYS.select { |key| env[key].blank? }
  end

  def self.assert!(env = ENV)
    missing = missing_keys(env)
    raise KeyError, "Missing required Active Storage B2 env vars: #{missing.join(', ')}" unless missing.empty?

    return if valid_https_url?(env['B2_ENDPOINT'])

    raise ArgumentError, 'Invalid Active Storage B2 endpoint: B2_ENDPOINT must be an https URL'
  end

  def self.valid_https_url?(endpoint)
    uri = URI.parse(endpoint)
    uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
