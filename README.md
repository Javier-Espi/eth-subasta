# Subasta Smart Contract

## Descripción
Este contrato inteligente en Solidity implementa una subasta de lotes con reglas definidas, asegurando transparencia y eficiencia en el proceso.
Se deja constancia que se trata de un ejercicio de practica con fines academicos y por ello tanto la complegidad como los elementos particulares
se ceentraron en un cierto alcance y con el fin de fijar conocimientos en forma escalonada.

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
   El tema comisiones merece una aclaracion especial dado que por tratarse de un prueba
   didáctica quizas en este planteo en particular quedaron algunas inconsistencias en el
   enunciado respecto a las practicas mas reales. Se consideró que al ofertante se le
   cobraria solamente la comision de 2% estipulada por enunciado  sobre el monto
   que quede depositado en el contrato al cierre (dado que se interpreta alude a los gastos
   de gas que en dicho caso recaerian en el del subastador y debe asegurarse su recupero.
   En un caso mas real, entiendo, deberia plantearse este porcentaje automaticamente en funcion
   de la base de la subasta teniendo en cuenta el Costo máximo del gas, el gas usado por dicha
   transaccion y agregando un factor de seguridad o cobertura para garantizar la viabilidad
   economica de la operacion. Como quedó planteado, si no hay base o es un numero menor de wei
   el subastador no lograria cubrir los gastos y la subasta seria economicamente inviable.
5. **Funciones Principales**:
   - `Ofertar()`: Permite que los participantes envíen ofertas.
   - `recuperarOfertasCaidas()`: Retiro de ofertas no ganadoras salvo la ultima realizada.
   - `liquidarSubasta()`: Finaliza la subasta y distribuye los fondos.
6. **Enfoque general utilizado en la eleccion de la logica y la estructura de datos**:
   - Minimizar los costos transaccionales del subastador y el contrato, con exepcion de
     ciertas estructuras que tienen el fin de dar legibilidad al codigo, conncentrando el
     mayor gasto transaccional en la funcion de "Ofertar" con la finalidad que los únicos
     costos que deba soportar el subastador se concentren solo en el despliegue y en la
     liquidacion final, con la seguridad que con las comisiones pactadas de antemano, pueda
     obtenerse la rentabilidad esperada. 

    
