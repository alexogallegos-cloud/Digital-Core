CREATE PROCEDURE "informix".sp_evc_consexclusionlotetotales(pIdUsuario char(8), pIdFuncion CHAR(10), pLote INT)

RETURNING 

	CHAR(5) AS codret,

	DATE AS fecha_carga,

	INT AS total_registros,

	INT AS registros_aceptados,

	INT AS registros_rechazados,

	CHAR(150) AS nombre_archivo;



DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE dFechaCarga DATETIME YEAR TO FRACTION(3);

DEFINE iTotalRegistros INT;

DEFINE iTotalAceptados INT;

DEFINE iTotalRechazados INT;

DEFINE cArchivoCarga char(150);

DEFINE iExiste int;

DEFINE mTotalMonto MONEY(14,2);

DEFINE cNombreEjecutivo char(45);

DEFINE cSistemaCuenta char(2);

DEFINE cStatusLote CHAR(1);

DEFINE cTotalRecal int;

	

LET cCodRet = '00000';

LET iSqlErr = 0;

LET dFechaCarga = NULL;

LET iTotalRegistros = 0;

LET iTotalAceptados = 0;

LET iTotalRechazados = 0;

LET cArchivoCarga = '';

LET iExiste = 0;

LET mTotalMonto= NULL;

LET cNombreEjecutivo = '';

LET cSistemaCuenta = '';

LET cStatusLote = '';

LET cTotalRecal= 0;



