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
  
  # 逆日歩情報を取得
  # :code 証券コード
  # :date 日付
  # :reload データ再取得(true or false)
  # :jsf 日証金取得ふらぐ(true or false)
  # :osf 大証金取得ふらぐ(true or false)
  def nipd(options={:all=>true, :jsf=>true, :osf=>true})
    if options.nil? or !options.is_a?(Hash)
      raise NipdException, "オプションがnil、もしくはハッシュじゃないです"
    end
    options[:jsf] = true if options[:jsf].nil?
    options[:osf] = true if options[:osf].nil?
    if options[:code].nil?
      options[:all] = true
    else
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
    end
    if options[:date].nil?
      # 前営業日のデータを取得する（ただし祝日は考慮してない）
      d = Date.today
      options[:date] = d - 1 if 2 <= d.wday and d.wday <= 5 # 火-金
      options[:date] = d - 2 if d.wday == 6 # 土
      options[:date] = d - 3 if d.wday == 0 # 日
      options[:date] = d - 3 if d.wday == 1 # 月
    end
    if !options[:date].is_a?(Date)
      begin
        options[:date] = Date.strptime(options[:date], '%Y/%m/%d')
      rescue
        raise NipdException, ":dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
      end
    end
    if options[:reload] != true
      options[:reload] = false
    end
    
    # 証券コード
    codes = options[:code]
    
    # 全取得
    all = options[:all] == true
      
    # 取得日時
    year = options[:date].year
    month = "%02d" % options[:date].month
    day = "%02d" % options[:date].day
    
    # 再取得
    reload = options[:reload]
      
    data = {}
    # 日証金から品貸料データを取得
    if options[:jsf]
      jsf_file = File.join(Dir.tmpdir, "/jsf#{year}#{month}#{day}.csv")
      if !File.exist?(jsf_file) or reload
        begin
          url = "http://www.jsf.co.jp/de/stock/dlcsv.php?target=pcsl&date=#{year}-#{month}-#{day}"
          open(url, "r:binary") do |doc|
            doc = doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
            raise if /指定された日付の品貸料率一覧表はありません/ =~ doc
            open(jsf_file, 'w') do |fp|
              fp.print doc
            end
          end
        rescue
          print "日証金データが見つからないです (#{url})\n"
        end
      end
      
      if File.exist?(jsf_file)
        CSV.open(jsf_file, 'r') do |csv|
          5.times do |i|
            csv.shift
          end
          csv.each do |row|
            row = row.map{|r| r.gsub(/(^(\s|　)+)|((\s|　)+$)/, '') if r.is_a?(String)} # 全角スペース対応
            next if row[8] == "*****" # 満額だったら飛ばす
            code = row[2]
            data[code] = NipdData.new(code, row[3], row[8], row[9])
          end
        end
      end
    end
      
    # 大証金から品貸料データを取得
    if options[:osf]
      osf_file = File.join(Dir.tmpdir, "/osf#{year}#{month}#{day}.csv")
      if !File.exist?(osf_file) or reload
        begin
          url = "http://www.osf.co.jp/debt-credit/pdf/ma715500#{year}#{month}#{day}.csv"
          open(url, "r:binary") do |doc|
            open(osf_file, 'w') do |fp|
              fp.print doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
            end
          end
        rescue
          print "大証金データが見つからないです (#{url})\n"
        end
      end
      
      if File.exist?(osf_file)
        CSV.open(osf_file, 'r') do |csv|
          3.times do |i|
            csv.shift
          end
          csv.each do |row|
            row = row.map{|r| r.gsub(/(^(\s|　)+)|((\s|　)+$)/, '') if r.is_a?(String)}
            code = row[2]
            data[code] = NipdData.new(code, row[3], row[6], row[5])
          end
        end
      end
    end
    
    results = {:date=>options[:date], :result=>{}}
    if all
      results[:result] = data
    else
      codes.each do |code|
        results[:result][code] = data[code]
      end
    end
    return results
  end
    
  module_function :nipd
end