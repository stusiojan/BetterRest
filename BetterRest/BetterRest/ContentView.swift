//
//  ContentView.swift
//  BetterRest
//
//  Created by Jan Stusio on 26/02/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var idealBedtime = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from:components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .pickerStyle(.segmented)
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted())hours", value: $sleepAmount, in: 2...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker("Please enter how much coffe do you drink each day", selection: $coffeeAmount) {
                        ForEach(1..<21){
                            Text($0 == 1 ? "1 cup" : "\($0) cups")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
//                    .onChange(of: coffeeAmount, perform: calculateBedtime())
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                
                Section {
                    Button("Calculate", action: calculateBedtime)
                    Text(idealBedtime)
                        .font(.largeTitle)
                } header: {
                    Text("Your ideal bedtime is...")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep

            idealBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            idealBedtime = "Sorry, there was a problem calculating your bedtime"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