BEGIN

	ON EXCEPTION SET iSqlErr

		LET cCodRet = iSqlErr;

		RETURN cCodRet, dFechaCarga, iTotalRegistros, iTotalAceptados, iTotalRechazados, cArchivoCarga;

	END EXCEPTION;



	----SET DEBUG FILE TO '/tmp/mfinis/sp_evc_consexclusionlotetotales.out';

	----TRACE ON;

 

	IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' THEN

		LET cCodRet = '00003';

		RETURN cCodRet, dFechaCarga, iTotalRegistros, iTotalAceptados, iTotalRechazados, cArchivoCarga;

	END IF;

	

	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;

	IF cCodRet <> '00000' THEN

		RETURN cCodRet, dFechaCarga, iTotalRegistros, iTotalAceptados, iTotalRechazados, cArchivoCarga;

	END IF;

	

	-- Buscamos en la tabla de lotes

		SET ISOLATION TO DIRTY READ;

		SELECT COUNT(*)

		INTO iExiste

		FROM bdicnweb:"informix".sw_tr_totales_masivo

		WHERE id_lote = pLote AND id_funcion = pIdFuncion;

		

	-- Buscamos el lote en la tabla de las cargas masivas

		IF iExiste = 0 THEN

			SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(lote)

			INTO iExiste

			FROM bdicnweb:"informix".sw_evc_excluidos

			WHERE lote = pLote;

			

			IF iExiste = 0 THEN

				let cCodRet = '00002';

				RETURN cCodRet, dFechaCarga, iTotalRegistros,  iTotalAceptados, iTotalRechazados, cArchivoCarga;

			END IF;

			

			LET iExiste = 0;

		END IF;

	

	IF iExiste = 0 THEN

	SET ISOLATION TO DIRTY READ;

	SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(id_funcion) 

	INTO iTotalAceptados

	FROM bdicnweb:"informix".sw_evc_excluidos 

	WHERE lote = pLote AND status = 'C';



	SET ISOLATION TO DIRTY READ;

	SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(id_funcion)

	INTO iTotalRechazados

	FROM bdicnweb:"informix".sw_evc_excluidos

	WHERE lote = pLote AND status <> 'C';



	SET ISOLATION TO DIRTY READ;

	SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} cm.archivo, cm.fecha_carga, 

		COUNT(cm.fecha_carga) AS total_registros

	INTO cArchivoCarga, dFechaCarga, iTotalRegistros

	FROM bdicnweb:"informix".sw_evc_excluidos cm

	WHERE cm.lote = pLote

	GROUP BY cm.archivo, cm.fecha_carga;



			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES

			-- Busqueda del nombre del ejecutivo

			SET ISOLATION TO DIRTY READ;

			SELECT nombre

			INTO cNombreEjecutivo

			FROM bdinteg:"informix".si_ejecut

			WHERE ejecutivo = pIdUsuario;

			

			LET cSistemaCuenta = '06';

			LET cStatusLote = 'C';

			INSERT INTO bdicnweb:"informix".sw_tr_totales_masivo (id_lote, usuario, nombre_ejecutivo, nombre_archivo, fecha_carga, sistema_cuenta, total_registros, 

																total_monto, registros_aceptados, registros_rechazados, id_funcion)

			VALUES (pLote, pIdUsuario, cNombreEjecutivo, cArchivoCarga, dFechaCarga, cSistemaCuenta, iTotalRegistros, mTotalMonto, iTotalAceptados, iTotalRechazados, pIdFuncion);

			

	

	RETURN cCodRet, dFechaCarga, iTotalRegistros, iTotalAceptados, iTotalRechazados, cArchivoCarga;

	

	ELSE

			SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(lote)

			INTO cTotalRecal

			FROM bdicnweb:"informix".sw_evc_excluidos

			WHERE lote = pLote;

			

			SET ISOLATION TO DIRTY READ;

			SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(id_funcion) 

			INTO iTotalAceptados

			FROM bdicnweb:"informix".sw_evc_excluidos 

			WHERE lote = pLote AND status = 'C' OR status = 'U';



			SET ISOLATION TO DIRTY READ;

			SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} COUNT(id_funcion)

			INTO iTotalRechazados

			FROM bdicnweb:"informix".sw_evc_excluidos

			WHERE lote = pLote AND status <> 'C' AND status <> 'U';

			

			SET ISOLATION TO DIRTY READ;

			UPDATE  bdicnweb:"informix".sw_tr_totales_masivo SET total_registros = cTotalRecal,

			registros_aceptados = iTotalAceptados, registros_rechazados = iTotalRechazados

			WHERE id_lote = pLote AND id_funcion = pIdFuncion;

			

			SET ISOLATION TO DIRTY READ;

			SELECT  fecha_carga, total_registros, total_monto, registros_aceptados, registros_rechazados, nombre_archivo, sistema_cuenta, status_lote

			INTO dFechaCarga, iTotalRegistros, mTotalMonto, iTotalAceptados, iTotalRechazados, cArchivoCarga, cSistemaCuenta, cStatusLote

			FROM bdicnweb:"informix".sw_tr_totales_masivo

			WHERE id_lote = pLote AND id_funcion = pIdFuncion;

			

			RETURN cCodRet, dFechaCarga, iTotalRegistros, iTotalAceptados, iTotalRechazados, cArchivoCarga;

		END IF;

	

END;

END PROCEDURE

DOCUMENT

"Autor: Juan Salvador JimÃ©nez Galindo",

"Fecha: 2013-07-24",

"DescripciÃ³n: Obtiene los totales de exclusiÃ³n de un lote seleccionado.";

CREATE PROCEDURE "informix".sp_evc_excluyecliente(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),
                                                  pNumCredito char(20),TipoExcepcion char(1), TipoEjecucion Smallint )
returning 
          CHAR(5) as resultado,
          CHAR(60) as mensaje;
		  
	DEFINE cMensajeRet      CHAR(100);
	DEFINE iCodRet          INTEGER;
	DEFINE SCodRet          CHAR(5);
	DEFINE  dtFechaHoy     	DATE;
	DEFINE  cRuta			CHAR(100);
	DEFINE  cNomArchOri 	CHAR(50);
	DEFINE  cNomArchRep 	CHAR(50);
	DEFINE  cSQL            CHAR(4000);
	DEFINE 	vnumcredito		CHAR(20);
	DEFINE 	vmotivo			CHAR(1);
	DEFINE	vfecharep		DATE;
	DEFINE	vproducto		CHAR(4);
	DEFINE	vexcluir		CHAR(100);
	DEFINE	bEsNumero		BOOLEAN;
	
	

