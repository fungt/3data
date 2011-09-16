#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'

# Your 3HK mobile number
MOBILE=''
# Your 3HK password
PASSWORD=''

if MOBILE.empty? || PASSWORD.empty?
    $stderr.puts "Please specify your mobile nubmer and password inside the script"
else
    uri = "https://www.three.com.hk"

    puts "Downloading data from three.com.hk ... "
    begin
        cookie = open(uri + '/website/appmanager/three').meta['set-cookie'].split('; ').first
        data = Nokogiri::HTML.parse open(uri + "/appCS2/verifyLogin.do?action=login&mobileno=#{MOBILE}&password=#{PASSWORD}&URLTo=https://www.three.com.hk/appCS2/usageNotYetBilled.do", "Cookie" => cookie)
        date_table = data.at_xpath "//table[@class='bg_gry95 dgy12']"
        bill_date = date_table.at_xpath("//tr[2]/td[2]").content
        call_cutoff_date = date_table.at_xpath("//tr[3]/td[2]").content
        data_usage, video_call_time, call_time, three_call_time, total_call_time, multimedia, sms,
            three_sms, cross_sms, inter_sms = data.xpath("//span[@class='keypro_u']").map { |v| v.content.to_i }

        puts "Cycle Start Date          : #{bill_date}"
        puts "Call Cutoff Date          : #{call_cutoff_date}"
        puts "Video Call                : #{video_call_time} minutes"
        puts "Voice Call"
        puts "    Basic call time       : #{call_time} minutes"
        puts "    Intra-three call time : #{three_call_time} minutes"
        puts "    " + "=" * 30
        puts "    Total voice call time : #{total_call_time} minutes"
        puts 
        puts "Mobile Data               : #{data_usage > 1024? (data_usage/1024.0).round(2) : data_usage} #{data_usage > 1024? "MB" : "KB"}"
        puts "Multimedia Content        : #{multimedia}"
        puts 
        puts "Text Content"
        puts "    Intra-three SMS       : #{three_sms}"
        puts "    Inter-operator SMS    : #{cross_sms}"
        puts "    International SMS     : #{inter_sms}"
        puts "    " + "=" * 30
        puts "    Total SMS             : #{sms}"
    rescue 
        puts "Fail when communicating with three.com.hk"
    end
end

