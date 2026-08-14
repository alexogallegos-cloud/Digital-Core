CREATE PROCEDURE "informix".sp_obtienegerenciacomercialcc(pNumGer SMALLINT)
	RETURNING 	CHAR(5)  AS CodigodeRetorno,
				CHAR(50) AS Mensaje,
				CHAR(3)  AS NumGer,
				CHAR(40) AS NombredeGer;

---DECLARACIONES
DEFINE iSqlErr	INTEGER;
DEFINE iIsamErr	INTEGER;
DEFINE cCod_ret	CHAR(5);
DEFINE cNumGer	CHAR(3);
DEFINE cNomGer	CHAR(40);
DEFINE cMensaje	CHAR(50);

LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET cNumGer	= '';
LET cNomGer		= '';
LET cMensaje	= 'EJECUCIÓN EXITOSA';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret = iSqlErr;
          RETURN cCod_ret,cMensaje,NVL(cNumGer,''),NVL(cNomGer,'');
       END IF;
    END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	-- SET DEBUG FILE TO "/respaldosbd/josue/sp_obtienegerenciacomercialcc.out";
	-- TRACE ON;
	
		FOREACH WITH HOLD		
			
			SELECT id_gerencia,gerencia_comercial INTO cNumGer,cNomGer
			FROM  "informix".si_catgcb_rh
			WHERE id_gerencia = DECODE(NVL(pNumGer,0),0,id_gerencia,pNumGer)
		
			RETURN cCod_ret,cMensaje,NVL(cNumGer,''),NVL(cNomGer,'') WITH RESUME;
			
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_ret = "00002";
			LET cMensaje = "NO EXISTE INFORMACIÓN";
		END IF;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:1469',
'AUTOR:94912599', 
'FECHA:20/01/2015',
'DESCRIPCIÓN: Procedimiento para consultar el catálago de gerencia comercial o una gerencia en particular',
'SUSTENTO:RQM 02 028 Modulo para la administracion de centro de costos.pdf',
'SOLICITA: Fernando Fernández Gómez';

CREATE PROCEDURE "informix".sp_obtienecatalogostatuscc(pEstatus SMALLINT)
	RETURNING 	CHAR(5)  AS CodigodeRetorno,
				CHAR(50) AS Mensaje,
				CHAR(15) AS Estatus,
				CHAR(40) AS Descripcion;

---DECLARACIONES
DEFINE iSqlErr	INTEGER;
DEFINE iIsamErr	INTEGER;
DEFINE cCod_ret	CHAR(5);
DEFINE cEstatus	CHAR(15);
DEFINE cDescripcion	CHAR(40);
DEFINE cMensaje	CHAR(50);

LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET cEstatus	= '';
LET cDescripcion = '';
LET cMensaje	= 'EJECUCIÓN EXITOSA';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret = iSqlErr;
          RETURN cCod_ret,cMensaje,NVL(cEstatus,''),NVL(cDescripcion,'');
       END IF;
    END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	-- SET DEBUG FILE TO "/respaldosbd/josue/sp_obtienecatalogostatuscc.out";
	-- TRACE ON;
		
		FOREACH WITH HOLD		
			
			SELECT id_status,status INTO cEstatus,cDescripcion
			FROM  "informix".si_catstatus_rh
			WHERE id_status = DECODE(NVL(pEstatus,0),0,id_status,pEstatus)
		
			RETURN cCod_ret,cMensaje,NVL(cEstatus,''),NVL(cDescripcion,'') WITH RESUME;
			
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_ret = "00002";
			LET cMensaje = "NO EXISTE INFORMACIÓN";
		END IF;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:1469',
'AUTOR:94912599', 
'FECHA:20/01/2015',
'DESCRIPCIÓN: Procedimiento para consultar el catálago de Estatus o un Estatus en particular',
'SUSTENTO:RQM 02 028 Modulo para la administracion de centro de costos.pdf',
'SOLICITA: Fernando Fernández Gómez';

