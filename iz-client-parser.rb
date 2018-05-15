require 'csv'
require 'shopify_api'
require 'pry'

csv_clients = CSV.read('iz-clients.csv')
csv_sales = CSV.read('iz-sales.csv')

def get_customer_purchases(csv_sales)
    customer_purchases = Array.new
    prodIdCol = 0
    saleIdCol = 4
    csv_sales.each_with_index do |sale, i|
        if i > 0
            customer_id = sale[saleIdCol][0...-1]
            valid_customer = Integer(customer_id) rescue false
            binding.pry if customer_id == "1047620"
            if valid_customer
                product = sale[prodIdCol]

                if client = customer_purchases.find {|h| h.key? customer_id }
                    # client.dig(customer_id, "purchases") << product
                else
                    customer_purchases << {customer_id => {"purchases" => [product]}}
                end
            end
        end
    end
    return customer_purchases
end

def get_client_data(csv_clients, clients)
    cId = 0
    cFname = 19
    cLname = 18
    cEmail = 14
    cCompany = 1
    cAccepts_marketing = 15
    vLast = csv_clients.length - 1
    
    csv_clients.reverse.each_with_index do |row, i|
        unless i == vLast 
            this_id = row[0][0...-1]
            # binding.pry
            if c = clients.find {|h| h.key? this_id } then
                c = check_and_add(c, this_id, "email", row[cEmail]);
                c = check_and_add(c, this_id, "company", row[cCompany]);
                c = check_and_add(c, this_id, "fname", row[cFname]);
                c = check_and_add(c, this_id, 'lname', row[cLname]);
                puts "1: #{c.dig(this_id, 'accepts_marketing') == nil}" 
                puts c.dig(this_id, 'accepts_marketing') == "0"
                if c.dig(this_id, 'accepts_marketing') == nil || c.dig(this_id, 'accepts_marketing') == "0"
                    c[this_id].store('accepts_marketing', false)
                else 
                    c[this_id].store('accepts_marketing', true)
                end
            end
        end
    end
    return clients
end

def check_and_add(c, id, key, cell)
    if c.dig(id, key) == nil && cell != nil
        c[id].store(key, cell)
    end
    return c
end

clients = get_customer_purchases(csv_sales)
clients = get_client_data(csv_clients, clients)

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

CYCLE = 2



clients_remaining = clients.size

clients.each do |client|
    # pausing to keep our shopify api_call bucket full
    start_time = Time.now
    client.each do |k, v|

        stop_time = Time.now
        processing_duration = stop_time - start_time
        puts "The processing lasted #{processing_duration.to_i} seconds."
        puts "#{clients_remaining} Remaining"
        wait_time = (CYCLE - processing_duration).ceil
        puts "We have to wait #{wait_time} seconds then we will resume."
        sleep wait_time if wait_time > 0
        start_time = Time.now
        clients_remaining -= 1
        validation = [v['fname'], v['lname'], v['email']]

        # binding.pry
        
        unless validation.include? nil
            puts "#{v['email']} at: #{Time.now}"
            new_client = ShopifyAPI::Customer.new
            new_client.fname = v['fname']
            new_client.lname = v['lname']
            new_client.email = v['email']
            new_client.company = v['company']
            new_client.accepts_marketing = v['accepts_marketing']

            # binding.pry
            new_client.save
        end
    end
end

