# Comunicación UART entre Microcontroladores PIC16F887

Este proyecto, escrito en lenguaje ensamblador, consiste en la implementación de un sistema de comunicación UART entre dos microcontroladores PIC16F887. Un microcontrolador actúa como emisor, mientras que el otro actúa como receptor. La comunicación se establece a través de transmisiones y recepciones de datos seriales, permitiendo la interacción entre ambos dispositivos. El proytecto esta implementado en el entorno de desarrollo **MPLAB X IDE**.

## Autores
- **Franco Nicolas Bottini**
- **Valentin Robledo**
- **Aquiles Benjamin Lencina**
- **Santiago Quinteros del Castillo**

## Componentes Utilizados
### Microcontroladores
- **Emisor:** PIC16F887
- **Receptor:** PIC16F887

### Otros Componentes
- **Teclado Matricial:** Utilizado en el emisor para la entrada de datos.
- **Display de 7 Segmentos:** Implementado en el receptor para la visualización de datos recibidos.

## Simulación en Proteus
El proyecto incluye la simulación del sistema en el entorno de diseño electrónico Proteus. Esto permite verificar el funcionamiento del sistema antes de su implementación física, garantizando una mayor eficiencia en el desarrollo y la identificación temprana de posibles problemas.

## Funcionalidades Principales
1. **Emisor:**
   - Escanea un teclado matricial para la entrada de datos.
   - Almacena los datos en un buffer para su posterior transmisión a través de UART.

2. **Receptor:**
   - Recibe datos a través de la comunicación UART.
   - Visualiza los datos recibidos en un display de 7 segmentos.

## Desarrollo del Proyecto

### Configuración de los Microcontroladores
- Se selecciona el microcontrolador PIC16F887 para ambos el emisor y el receptor.
- La configuración incluye la frecuencia del oscilador, configuración de los pines, y otros parámetros específicos de los microcontroladores.

### Comunicación UART
- Se establece la comunicación UART entre los microcontroladores mediante los pines TX y RX.
- La configuración de la velocidad de transmisión (baud rate) se realiza para garantizar una comunicación eficiente y confiable.

### Teclado Matricial (Emisor)
- Se implementa el escaneo de un teclado matricial para la entrada de datos en el emisor.
- La detección de pulsaciones se realiza de manera precisa para evitar lecturas erróneas.

### Display de 7 Segmentos (Receptor)
- El receptor cuenta con un display de 7 segmentos para visualizar los datos recibidos.
- Se ha definido una tabla de decodificación para convertir los datos en formatos adecuados para la visualización.

### Subrutinas Específicas
1. **PutBuffer (Emisor):**
   - Almacena los datos provenientes del teclado matricial en un buffer para su posterior transmisión.

2. **PollBuffer (Receptor):**
   - Verifica y extrae datos del buffer de recepción para su procesamiento.

3. **SendRegister (Emisor):**
   - Envía los datos almacenados en el buffer a través de la comunicación UART.

4. **Keypad (Emisor):**
   - Escaneo y manejo de pulsaciones del teclado matricial, asegurando una entrada de datos correcta.

5. **DisplayData (Receptor):**
   - Procesa los datos recibidos y los muestra en el display de 7 segmentos.

6. **Multiplex (Receptor):**
   - Realiza la multiplexación para actualizar la visualización en el display.