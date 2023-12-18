//
//  LocationView.swift
//  EC
//
//  Created by Justin Zhang on 12/16/23.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct LocationView: View {
    @State var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State var searchText = ""
    @State var results = [MKMapItem]()
    @State var mapSelection: MKMapItem?
    @State var showDetails: Bool = false
    @State var selectedLocation: Bool = false
    @Binding var mapSelectionLocation: MKMapItem?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            Annotation("My location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue.opacity(0.25))
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(results, id: \.self) { item in
                let placeMark = item.placemark
                Marker(placeMark.name ?? "", coordinate: placeMark.coordinate)
            }
        }
        .overlay(alignment: .top) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.square")
                }
                
                TextField("Search for a location", text: $searchText)
                    .font(.subheadline)
                    .frame(width: UIScreen.main.bounds.width / 1.5)
                    .padding(12)
                    .background(.white)
                    .cornerRadius(25)
                    .padding(.trailing, 30)
                    .shadow(radius: 10)
            }
        }
        .onSubmit {
            Task { await searchPlaces() }
        }
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
            mapSelectionLocation = newValue
        })
        .onChange(of: selectedLocation, { oldValue, newValue in
            dismiss()
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, selectedLocation: $selectedLocation)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}

@available(iOS 17.0, *)
extension LocationView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
