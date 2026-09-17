CREATE PROCEDURE "informix".tc_subearchivo (pEmpresa CHAR(16), pArchivo CHAR(40))

   RETURNING CHAR(5);

   -- *************************************************************************
   -- *                      DEFINICION DE VARIABLES                          *
   -- *************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vRuta		      VARCHAR(200);
   DEFINE vFechaHoy	      DATE;
   DEFINE vFechaArch          CHAR(8);
   DEFINE v_sql               VARCHAR(255);
   DEFINE vColumnas           SMALLINT;
   DEFINE vCuantos            INTEGER;
   DEFINE vTabla	      VARCHAR(30);
   DEFINE vArchProc	      VARCHAR(50);
   DEFINE vArchivoGraba       VARCHAR(30);
   DEFINE vTpMov              CHAR(1);
   DEFINE vTranCen            CHAR(4);
   DEFINE vTranSuc            CHAR(4);
   DEFINE vFolio              CHAR(16);
   DEFINE vCuenta             CHAR(20);
   DEFINE vSecuencia          VARCHAR(20);
   DEFINE vMonto              DECIMAL(14,2);
   DEFINE vMoneda             CHAR(2);
   DEFINE vReferencia         VARCHAR(50);
   DEFINE vTrabajo            VARCHAR(10);
   DEFINE vBandera	      CHAR(1);
   DEFINE vSucursal           CHAR(3);
   DEFINE vUsuario            CHAR(8);
   DEFINE vFecha	      DATE;
   DEFINE vTotMovs	      INTEGER;
   DEFINE vTotCgo 	      INTEGER;
   DEFINE vTotAbono 	      INTEGER;
   DEFINE vTotRev 	      INTEGER;
   DEFINE vFolioOri           VARCHAR(16);
   DEFINE vDocto	      INTEGER;
   DEFINE vCodAutoriza        VARCHAR(18);
   DEFINE vRfc_comer          VARCHAR(100);
   DEFINE vReferencia23        VARCHAR(100);




   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

--SET DEBUG FILE TO "sube.out";
--TRACE ON;

  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret       = "000";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ******************************
	-- Inicializa Tablas de Trabajo *
	-- ******************************
	DELETE FROM td_validacarga;
	DELETE FROM td_pasoconcilia;

	-- ******************
	-- Extra parametros *
	-- ******************
	SELECT TRIM(valor) INTO vRuta
	  FROM td_param
	 WHERE empresa = pEmpresa
	   AND cod_param = "1";

	IF vRuta IS NULL THEN
		LET cod_ret = "100";
		RETURN cod_ret;
	END IF

	SELECT fecha_hoy, TO_CHAR(fecha_hoy,"%d%m%Y")
	  INTO vFechaHoy, vFechaArch
	  FROM bdinteg:si_fechas
	 WHERE empresa = pEmpresa;

	SELECT columnas, tabla INTO vColumnas, vTabla
	  FROM td_archivos
	 WHERE empresa = pEmpresa
	   AND archivo = pArchivo;

	LET vArchivoGraba = pArchivo;
	LET pArchivo = TRIM(pArchivo) || TRIM(vFechaArch);


	-- **************************************************************
	-- Sube nombres de archivo para determinar el que se va a subir *
	-- **************************************************************

	LET v_sql = "ls " || TRIM(vRuta) || "/" || TRIM(pArchivo)
		    || ".* > sube";
	SYSTEM v_sql;


	LET v_sql = "echo " || "' load from sube delimiter '' " ||
		    "insert into td_validacarga' > cual.sql ";
        SYSTEM v_sql;

	LET v_sql = "dbaccess bditarjeta cual.sql";
	SYSTEM v_sql;