--Inicialización de variables
	LET cMensajeRet = 'Proceso de desbloqueo ejecutado correctamente';
	LET iCodRet     = 0;
	LET SCodRet     ='00000';
	LET dtFechaHoy  = DATE(1);	
	LET cRuta       = '';
	LET cNomArchOri = '';
	LET cNomArchRep = '';
	LET cSQL        = '';
	LET vnumcredito   = '';
	LET vmotivo       = '';
	LET vfecharep	= DATE(1);
	LET	vproducto	= '';
	LET vexcluir    = '';
	LET bEsNumero   = 't';
	
	IF (length(pNumCredito) > 20)  THEN
        LET SCodRet    = '00002';
        LET cMensajeRet   = 'Crédito no válido, excede del número de dígitos permitidos';
        RETURN SCodRet, cMensajeRet;
    END IF;	 
/*
	IF (nvl(pNumCredito,'') <> '')  THEN
		EXECUTE PROCEDURE bdinteg:val_num (pNumCredito) INTO bEsNumero;
			IF bEsNumero = 'f' THEN
				LET SCodRet    = '00003';
				LET cMensajeRet   = 'Num. de crédito no válido, contiene caracteres no numericos';
				RETURN SCodRet, cMensajeRet;
			END IF;	
    END IF; */
    
	
    /*if pNumCredito <>'0' then
	  EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, pNumCredito ,'06','1')
	  INTO	SCodRet ;
      IF SCodRet = "00028" THEN
        RETURN SCodRet, cMensajeRet;
      END IF;
	else   
	  EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
      INTO SCodRet ;
      IF SCodRet = "00028" THEN
        RETURN SCodRet, cMensajeRet;
      END IF;
    end if;*/
	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF SCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en el proceso de desbloqueo de los créditos a excluir';
         UPDATE sw_evc_excluidos		
               SET status = 'E', fecha_proceso =dtFechaHoy, codret_proceso =SCodRet, motivo_rechazo= cMensajeRet 
	     WHERE cuenta = vnumcredito and status=  'C';

	END IF;
	RETURN SCodRet,cMensajeRet;
	END EXCEPTION;
	set isolation to dirty read;
	select max(fechareporte) into dtFechaHoy from bdicobranza:cb_rep_cart_quebrantar;
	
	----SET DEBUG FILE TO "sp_vta_excluyect1e.out";
      -- --TRACE ON; 
	
	--If TipoEjecucion = 1 Then
	  --insert into  sw_evc_excluidos (cuenta, motivo )
	  --values (pNumCredito, TipoExcepcion);
	--End if;  
	set isolation to dirty read;
	FOREACH
		SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} b.num_credito, a.motivo, b.fechareporte, b.producto
		INTO vnumcredito, vmotivo, vfecharep, vproducto
		FROM sw_evc_excluidos a, bdicobranza:cb_rep_cart_quebrantar b
		WHERE FechaReporte =  dtFechaHoy
		  and a.cuenta = b.num_credito
                and a.status = 'C' 
                and ( b.num_credito = pNumCredito or pNumCredito  =0 )
		
		--Actualizando en tabla bdicobranza:cb_rep_cart_quebrantar los creditos a excluir
		UPDATE bdicobranza:cb_rep_cart_quebrantar
			SET excluido = vmotivo
			WHERE num_credito = vnumcredito and FechaReporte =  dtFechaHoy;
		
		
			--Actualizando en la tabla maecred y maecredcrd los creditos que se desbloquearán por excluirse de la venta de cartera
			IF  vproducto = '6001' and vmotivo = 'E' then 
						UPDATE bdicred:sd_maecred
							SET id_unidad_prod = null 
							WHERE empresa = '001'
							AND num_credito = vnumcredito;
					ELIF vproducto = '6001' and vmotivo = 'F' then 
						UPDATE bdicred:sd_maecred
							SET id_unidad_prod = null, cod_caract_2 = 'DEF' 
							WHERE empresa = '001'
							AND num_credito = vnumcredito;		
					ELIF vproducto in ('6011','6300','6400') and vmotivo in ('E','F') then 			
						UPDATE bdicred:sd_maecredcrd
							SET id_origen = ''
							WHERE empresa = '001'
							AND num_credito = vnumcredito;
			END IF;
            UPDATE sw_evc_excluidos		
               SET status = 'S', fecha_proceso =dtFechaHoy
	     WHERE cuenta = vnumcredito and status=  'C';

	END FOREACH;
	 RETURN SCodRet,cMensajeRet;
	 END;
				
