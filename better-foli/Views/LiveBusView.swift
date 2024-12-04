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
    
    @State private var liveVehicle: SiriVehicleMonitoring.Result.Vehicle?
    @State private var tripCoords: [CLLocationCoordinate2D]?
    @State private var showTimetable: Bool = false

    @State var mapCameraPosition: MapCameraPosition
    
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
                                
                                Annotation(coordinate: stopCoords) {
                                    BusStopLabelView()
                                } label: {
                                    Text(stop.stop_name)
                                }

                            }
                        }
                    }
                    
                    Annotation(coordinate: busCoordinates) {
                        Image(systemName: "bus")
                            .foregroundStyle(.orange)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .stroke(.orange, lineWidth: 2)
                            )
                    } label: {
                        Text(upcomingBus.lineref)
                    }
                }
                
                VStack(alignment: .trailing) {
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
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 10)
            }
            .sheet(isPresented: $showTimetable, content: {
                if let onwardsCalls = liveVehicle?.onwardcalls {
                    ScrollView {
                        VStack(spacing: 10) {
                            Label {
                                Text("Upcoming Stops")
                                    .font(.title)
                            } icon: {
                                BusStopLabelView()
                            }
                            
                            ForEach(onwardsCalls, id: \.stoppointref) { call in
                                HStack(alignment: .center) {
                                    Text(call.stoppointref)
                                        .bold()
                                        .frame(width: 75)
                                    Text(call.stoppointname)
                                    
                                    Spacer()
                                                                   
                                    VStack {
                                        let aimedArrivalDate = Date(timeIntervalSince1970: TimeInterval(call.aimedarrivaltime))
                                        let expectedArrivalDate = Date(timeIntervalSince1970: TimeInterval(call.expectedarrivaltime))
                                        let arrivalDelay = Int(floor(expectedArrivalDate.timeIntervalSince(aimedArrivalDate) / 60))
                                        
                                        Label {
                                            HStack(alignment: .top, spacing: 2) {
                                                Text(aimedArrivalDate, style: .time)
                                                Text("\(arrivalDelay >= 0 ? "+" : "")\(arrivalDelay)")
                                                    .foregroundStyle(arrivalDelay > 0 ? .red : .primary)
                                                    .font(.footnote)
                                            }
                                        } icon: {
                                            Image(systemName: "arrow.right")
                                        }
                                        .labelStyle(AlignedLabel())
                                        
                                        let aimedDepartureDate = Date(timeIntervalSince1970: TimeInterval(call.aimeddeparturetime))
                                        let expectedDepartureDate = Date(timeIntervalSince1970: TimeInterval(call.expecteddeparturetime))
                                        let departureDelay = Int(floor(expectedDepartureDate.timeIntervalSince(aimedDepartureDate) / 60))
                                        
                                        Label {
                                            HStack(alignment: .top, spacing: 2) {
                                                Text(aimedDepartureDate, style: .time)
                                                Text("\(departureDelay >= 0 ? "+" : "")\(departureDelay)")
                                                    .foregroundStyle(departureDelay > 0 ? .red : .primary)
                                                    .font(.footnote)
                                            }
                                        } icon: {
                                            Image(systemName: "arrow.left")
                                        }
                                        .labelStyle(AlignedLabel())
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
    let upcomingBus = DetailedSiriStop.Result()
    
    let center = CLLocationCoordinate2D(latitude: upcomingBus.latitude ?? 0.0, longitude: upcomingBus.longitude ?? 0.0)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    
    LiveBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus, mapCameraPosition: mapCameraPosition)
}
