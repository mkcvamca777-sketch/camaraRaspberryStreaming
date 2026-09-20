# Guía de Diagnóstico y Resolución de Problemas (Troubleshooting)

---

## 1. La Raspberry Pi se reinicia al acelerar los motores
- **Causa:** Caída de tensión momentánea (brownout) provocada por el consumo inicial de los motores, afectando la línea de 5V de la Raspberry Pi.
- **Solución:**
  1. No alimentar los motores desde la línea de 5V de la Raspberry Pi.
  2. Verificar que el convertidor DC-DC entregue un mínimo de **3.5A continuos** y esté calibrado a **5.1V**.
  3. Soldar un condensador electrolítico de **470 µF a 1000 µF** en los bornes `VM` y `GND` del driver de motores.
  4. Revisar que los cables de masa (`GND`) tengan una sección adecuada (AWG 18-20).

---

## 2. La APK no conecta con el servidor WebSocket
- **Causa:** Dispositivos en subredes diferentes, IP errónea o puerto bloqueado por firewall.
- **Solución:**
  1. Asegurar que el smartphone y la Raspberry Pi estén en la misma red Wi-Fi local.
  2. Obtener la IP real de la Raspberry Pi mediante:
     ```bash
     hostname -I
     ```
  3. Comprobar que el puerto 8765 no esté bloqueado por `ufw`:
     ```bash
     sudo ufw allow 8765/tcp
     ```

---

## 3. Uno o ambos motores giran en sentido contrario al deseado
- **Causa:** Polaridad invertida en los bornes de salida del driver hacia los motores DC.
- **Solución:** Invertir físicamente los dos cables del motor en el conector de clemas del driver (OUT1/OUT2 o OUT3/OUT4), o intercambiar los pines AIN1/AIN2 o BIN1/BIN2 en el firmware.

---

## 4. Latencia excesiva en video
- **Causa:** Congestión en la banda de 2.4 GHz o sobrecarga del codificador.
- **Solución:**
  1. Conectar la Raspberry Pi y el smartphone a la banda Wi-Fi de **5 GHz**.
  2. Reducir la resolución en los ajustes de la APK a **720p a 30 FPS**.
