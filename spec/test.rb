require_relative '../weather'
require 'rspec'
require 'fileutils'

RSpec.describe Weather do
  let(:weather) { Weather.new }
  let(:sample_response) do
    {
      'name' => 'Kharkiv',
      'main' => {
        'temp' => 9.59,
        'humidity' => 87
      },
      'wind' => {
        'speed' => 3.5
      }
    }
  end

  describe '#get_weather_data' do
    it 'успешно выполняет HTTP-запрос к API' do
      allow(HTTParty).to receive(:get).and_return(double(code: 200, parsed_response: sample_response))
      data = weather.get_weather_data('Kharkiv')
      expect(data).to be_a(Hash)
      expect(data[:city]).to eq('Kharkiv')
    end

    it 'возвращает ошибку при неуспешном запросе' do
      allow(HTTParty).to receive(:get).and_return(double(code: 401, message: 'Unauthorized'))
      data = weather.get_weather_data('Kharkiv')
      expect(data).to be_nil
    end
  end

  describe '#filter_weather_data' do
    it 'правильно обрабатывает данные от API' do
      parsed_data = weather.filter_weather_data(sample_response)
      expect(parsed_data).to eq({
        city: 'Kharkiv',
        temperature: 9.59,
        humidity: 87,
        wind_speed: 3.5
      })
    end
  end

  describe '#save_to_csv' do
    let(:data) do
      {
        city: 'Kharkiv',
        temperature: 9.59,
        humidity: 87,
        wind_speed: 3.5
      }
    end
    let(:filename) { 'test_weather.csv' }

    after do
      FileUtils.rm_f(filename) 
    end

    it 'сохраняет данные в CSV-файл' do
      weather.save_to_csv(data, filename)
      expect(File.exist?(filename)).to be true

      csv_content = CSV.read(filename)
      expect(csv_content).to eq([
        ['Параметр', 'Значення'],
        ['Місто', 'Kharkiv'],
        ['Температура (°C)', '9.59'],
        ['Вологість (%)', '87'],
        ['Швидкість вітру (м/с)', '3.5']
      ])
    end
  end
end
