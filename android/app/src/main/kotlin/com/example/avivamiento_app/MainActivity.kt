package com.example.avivamiento_app

// 1. Importa la Activity correcta del plugin de audio
import com.ryanheise.audioservice.AudioServiceActivity

// 2. Hereda de AudioServiceActivity en lugar de FlutterActivity
class MainActivity: AudioServiceActivity() {
    // 3. NO NECESITAS NADA MÁS.
    // Esta clase base se encarga de toda la lógica de 
    // motores de fondo que el 'builder:' necesita.
}