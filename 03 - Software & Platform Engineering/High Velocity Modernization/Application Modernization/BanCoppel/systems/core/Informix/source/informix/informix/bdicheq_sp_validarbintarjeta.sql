CREATE PROCEDURE "informix".sp_validarbintarjeta(p_NumTarjeta CHAR(16))

	RETURNING
	CHAR(5)		AS COD_RET,
	CHAR(25)	AS BANCO;

	---DECLARACIONES
	DEFINE v_cod_ret   CHAR(5);
	DEFINE v_cod_ret2  CHAR(5);
	DEFINE iSqlErr     INTEGER;
	DEFINE iSamErr     INTEGER;
	DEFINE sBIN        CHAR(6);
	DEFINE sBanco	   CHAR(25);
	DEFINE sCveBanco   CHAR(3);

	---INICIALIZACIONES
	LET v_cod_ret	= "00000";
	LET v_cod_ret2	= "00000";
	LET sBIN		= "";
	LET sBanco		= "";
	LET sCveBanco	= "";

	-- SET DEBUG FILE TO "/tmp/pitdc/sp_validarbintarjetas.out";
	-- TRACE ON;

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
			END IF;
			RETURN v_cod_ret, sBanco;
		END EXCEPTION;

		--- VALIDA QUE LA TARJETA NO VENGA VACIA O NULA
		IF (p_NumTarjeta IS NULL OR p_NumTarjeta = '') THEN
			LET v_cod_ret = "00001";
			RETURN v_cod_ret, sBanco;
		END IF

        ---- 06-05-2010 
        IF LENGTH (p_NumTarjeta) = 15 THEN
            LET sBIN = SUBSTR(p_NumTarjeta,1,2);
            IF EXISTS (SELECT valor FROM bdisac:sac_param WHERE cod_param = sBIN) THEN
                SELECT valor INTO sBanco FROM bdisac:sac_param WHERE cod_param = sBIN;
            ELSE
--                LET v_cod_ret = "00055";
                LET v_cod_ret = "00058";
            END IF;
        ELSE
            ---- OBTIENE EL BIN POR MEDIO LOS PRIMEROS SEIS DIGITOS DE LA TARJETA
            LET sBIN = SUBSTR(p_NumTarjeta,1,6);

            ---- VALIDA QUE EXISTA EL BIN EN EL CATALOGO
            IF NOT EXISTS (SELECT {INDEX (bdicheq:sc_bines i_bin_cd)} bin FROM bdicheq:sc_bines WHERE bin = sBIN and LOWER(creditodebito) = 'c') THEN
--                LET v_cod_ret = "00055";
                LET v_cod_ret = "00058";
                RETURN v_cod_ret, sBanco;
            ELSE
                --- OBTIENE EL BANCO AL CUAL PERTENECE EL BIN
                SELECT {INDEX (bdicheq:sc_bines i_bin_cd)} banco_prosa, cve_banco
                INTO sBanco, sCveBanco
                FROM bdicheq:sc_bines
                WHERE bin = sBIN and LOWER(creditodebito) = 'c';

                -- DSB 14/04/2010
                IF TRIM(sCveBanco) = "137" THEN
--                    LET v_cod_ret = "00056";
                    LET v_cod_ret = "00059";
                    RETURN v_cod_ret,sBanco;
                END IF;
            END IF;
        END IF;
		RETURN v_cod_ret,sBanco;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Mohamed Carreón',
'DESCRIPCION: Procedimiento que valida el bin de la tarjeta',
'FECHA: MARZO 2010',
'VERSION: 20100325.1800',
'DSB 14/04/2010 - Se agrega validacion de la clave banco para que cuando se BanCoppel lo rechaze',
'MODIFICO: Iris Arias Zazueta',
'06-05-2010 - Se agrega validacion para que en caso de que la tarjeta sea de AMEX obtenga descripion del banco de sac_param',
'MODIFICO: Jesus Montoya',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_dispersiontraspasomovtos()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE cCodRet            	    	CHAR(5);
DEFINE iSqlError            	    INTEGER;
DEFINE iIsamErr            	    	INTEGER;
DEFINE iEmpleado           	    	INTEGER;
DEFINE iNumRegMov           	    INTEGER;
DEFINE iNumRegEnc           	    INTEGER;

LET cCodRet  = '00000';
LET iSqlError  = 0;
LET iIsamErr = 0;
LET iEmpleado = 0;
LET iNumRegMov = 0;
LET iNumRegEnc = 0;

--*********************************************
--SET DEBUG FILE TO '/tmp/sp_dispersiontraspasomovtos.out';
--TRACE ON;
--*********************************************

