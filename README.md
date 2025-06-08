# Subasta Smart Contract

## Descripción
Este contrato inteligente en Solidity implementa una subasta de lotes con reglas definidas, asegurando transparencia y eficiencia en el proceso.
Se deja constancia que se trata de un ejercicio de práctica con fines académicos y por ello tanto la complegidad como los elementos particulares
se centraron en un cierto alcance y con el fin de fijar conocimientos en forma escalonada.

## Características
- Gestión de ofertas y ganador.
- Extensión de subasta basada en actividad.
- Protección contra ofertas inválidas.
- Manejo de comisiones y recuperación de fondos.

## Estructura del Código
El contrato está dividido en bloques organizados para mejorar la legibilidad:
1. **Datos del Lote subastado**: Información clave de la subasta que como no se incluía en
   la propuesta original al menos se toma al menos en forma simplificada para ayudar a la
   propuesta académica.
3. **Condiciones de la Subasta**: Parámetros como incrementos mínimos y tiempo de extensión.
4. **Comisiones**: Estructura de pagos y costos de recuperación.
   El tema comisiones merece una aclaración especial dado que por tratarse de un prueba
   didáctica quizás en este planteo en particular quedaron algunas inconsistencias en el
   enunciado respecto a las practicas mas reales. Se consideró que al ofertante se le
   cobraria solamente la comision de 2% estipulada por enunciado  sobre el monto
   que quede depositado en el contrato al cierre (dado que se interpreta alude a los gastos
   de gas que en dicho caso recaerian en el del subastador y debe asegurarse su recupero.
   En un caso mas real, entiendo, deberia plantearse este porcentaje automaticamente en funcion
   de la base de la subasta teniendo en cuenta el Costo máximo del gas, el gas usado por dicha
   transaccion y agregando un factor de seguridad o cobertura para garantizar la viabilidad
   economica de la operacion. Como quedó planteado, si no hay base o es un numero menor de weis,
   el subastador no lograria cubrir los gastos y la subasta seria economicamente inviable.
   Que el ofertante que no posee la oferta ganadora no pueda retirar su ultima oferta hasta
   tanto se cierre la subasta, si bien sería una situación totalmente atípica en la realidad,
   intuyo está pensado a los fines académicos de que el estudiante diferencie como se direcciona
   el cobro de las tasas por consumo de gas y procesamiento segun quien impulse la acción, por
   cual opte por mantenerlo de dicho modo.
6. **Funciones Principales**:
   - `Ofertar()`: Permite que los participantes envíen ofertas.
   - `recuperarOfertasCaidas()`: Retiro de ofertas no ganadoras salvo la ultima realizada.
   - `liquidarSubasta()`: Finaliza la subasta y distribuye los fondos.
7. **Enfoque general utilizado en la eleccion de la logica y la estructura de datos**:
   - Minimizar los costos transaccionales del subastador y el contrato, con exepción de
     ciertas estructuras que tienen el fin de dar legibilidad al código, conncentrando el
     mayor gasto transaccional en la funcion de "Ofertar" con la finalidad que los únicos
     costos que deba soportar el subastador se concentren solo en el despliegue y en la
     liquidacion final, con la seguridad que con las comisiones pactadas de antemano, pueda
     obtenerse la rentabilidad esperada y que la responsabilidad de los costos que se pagan
     por el uso de la red no pasen a engrosar a los ojos de los participantes las comisiones
     del subastador. 

    
