require 'debug'
require 'excon'
require 'json'

class IpUpdater
  def initialize(config)
    @config = config
  end

  def run
    puts "Fetching my IP"
    @my_ip = get_my_ip
    puts "My IP is #{@my_ip}"

    if update_remote_ip
      puts "Successfully updated IP!"
    end
  end

  private

  def get_my_ip
    response = Excon.get('https://api.ipify.org', query: { format: 'json' })
    data = JSON.parse(response.body)
    data['ip']
  end

  def zone_id
    @config['zone_id']
  end

  def record_id
    @config['record_id']
  end

  def cloudflare_token
    @config['token']
  end

  def update_remote_ip
    payload = { content: @my_ip }

    response = Excon.patch("https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/#{record_id}",
      headers: {
        'Authorization' => "Bearer #{cloudflare_token}",
        'Content-Type' => 'application/json',
      },
      body: JSON.dump(payload)
    )

    return true if response.status == 200

    puts "Failed to update IP. Got status #{response.status}"
    puts "Response body: #{response.body}"
  end
end

config = JSON.parse(File.read "#{ENV['HOME']}/.config/dns-edit-config.json")
IpUpdater.new(config).run

