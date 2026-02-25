//
//  ContentView.swift
//  Curso-iOS-Notificaciones
//
//  Created by Equipo 2 on 25/2/26.
//

import SwiftUI

struct VistaPrincipal: View {
    @Environment(NotificationManager.self) var manager
    
    @State private var horaProgramada = Date()
    @State private var recordatorio = "Revisar apuntes de SwiftUI"
    
    @State private var mostrarAlertaAjustes = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    TextField("Recordatorio", text: $recordatorio)
                    DatePicker("Hora", selection: $horaProgramada, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    HStack {
                        Text("Estado permisos:")
                        Spacer()
                        VistaEstadoPermisos(status: manager.estadoAutorizacion)
                    }
                }
                
                Section {
                    Button("Programar aviso") {
                        programarAccionDeAviso()
                    }
                }
            }
            
            .navigationTitle("Notificaciones")
        }
    }
    
    func programarAccionDeAviso() {
        
    }
}

struct VistaEstadoPermisos: View {
    let status: UNAuthorizationStatus
    
    var body: some View {
        switch status {
        case .authorized:
            Text("Autorizado").foregroundStyle(.green)
        case .denied:
            Text("Denegado").foregroundStyle(.red)
        case .notDetermined:
            Text("Pendiente").foregroundStyle(.orange)
        default:
            Text("Otros...").foregroundStyle(.gray)
        }
    }
}

struct VistaDetalle: View {
    let texto: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
                .symbolEffect(.bounce)
            
            Text("¡Recordatorio recibido!")
                .font(.title2)
                .bold()
            
            Text(texto)
                .font(.body)
                .padding()
                .background(Color.orange.opacity(0.3))
                .cornerRadius(10)
                
        }
        .navigationTitle("Recordatorio")
    }
}

#Preview("Vista detalle") {
    return NavigationStack { VistaDetalle(texto: "Tómate la pastillita") }
}

#Preview("Vista principal") {
    VistaPrincipal()
        .environment(NotificationManager())
}
