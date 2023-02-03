//
//  UserInformationView.swift
//  HotProspects
//
//  Created by 최준영 on 2023/02/02.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct UserInformationView: View {
    
    @State private var name = ""
    @State private var address = ""
    @State private var qRImage: Image?
    
    let filter = CIFilter.qrCodeGenerator()
    let context = CIContext()
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                HStack(spacing: 0) {
                    HStack {
                        Text("Name")
                            .font(.body)
                            .bold()
                        Spacer()
                    }
                    .frame(width: 80)
                    Divider()
                    TextField("enter your name", text: $name)
                        .padding(.leading, 5)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                HStack(spacing: 0) {
                    HStack {
                        Text("Address")
                            .font(.body)
                            .bold()
                        Spacer()
                    }
                    .frame(width: 80)
                    Divider()
                    TextField("enter your address", text: $address)
                        .padding(.leading, 5)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
            }
            .frame(height: 150)
            .scrollContentBackground(.hidden)
            .background(.indigo)
            ZStack {
                LinearGradient(colors: [.indigo, .cyan], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 0) {
                    Button {
                        withAnimation {
                            qRImage = Image(uiImage: makeStringToQrCode(from: "\(name)\n\(address)"))
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .frame(width: 200, height: 70)
                                .foregroundColor(.secondary)
                                .opacity(0.5)
                            Text("Create QR Code")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .padding()
                    if let unwrappedImg = qRImage {
                        unwrappedImg
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .transition(.scale)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
    
    func makeStringToQrCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImg = filter.outputImage {
            if let cgImg = context.createCGImage(outputImg, from: outputImg.extent) {
                return UIImage(cgImage: cgImg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct UserInformationView_Previews: PreviewProvider {
    static var previews: some View {
        UserInformationView()
    }
}
