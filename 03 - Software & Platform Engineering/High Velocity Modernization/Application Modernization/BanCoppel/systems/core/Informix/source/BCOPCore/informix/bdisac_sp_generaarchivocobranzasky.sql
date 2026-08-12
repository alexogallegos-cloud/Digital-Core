CREATE PROCEDURE "informix".sp_generaarchivocobranzasky(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;

    DEFINE cCveRegistro             CHAR;
    DEFINE cMes, cDia               CHAR(2);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cAnio                    CHAR(4);
    DEFINE cCveEmpresa              CHAR(3);
    DEFINE cReferencia1             CHAR(20);
    DEFINE cSucursal                CHAR(4);
    DEFINE cFolioSuc                CHAR(16);
    DEFINE cEmpresa                 CHAR(9);
    DEFINE cNomArchSky              CHAR(30);
    DEFINE cRutaArchSky             CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cCP                      CHAR(5);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Pago              DATE;

    DEFINE iCveFormato              INTEGER;
    DEFINE iImporte_Pago            INTEGER;
    DEFINE iTotalreg                INTEGER;
    DEFINE iImporteTotal            INTEGER;
    DEFINE iIdTransacc              INTEGER;
    DEFINE mImporteTotal            MONEY(16,2);

    DEFINE cFolio                   CHAR(16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
    DEFINE iCuantos                 INTEGER;
	
	DEFINE cIdentif_Pago_1			CHAR(2);
	
	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE cSPcp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);
	
	/*VARIABLES PARA ELIMINAR SELECT DE IF*/
	DEFINE cvalidaselif INTEGER;
	LET cvalidaselif =0;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cCveEmpresa = 'SKY';
    LET cCveRegistro = '1';
    LET cEmpresa = 'BANCOPPEL';
    LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1 = '';
    LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
    LET iImporte_Pago = 0;
    LET iTotalReg = 0;
    LET iImporteTotal = 0;
    LET iIdTransacc = 0;
    LET mImporteTotal = 0;
    LET cCP='';
    LET cFolio = '';                 
    LET cFlagCen = 0;                 
    LET cFlagSuc = 0;      
    LET iCuantos = 0;    
	
	LET cIdentif_Pago_1 = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET cSPcp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';
	
    --SET DEBUG FILE TO "/tmp/sp_generaarchivocobranzasky_aia.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');

		/*
        SELECT TRIM(valor)||cDia||cMes||cAnio INTO cNomArchSky FROM bdisac:sac_param WHERE cod_param = 06002;
        SELECT TRIM(valor)||cNomArchSky INTO cRutaArchSky FROM bdisac:sac_param WHERE cod_param = 3;
		*/
		
		SELECT valor INTO cNomArchSky FROM bdisac:sac_param WHERE cod_param = 06002;
		LET cNomArchSky = TRIM(cNomArchSky)||cDia||cMes||cAnio;
		
		SELECT valor INTO cRutaArchSky FROM bdisac:sac_param WHERE cod_param = 3;
		LET cRutaArchSky = TRIM(cRutaArchSky)||cNomArchSky;

        --Encabezado

        LET cStmt = 'echo "' || cCveRegistro || '|' || cDia || cMes || cAnio || '|' || cCveEmpresa || '|' || cEmpresa || '" > ' || cRutaArchSky;
        SYSTEM cStmt;

        LET cCveRegistro = '2';
        LET cStmt = '';

        --Detalle
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),
                   LPAD(YEAR(fecha_pago::DATE), 4, '0'), referencia1, 
		   importe_pago * 100, CAST(transacc_suc AS INTEGER),
		   SUBSTRING(folio_suc FROM 9 FOR 8), NVL(id_sucursal,'0000'), 
           flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago,
           CASE forma_pago
		        WHEN '1' THEN '01'
				WHEN '2' THEN '28'
				ELSE '99' END AS Identificador_Pago_1
	    INTO   cDia, cMes, cAnio, cReferencia1, iImporte_Pago, iIdTransacc, cFolioSuc, cSucursal, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, cIdentif_Pago_1
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
            OR flag_confirmacion_sucursal = 1)

			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,cSPcp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			IF cSPCodRet != '00000' THEN
				LET cCP = '00000';				
			ELSE
				LET cCP = cSPcp;
			END IF;	

            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f		 
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
						LET iCuantos=0;
              END IF;
            END IF;
			
            LET iTotalReg = iTotalReg + 1;
            LET mImporteTotal = mImporteTotal + iImporte_Pago / 100;

            LET cStmt = 'echo "' || cCveRegistro || '|' || cDia || cMes || cAnio || '|' || LPAD(trim(cReferencia1), 12, ' ') || '|' || LPAD(iImporte_Pago, 12, '0') ||  
						'|' || LPAD(iIdTransacc, 5, '0') || '|' || LPAD(trim(cFolioSuc), 8, '0')  || '|' || LPAD(trim(cCP), 5, '0') || '|' || cIdentif_Pago_1 ||  '" >> ' || cRutaArchSky;
            SYSTEM cStmt;
        END FOREACH;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFecha_Pago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			LET cReferencia1 = TRIM(cReferencia1);
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFecha_Pago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;

        LET iImporteTotal = mImporteTotal * 100;

        -- Sumario
        LET cCveRegistro = '9';
        LET cStmt = '';

        LET cStmt = 'echo "' || cCveRegistro || '|' || LPAD(iTotalReg, 7, '0') || '|' || LPAD(iImporteTotal, 12, '0') || '" >> ' || cRutaArchSky;
        SYSTEM cStmt;

        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE;