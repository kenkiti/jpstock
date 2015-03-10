# JpStock

JpStock is a Ruby library for extracting information about Japan stocks.

日本の株価情報を取得するためのRubyライブラリ。

## Installing

```
$ gem install jpstock
```

## Dependencies

```
ruby ~> 2.0.0
nokogiri ~> 1.6.6.2
```

## Using

現在の株価を取得
```ruby
JpStock.price(:code=>"4689")
JpStock.price(:code=>["4689", "2702"])
```

過去の株価を取得
```ruby
JpStock.historical_prices(:code=>"4689", :start_date=>'2012/01/01', :end_date=>'2012/3/31')
JpStock.historical_prices(:code=>"4689", :start_date=>Date.new(2012,1,1), :end_date=>Date.today)
JpStock.historical_prices(:code=>"4689", :all=>true)
```

セクター別銘柄情報を取得
```ruby
JpStock.sector(:id=>"0050")
JpStock.sector(:code=>'4689')
JpStock.sector(:update=>true)
```

個別銘柄情報を取得
```ruby
JpStock.quote(:code=>"4689")
```

逆日歩情報を取得
```ruby
JpStock.nipd()
JpStock.nipd(:code=>"4689")
JpStock.nipd(:code=>"4689", :date=>'2012/3/20')
JpStock.nipd(:code=>"4689", :date=>'2012/3/20', :reload=>true)
```

信用情報を取得
```ruby
JpStock.credit()
JpStock.credit(:code=>"4689")
JpStock.credit(:code=>"4689", :date=>'2012/9/22')
JpStock.credit(:code=>"4689", :date=>'2012/9/22', :reload=>true)
```

適時開示情報を取得
```ruby
JpStock.tdnet()
JpStock.tdnet(:date=>'2012/3/20')
JpStock.tdnet(:code=>'4689')
JpStock.tdnet(:code=>'4689', :date=>'2012/3/20')
JpStock.tdnet_each{|td| p td}
```

証券コードからEDINETコードを取得
```ruby
JpStock.sec2edi(:code=>'4689')
```

EDINETコードから証券コードを取得
```ruby
JpStock.edi2sec(:code=>'E05000')
```

## Copyright

Copyright (c) 2012-2015 utahta. See LICENSE.txt for further details.
