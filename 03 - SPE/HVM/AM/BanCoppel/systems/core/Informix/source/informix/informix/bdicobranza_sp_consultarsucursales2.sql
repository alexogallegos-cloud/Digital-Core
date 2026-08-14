CREATE PROCEDURE "informix".sp_consultarsucursales2(pEmpresa CHAR(3) ,pRegion SMALLINT ,pSucursal CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING
        CHAR(6) AS COD_RET,
        CHAR(4) AS SUCURSAL,
        CHAR(40) AS NOMSUCURSAL;

--Muestra las sucursales dependiendo del numero de sucursal, si no se envia el numero de sucursal se realiza por numero de region.

        --DECLARACIONES
    DEFINE iSqlErr         INTEGER;
    DEFINE cCodRet         CHAR(6);
    DEFINE cMensajeRet     CHAR(40);
    DEFINE nrows           INTEGER;
    DEFINE cNomSucursal    CHAR(40);
    DEFINE cNumSuc         CHAR(4);
	DEFINE iNoRegistros INTEGER;

        ---INICIALIZACIONES
    LET iSqlErr            = 0;
    LET cCodRet            = "000000";
    LET cMensajeRet        = "";
    LET nrows              = 0;
    LET cNomSucursal       = "";
    LET cNumSuc            = "0000";
	LET iNoRegistros = 0;

BEGIN

    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cMensajeRet,cNomSucursal;
       END IF;
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_consultarsucursales2.out";
	--TRACE ON;

	IF pSucursal <> "" THEN

			SELECT sucursal, nombre
			INTO cNumSuc, cNomSucursal
			FROM bdinteg:si_sucursales WHERE sucursal = pSucursal;

			IF cNumSuc = "0000" OR cNumSuc IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
					Let cCodRet = '000001';
					Let cNumSuc = pSucursal;
					Let cNomSucursal = 'No se Encuentra la Sucursal Requerida';
			END IF;

			RETURN cCodRet,cNumSuc,cNomSucursal;

	ELSE

	FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion suc.sucursal,suc.nombre
			INTO cNumSuc, cNomSucursal
			FROM bdinteg:"informix".si_ciudades ciu,
					 bdinteg:"informix".si_catciudades cat,
					 bdinteg:"informix".si_regiones reg,
					 bdinteg:"informix".si_sucursales suc
			WHERE suc.estado = ciu.estado
			  AND suc.ciudad = ciu.ciudad
			  AND cat.numerociudad = ciu.ciudad_coppel
			  AND cat.numero_region = reg.numero_region
			  AND reg.numero_region = DECODE(pRegion,0,reg.numero_region,pRegion)
			  AND suc.tpo_sucursal = 'S'
			order by suc.sucursal
			
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet,cNumSuc,cNomSucursal WITH RESUME;

	END FOREACH

	IF cNumSuc = '0000' THEN
		Let cCodRet = '000002';
		Let cNomSucursal = 'No Existen Sucursales Para la Region';
		RETURN cCodRet,cNumSuc,cNomSucursal WITH RESUME;  ---PRUEBA
	END IF
	
	IF iNoRegistros = 0 AND pRegistros = 0 THEN
		LET cCodRet = '000002';
		RETURN cCodRet,cNumSuc,cNomSucursal;
	ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
		LET cCodRet = '001001';
		RETURN cCodRet,cNumSuc,cNomSucursal;
	END IF;		

END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una Consulta con la Informacion de las Sucursales de una Determinada Division',
'AUTOR: ValentÃ­n LÃ³pez',
'FECHA: Agosto 2010',
'VERSION: 201008.0924',
'AUTOR: Guadalupe HernÃ¡ndez PÃ©rez',
'FECHA: 27/05/2016',
'DescripciÃ³n: Se modifica para agregar parametros de paginado',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_medidores_compac_crd()
    RETURNING char(6), char(80);
	   
--declaracion de variables
------------------------------------------------------------
DEFINE sql_err                             	INTEGER;
DEFINE isam_err                            	INTEGER;
DEFINE error_info                          	CHAR(80);
DEFINE cMensaje                            	CHAR(80);
DEFINE cCod_ret                            	CHAR(6);
DEFINE vproceso							   	CHAR(5);

DEFINE v_sucursal                          	CHAR(4);
DEFINE v_numero_convenios                  	INTEGER;
DEFINE v_tipo_compac                       	CHAR(1);
DEFINE v_importe                           	DECIMAL(16,2);
DEFINE v_pagado                            	DECIMAL(16,2);
DEFINE v_numero_producto		           	CHAR(4);

--DEFINE vdia2 								DATE;
DEFINE vfecha_ini							DATE;
DEFINE vfecha_fin							DATE;
DEFINE dtFechaCorte							DATE;
DEFINE vfecha_hoy                           DATE;
------------------------------------------------------------

LET sql_err       		= 0;
LET isam_err      		= 0;
LET error_info    		= '';
LET cMensaje     		= 'PROCESO EXITOSO';
LET cCod_ret      		= '000000';
LET vProceso			= '0039';

LET v_sucursal 			= "";
LET v_numero_convenios	= 0;
LET v_tipo_compac		= "";
LET v_importe			= 0;
LET v_pagado			= 0;
LET v_numero_producto	= "";

--LET vdia2				= DATE(1);
LET vfecha_ini			= DATE(1);
LET vfecha_fin			= DATE(1);
LET vfecha_hoy			= TODAY;
LET dtFechaCorte		= DATE(1);
------------------------------------------------------------

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '02');         
		RETURN cCod_ret, cMensaje;
	END EXCEPTION;

	--SET DEBUG FILE TO '/aplicacion/Carlos/sp_medidores_compac.out';
	--TRACE ON;

	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '01');

	LET vfecha_ini = (vfecha_hoy - 2 UNITS MONTH) + 1 UNITS DAY;
	LET vfecha_fin = vfecha_hoy - 1 UNITS MONTH;
	LET dtFechaCorte = vfecha_fin;