BEGIN
	ON EXCEPTION SET iSqlError, iIsamErr
		IF iSqlError != 0 THEN
				LET cCodRet = iSqlError;
				RETURN cCodRet;
		END IF;
    END EXCEPTION;

	INSERT INTO bdicheq:sc_nominamovimientoshist (nombre_archivo,num_empleado,apell_paterno,apell_materno,nombres,cuenta_abono,importe,concepto,status)
	SELECT nombre_archivo,num_empleado,apell_paterno,apell_materno,nombres,cuenta_abono,importe,concepto,status
	FROM bdicheq:sc_nominamovimientos
	WHERE status <> 0;

	LET iNumRegMov = DBINFO("sqlca.sqlerrd2");

	INSERT INTO bdicheq:sc_nominaencabezadosumariohist (empresa,fecha_gen,folio_archivo,nombre_archivo,sentido,cuenta_cargo,fecha_aplicacion,
	total_registros,importe_tot,status,	fecha_insert,importe_aplicado,importe_no_aplicado,folio_acuserecibo,folio_dispersion,iva,comision,
	fecha_aplicado,hora_aplicado)
	SELECT empresa,fecha_gen,folio_archivo,nombre_archivo,sentido,cuenta_cargo,fecha_aplicacion,total_registros,importe_tot,status,
	fecha_insert,importe_aplicado,importe_no_aplicado,folio_acuserecibo,folio_dispersion,iva,comision,fecha_aplicado,hora_aplicado
	FROM bdicheq:sc_nominaencabezadosumario
	WHERE status <> 1;
	
	LET iNumRegEnc = DBINFO("sqlca.sqlerrd2");

	IF iNumRegMov <= 0 OR iNumRegEnc <= 0 THEN
		LET cCodRet = '00001';
	ELSE
		DELETE FROM bdicheq:sc_nominamovimientos WHERE status <> 0;
		DELETE FROM bdicheq:sc_nominaencabezadosumario WHERE status <> 1;
	END IF;

 RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se genera el proceso para realizar el traspaso de la informacion a las tablas historicas. ',
'FECHA : 16/12/2010',
'VERSION: 20101216.1158',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_nominamovimientos(pNombreArchivo CHAR(17))
	RETURNING CHAR(5), CHAR(10), CHAR(30), CHAR(20), CHAR(30), CHAR(20), MONEY(16,2), CHAR(60), CHAR(30);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE isam_err			INTEGER;
DEFINE cNum_empleado		CHAR(10);
DEFINE cApell_paterno	CHAR(30);
DEFINE cApell_materno	CHAR(20);
DEFINE cNombres			CHAR(30);
DEFINE cCuenta_abono	CHAR(20);
DEFINE mImporte			MONEY(16,2);
DEFINE cConcepto		CHAR(60);
DEFINE iContador		INTEGER;
DEFINE cStatus 			CHAR(30);

--VALORES INICIALES
LET cSqlerr 			= 0;
LET cCodret 			= '00000';
LET vsSQL 				= '';
LET isam_err 			= 0;
LET cNum_empleado		= '';
LET cApell_paterno 		= '';
LET cApell_materno 		= '';
LET cNombres 			= '';
LET cCuenta_abono 		= '';
LET mImporte	 			= 0.00;
LET cConcepto 			= '';
LET cStatus 				= '';
LET iContador = 0;

--SET debug FILE TO "/tmp/sp_NominaMovimientos.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
            RETURN NVL(cCodret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,''),NVL(cConcepto,''),NVL(cStatus,'');
        END IF;
	END EXCEPTION;

	--Se obtiene la lista de cuentas a regresar
	FOREACH WITH HOLD
		
	SELECT {+INDEX(sc_nominamovimientos idx_nominamovimientos2)} mov.num_empleado, mov.apell_paterno, mov.apell_materno, mov.nombres, mov.cuenta_abono, mov.importe, con.descripcion, est.descripcion 
	INTO cNum_empleado, cApell_paterno, cApell_materno, cNombres, cCuenta_abono, mImporte, cConcepto, cStatus
	FROM bdicheq:sc_nominamovimientos AS mov, 
	     bdicheq:sc_nominaestatus AS est, bdicheq:sc_nominaconceptos AS con 
	WHERE est.tpo_status = '02' 
	AND est.cod_status = mov.status 
	AND mov.nombre_archivo = pNombreArchivo 
	AND mov.status = est.cod_status
	AND  mov.concepto = con.codigoconcepto
	
	UNION ALL
	
	SELECT {+INDEX(sc_nominamovimientoshist idx_nominamovimientoshist2)} mov.num_empleado, mov.apell_paterno, mov.apell_materno, mov.nombres, mov.cuenta_abono, mov.importe, con.descripcion, est.descripcion 
	FROM bdicheq:sc_nominamovimientoshist AS mov, 
	     bdicheq:sc_nominaestatus AS est, bdicheq:sc_nominaconceptos AS con 
	WHERE est.tpo_status = '02' 
	AND est.cod_status = mov.status 
	AND mov.nombre_archivo = pNombreArchivo 
	AND mov.status = est.cod_status
	AND  mov.concepto = con.codigoconcepto

		LET iContador = iContador + 1;
		RETURN NVL(cCodret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,''),NVL(cConcepto,''),NVL(cStatus,'') WITH RESUME;
	END FOREACH;
	IF iContador = 0 THEN
		--no hay registros  para regresar
		LET cCodret = '00001';
		RETURN NVL(cCodret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,''),NVL(cConcepto,''),NVL(cStatus,'');
	END IF
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Obtener las cuentas para la dispersion manual, con el fin de regresar la informacion de cuentas al reporte de dispersion manual',
'FECHA : Noviembre de 2009',
'BD    : BDICHEQ',
'VERSION: 20091119.0730',
'MODIFICÓ :Maria Elena Angulo Aispuro',
'DESCRIPCION:  Se agrega union a una nueva consulta a la tabla de sc_nominamovimientoshist con el fin de regresar la informacion de cuentas al reporte de dispersion manual que se encuentran en la historica',
'FECHA : Enero del 2011',
'BD    : BDICHEQ',
'VERSION: 20110112.1806';

