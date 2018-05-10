require 'csv'
require 'shopify_api'

csvClients = CSV.read('iz-clients.csv')
csvSales = CSV.read('iz-sales.csv')

def get_customer_purchases(csvSales)
    customer_purchases = Array.new
    prodIdCol = 0
    saleIdCol = 4
    csvSales.each_with_index do |sale, i|
        if i > 0
            customer_id = sale[saleIdCol][0...-1]
            product = sale[prodIdCol]

            if client = customer_purchases.find {|h| h.key? customer_id }
                client.dig(customer_id, "purchases") << product
            else
                customer_purchases << {customer_id => {"purchases" => [product]}}
            end
        end
    end
    return customer_purchases
end

def get_client_data(csvClients, clients)
    cId = 0
    cFname = 19
    cLname = 18
    cEmail = 14
    cCompany = 1
    cAccepts_marketing = 15
    vLast = csvClients.length - 1
    
    csvClients.reverse.each_with_index do |row, i|
        unless i == vLast 
            this_id = row[0][0...-1]
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

clients = get_customer_purchases(csvSales)
clients = get_client_data(csvClients, clients)

API_KEY = "5be1e793270a36242c1368d6de5c3a9d"
PASSWORD = "ddcafc1072286dfb03dba080f7f5083d"
SHOP_NAME = "imagezoo"
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

currentCustomers = ShopifyAPI::Customer

clients.each do |client|
    i = 0
    tries = 3
    pause = 10
    client.each do |k, v|
        puts "#{v['email']} at: #{Time.now}"
        new_client = ShopifyAPI::Customer.new
        new_client.fname = v['fname']
        new_client.lname = v['lname']
        new_client.email = v['email']
        new_client.company = v['company']
        new_client.accepts_marketing = v['accepts_marketing']
        puts new_client.accepts_marketing
        begin
            new_client.save
        rescue ClientError => e
            puts 
            sleep 10
            retry unless (tries -= 1).zero?
        end
        # csv << [v['fname'], v['lname'], v['email'], v['company'], "add1", "add2", "city", "prov", "prov_code", "country", "zip", v['accepts_marketing'], "total_spent", "total_orders", v['purchases'], "", "no"]
    end
end