--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
/*
	SELECT max(fecha_insert) INTO vdia2 FROM "informix".cb_medidor_compac;

	IF(vdia2 = vfecha_hoy) THEN
		DELETE "informix".cb_medidor_compac WHERE fecha_insert >= '01-01-1900';
	ELSE
		DELETE "informix".cb_medidor_compac WHERE fecha_insert < vdia2;
	END IF;*/

--------------------------------------------------------------------------
--se obtiene la informacion
	SET ISOLATION TO dirty READ;
------------------------------- Se obtienen DATOS del CLIENTE y SALDOS----
    FOREACH
        SELECT sucursal INTO v_sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = "001" AND tpo_sucursal = "S"

		IF EXISTS (SELECT empresa, canal, fecha_corte, sucursal, tipo_convenio FROM "informix".cb_medidor_compac WHERE empresa = '001' AND canal = 2 AND fecha_corte = dtFechaCorte AND sucursal = v_sucursal AND num_producto <> "6001") THEN
			DELETE FROM "informix".cb_medidor_compac
			WHERE empresa = "001" AND canal = 2 AND fecha_corte = dtFechaCorte
			AND  sucursal = v_sucursal
			AND num_producto <> "6001";
		END IF;

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, vfecha_hoy, "6300");

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, vfecha_hoy, "6300");
		
		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, vfecha_hoy, "6400");

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, vfecha_hoy, "6400");
		
		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, vfecha_hoy, "6011");

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, vfecha_hoy, "6011");
		
		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, vfecha_hoy, "7600");

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, vfecha_hoy, "7600");
		
		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, vfecha_hoy, "7700");

		INSERT INTO "informix".cb_medidor_compac (empresa, canal, fecha_corte, sucursal, tipo_convenio, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, vfecha_hoy, "7700");

		LET v_sucursal = "";
    END FOREACH;

	FOREACH
		SELECT h.sucursal, h.tipo_compac, COUNT(h.numcuenta) NumCompromis, SUM(h.importe) ImporteCom,
			CASE WHEN (SUM(h.importe) >= SUM(h.imp_pagado)) THEN SUM(h.imp_pagado)
			ELSE (SUM(h.importe)) END Imp_pagado, crd.num_producto
		INTO v_sucursal, v_tipo_compac, v_numero_convenios, v_importe, v_pagado, v_numero_producto
		FROM "informix".cb_compac_his h
			INNER JOIN bdicred:"informix".sd_maecredcrd crd ON (crd.empresa = h.empresa AND crd.num_credito = h.numcuenta)
			INNER JOIN bdicred:"informix".sd_maecredanexocrd anx ON (anx.num_credito = h.numcuenta AND anx.dia_corte = DAY(dtFechaCorte))
		WHERE h.fecha_insert BETWEEN vfecha_ini AND vfecha_fin
		AND h.origen = 2
		AND h.flag_pago = 1
		GROUP BY h.sucursal, h.tipo_compac, num_producto
		ORDER BY h.sucursal, h.tipo_compac

		UPDATE "informix".cb_medidor_compac 
		SET numero_convenios = v_numero_convenios, importe_conveniado = v_importe,
			importe_pagado = v_pagado, fecha_insert = vfecha_hoy, num_producto = v_numero_producto
		WHERE empresa = '001'
		AND fecha_corte = dtFechaCorte
		AND sucursal = v_sucursal
		AND tipo_convenio = v_tipo_compac
		AND num_producto = v_numero_producto;

		LET v_sucursal, v_tipo_compac, v_numero_convenios, v_importe, v_pagado, v_numero_producto = "", "", 0, 0, 0, "";
	END FOREACH;

	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '03');

	RETURN cCod_ret, cMensaje;
