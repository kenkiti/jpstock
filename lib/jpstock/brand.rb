# coding: utf-8

module JpStock
  class BrandException < StandardError
  end

  class BrandData
    attr_accessor :code, :market, :company_name, :info
    def initialize(code, market, company_name, info)
      @code = code # 証券コード
      @market = market # 市場
      @company_name = company_name # 会社名
      @info = info # 銘柄情報
    end
  end
  
  class Brand
    CATEGORIES = {'0050' => '農林・水産業',
           '1050' => '鉱業',
           '2050' => '建設業',
           '3050' => '食料品',
           '3100' => '繊維製品',
           '3150' => 'パルプ・紙',
           '3200' => '化学',
           '3250' => '医薬品',
           '3300' => '石油・石炭製品',
           '3350' => 'ゴム製品',
           '3400' => 'ガラス・土石製品',
           '3450' => '鉄鋼',
           '3500' => '非鉄金属',
           '3550' => '金属製品',
           '3600' => '機械',
           '3650' => '電気機器',
           '3700' => '輸送機器',
           '3750' => '精密機器',
           '3800' => 'その他製品',
           '4050' => '電気・ガス業',
           '5050' => '陸運業',
           '5100' => '海運業',
           '5150' => '空運業',
           '5200' => '倉庫・運輸関連業',
           '5250' => '情報・通信',
           '6050' => '卸売業',
           '6100' => '小売業',
           '7050' => '銀行業',
           '7100' => '証券業',
           '7150' => '保険業',
           '7200' => 'その他金融業',
           '8050' => '不動産業',
           '9050' => 'サービス業'}
  end
  
  # 銘柄情報を取得
  # :category
  # :all
  # :update
  def brand(options)
    if options.nil? or !options.is_a?(Hash)
      raise BrandException, "オプションがnil、もしくはハッシュじゃないです"
    end
    brand_csv = File.join(File.dirname(__FILE__), 'brand.csv')
    if options[:update]
      # ブランド情報を更新
      brand_update(brand_csv)
    end
    if options[:all]
      categories = Brand::CATEGORIES.keys
    else
      if options[:category].nil?
        raise BrandException, "カテゴリが指定されてません"
      end
      if options[:category].is_a?(Array)
        categories = Brand::CATEGORIES.keys & options[:category] # 正解のカテゴリだけ抽出
        if categories.empty?
          raise BrandException, "指定されたカテゴリが見つかりません"
        end
      else
        if Brand::CATEGORIES[options[:category]].nil?
          raise BrandException, "指定されたカテゴリが見つかりません"
        end
        categories = [options[:category]]
      end
    end

    # ファイルチェック
    unless File.exist?(brand_csv)
      # ブランド情報を更新
      brand_update(brand_csv)
    end
    
    # カテゴリをキーにしたハッシュをつくる
    data = {}
    CSV.open(brand_csv, 'r') do |csv|
      csv.each do |row|
        cat = row[0]
        data[cat] = [] if data[cat].nil?
        data[cat].push(BrandData.new(row[1], row[2], row[3], row[4]))
      end
    end
    
    results = {}
    categories.each do |category|
      results[category] = data[category]
    end
    return results
  end

  # 銘柄情報を更新
  def brand_update(brand_csv)
    results = {}
    categories = Brand::CATEGORIES.keys
    categories.each do |category|
      results[category] = []
      30.times do |page|
        page += 1 # 1～の指定
        site_url = "http://stocks.finance.yahoo.co.jp/stocks/qi/?ids=#{category}&p=#{page}"
        html = open(site_url).read
        doc = Nokogiri::HTML(html)
        trs = doc.xpath('//tr[@class="yjM"]')
        if trs.empty?
          break
        end
        
        data_field_num = 5
        trs.each do |tr|
          tds = tr.xpath('.//td')
          row = [
            tds[0].content.strip,
            tds[1].content.strip,
            tds[2].xpath('./strong').text.strip,
            tds[2].xpath('./span').text.strip
           ]
          results[category].push(BrandData.new(row[0], row[1], row[2], row[3]))
        end
        sleep(0.5)
      end
    end
    
    CSV.open(brand_csv, 'w') do |csv|
      results.keys.each do |cat|
        results[cat].each do |row|
          next if [" ", "JASDAQ"].include?(row.market)
          csv << [cat, row.code, row.company_name, row.market, row.info]
        end
      end
    end
    results
  end
  
  module_function :brand, :brand_update
end
