CREATE PROCEDURE "informix".sp_obten_compras_promo(pEmpresa CHAR(3),pCredito CHAR(20),pSecuencia SMALLINT)

	RETURNING
		CHAR(6) 						AS CodRet,
		CHAR(80)						AS MensajeRet,
		DATE    						AS FechaMov,
		DATETIME HOUR TO FRACTION(3) 	AS HoraMov,
		CHAR(20)					 	AS NumCredito,
		CHAR(40) 						AS Referencia,
		DECIMAL(18,2)					AS Monto,
		CHAR(16)						AS FolioSuc;		
		
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr				INTEGER;	
	DEFINE iIsamErr				INTEGER;	
	DEFINE cErrorInfo			CHAR(80);
	DEFINE cCodRet				CHAR(6);			
	DEFINE cMensajeRet			CHAR(80);		
	DEFINE dmontoMin			DECIMAL(18, 2);	
	DEFINE dtFechaHoy			DATE;
	DEFINE dtFechaCorte			DATE;
	DEFINE dtFechaMov			DATE;
	DEFINE dtHoraMov			DATETIME HOUR TO FRACTION(3);
	DEFINE cNumCredito			CHAR(20);
	DEFINE vReferencia			VARCHAR(40,1);
	DEFINE dmonto 				DECIMAL(18,2);
	DEFINE iNRows 				INTEGER;	
	DEFINE cFolioSuc			CHAR(16);	
	DEFINE sCiclo   			SMALLINT;
		
	--INICIALIZACION DE VARIABLES.
	LET iSqlErr				= 0;	
	LET iIsamErr			= 0;	
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';	
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dmontoMin			= 0.00;	
	LET dtFechaHoy 			= DATE(1);
	LET dtFechaCorte 		= DATE(1);
	LET dtFechaMov 			= DATE(1);
	LET dtHoraMov 			= CURRENT;
	LET cNumCredito			= '';
	LET vReferencia			= '';
	LET dmonto				= 0.00;
	LET iNRows				= 0;
	LET cFolioSuc			= '';
	LET sCiclo				= 0;
		
	BEGIN
				
		ON EXCEPTION SET iSqlErr,iIsamErr,cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;	
				LET cMensajeRet = TRIM(cErrorInfo);
				RETURN TRIM(cCodRet),TRIM(cMensajeRet), NVL(dtFechaMov, DATE(1)), NVL(dtHoraMov, CURRENT), TRIM(NVL(cNumCredito,'')),TRIM(NVL(vReferencia,'')),NVL(dmonto,0.00),TRIM(NVL(cFolioSuc,''));							
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/sysifx/SPsPAYAN/sp_obten_compras_promo.out";
		--TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;		
		SET ISOLATION TO DIRTY READ;	
						
		--SE VALIDAN LOS PARAMETROS DE ENTRADA.
		IF NVL(pEmpresa, '') = '' OR NVL(pCredito,'') = '' OR pSecuencia IS NULL THEN
			LET cCodRet = '000001';
			LET cMensajeRet = "ERROR EN LOS PARAMETROS";
			RETURN TRIM(cCodRet),TRIM(cMensajeRet),dtFechaMov,dtHoraMov,TRIM(NVL(cNumCredito,'')),TRIM(NVL(vReferencia,'')),NVL(dmonto,0.00),TRIM(NVL(cFolioSuc,''));
		END IF;
		
		--SE OBTIENE EL MONTO MINIMO DE COMPRA.
		SELECT valor
		INTO dmontoMin
		FROM bdicred:"informix".sd_param	
		WHERE cod_param  = '029';
		
		--SE VALIDA EL MONTO MINIMO DE COMPRA.
		IF NVL(dmontoMin,0.01) = 0.01 THEN
			LET cCodRet = '000002';          
			LET cMensajeRet = "NO SE ENCUENTRA EL MONTO MINIMO A DIFERIR";
			RETURN TRIM(cCodRet),TRIM(cMensajeRet), dtFechaMov, dtHoraMov,TRIM(cNumCredito),TRIM(vReferencia), dmonto, TRIM(NVL(cFolioSuc,''));
		END IF;
		
		--SE OBTIENE LA FECHA HOY.		
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;
		
		--SE VALIDA QUE LA FECHA HOY SEA IGUAL O MENOR QUE LA FECHA CORTE PARA CALCULAR EL RENGO DE FECHAS.
		IF DAY(dtFechaHoy)< 21 THEN 			
			--SE CALCULA FECHA CORTE.
			EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1) 
			INTO dtFechaCorte;	
			IF TRIM(NVL(dtFechaCorte,'')) = '' THEN			
				LET cCodRet = '000003';
				LET cMensajeRet = "ERROR EN LA EJECUCION DE BDICRED:MONTHADD";
				RETURN TRIM(cCodRet),TRIM(cMensajeRet),dtFechaMov,dtHoraMov,TRIM(cNumCredito),TRIM(vReferencia),dmonto, TRIM(NVL(cFolioSuc,''));
			END IF;		
			LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
		ELSE 
			LET dtFechaCorte = MDY(MONTH(dtFechaHoy),20,YEAR(dtFechaHoy));
		END IF;
		
		
		FOREACH 
			
			--OBTIENE LOS MOVIMIENTOS DE COMPRAS A COMERCIO EN UN RANGO DE FECHAS ENTRE LA FECHA CORTE Y LA FECHA DE HOY.
			SELECT a.fecha_mov,a.hora_mov,TRIM(a.num_credito), TRIM(SUBSTR(a.referencia, 16, 41)), a.monto,a.folio_suc
			INTO dtFechaMov,dtHoraMov,cNumCredito,vReferencia,dmonto,cFolioSuc
			FROM bdicred:"informix".sd_movdia a
			WHERE a.codigo_fun = '002' 
				AND a.codigo_ref IN (37,57,937,938) 
				AND a.num_credito= pCredito
                AND a.folio_suc NOT IN (SELECT folio_movto FROM bdicred:sd_promocion_credito WHERE num_promo = 2 AND num_credito = pCredito AND status IN (2,0))
				AND a.monto >= dmontoMin
			UNION ALL
			SELECT b.fecha_mov,b.hora_mov,TRIM(b.num_credito),TRIM(SUBSTR(b.referencia, 16, 41)), b.monto,b.folio_suc
			FROM bdicred:"informix".sd_movhis b
			WHERE b.codigo_fun = '002' 
				AND b.codigo_ref IN (37,57,937,938) 
				AND b.monto >= dmontoMin
				AND b.num_credito= pCredito
                AND b.folio_suc NOT IN (SELECT folio_movto FROM bdicred:sd_promocion_credito WHERE num_promo = 2 AND num_credito = pCredito AND status IN (2,0))
				AND b.fecha_mov BETWEEN dtFechaCorte AND dtFechaHoy  
			ORDER BY 1,2 ASC
			
			--SE INCREMENTA VARIABLE PARA EL PAGINADO.
			LET sCiclo = sCiclo + 1;			
			IF sCiclo <= pSecuencia THEN
				CONTINUE FOREACH;
			END IF;
			
			RETURN TRIM(cCodRet),TRIM(cMensajeRet),dtFechaMov,dtHoraMov,TRIM(cNumCredito),TRIM(vReferencia),dmonto,TRIM(NVL(cFolioSuc,'')) WITH RESUME;
			
		END FOREACH; 
		
		--SE VALIDA QUE REGRESE INFORMACION EL PROCEDIMIENTO.						
		LET iNRows = dbinfo("sqlca.sqlerrd2");				
		IF iNRows = 0 THEN
			LET cCodRet = "000004";			
			LET cMensajeRet = "NO SE OBTUVO INFORMACION";
			RETURN TRIM(cCodRet),TRIM(cMensajeRet),NVL(dtFechaMov, DATE(1)), NVL(dtHoraMov, CURRENT),TRIM(NVL(cNumCredito,'')),TRIM(NVL(vReferencia,'')),NVL(dmonto, 0.00), TRIM(NVL(cFolioSuc,''));
		END IF;			
							
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene los movimientos de compras a comercio en un determinado rango de fechas', 
'entre la fecha corte y la fecha hoy',
'AUTOR: Guadalupe Payan',
'FECHA DE CREACION: 26 de Enero del 2012',
'VERSION: 20120126.1230',
'BD: bdicred';

