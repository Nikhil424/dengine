require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_client_base"

module Engine
  class DengineAwsPricingDetails < Chef::Knife

    include DengineClientBase

    deps do
      require 'fog/aws'
    end

    banner "knife dengine aws pricing details (options)"

    def run

      fetch_pricing_info

    end

    def fetch_date

      current_time = DateTime.now

      date = current_time.strftime "%Y-%m-%d"
      return date

    end

    def fetch_pricing_info

      date_now = fetch_date
#      date_now = "2018-01-10"
      puts "#{ui.color('Right now the granurality is based on month and not daily basis', :cyan)}"
      ui.confirm('Do you want to proceed further on this...?')
      puts "#{ui.color('Date of today is ', :cyan)} :#{date_now}"
      puts "#{ui.color('Above date is taken as refrence for from date', :cyan)} :#{date_now}"
      puts "#{ui.color('Enter the date from where the calculation has to be made', :cyan)}"
      from_date = ask_question("EX: 2009-02-21 (YYYY-MM-DD) :", :default => "2018-01-06")
      puts "#{ui.color('The available dimension catageories values are: AZ, INSTANCE_TYPE, LINKED_ACCOUNT, OPERATION, PURCHASE_TYPE, REGION, SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, RECORD_TYPE, OPERATING_SYSTEM, TENANCY, SCOPE, PLATFORM, SUBSCRIPTION_ID', :cyan)}"
      dimnsn = ask_question("Enter any one of the above value: ",:default => "INSTANCE_TYPE")
      puts "#{ui.color('.', :cyan)}"
      puts "#{ui.color('The available context values are: COST_AND_USAGE, RESERVATIONS', :cyan)}"
      cntxt = ask_question("Enter any one of the above value: ",:default => "COST_AND_USAGE")
      puts "#{ui.color('...', :cyan)}"
      puts "#{ui.color('Fetching the dimension values...', :cyan)}"
      puts "#{ui.color('...', :cyan)}"

      test = aws_cost_explore.get_dimension_values({
        time_period: {
          start: from_date,
          end: date_now,
        },
        dimension: dimnsn,
        context: cntxt,
      })
      puts "The return size is: #{test.return_size} and total size is: #{test.total_size}"
      n=0
      dimension = []
      test.dimension_values.each do |i|
        puts i.value
        dimension[n] = i.value
        n +=1
      end
      puts "#{ui.color('The above is the list of dimension values', :cyan)}"
      dimnsn_value = ask_question("If you want to select all the dimension values enter (all) else enter the required value as (ReadCostAllocation,ReadLogProps) but seperated by commas: ",:default => "RunInstances" )

      if dimnsn_value == "all"

        cost_dimension = dimension

      else

        cost_dimension = dimnsn_value.split(/,/)

      end
      puts "#{ui.color('Getting the pricing details of the resource...', :cyan)}"
      puts "#{ui.color('...', :cyan)}"
      metric_value = ask_question("Based on what metric you need to measure the cost, the vailable values are: BlendedCost,UnblendedCost and UsageQuantity: ",:default => "BlendedCost")
      puts "#{ui.color('...', :cyan)}"
      puts "#{ui.color('You can see the pricing details above...', :cyan)}"


      cost = aws_cost_explore.get_cost_and_usage({
        time_period: {
        start: from_date, # required
        end: date_now, # required
        },
        granularity: "MONTHLY", # accepts DAILY, MONTHLY
        filter: {
        dimensions: {
          key: dimnsn,
          values: cost_dimension,
          },
        },
        metrics: ["#{metric_value}"],
      })

      puts "#{cost.next_page_token}"
      puts "#{cost.results_by_time[0].time_period.start}"
      puts "#{cost.results_by_time[0].time_period.end}"
      puts "#{cost.results_by_time[0].total["BlendedCost"].amount+cost.results_by_time[0].total["BlendedCost"].unit}"

    end

  end
end
