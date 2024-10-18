require 'httparty'
require 'csv'

class Weather
  API_KEY = 'c878e6ff9e936dec9eb807dc1fabc0f6'

  def get_weather_data(city)
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{API_KEY}&units=metric"
    response = HTTParty.get(url)
    if response.code == 200
      filter_weather_data(response.parsed_response) 
    else
      puts "Ошибка получения данных: #{response.message} (Код: #{response.code})"
      nil
    end
  end

  def filter_weather_data(data)
    {
      city: data['name'],
      temperature: data['main']['temp'],
      humidity: data['main']['humidity'],
      wind_speed: data['wind']['speed']
    }
  end

  def save_to_csv(data, filename = 'weather.csv')
    CSV.open(filename, 'w') do |csv|
      csv << ['Параметр', 'Значення']
      csv << ['Місто', data[:city]]
      csv << ['Температура (°C)', data[:temperature]]
      csv << ['Вологість (%)', data[:humidity]]
      csv << ['Швидкість вітру (м/с)', data[:wind_speed]]
    end
    puts "Дані збережено у файл #{filename}"
  end
end

weather = Weather.new
data = weather.get_weather_data('Kharkiv') 
weather.save_to_csv(data) if data
