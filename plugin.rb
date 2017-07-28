# name: thewinesociety-onebox
# about: Display Oneboxed product links from The Wine Society online shop
# version: 0.0.1
# authors: Chris Kottom
# url: https://github.com/chriskottom/thewinesociety-onebox

Onebox.options.load_paths << File.join(File.dirname(__FILE__), 'templates')

gem 'money', '6.9.0'

register_asset 'images/tws-logo.png'
register_asset 'stylesheets/thewinesociety.css'

require_relative './lib/onebox/helpers.rb'
require_relative './lib/onebox/engine/the_wine_society_engine.rb'
require_relative './lib/onebox/engine/thewinesociety_onebox.rb'
require_relative './lib/onebox/engine/thewinesocietyhistoric_onebox.rb'
