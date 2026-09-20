# Diagrama de Conexiones y Cableado (Wiring Guide)

Este documento especifica el conexionado físico entre los módulos electrónicos del robot.

---

## 1. Conexión Microcontrolador a Driver de Motores (TB6612FNG)

| Pin Driver TB6612FNG | Pin ESP32 | Pin RPi Pico | Función |
| :--- | :--- | :--- | :--- |
| **PWMA** | GPIO 18 | GP2 | Velocidad Motor Izquierdo (PWM) |
| **AIN1** | GPIO 19 | GP3 | Dirección A Motor Izquierdo |
| **AIN2** | GPIO 21 | GP4 | Dirección B Motor Izquierdo |
| **PWMB** | GPIO 22 | GP5 | Velocidad Motor Derecho (PWM) |
| **BIN1** | GPIO 23 | GP6 | Dirección A Motor Derecho |
| **BIN2** | GPIO 25 | GP7 | Dirección B Motor Derecho |
| **STBY** | GPIO 26 | GP8 | Standby (Habilitación, HIGH) |
| **VCC** | 3.3V | 3V3(OUT) | Alimentación lógica |
| **GND** | GND | GND | Masa lógica (común) |
| **VM** | Batería (+) | Batería (+) | Alimentación de potencia motores (6V - 12V) |
| **GND (Potencia)** | Batería (-) | Batería (-) | Masa de potencia (unificada con GND común) |

> [!NOTE]
> Si utilizas **L298N** en lugar de TB6612FNG:
> Retira los jumpers de **ENA** y **ENB** y conéctalos a los pines de PWM correspondientes (PWMA y PWMB). Conecta IN1, IN2, IN3, IN4 a las líneas de dirección AIN1, AIN2, BIN1, BIN2.

---

## 2. Enlace Raspberry Pi 4 <-> Microcontrolador (Pico / ESP32)

Se recomienda utilizar el cable **USB tipo A a micro-USB o USB-C** conectado directamente entre uno de los puertos USB de la Raspberry Pi y el puerto USB del microcontrolador:
- Proporciona comunicación serie confiable como `/dev/ttyACM0` o `/dev/ttyUSB0`.
- Alimenta el microcontrolador de forma limpia desde el bus USB de la Raspberry.
- Si se usa UART física por GPIO (Pines 8 y 10 de Raspberry Pi), recuerda que el nivel lógico de Raspberry y Pico/ESP32 es **3.3V**.

---

## 3. Monitor de Batería INA219 (I²C en Raspberry Pi)

| Pin INA219 | Pin Físico RPi 4 | Función GPIO |
| :--- | :--- | :--- |
| **VCC** | Pin 1 | 3.3V Power |
| **GND** | Pin 9 | Ground |
| **SDA** | Pin 3 | GPIO 2 (I2C SDA) |
| **SCL** | Pin 5 | GPIO 3 (I2C SCL) |
| **VIN+** | Batería (+) antes de cargas | Entrada medición shunt |
| **VIN-** | Entrada de convertidor DC-DC / Driver | Salida hacia consumidores |

---

## 4. Audio I²S (Opcional - Prototipo Avanzado)

### Micrófono Digital I²S (INMP441)
- **VDD:** Pin 1 (3.3V)
- **GND:** Pin 6 (GND)
- **SD:** Pin 38 (GPIO 20 / PCM DIN)
- **WS (LRCL):** Pin 35 (GPIO 19 / PCM FS)
- **SCK (BCLK):** Pin 12 (GPIO 18 / PCM CLK)
- **L/R:** GND (Canal Izquierdo)

### Amplificador I²S (MAX98357A)
- **VIN:** Pin 2 o 4 (5V)
- **GND:** Pin 14 (GND)
- **DIN:** Pin 40 (GPIO 21 / PCM DOUT)
- **BCLK:** Pin 12 (GPIO 18 / PCM CLK)
- **LRC:** Pin 35 (GPIO 19 / PCM FS)
- **GAIN / SD:** Sin conectar (ganancia por defecto)
