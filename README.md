# AnywayanydayApi (Redirect)

Ruby gem for Anywayanyday XML-API (https://www.anywayanyday.com/partners/#commissioner) Redirect.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anywayanyday_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anywayanyday_api

## Usage

Create an initializer in config/initializers:

```ruby
# config/initializers/anywayanyday_api.rb
Anywayanyday.configure do |config|
  config.host = "http://api.anywayanyday.com/api"
  config.code = "testapic"
  config.currency = 'RUB'
  config.locale = 'RU'
end

```

where

 * `host` - Address anywayanyday system, for test "http://api.anywayanyday.com/api"
 * `code` - Your client id in anywayanyday system, for test "testapic"
 * `currency` - Display Language Answer: RU, EN.
 * `locale` - Value of the currency code view: RUB, USD, EUR, CHF, UAH.

And now in your controller you can do something like this:

```ruby
@api = Anywayanyday.api
```

### Initialization request

To define a search query, you must transfer the parameters of the route, the number of passengers and class of service.

```ruby
@api.fare_new_request(route: '2610DYRLON2811LONDYR', ad: 1, cn: 0, inf: 0,  sc: 'E')
```
Options:

 * `route` - Route containing points of departure, arrival, departure date and month. The route may comprise several sections, each of which is a set of ten consecutive symbols:
two characters day of departure with a leading zero; two characters month departure with leading zero; IATA code of the city or airport of departure; IATA code of the city or airport of departure; three characters - IATA code for the city or the airport of arrival.
 * `ad` - The number of adult passengers. A number from 1 to 6. The default value is 1.
 * `cn` - The number of children aged 2 to 12 years. A number from 0 to 4. The default value is 0.
 * `in` - The number of children aged from 2 weeks to 2 years. A number from 0 to 2. The default value is 0.
 * `sc` - Class service. Accepted values: E (Economy), B (business / first). Default value: E.

Restrictions:

 * The maximum number of route segments - 4.
 * The total number of passengers must not exceed 8.

### Details of the request

Getting parts search.

```ruby
data = @api.fare_request_info
puts [data.ad, data.cn, data.in, data.sc].join(', ')
data.directions.each do |direction|
  puts [direction.route, direction.dc, direction.dp, direction.ac, direction.ap, direction.dd].join(', ')
end
```

Sample answer:

```ruby
#<OpenStruct ad="1", cn="0", in="0", sc="E", directions=[#<OpenStruct route="DYRMOW", dc="Россия", dp="Анадырь", ac="Россия", ap="Москва", dd=Mon, 26 Oct 2015>, #<OpenStruct route="MOWDYR", dc="Россия", dp="Москва", ac="Россия", ap="Анадырь", dd=Sun, 29 Nov 2015>]>
```


### Status of the search

Obtaining the status of the search query. The recommended interval request - every 2 seconds.
Returns the exit status of the search terms the percentage (0 to 100).

```ruby
loop do
  break if @api.fare_request_state == 100
  sleep 2
end
```

### Search results

Preparation of the search result. Rates are grouped by the airlines.

```ruby
@api.fares(s:, vb:, bc1:, dt1:, at1:, da1:, aa1:, ps:, pn:, ct:, pt:)
```

Required parameters:

 * `s` - Sorting: Price - the price (default); Time - the time in a way.
 * `vb` - Method of displaying information on the rate of: false - a short (default) true - detailed

Not required parameters:

 * `bc1` - Filter on the number of direct.
 * `dt1` - Filter by time of departure: N - night; M - morning; D - day; E - evening.
 * `at1` - Filter by time of arrival: N - night; M - morning; D - day; E - evening.
 * `da1` - Filter on the departure airport, IATA airport code.
 * `aa1` - Filter of the arrival airport, IATA airport code.
 * `ps` - The size of the search results page (for the method List; recommended to refine the search query one request; pager, can be disabled in the future).
 * `pn` - Number of the search results page (for the method List; recommended to refine the search query one request; pager, can be disabled in the future).
 * `ct` - Filter the type of flight: All - all options (default) Direct - only direct flights
 * `pt` - Type Price: All - the price for all passengers (default value); Adult - the price per adult; Filter options necessarily contain indeks.Indeks determines which section of the route filter is applied.

Sample answer:

```ruby
#<OpenStruct c="RUB", l="RU", r="66p5ck6aj73153", pt=nil, ct="All", airlines=[#<OpenStruct c="UN", n="Transaero Airlines", fares=[#<OpenStruct id="0", at="57101", avl="true", res="true", mm="false", mmc="", cs="0", sts="unknown", dirs=[#<OpenStruct dep_apt="DYR", arr_apt="DME", sep_tm="D", arr_tm="D", hr="8", min="25", brd_cng="0", flt_num="UN-112">, #<OpenStruct dep_apt="DME", arr_apt="DYR", sep_tm="E", arr_tm="D", hr="8", min="20", brd_cng="0", flt_num="UN-111">]>, #<OpenStruct id="4", at="62645", avl="true", res="true", mm="false", mmc="", cs="0", sts="2", dirs=[#<OpenStruct dep_apt="DYR", arr_apt="DME", sep_tm="D", arr_tm="D", hr="8", min="25", brd_cng="0", flt_num="UN-112">, #<OpenStruct dep_apt="DME", arr_apt="DYR", sep_tm="E", arr_tm="D", hr="8", min="20", brd_cng="0", flt_num="UN-111">]>]>]>
```

### Details of the flight options

Get detailed information on the selected tariff.

```ruby
@api.fare_detail(f:)
```

Options:

 * `f` - Key tariff.

Sample answer:

```ruby
#<OpenStruct currency="RUB", available="True", r="b77y705842G3df", f="4", v="", can_make_reservation="true", mm="false", mmc="", cs="0", total_amount="62645", need_middle_name="false", min_avail_seats="2", adults="1", children="0", infants="0", airline_code="UN", airline_name="Transaero Airlines", reservation_time_limit=2015-09-29 19:59:00 +1200, a_base="50270", a_taxes="11720", a_total="61990", c_base="0", c_taxes="0", c_total="0", i_base="0", i_taxes="0", i_total="0", dirs=[#<OpenStruct variants=[#<OpenStruct id="0", tt="08:25", legs=[#<OpenStruct sc="E", bc="V", fn="UN-112", ft="08:25", plane_code="763", plane_name="Boeing 767", carrier_code=nil, carrier_name=nil, departure_code="DYR", departure_contry="Россия", departure_city="Анадырь", departure_airport="Анадырь", departure_terminal=nil, departure_date="2015-10-26", departure_time="15:25", departure_day_of_week="Monday", arrival_code="DME", arrival_contry="Россия", arrival_city="Москва", arrival_airport="Домодедово", arrival_terminal=nil, arrival_date="2015-10-26", arrival_time="14:50", arrival_day_of_week="Monday">]>]>, #<OpenStruct variants=[#<OpenStruct id="1", tt="08:20", legs=[#<OpenStruct sc="E", bc="V", fn="UN-111", ft="08:20", plane_code="763", plane_name="Boeing 767", carrier_code=nil, carrier_name=nil, departure_code="DME", departure_contry="Россия", departure_city="Москва", departure_airport="Домодедово", departure_terminal=nil, departure_date="2015-11-29", departure_time="19:05", departure_day_of_week="Sunday", arrival_code="DYR", arrival_contry="Россия", arrival_city="Анадырь", arrival_airport="Анадырь", arrival_terminal=nil, arrival_date="2015-11-30", arrival_time="12:25", arrival_day_of_week="Monday">]>]>]>
```

### Fare rules

Get the right fare. Possibility and conditions of the return and exchange.

```ruby
@api.fare_rules(f:)
```

Options:

 * `f` - Key tariff.

Sample answer:

```ruby
#<OpenStruct directions=[#<OpenStruct cbd="true", cad="true", rbd="false", rad="false", dep_ctry="Россия", dep_city="Анадырь", dep_apt="Анадырь", arr_ctry="MOW", arr_city="MOW", arr_apt="MOW", rules="RULES TEXT...">, #<OpenStruct cbd="true", cad="true", rbd="false", rad="false", dep_ctry="MOW", dep_city="MOW", dep_apt="MOW", arr_ctry="Россия", arr_city="Анадырь", arr_apt="Анадырь", rules="RULES TEXT...">]
```


### Check availability of flight options

Check availability on selected flights.

```ruby
@api.confirm_fare(f:, v:)
```

Options:

 * `f` - Key tariff.
 * `v` - Selected options, if there are several options, the version numbers must be separated by a ";".

Sample answer:

```ruby
#<OpenStruct r="SYM465FV4Dd53f", f="0", confirmed="True", min_avail_seats="1">
```

### Getting a link to create order

Returns the URL to which you want to redirect the buyer if the contract involves design affiliate purchases online anywayanyday.

```ruby
@api.get_create_order_url(f:, v:)
```

Options:

 * `f` - Key tariff.
 * `v` - Selections; in the case of several options, the version numbers must be separated by a ";".

Sample answer:

```ruby
https://www.anywayanyday.com/avia/makeorder/2610DYRMOW2911MOWDYRAD1CN0IN0SCE/DYR1525U825N112E1450DME-DME1905U820N111E11225DYR/RUB61761/65BFBE2C5C30811A747A3377458B70748AE63A66624582E7669138CF1543ABA5?RequestId=zHH06NF632Ycd5&FareId=1&SegmentId=0;1&FareConfirmed=False&Language=RU&Currency=RUB
```

## Contributing

1. Fork it ( https://github.com/gordienko/anywayanyday_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
