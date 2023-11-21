//
//  ContentView.swift
//  dsotm-switfui
//
//  Created by Jaydeep Joshi on 30/09/23.
//

import SwiftUI

struct Params {
    var lightFraction = 0.55
    var prismFraction = 0.4
    var dispersionSize = 0.2
    var rainbowSize = 0.15
}

struct ContentView: View {
    @State var fraction: Double = 0
    @State var params = Params()

    var body: some View {
        ScrollView {
            DarkSideView(params: params, drawnFraction: fraction)
            .clipped()
            Spacer()
            slider("Light Fraction", value: $params.lightFraction, in: 0.1...0.9)
            slider("Prism Fraction", value: $params.prismFraction, in: 0.3...0.7)
            slider("Dispersion", value: $params.dispersionSize, in: 0.1...0.3)
            slider("Rainbow", value: $params.rainbowSize, in: 0.1...0.5)
            slider("Drawn Fraction", value: $fraction, in: 0...1)
            Button("Reset", role: .destructive) {
                params = Params()
            }
        }.onAppear {
            withAnimation(.linear(duration: 2)) {
                fraction = 1
            }
        }
    }

    @ViewBuilder
    private func slider(_ label: String, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label)
            Slider(value: value, in: range)
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
