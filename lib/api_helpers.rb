require 'pp'
require 'yajl/json_gem'
require 'stringio'
require 'cgi'
require 'securerandom'
require 'pry'

$root = File.expand_path('../', File.dirname(__FILE__))

module APIHelpers
  STATUSES = {
    200 => '200 OK',
    201 => '201 Created',
    202 => '202 Accepted',
    204 => '204 No Content',
    205 => '205 Reset Content',
    301 => '301 Moved Permanently',
    302 => '302 Found',
    307 => '307 Temporary Redirect',
    304 => '304 Not Modified',
    401 => '401 Unauthorized',
    403 => '403 Forbidden',
    404 => '404 Not Found',
    405 => '405 Method not allowed',
    409 => '409 Conflict',
    422 => '422 Unprocessable Entity',
    500 => '500 Server Error'
  }

  DefaultTimeFormat = "%B %-d, %Y".freeze

  def strftime(time, format = DefaultTimeFormat)
    attribute_to_time(time).strftime(format)
  end

  def headers(status, head = {})
    css_class = (status == 204 || status == 404) ? 'headers no-response' : 'headers'
    lines = ["Status: #{STATUSES[status]}"]
    head.each do |key, value|
      lines << "#{key}: #{value}"
    end

    code_block(lines.join("\n"), class: css_class)
  end

  def json(json = nil, &block)
    hash = if block_given?
      JSON.load capture(&block)
    elsif json.is_a?(Hash)
      Hash[json.map { |k, v| [k.to_s, v] }]
    else
      json
    end

    html = code_block(JSON.pretty_generate(hash), class: "highlight", language: "javascript")
    concat(html, &block)
  end

  def xml(&block)
    xml = capture(&block)
    html = code_block(xml, language: "xml", class: "highlight")
    concat(html, &block)
  end

  def code_block(content, attributes = {})
    language = "language-#{attributes.delete(:language)}"
    attributes_html = attributes.map do |tuple|
      '%s="%s"' % tuple.map { |x| h(x.to_s) }
    end.join(" ")
    %(<pre #{attributes_html}><code class="#{language}">#{h(content.to_s)}</code></pre>)
  end

  def concat(string, &block)
    string &&= string.to_s
    if block.nil?
      string
    else
      eval('_erbout', block.binding) << string
    end
  end
end