END;

END PROCEDURE
DOCUMENT 'AUTOR: Carlos Valenzuela',
'FECHA: 21/10/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAT - CALIFICACION DE CONVENIOS CAT COBRANZA',
'DESCRIPCION: Genera informacion para el llenado de la tabla cb_medidor_compac para los productos a plazos', 
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_medidores_compac(fecha_ini DATE, fecha_fin DATE)
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err                             INTEGER;
DEFINE isam_err                            INTEGER;
DEFINE error_info                          CHAR(80);
DEFINE cMensaje                            CHAR(80);
DEFINE cCod_ret                            CHAR(6);
DEFINE vproceso							   CHAR(5);
------------------------------------------------------------
DEFINE pUsuario                            CHAR(8);
DEFINE vlNumInsert                         INTEGER;
------------------------------------------------------------
DEFINE v_sucursal                          CHAR(4);
DEFINE v_sucursal_ant                      CHAR(4);
DEFINE v_numero_convenios                  INTEGER;
DEFINE v_importe_conveniado_compromiso 	   DECIMAL(16,2);
DEFINE v_importe_pagado                    DECIMAL(16,2);
DEFINE v_numero_acuerdos                   INTEGER;
DEFINE v_importe_acuerdos                  DECIMAL(16,2);
DEFINE v_importe_pagado_acuerdo            DECIMAL(16,2);
DEFINE vdia                                DATE;
DEFINE vdia2                               DATE;
DEFINE vhora                               CHAR(8);
DEFINE v_tipo_compac                       CHAR(1);
DEFINE v_importe                           DECIMAL(16,2);
DEFINE v_pagado                            DECIMAL(16,2);
DEFINE v_numero_producto		           CHAR(4);
------------------------------------------------------------
DEFINE AnoFin                              CHAR(15);
DEFINE MesFin                              CHAR(15);
DEFINE v_periodo                           CHAR(15);
DEFINE dtFechaCorte                        DATE;

--SET DEBUG FILE TO '/aplicacion/Carlos/sp_medidores_compac.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET vProceso		= '2001';
	  LET vdia 			= today;
	  LET dtFechaCorte	= DATE(1);
	  LET v_numero_producto	= "";
------------------------------------------------------------
      LET pUsuario      = user;
------------------------------------------------------------
      LET AnoFin = year(fecha_fin);
      LET MesFin = month(fecha_fin);
      LET v_periodo =  trim(MesFin)||'-'||'20'||'-'||trim(AnoFin) ;
      LET dtFechaCorte = v_periodo::DATE;

BEGIN        

       ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '02');         
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

            CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '01');

            --RETURN cCod_ret, cMensaje;

--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

    SELECT max(fecha_insert) INTO vdia2 FROM bdicobranza:cb_medidor_compac WHERE num_producto = "6001";

	IF vdia2 IS NULL THEN LET vdia2 = DATE(1); END IF;

    IF(vdia2 = vdia ) THEN

        DELETE bdicobranza:cb_medidor_compac WHERE fecha_insert >= '01-01-1900';

    ELSE

        DELETE bdicobranza:cb_medidor_compac WHERE fecha_insert < vdia2;

    END IF;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
        --se obtiene la informacion
		SET ISOLATION TO dirty READ;
