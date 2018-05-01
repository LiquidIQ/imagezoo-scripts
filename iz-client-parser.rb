require 'csv'

csvClients = CSV.read('iz-clients.csv')
csvSales = CSV.read('iz-sales.csv')

clientId = Array.new
fname = Array.new
lname = Array.new
email = Array.new
company = Array.new
address1 = Array.new
address2 = Array.new
city = Array.new
province = Array.new
province_code = Array.new
country = Array.new
country_code = Array.new
zip = Array.new
accepts_marketing = Array.new
total_spent = Array.new
total_orders = Array.new
tags = Array.new
note = Array.new
tax_exempt = Array.new

vLast = csvClients.length - 1
csvClients.reverse.each_with_index do |row, i|
    nFname = 19
    nLname = 18
    nEmail = 14
    nCompany = 1
    nAddress1 = 2
    nAddress2 = 3
    nCity = 5
    nProvince = 6
    # nProvince_code = 7
    nCountry = 8
    nZip = 7
    nAccepts_marketing = 15

    unless i == vLast 
        clientId << row[0]
        fname << row[nFname]
        lname << row[nLname]
        email << row[nEmail]
        company << row[nCompany]
        address1 << row[nAddress1]
        address2 << row[nAddress2]
        city << row[nCity]
        province << row[nProvince]
        country << row[nCountry]
        zip << row[nZip]
        accepts_marketing << row[nAccepts_marketing]

    end
end
csvSales[4].each_with_index do |fuckkkkkk|
    if i > 0
        clientId.each_with_index do |id, j|
            if id == row[4]
                puts "match row #{j} #{id}"
            end
        end
    end
end



# puts clientIds