# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'pp'
require 'cgi'
require 'ostruct'
require 'kconv'

def search(keyword)
  url = 'http://gdata.youtube.com/feeds/api/videos'
  query = '?vq=' + CGI.escape(keyword) + '&prettyprint=true&orderby=published'

  result = []

  doc = Nokogiri::XML(open(url + query))
  doc.css('entry').each do |item|
    result.push(OpenStruct.new({
      id: item.css('id').text,
      published: DateTime.parse(item.css('published').text).strftime('%Y/%m/%d %H:%M:%S'),
      date: DateTime.parse(item.css('updated').text).strftime('%Y/%m/%d %H:%M:%S'),
      title: item.css('title').text,
      category: item.css('category')[1].attr('term'),
      content: item.css('content').text,
      author: item.css('author name').text,
      link: item.css('link')[0].attr('href')
    }))
  end
  result
end

keyword = ARGV.join(' ').toutf8
puts keyword

search(keyword).each_with_index do |video, i|
  puts "\n" + '-'*50
  puts (i+1).to_s + ': ' + video.title
  puts 'Date: ' + video.date
  puts 'Author: ' + video.author
  print "\n"

  print 'Open?(y/n/q): '
  input = STDIN.gets.chomp

  if input == 'y'
    `chrome #{video.link}`
  elsif input == 'q'
    exit
  end
end

