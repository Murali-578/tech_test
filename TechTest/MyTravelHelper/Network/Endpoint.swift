//
//  Endpoint.swift
//  MyTravelHelper
//

import Foundation

protocol Endpoint {
    
    var base: String { get }
    var path: String { get }
    var subPath: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    
//    var url: URL? {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "reqres.in"
//        components.path = path
//        components.queryItems = queryItems
//        return components.url
//    }
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = subPath
        components.queryItems = queryItems
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum IrishRailMethod {
    case getAllStations
    case getStationDataByCode(String)
    case getTrainMovements(String, String)
}

extension IrishRailMethod: Endpoint {
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getAllStations:
            return []
        case .getStationDataByCode(let stationCode):
            return [
                URLQueryItem(name: "StationCode", value: stationCode)
            ]
        case .getTrainMovements(let trainId, let trainDate):
            return [
                URLQueryItem(name: "TrainId", value: trainId),
                URLQueryItem(name: "TrainDate", value: trainDate)
            ]
        }
    }
    
    var base: String {
        return "http://api.irishrail.ie"
    }
    
    var path: String {
        return "/realtime/realtime.asmx"
    }
    
    var subPath: String {
        switch self {
        case .getAllStations:
            return "\(path)/getAllStationsXML"
        case .getStationDataByCode:
            return "\(path)/getStationDataByCodeXML"
        case .getTrainMovements:
            return "\(path)/getTrainMovementsXML"
        }
    }
    
}
