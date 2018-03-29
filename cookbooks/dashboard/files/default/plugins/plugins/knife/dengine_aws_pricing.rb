require 'chef/knife'
require 'date'
require "#{File.dirname(__FILE__)}/base/dengine_client_base"

module Engine
  class DengineAwsPricing < Chef::Knife

    include DengineClientBase

    deps do
      require 'fog/aws'
    end

    banner "knife dengine aws pricing (options)"

    def run

      fetch_pricing_info

    end

    def fetch_date

      current_time = DateTime.now

      date = current_time.strftime "%Y-%m-%d"
      return date

    end

    def calculate_cost(price, days)

      per_day_cost = cost_per_day(price)
      cost = per_day_cost*days
      return cost.to_f

    end

    def cost_per_day(price)

      per_day_cost = price/30
      return per_day_cost

    end

    def calculate_days(date)

      day = date.reverse
      from_date = Date.parse("#{day.first}")
      to_date = Date.parse("#{day.last}")
      days = from_date-to_date

      return days.to_i

    end

    def fetch_pricing_info

      dates = ask_question("Enter the start and end date, start followed by end date separated by commas. Refer the sample in the box >>>>",:default => "21-12-2010,8-12-2010" )

      date = dates.split(/,/)
      days = calculate_days(date)
      puts "#{ui.color('Fetching the possible services, please hold on to this', :cyan)}"
      puts "#{ui.color('*****************************', :cyan)}"
      service = aws_pricing_list.describe_services({
        format_version: "aws_v1",
      })

      service.services.each do |i|
        puts i.service_code
      end
      puts "#{ui.color('*****************************', :cyan)}"
      puts ""

      puts "#{ui.color('The above are the possible services', :cyan)}"
      serv_code = ask_question("Enter the required value as (AmazonEC2,AmazonVPC,OpsWorks etc) one at a time: ",:default => "usagetype" )

      puts "#{ui.color('Fetching the list of attributes, please hold on to this', :cyan)}"
      puts "#{ui.color('*****************************', :cyan)}"
      attr = aws_pricing_list.describe_services({
        service_code: serv_code,
        format_version: "aws_v1",
      })

      attr.services[0].attribute_names.each do |i|
        puts i
      end
      puts "#{ui.color('*****************************', :cyan)}"
      puts ""

      puts "#{ui.color('The above are the possible attributes values for the catageory you eneterd', :cyan)}"
      attr_name = ask_question("Enter the required value as (provisioned,PurchaseOption,usagetype etc) one at a time: ",:default => "usagetype" )
      puts ""
      puts "#{ui.color('Fetching the possible sub attributes for the services you entered, please hold your stance', :cyan)}"
      puts "#{ui.color('*****************************', :cyan)}"

      attribute = aws_pricing_list.get_attribute_values({
        attribute_name: attr_name,
        service_code: serv_code,
      })

      attribute.attribute_values.each do |i|
        puts i.value
      end

      puts "#{ui.color('*****************************', :cyan)}"
      puts ""
#      puts "#{attribute.next_token}"
      puts "#{ui.color('The above are the possible sub attribute values for the catageory you eneterd', :cyan)}"
      attri_value = ask_question("Enter the required value as (provisioned,PurchaseOption,usagetype etc) one at a time: ",:default => "none" )

      puts "The next token is: #{attribute.next_token}"
      price = aws_pricing_list.get_products({
        service_code: serv_code,
        filters: [
          {
            field: attr_name,
            type: "TERM_MATCH",
            value: attri_value,
          },
        ],
        format_version: "aws_v1",
#        next_token: "#{attribute.next_token}",
      })

#      price.price_list.each do |i|
#       puts i
#      end
      list = price.price_list
      list.each do |a|
      json_string = "#{a}"
      parsed = JSON.parse(json_string)
#--------------------------------------if output is Genearal purpose disk ------------------

       ary1 = parsed['product']['attributes']
         @ary = ary1['location']
       ary2 = parsed['terms']['OnDemand'].each do |i|
         a = i[1]

           puts "#{ui.color('******************************************************', :cyan)}"
           puts "For region #{@ary} the price for the #{attri_value} #{attr_name} is #{a.values.first.values.last.values.last.values.to_s.tr("[]", '').tr('"', '')} #{a.values.first.values.last.values.last.keys.to_s.tr("[]", '').tr('"', '')} #{a.values.first.values.first.values[0].to_s.tr("[]", '').tr('"', '')}"
           unit_price = a.values.first.values.last.values.last.values.to_s.tr("[]", '').tr('"', '').to_f
           cost = calculate_cost(unit_price,days)
           puts "For the days you specified the estimated cost will be around #{cost} #{a.values.first.values.last.values.last.keys.to_s.tr("[]", '').tr('"', '')} #{a.values.first.values.first.values[0].to_s.tr("[]", '').tr('"', '')}"
           puts ""
       end
#-------------------------------------------------------------------------------------------
      end
    end

  end
end
