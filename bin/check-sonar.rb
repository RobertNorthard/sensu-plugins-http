#!/usr/bin/env ruby
# encoding: UTF-8
#  check-sonar.rb
#
# DESCRIPTION:
#     Checks SonarQube API health check, http://localhost:9000/api/server/index?&format=json
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# check-sonar.rb --host https://host/
#
#

require 'sensu-plugin/check/cli'
require 'json'
require 'socket'
require 'net/http'
require 'net/http'
require 'net/https'
require 'uri'

class CheckSonar < Sensu::Plugin::Check::CLI
  check_name 'check_sonar'

  option :url,
         description: 'Hostname of server to check',
         short: '-u',
         long: '--url URL',
         required: true

  option :context,
         description: 'Web context',
         short: '-c',
         long: '--context /sonar',
         required: false
  
  def run
    check_api = '/api/server/index?&format=json'

    if config[:context] != nil
      check_api = config[:context] + '/api/server/index?&format=json'
    end
    
    uri          = URI.parse(config[:url] + check_api)
    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.kind_of?(URI::HTTPS)
    request      = Net::HTTP::Get.new(uri.request_uri)  
    response     = JSON.parse(http.request(request).body)

    message = "Sonar #{response['version']} status: "

    case response['status']
    when "UP"
      ok message + "OK."
    when "DOWN"
      crtical ok message + "Down."
    default
      warning message + "#{response['status']}"
    end
  end
end