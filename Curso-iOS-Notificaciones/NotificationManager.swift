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
}
