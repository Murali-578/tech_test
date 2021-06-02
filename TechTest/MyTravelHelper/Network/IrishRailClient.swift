//
//  IrishRailClient.swift
//  MyTravelHelper
//
//  Created by IT on 02/06/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import Foundation

class IrishRailClient: APIClient {
    func requestAllStations(from kosmosMethod: IrishRailMethod, completion: @escaping (Result<Stations?, APIError>) -> Void) {
        
        let endpoint = kosmosMethod
        let request = endpoint.request
        fetch(with: request, decode: { json -> Stations? in
            guard let response = json as? Stations else { return  nil }
            return response
        }, completion: completion)
    }
    
    func requestToGetStationDataByCode(from kosmosMethod: IrishRailMethod, completion: @escaping (Result<StationData?, APIError>) -> Void) {
        let endpoint = kosmosMethod
        let request = endpoint.request
        fetch(with: request, decode: { json -> StationData? in
            guard let response = json as? StationData else { return  nil }
            return response
        }, completion: completion)
    }
    
    func requestToGetTrainMovements(from kosmosMethod: IrishRailMethod, completion: @escaping (Result<TrainMovementsData?, APIError>) -> Void) {
        let endpoint = kosmosMethod
        let request = endpoint.request
        fetch(with: request, decode: { json -> TrainMovementsData? in
            guard let response = json as? TrainMovementsData else { return  nil }
            return response
        }, completion: completion)
    }
}

