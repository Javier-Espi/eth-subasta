// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.30;

contract Subasta {

    // ---DATOS DEL LOTE SUBASTADO---
        address private subastador;  // No encuadro como inmutable ya que se pueden agregar funcionalidades de gestion mas adelante (fuera del alcance de la practica).
        uint256 public immutable loteID;
        address private immutable vendedor; // Se agrega para reforzar las transferencias y su manejo sin entrar en detalle con la entrega del activo o su contraprestacion.-
        uint256 public immutable baseSubasta;

    // ---DATOS DE LAS CONDICIONES DE LA SUBASTA---
        uint16 private immutable porcentajeSaltoNuevaOferta; 
        uint256 private immutable tsExtenderNuevaOferta;
        uint8 private immutable porcentajeComisionRecuperoGas;
   
    // ---DATOS DE LAS COMISIONES DE LA SUBASTA--- VER AACLARACION ESPECIAL EN READ.ME
        uint256 private immutable porcentajeComisionVendedor;
        uint256 private immutable porcentajeComisionOfertante;

        /* El tema comisiones merece una aclaracion especial dado que por tratarse de un prueba didáctica quizas
           en este planteo en particular quedaron algunas inconsistencias en el enunciado respecto a las practicas
           mas reales. Se consideró que al ofertante se le cobraria solamente la comision de 2% requerida solamente
           sobre el monto que quede depositado en el contrato al cierre dado que los gastos de gas de la misma estan
           a cargo del subastador y debe asegurarse su recupero.
           En un caso mas real entiendo, deberia plantearse este porcentaje automaticamente en funcion de la base de
           la subasta

        */

    // ---BLOQUE DE CODIGO DEL CONSTRUCTOR Y SUS MODIFICADORES ESPECIFICOS---
        constructor(
            uint256 _loteID,
            address _vendedor,
            uint256 _baseSubasta,
            uint256 _duracionMinima,
            uint16 _porcentajeSaltoNuevaOferta,
            uint256 _tsExtenderNuevaOferta,
            uint8 _porcentajeComisionRecuperoGas,
            uint256 _porcentajeComisionVendedor

            ) esValida(_vendedor) {
            subastador = msg.sender;
            loteID = _loteID;
            vendedor = _vendedor;
            baseSubasta = _baseSubasta;
            ts = Ts(block.timestamp, 0, _duracionMinima);
            porcentajeSaltoNuevaOferta = _porcentajeSaltoNuevaOferta;
            tsExtenderNuevaOferta = _tsExtenderNuevaOferta;
            porcentajeComisionRecuperoGas = _porcentajeComisionRecuperoGas;
            porcentajeComisionVendedor = _porcentajeComisionVendedor;
        }
 
        modifier esValida(address _direccion) {
            require(_direccion != address(0), "La direccion cargada es invalida.-");
            _;
        }

    // ---BLOQUE PARA LA ESTRUCTURA DE LOS DATOS---  -EN READ.ME SE AMPLIA Y JUSTIFICA-
        mapping(address => uint256) private balanceOfertante; 
        mapping(address => uint256) private ultimaOferta;

        struct Oferta {
            uint256 montoOfertado;
            address ofertante;
        }
        Oferta[] ofertas;
        Oferta public ofertaGanadora;

        struct Ts {
            uint256 timestampInicio;
            uint256 timestampUltimaOferta;
            uint256 duracion;
        }    
        Ts private ts;


    // ---BLOQUE DE MODIFICADORES---
        //---DE USO GENERAL---
            modifier soloSubastador() {
                require(msg.sender == subastador, "Solo el subastador puede realizar esta tarea");
                _;
            }
        //---DE USO PARTICULAR O PARA MEJORAR LA LEGIBILIDAD---
            modifier esOfertaValida(uint256 _nuevaOferta) {
                require(msg.sender != subastador && msg.sender != vendedor,
                    "El subastador o Vendedor no pueden participar en su propia subasta");
                require(tiempoAlCierre() > 0, "Lo sentimos, finalizo el tiempo. Subasta en proceso de liquidacion.-");
                require(msg.value > 0, "El monto ofertado debe ser mayor a cero.-");
                require(address(msg.sender).balance >= _nuevaOferta, "Su saldo es insuficiente para realizar la operacion");
                require(_nuevaOferta >= baseSubasta, "Se debe ofertar al menos el monto base propuesto para la subasta.-");
                require( _nuevaOferta*100 > (ofertaGanadora.montoOfertado*(100 + porcentajeSaltoNuevaOferta)),
                    "Debe ofertar por encima del porcentaje minimo establecido para superar la Oferta Ganadora vigente");
                _;
            }

    // ---BLOQUE DE EVENTOS---
        event OfertaRecibida(address indexed ofertante, uint256 montoOferta, uint256 lote);
        event Finalizacion(uint256 TsDeCierre, bool Exito, uint256 ofertaGanadora, uint256 lote);


    // ---BLOQUE DE FUNCIONES---
        //---FUNCIONES TRANSACCIONALES DEL OFERENTE Y SUS SUB-FUNCIONES---

            function Ofertar() payable external esOfertaValida(msg.value) {
                ofertaGanadora = Oferta(msg.value, msg.sender);
                ofertas.push(ofertaGanadora);
                balanceOfertante[msg.sender] += msg.value;
                ultimaOferta[msg.sender] = msg.value;
                actualizarTs();
                emit OfertaRecibida(msg.sender, msg.value, loteID);
            }

            function actualizarTs() private {
                if (tiempoAlCierre() < int256(tsExtenderNuevaOferta)) {
                    ts.timestampInicio = block.timestamp;
                    ts.duracion = tsExtenderNuevaOferta;
                    ts.timestampUltimaOferta = block.timestamp;
                    }
                else {
                    ts.timestampUltimaOferta = block.timestamp;
                    }
            }

            function recuperarOfertasCaidas() payable external {
                require(balanceOfertante[msg.sender] != 0, "No posee saldo transferido a esta subasta.-");
                require(balanceOfertante[msg.sender] > ultimaOferta[msg.sender],
                     "Por condiciones de la subasta, la ultima oferta sera retenida hasta la liquidacion de la misma al cierre y se le retendran un % en concepto de recupero del GAS.-");
        (bool resultadoCall,) = msg.sender.call{value: (balanceOfertante[msg.sender] - ultimaOferta[msg.sender])}("");
        require(resultadoCall, "Error al trasnsferir el monto de recupero de Oferta solicitado.-");
        balanceOfertante[msg.sender] = ultimaOferta[msg.sender];
            }
                
        //---FUNCIONES CONSULTA DEL OFERENTE---      
            function tiempoAlCierre() public view returns (int256) {
                int256 _faltan = int256(ts.timestampInicio) + int256(ts.duracion) - int256(block.timestamp);
                return _faltan > 0 ? _faltan : int256(0);
            }

            function listarOfertas() public view returns(Oferta[] memory _ofertas) {
                return ofertas;
            }

        //---FUNCIONES TRANSACCIONALES POR LIQUIDACION (SUBASTADOR) Y SUS SUB-FUNCIONES---
            /* Se opto usar el prefijo "ss - Solo Subastador) en todas estas funciones para agruparlas.-
               Sin duda en una practica mas real hubiese preferido separar la distintas funcionalidades
               en funciones individuales para tener un mayor control de su ejecucion y poder manejar mejor
               si susceden errores, para este ejercicio me pareció excesivo hacerlo antes de tratar mas
               en profundidad ese tema en particular.
            */
            function ssLiquidarSubasta() external payable soloSubastador {
                require(tiempoAlCierre() == 0, "Aun no finalizo el tiempo estipulado en las condiciones.-");
                require(address(this).balance > 0, "No hay fondos en el contrato para liquidar.-");

                bool _exito = ofertaGanadora.montoOfertado > 0;

                //---Reembolso a ofertantes no ganadores (descontando recupero de gas)---
                for (uint i = 0; i < ofertas.length; i++) {
                    if (ofertas[i].ofertante != ofertaGanadora.ofertante) {
                        uint256 montoReembolso = balanceOfertante[ofertas[i].ofertante] * (100 - porcentajeComisionRecuperoGas) / 100;
                        (bool resultadoCallReembolso, ) = payable(ofertas[i].ofertante).call{value: montoReembolso}("");
                        require(resultadoCallReembolso, "Error al transferir reembolso.-");
                        balanceOfertante[ofertas[i].ofertante] = 0;
                    }
                }

                //--- Pago al vendedor descontando la comisión---
                uint256 montoVendedor = ofertaGanadora.montoOfertado * (100 - porcentajeComisionVendedor) / 100;
                (bool resultadoCallVendedor, ) = payable(vendedor).call{value: montoVendedor}("");
                require(resultadoCallVendedor, "Error al transferir pago al vendedor.-");

                //---Transferencia al subastador (saldo restante)---
                uint256 saldoSubastador = address(this).balance;
                (bool resultadoCallSubastador, ) = payable(subastador).call{value: saldoSubastador}("");
                require(resultadoCallSubastador, "Error al transferir saldo al subastador.-");

                //--- Emitir evento de finalización---
                emit Finalizacion(block.timestamp, _exito, ofertaGanadora.montoOfertado, loteID);
            }

            // Funcion mas que nada para facilitar la Auditoria de los eventos payable.-
            function ssSaldoContrato() public view soloSubastador returns (uint256) {
                return address(this).balance;
            }
}
