//
//  NotificationManager.swift
//  Curso-iOS-Notificaciones
//
//  Created by Equipo 2 on 25/2/26.
//

import SwiftUI
import UserNotifications

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    var estadoAutorizacion: UNAuthorizationStatus = .notDetermined
    var idRecordatorio: String?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task {
            await comprobarEstadoPermisos()
        }
    }
    
    @MainActor
    func comprobarEstadoPermisos() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.estadoAutorizacion = settings.authorizationStatus
    }
    
    func solicitarPermiso() async {
        do {
            // Esta instrucción nos lanza el modal de sistema para que el usuario acepte o deniegue las notificaciones
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await comprobarEstadoPermisos()
        } catch {
            print("Error al solicitar permisos: \(error.localizedDescription)")
        }
    }
    
    func programarNotificacion(titulo: String, date: Date) {
        guard estadoAutorizacion == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio 📅"
        content.body = titulo
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        // El disparador de la alerta. Si ponemos repeats a true, se repetirá cada día
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let notificacion = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Publica la notificación en el sistema
        UNUserNotificationCenter.current().add(notificacion) { error in
            if let error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("Notificación programada correctamente")
            }
        }
    }
    
    func cancelarNotificaciones() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func listarNotificacionesPendientes() async {
        let notificacionesPendientes = await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: métodos delegados ⬇️
    
    // Caso de notificación cuando la app está abierta.
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        print("Notificación recibida en primer plano")
        return [.banner, .sound]
    }
    
    // Caso de notificación cuando la app está cerrada o en background y el usuario clica en ella
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        
        // el titulo del recordatorio lo hemos puesto en el body en la función programarNotificacion()
        let titulo = response.notification.request.content.body
        print("El usuario ha pulsado la notificación \(titulo)")
        self.idRecordatorio = titulo
    }
}
