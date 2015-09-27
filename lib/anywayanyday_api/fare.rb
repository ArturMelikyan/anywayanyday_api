module Anywayanyday
  class Api
    module Fare

      # NewRequest - Инициализация запроса
      def fare_new_request(route:, ad: 0, cn: 0, inf: 0, sc: 0)
        data = request 'NewRequest', {route: route, ad: ad, cn: cn, sc: sc, in: inf, partner: config.code}
        @request_id = data['Id']
      end

      # RequestInfo - Детали запроса
      def fare_request_info
        data = request 'RequestInfo', {r: request_id, l: config.locale}
        ds = []
        data.xpath('Direction').each do |a|
          ds << OpenStruct.new(route: a['Route'], dc: a['DC'], dp: a['DP'], ac: a['AC'], ap: a['AP'], dd: a['DD'].to_date)
        end
        OpenStruct.new(ad: data['AD'], cn: data['CN'], in: data['IN'], sc: data['SC'], directions: ds)
      end

      # RequestState - Статус поиска
      def fare_request_state
        data = request 'RequestState', {r: request_id}
        data['Completed'].to_i
      end

      # Fares - Результат поиска
      def fares(s: 'Price', vb: false,
                bc1: nil, dt1: nil, at1: nil, da1: nil, aa1: nil, ps: nil, pn: nil, ct: 'All', pt: 'All')
        data = request 'Fares', {r: request_id, v: 'Matrix', l: config.locale, c: config.currency, s: s, vb: vb,
                                 bc1: bc1, dt1: dt1, at1: at1, da1: da1, aa1: aa1, ps: ps, pn: pn, ct: ct, pt: pt}
        airlines = []
        data.xpath('Arln').each do |a|
          fares = []
          a.xpath('Fare').each do |f|
            dirs = []
            f.xpath('Dir').each do |d|
              dirs << OpenStruct.new(dep_apt: d["DepApt"], arr_apt: d["ArrApt"], sep_tm: d["DepTm"], arr_tm: d["ArrTm"], hr: d["Hr"], min: d["Min"], brd_cng: d["BrdCng"], flt_num: d["FltNum"])
            end
            fares << OpenStruct.new(id: f['Id'], at: f['AT'], avl: f['Avl'], res: f['Res'], mm: f['MM'], mmc: f['MMC'], cs: f['CS'], sts: f['Sts'], dirs: dirs)
          end
          airlines << OpenStruct.new(c: a['C'], n: a['N'], fares: fares)
        end
        OpenStruct.new(c: data['C'], l: data['L'], r: data['R'], pt: data['P'], ct: data['CT'], airlines: airlines)
      end

      # Fare - Детали варианта перелета
      def fare_detail(f:)
        data = request 'Fare', {r: request_id, f: f}
        passengers = data.xpath('Passengers').first
        airline = data.xpath('Airline').first
        reservation_time_limit_tmp = data.xpath('ReservationTimeLimit').first
        reservation_time_limit = Time.parse([reservation_time_limit_tmp['Date'], reservation_time_limit_tmp['Time']].join(" "))
        amount = data.xpath('Amount').first

        dirs = []
        data.xpath('Dir').each do |d|
          variants = []
          d.xpath('Variant').each do |v|
            legs = []
            v.xpath('Leg').each do |l|
              carrier = l.xpath('Carrier').first
              plane = l.xpath('Plane').first
              departure = l.xpath('Departure').first
              arrival = l.xpath('Arrival').first
              legs << OpenStruct.new(sc: l["SC"], bc: l["BC"], fn: l["FN"], ft: l["FT"], plane_code: plane['C'],
                                     plane_name: plane['N'], carrier_code: carrier.try('C'), carrier_name: carrier.try('N'),
                                     departure_code: departure["Code"],
                                     departure_contry: departure["Contry"], departure_city: departure["City"],
                                     departure_airport: departure["Airport"], departure_terminal: departure["Terminal"],
                                     departure_date: departure["Date"], departure_time: departure["Time"],
                                     departure_day_of_week: departure["DayOfWeek"], arrival_code: arrival["Code"],
                                     arrival_contry: arrival["Contry"], arrival_city: arrival["City"],
                                     arrival_airport: arrival["Airport"], arrival_terminal: arrival["Terminal"],
                                     arrival_date: arrival["Date"], arrival_time: arrival["Time"],
                                     arrival_day_of_week: arrival["DayOfWeek"])
            end
            variants << OpenStruct.new(id: v['Id'], tt: v['TT'], legs: legs)
          end
          dirs << OpenStruct.new(variants: variants)
        end
        OpenStruct.new(currency: data["Currency"], available: data["Available"], r: data["R"], f: data["F"],
                       v: data["V"], can_make_reservation: data["CanMakeReservation"], mm: data["MM"], mmc: data["MMC"],
                       cs: data["CS"], total_amount: data["TotalAmount"], need_middle_name: data["NeedMiddleName"],
                       min_avail_seats: data["MinAvailSeats"], adults: passengers['Adults'], children: passengers['Children'],
                       infants: passengers['Infants'], airline_code: airline['C'], airline_name: airline['N'],
                       reservation_time_limit: reservation_time_limit, a_base: amount["ABase"], a_taxes: amount["ATaxes"],
                       a_total: amount["ATotal"], c_base: amount["CBase"], c_taxes: amount["CTaxes"], c_total: amount["CTotal"],
                       i_base: amount["IBase"], i_taxes: amount["ITaxes"], i_total: amount["ITotal"], dirs: dirs)
      end

      # FareRules - Правила применения тарифа
      def fare_rules(f:)
        directions = []
        data = request 'FareRules', {r: request_id, f: f, l: config.locale}
        data.xpath('Direction').each do |d|
          h=d.xpath('Header').first
          dep = h.xpath('Dep').first
          arr = h.xpath('Arr').first
          r=d.xpath('Rules').first.text
          directions << OpenStruct.new(cbd: h["CBD"], cad: h["CAD"], rbd: h["RBD"], rad: h["RAD"],
                                       dep_ctry: dep["Ctry"], dep_city: dep["City"], dep_apt: dep["Apt"],
                                       arr_ctry: arr["Ctry"], arr_city: arr["City"], arr_apt: arr["Apt"],
                                       rules: r)
        end
        OpenStruct.new(directions: directions)
      end

      # ConfirmFare - Проверка доступности варианта перелета
      def confirm_fare(f:, v:)
        data = request 'ConfirmFare', {r: request_id, f: f, v: v}
        OpenStruct.new(r: data["R"], f: data["F"], confirmed: data["Confirmed"], min_avail_seats: data["MinAvailSeats"])
      end

      # GetCreateOrderURL - Получение ссылки на страницу создания заказа сайта www.anywayanyday.com
      def get_create_order_url(f:, v:)
        data = request 'GetCreateOrderURL', {r: request_id, f: f, v: v, l: config.locale, c: config.currency}
        data['URL']
      end

    end
  end
end

