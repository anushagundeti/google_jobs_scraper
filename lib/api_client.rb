require 'httparty'

module ApiClient
  include HTTParty
  base_uri 'https://api.example.com'

  def self.fetch_data(endpoint)
    response = get(endpoint)
    if response.success?
      response.parsed_response
    else
      Rails.logger.error("API Error: #{response.code} - #{response.message}")
      nil
    end
  end
end