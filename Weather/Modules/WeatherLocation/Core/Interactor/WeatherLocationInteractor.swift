import Foundation


public struct WeatherLocation {
    let locationId: String
    let name: String
    var geolocation: WeatherGeolocation?
    
    init(locationId: String, name: String, geolocation: WeatherGeolocation? = nil) {
        self.locationId = locationId
        self.name = name
    }
}

public struct WeatherGeolocation {
    let latitude: Double
    let longitude: Double
}


public enum FetchWeatherLocationResult {
    case Success(locations: [WeatherLocation])
    case Failure(reason: NSError)
}


public protocol WeatherLocationInteractor {
    func locationsWithText(text: String, completion: (FetchWeatherLocationResult) -> ())
    func selectLocation(location: WeatherLocation)
}


class WeatherLocationCitiesInteractor: WeatherLocationInteractor {
    let citiesService: CitiesService
    let userLocationsService: UserLocationsService
    
    init(citiesService: CitiesService, userLocationsService: UserLocationsService) {
        self.citiesService = citiesService
        self.userLocationsService = userLocationsService
    }
    
    // MARK: <CitiesService>
    
    func locationsWithText(text: String, completion: (FetchWeatherLocationResult) -> ()) {
        self.citiesService.fetchCitiesWithText(text) { (cities, error) in
            var result: FetchWeatherLocationResult!
            
            if error != nil {
                result = FetchWeatherLocationResult.Failure(reason: error!)
            } else if let cities = cities {
                let locations = self.mapCities(cities)
                result = FetchWeatherLocationResult.Success(locations: locations)
            } else {
                let error = NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil)
                result = FetchWeatherLocationResult.Failure(reason: error)
            }
            
            completion(result)
        }
    }
    
    func selectLocation(location: WeatherLocation) {
        self.userLocationsService.storeLocation(location)
    }
    
    // MARK: Private
    
    private func mapCities(cities: [City]) -> [WeatherLocation] {
        return cities.map { (city) -> WeatherLocation in
            let geolocation = WeatherGeolocation(latitude: city.latitude, longitude: city.longitude)
            return WeatherLocation(locationId: city.cityId, name: city.name, geolocation: geolocation)
        }
    }
    
}
