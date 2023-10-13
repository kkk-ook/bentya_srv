require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
    config.fog_credentials = {
            provider:              'AWS',
            aws_access_key_id:     Rails.application.credentials.dig(:aws, :access_key_id),
            aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
            region:                'ap-northeast-1'
    }
    config.storage = :fog
    if Rails.env.production?
        config.fog_directory = 'sennari'
    else
        config.fog_directory = 'sennari-dev'
    end
    config.fog_public = true
end