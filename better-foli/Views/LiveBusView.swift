//
//  LiveBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit

struct LiveBusView: View {
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @State var liveVehicle: SiriVehicleMonitoring.Result.Vehicle?
    @State var tripCoords: [CLLocationCoordinate2D]?
    @State var mapCameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        if let latitude = liveVehicle?.latitude, let longitude = liveVehicle?.longitude, let coords = tripCoords {
            let busCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            ZStack(alignment: .bottomTrailing) {
                Map(position: $mapCameraPosition) {
                    MapPolyline(coordinates: coords, contourStyle: .straight)
                        .stroke(.orange.opacity(0.8), lineWidth: 3)
                    
                    if let onwardsCalls = liveVehicle?.onwardcalls {
                        ForEach(onwardsCalls, id: \.stoppointref) { call in
                            let stop = foliData.allStops.filter { stop in
                                return stop.value.stop_code == call.stoppointref
                            }.first
                            
                            if let stop {
                                let stop = stop.value
                                let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                                
                                Annotation(stop.stop_name, coordinate: stopCoords) {
                                    ZStack {
                                        Circle()
                                            .fill(.orange)
                                        
                                        Image(systemName: "parkingsign.square")
                                            .foregroundStyle(.white)
                                            .padding(5)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    Annotation(coordinate: busCoordinates) {
                        ZStack {
                            Circle()
                                .fill(.orange)
                            
                            Image(systemName: "bus")
                                .foregroundStyle(.white)
                                .padding(5)
                        }
                    } label: {
                        Text(upcomingBus.lineref)
                            .bold()
                    }
                }
                
                Button {
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    
                    mapCameraPosition = .region(MKCoordinateRegion(center: busCoordinates, span: span))
                } label: {
                    Label {
                        Text("Find Bus")
                    } icon: {
                        Image(systemName: "location.circle")
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 10)
            }
            .onReceive(timer) { _ in
                print("Updating vehicle location...")
                
                Task {
                    if let vehicleRef = upcomingBus.vehicleref {
                        do {
                            liveVehicle = try await foliData.getVehiclePosition(vehicleRef: vehicleRef)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } else {
            ProgressView("Loading bus location...")
                .task {
                    if let vehicleRef = upcomingBus.vehicleref {
                        do {
                            liveVehicle = try await foliData.getVehiclePosition(vehicleRef: vehicleRef)
                            
                            if let routeID = liveVehicle?.__routeref, let tripID = liveVehicle?.__tripref {
                                tripCoords = try await foliData.getTripCoordinates(routeID: routeID, tripID: tripID)
                            }
                            
                            if let latitude = liveVehicle?.latitude, let longitude = liveVehicle?.longitude {
                                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                
                                mapCameraPosition = .region(MKCoordinateRegion(center: center, span: span))
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
        }
    }
}

#Preview {
    let currentTimestamp = Int(Date.now.timeIntervalSince1970)
    let upcomingBus = DetailedSiriStop.Result(
        recordedattime: currentTimestamp,
        monitored: true,
        lineref: "51",
        vehicleref: "550003",
        longitude: 22.21967,
        latitude: 60.43503,
        destinationdisplay: "Oriniemi Häppilän kautta",
        aimedarrivaltime: currentTimestamp + 60,
        expectedarrivaltime: currentTimestamp + 120,
        aimeddeparturetime: currentTimestamp + 180,
        expecteddeparturetime: currentTimestamp + 240,
        __tripref: "00015150__1050051106", __routeref: ""
    )
    
    let center = CLLocationCoordinate2D(latitude: 60.43503, longitude: 22.21967)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    
    LiveBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus, mapCameraPosition: mapCameraPosition)
}
