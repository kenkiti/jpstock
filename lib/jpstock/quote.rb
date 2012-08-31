# coding: utf-8

module JpStock
  class QuoteException < StandardError
  end
  
  class QuoteData
    attr_accessor :company_name, :close, :prev_close, :open, :high, :low, :volume,
      :market_cap, :shares_issued, :dividend_yield, :dividend_one, 
      :per, :pbr, :eps, :bps, :price_min, :round_lot, :years_high, :years_low
    
    def initialize(company_name, close, prev_close, open, high, low, volume,
                  market_cap, shares_issued, dividend_yield, dividend_one, 
                  per, pbr, eps, bps, price_min, round_lot, years_high, years_low)
      @company_name = company_name # 会社名
      @close = to_int(close) # 現在終値
      @prev_close = to_int(prev_close) # 前日終値
      @open = to_int(open) # 始値
      @high = to_int(high) # 高値
      @low = to_int(low) # 安値
      @volume = to_int(volume) # 出来高
      @market_cap = to_int(market_cap) # 時価総額
      @shares_issued = to_int(shares_issued) # 発行済株式数
      @dividend_yield = to_float(dividend_yield) # 配当利回り
      @dividend_one = to_float(dividend_one) # 1株配当
      @per = to_float(per) # 株価収益率
      @pbr = to_float(pbr) # 純資産倍率
      @eps = to_float(eps) # 1株利益
      @bps = to_float(bps) # 1株純資産
      @price_min = to_int(price_min) # 最低購入代金
      @round_lot = to_int(round_lot, 1) # 単元株数
      @years_high = to_int(years_high) # 年初来高値
      @years_low = to_int(years_low) # 年初来安値
    end
    
    private
    def parse_num(val, default)
      /((-|)[0-9,\.]+)/ =~ val
      val = $1
      if val
        return val.gsub(',', '')
      end
      return default
    end
    
    def to_int(val, default=nil)
      val = parse_num(val, default)
      return val.nil? ? val : val.to_i
    end
    
    def to_float(val, default=nil)
      val = parse_num(val, default)
      return val.nil? ? val : val.to_f
    end
  end
  
  # 個別銘柄情報を取得
  def quote(options)
    if options.nil? or !options.is_a?(Hash)
      raise QuoteException, "オプションがnil、もしくはハッシュじゃないです"
    end
    if options[:code].nil?
      raise QuoteException, ":codeが指定されてないです"
    end
    if !options[:code].is_a?(Array)
      options[:code] = [options[:code]]
    end
    options[:code].map!{|code| code.to_s} # 文字列に変換
    options[:code].uniq!
    options[:code].each do |code|
      if (/^\d{4}$/ =~ code).nil?
        raise QuoteException, "指定された:codeの一部が不正です"
      end
    end
    codes = options[:code]
    
    results = {} # 証券コードをキーにしたハッシュを返す
    codes.each do |code|
      site_url = "http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}"
      html = open(site_url).read
      doc = Nokogiri::HTML(html)
      
      # 企業名抽出
      elm = doc.xpath('//table[@class="stocksTable"]/tr/th[@class="symbol"]/h1')
      company_name = elm.text.strip.gsub(/【.*】/,'')
      
      # 株価抽出
      close = doc.xpath('//table[@class="stocksTable"]/tr/td')[1].text.strip
      elms = doc.xpath('//div[@class="innerDate"]/div/dl/dd[@class="ymuiEditLink mar0"]/strong')
      prev_close = elms[0].text.strip
      open = elms[1].text.strip
      high = elms[2].text.strip
      low = elms[3].text.strip
      volume = elms[4].text.strip
      
      # 財務データ抽出
      elms = doc.xpath('//div[@class="chartFinance"]')
      elms = elms.xpath('.//div')
      
      data_field_num = 12
      if elms.length == data_field_num
        row = elms.map{|elm| elm.xpath('.//dd/strong').text }
        results[code] = QuoteData.new(company_name, close, prev_close, open, high, low, volume,
                                        row[0], row[1], row[2], row[3], row[4], row[5],
                                        row[6], row[7], row[8], row[9], row[10], row[11])
      end
      sleep(0.5)
    end
    return results
  end
  
  module_function :quote
end
