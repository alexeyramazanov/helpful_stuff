require 'yaml'
require 'open-uri'
require 'capybara'
require 'selenium-webdriver'
require 'addressable/uri'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

settings = YAML.load(File.read('config.yml'))
if settings['firefox_path']
  Selenium::WebDriver::Firefox::Binary.path = settings['firefox_path']
end

# > 640x480
url = "https://www.google.com/search?tbm=isch&q=#{URI.escape(settings['search_term'])}&tbs=isz:lt,islt:vga"

page = Capybara::Session.new(:selenium)
page.visit(url)

scroll = 0
settings['iterate_times'].times do
  scroll += 25000
  page.execute_script("window.scrollBy(0, #{scroll});")
  sleep settings['image_load_delay']
  if page.has_selector?('#smb')
    page.find('#smb').click
    sleep 1
  end
end

File.open('out.txt', 'w') do |f|
  page.all(:css, '#rg_s .rg_di a.rg_l').each do |a|
    uri = Addressable::URI.parse(a[:href])
    f.write "#{uri.query_values['imgurl']}\n"
  end
end
