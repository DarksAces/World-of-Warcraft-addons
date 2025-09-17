# 🧳 BagSpaceNotifier

BagSpaceNotifier is an addon for **World of Warcraft** that notifies you when your inventory is full according to configurable thresholds. Get alerts in chat and/or on screen to avoid losing items due to lack of space.

---

## 🚀 Installation

1. Download the addon and copy the `BagSpaceNotifier` folder to your WoW addons directory:
   - `World of Warcraft/_retail_/Interface/AddOns/`
2. Restart the game or use `/reload` to load the addon.

---

## ⚙️ What does it do?

- Detects the percentage of your bag space used.
- Shows alerts in chat and/or on screen when configured thresholds are exceeded (default: 50%, 75%, 90%, 95%).
- Allows easy alert configuration via commands.

---

## 📝 Commands

- `/bn config`  
  Shows current configuration and available commands.
- `/bn chat on` / `/bn chat off`  
  Enables/disables chat alerts.
- `/bn screen on` / `/bn screen off`  
  Enables/disables on-screen alerts.
- `/bn reset`  
  Restores default configuration.
- `/bn status`  
  Shows current inventory usage percentage.
- `/bn save`  
  Shows saved configuration.

---

## 💡 Customization

You can edit alert thresholds by modifying the `thresholds` table in the `BagSpaceNotifier.lua` file.

---

## 📢 Credits

Developed by Daniel.  
Keep your inventory under control and never lose important items!

---

# 🧳 BagSpaceNotifier

BagSpaceNotifier es un addon para **World of Warcraft** que te avisa cuando tu inventario está lleno según umbrales configurables. Recibe alertas en el chat y/o en pantalla para evitar perder objetos por falta de espacio.

---

## 🚀 Instalación

1. Descarga el addon y copia la carpeta `BagSpaceNotifier` en tu directorio de addons de WoW:
   - `World of Warcraft/_retail_/Interface/AddOns/`
2. Reinicia el juego o usa `/reload` para cargar el addon.

---

## ⚙️ ¿Qué hace?

- Detecta el porcentaje de ocupación de tus bolsas.
- Muestra alertas en el chat y/o en pantalla cuando se superan los umbrales configurados (por defecto: 50%, 75%, 90%, 95%).
- Permite configurar las alertas fácilmente con comandos.

---

## 📝 Comandos

- `/bn config`  
  Muestra la configuración actual y los comandos disponibles.
- `/bn chat on` / `/bn chat off`  
  Activa o desactiva las alertas en el chat.
- `/bn screen on` / `/bn screen off`  
  Activa o desactiva las alertas en pantalla.
- `/bn reset`  
  Restaura la configuración por defecto.
- `/bn status`  
  Muestra el porcentaje actual de ocupación del inventario.
- `/bn save`  
  Muestra la configuración guardada.

---

## 💡 Personalización

Puedes editar los umbrales de alerta modificando la tabla `thresholds` en el archivo `BagSpaceNotifier.lua`.

---

## 📢 Créditos

Desarrollado por Daniel.  
¡Evita perder objetos importantes y mantén tu inventario bajo control!