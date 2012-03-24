# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "株価を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    lambda{ JpStock.price(nil) }.should raise_error(JpStock::PriceException)
  end

  it "証券コードがおかしかったら例外を投げるべき" do
    lambda{ JpStock.price(:code=>"3") }.should raise_error(JpStock::PriceException)
    lambda{ JpStock.price(:code=>"abcd") }.should raise_error(JpStock::PriceException)
    lambda{ JpStock.price(:code=>"123456") }.should raise_error(JpStock::PriceException)
    lambda{ JpStock.price(:code=>["1", "a"]) }.should raise_error(JpStock::PriceException)
  end
  
end

describe "過去の株価を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    lambda{ JpStock.historical_prices(nil) }.should raise_error(JpStock::HistoricalPricesException)
  end

  it "証券コードがおかしかったら例外を投げるべき" do
    lambda{ JpStock.historical_prices(:code=>"3", :all=>true) }.should raise_error(JpStock::HistoricalPricesException)
    lambda{ JpStock.historical_prices(:code=>"abcd", :all=>true) }.should raise_error(JpStock::HistoricalPricesException)
    lambda{ JpStock.historical_prices(:code=>"123456", :all=>true) }.should raise_error(JpStock::HistoricalPricesException)
    lambda{ JpStock.historical_prices(:code=>["1", "a"], :all=>true) }.should raise_error(JpStock::HistoricalPricesException)
  end

  it "allか日付が指定されていなかったら例外を投げるべき" do
    lambda{ JpStock.historical_prices(:code=>"4689") }.should raise_error(JpStock::HistoricalPricesException)
  end
  
  it "日付の指定がおかしかったら例外を投げるべき" do
    lambda{ JpStock.historical_prices(:code=>"4689", :start_date=>'2012/3', :end_date=>'2012/3/31') }.should raise_error(JpStock::HistoricalPricesException)
    lambda{ JpStock.historical_prices(:code=>"4689", :start_date=>'2012/3/1', :end_date=>'2012/3') }.should raise_error(JpStock::HistoricalPricesException)
  end
  
  it "指定されたレンジタイプがおかしかったら例外を投げるべき" do
    lambda{ JpStock.historical_prices(:code=>"4689", :all=>true, :range_type=>"abc") }.should raise_error(JpStock::HistoricalPricesException)
  end
  
end

describe "銘柄情報を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    lambda{ JpStock.brand(nil) }.should raise_error(JpStock::BrandException)
  end

  it "指定されたカテゴリーがおかしかったら例外を投げるべき" do
    lambda{ JpStock.brand(:category => "abc") }.should raise_error(JpStock::BrandException)
    lambda{ JpStock.brand(:category => ["abc", "def"]) }.should raise_error(JpStock::BrandException)
  end
  
end

describe "財務情報を取得する場合" do
  
  it "オプションがnilだったら例外を投げるべき" do
    lambda{ JpStock.finance(nil) }.should raise_error(JpStock::FinanceException)
  end

  it "証券コードがおかしかったら例外を投げるべき" do
    lambda{ JpStock.finance(:code=>nil) }.should raise_error(JpStock::FinanceException)
    lambda{ JpStock.finance(:code=>3) }.should raise_error(JpStock::FinanceException)
    lambda{ JpStock.finance(:code=>"abcd") }.should raise_error(JpStock::FinanceException)
  end

end
