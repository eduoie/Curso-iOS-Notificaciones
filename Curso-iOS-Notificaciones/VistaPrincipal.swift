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
    @State private var mostrarMensajeExito = false
    
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
            
            // Cuando el usuario clica en la notificación, se actualiza idRecordatorio y navega a VistaDetalle
            .navigationDestination(item: Bindable(manager).idRecordatorio) { tituloRecordatorio in
                VistaDetalle(texto: tituloRecordatorio)
            }
            
            // Vamos a escuchar una notificación interna por si el usuario viene de Ajustes al conceder o no los permisos
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await manager.comprobarEstadoPermisos() }
            }
            
            .alert("Permisos necesarios", isPresented: $mostrarAlertaAjustes) {
                Button("Cancelar", role: .cancel) { }
                Button("Ir a Ajustes") {
                    // Este código nos abre la ventana de ajustes
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Has desactivado las notificaciones. Por favor, actívalas en Ajustes para recibir recordatorios.")
            }
            
            // Popup temporal de que la notificación se ha programado
            .overlay(alignment: .bottom) {
                if mostrarMensajeExito {
                    Text("✅ Notificación programada")
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom)) // para la animación
                        .padding(.bottom, 50)
                }
            }
        }
    }
    
    func programarAccionDeAviso() {
        switch manager.estadoAutorizacion {
        case .authorized:
            manager.programarNotificacion(titulo: recordatorio, date: horaProgramada)
            
            withAnimation {
                mostrarMensajeExito = true
            }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    withAnimation {
                        mostrarMensajeExito = false
                    }
                }
            }

        case .notDetermined:
            // cuando es la primera vez, pedimos los permisos
            Task {
                await manager.solicitarPermiso()
                if manager.estadoAutorizacion == .authorized {
                    manager.programarNotificacion(titulo: recordatorio, date: horaProgramada)
                }
            }
        
        case .denied:
            // El usuario ha bloqueado los permisos y tenemos que mostrarle un aviso para que vaya a Ajustes
            mostrarAlertaAjustes = true
            
        default:
            break
        }
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
