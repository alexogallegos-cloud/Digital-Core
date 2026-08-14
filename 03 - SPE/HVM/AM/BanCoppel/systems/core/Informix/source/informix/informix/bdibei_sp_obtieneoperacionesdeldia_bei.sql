CREATE PROCEDURE "informix".sp_obtieneoperacionesdeldia_bei( pNumCte CHAR(20), p_sUsuario CHAR(20), p_dFecha date, pDesde INTEGER, pHasta INTEGER )
    RETURNING CHAR(6), CHAR(10), CHAR(50), CHAR(12), CHAR(12), CHAR(16), CHAR(10), CHAR(40),CHAR(40);

-- *************************************************
-- Realizo: Mauricio Leon Ibarra
-- Modificacion: Consulta las operaciones del dia de usuarios de BEI
--Fecha: 25/10/2011
-- Realizo: Jose Ruben Lopez Hernandez
-- Modificacion:Se agrego el parametro v_sDestinoSpei
--Fecha: 12/04/2013
-- Liberado a produccion: Mayo 2014
-- Modificacion: Se agregan los id's para dispersiones de Ã³rdenes de pago 3003 y 3004
-- Bibiana Gaxiola Verdugo
-- 19/03/2015
--
-- Modificacion: Se agregan validaciones para omitir las consultas de reimpresiÃ³n de comprobantes
-- Gabriela Aguilar Mendoza
-- 06/07/2018
-- *************************************************

--Declaracion de variables
DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret        INTEGER;
DEFINE v_sFecha CHAR(10);
DEFINE v_sTransaccion CHAR(50);
DEFINE v_sOrigen CHAR(12);
DEFINE v_sDestino CHAR(12);
DEFINE v_sImporte CHAR(16);
DEFINE v_sFAplicacion CHAR(10);
DEFINE v_sFolio CHAR(40);
DEFINE v_sDestinoSpei CHAR(40);


--Asignacion de variables
LET v_sFecha = '';
LET v_sTransaccion = '';
LET v_sOrigen = '';
LET v_sDestino = '';
LET v_sImporte = '';
LET v_sFAplicacion = '';
LET v_sFolio = '';
LET v_sCodRet = '000';
LET v_sDestinoSpei='';



 --set debug file to "/informix/gaby/ArchivosOut/sp_obtieneoperacionesdeldia_bei";
   --Trace on;

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei;
            END IF;
        END EXCEPTION;

	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	--Se valida que el usuario no este en blanco o en nulo
	IF (NVL(p_sUsuario,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '147';
		RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei ;
	END IF;

        FOREACH SELECT SKIP pDesde FIRST pHasta  to_char(fecha_oper,'%m/%d/%Y'), NVL(desc_oper,''), NVL(cuenta_origen,''), NVL(destino,''), NVL(monto_oper,'0.00'), to_char(fecha_aplic,'%m/%d/%Y'), NVL(cgenerico1,''),NVL(cgenerico2,'')
                INTO v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio, v_sDestinoSpei
                --FROM bdinteg:"informix".si_bpibitacorapm a, bdinteg:"informix".si_bpioperaciones b
				FROM bdibei:"informix".bei_bitacora a, bdibpi:"informix".bpi_cat_operaciones b
                WHERE DATE(fecha_oper) = DATE(p_dFecha)
                AND a.id_operacion = b.id_oper
				AND a.num_cliente = pNumCte
				AND id_usuario = p_sUsuario
				AND id_operacion IN ('1026','1006','1007','1008','1011','1015','1016','1017','1020','2011','2015','2020','1021','1022','1023','3025','3026','3029','3030','2001', '2004', '2005', '2006','3028','2021','2022','2023','3003','3004')
                AND NVL(a.cgenerico5,'') <>'RC'
				and NVL(a.cgenerico3,'') <>'RC'
				and NVL(a.cgenerico2,'') <>'RC'
				ORDER BY fecha_oper

                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei WITH RESUME;

        END FOREACH;
END
END PROCEDURE;