CREATE PROCEDURE "informix".sp_actualizarelacionhistcc(pNomArchivo CHAR(100),pRuta CHAR(250))
	RETURNING 	CHAR(5)  AS CodigodeRetorno;

---DECLARACIONES
DEFINE iSqlErr	INTEGER;
DEFINE iIsamErr	INTEGER;
DEFINE cCod_ret	CHAR(5);
DEFINE iExiste	INTEGER;
DEFINE cSentencia CHAR(5000);
DEFINE cSucu	CHAR(4);
DEFINE cReg		INTEGER;
DEFINE cGcb		INTEGER;
DEFINE cStatus	INTEGER;
DEFINE cCadenaFinal	CHAR(150);

LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET iExiste		= 0;
LET cSentencia	= '';
LET cSucu	= '';
LET cReg	= 0;
LET cGcb	= 0;
LET cStatus	= 0;
LET cCadenaFinal = '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret =iSqlErr;
			SELECT COUNT(*) INTO iExiste FROM systables WHERE tabname = "tmp_si_actualizasucursales";

			IF iExiste = 1 THEN
			   DROP TABLE "informix".tmp_si_actualizasucursales;
			END IF;
		  RETURN cCod_ret;
       END IF;
    END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	 --SET DEBUG FILE TO "/respaldosbd/josue/sp_actualizarelacionhistcc.out";
	 --TRACE ON;
	
	
	SELECT COUNT(*) INTO iExiste FROM systables WHERE tabname = "tmp_si_actualizasucursales";

	IF iExiste = 0 THEN
	 CREATE TABLE "informix".tmp_si_actualizasucursales
	  (
		sucursal CHAR(4),
		region   INTEGER,
		gerencia INTEGER,
		estatus INTEGER
	  );
	END IF;
	
	LET cSentencia = ' echo "load from  '||TRIM(pRuta)||TRIM(pNomArchivo)||'  insert into "informix".tmp_si_actualizasucursales"'||
	 ' > query.sql';

	SYSTEM cSentencia;
	LET cSentencia = "dbaccess bdinteg query.sql";
	SYSTEM cSentencia;

	LET cSentencia = '';
	LET cSentencia = "rm  query.sql";
	SYSTEM cSentencia;
    
		
		FOREACH WITH HOLD		
			
			SELECT  sucursal,region,gerencia,estatus 
			INTO cSucu,cReg,cGcb,cStatus
			FROM "informix".tmp_si_actualizasucursales 
			
			IF NVL(cSucu,"") = "" THEN 
				CONTINUE FOREACH;
			END IF;
			
			IF NVL(cReg,"") <> "" THEN  
				UPDATE "informix".si_sucursales SET id_region_rh = cReg  WHERE sucursal = cSucu;		
			END IF;
			
			IF NVL(cGcb,"") <> "" THEN  
				UPDATE "informix".si_sucursales SET id_gerencia_rh = cGcb WHERE sucursal = cSucu;
			END IF;
			
			IF NVL(cStatus,"") <> "" THEN  
				UPDATE "informix".si_sucursales SET id_status_rh = cStatus WHERE sucursal = cSucu;		
			END IF;
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_ret = "00001";
		END IF;
		
			SELECT COUNT(*) INTO iExiste FROM systables WHERE tabname = "tmp_si_actualizasucursales";

			IF iExiste = 1 THEN
			   DROP TABLE "informix".tmp_si_actualizasucursales;
			END IF;
			
			RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:1469',
'AUTOR:94912599', 
'FECHA:5/02/2015',
'DESCRIPCIÓN: Procedimiento para insertar informacion en los campos id_region_rh,id_gerencia_rh,id ',
'de la tabla "informix".si_sucursales por medio de un archivo unl',
'SUSTENTO:RQM 02 028 Modulo para la administracion de centro de costos.pdf',
'SOLICITA: Fernando Fernández Gómez';

CREATE PROCEDURE "informix".sp_consultartdacoppel(pNumTienda CHAR(10))