FOREACH SELECT SUBSTRING(archivo FROM LENGTH(vRuta) +2) INTO vArchProc
	  FROM td_validacarga
	 WHERE SUBSTRING(archivo FROM LENGTH(vRuta) +2) NOT IN
		(SELECT archivo FROM td_conciliaarchivos
		  WHERE fecha = vFechaHoy)

	IF vArchProc IS NULL THEN
		RETURN cod_ret;
	END IF

	-- *****************************************************
	-- Sube Archivo d tabla de paso para su clasificacion  *
	-- *****************************************************
        LET v_sql = "echo "||'"'|| "file '"|| TRIM(vRuta) ||
		    "/" || TRIM(vArchProc) || "' delimiter '|' "|| VColumnas||
                    "; insert into td_pasoconcilia" || ";"||'"'||' > carga';
      	SYSTEM v_sql;

	LET v_sql = "dbload -d bditarjeta -c carga -l er -n 100";
      	SYSTEM v_sql;

	-- **************************
	-- Valida subida de archivo *
	-- **************************

	SELECT COUNT(*) INTO vCuantos
	  FROM td_pasoconcilia;

	IF vCuantos IS NULL or vCuantos = 0 THEN
		RETURN cod_ret;
	END IF

	-- ********************************
	-- Inserta Encabezado del Archivo *
	-- ********************************
	SELECT COUNT(*) INTO vCuantos
	  FROM td_pasoconcilia
	 WHERE tp_renglon = "E";

	IF vCuantos IS NULL or vCuantos = 0 THEN
		RETURN cod_ret;
	END IF

	SELECT tp_movto, tran_central, tran_sucursal, folio_mov, cuenta,
	       tran_secuencia, monto, moneda
	  INTO vSucursal, vUsuario, vFecha, vTotMovs, vTotCgo, vTotAbono,
	       vTotRev, vBandera
	  FROM td_pasoconcilia
	 WHERE tp_renglon = "E";

	INSERT INTO td_conciliaarchivos
	 (empresa, archivo, fecha, recibidos_total, recibidos_cargo,
	  recibidos_abono, recibidos_reversa, fecha_recepcion,
	  bandera_procesa,
	  procesados,
	  cargo_concilia,
	  cargo_aplica,
	  cargo_error,
	  abono_concilia,
	  abono_aplica,
	  abono_error,
	  reversa_concilia,
	  reversa_aplica,
	  reversa_error)
	VALUES
	 (pEmpresa, vArchProc, vFechaHoy, vTotMovs, vTotCgo, vTotAbono,
	  vTotRev, vFecha, "0","0","0","0","0","0","0","0","0","0","0");

	-- *************************************************
	-- Inserta Detalle de acuerdo a tipo de movimiento *
	-- *************************************************
	FOREACH SELECT tp_movto, tran_central, tran_sucursal, folio_mov,
		       cuenta, tran_secuencia, monto, moneda, referencia,
		       folio_original, documento, cod_autorizacion,
		       campo_trabajo, bandera_proceso,rfc_comer,referencia23
		  INTO vTpMov, vTranCen, vTranSuc, vFolio, vCuenta,
		       vSecuencia, vMonto, vMoneda, vReferencia,
		       vFolioOri, vDocto, vCodAutoriza, vTrabajo,
		       vBandera,vRfc_comer,vReferencia23
		  FROM td_pasoconcilia
		 WHERE tp_renglon <> "E"

		IF vArchivoGraba = "CONPOS_PNC_" THEN
			INSERT INTO td_conpospnc
			 (empresa, archivo, fecha, consecutivo, tp_movto,
			  tran_central, tran_sucursal, folio_mov,
			  cuenta, tran_secuencia, monto, moneda,
			  referencia, folio_original, documento,
			  cod_autorizacion, campo_trabajo, bandera_proceso,
			  rfc_comer,referencia23)
			VALUES
			 (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
			  vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
			  vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONPOS_VNC_" THEN
                        INSERT INTO td_conposvnc
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONPOS_VND_" THEN
                        INSERT INTO td_conposvnd
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONPOS_VIC_" THEN
                        INSERT INTO td_conposvic
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONPOS_VID_" THEN
                        INSERT INTO td_conposvid
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONATMC_" THEN
                        INSERT INTO td_conatmc
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		ELIF vArchivoGraba = "CONATMD_" THEN
                        INSERT INTO td_conatmd
                         (empresa, archivo, fecha, consecutivo, tp_movto,
                          tran_central, tran_sucursal, folio_mov,
                          cuenta, tran_secuencia, monto, moneda,
                          referencia, folio_original, documento,
                          cod_autorizacion, campo_trabajo, bandera_proceso,
				  rfc_comer,referencia23)
                        VALUES
                         (pEmpresa, vArchProc, vFechaHoy, 0, vTpMov, vTranCen,
                          vTranSuc, vFolio, vCuenta, vSecuencia, vMonto,
                          vMoneda, vReferencia, vFolioOri, vDocto,
			  vCodAutoriza,vTrabajo, "0",vRfc_comer,vReferencia23);

		END IF

	END FOREACH


	TRUNCATE td_pasoconcilia;
END FOREACH

   RETURN cod_ret;


END PROCEDURE
DOCUMENT
'Esta funcion busca los archivos para la conciliacion de Tarjeta de Credito ',
'AUTOR : Antonio Ruiz Mtz ',
'FECHA : 11/01/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".tc_consulta_concilia 
		(
		pEmpresa CHAR(3), 
		pFechaProceso DATE,
		pTipoConcilia CHAR(3)
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter 
		--	Consecutivo  1 caracter 
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5),	VARCHAR(30),	DATE,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER;
	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	DEFINE v_archivo						VARCHAR(30);
	DEFINE v_fecha							DATE;
	DEFINE v_recibidos_total		INTEGER;
	DEFINE v_recibidos_cargo		INTEGER;
	DEFINE v_recibidos_abono		INTEGER;
	DEFINE v_recibidos_reversa	INTEGER;
	DEFINE v_procesados					INTEGER;
	DEFINE v_cargo_concilia			INTEGER;
	DEFINE v_cargo_aplica				INTEGER;
	DEFINE v_cargo_error				INTEGER;
	DEFINE v_abono_concilia			INTEGER;
	DEFINE v_abono_aplica				INTEGER;
	DEFINE v_abono_error				INTEGER;
	DEFINE v_reversa_concilia		INTEGER;
	DEFINE v_reversa_aplica			INTEGER;
	DEFINE v_reversa_error			INTEGER;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	--	DEFINE v_recibidos_total	INTEGER;
	--	DEFINE v_recibidos_cargo	INTEGER;
	--	DEFINE v_recibidos_abono	INTEGER;
	--	DEFINE v_recibidos_reversa	INTEGER;
	
	--	DEFINE v_concilia_total		INTEGER;
	DEFINE v_concilia_cargo		INTEGER;
	DEFINE v_concilia_abono		INTEGER;
	DEFINE v_concilia_reversa	INTEGER;
	
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	LET v_archivo							= "";
	LET v_fecha								= " ";
	LET v_recibidos_total			= 0;
	LET v_recibidos_cargo			= 0;
	LET v_recibidos_abono			= 0;
	LET v_recibidos_reversa		= 0;
	LET v_procesados					= 0;
	LET v_cargo_concilia			= 0;
	LET v_cargo_aplica				= 0;
	LET v_cargo_error					= 0;
	LET v_abono_concilia			= 0;
	LET v_abono_aplica				= 0;
	LET v_abono_error					= 0;
	LET v_reversa_concilia		= 0;
	LET v_reversa_aplica			= 0;
	LET v_reversa_error				= 0;
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	--	LET v_recibidos_total	= 0;
	--	LET v_recibidos_cargo	= 0;
	--	LET v_recibidos_abono	= 0;
	--	LET v_recibidos_reversa	= 0;
	
	--	LET v_concilia_total	= 0;
	LET v_concilia_cargo	= 0;
	LET v_concilia_abono	= 0;
	LET v_concilia_reversa	= 0;
	
BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN 	cod_ret,	"",			" ",
							0,				0,			0,
							0,				0,			0,
							0,				0,			0,
							0,				0,			0,
							0,				0,			0;
   END EXCEPTION;

 --SET DEBUG FILE TO "tc_aplica_concilia.out";
 --TRACE ON;

  SET LOCK MODE TO WAIT 10;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	FOREACH 
		SELECT 	archivo,					fecha,							recibidos_total,
						recibidos_cargo,	recibidos_abono,		recibidos_reversa,
						procesados,				cargo_concilia,			cargo_aplica,
						cargo_error,			abono_concilia,			abono_aplica,
						abono_error,			reversa_concilia,		reversa_aplica,
						reversa_error
		INTO 		v_archivo,					v_fecha,						v_recibidos_total,
						v_recibidos_cargo,	v_recibidos_abono,	v_recibidos_reversa,
						v_procesados,				v_cargo_concilia,		v_cargo_aplica,	
						v_cargo_error,			v_abono_concilia,		v_abono_aplica,
						v_abono_error,			v_reversa_concilia,	v_reversa_aplica,
						v_reversa_error
		FROM  td_conciliaarchivos
		WHERE	fecha_recepcion = pFechaProceso AND tipoarchivo = NVL(pTipoConcilia,tipoarchivo)
		
		LET v_concilia_cargo		= NVL(v_cargo_concilia,0) 	+ NVL(v_cargo_aplica,0) 	+ NVL(v_cargo_error,0);
		LET v_concilia_abono		= NVL(v_abono_concilia,0) 	+ NVL(v_abono_aplica,0) 	+ NVL(v_abono_error,0);
		LET v_concilia_reversa	= NVL(v_reversa_concilia,0) + NVL(v_reversa_aplica,0) + NVL(v_reversa_error,0);


		RETURN 	cod_ret,
						NVL(v_archivo,0),							NVL(v_fecha,0),							NVL(v_recibidos_cargo,0),
						NVL(v_cargo_concilia,0),			NVL(v_cargo_aplica,0),			NVL(v_cargo_error,0),
						NVL(v_recibidos_cargo,0) - 		NVL(v_concilia_cargo,0),
																																			NVL(v_recibidos_abono,0),	
						NVL(v_abono_concilia,0),			NVL(v_abono_aplica,0),			NVL(v_abono_error,0),
						NVL(v_recibidos_abono,0) - 		NVL(v_concilia_abono,0),
																																			NVL(v_recibidos_reversa,0),
						NVL(v_reversa_concilia,0),		NVL(v_reversa_aplica,0),		NVL(v_reversa_error,0),
						NVL(v_recibidos_reversa,0) - 	NVL(v_concilia_reversa,0)		WITH RESUME;

	END FOREACH;
	

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE
DOCUMENT
'ESTA FUNCION APLICA EL PROCESO DE CONCILIACION ',
'AUTOR : Cristian Campos Diaz ',
'FECHA : 29 Mayo 2008',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".conciliadebito(pempresa char(3),
                                pnum_tarjeta char(16),
                                psucursal char(4),
                                pusuario char(8),
                                ptipomov char(1),
                                ptransacc char(4),
                                pfoliosuc char(16),
                                pmonto_tot money(14,2),
                                pdivisa char(2),
                                preferencia char(40),
                                pfolioori char(16),
				pvRfcComer char (20),
				pvRef23 char(23))
       returning char(5),char(1);

