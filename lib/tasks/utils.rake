# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
# Optimized loading of data from JSON file into the database using raw SQL
# rake reload_json[fixtures/small.json]
task :reload_json, [:file_name] => :environment do |_task, args|
  json = JSON.parse(File.read(args.file_name))

  ActiveRecord::Base.transaction do
    # Efficient deletion of all records
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    ActiveRecord::Base.connection.execute('DELETE FROM buses_services;')

    cities = {}
    services = {}
    buses = []
    trips = []
    bus_services = []

    # Collect unique cities and services
    json.each do |trip|
      cities[trip['from']] ||= nil
      cities[trip['to']] ||= nil
      trip['bus']['services'].each do |service|
        services[service] ||= nil
      end
    end

    # Insert cities
    city_values = cities.keys.map { |name| ActiveRecord::Base.sanitize_sql(["(?)", name]) }.join(", ")
    ActiveRecord::Base.connection.execute("INSERT INTO cities (name) VALUES #{city_values} ON CONFLICT (name) DO NOTHING;")
    city_ids = City.pluck(:name, :id).to_h

    # Insert services
    service_values = services.keys.map { |name| ActiveRecord::Base.sanitize_sql(["(?)", name]) }.join(", ")
    ActiveRecord::Base.connection.execute("INSERT INTO services (name) VALUES #{service_values} ON CONFLICT (name) DO NOTHING;")
    service_ids = Service.pluck(:name, :id).to_h

    # Prepare bus data and trip data
    json.each do |trip|
      from_city_id = city_ids[trip['from']]
      to_city_id = city_ids[trip['to']]
      bus_number = trip['bus']['number']
      bus_model = trip['bus']['model']
      start_time = trip['start_time']
      duration_minutes = trip['duration_minutes']
      price_cents = trip['price_cents']

      # Cache bus data
      buses << "('#{bus_number}', '#{bus_model}')"

      # Prepare trip data
      trips << {
        from_id: from_city_id,
        to_id: to_city_id,
        bus_number: bus_number,
        start_time: start_time,
        duration_minutes: duration_minutes,
        price_cents: price_cents
      }
    end

    # Insert buses
    bus_values = buses.join(", ")
    ActiveRecord::Base.connection.execute("INSERT INTO buses (number, model) VALUES #{bus_values} ON CONFLICT (number) DO NOTHING;")
    bus_ids = Bus.pluck(:number, :id).to_h

    # Insert trips
    trip_values = trips.map do |trip|
      bus_id = bus_ids[trip[:bus_number]]
      "(#{trip[:from_id]}, #{trip[:to_id]}, #{bus_id}, '#{trip[:start_time]}', #{trip[:duration_minutes]}, #{trip[:price_cents]})"
    end.join(", ")
    ActiveRecord::Base.connection.execute("INSERT INTO trips (from_id, to_id, bus_id, start_time, duration_minutes, price_cents) VALUES #{trip_values};")

    # Prepare bus services data
    json.each do |trip|
      bus_id = bus_ids[trip['bus']['number']]
      trip['bus']['services'].each do |service|
        service_id = service_ids[service]
        bus_services << "(#{bus_id}, #{service_id})"
      end
    end

    # Insert bus services
    bus_service_values = bus_services.join(", ")
    ActiveRecord::Base.connection.execute("INSERT INTO buses_services (bus_id, service_id) VALUES #{bus_service_values} ON CONFLICT DO NOTHING;")
  end
end
