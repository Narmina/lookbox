require 'net/http'
require 'net/https'

class UrlValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field|
      url = record.send(field).try(:strip)
      next if url.blank?
      begin
        #url.prepend('http://') unless url =~ URI::regexp(%w(http https))
        raise URI::InvalidURIError.new('is Invalid. Should be started with http or https') unless url =~ URI::regexp(%w(http https))
        source = URI.parse(url)
        Net::HTTP.get_response(source)
      rescue URI::InvalidURIError => e
        #Bugsnag.notify(e)
        record.errors.add(field.to_sym, e.message || 'is Invalid')
      rescue SocketError
        record.errors.add(field.to_sym, 'is Invalid')
      end
    end
  end
end