define vcodret char(5);
define vsqlerr integer;
define vbandera char(1);
define vcuenta char(20);
define vtranret char(4);
define vnum_serial integer;
define vcancelad char(1);
define vfecapli date;
define vsdodisp money(14,2);
define vmtoapli money(14,2);
define vTranResp CHAR(4);
define vTipoTran char(2);
--set debug file to "conciliadebito.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vbandera;
      end if
   end exception;

   let vcodret = "000";
   let vbandera = "E";
   let vsqlerr = 0;
   let vcuenta = "";
   let vtranret = "";
   let vnum_serial = 0;
   let vcancelad = "";
   let vfecapli = "";
   let vsdodisp = 0;
   let vmtoapli = 0;
   let vTranResp = "";
   let vTipoTran = "";


   select cuenta into vcuenta
      from sc_tarjeta
      where empresa = pempresa and num_tarjeta = pnum_tarjeta;
   if vcuenta is null then
      let vcodret = "111";
      let vbandera = "E";
      return vcodret,vbandera;
   end if

   select num_serial,cancelad
      into vnum_serial,vcancelad
      from sc_movhis
      where empresa = pempresa and cuenta = vcuenta and
            folio_suc = pfoliosuc and transacc = ptransacc;

  IF vnum_serial IS NULL THEN  -- Temporal
     select num_serial,cancelad
      into vnum_serial,vcancelad
      from sc_movhis
      where empresa = pempresa and cuenta = vcuenta and
            folio_suc = pfoliosuc and
            monto_tot = pmonto_tot;
  END IF


        LET vTranResp = ptransacc;

      	SELECT NVL(tranlibprot,"0000"),tipo_tran
          INTO ptransacc,vTipoTran
          FROM bdinteg:si_transacc
         WHERE empresa = pempresa
           AND numero = ptransacc
           AND sistema = "01";

      if ptipomov = "C" then

           if vTipoTran  in ("00","01","02") then
	      let vbandera = "C";
	      return vcodret,vbandera;
	   end if;

        IF ptransacc = "0000" OR ptransacc = " " THEN
              LET ptransacc = vTranResp;
        END IF

         call cargo_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                        pfoliosuc,vcuenta,0,pmonto_tot,pdivisa,preferencia,
                        pnum_tarjeta,"")
              returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
         if vcodret <> "000" and vcodret <> "400" then
            let vbandera = "E";
            return vcodret,vbandera;
	 elif vcodret = "400" then
            let vbandera = "0";
            return vcodret,vbandera;
	 else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
      if ptipomov = "A" then
      	 LET ptransacc = "0813";
         call abono_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                        pfoliosuc,vcuenta,0,pmonto_tot,pmonto_tot,0,0,0,
                        pdivisa,preferencia,pnum_tarjeta,"")
              returning vcodret;
         if vcodret <> "000" then
            let vbandera = "E";
            return vcodret,vbandera;
         else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
      if ptipomov = "R" then
         call reversiontd(pempresa,psucursal,pusuario,pfolioori,"A",
                          vcuenta,ptransacc)
              returning vcodret;
         if vcodret <> "000" then
            let vbandera = "E";
            return vcodret,vbandera;
         else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
  return vcodret,vbandera;
end
end procedure
;