--RETORNOS
RETURNING
CHAR(5) AS CodigoError,
CHAR(10) AS TiendaCoppel,
CHAR(40) AS Descripcion;

--DEFINICION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE cTiendaCoppel CHAR(10);
DEFINE cDescripcion CHAR(40);
DEFINE iSqlErr INTEGER;

--INICIALIZACION
LET cCodRet = "00000";
LET cTiendaCoppel = "";
LET cDescripcion = "";
LET iSqlErr = 0;

--SET DEBUG FILE TO "/informix/JOSE_CARLOS/sp_consulta_resumen_compensacion.out";
--TRACE ON;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTiendaCoppel,""), NVL(cDescripcion,""); -- ERROR NO CONTROLADO
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(NVL(pNumTienda,"")) = ""  THEN
		LET cCodRet = "00001"; -- PARAMETRO DE ENTRADA NULO
		RETURN cCodRet, NVL(cTiendaCoppel,""), NVL(cDescripcion,"");
	END IF;
	
	SELECT tienda, descripcion
		INTO cTiendaCoppel, cDescripcion
	FROM "informix".si_tiendascoppel
		WHERE tienda = TRIM(pNumTienda);
	

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "00002"; -- PARAMETRO DE ENTRADA NO SE ENCONTRO EN LA TABLA
	END IF;
	
	RETURN cCodRet, NVL(cTiendaCoppel,""), NVL(cDescripcion,"");
	
END;
END PROCEDURE
DOCUMENT
"AUTOR: 96152877 - Jose Raul Pacheco Ortiz",
"FOLIO: 1441-DepositosReferenciadosCoppelBancoppel",
"DESCRIPCION: Valida si la tienda existe en la tabla si_tiendascoppel.",
"FECHA: 04/09/2014",
"SUSTENTO: Se definio  en el requerimiento RQM 06 285 Depósitos Referenciados de Coppel en BanCoppel.",
"BD: BDINTEG";

CREATE PROCEDURE  "informix".cons_tarjetas_cte(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	    CHAR(26),      -- Nombre2
	    CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	       -- Fecha Nacimiento
	    CHAR(13),      -- RFC
	    CHAR(20),      -- CUENTA
	    CHAR(20),      -- TARJETA
	    CHAR(1),       -- STATUS APLICATIVO
	    SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);    --STATUS DE INTERCARD

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numcte        CHAR(20);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_paterno       CHAR(26);
DEFINE s_materno       CHAR(26);
DEFINE s_fechanac      DATE;
DEFINE s_rfc           CHAR(13);
DEFINE s_cuenta        CHAR(20);
DEFINE s_tarjeta       CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE s_status        CHAR(1);
DEFINE s_sistema       SMALLINT;
DEFINE s_status_cta    CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE s_rfc_alterno   CHAR(13);
DEFINE cProdTransfer   CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
SET OPTIMIZATION HIGH;
SET OPTIMIZATION ALL_ROWS;
LET scod_ret      = "000";
LET vsqlerr       = 0;
LET v_cuantos     = 0;
LET s_numcte      = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	      = "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status      = "";
LET s_sistema     = 0;
LET s_status_cta  = "";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta = "";
LET s_rfc_alterno = "";
LET cProdTransfer	= "";
--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO dirty READ;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/integral/cons_tarjetas_cte.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   LET pempresa = pempresa;
   LET pnumcte = pnumcte;


  -- Valida Parametros de Entrada

  IF pempresa = "" or
     pnumcte = ""  then
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF


	SELECT valor 
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE empresa = pempresa 
	AND	cod_param = 4;

  -- Extrae las Tarjeta de Cheques
	-- Se agrega la validaciÃ³n a la sc_firmantes para solo buscar tarjetas autorizadas
	-- CGP 10032015
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno  
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicheq:"informix".sc_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicheq:"informix".sc_maechq d,
            bdicheq:"informix".sc_producto e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar,
			bdicheq:"informix".sc_firmantes as firm
      WHERE a.empresa = b.empresa
            AND a.numcte = b.numcte
            AND a.empresa = c.empresa
            AND a.numcte = c.numcte
            AND a.empresa = d.empresa
            AND a.cuenta = d.cuenta
            AND e.empresa = a.empresa
            AND e.producto = a.prodtarjeta
            AND f.empresa = a.empresa
            AND f.divisa = e.divisa
			and (firm.cuenta = a.cuenta)
			and (firm.numcte = a.numcte)
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte))
			AND a.prodtarjeta <> cProdTransfer  order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF;

	 IF s_rfc_alterno is not null and s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno 
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicred:"informix".sd_maecred d,
            bdicred:"informix".sd_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicred:"informix".sd_definicion e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar
      WHERE d.numcte=pnumcte
            and d.numcte = b.numcte
            AND d.numcte = c.numcte
            and a.empresa = d.empresa
            and a.num_credito = d.num_credito  
            AND e.empresa = d.empresa
            AND e.num_producto = d.num_producto
            and f.empresa=pempresa
            AND f.divisa = d.divisa
            AND a.num_tarjeta = tar.numtarjeta
            AND d.status_cred <> "FF"
	ORDER BY a.num_tarjeta    

     LET s_sistema = 6;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

	 IF s_rfc_alterno is not null or s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

