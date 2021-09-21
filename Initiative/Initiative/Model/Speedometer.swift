//
//  Speedometer.swift
//  Initiative
//
//  Created by Andres Liu on 11/12/20.
//

import SwiftUI

struct Speedometer: View {
    var body: some View {
        Home()
    }
}
var child = UIHostingController(rootView: Speedometer())
var child2 = UIHostingController(rootView: Speedometer())
var child3 = UIHostingController(rootView: Speedometer())
var child4 = UIHostingController(rootView: Speedometer())


struct Speedometer_Previews: PreviewProvider {
    static var previews: some View {
        Speedometer()
    }
}
  struct Home : View {
      
      let colors = [Color("gaugeColor"),Color("gaugeColor")]
      @State var progress : CGFloat = 70
    @ObservedObject var speedometerObs: SpeedometerObs = SpeedometerObs(meterValue: 50)
      var body: some View{
          
          VStack{
              
            Meter(progress: CGFloat(self.speedometerObs.meterValue))
              
//              HStack(spacing: 25){
                  
//                  Button(action: {
//
//                      withAnimation(Animation.default.speed(0.55)){
//
//                          self.progress += 10
//
//                      }
//
//                  }) {
//
//                      Text("Update")
//                          .padding(.vertical,10)
//                          .frame(width: (UIScreen.main.bounds.width - 50) / 2)
//
//                  }
//                  .background(Capsule().stroke(LinearGradient(gradient: .init(colors: self.colors), startPoint: .leading, endPoint: .trailing), lineWidth: 2))
                  
                  
//                  Button(action: {
//
//                      withAnimation(Animation.default.speed(0.55)){
//
//                          self.progress = 0
//                      }
//
//                  }) {
//
//                      Text("Reset")
//                          .padding(.vertical,10)
//                          .frame(width: (UIScreen.main.bounds.width - 50) / 2)
//
//                  }
                  //                  .background(Capsule().stroke(LinearGradient(gradient: .init(colors: self.colors), startPoint: .leading, endPoint: .trailing), lineWidth: 2))
//              }
//              .padding(.top, 55)
          }
      }
  }
  
  
  struct Meter : View {
      
      let colors = [Color("gaugeColor"),Color("gaugeColor")]
      var progress : CGFloat
      
      var body: some View{
          ZStack{
              
              ZStack{
                  
                  Circle()
                      .trim(from: 0, to: 0.5)
                      .stroke(Color.black.opacity(0.1), lineWidth: 25)
                      .frame(width: 60, height: 60)
                  
                  
                  Circle()
                      .trim(from: 0, to: self.setProgress())
                      .stroke(AngularGradient(gradient: .init(colors: self.colors), center: .center, angle: .init(degrees: 180)), lineWidth: 25)
                      .frame(width: 60, height: 60)
                  
              }
              .rotationEffect(.init(degrees: 180))
              .offset(x:30, y: 20)
              ZStack(alignment: .bottom) {
                  
                  self.colors[0]
                  .frame(width: 2, height: 30)
                  
                  Circle()
                      .fill(self.colors[0])
                      .frame(width: 15, height: 15)
              }
              .offset(x: 30, y: 7)
              .rotationEffect(.init(degrees: -90))
              .rotationEffect(.init(degrees: self.setArrow()))
              
              
          }
          .padding(.bottom, -140)
      }
      
      func setProgress()->CGFloat{
          
        let temp = self.progress / 2
          return temp * 0.01
      }
      
      func setArrow()->Double{
          
        let temp = self.progress / 100
          return Double(temp * 180)
      }
  }
  