------------------------------- Se obtienen DATOS del CLIENTE y SALDOS----
   ---MACF
    FOREACH
        SELECT  SUCURSAL INTO v_sucursal  FROM BDINTEG:si_sucursales where empresa = '001' and tpo_sucursal = 'S'

		IF EXISTS (SELECT empresa, canal, fecha_corte, sucursal, tipo_convenio 
         		  FROM bdicobranza:cb_medidor_compac WHERE empresa = '001' AND canal = 2 AND fecha_corte = dtFechaCorte AND sucursal = v_sucursal AND num_producto = "6001") THEN
			        DELETE FROM bdicobranza:cb_medidor_compac WHERE empresa = '001' AND canal = 2 AND fecha_corte = dtFechaCorte AND  sucursal = v_sucursal AND num_producto = "6001";
		END IF;
		INSERT INTO bdicobranza:cb_medidor_compac (EMPRESA, CANAL, FECHA_CORTE, SUCURSAL, TIPO_CONVENIO,fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 1, today, "6001");

		INSERT INTO bdicobranza:cb_medidor_compac (EMPRESA, CANAL, FECHA_CORTE, SUCURSAL, TIPO_CONVENIO, fecha_insert, num_producto)
		VALUES ('001', 2, dtFechaCorte, v_sucursal, 2, today, "6001");
		
		LET v_sucursal = "";
    END FOREACH;
    ---MACF

    FOREACH

        SELECT h.sucursal, h.tipo_compac, count(h.numcuenta) NumCompromis, sum(h.importe) ImporteCom,
            case when (sum(h.importe)>=sum(imp_pagado) )then sum(h.imp_pagado)
            else (sum(h.importe)) end Imp_pagado, mae.num_producto
        INTO v_sucursal, v_tipo_compac, v_numero_convenios, v_importe, v_pagado, v_numero_producto  
        FROM bdicobranza:cb_compac_his h
			INNER JOIN bdicred:"informix".sd_maecred mae ON (mae.empresa = h.empresa AND mae.num_credito = h.numcuenta)
        WHERE fecha_insert between fecha_ini and  fecha_fin
        AND h.origen = 2
        AND h.flag_pago =1
        --AND importe >= imp_pagado  --MACF
        GROUP BY h.sucursal, h.tipo_compac, mae.num_producto
        ORDER BY h.sucursal, h.tipo_compac

        UPDATE bdicobranza:cb_medidor_compac
           SET numero_convenios = v_numero_convenios, importe_conveniado = v_importe,
               importe_pagado = v_pagado, fecha_insert = today
        WHERE empresa = '001'
          AND fecha_corte = dtFechaCorte
          AND sucursal = v_sucursal
          AND tipo_convenio = v_tipo_compac
		  AND num_producto = v_numero_producto;

		LET v_sucursal, v_tipo_compac, v_numero_convenios, v_importe, v_pagado, v_numero_producto = "", "", 0, 0, 0, "";
    END FOREACH;

	     CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_ret, cMensaje, '03');

		RETURN cCod_ret, cMensaje;
        END;

END PROCEDURE
DOCUMENT 
'Se modifica procedimiento para que contemple el cambio de nombre del campo periodo de la tabla cb_medidor_compac por fecha_corte',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110405.0850',
'Modificar para que genere la información de todas las sucursales inclusive las que contengan información en cero.',
'Modificó: Marco A. Campos',
'Fecha: 2011/08/02',
'Se modifica para que solo tome el producto TDC',
'Modificó: Carlos Valenzuela ',
'Fecha: 27/10/28';

CREATE PROCEDURE "informix".sp_carga_tabla_movimientos_peticion_pba(pfecha DATE)

