# weatherweather

App follows requirements in that:
-- it allows user to query for a city.
-- saves last search
-- requests location permissions
-- displays useful info to user
  -- if queried for city then all stats return
  -- if home location then only main stats return
-- last search persists as does location permission data
-- features defensive programming.
-- features both UIKit and SwiftUI
-- UIKit leverages delegate pattern in a way usually seen in older frameworks
-- Swiftui and combine used directly adhereing to MVVM principles.
-- rudementary unit tests for viewmodels in showcase of building unit tests.
-- dependency injection for better readability and code testing. 
-- concurrency when looking up icons after first request for weather data
  -- icon fetched with image fetch class which has cache.
-- leverages swifts previews framework for on the go ui testing. 
-- has reverse lookup of user location to display weather. 
