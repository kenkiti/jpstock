# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JpStock, "株価を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.price(nil) }.to raise_error(JpStock::PriceException)
  end
  
  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.price(:code=>"3") }.to raise_error(JpStock::PriceException)
    expect{ JpStock.price(:code=>"abcd") }.to raise_error(JpStock::PriceException)
    expect{ JpStock.price(:code=>"123456") }.to raise_error(JpStock::PriceException)
    expect{ JpStock.price(:code=>["1", "a"]) }.to raise_error(JpStock::PriceException)
  end

  it "証券コードは文字列型であること" do
    o = JpStock.price(:code=>"4689")
    o.code.instance_of?(String).should == true
  end

  it "始値, 終値, 高値, 安値, 出来高は数値型であること" do
    o = JpStock.price(:code=>"4689")
    (o.open.instance_of?(Float) and o.open > 0).should == true
    (o.close.instance_of?(Float) and o.close > 0).should == true
    (o.high.instance_of?(Float) and o.high > 0).should == true
    (o.low.instance_of?(Float) and o.low > 0).should == true
    (o.volume.instance_of?(Float) and o.volume >= 0).should == true
  end

  it "日付は日付型であること" do
    o = JpStock.price(:code=>"4689")
    (o.date.instance_of?(Date)).should == true
  end
  
end

describe JpStock, "過去の株価を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.historical_prices(nil) }.to raise_error(JpStock::HistoricalPricesException)
  end

  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.historical_prices(:code=>"3", :all=>true) }.to raise_error(JpStock::HistoricalPricesException)
    expect{ JpStock.historical_prices(:code=>"abcd", :all=>true) }.to raise_error(JpStock::HistoricalPricesException)
    expect{ JpStock.historical_prices(:code=>"123456", :all=>true) }.to raise_error(JpStock::HistoricalPricesException)
    expect{ JpStock.historical_prices(:code=>["1", "a"], :all=>true) }.to raise_error(JpStock::HistoricalPricesException)
  end

  it "allか日付が指定されていなかったら例外を投げるべき" do
    expect{ JpStock.historical_prices(:code=>"4689") }.to raise_error(JpStock::HistoricalPricesException)
  end
  
  it "日付の指定がおかしかったら例外を投げるべき" do
    expect{ JpStock.historical_prices(:code=>"4689", :start_date=>'2012/3', :end_date=>'2012/3/31') }.to raise_error(JpStock::HistoricalPricesException)
    expect{ JpStock.historical_prices(:code=>"4689", :start_date=>'2012/3/1', :end_date=>'2012/3') }.to raise_error(JpStock::HistoricalPricesException)
  end
  
  it "指定されたレンジタイプがおかしかったら例外を投げるべき" do
    expect{ JpStock.historical_prices(:code=>"4689", :all=>true, :range_type=>"abc") }.to raise_error(JpStock::HistoricalPricesException)
  end

  it "2012/11/30の株価データが一致すること" do
    o = JpStock.historical_prices(:code=>"4689", :start_date=>'2012/11/30', :end_date=>'2012/11/30')
    o.length.should == 1
    o = o[0]
    o.code.should == '4689'
    o.date.should == Date.new(2012, 11, 30)
    o.open.should == 281.5
    o.close.should == 276.8
    o.high.should == 281.7
    o.low.should == 276.8
    o.volume.should == 12363000.0
  end

  it "2012/1/1から3/31までの株価データ取得件数が一致すること" do
    o = JpStock.historical_prices(:code=>"4689", :start_date=>'2012/1/1', :end_date=>'2012/3/31')
    o.length.should == 61
  end
  
end

describe "セクター情報を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.sector(nil) }.to raise_error(JpStock::SectorException)
  end

  it "指定されたIDがおかしかったら例外を投げるべき" do
    expect{ JpStock.sector(:id => "abc") }.to raise_error(JpStock::SectorException)
    expect{ JpStock.sector(:id => ["abc", "def"]) }.to raise_error(JpStock::SectorException)
  end
  
end



describe "個別銘柄情報を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.quote(nil) }.to raise_error(JpStock::QuoteException)
  end

  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.quote(:code=>nil) }.to raise_error(JpStock::QuoteException)
    expect{ JpStock.quote(:code=>3) }.to raise_error(JpStock::QuoteException)
    expect{ JpStock.quote(:code=>"abcd") }.to raise_error(JpStock::QuoteException)
  end

end

describe "逆日歩を取得する場合" do

  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.nipd(nil) }.to raise_error(JpStock::NipdException)
  end
  
  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.nipd(:code=>3) }.to raise_error(JpStock::NipdException)
    expect{ JpStock.nipd(:code=>"abcd") }.to raise_error(JpStock::NipdException)
  end
  
  it "日付の指定がおかしかったら例外を投げるべき" do
    expect{ JpStock.nipd(:code=>"4689", :date=>'2012/3') }.to raise_error(JpStock::NipdException)
  end

end

describe "適時開示を取得する場合" do

  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.tdnet(nil) }.to raise_error(JpStock::TdnetException)
  end
  
  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.tdnet(:code=>3) }.to raise_error(JpStock::TdnetException)
    expect{ JpStock.tdnet(:code=>"abcd") }.to raise_error(JpStock::TdnetException)
  end

  it "日付の指定がおかしかったら例外を投げるべき" do
    expect{ JpStock.tdnet(:code=>"4689", :date=>'2012/3') }.to raise_error(JpStock::TdnetException)
  end

end

describe "信用情報を取得する場合" do

  it "オプションがnilだったら例外を投げるべき" do
    expect{ JpStock.credit(nil) }.to raise_error(JpStock::CreditException)
  end
  
  it "証券コードがおかしかったら例外を投げるべき" do
    expect{ JpStock.credit(:code=>3) }.to raise_error(JpStock::CreditException)
    expect{ JpStock.credit(:code=>"abcd") }.to raise_error(JpStock::CreditException)
  end
  
  it "日付の指定がおかしかったら例外を投げるべき" do
    expect{ JpStock.credit(:code=>"4689", :date=>'2012/3') }.to raise_error(JpStock::CreditException)
  end

end



