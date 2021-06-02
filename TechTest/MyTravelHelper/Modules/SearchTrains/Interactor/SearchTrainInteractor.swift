//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing
import Alamofire

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    private var railClient = IrishRailClient()

    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
//            Alamofire.request("http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML")
//                .response { (response) in
//                let station = try? XMLDecoder().decode(Stations.self, from: response.data!)
//                self.presenter!.stationListFetched(list: station!.stationsList)
//            }
            railClient.requestAllStations(from: IrishRailMethod.getAllStations) {[weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let station):
                    if let presenter = self.presenter, let stationsList = station?.stationsList {
                        presenter.stationListFetched(list: stationsList)
                    }
                    break
                case .failure(let error):
                    debugPrint(error)
                    break
                }
            }
        } else {
            if let presenter = self.presenter {
                presenter.showNoInterNetAvailabilityMessage()
            }
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
//        let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=\(sourceCode)"
        guard let presenter = presenter else {
            return
        }
        if Reach().isNetworkReachable() {
            railClient.requestToGetStationDataByCode(from: IrishRailMethod.getStationDataByCode(sourceCode)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let stationData):
                    if let _trainsList = stationData?.trainsList {
                        self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                    } else {
                        presenter.showNoTrainAvailbilityFromSource()
                    }
                case .failure( _):
                    presenter.showNoTrainAvailbilityFromSource()
                }
            }
        } else {
            presenter.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
//            let _urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            if Reach().isNetworkReachable() {
                railClient.requestToGetTrainMovements(from: IrishRailMethod.getTrainMovements(trainsList[index].trainCode, dateString)) { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let trainMovements):
                        if let _movements = trainMovements?.trainMovements {
                            let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                            let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                            let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                            let isDestinationAvailable = desiredStationMoment.count == 1

                            if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                                _trainsList[index].destinationDetails = desiredStationMoment.first
                            }
                        }
                        group.leave()
                    case .failure( let error):
                        debugPrint(error)
                        group.leave()
                    }
                }
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter { $0.destinationDetails != nil }
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
