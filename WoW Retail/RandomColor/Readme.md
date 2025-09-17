# RandomColorBars

RandomColorBars is a World of Warcraft addon that assigns visually distinct colors to unit health bars based on their category: hostile, friendly, or neutral. Colors are dynamically assigned to minimize similarity and are updated automatically when changing zones or maps.

---

## Features

- Automatically assigns distinct colors for **hostile**, **friendly**, and **neutral** units.  
- Colors are reassigned when crossing zones or entering new maps.  
- Uses a large palette of predefined colors to minimize similarity.  
- Non-intrusive: hooks into default unit frame updates without interfering with other addons.

---

## Installation

1. Go to the addon page on CurseForge:  
   [https://www.curseforge.com/wow/addons/random-color-bars](https://www.curseforge.com/wow/addons/random-color-bars)  


---

## Usage

- Load the addon in-game. Colors will be assigned automatically on login and when changing zones.  
- To customize the similarity threshold or the color palette, modify the `umbral` value or `coloresDisponibles` array inside `RandomColorBars.lua`.

---

## Configuration

- `umbral`: A value between 0 and 1 that defines how different colors must be. Higher values make colors more distinct.  
- `coloresDisponibles`: Array of RGB colors available for assignment. You can add or remove colors as desired.

---

# RandomColorBars (Español)

RandomColorBars es un addon de World of Warcraft que asigna colores visualmente distintos a las barras de salud de las unidades según su categoría: hostil, amistosa o neutral. Los colores se asignan dinámicamente para minimizar similitudes y se actualizan automáticamente al cambiar de zona o mapa.

---

## Características

- Asigna automáticamente colores distintos para unidades **hostiles**, **amistosas** y **neutrales**.  
- Los colores se reasignan al cruzar zonas o entrar en nuevos mapas.  
- Utiliza una gran paleta de colores predefinidos para minimizar similitudes.  
- No intrusivo: se integra con las actualizaciones estándar de las barras de unidad sin interferir con otros addons.

---

## Instalación

1. Ve a la página del addon en CurseForge:  
   [https://www.curseforge.com/wow/addons/random-color-bars](https://www.curseforge.com/wow/addons/random-color-bars)  

---

## Uso

- Carga el addon en el juego. Los colores se asignarán automáticamente al iniciar sesión y al cambiar de zona.  
- Para personalizar el umbral de similitud o la paleta de colores, modifica el valor `umbral` o el array `coloresDisponibles` dentro de `RandomColorBars.lua`.

---

## Configuración

- `umbral`: Valor entre 0 y 1 que define qué tan distintos deben ser los colores. Valores más altos hacen que los colores sean más diferentes.  
- `coloresDisponibles`: Array de colores RGB disponibles para asignación. Puedes añadir o quitar colores según lo desees.