END PROCEDURE 
DOCUMENT
'Se realiza procedimiento para marcar y desbloquear los créditos a excluir de la venta de cartera solicitados por el area de operaciones y crédito',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 03/Abril/2013',
'BD    : bdicred',
'Version: 20130506.0957',
'Modificación Se agregaron validaciones a parámetros de entrada: número de crédito, tipo de excepción y tipo ejecución ',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 08/Mayo/2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_evc_excluyecredito(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10), cNUMCREDITO char(20), 
                                                  cMotivo char(1))
returning 
          CHAR(5) as resultado,
          INTEGER as idRegistro;
		  
	DEFINE cMensajeRet      CHAR(100);
	DEFINE iCodRet          INTEGER;
	DEFINE SCodRet          CHAR(5);
	DEFINE  dtFechaHoy     	DATE;
	DEFINE  dtFechaAnt     	DATE;
	DEFINE  dtFechaRep     	CHAR(8);
	DEFINE  cRuta			CHAR(100);
	DEFINE  cNomArchOri 	CHAR(50);
	DEFINE  cNomArchRep 	CHAR(50);
	DEFINE  cSQL            CHAR(4000);
	DEFINE 	vnumcredito		CHAR(20);
	DEFINE 	vmotivo			CHAR(1);
	DEFINE	vfecharep		DATE;
	DEFINE	vproducto		CHAR(4);
	DEFINE	vexcluir		CHAR(100);
    DEFINE  vidRegistro     INTEGER;
	


