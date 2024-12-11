//
//  LiveBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LiveBusView: View {
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @State private var liveVehicle: SiriVehicleMonitoring.Result.Vehicle?
    @State private var tripCoords: [CLLocationCoordinate2D]?
    @State private var showTimetable: Bool = false

    @State var mapCameraPosition: MapCameraPosition
    
    @Query var allStops: [StopData]
    
    var body: some View {
        if let latitude = liveVehicle?.latitude, let longitude = liveVehicle?.longitude, let coords = tripCoords {
            let busCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            Map(position: $mapCameraPosition) {
                // Always show user location
                UserAnnotation()
                
                MapPolyline(coordinates: coords, contourStyle: .straight)
                    .stroke(.orange.opacity(0.8), lineWidth: 3)
                
                if let onwardsCalls = liveVehicle?.onwardcalls {
                    ForEach(onwardsCalls, id: \.stoppointref) { call in
                        let stop = allStops.first { $0.code == call.stoppointref }
                        
                        if let stop {
                            Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "parkingsign", coordinate: stop.coords)
                                .tint(.orange)
                        }
                    }
                }
                
                Marker(upcomingBus.lineref, systemImage: "bus", coordinate: busCoordinates)
                    .tint(.orange)
            }
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    Spacer()
                    
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
                    
                    Button {
                        showTimetable.toggle()
                    } label: {
                        Label {
                            Text("Timetable")
                        } icon: {
                            Image(systemName: "calendar")
                        }
                    }
                    
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 15)
                .background(.ultraThinMaterial)
            })
            .sheet(isPresented: $showTimetable, content: {
                if let onwardsCalls = liveVehicle?.onwardcalls {
                    ScrollView {
                        VStack(spacing: 10) {
                            Label {
                                Text("Upcoming Stops")
                                    .font(.title)
                            } icon: {
                                Image(systemName: "parkingsign")
                            }
                            
                            ForEach(onwardsCalls, id: \.stoppointref) { call in
                                HStack(alignment: .center) {
                                    Text(call.stoppointref)
                                        .bold()
                                        .frame(width: 75)
                                    Text(call.stoppointname)
                                    
                                    Spacer()
                                                                   
                                    VStack {
                                        ArrivalTimeView(aimedArrival: call.aimedarrivaltime, expectedArrival: call.expectedarrivaltime)
                                        DepartureTimeView(aimedDeparture: call.aimeddeparturetime, expectedDeparture: call.expecteddeparturetime)
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .presentationDetents([.medium])
                    .presentationBackground(.regularMaterial)
                }
            })
            .onReceive(timer) { _ in
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
    let upcomingBus = DetailedSiriStop.Result()
    
    let center = CLLocationCoordinate2D(latitude: upcomingBus.latitude ?? 0.0, longitude: upcomingBus.longitude ?? 0.0)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    
    LiveBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus, mapCameraPosition: mapCameraPosition)
}
