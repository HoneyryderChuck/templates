# Publish gems with HTTP

## Why?

Sometimes it's handy to automate a task, and not all gem servers are rubygems. 

## How?

```ruby
def publish(package_path, endpoint, *credentials)
  bounds = [('a'..'z'), ('A'..'Z'),('1'..'9')].map { |i| i.to_a }.flatten
  uri = URI(endpoint) # to POST here
  NET::HTTP.start(uri.host, use_ssl: true) do |server| # I hope it's using ssl, your alt gem server
    boundary = (0...6).map { bounds[rand(bounds.length)] }.join

    body = []
    body << "--#{boundary}\r\n"
    body << %Q{Content-Disposition: form-data; name="file"; filename="#{CGI.escape(File.basename(package_path))}"\r\n}
    body << "Content-Type: text/plain\r\n"
    body <<  "\r\n"
    body << File.read(package_path)
    body << "\r\n--#{boundary}--\r\n"

    req = Net::HTTP::Post.new(uri)
    req.basic_auth(*credentials)
    req["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

    req.body = body.join

    rep = server.request(req)

    code = response.code.to_i
    raise "if failed!" unless code < 300

    puts response.body
end