RETURNING CHAR(6), CHAR(80);
/*
___________________________________________________________________________________________________________________________________________________________________________
	Creado: Carlos Valenzuela
	FECHA: 08-03-2016.
	DESCRIPCION: Carga de archivos de movimientos con fecha a peticion.
	BASE DE DATOS: bdicobranza.
*/
--DECLARACION DE VARIABLES
DEFINE sql_err					INTEGER;
DEFINE isam_err					INTEGER;
DEFINE error_info				CHAR(80);
DEFINE cCod_ret					CHAR(6);
DEFINE vempresa     			CHAR(3);
DEFINE cproceso     			CHAR(4);
DEFINE vvcCod_ret				CHAR(6);
DEFINE cMensaje					CHAR(80);
DEFINE cCadena					CHAR(500);
DEFINE vRuta					CHAR(100);
DEFINE cSql         			CHAR(2204);	
DEFINE vNomArch     			CHAR(2204);	
DEFINE X 						CHAR(100);
DEFINE pNomArch 				CHAR(100);
DEFINE v_cvemovimiento       	CHAR(1);
DEFINE v_tipomovimiento      	SMALLINT;
DEFINE v_horainicio          	DATETIME YEAR to SECOND;
DEFINE v_horafin             	DATETIME YEAR to SECOND;
DEFINE v_cliente             	CHAR(20);
DEFINE v_tipologica          	SMALLINT;
DEFINE v_tipocobranza        	CHAR(1);
DEFINE v_tipoclientecampana  	SMALLINT;
DEFINE v_cuenta              	CHAR(2);
DEFINE v_tienda              	CHAR(20);
DEFINE v_importe             	DECIMAL(18,2);
DEFINE v_tipoconvenio        	SMALLINT;
DEFINE v_plazo               	CHAR(2);
DEFINE v_cobranzacat         	SMALLINT;
DEFINE v_sucursal            	CHAR(4);
DEFINE v_empresa             	CHAR(3);
DEFINE v_usteddebe           	DECIMAL(18,2);
DEFINE v_usteddebia          	DECIMAL(18,2);
DEFINE v_vencido             	DECIMAL(18,2);
DEFINE v_tipotelefono        	SMALLINT;
DEFINE v_numext              	CHAR(5);
DEFINE v_telefonooriginal    	CHAR(13);
DEFINE v_telefonoreconstruido	CHAR(13);
DEFINE v_finllamada          	SMALLINT;
DEFINE v_contacto            	CHAR(2);
DEFINE v_tipored             	CHAR(1);
DEFINE v_aclaracion          	SMALLINT;
DEFINE v_fechahorallamada    	DATETIME YEAR to SECOND;
DEFINE v_horainiciollamada   	DATETIME HOUR to SECOND;
DEFINE v_horafinllamada      	DATETIME HOUR to SECOND;
DEFINE v_pkwhere             	CHAR(50);
DEFINE v_duracionefectiva    	SMALLINT;
DEFINE v_cat                 	VARCHAR(40);
DEFINE v_ip                  	VARCHAR(40);
DEFINE v_numempleado         	CHAR(8);
DEFINE v_observaciones       	CHAR(80);
DEFINE v_fechacartera        	DATETIME YEAR to SECOND;
DEFINE v_carrier             	SMALLINT;
DEFINE v_numerociudad        	SMALLINT;
DEFINE v_numeroestado        	CHAR(2);
DEFINE v_keyx                	INTEGER;
DEFINE v_bandera				CHAR(1);
DEFINE cMensaje2		    	CHAR(300);
DEFINE iCuentasProcesadas   	INTEGER;
DEFINE iCuentasDuplicadas	  	INTEGER;
DEFINE iCuentasInsertadas   	INTEGER;
	
--DEFINICIAON DE VARIABLES
LET cCod_ret  				= "000000";
LET sql_err   				= 0;
LET cMensaje  				= "PROCESO EXITOSO";
LET cCadena   				= "";
LET vRuta     				= "";
LET cSql      				= "";
LET vempresa   				= '001';
LET cproceso    			= '0095';
LET vNomArch    			= "";
LET X 						= '';
LET pNomArch 				= '';
LET v_cvemovimiento       	= "";
LET v_tipomovimiento      	= 0;
LET v_horainicio          	= DATE(1);
LET v_horafin             	= DATE(1);
LET v_cliente             	= "";
LET v_tipologica          	= 0;
LET v_tipocobranza        	= "";
LET v_tipoclientecampana  	= 0;
LET v_cuenta              	= "";
LET v_tienda              	= "";
LET v_importe             	= 0;
LET v_tipoconvenio        	= 0;
LET v_plazo               	= "";
LET v_cobranzacat         	= 0;
LET v_sucursal            	= "";
LET v_empresa             	= "";
LET v_usteddebe           	= 0;
LET v_usteddebia          	= 0;
LET v_vencido             	= 0;
LET v_tipotelefono        	= 0;
LET v_numext              	= "";
LET v_telefonooriginal    	= "";
LET v_telefonoreconstruido	= "";
LET v_finllamada          	= 0;
LET v_contacto            	= "";
LET v_tipored             	= "";
LET v_aclaracion          	= 0;
LET v_fechahorallamada    	= DATE(1);
LET v_horainiciollamada   	= DATE(1);
LET v_horafinllamada      	= DATE(1);
LET v_pkwhere             	= "";
LET v_duracionefectiva    	= 0;
LET v_cat                 	= "";
LET v_ip                  	= "";
LET v_numempleado         	= "";
LET v_observaciones       	= "";
LET v_fechacartera        	= DATE(1);
LET v_carrier             	= 0;
LET v_numerociudad        	= 0;
LET v_numeroestado        	= "";
LET v_keyx                	= 0;
LET v_bandera				= "";
LET cMensaje2		    	= "";
LET iCuentasProcesadas   	= 0;
LET iCuentasDuplicadas	  	= 0;
LET iCuentasInsertadas   	= 0;