CREATE PROCEDURE "informix".updtraspcred801(fecha_inicial date)
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
DEFINE cVarDataErr      CHAR(100);
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vcuantos 	INTEGER;
DEFINE vmodificados 	INTEGER;
DEFINE vleidos 	        INTEGER;
DEFINE vreferencia	    CHAR(80);
DEFINE vchrfolio        CHAR(16);
DEFINE vfolio           CHAR(16);
DEFINE vtransaccion     CHAR(4);
DEFINE vusuario         CHAR(4);
DEFINE vchrtransuc      CHAR(4);
DEFINE vsucursal        CHAR(4);
DEFINE vdivisa          CHAR(2);
DEFINE vhora            CHAR(15);
DEFINE vnum_credito     CHAR(20);
DEFINE vchrTarjeta      CHAR(16);
DEFINE vimporte_abono   MONEY(14,2);
DEFINE vempresa         CHAR(3);
DEFINE v_codigo_fun     CHAR(3);
DEFINE v_codigo_ref     INTEGER;
DEFINE v_fecha_mov      DATE;


LET cVarDataErr = '';
LET vchrTarjeta = '';
LET vnum_credito = '';
LET v_codigo_fun = '';
LET v_codigo_ref = 0;
LET v_fecha_mov = date(1);
LET vfolio = '';
LET vreferencia = '';
LET vchrcodret = '000';
LET vempresa = '001';


BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
         rollback work;
    	   LET vchrcodret = vintcodret;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --//DEBUG FLAG
    --SET debug file to "/informix/gpe/updtraspcred801.out";
    --TRACE ON;

-- DIVISAS
    select abrev_divisa,cod_divisa from intercard:cat_paisdivisa
	group by abrev_divisa,cod_divisa
    into temp cat_paisdivisa_VIC;

    create unique index cat_paisdivisa_VIC_index on cat_paisdivisa_VIC(cod_divisa);
    update statistics medium for table cat_paisdivisa_VIC;

-- VIC
    select * from bditarjeta:td_movimientos_conciliacion_his
    where archivo_origen in ('VIC','MCC')
      and date(fechaconcilia) >= fecha_inicial - 180
    union all
    select * from bditarjeta:td_movimientos_conciliacion
    where archivo_origen in ('VIC','MCC') 
      and date(fechaconcilia) >= fecha_inicial - 180
    into temp td_movimientos_conciliacion_VIC with no log;

    create index td_movimientos_conciliacion_VIC_inx on td_movimientos_conciliacion_VIC(numtarjeta,folio_mov);
    update statistics medium for table td_movimientos_conciliacion_VIC;
	-- Se agregan Nuevos codigos IFRS
    select a.num_credito, 
           a.fecha_mov, 
           a.codigo_fun, 
           a.codigo_ref, 
           a.folio_suc,
           a.nro_tarjeta, 
           trim(a.folio_suc)|| ' '||trim(nomcomercio325)||' $'||round((b.monto_divisa325/100),2)||' '||trim(c.abrev_divisa)||' T.C $'||round((a.monto/(b.monto_divisa325/100)),2) referencia
    from bdicred:sd_movhisedocta a
    left outer join td_movimientos_conciliacion_VIC b on (a.folio_suc = b.folio_mov and a.nro_tarjeta = b.numtarjeta)
    left outer join cat_paisdivisa_VIC c on (b.divisa325 = c.cod_divisa)
    where a.codigo_fun = '002'
      and a.codigo_ref  IN (37,937,938)
      and a.reversado = 'N'
      and b.monto_divisa325 is not null
      into temp td_referencia_VIC with no log;

    create index td_referencia_VIC_index on td_referencia_VIC(num_credito);
    update statistics medium for table td_referencia_VIC;

    FOREACH WITH HOLD
 
        SELECT num_credito, 
               fecha_mov, 
               codigo_fun, 
               codigo_ref, 
               folio_suc,
               nro_tarjeta, 
               referencia
          INTO vnum_credito,
               v_fecha_mov,
               v_codigo_fun, 
               v_codigo_ref,
               vfolio,
               vchrTarjeta,
               vreferencia
          FROM td_referencia_VIC

        begin work;

            UPDATE sd_movhisedocta SET referencia = trim(vreferencia)
                WHERE empresa = vempresa
                  AND num_credito = vnum_credito
                  AND codigo_fun = v_codigo_fun 
                  AND codigo_ref = v_codigo_ref
				  AND fecha_mov = v_fecha_mov
                  AND reversado <> "S"
                  AND folio_suc = vfolio
                  AND nro_tarjeta = vchrTarjeta;
       
        commit work;
    END FOREACH

    --//Entrega el codigo de retorno 
    RETURN vchrcodret;

END
END PROCEDURE;