----SET DEBUG FILE TO "/informix/marcov/sp_vta_cargacteexcep.out";
----TRACE ON; 
	
	
--Inicialización de variables
	LET cMensajeRet = 'El Proceso de cargar los créditos a excluir se ejecutó correctamente';
	LET iCodRet     = 0;
	LET SCodRet     ='00000';
	LET dtFechaHoy  = DATE(1);
	LET dtFechaAnt  = DATE(1);
	LET dtFechaRep  = '';
	LET cRuta       = '';
	LET cNomArchOri = '';
	LET cNomArchRep = '';
	LET cSQL        = '';
	LET vnumcredito = '';
	LET vmotivo     = '';
	LET vfecharep	= DATE(1);
	LET	vproducto	= '';
	LET vexcluir    = '';
    LET vidRegistro = 0;
	
	
	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF iCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en la ejecución del proceso de cargar los créditos a excluir';
	END IF;
	RETURN SCodRet,vidRegistro;
	END EXCEPTION;
	
	--Sacando fecha del ultimo reporte
	Select max(fechareporte) INTO vfecharep
	from bdicobranza:cb_rep_cart_quebrantar;
	
	
	--Validando que se actualice el marcaje  de los creditos que se van a excluir de acuerdo al campo valor de la tabla sd_param
	SELECT TRIM(valor) INTO vexcluir
        FROM bdicred:"informix".sd_param
       WHERE cod_param = '108';
		 
	IF TRIM(vexcluir) <> '0' OR vexcluir IS NULL THEN
        LET SCodRet    = '00212';
        LET cMensajeRet   = 'Ya no es posible excluir créditos';
        RETURN SCodRet, vidRegistro;
    END IF;	


	EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCREDITO ,'06','1')
	INTO 	SCodRet;

		IF SCodRet <> "00000" THEN
			RETURN SCodRet, vidRegistro;
		END IF;
	--para no permitir insertar registros en blanco
	IF NVL(cNUMCREDITO,'') = '' THEN
		
			LET SCodRet    = '00001';
			RETURN SCodRet, vidRegistro;
	END IF;
	--para no permitir insertar creditos vendidos
	IF cNUMCREDITO IN (select num_credito from bdicred:sd_maecred where status_cred = 'CV') 
			OR cNUMCREDITO IN (select num_credito from bdicred:sd_maecredcrd where status_cred = 'CV') THEN

			LET SCodRet    	  = '00201';
			LET cMensajeRet   = 'El Crédito se encuentra vendido';
			RETURN SCodRet, vidRegistro;
	END IF;

	--Para reverso de exclusion
	IF cNUMCREDITO IN (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} cuenta
							from sw_evc_excluidos
							where status not in ('C','E')) THEN
		
		IF cNUMCREDITO IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where nvl(excluido, '') = '' and FechaReporte = vfecharep ) THEN

			UPDATE sw_evc_excluidos
			SET status = 'C', motivo = cMotivo, fecha_carga = today, id_funcion = id_funcion, usuario = cID_USUARIOC
			WHERE id_registro = (select max(id_registro) from sw_evc_excluidos where cuenta = cNUMCREDITO);
			
		ELSE
		
			/*UPDATE sw_evc_excluidos
			SET status = 'C', fecha_carga = today, id_funcion = id_funcion, usuario = cID_USUARIOC
			WHERE cuenta = cNUMCREDITO;*/
			
			LET SCodRet    = '00213';
			LET cMensajeRet   = 'El crédito ya se encuentra excluido';
			RETURN SCodRet, vidRegistro;
			
		END IF;	
			

	ELIF cNUMCREDITO IN (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} cuenta
							from sw_evc_excluidos where status = 'C') THEN	
	
			UPDATE sw_evc_excluidos
			SET status = 'U', fecha_carga = today, id_funcion = id_funcion, usuario = cID_USUARIOC
			WHERE id_registro = (select max(id_registro) from sw_evc_excluidos where cuenta = cNUMCREDITO);
			
			
	ELIF cNUMCREDITO NOT IN (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} cuenta
								from sw_evc_excluidos
								where status<>'') AND --inserte campo 
			cNUMCREDITO IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where nvl(excluido, '') <> '' and FechaReporte = vfecharep ) THEN	
	
			LET SCodRet    = '00213';
			LET cMensajeRet   = 'El crédito ya se encuentra excluido';
			RETURN SCodRet, vidRegistro;
	
	ELIF cNUMCREDITO NOT IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where FechaReporte = vfecharep ) THEN	
	
			LET SCodRet = '00017';
			LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
			RETURN SCodRet, vidRegistro;

	ELIF cNUMCREDITO IN (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} cuenta
							from sw_evc_excluidos where status = 'E') THEN	

			LET SCodRet = '00214';
			LET cMensajeRet = 'El Crédito se encuentra ignorado por error de validación';
			RETURN SCodRet, vidRegistro;			

	ELSE

		insert into sw_evc_excluidos
		 ( id_registro ,id_funcion,usuario ,fecha_carga,status, cuenta, motivo, lote )
		values(0, cID_FUNCIONC, cID_USUARIOC, today, 'C', cNUMCREDITO, cMotivo, 0 );
		set isolation to dirty read;
		select max(id_registro) 
		into vIdRegistro
		from sw_evc_excluidos;
		
	END IF;	

    IF vIdRegistro IS NULL THEN LET vIdRegistro = 0; END IF;
	
	RETURN SCodRet,vIdRegistro;
	END;

END PROCEDURE 
DOCUMENT
'Se realiza procedimiento para cargar de archivo a tabla los créditos a excluir de la venta de cartera solicitados por el area de operaciones y crédito',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 03/Abril/2013',
'BD    : BDISOLIC',
'Version: 20130507.1807 ',
'Modificación : Se Modificó SP para modificar el nombre del archivo a cargar para que tome el mes actual y solo en formato AAAAMM',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 07/Mayo/2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_evc_marca_creditosnovalidos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))

