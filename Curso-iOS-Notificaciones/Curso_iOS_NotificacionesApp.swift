//
//  Curso_iOS_NotificacionesApp.swift
//  Curso-iOS-Notificaciones
//
//  Created by Equipo 2 on 25/2/26.
//

import SwiftUI

@main
struct Curso_iOS_NotificacionesApp: App {
    @State private var manager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            VistaPrincipal()
                .environment(manager)
        }
    }
}
