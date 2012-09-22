# coding: utf-8
# 信用情報: Credit
require 'csv'
require 'tmpdir'

module JpStock
  class CreditException < StandardError
  end
  
  # 信用情報データ
  class CreditData
    attr_accessor :code, :loan_new, :loan_return, :loan_balance,
                  :stock_new, :stock_return, :stock_balance,
                  :balance, :balance_prev, :security
    def initialize(code, loan_new, loan_return, loan_balance, 
                   stock_new, stock_return, stock_balance,
                   balance, balance_prev, security)
      @code = code # 証券コード
      @loan_new = loan_new.to_i # 融資新規
      @loan_return = loan_return.to_i # 融資返済
      @loan_balance = loan_balance.to_i # 融資残高
      @stock_new = stock_new.to_i # 貸株新規
      @stock_return = stock_return.to_i # 貸株返済
      @stock_balance = stock_balance.to_i # 貸株残高
      @balance = balance.to_i # 差引残高
      @balance_prev = balance_prev.to_i # 差引前日比
      @security = security # 証金
    end
  end
  
  # 信用情報を取得
  # :code 証券コード
  # :date 日付
  # :reload データ再取得(true or false)
  # :jsf 日証金取得ふらぐ(true or false)
  # :osf 大証金取得ふらぐ(true or false)
  def credit(options={:jsf=>true, :osf=>true})
    if options.nil? or !options.is_a?(Hash)
      raise CreditException, "オプションがnil、もしくはハッシュじゃないです"
    end
    options[:jsf] = true if options[:jsf].nil?
    options[:osf] = true if options[:osf].nil?
    if options[:code].nil?
      options[:all] = true
    else
      options[:return_array] = true
      if !options[:code].is_a?(Array)
        options[:return_array] = false
        options[:code] = [options[:code]]
      end
      options[:code].map!{|code| code.to_s} # 文字列に変換
      options[:code].each do |code|
        if (/^\d{4}$/ =~ code).nil?
          raise CreditException, "指定された:codeの一部が不正です"
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
        raise CreditException, ":dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
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
      
    # 日証金から品貸料データを取得
    jsf = {}
    if options[:jsf]
      jsf_file = File.join(Dir.tmpdir, "/jsfb#{year}#{month}#{day}.csv")
      if !File.exist?(jsf_file) or reload
        begin
          url = "http://www.jsf.co.jp/de/stock/dlcsv.php?target=balance&date=#{year}-#{month}-#{day}"
          open(url, "r:binary") do |doc|
            doc = doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
            raise if /指定された日付の融資・貸株残高一覧表はありません/ =~ doc
            open(jsf_file, 'w') do |fp|
              fp.print doc
            end
          end
        rescue
          puts "日証金データが見つからないです (#{url})"
        end
      end
      
      if File.exist?(jsf_file)
        CSV.open(jsf_file, 'r') do |csv|
          5.times do
            csv.shift
          end
          csv.each do |row|
            code = row[2]
            jsf[code] = CreditData.new(code, row[5], row[6], row[7], 
                                       row[8], row[9], row[10],
                                       row[11], row[12], 'jsf')
          end
        end
      end
    end
      
    # 大証金から品貸料データを取得
    osf = {}
    if options[:osf]
      osf_file = File.join(Dir.tmpdir, "/osfb#{year}#{month}#{day}.csv")
      if !File.exist?(osf_file) or reload
        begin
          url = "http://www.osf.co.jp/debt-credit/pdf/ma713500#{year}#{month}#{day}.csv"
          open(url, "r:binary") do |doc|
            open(osf_file, 'w') do |fp|
              fp.print doc.read.encode('utf-8', 'cp932', :invalid => :replace, :undef => :replace)
            end
          end
        rescue
          puts "大証金データが見つからないです (#{url})"
        end
      end
      
      if File.exist?(osf_file)
        CSV.open(osf_file, 'r') do |csv|
          3.times do
            csv.shift
          end
          csv.each do |row|
            code = row[3]
            osf[code] = CreditData.new(code, row[6], row[7], row[8], 
                                       row[10], row[11], row[12],
                                       row[13], row[14], 'osf')
          end
        end
      end
    end
    
    results = []
    if all
      results = jsf.values + osf.values
    else
      brands = JpStock.brand(:code=>codes)
      brands.each do |b|
        if b.nil?
          results.push(nil)
        elsif Util.is_jsf?(b.market)
          results.push(jsf[b.code])
        elsif Util.is_osf?(b.market)
          results.push(osf[b.code])
        else
          if jsf[b.code]
            results.push(jsf[b.code])
          elsif osf[b.code]
            results.push(osf[b.code])
          end
        end
      end
      results = results[0] unless options[:return_array]
    end
    return results
  end
  
  module_function :credit
end