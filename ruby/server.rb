require 'webrick'
require_relative 'router'
require_relative 'database'



$policyInfo = '<?xml version="1.0"?>'
$policyInfo += '<cross-domain-policy>'
$policyInfo += '<allow-access-from domain="*" to-ports="8090" />'
$policyInfo += "</cross-domain-policy>\0"

class MyServlet < WEBrick::HTTPServlet::AbstractServlet
  @@conn = Database.instance
  def do_GET (request, response)
    @@conn.connect
    if request.query["xml"]
    xmlstring = request.query["xml"]
      @@conn.updateField(xmlstring)


    route         request.path,
                  request.query["id"],
                  request.query["type"],
                  request.query["x"],
                  request.query["y"],
                  request.query["contract"],
                  request.query["time"]
    response.status = 200
    response.content_type = "text/xml"
    response.body = @@conn.generate_xml_by_table + "\n" if (request.path!="/")

      elsif (request.path=="/crossdomain.xml")
      response.status = 200
        # @@conn.update_table
        response.content_type = "text/xml"
        response.body = $policyInfo + "\n"
    elsif request.path=='/get'
      response.body = @@conn.generate_xml_by_table + "\n"
      else
    response.body = File.new(request.path[1,request.path.size-1])
      end
      end
  end

server = WEBrick::HTTPServer.new(:Port => 8090)



server.mount "/", MyServlet

trap("INT") {
  puts "exit"
  server.shutdown
}
server.start
