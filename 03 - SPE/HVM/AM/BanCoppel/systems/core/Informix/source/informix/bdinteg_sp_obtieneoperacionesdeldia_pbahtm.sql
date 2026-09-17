CREATE PROCEDURE "informix".sp_obtieneoperacionesdeldia_pbahtm( p_sUsuario CHAR(20), p_dFecha date, pDesde INTEGER, pHasta INTEGER )
    RETURNING CHAR(6), CHAR(10), CHAR(50), CHAR(12), CHAR(18), CHAR(16), CHAR(10), CHAR(40);

--Declaracion de variables

DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret INTEGER;

DEFINE v_sFecha CHAR(10);
DEFINE v_sTransaccion CHAR(50);
DEFINE v_sOrigen CHAR(12);
DEFINE v_sDestino CHAR(18);
DEFINE v_sImporte CHAR(16);
DEFINE v_sFAplicacion CHAR(10);
DEFINE v_sFolio CHAR(40);

-- *************************************************
-- Realizo: Walber Castro                    
-- Actividad: Obtener las operaciones del dÃ­a 
-- Solicito: Diana Castellanos                
--Fecha: 29/JUNIO/2010                                                      
-- 
-- Realizo: JosÃ© de JesÃºs Nevarez             
-- Modificacion: Se agrega id_operacion 1022 DISH y 1023 MASTV para que se incluya dentro de las operaciones a consultar--*
-- Solicito: Mauricio LeÃ³n                    
--Fecha: 3/SEPTIEMBRE/2010                        
--
-- Realizo: ING. ALFONSO CRUZ
-- Modificacion: Se cambia el campo de cosnsulta de folio de la operaciÃ³n
-- Solicito: WALBERTO CASTRO
-- Fecha: 15/07/2013
--
-- Se cambia la tabla de bitÃ¡cora y se agregan las operaciones de Pago TDC terceros BanCoppel
-- Bibiana Gaxiola
-- 29/11/2013
--
--Realizo: Roberto Castro
--Modificacion: Se agrega id_operacion 1033 para que se incluya pago de servicio avon en las operaciones del dia.
--Solicito: Bibiana Gaxiola
--Fecha: 16/06/2014
--
--Realizo: Jose Ruben Lopez
--Modificacion: Se agrega id_operacion 1034 para que se incluya las ordenes de pago en las operaciones del dia.
--Solicito: Jose de Jesus Nevarez
--Fecha: 15/01/2015
--

--Realizo: RenÃ© Aldana
--Modificacion: Se agrega id_operacion 1050 para que se incluya las transferencias a cuentas transfer en las operaciones del dia.
--Solicito: Alejandro Vazquez
--Fecha: 18/01/2017
--*******************************************

--Asignacion de variables
LET v_sFecha = '';
LET v_sTransaccion = '';
LET v_sOrigen = '';
LET v_sDestino = '';
LET v_sImporte = '';
LET v_sFAplicacion = '';
LET v_sFolio = '';
LET v_sCodRet = '000';

