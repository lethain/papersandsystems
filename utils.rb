require 'logger'
require 'openssl'
require 'digest/sha1'
require 'base64'
require 'cgi'
require 'securerandom'

UPLOAD_TOKEN_KEY = 'ad5b5ecb30391fb29294891f6b5e4cf6685fae26'.freeze
UPLOAD_TOKEN_IV = "yz\xF5\xCB\x0E\xB8\xE7\xD5'\x80h\x85Q\xCD)\x18".freeze

# monkey-patch Mysql2::Result to have empty? method to
# avoid rubocop rewrites breaking things
module Mysql2
  # Mysql2 Result class, need this to avoid bad
  # rubocop auto-rewrites
  class Result
    def empty?
      size.zero?
    end
  end
end

def extract_desc(s)
  acc = ''
  s.split("\n").each do |line|
    break if (line.strip == '') || acc.length > 300
    acc += line + ' '
  end
  acc.strip.gsub(/\[(.*)\]\(.*\)/, '\1').delete('*')
end

def upload_token(uid)
  ts = Time.now.to_i
  cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  cipher.encrypt
  cipher.key = UPLOAD_TOKEN_KEY
  cipher.iv = UPLOAD_TOKEN_IV
  encrypted = cipher.update("#{uid},#{ts}")
  encrypted << cipher.final
  CGI.escape(Base64.urlsafe_encode64(encrypted))
end

def decode_token(token)
  token = Base64.urlsafe_decode64(CGI.unescape(token))
  cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  cipher.decrypt
  cipher.key = UPLOAD_TOKEN_KEY
  cipher.iv = UPLOAD_TOKEN_IV
  decrypted = cipher.update(token)
  decrypted << cipher.final
  decrypted.split(',')
end

# Base model for MySQL models.
class PASModel
  def initialize(mysql, table)
    @table = table
    @m = mysql
    @log = Logger.new(STDERR)
  end

  def run(sql)
    begin
      results = @m.query(sql)
    ensure
      log(sql, results)
    end
    results
  end

  def get(col, val, fields = nil)
    return nil unless val
    val = escape(val)
    fields = fields ? fields.join(', ') : '*'
    sql = "SELECT #{fields} FROM #{@table} WHERE #{col}='#{val}' LIMIT 1"
    results = run(sql)
    !results.empty? ? results.first : nil
  end

  def list(opts = nil)
    opts = {} unless opts
    sort = opts[:sort] ? opts[:sort] : 'id'
    cols = opts[:cols] ? opts[:cols].join(', ') : '*'
    sql = "SELECT #{cols} FROM #{@table}"
    if opts[:where]
      filters = opts[:where].map do |k, v|
        "#{k}='#{escape(v)}'"
      end
      sql += " WHERE #{filters.join(' and ')}"
    end
    sql += " ORDER BY #{sort}"
    sql += " LIMIT #{opts[:limit]}" if opts[:limit]
    run(sql)
  end

  def update(id, kvs)
    sql = "UPDATE #{@table} SET "
    updates = kvs.map { |k, v| "#{k}='#{escape(v)}'" }
    sql += updates.join(', ')
    sql += " WHERE id='#{escape(id)}'"
    run(sql)
  end

  def incr(id, key)
    sql = "UPDATE #{@table} SET #{key} = #{key} + 1 WHERE id='#{escape(id)}'"
    run(sql)
  end

  def count(opts = nil)
    opts = opts ? opts : {}
    key = 'COUNT(id)'
    sql = "SELECT #{key} FROM #{@table}"
    if opts[:where]
      filters = opts[:where].map do |k, v|
        "#{k}='#{escape(v)}'"
      end
      sql += " WHERE #{filters.join(' and ')}"
    end

    res = run(sql).to_a
    if res.size && res[0].key?(key)
      res[0][key]
    else
      0
    end
  end

  def uuid
    SecureRandom.uuid
  end

  def log(sql, results)
    @log.debug("'#{sql}', #{results.to_a}")
  end

  def escape(val)
    if val.is_a? String
      @m.escape(val)
    else
      val
    end
  end

  def standard(s)
    @m.escape(s.gsub(/\W+/, ' ').strip)
  end
end
