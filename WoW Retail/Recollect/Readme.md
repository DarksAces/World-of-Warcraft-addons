# Recollect – DPS/Damage/Healing Meter

**Author:** Daniel  
**Version:** 1.0  
**Description:** Recollect is a modern DPS, damage, and healing meter for WoW, with support for pets, resizable interface, stylish progress bars, and clear display of players and their pets.

---

## 📥 Installation
Download and install from [CurseForge](https://www.curseforge.com/wow/addons/recolect).

---

## ⚙️ Customization
- **Window size:** The main window is resizable with minimum (`180x200`) and maximum (`1000x1200`) limits.  
- **Views:** Toggle between DPS, Damage, Damage Taken, Healing Done, and Healing Taken using the top view buttons.  
- **Sorting:** Change the order of the lists with `↓ Desc / ↑ Asc`.  
- **Reset:** Reset all data using the `Reset` button.  

---

## 🎨 Interface
- **Modern design:** Gradient-style background, styled border, and shiny header bar.  
- **Dynamic rows:** Each player and their pets appear in rows with:
  - Class or pet icon.
  - Player/pet name.
  - Value according to the selected view.
  - Progress bar proportional to the highest recorded value.
  - Position number in the table.
- **Expand/Collapse pets:** Players with pets have a button to expand or collapse their list.

---

## 🐾 Pet Support
- **Advanced detection:** Recollect identifies pets by type, name, and owner class.
- **Custom icons:** Each pet has a specific icon based on type (e.g., Imp, Succubus,elemental, etc.).
- **Numbering:** Multiple pets of the same type are automatically numbered.

---

## 🛠 Main Functions
- `ResetData()` – Clears all recorded data.
- `UpdateDisplay()` – Updates the table display.
- `GetPlayerValue(playerData, viewType)` – Gets the value according to the selected view (DPS, Damage, Healing, etc.).
- `FormatNumber(num)` – Formats large numbers as `K` or `M`.
- `GetPlayerPets(playerName)` – Returns a list of a player's pets.
- `GetPlayerClass(playerName)` – Returns the class of a player.

---

# Recollect – Medidor de DPS/Daño/Curación

**Autor:** Daniel  
**Versión:** 1.0  
**Descripción:** Recollect es un medidor moderno de DPS, daño y curación para WoW, con soporte para mascotas, interfaz redimensionable, barras de progreso estilizadas y visualización clara de jugadores y sus mascotas.

---

## 📥 Instalación
Descarga e instala desde [CurseForge](https://www.curseforge.com/wow/addons/recolect).

---

## ⚙️ Personalización
- **Tamaño de la ventana:** La ventana principal es redimensionable con restricciones mínimas (`180x200`) y máximas (`1000x1200`).  
- **Vistas:** Alterna entre DPS, Damage, Damage Taken, Healing Done y Healing Taken usando los botones de vista superiores.  
- **Orden:** Cambia el orden de las listas con el botón `↓ Desc / ↑ Asc`.  
- **Reset:** Reinicia todos los datos con el botón `Reset`.  

---

## 🎨 Interfaz
- **Diseño moderno:** Fondo con estilo degradado, borde estilizado y barra de cabecera con efecto brillante.  
- **Filas dinámicas:** Cada jugador y sus mascotas se muestran en filas con:
  - Icono de clase o mascota.
  - Nombre del jugador/pet.
  - Valor según la vista seleccionada.
  - Barra de progreso proporcional al valor máximo registrado.
  - Número de posición en la tabla.
- **Expandir/Colapsar mascotas:** Si un jugador tiene mascotas, se muestra un botón para expandir o colapsar su lista.

---

## 🐾 Soporte de mascotas
- **Detección avanzada:** Recollect identifica mascotas por tipo, nombre y clase del dueño.
- **Iconos personalizados:** Cada mascota tiene su icono específico según su tipo (ej. Imp, Succubus, Elemental, etc.).
- **Numeración:** Si un jugador tiene múltiples mascotas del mismo tipo, se numeran automáticamente.

---

## 🛠 Funciones principales
- `ResetData()` – Limpia todos los datos registrados.
- `UpdateDisplay()` – Actualiza la visualización de la tabla.
- `GetPlayerValue(playerData, viewType)` – Obtiene el valor según la vista seleccionada (DPS, Daño, Curación, etc.).
- `FormatNumber(num)` – Formatea números grandes como `K` o `M`.
- `GetPlayerPets(playerName)` – Devuelve la lista de mascotas de un jugador.
- `GetPlayerClass(playerName)` – Devuelve la clase de un jugador.