END

END PROCEDURE

DOCUMENT
"Especificacion: Se modifico para que consulte el status de la",
"                tarjeta en la tabla intercard:tarjeta y se regrese como retorno",
"Base de Datos : bdinteg",
"AUTOR : Jesus Manuel Perea Heredia",
"FECHA : 19/Nov/2010",
"Descripcion: Se actualiza a la nueva version de reglas.", 
"Base de Datos : bdinteg",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
'',
'FOLIO: 1611',
'FECHA : 26/06/2014',
'MODIFICO : 94972834',
'MODIFICACION: se modifica para excluir las tarjetas que pertenecen a un producto transfer',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_reconsultastatushuellalinea()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(2000) 	AS TramaSalida,
	CHAR(1)		AS EstatusConsulta;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCadena			CHAR(2000);
	DEFINE cEstatusConsulta	CHAR(1);

	--INICIALIZACION DE VARIABLES--
	LET iSql_err		= 0;
	LET cCodRet			= '00000';
	LET cCadena			= "";
	LET cEstatusConsulta	= "";

	--SET DEBUG FILE TO "/tmp/JA/sp_reconsultastatushuellalinea.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cCadena,cEstatusConsulta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			--Buscar las huellas que no se han enviado
			SELECT LIMIT 10 {+AVOID_FULL("informix".si_huella_linea)} TRIM(numcte) ||"|"|| TRIM(secuencia) ||"|"|| TRIM(sexo) ||"|"|| TRIM(sucursal) ||"|"|| YEAR(fecha_alta_huella)|| LPAD(MONTH(fecha_alta_huella),2,0) || LPAD(DAY(fecha_alta_huella),2,0) ||"|"|| TRIM(ip) ||"|"|| TRIM(tipo_mov_huella) ||"|"||
			TRIM(empleado) ||"|"|| TRIM(tipo_sensor) ||"|"|| TRIM(dmapa) ||"|"|| TRIM(imapa) ||"|"|| TRIM(status_huella) ||"|"|| TRIM(ref_coppel) ||"|"|| 
			YEAR(fecha_ult_cambio)|| LPAD(MONTH(fecha_ult_cambio),2,0)|| LPAD(DAY(fecha_ult_cambio),2,0)||" "||(fecha_ult_cambio::DATETIME HOUR TO HOUR::CHAR(2))||":"|| (fecha_ult_cambio::DATETIME MINUTE TO MINUTE::CHAR(2))||":"||(fecha_ult_cambio::DATETIME SECOND TO SECOND::CHAR(2)) ||"|"|| 
			TRIM(tipo_cliente) ||"|"||TRIM(tipo_verificacion) ||"|"|| TRIM(status_consulta), status_consulta --0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			INTO cCadena, cEstatusConsulta
			FROM bdinteg:"informix".si_huella_linea
			WHERE fecha_consulta = TODAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			AND status_consulta IN ('3','9','0') 
			AND fecha_insert < CURRENT - 10 UNITS MINUTE 
			ORDER BY status_consulta, fecha_consulta DESC 
			
			
			/*SELECT LIMIT 10 TRIM(numcte) ||"|"|| TRIM(secuencia) ||"|"|| TRIM(sexo) ||"|"|| TRIM(sucursal) ||"|"|| YEAR(fecha_alta_huella)|| LPAD(MONTH(fecha_alta_huella),2,0) || LPAD(DAY(fecha_alta_huella),2,0) ||"|"|| TRIM(ip) ||"|"|| TRIM(tipo_mov_huella) ||"|"||
			TRIM(empleado) ||"|"|| TRIM(tipo_sensor) ||"|"|| TRIM(dmapa) ||"|"|| TRIM(imapa) ||"|"|| TRIM(status_huella) ||"|"|| TRIM(ref_coppel) ||"|"|| 
			YEAR(fecha_ult_cambio)|| LPAD(MONTH(fecha_ult_cambio),2,0)|| LPAD(DAY(fecha_ult_cambio),2,0)||" "||(fecha_ult_cambio::DATETIME HOUR TO HOUR::CHAR(2))||":"|| (fecha_ult_cambio::DATETIME MINUTE TO MINUTE::CHAR(2))||":"||(fecha_ult_cambio::DATETIME SECOND TO SECOND::CHAR(2)) ||"|"|| 
			TRIM(tipo_cliente) ||"|"||TRIM(tipo_verificacion) ||"|"|| TRIM(status_consulta), status_consulta --0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			INTO cCadena, cEstatusConsulta
			FROM bdinteg:"informix".si_huella_linea
			WHERE status_consulta IN ('3','9') 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			AND DATE(fecha_consulta) = TODAY 
			AND fecha_insert::DATETIME HOUR TO MINUTE < CURRENT HOUR TO MINUTE - 1 UNITS MINUTE 
			ORDER BY status_consulta, fecha_consulta DESC 
			*/
			IF cCadena IS NOT NULL THEN
				RETURN cCodRet, TRIM(cCadena), cEstatusConsulta WITH RESUME;
			END IF;
		END FOREACH;

	END
