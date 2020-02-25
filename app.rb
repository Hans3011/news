require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# Dark Sky & News API
ForecastIO.api_key = "0cbdea4f22bbbc86ede6823e3b066825"
url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=1a71869bcefa4700b52ccff2deee689a"
news = HTTParty.get(url).parsed_response.to_hash

get "/" do
  view "ask"
end

get "/news" do

    results = Geocoder.search(params["q"])
    lat_long = results.first.coordinates

    @forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_summary = @forecast["currently"]["summary"]
    @current_icon = @forecast["currently"]["icon"]
    
    @forecast_temperature = Array.new
    @forecast_summary = Array.new
    # @forecast_icon = Array.new
    @forecast_time = Array.new
    i = 0
    for day in @forecast["daily"]["data"] do
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        # @forecast_icon[i] = day["icon"]
        @forecast_time[i] = day["time"]
        i = i+1
    end

    @title = Array.new
    @story_link = Array.new
    a = 0
    for story in news["articles"] do
        @title[a] = story["title"]
        @story_link[a] = story["url"]
        a = a+1
    end

    view "news"

end