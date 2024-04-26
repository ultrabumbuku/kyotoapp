//
//  ContentView.swift
//  kyotoapp
//
//  Created by 黒川悠馬 on 2024/01/09.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var isLocationUpdated = false
    @Published var locationStatusMessage: String = "現在地を取得中..."

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()  // 許可がまだ決まっていない場合、要求する
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()  // 許可された場合、位置情報の取得を開始
            locationStatusMessage = "位置情報の取得を開始します"
            print(locationStatusMessage)
        case .restricted, .denied:
            locationStatusMessage = "位置情報の使用が許可されていません"
            print(locationStatusMessage)
            // 制限されているか拒否された場合
        default:
            locationStatusMessage = "位置情報サービスの使用が不可能です"
            print(locationStatusMessage)
            // その他のケース
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            location = newLocation
            isLocationUpdated = true
            locationStatusMessage = "位置情報を取得できました"
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
        locationStatusMessage = "位置情報の取得に失敗しました"
    }
}


struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var weight: Double = 0.0  // 重みを追加
}


struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: Location?
    @State private var newLocationName: String = ""
    @State private var newLocationLatitude: String = ""
    @State private var newLocationLongitude: String = ""
    @State private var locationAddedMessage: String = ""
    


            // リスト内の地点
    @State var locations: [Location] = [
                Location(name: "金閣", coordinate: CLLocationCoordinate2D(latitude: 35.0221, longitude: 135.4345)),
                Location(name: "銀閣", coordinate: CLLocationCoordinate2D(latitude: 35.0137, longitude: 135.4753)),
                Location(name: "清水寺", coordinate: CLLocationCoordinate2D(latitude: 34.5940, longitude: 135.4704)),
                Location(name: "龍安寺", coordinate: CLLocationCoordinate2D(latitude: 35.0204, longitude: 135.4305)),
                Location(name: "伏見稲荷大社", coordinate: CLLocationCoordinate2D(latitude: 34.5803, longitude: 135.4645)),
                Location(name: "八坂神社", coordinate: CLLocationCoordinate2D(latitude: 35.0010, longitude: 135.4642)),
                Location(name: "二条城", coordinate: CLLocationCoordinate2D(latitude: 35.0050, longitude: 135.4454)),
                Location(name: "東寺", coordinate: CLLocationCoordinate2D(latitude: 34.5850, longitude: 135.4452)),
                Location(name: "嵐山", coordinate: CLLocationCoordinate2D(latitude: 35.0034, longitude: 135.4000)),
                Location(name: "薫習館", coordinate: CLLocationCoordinate2D(latitude: 35.0050, longitude: 135.4535)),
                Location(name: "南禅寺", coordinate: CLLocationCoordinate2D(latitude: 35.0041, longitude: 135.7833)),
                Location(name: "マールブランジュ 京都タワーサンド店", coordinate: CLLocationCoordinate2D(latitude: 34.5914, longitude: 135.4533)),
                Location(name: "哲学の道", coordinate: CLLocationCoordinate2D(latitude: 35.0117, longitude: 135.4739)),
                Location(name: "京都水族館", coordinate: CLLocationCoordinate2D(latitude: 34.5915, longitude: 135.4449)),
                Location(name: "錦市場", coordinate: CLLocationCoordinate2D(latitude: 35.0018, longitude: 135.4553)),
                Location(name: "妙心寺", coordinate: CLLocationCoordinate2D(latitude: 35.0122, longitude: 135.4311)),
                Location(name: "建仁寺", coordinate: CLLocationCoordinate2D(latitude: 35.00, longitude: 135.4624)),
                Location(name: "大仙寺", coordinate: CLLocationCoordinate2D(latitude: 35.0139, longitude: 135.4157)),
                Location(name: "正伝寺", coordinate: CLLocationCoordinate2D(latitude: 35.0344, longitude: 135.4412)),
                Location(name: "御金神社", coordinate: CLLocationCoordinate2D(latitude: 35.0042, longitude: 135.4517)),
                Location(name: "花見小路通", coordinate: CLLocationCoordinate2D(latitude: 35.0019, longitude: 135.4630)),
                Location(name: "壬生寺", coordinate: CLLocationCoordinate2D(latitude: 35.0006, longitude: 135.4436)),
                Location(name: "池田屋騒動之趾", coordinate: CLLocationCoordinate2D(latitude: 35.0032, longitude: 135.4611)),
                Location(name: "上賀茂神社", coordinate: CLLocationCoordinate2D(latitude: 35.0329, longitude: 135.4528)),
                Location(name: "下鴨神社", coordinate: CLLocationCoordinate2D(latitude: 35.0220, longitude: 135.4622)),
                Location(name: "ポケモンセンターキョウト", coordinate: CLLocationCoordinate2D(latitude: 35.0036, longitude: 135.7583)),
                Location(name: "ポケモンセンターキョウト", coordinate: CLLocationCoordinate2D(latitude: 35.0036, longitude: 135.7583)),
                Location(name: "筑波大学春日エリア", coordinate: CLLocationCoordinate2D(latitude: 36.0510, longitude: 140.0623)),
                Location(name: "筑波大学第三エリア", coordinate: CLLocationCoordinate2D(latitude: 36.0532, longitude: 140.0607)),
                // 他の地点を追加...
            ]

    var body: some View {
            VStack {
                Spacer()

                Text(locationManager.locationStatusMessage)
                    .font(.system(size: 20))  // フォントサイズを大きくする
                    .foregroundColor(.blue)
                    .padding()

                if locationManager.isLocationUpdated {
                    if let location = locationManager.location {
                        // 緯度と経度を表示
                        Text("緯度: \(location.coordinate.latitude)")
                        Text("経度: \(location.coordinate.longitude)")
                    }
                    Button(action: {
                        selectLocationBasedOnDistance()
                    }) {
                        Text("次の目的地を選択")
                            .foregroundColor(.white)
                            .font(.system(size: 18))  // ボタンのテキストも大きくする
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    if let selectedLocation = selectedLocation {
                        Text("選択地点: \(selectedLocation.name)")
                            .font(.title2)  // フォントサイズを大きくする
                            .padding()
                        
                    }
                }
                
                // 新しい地点を追加するための入力フィールド
                            TextField("追加したい地点の名前", text: $newLocationName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            TextField("緯度", text: $newLocationLatitude)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            TextField("経度", text: $newLocationLongitude)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            Button("地点を追加") {
                                addNewLocation()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                
                            // 地点追加メッセージ
                            if !locationAddedMessage.isEmpty {
                                Text(locationAddedMessage)
                                    .foregroundColor(.green)
                                    .padding()
                            }
                            // 追加された地点のリストを表示するScrollView
                            ScrollView {
                                ForEach(locations) { location in
                                    VStack(alignment: .leading) {
                                        Text(location.name)
                                            .fontWeight(.bold)
                                        Text("緯度: \(location.coordinate.latitude)")
                                        Text("経度: \(location.coordinate.longitude)")
                                    }
                                    .padding()
                                }
                            }
                            Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // VStackを画面いっぱいに広げる
            .padding()
        }

    
    func addNewLocation() {
        guard let latitude = Double(newLocationLatitude), let longitude = Double(newLocationLongitude), !newLocationName.isEmpty else {
            // 不適切な入力値の場合の処理
            locationAddedMessage = "正しい地点情報を入力してください。"
            return
        }
        
        let newLocation = Location(name: newLocationName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        locations.append(newLocation)
        newLocationName = ""
        newLocationLatitude = ""
        newLocationLongitude = ""
        locationAddedMessage = "地点を追加できました！"
    }

    func calculateWeights(currentLocation: CLLocation) {
        let adjustmentFactor: Double = 7.5
        let distanceExponent: Double = 1.35

        let totalWeight = locations.reduce(0) { total, location in
            let distance = currentLocation.distance(from: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) / 1000.0
            let weight = 1 / pow(distance + adjustmentFactor, distanceExponent)
            return total + weight
        }

     
        for i in 0..<locations.count {
            let distance = currentLocation.distance(from: CLLocation(latitude: locations[i].coordinate.latitude, longitude: locations[i].coordinate.longitude)) / 1000.0
            locations[i].weight = (1 / pow(distance + adjustmentFactor, distanceExponent)) / totalWeight
        }
    }

    func selectLocationBasedOnDistance() {
        if let currentLocation = locationManager.location {
            calculateWeights(currentLocation: currentLocation)

            let randomValue = Double.random(in: 0..<1)
            var cumulativeWeight = 0.0
            for location in locations {
                cumulativeWeight += location.weight
                if randomValue < cumulativeWeight {
                    selectedLocation = location
                    break
                }
            }
        }
    }
                }
            