--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtieneoperacionesdeldia.out";
--TRACE ON;   

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
            END IF;
        END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	--Se valida que la cuenta no este en blanco o en nulo

	IF (NVL(p_sUsuario,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes 
		where cve_mensaje = '147';
		RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
	END IF;		

        FOREACH SELECT SKIP pDesde FIRST pHasta  DATE(fecha_oper), NVL(desc_oper,''), NVL(cuenta_origen,''), NVL(destino,''), NVL(monto_oper,'0.00'), DATE(fecha_aplic), NVL(folio,'')
                INTO v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio
                FROM bdibpi:"informix".bpi_bitacora a, bdibpi:"informix".bpi_cat_operaciones b
                WHERE DATE(fecha_oper) = DATE(p_dFecha)
                AND a.id_operacion = b.id_oper AND id_usuario = p_sUsuario
				AND id_operacion IN ('1006',
				'1007',
				'1008',
				'1011',
				'1015',
				'1016',
				'1017',
				'1020',
				'1021',
				'1022',
				'1023',
				'1024',
				'1025',
				'1026',
				'1027',
				'1030',
				'1031',
				'1033',
				'2011',
				'2015',
				'2017',
				'2020',
				'2021',
				'2022',
				'2023',
				'2027',
				'1034',
				'1050',
				'1041')
                ORDER BY fecha_oper

                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio WITH RESUME;     
        
        END FOREACH;        
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1597 - EdoMovimientos',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 15-09-2015',
'MODIFICACIÃN..: Se cambia tamaÃ±o del quinto parametro del retorno de 12 a 18 caracteres',
'SOLICITA......: Jesus Montoya',
'BD............: BDINTEG',
'FOLIO.........: 308 - HomologaciÃ³n de Servicios Coppel',
'AUTOR.........: Arturo Astorga',
'FECHA.........: 20-09-2017',
'MODIFICACIÃN..: Se agrega id_operacion 1041 para que se incluya pago de servicio CFE en las operaciones del dia.',
'SOLICITA......: Evelia Ontiveros Valenzuela',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_obtieneoperacionesdeldia_pb2( p_sUsuario CHAR(20), p_dFecha date, pDesde INTEGER, pHasta INTEGER )
    RETURNING CHAR(6), CHAR(10), CHAR(50), CHAR(12), CHAR(18), CHAR(16), CHAR(10), CHAR(40);

--Declaracion de variables

DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret INTEGER;

DEFINE v_sFecha CHAR(10);
DEFINE v_sTransaccion CHAR(50);
DEFINE v_sOrigen CHAR(12);
DEFINE v_sDestino CHAR(18);
DEFINE v_sImporte CHAR(16);
DEFINE v_sFAplicacion CHAR(10);
DEFINE v_sFolio CHAR(40);

-- *************************************************
-- Realizo: Walber Castro                    
-- Actividad: Obtener las operaciones del dÃ­a 
-- Solicito: Diana Castellanos                
--Fecha: 29/JUNIO/2010                                                      
-- 
-- Realizo: JosÃ© de JesÃºs Nevarez             
-- Modificacion: Se agrega id_operacion 1022 DISH y 1023 MASTV para que se incluya dentro de las operaciones a consultar--*
-- Solicito: Mauricio LeÃ³n                    
--Fecha: 3/SEPTIEMBRE/2010                        
--
-- Realizo: ING. ALFONSO CRUZ
-- Modificacion: Se cambia el campo de cosnsulta de folio de la operaciÃ³n
-- Solicito: WALBERTO CASTRO
-- Fecha: 15/07/2013
--
-- Se cambia la tabla de bitÃ¡cora y se agregan las operaciones de Pago TDC terceros BanCoppel
-- Bibiana Gaxiola
-- 29/11/2013
--
--Realizo: Roberto Castro
--Modificacion: Se agrega id_operacion 1033 para que se incluya pago de servicio avon en las operaciones del dia.
--Solicito: Bibiana Gaxiola
--Fecha: 16/06/2014
--
--Realizo: Jose Ruben Lopez
--Modificacion: Se agrega id_operacion 1034 para que se incluya las ordenes de pago en las operaciones del dia.
--Solicito: Jose de Jesus Nevarez
--Fecha: 15/01/2015
--

--Realizo: RenÃ© Aldana
--Modificacion: Se agrega id_operacion 1050 para que se incluya las transferencias a cuentas transfer en las operaciones del dia.
--Solicito: Alejandro Vazquez
--Fecha: 18/01/2017
--*******************************************

--Asignacion de variables
LET v_sFecha = '';
LET v_sTransaccion = '';
LET v_sOrigen = '';
LET v_sDestino = '';
LET v_sImporte = '';
LET v_sFAplicacion = '';
LET v_sFolio = '';
LET v_sCodRet = '000';

--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtieneoperacionesdeldia.out";
--TRACE ON;   

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
            END IF;
        END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	--Se valida que la cuenta no este en blanco o en nulo

	IF (NVL(p_sUsuario,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes 
		where cve_mensaje = '147';
		RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
	END IF;		

        FOREACH SELECT SKIP pDesde FIRST pHasta  DATE(fecha_oper), NVL(desc_oper,''), NVL(cuenta_origen,''), NVL(destino,''), NVL(monto_oper,'0.00'), DATE(fecha_aplic), NVL(folio,'')
                INTO v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio
                FROM bdibpi:"informix".bpi_bitacora a, bdibpi:"informix".bpi_cat_operaciones b
                WHERE DATE(fecha_oper) = DATE(p_dFecha)
                AND a.id_operacion = b.id_oper AND id_usuario = p_sUsuario
				AND id_operacion IN ('1006',
				'1007',
				'1008',
				'1011',
				'1015',
				'1016',
				'1017',
				'1020',
				'1021',
				'1022',
				'1023',
				'1024',
				'1025',
				'1026',
				'1027',
				'1030',
				'1031',
				'1033',
				'2011',
				'2015',
				'2017',
				'2020',
				'2021',
				'2022',
				'2023',
				'2027',
				'1034',
				'1050',
				'1041')
                ORDER BY fecha_oper

                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio WITH RESUME;     
        
        END FOREACH;        
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1597 - EdoMovimientos',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 15-09-2015',
'MODIFICACIÃN..: Se cambia tamaÃ±o del quinto parametro del retorno de 12 a 18 caracteres',
'SOLICITA......: Jesus Montoya',
'BD............: BDINTEG',
'FOLIO.........: 308 - HomologaciÃ³n de Servicios Coppel',
'AUTOR.........: Arturo Astorga',
'FECHA.........: 20-09-2017',
'MODIFICACIÃN..: Se agrega id_operacion 1041 para que se incluya pago de servicio CFE en las operaciones del dia.',
'SOLICITA......: Evelia Ontiveros Valenzuela',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_consultarnombre_monitor(pEmpresa char (3), pNombre1 char(26), pNombre2 char(26), pApe_pat char (26),pApe_mat char(26), pRegistros SMALLINT)
    returning char (5) AS retorno, char (9) AS numcliente, char (26) AS nombre1, char (26) AS nombre2, char (26) AS apepaterno, char (26) AS apematerno, char (13) AS RFC;

   --Elaboró: Javier A. Chávez T.
   --Actividad: consulta los datos de un cliente por nombre
   --Solicito: Mauricio León
   --Fecha: 26-03-09

   --DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE vNomCte1 char (26);
    DEFINE vNomCte2 char (26);
    DEFINE vApe_pat char (26);
    DEFINE vApe_mat char (26);
    DEFINE vNumCte char (9);
    DEFINE vRfc char (13);

    --SET DEBUG FILE TO "/tmp/sp_consultanombre_monitoreo.out";
    -- TRACE ON;

    --Inicializa
    LET cod_ret  = "000";
    LET vNomCte1 = "";
    LET vNumCte = "0";
    LET vNomCte2 = "";
    LET vApe_pat = "";
    LET vApe_mat = "";
    LET vRfc = "";
    LET pNombre1 = UPPER(TRIM(pNombre1));
    LET pNombre2 = UPPER(TRIM(pNombre2));
    LET pApe_pat = UPPER(TRIM(pApe_pat));
    LET pApe_mat = UPPER(TRIM(pApe_mat));

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat,vRfc;
      END IF ;
   END EXCEPTION ;


   IF (pNombre1 <> "") THEN
        IF (pApe_pat <> "" or pApe_mat <> "") THEN

        {    IF(pNombre2 = '')THEN
                LET pNombre2 = NULL;
            END IF;

            IF(pApe_pat = '')THEN
                LET pApe_pat = NULL;
            END IF;

            IF(pApe_mat = '')THEN
                LET pApe_mat = NULL;
            END IF;}

            set lock mode to wait 3;
            SET ISOLATION DIRTY READ;

            let pNombre1 = trim(pNombre1)||"*";
            let pNombre2 = trim(pNombre2)||"*";
            let pApe_pat = trim(pApe_pat)||"*";
            let pApe_mat = trim(pApe_mat)||"*";

            FOREACH
                SELECT SKIP pRegistros FIRST 10 numcte, nombre1,nombre2,apell_paterno, apell_materno, rfc
                INTO vNumCte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc
                FROM bdinteg:si_cliente
                WHERE --razon_social is null and
                apell_paterno MATCHES pApe_pat
                AND apell_materno  MATCHES pApe_mat
                and nombre1 MATCHES pNombre1
                AND nombre2 MATCHES pNombre2                                
                AND empresa = pEmpresa
		AND tipo_cliente = '1'

                RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc WITH RESUME;

            END FOREACH;

         IF (vNomCte1 = "") THEN

          LET cod_ret = "001";
           RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;

          END IF;
        ELSE
         LET cod_ret = "003";
         RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;
        END IF;

    ELSE
        LET cod_ret = "002";
         RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;
   END IF;

 END;
END PROCEDURE;