END PROCEDURE
DOCUMENT
'Se obtienen los registros de las huellas que no se han enviado tuvieron algun problema o estan pendientes por enviar',
'Autor :Josue Zepeda',
'FECHA : 22/07/2013',
'BD: bdinteg',
'Folio: 1335',
'Autor: 94565457',
'Fecha: 30/10/2013',
'ModificaciÃ³n: Se modifica agregando; "LIMIT 100" a consulta, y se ordena por; "status_consulta,fecha_alta_huella" ',
'Sustento: El dia 26/09/2013 Se llega acuerdo entre Sonia Guzman Rodriguez y Manuel Osuna para realizar dicha modificacion',
'Solicita: Jaime Gonzalez',
'BD: BDINTEG',
'ASUNTO:		ModificaciÃ³n',
'ELABORÃ: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'DESCRIPCIÃN: 	Se modifica el limite de registros, de 100 a 10, el  status_consulta se cambia de (1,9) a (0,9) y se condiciona que la fecha del Ãºltimo cambia sea la de hoy',
'FECHA: 		10/11/2013',
'Autor: 92802036 Josue Zepeda',
'Fecha: 28/10/2013',
'ModificaciÃ³n: Se modifica filtrandose por fecha_consulta" ',
'Sustento: El dia 28/10/2013 Se llega acuerdo entre Sonia Guzman Rodriguez y Manuel Osuna para realizar dicha modificacion',
'Solicita: Jaime Gonzalez',
'BD: BDINTEG',
'Folio:1354',
'Autor:92802036 - Josue Zepeda',
'Fecha:27/11/2013',
'ModificaciÃ³n: Se Agrega status_consulta =  3 y se valida fecha_insert',
'Sustento: Se definio por Telefono Con Manuel Osuna y Sonia Guzman, y se acepto por correo',
'se encuentra plasmado el cambio en el cuerpo del correo del dÃ­a 27/11/2013',
'Solicita:Manuel Osuna',
'BD:BDINTEG',
'Autor:95564063 - Anahi Leyva',
'Fecha:07/01/2015',
'ModificaciÃ³n: Se quita filtro de registros con status_consulta= 0',
'Sustento: RQI 64 061_Mantenimiento_comparacion_de_huellas_en_linea_v1.0',
'Solicita: Jaime Gonzalez',
'BD:Bdinteg',
'---------------------------------------------------------------------------------------------------------------------------------',
'Folio.........: 1575 - INC_ReenvioHuella',
'Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'Fecha.........: 09/03/2015 - DSB20150309',
'ModificaciÃ³n..: Se modifica para que consulte los clientes con status = 0 y tengan 10 minutos o mas de haberse insertado',
'Sustento......: 64 076_MejCorrec_v1.0.',
'Solicita......: JosÃ© Angel LÃ³pez Adams',
'BD............: BDINTEG',
'----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_bit_solicitudessos (pNumCte CHAR(20), 
														   pTipoSol CHAR(20), 
														   pNombreInc CHAR (104), 
														   pFechaNacInc DATE, 
														   pNombreCorr CHAR(104),
														   pFechaNacCorr DATE, 
														   pSucursal CHAR(4), 
														   pNumEmp CHAR(8), 
														   pOrigen CHAR(1)) 
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cFechaNacInc DATE;


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cFechaNacInc = DATE(1);

