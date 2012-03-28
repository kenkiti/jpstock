# coding: utf-8
# 逆日歩: Negative interest per diem
require 'csv'
require 'tmpdir'

module JpStock
  class NipdException < StandardError
  end
  
  class NipdData
    attr_accessor :code, :company_name, :price, :days
    def initialize(code, company_name, price, days)
      @code = code # 証券コード
      @company_name = company_name # 会社名
      @price = price.to_f # 品貸料率（円）
      @days = days.to_i # 品貸日数
    end
  end
  
  def nipd(options)
    if options.nil? or !options.is_a?(Hash)
      raise NipdException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise NipdException, ":codeが指定されてないです"
    end
    if !options[:code].is_a?(Array)
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].uniq!
    options[:code].each do |code|
      if (/^\d{4}$/ =~ code).nil?
        raise NipdException, "指定された:codeの一部が不正です"
      end
    end
    if options[:date].nil?
      options[:date] = Date.today - 1 # 1日前のデータ
    end
    if !options[:date].is_a?(Date)
      begin
        options[:date] = Date.strptime(options[:date], '%Y/%m/%d')
      rescue
        raise NipdException, ":dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
      end
    end
    codes = options[:code]
    
    # 取得日時
    year = options[:date].year
    month = "%02d" % options[:date].month
    day = "%02d" % options[:date].day
    
    # 日証金から品貸料データを取得
    jsf_file = Dir.tmpdir + "/jsf#{year}#{month}#{day}.csv"
    if !File.exist?(jsf_file)
      begin
        url = "http://www.jsf.co.jp/de/stock/dlcsv.php?target=pcsl&date=#{year}-#{month}-#{day}"
        open(url) do |doc|
          open(jsf_file, 'wb') do |fp|
            fp.print doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
          end
        end
      rescue
        raise NipdException, "日証金データを取得できませんでした (#{url})"
      end
    end
    
    # 大証金から品貸料データを取得
    tsf_file = Dir.tmpdir + "/tsf#{year}#{month}#{day}.csv"
    if !File.exist?(tsf_file)
      begin
        url = "http://www.osf.co.jp/debt-credit/pdf/ma715500#{year}#{month}#{day}.csv"
        open(url) do |doc|
          open(tsf_file, 'wb') do |fp|
            fp.print doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
          end
        end
      rescue
        raise NipdException, "大証金データを取得できませんでした (#{url})"
      end
    end
    
    data = {}
    CSV.open(jsf_file, 'rb') do |csv|
      5.times do |i|
        csv.shift
      end
      csv.each do |row|
        row = row.map{|r| r.strip if r.is_a?(String) }
        code = row[2]
        data[code] = NipdData.new(code, row[3], row[8], row[9])
      end
    end

    CSV.open(tsf_file, 'rb') do |csv|
      3.times do |i|
        csv.shift
      end
      csv.each do |row|
        row = row.map{|r| r.strip if r.is_a?(String) }
        code = row[2]
        data[code] = NipdData.new(code, row[3], row[6], row[5])
      end
    end
    
    results = {}
    codes.each do |code|
      results[code] = data[code]
    end
    return results
  end
  
  module_function :nipd
end