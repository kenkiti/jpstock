# coding: utf-8

module JpStock
  class SectorException < StandardError
  end

  class SectorData
    attr_accessor :code, :market, :company_name, :info, :id
    def initialize(code, market, company_name, info, id)
      @code = code # 証券コード
      @market = market # 市場
      @company_name = company_name # 会社名
      @info = info # 銘柄情報
      @id = id # 業種ID
    end
  end
  
  class Sector
    IDS = {'0050' => '農林・水産業',
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
  # :code
  # :id
  # :update
  def sector(options={})
    if options.nil? or !options.is_a?(Hash)
      raise SectorException, "オプションがnil、もしくはハッシュじゃないです"
    end
    sector_csv = File.join(File.dirname(__FILE__), 'sector.csv')
    if options[:update]
      # ブランド情報を更新
      sector_update(sector_csv)
    end
    if options[:code]
      options[:return_array] = true
      if !options[:code].is_a?(Array)
        options[:return_array] = false
        options[:code] = [options[:code]]
      end
      options[:code].map!{|code| code.to_s} # 文字列に変換
      options[:code].each do |code|
        if (/^\d{4}$/ =~ code).nil?
          raise SectorException, "指定された:codeの一部が不正です"
        end
      end
    end
    if options[:id]
      if options[:id].is_a?(Array)
        ids = Sector::IDS.keys & options[:id] # 正解のカテゴリだけ抽出
        if ids.empty?
          raise SectorException, "指定されたカテゴリが見つかりません"
        end
      else
        if Sector::IDS[options[:id]].nil?
          raise SectorException, "指定されたカテゴリが見つかりません"
        end
        ids = [options[:id]]
      end
    else
      ids = Sector::IDS.keys
    end
    codes = options[:code]
    
    # ファイルチェック
    unless File.exist?(sector_csv)
      # ブランド情報を更新
      sector_update(sector_csv)
    end
    
    # 証券コードをキーにしたハッシュをつくる
    data = {}
    CSV.open(sector_csv, 'r') do |csv|
      csv.each do |row|
        id = row[0]
        next unless ids.include?(id)
        data[row[1]] = SectorData.new(row[1], row[2], row[3], row[4], id)
      end
    end
    # 結果を返す
    results = []
    if codes
      codes.each do |code|
        results.push(data[code])
      end
      results = results[0] unless options[:return_array]
    else
      results = data.values
    end
    return results
  end
  
  # 銘柄情報を更新
  def sector_update(sector_csv)
    puts "銘柄情報を取得します..."
    results = {}
    ids = Sector::IDS.keys
    CSV.open(sector_csv, 'w') do |csv|
      ids.each do |id|
        results[id] = []
        30.times do |page|
          page += 1 # 1～の指定
          site_url = "http://stocks.finance.yahoo.co.jp/stocks/qi/?ids=#{id}&p=#{page}"
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
            next if [" ", "JASDAQ"].include?(row[1])
            csv << [id, row[0], row[1], row[2], row[3]]
          end
          sleep(0.5)
        end
      end
    end
  end
  
  module_function :sector, :sector_update
end
