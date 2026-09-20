# Guía de Alimentación y Potencia (Power Supply Guide)

Una arquitectura de alimentación robusta es esencial en robótica móvil para evitar **reinicios aleatorios (brownouts)** en la Raspberry Pi 4 debido a los picos de corriente inductiva que generan los motores al arrancar o cambiar de sentido.

---

## 1. Esquema de Distribución de Energía

```
               [ PACK BATERÍA (2S / 3S Li-ion) ]
                              │
                      [ BMS DE PROTECCIÓN ]
                              │
                    [ INTERRUPTOR GENERAL ]
                              │
                    [ FUSIBLE 5A RÁPIDO ]
                              │
         ┌────────────────────┴────────────────────┐
         │                                         │
         ▼                                         ▼
[ CONVERTIDOR DC-DC BUCK ]               [ DRIVER DE MOTORES ]
(Salida 5.1V / 4A Continuos)            (Condensador 470µF desacoplo)
         │                                         │
         ▼                                         ▼
  [ RASPBERRY PI 4 ]                           [ MOTORES DC ]
         │ (Bus USB 5V)
         ▼
  [ ESP32 / PICO 2 W ]
```

---

## 2. Puntos Críticos de Implementación

> [!CAUTION]
> **Nunca alimentar la Raspberry Pi 4 directamente desde la batería:**
> La Raspberry Pi 4 requiere **5.0V - 5.2V regulados**. Un voltaje mayor dañará permanentemente la placa.

1. **Convertidor DC-DC (Step-Down Buck):**
   - Utilizar un módulo con capacidad continua de al menos **3.5A a 4.0A** (ej. basado en XL4015, LM2596 de alta calidad o convertidores síncronos mini de 5A).
   - Ajustar el trimmer de salida a **5.1V** medidos con multímetro antes de conectar a la Raspberry Pi.

2. **Desacoplo para Motores:**
   - Soldar un condensador electrolítico de **470 µF a 1000 µF (16V o 25V)** directamente en los bornes `VM` y `GND` del driver de motores.
   - Soldar un condensador cerámico de **100 nF (0.1 µF)** en paralelo en cada borne de los motores DC para amortiguar el ruido de conmutación de escobillas (chispas electromagnéticas).

3. **Topología de Masas (Masa en Estrella):**
   - El punto de unión común de masas (`GND`) debe ser la salida del BMS de la batería.
   - No encadenar la masa de alta potencia de los motores a través de los pines de la Raspberry Pi.