--SET DEBUG FILE TO '/informix/cristo/sp_bit_solicitudessos.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (pNumCte IS NULL OR pNumCte  = '') OR (pTipoSol IS NULL OR pTipoSol = '')
		OR (pNombreInc  IS NULL OR pNombreInc  = '') 
		OR (pFechaNacInc IS NULL OR pFechaNacInc = '') 
		OR (pNombreCorr IS NULL OR pNombreCorr = '')  
		OR (pFechaNacCorr IS NULL OR pFechaNacCorr = '') 
		OR (pSucursal IS NULL OR pSucursal = '') 
		OR (pNumEmp IS NULL OR pNumEmp = '') 
		OR (pOrigen IS NULL OR pOrigen = '') THEN
		LET cCodRet = '00001';
	ELSE
		
		SELECT first 1 {+AVOID("informix".si_ctepf)}fecha_nac INTO cFechaNacInc FROM "informix".si_ctepf WHERE numcte=pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
			LET pFechaNacInc = cFechaNacInc;			
		END IF;
		
		INSERT INTO bdinteg:"informix".si_bitacora_solicitudessos
		(numcte, tipo_sol, nombre_inc, fecha_nac_inc, nombre_corr, fecha_nac_corr, sucursal, numemp, origen, fecha_insert)
		VALUES( pNumCte, pTipoSol  , pNombreInc, pFechaNacInc  , pNombreCorr, pFechaNacCorr, pSucursal, pNumEmp, pOrigen,CURRENT);
	END IF	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea procedimiento almacenado para llamar sp_bit_solicitudessos el cual guardara  una bitacora de las coincidencias para su posterior procesamiento. ',
'AUTOR : Leonardo Alfonso Plata Garcia',
'FECHA : 06/09/2013',
'MODIFICACION: Se obtiene fecha de nacimiento del cliente para evitar errores en la convercion de fechas antes del llamado de este procedimiento',
'FECHA: 25/03/2015',
'VERSION: ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualizactebiometria(pTipo CHAR(1), pNumCte CHAR(20))
    RETURNING CHAR(5) AS CodRet;

    --Definicion de Variables
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);

    --Inicializacion de Variables
    LET iSqlErr = 0;
    LET cCodRet = '000';

    --SET DEBUG FILE TO '/informix/IrisA/sp_actualizactebiometria.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			UPDATE "informix".si_cliente SET tpo_biometria = '2' WHERE numcte = pNumCte;
		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;