RETURNING CHAR(5) AS codret;
-- Control de Cambios
-----------------------------------------------------------------------------------
----Marco Valenzuela
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);
DEFINE iSqlErr INT;
DEFINE dFechaRep DATE;
DEFINE cNumCredito	CHAR(20);
DEFINE cMotivo	CHAR(1);
DEFINE iNumLote INTEGER;
DEFINE iLote INTEGER;
DEFINE iNumReg INTEGER;
DEFINE cStatus	CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "00000";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";
LET iSqlErr = 0;
LET dFechaRep = DATE(1);
LET cNumCredito = '';
LET cMotivo = '';
LET iNumLote = 0;
LET iLote = 0;
LET iNumReg = 0;
LET cStatus = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
	--Sacando fecha del ultimo reporte
	Select max(fechareporte) INTO dFechaRep
	from bdicobranza:cb_rep_cart_quebrantar;

	--Sacando el ultimo lote generado
	Select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)}
	max(lote) INTO iNumLote
	from bdicnweb:sw_evc_excluidos
	where lote<>'0';
	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

	IF trim(cCodRet) <> "00000" THEN
		RETURN trim(cCodRet);
	END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

----SET DEBUG FILE TO "/informix/marcov/sp_evc_marca_creditosnovalidos.out";
----TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
set isolation to dirty read;
	FOREACH
		SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_lote)} a.cuenta, a.motivo, a.lote, a.id_registro,a.status
		INTO cNumCredito, cMotivo, iLote, iNumReg, cStatus
		FROM bdicnweb:sw_evc_excluidos a
		WHERE a.lote = iNumLote
		
		
		
		IF cNumCredito IN (select num_credito from bdicred:sd_maecred where status_cred = 'CV') 
			OR cNumCredito IN (select num_credito from bdicred:sd_maecredcrd where status_cred = 'CV') THEN

			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Vendido',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
			
		ELIF cNumCredito IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where nvl(excluido, '') <> '' and FechaReporte = dFechaRep ) THEN
		
			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Ya Excluido',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
		
		ELIF cNumCredito NOT IN (SELECT num_credito from bdicobranza:cb_rep_cart_quebrantar where FechaReporte = dFechaRep ) THEN	
			
			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito No Existe',
			status = 'E'
			WHERE cuenta = cNumCredito and lote = iNumLote;
			
			
		ELIF iNumReg NOT IN(SELECT MAX(id_registro) FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta) AND cStatus <> 'P' THEN

			UPDATE bdicnweb:"informix".sw_evc_excluidos
			SET motivo_rechazo = 'Crédito Repetido',
			status = 'E'
			WHERE cuenta = cNumCredito
			AND id_registro NOT IN(SELECT MAX(id_registro) FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta) AND cStatus <> 'P';
			
		END IF;
		
	END FOREACH;	
		
 
RETURN trim(cCodRet);
END;
 
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para actualizar con estatus E y poner motivo de rechazo, a los créditos no validos por no pasar los filtros de validación en la carga masiva',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 27/Sep/2013',
'BD    : BDICNWEB';