--SET DEBUG FILE TO "/aplicacion/Carlos/catmovimientosctbcpl_peticion.out ";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;	    
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL INICIO DE LA EJECUCION DE SP
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING vvcCod_ret;

	--SELECCIONAMOS LA RUTA 
	select valor_alfabetico into vRuta 
	from bdicobranza:cb_param_campania
	where empresa = '001'
	and tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 9;	

	-----PRUEBAS-----
	--LET vRuta = '/respaldos/Carlos/predictivo/';
	-----------------				

	--ASIGNAMOS NOMBRE AL ARCHIVO
	LET pNomArch = 'movimientosctbcpl_'|| TO_CHAR(pfecha,'%d%m%Y')||'.txt.gz';

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--DESCOMPRIMIMOS EL ARCHIVO
	LET cSql = "";
	LET cSql = "gunzip "  || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
	LET X = LENGTH(pNomArch);
	LET vNomArch = SUBSTR(pNomArch,0,X-3);

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(vNomArch); 
	SYSTEM cSql;

	--BORRAMOS LA INFORMACION QUE CONTIENE LA TABLA CON LA QUE VAMOS A TRABAJAR
	TRUNCATE TABLE "informix".cb_cat_movimientos_peticion DROP STORAGE;

	--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
	LET cCadena = 'echo " LOAD FROM ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(VNomArch,1,
	LENGTH(VNomArch))  || ' INSERT INTO bdicobranza:cb_cat_movimientos_peticion " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--EJECUTAMOS EL ARCHIVO QUE CONTIENE LA CADENA
	LET cCadena = "";
	LET cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--BORRA EL ARCHIVO 
	LET cCadena = "";
	LET cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--SE COMPRIME DE NUEVO EL ARCHIVO
	LET cSql = "";
	LET cSql = "gzip " || TRIM(vRuta) || TRIM(vNomArch); 
	SYSTEM cSql;

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--SE ACTUALIZA CAMPO CLIENTE CON CEROS A LA IZQUIERDA HASTA QUE LA CADENA CLIENTE CUMPLA CON LOS 9 DIGITOS
	UPDATE "informix".cb_cat_movimientos_peticion
	SET cliente = LPAD(TRIM(cliente),9,'0')
	WHERE DATE(horainicio) = pfecha;

-------------------------------------------------------------------------------------------------------------------------------------
	UPDATE statistics medium FOR TABLE "informix".cb_cat_movimientos_peticion;
	
	FOREACH WITH HOLD
		SELECT cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
			tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
			importe, tipoconvenio, plazo, cobranzacat, sucursal,
			empresa, usteddebe, usteddebia, vencido, tipotelefono,
			numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
			tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
			pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
			fechacartera, carrier, numerociudad, numeroestado, keyx
		INTO v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
			v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
			v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
			v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
			v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
			v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
			v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
			v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx
		FROM "informix".cb_cat_movimientos_peticion

--------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------
		LET iCuentasProcesadas = iCuentasProcesadas + 1;
		
--------BUSCAMOS SI EXISTE EL REGISTRO--------
		SELECT 1 INTO v_bandera
		FROM "informix".cb_cat_movimientos
		WHERE cvemovimiento = v_cvemovimiento
		AND tipomovimiento = v_tipomovimiento
		AND horainicio = v_horainicio
		AND cliente = v_cliente
		AND tipologica = v_tipologica
		AND tipocobranza = v_tipocobranza
		AND tienda = v_tienda
		AND keyx = v_keyx;

--------SI EL REGISTRO NO EXISTE ES NULO Y POR LO TANTO SE IGUALA A VACIO PARA QUE NO MARQUE ERROR EN LA COMPARACION--------
		IF v_bandera IS NULL THEN LET v_bandera = ""; END IF;

--------SI EXISTE EL REGISTRO SE BORRA Y DESPUES DE INSERTA EN LA TABLA cb_cat_movimientos--------
		IF v_bandera = "1" THEN
			BEGIN WORK;