create procedure "informix".reg_cheque_doc( pempresa   char(3),  -- Empresa
                                            pcuenta    char(20), -- Cuenta
                                            psucursal  char(4), -- Sucursal
                                            pnumcheq   integer, -- No. Cheque
                                            pcodigo    char(2), -- codigo devolucion
                                            pmonto     decimal(12,2), -- importe
                                            pfolio_suc char(16), -- folio sucursal
                                            ptransacc  char(4), -- transaccion
                                            pejecutivo char(8)    --Usuario
                                            )
RETURNING     CHAR(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              reg_cheque_doc
   --
   -- Version              1.0.1
   -- Objetivo:            Registro detalle de movimientos de chequeras.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Alejandro Rueda Sanchez
   -- ModIFicado por:      
   -- Ultima ModIFicacion: Junio  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vconsec         smallint;
   DEFINE vdummy          char(100);
   DEFINE vfecha_hoy   	  DATE;
   DEFINE vhora           char(15);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vt_estado 	  CHAR(1);

   LET vcodret      = " ";
   LET vsqlerr      = 0;
   LET vconsec      = 0;
   LET vdummy       = " ";
   LET vt_estado    = " ";

--   SET DEBUG FILE TO "/tmp/reg_cheque_doc.out";
--   TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END exception;

   --// Selecciona la fecha del dia.
   SELECT fecha_hoy 
     INTO vfecha_hoy 
     FROM bdicheq:sc_fechas;

   SELECT CURRENT HOUR TO second
     INTO vhora
     FROM bdinteg:dual;

   --//Validaciones de nulos en parametros de entrada
   IF pempresa = " " or pcuenta = " " or psucursal = " " or pnumcheq = 0 or pcodigo = " "  or pejecutivo = " " then
      LET vcodret = "110";
      RETURN vcodret;
   END IF

let pempresa = pempresa;
let pcuenta = pcuenta;
let pnumcheq = pnumcheq;

   --// Selecciona el numero maximo de cheques.
   SELECT max(secuencia)
     INTO vconsec
     FROM bdicheq:sc_contch_hist
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND numchq = pnumcheq;

   IF vconsec IS NOT NULL THEN
      LET vconsec = vconsec + 1;
   ELSE
      LET vconsec = 1;
   END IF


   --// SI fue pagado en sucursal, regisstra el cambio del documento
   If pcodigo = "00" then
      --//Inserta el detalle
-- METER ACTUALIZACION POR SEPARADO PARA CHEQUES POR CAMARA'
    if ptransacc = '0231' then
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq,vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "M", "", pejecutivo);
    else
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq,vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "P", "", pejecutivo);

       UPDATE sc_contch SET estado = "P", fecha_alta = vfecha_hoy, importe = pmonto 
        WHERE empresa = pempresa
          AND cuenta = pcuenta
          AND numero = pnumcheq;
    end if
   ELSE --//No fue pagado
      --//Verifica el estatus actual del cheque
      SELECT estado 
        INTO vt_estado 
        FROM bdicheq:sc_contch
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND numero = pnumcheq;
  
      IF vt_estado = "P" THEN
         LET vcodret = "600";
         RETURN vcodret;
      END IF  

      --//Inserta el detalle
     IF ptransacc in ('3314','3313','3228','0260') THEN -- PRESENTADO POR CAMARA Y DEVUELTO
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq, vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "N", pcodigo, pejecutivo);
     ELSE
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq, vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "U", pcodigo, pejecutivo);
     IF vt_estado = "A" or vt_estado = "U" THEN
       UPDATE sc_contch SET estado = "U", fecha_alta = vfecha_hoy, importe = pmonto
        WHERE empresa = pempresa
          AND cuenta = pcuenta
          AND numero = pnumcheq;
     END IF  
     END IF	 
   END IF

   LET vcodret = "000";
   RETURN vcodret;
end
END procedure;