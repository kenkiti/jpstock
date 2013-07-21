# coding: utf-8

module JpStock
  class TdnetException < StandardError
  end
  
  class TdnetData
    attr_accessor :datetime, :code, :company_name, :title, :url, :gyouhai, :exchange, :xbrl
    def initialize(datetime, code, company_name, title, url, gyouhai, exchange, xbrl)
      @datetime = datetime # 日時
      @code = code # 証券コード
      @company_name = company_name # 会社名
      @title = title # 表題
      @url = url # PDFリンク
      @gyouhai = gyouhai # 業績・配当
      @exchange = exchange # 取引所
      @xbrl = xbrl # XBRLリンク
    end
  end
  
  # 適時開示情報を順番に取得
  # :code 証券コード
  # :date 日付
  def tdnet_each(options={})
    if options.nil? or !options.is_a?(Hash)
      raise TdnetException, "オプションがnil、もしくはハッシュじゃないです"
    end
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
          raise TdnetException, "指定された:codeの一部が不正です"
        end
      end
    end
    if options[:date].nil?
      options[:date] = Date.today
    end
    if !options[:date].is_a?(Date)
      begin
        options[:date] = Date.strptime(options[:date], '%Y/%m/%d')
      rescue
        raise TdnetException, ":dateはDate型かyyyy/mm/ddフォーマットの文字列じゃないとだめです"
      end
    end
    
    # 証券コード
    codes = options[:code]
    
    # 全取得
    all = options[:all] == true
      
    # 取得日時
    year = options[:date].year
    month = "%02d" % options[:date].month
    day = "%02d" % options[:date].day
    
    # 取得先URL
    root_url = "https://www.release.tdnet.info/inbs"
    
    results = []
    100.times do |i|
      num = "%03d" % (i+1)
      pageurl = "#{root_url}/I_list_#{num}_#{year}#{month}#{day}.html"

      print "Fetching #{pageurl}...\n"
      begin
          html = open(pageurl)
      rescue
          break
      end
      doc = Nokogiri::HTML(html)
      
      # 情報取得
      tables = doc.xpath('//table[@cellspacing="0"]')
      trs = tables[0].xpath('.//tr')
      trs.shift
  
      trs.each do |tr|
        tds = tr.xpath('.//td')
        row = tds.map{|td| td.content.strip}
        
        datetime = DateTime.strptime("#{year}/#{month}/#{day} #{row[0]} JST", '%Y/%m/%d %H:%M %Z') # 日付時刻
        code = row[1][0..3] # コード
        name = row[2] # 会社名
        title = row[3] # 表題
        url = tds[3].xpath('.//a') # 開示リンク先
        url = url.empty? ? "" :  "#{root_url}/"+url[0][:href]
        gyouhai = !row[4].empty? # 業績・配当
        xbrl = tds[5].xpath('.//a') # XBRLリンク先
        xbrl = xbrl.empty? ? "" : "#{root_url}/"+xbrl[0][:href]
        exchange = row[6] # 取引所
        
        if all
          yield TdnetData.new(datetime, code, name, title, url, gyouhai, exchange, xbrl)
        else
          if codes.include?(code)
            yield TdnetData.new(datetime, code, name, title, url, gyouhai, exchange, xbrl)
          end
        end 
      end
    end
  end
  
  # 適時開示情報をまとめて取得
  def tdnet(options={})
    results = []
    tdnet_each(options) do |tdnet|
      results.push(tdnet)
      sleep(0.3)
    end
    results
  end
  
  module_function :tdnet_each, :tdnet
end