CREATE PROCEDURE "informix".sp_reversocargomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
	
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(6);
	DEFINE cFolioGen	CHAR(16);
	DEFINE dFechaProc	DATETIME YEAR TO FRACTION;
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	DEFINE cResultadoSp	CHAR(100);
	DEFINE cResultado	CHAR(15);
	DEFINE iIdRegistro	INTEGER;
	DEFINE cStatus		CHAR(1);
	DEFINE wBegin		SMALLINT;
	DEFINE iReversar 	SMALLINT;
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	DEFINE iTotalRegs	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE iTotalRever	INTEGER;
	DEFINE iTotNoRever	INTEGER;
	
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cFolioGen = '';
	LET cResultado = '';
	LET dFechaProc = NULL;
	LET iIdRegistro	= 0;
	LET iNoRegs = 0;
	LET cStatus = '';
	LET cResultadoSp = '';
	LET wBegin = 0;
	LET iReversar = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535)
			LET wBegin = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtenmos la fecha actual
		SELECT FIRST 1 current
		INTO dFechaProc
		FROM bdicnweb:sw_tr_cargamasiva_cargo_hist
		WHERE lote = pLote;
		
		BEGIN;
			UPDATE   bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'P'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		-- Se coloca el estatus de todos los movimientos para ser reversados
		BEGIN;
			UPDATE {+INDEX (bdicnweb:sw_tr_cargamasiva_cargo_hist idx_status)} bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'R'
			WHERE status = 'S';
		COMMIT;
		
		-- Se recorre el lote
		FOREACH WITH HOLD SELECT id_registro, folio
			INTO iIdRegistro, cFolioGen
			FROM bdicnweb:sw_tr_cargamasiva_cargo_hist
			WHERE lote = pLote AND status = 'R'
			
			BEGIN;
				EXECUTE PROCEDURE bdicred:"informix".sp_grabarreversocargosmasivos(cFolioGen)
				INTO cCodRetSp, cResultadoSp;
			COMMIT;
			
			IF cCodRetSp <> '000000' THEN
				LET cResultado = 'NO REVERSADO';
				LET cStatus = 'S';
			ELIF cCodRetSp = '000000' THEN
				LET cResultado = 'REVERSADO';
				LET cStatus = 'R';
			END IF;
				
			BEGIN;	
				UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
				SET fecha_reverso = dFechaProc,
					resultado_reverso = cResultado,
					codret_reverso = cCodRetSp,
					status = cStatus,
					comentario_reverso = cResultadoSp
				WHERE lote = pLote AND id_registro = iIdRegistro;
				
				LET iNoRegs = iNoRegs + 1;
			COMMIT;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizamos los estatus a inactivos
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'I'
			WHERE codret_reverso <> '000000'
				AND lote = pLote;
		COMMIT;
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'I'
			WHERE codret_reverso = '000000'
				AND lote = pLote;
		COMMIT;
			
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_cargo_hist
			SET status = 'S', resultado = 'APLICADO'
			WHERE lote = pLote AND status = 'NP';
		COMMIT;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_totales_masivo
			SET status_lote = 'T'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		COMMIT;
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_constotalesreversocargocre(pUsuario, pIdFuncion, pLote)
		INTO cCodRetSp, iTotalRegs, mTotalMonto, iTotalRever, iTotNoRever;
		
		IF cCodRetSp <> '00000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, iNoRegs;
		END IF;
		
		LET dFechaMail = current;
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, TRIM(pPlantilla)
			, TRIM(pPlantilla)			
			, pUsuario
			,''
			,''
			,'1'
			, pLote
			,NVL(iTotalRegs, 0)
			,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
			,''
			,''
			,''
			,''
			,''
			,''
			, TRIM(pTituloPlantilla)
			,''
			,''
			,'0'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRetSp;
					
		IF wBegin = 1 THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el reverso de un lote masivo de cargo de credito de la aplicación CNWEB";

CREATE PROCEDURE "informix".sp_sw_ro_consctesimgsctas(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT)
	RETURNING CHAR(5) AS codret,
			INT AS id_cliente,
			CHAR(164) AS nombre
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iIdCte INT;
	DEFINE cNombreCte CHAR(164);
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET iIdCte = 0;
	LET cNombreCte = '';
	LET iNoRows = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdCte, cNombreCte;
			END IF;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''OR pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} COUNT(*)
		INTO iNoRows
		FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1');
		IF iNoRows = 0 THEN
			LET cCodRet = '00111';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
		LET iNoRows = 0; 
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT {+INDEX (bdicnweb:sw_ro_resulcte idx_certexpdig)} b.id_resulcte, TRIM(TRIM(a.nombre1)||' '||
										TRIM(a.nombre2)||' '||
										TRIM(a.apell_paterno)||' '||
										TRIM(a.apell_materno)||' '||
										TRIM(a.razon_social)) AS nombre
			INTO iIdCte, cNombreCte
			FROM sw_ro_resulper a, sw_ro_resulcte b
			WHERE a.id_oficio = pIdOficio
				AND a.status_busqueda = '1'
				AND a.ind_omitir = '0'
				AND a.status = '1'
				AND b.id_resulper = a.id_resulper
				AND (b.certifica_imagenes = '1'OR b.ind_expdig = '1')
			LET iNoRows = iNoRows + 1;
			RETURN cCodRet, iIdCte, cNombreCte WITH resume;
		END FOREACH;
		IF iNoRows = 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, iIdCte, cNombreCte;
		END IF;
	END
END PROCEDURE;