----------------BORRAMOS EL REGISTRO DE LA TABLA cb_cat_movimientos PARA EVITAR DUPLICADOS----------------	
				DELETE 
				FROM "informix".cb_cat_movimientos 
				WHERE cvemovimiento = v_cvemovimiento
				AND tipomovimiento = v_tipomovimiento
				AND horainicio = v_horainicio
				AND cliente = v_cliente
				AND tipologica = v_tipologica
				AND tipocobranza = v_tipocobranza
				AND tienda = v_tienda
				AND keyx = v_keyx;

----------------VARIABLE PARA EL CONTEO DE CUENTAS DUPLICADAS----------------
				LET iCuentasDuplicadas = iCuentasDuplicadas +1;

----------------INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos----------------		

				INSERT INTO "informix".cb_cat_movimientos
					(cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
					tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
					importe, tipoconvenio, plazo, cobranzacat, sucursal,
					empresa, usteddebe, usteddebia, vencido, tipotelefono,
					numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
					tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
					pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
					fechacartera, carrier, numerociudad, numeroestado, keyx)
				VALUES (v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
					v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
					v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
					v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
					v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
					v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
					v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
					v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx);

----------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS----------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
			COMMIT WORK;

			LET v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente = "", 0, DATE(1), DATE(1), "";
			LET v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda = 0, "", 0, "", "";
			LET v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal = 0, 0, "", 0, "";
			LET v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono = "", 0, 0, 0, 0;
			LET v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto = "", "", "", 0, "";
			LET v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada = "", 0, DATE(1), DATE(1), DATE(1);
			LET v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones = "", 0, "", "", "","";
			LET v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx, v_bandera = DATE(1), 0, 0, "", 0, "";
		ELSE
			BEGIN WORK;
----------------INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos----------------				
				INSERT INTO "informix".cb_cat_movimientos
					(cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
					tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
					importe, tipoconvenio, plazo, cobranzacat, sucursal,
					empresa, usteddebe, usteddebia, vencido, tipotelefono,
					numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
					tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
					pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
					fechacartera, carrier, numerociudad, numeroestado, keyx)
				VALUES (v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
					v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
					v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
					v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
					v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
					v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
					v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
					v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx);

----------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS----------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
			COMMIT WORK;

			LET v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente = "", 0, DATE(1), DATE(1), "";
			LET v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda = 0, "", 0, "", "";
			LET v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal = 0, 0, "", 0, "";
			LET v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono = "", 0, 0, 0, 0;
			LET v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto = "", "", "", 0, "";
			LET v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada = "", 0, DATE(1), DATE(1), DATE(1);
			LET v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones = "", 0, "", "", "","";
			LET v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx, v_bandera = DATE(1), 0, 0, "", 0, "";
		END IF;
	END FOREACH;
	
--------GENERA CIFRAS DE CONTROL--------
	LET cMensaje2 = 'TOTAL cuentas PROCESADAS: ' || iCuentasProcesadas;
	LET cMensaje2 = TRIM(cMensaje2) ||'  TOTAL cuentas DUPLICADAS: ' || iCuentasDuplicadas;
	LET cMensaje2 = TRIM(cMensaje2) ||'  TOTAL cuentas INSERTADAS: ' || iCuentasInsertadas;
	CALL "informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;
		
--------INICIALIZACION DE VARIABLES DE CONTEO--------
	LET cMensaje2 = '';
	LET iCuentasProcesadas = 0;
	LET iCuentasDuplicadas = 0;
	LET iCuentasInsertadas = 0;
-------------------------------------------------------------------------------------------------------------------------------------

	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03') RETURNING vvcCod_ret;

	--SE MANDA LLAMAR SP CIERRE LLAMADAS PARA REALIZAR EL CONTEO DE LLAMADAS POR CLIENTE
	CALL bdicobranza:"informix".sp_cat_cierrellamadas() RETURNING cCod_ret, cMensaje;

	--SE MANDA LLAMAR SP PARA ACTUALIZAR EN LA TABLA SI_TELEFONOS_ACTUAL EL CAMPO "CONTACTO"
	CALL bdicobranza:"informix".sp_actualiza_contacto_exitoso() RETURNING cCod_ret, cMensaje;
		
	UPDATE statistics medium FOR TABLE "informix".cb_cat_movimientos;
		
	RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;