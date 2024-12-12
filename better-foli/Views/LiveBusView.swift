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
    let trip: TripData

    @State private var showTimetable: Bool = false

    @State var busCoords: CLLocationCoordinate2D
    @State var onwardCalls: [SiriVehicleMonitoring.Result.Vehicle.OnwardCalls] = []
    @State var mapCameraPosition: MapCameraPosition
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var allShapes: [ShapeData]
    @Query var allShapeCoords: [ShapeCoordsData]
    
    init(foliData: FoliDataClass, upcomingBus: DetailedSiriStop.Result, trip: TripData, busCoords: CLLocationCoordinate2D, mapCameraPosition: MapCameraPosition) {
        let shapeID = trip.shapeID

        let predicate = #Predicate<ShapeData> {
            $0.shapeID == shapeID
        }

        self.foliData = foliData
        self.upcomingBus = upcomingBus
        self.trip = trip
        self.busCoords = busCoords
        self.mapCameraPosition = mapCameraPosition
        
        _allShapes = Query(filter: predicate)
    }
    
    var body: some View {
        if let shape = allShapeCoords.first(where: { $0.shapeID == trip.shapeID }) {
            let shapeCoords: [CLLocationCoordinate2D] = shape.shapes.map { $0.coords }
            
            Map(position: $mapCameraPosition) {
                // Always show user location
                UserAnnotation()
                
                MapPolyline(coordinates: shapeCoords, contourStyle: .straight)
                    .stroke(.orange.opacity(0.8), lineWidth: 3)
                
                ForEach(onwardCalls, id: \.stoppointref) { call in
                    let stop = allStops.first { $0.code == call.stoppointref }
                    
                    if let stop {
                        Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "parkingsign", coordinate: stop.coords)
                            .tint(.orange)
                    }
                }
                
                Marker(upcomingBus.lineref, systemImage: "bus", coordinate: busCoords)
                    .tint(.orange)
            }
            .onAppear {
                let vehicleRef = upcomingBus.vehicleref
                
                guard let liveVehicle = foliData.vehicleData.first(where: { $0.vehicleref == vehicleRef }) else { return }
                guard let latitude = liveVehicle.latitude else { return }
                guard let longitude = liveVehicle.longitude else { return }
                let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                busCoords = coords
                onwardCalls = liveVehicle.onwardcalls ?? []
                mapCameraPosition = .region(MKCoordinateRegion(center: busCoords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            }
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    Spacer()
                    
                    Button {
                        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        
                        mapCameraPosition = .region(MKCoordinateRegion(center: busCoords, span: span))
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
                if (!onwardCalls.isEmpty) {
                    ScrollView {
                        VStack(spacing: 10) {
                            Label {
                                Text("Upcoming Stops")
                                    .font(.title)
                            } icon: {
                                Image(systemName: "parkingsign")
                            }
                            
                            ForEach(onwardCalls, id: \.stoppointref) { call in
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
        } else {
            ProgressView("Loading bus location...")
                .task {
                    do {
                        print("Getting shape coords...")
                        guard let shapeCoords = try await foliData.getShape(shapeID: trip.shapeID) else { return }
                        context.insert(shapeCoords)
                        try context.save()
                    } catch {
                        print(error)
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
    
    LiveBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus, trip: TripData(trip: GtfsTrip()), busCoords: center, mapCameraPosition: mapCameraPosition)
}
