//
//  ContentView.swift
//  BetterRest
//
//  Created by Zoltan Vegh on 12/04/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    var bedtime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, something went wrong"
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker(selection: $coffeeAmount, label: Text("Coffee")) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0) cup\($0 == 1 ? "" : "s")")
                        }
                    }
                } header: {
                    Text("Coffee consumption")
                        .font(.headline)
                }
                
                Section {
                    Text(bedtime)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                } header: {
                    Text("Your ideal bedtime is")
                        .font(.headline)
                }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
            }
            .navigationTitle("BetterRest")
        }
    }
}

#Preview {
    ContentView()
}
