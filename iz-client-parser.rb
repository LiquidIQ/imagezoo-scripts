require 'csv'

csvClients = CSV.read('iz-clients.csv')
csvSales = CSV.read('iz-sales.csv')

clientId = Array.new
fname = Array.new
lname = Array.new
email = Array.new
company = Array.new
accepts_marketing = Array.new
total_spent = Array.new
total_orders = Array.new
tags = Array.new
note = Array.new
tax_exempt = Array.new
shopify_write = Array.new
tags = Array.new

vLast = csvClients.length - 1

csvClients.each_with_index do |row, i|
    nFname = 19
    nLname = 18
    nEmail = 14
    nCompany = 1
    nAccepts_marketing = 15

    unless i == vLast 
        clientId << row[0]
        fname << row[nFname]
        lname << row[nLname]
        email << row[nEmail]
        company << row[nCompany]
        tags << ""
        if row[nAccepts_marketing] == "1" 
            accepts_marketing << "yes"
        else 
            accepts_marketing << "no"
        end
    end
end

csvSales.each_with_index do |row, i|
    clientId.each_with_index do |id, j|
        if row[4] == id
            if tags[j] == "" 
                tags[j] << "#{row[0]}"
            else 
                unless tags[j].include? row[0]
                    tags[j] << ",#{row[0]}"
                end
            end
        end
    end
end
 
# tags.each_with_index do |tag, i|
#     puts "#{company[i]}: #{tag}" if tag != "" 
# end
fname.each_with_index do |name, i|

end
CSV.open("customer_template.csv", "a+") do |csv|
    fname.each_with_index do |name, i|
        unless tags[i] == "" 
            if email[i] == ""
                csvClients.each_with_index do |row, j|
                    if company[i] == row[1] && row[14] != ""
                        email[i] == row[14]
                    end
                end
            end
            unless company[i] == "Corbis"
                unless company[i] == "Getty Images"
                    csv << [name, lname[i], email[i], company[i], "", "", "", "", "", "", "", "", "",accepts_marketing[i], "", "", tags[i], "", "no"]
                end
            end
        end
    end
end