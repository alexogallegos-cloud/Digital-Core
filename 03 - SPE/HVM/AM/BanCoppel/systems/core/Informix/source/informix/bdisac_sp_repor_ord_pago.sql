CREATE PROCEDURE "informix".sp_repor_ord_pago()
    RETURNING VARCHAR(5), VARCHAR(40);  -- CÃ³digo de retorno

    DEFINE cCodRet          VARCHAR(5);
    DEFINE cCodMsj          VARCHAR(40);
    DEFINE cInfoErr         VARCHAR(100);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE dPri_dia_mes     DATE;
    DEFINE dUlt_dia_mes     DATE;
    DEFINE vcontregshist    INTEGER;
    DEFINE vcontregsold     INTEGER;
    DEFINE inumdias         INTEGER;
    DEFINE cStatusJob       VARCHAR(1);
    DEFINE iRegJob          VARCHAR(1);
	DEFINE cEstado 			VARCHAR(21);
	DEFINE cNumOper         INTEGER;
	DEFINE cGanacia         VARCHAR(14);
    DEFINE cTnumOper        INTEGER;
	DEFINE cTganacia	    VARCHAR(14);
	DEFINE cRutaArch		VARCHAR(100);
	DEFINE cMes             VARCHAR(2);
	DEFINE cAnio            VARCHAR(4);
	DEFINE iDiasMes         INTEGER;
	DEFINE cStmt			VARCHAR(250);

	--SET DEBUG FILE TO "/informix/EPG/sp_repor_ord_pago.out";
	--TRACE ON;
	
    LET cCodRet          = '00000';
    LET cCodMsj          = '';
    LET cInfoErr         = '';
	LET iSqlErr          = 0;
	LET iIsamErr         = 0;
    LET dPri_dia_mes     = '';
    LET dUlt_dia_mes     = '';
    LET vcontregshist    = 0;
    LET vcontregsold     = 0;
    LET inumdias         = 0;    
    LET cStatusJob       = '';
    LET iRegJob          = '';
	LET cEstado  		 = '';
    LET cNumOper		 = '';	
    LET cGanacia  		 = 0;
	LET cTnumOper        = ''; 
	LET cTganacia        = 0; 
	--LET cRutaArch	     = '/RESPALDOS/Reporte_Ordenes_Pago_MMAAAA.txt';
    --LET cRutaArch	     = '/informix/EPG/Reporte_Ordenes_Pago_MMAAAA.txt';
    LET cRutaArch	     = '/RESPALDOSNEW/Reporte_Ordenes_Pago_MMAAAA.txt';
	LET cAnio            = '';
	LET cMes             = '';
	LET iDiasMes         = 0;
	LET cStmt            = '';
	

     BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                let cCodRet = iSqlErr;
                ROLLBACK WORK;
                EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_repor_ord_pago");
                RETURN cCodRet, cCodMsj;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VERIFICO QUE LA TABLA TMP NO EXISTA
		DROP TABLE IF EXISTS ordenes_pago_tmp;
       
        --VERIFICO QUE EL JOB SE EJECUTE UNA SOLA VEZ EN EL DIA
        SELECT COUNT(*) INTO iRegJob 
        FROM "informix".sac_procesos_jobs WHERE proceso = 'REP_ORDENES_PAGO' AND fecha_proceso = TODAY;

        IF iRegJob = '0' THEN 
            --SE INSERTA UN REGISTRO EN LA TABLA SAC_PROCESOS_JOBS
            INSERT INTO "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                      numero_ejecuciones, nombre_sp, descripcion)
                      VALUES ('REP_ORDENES_PAGO', TODAY, '0', 'informix', CURRENT, 1, 'sp_repor_ord_pago', 'Generacion de reporte de ordenes de pago');
        END IF;              
                    
        --SE EXTRAE EL VALOR DEL CAMPO STATUS
        SELECT status INTO cStatusJob 
          FROM "informix".sac_procesos_jobs WHERE proceso = 'REP_ORDENES_PAGO' AND fecha_proceso = TODAY;

        --SI EL CAMPO STATUS CONTIENE UN VALOR '1' YA NO SE REALIZA EL PROCESO PORQUE YA FUE EJECUTADO ANTERIORMENTE
        --SOLO PUEDE EJECUTARCE UNA VEZ AL DIA.
        IF cStatusJob = '0' THEN

			--SELECCIONAMOS MES ANTERIOR
			SELECT pri_dia_mes INTO dUlt_dia_mes 
			  FROM sac_fechas;
			
			LET dUlt_dia_mes = dUlt_dia_mes - 1;
			LET iDiasMes = SUBSTR(dUlt_dia_mes,4,2) - 1;
			LET dPri_dia_mes = dUlt_dia_mes - iDiasMes;
		
			--ASIGNA VALOR A LAS VARIABLES para el nomnre del arvhivo
			LET cMes  = LPAD(MONTH(dPri_dia_mes),2,'0');
			LET cAnio = LPAD(YEAR (dPri_dia_mes),4,'0');			
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
			
			LET cStmt = 'echo "'||'ESTADO               |NO.OPERACIONES|COMISION'|| '" >> ' || cRutaArch;
			SYSTEM cStmt;
			LET cStmt ='';
			
			--AGRUPO NUMERO DE OPERACIONES Y GANACIA POR ESTADO
			SELECT id_sucursal, importe_comision_cte, iva_comision_cte
			  FROM "informix".sac_movimientoshistorial
			  WHERE numcategoria = '07' 
			   AND numconvenio  = '001'
			   AND flag_confirmacion_central = '1'
			   AND flag_confirmacion_central = '1'
			   AND fecha_pago >= dPri_dia_mes
			   AND fecha_pago <= dUlt_dia_mes
			   AND status_cancelado <> 'S'
			   AND origen is not null
			  INTO temp mov_hist_tmp with no log;

			select id_ptf, cve_estado from bdinteg:"informix".si_ptf 
			where tipo <> 'C'
			into temp sucurales_tmp with no log;

			select cve_estado, count(id_sucursal) as num_mov , sum (importe_comision_cte + iva_comision_cte) as totales
			from mov_hist_tmp INNER JOIN sucurales_tmp ON( id_ptf = id_sucursal)
			group by cve_estado
			into temp totales_temp with no log;

			FOREACH
			
				SELECT nombre, num_mov, totales
				  INTO cEstado, cNumOper, cGanacia				
				  FROM totales_temp
				 INNER JOIN bdinteg:"informix".si_estados ON (estado = cve_estado)
				 ORDER BY cve_estado

				LET cGanacia = REPLACE(cGanacia,'$',''); 
				LET cStmt = 'echo "' || cEstado || '|' || RPAD(cNumOper,14,' ') || '|' ||cGanacia ||'" >> ' || cRutaArch;
				SYSTEM cStmt;
				LET cStmt ='';				
			END FOREACH;
			--TOTAL DE OPERACIONES Y GANANCIAS

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cStmt = 'echo "' || ""  || '" >> ' || cRutaArch;
				SYSTEM cStmt;                 
			ElSE
				SELECT SUM (num_mov) AS t_numoper, SUM (totales) AS t_ganancia 
				  INTO cTnumOper, cTganacia	   
				  FROM totales_temp;

				LET cTganacia = REPLACE(cTganacia,'$',''); 	
				LET cStmt = 'echo "'                   ||'               TOTAL |'|| RPAD(cTnumOper,14,' ') || '|' || cTganacia ||'" >> ' || cRutaArch;
				SYSTEM cStmt;
				LET cStmt ='';
			END IF;
			
			DROP TABLE IF EXISTS mov_hist_tmp;
			DROP TABLE IF EXISTS sucurales_tmp;
			DROP TABLE IF EXISTS totales_temp;			
			
			-- REALIZO UN UPADATE A LA TABLA SAC_PROCESOS_JOBS EN EL CAMPO STATUS = 1 PARA QUE SÃ?LO SE EJECUTE UNA SOLA VEZ EL JOB
			UPDATE sac_procesos_jobs SET status = '1' WHERE proceso = 'REP_ORDENES_PAGO' AND fecha_proceso = TODAY; 
			LET cCodMsj = 'Proceso Exitoso';
			
			RETURN cCodRet, cCodMsj;
		ELSE
         
			LET cCodMsj = 'Este proceso ya fue ejecutado';
            RETURN cCodRet, cCodMsj;
        END IF;    
        
    END;
END PROCEDURE

 DOCUMENT
'AUTOR: Eduardo Pineda GuzmÃ¡n',
'Proyecto: RQM 10 1081 Reporte de Ordenes de Pagos',
'Solicito: Leonardo Hernandez Moreno',
'Descripcion: Genera un reporte de ordenes de pagos mensual',
'Fecha: 2018/07/11',
'Version: v1.0',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_confpago_remesa 
(
	cReferencia1 		CHAR (20),
	cCategoria 			CHAR (2), 
	cConvenio 			CHAR(5),
	cFolio_suc 			CHAR (16),
	pNewMtcn 			CHAR(16), 
	pMtcn 				CHAR(10), 
	pBenefCiudad 		CHAR(24), 
	pBenefEdo 			CHAR(40),
	pRetCode 			CHAR(5), 	
	pDesError 			CHAR(250), 
	pFechaHoraRp 		DATETIME YEAR TO SECOND, 
	pFechaInsert 		DATETIME YEAR TO SECOND,
	pFechaNac 			CHAR(8),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pMoneyTransferKey	CHAR(10),  
	pForeignRefNumRq	CHAR(16), 
	pForeingRefNumRp	CHAR(16), 
	pUserInsert			CHAR(8),
	pConfPago           CHAR(1)
)
RETURNING
CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE cConf_pago CHAR(1);
	DEFINE cTxn_status CHAR(1);
	DEFINE dMaxFexha DATETIME YEAR TO SECOND;
	DEFINE cod_errPayWU CHAR(5);
	DEFINE error_descPayWU CHAR(30);
	DEFINE cMarca CHAR(2);
	
	
	LET cCodRet = '00000';
	LET iSql_err = 0;
	LET iIsamErr = 0;
	LET cDescripcion = '';
	LET cConf_pago = '';
	LET cTxn_status = '';
	LET dMaxFexha = '1900-01-01 00:00:00';
	LET cod_errPayWU= '';
	LET error_descPayWU = '';
	
	-- SET DEBUG FILE TO '/tmp/isaac/trace.sql';
	-- TRACE ON;
	 

    BEGIN
		ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
		   IF iSql_err <> 0 THEN
			  LET cCodRet = iSql_err;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		


		IF  NVL(cReferencia1,'') <> ''THEN		
		
				
				IF cCategoria = '07' AND ( cConvenio = '006') THEN LET cMarca = 'WU'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '007') THEN LET cMarca = 'OV'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '008') THEN LET cMarca = 'VI'; END IF;								
				
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_pay(pUsuario,pBenefNameType,pBenefNombreUno,pBenefNombreDos,pBenefApaterno,pBenefAmaterno,pFechaNac,pMoneyTransferKey,pNewMtcn,pMtcn,pForeignRefNumRq,pRetCode,pForeingRefNumRp,pDesError,pUserInsert,pConfPago)
			    INTO cod_errPayWU, error_descPayWU;
				
				SELECT MAX(fecha_insert)
				INTO dMaxFexha
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE mtcn = cReferencia1
				AND TO_CHAR(fecha_insert::DATE) = TODAY;									
									
				SELECT conf_pago, txn_status 
				INTO cConf_pago, cTxn_status 
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE  mtcn = cReferencia1 
				AND fecha_insert = dMaxFexha;	

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00002';
				ELSE
					IF NVL(cConf_pago,'') <> '' AND NVL(cTxn_status,'') <> '' THEN
						IF TRIM(cConf_pago) <> 'P' AND TRIM(cTxn_status) <>'A' THEN
							LET cCodRet = '00004';
						END IF;
					ELSE
						LET cCodRet = '00003';
					END IF;
				END IF;

		ELSE
			LET cCodRet = '00001';
		END IF;	

		RETURN cCodRet;
    END;
END PROCEDURE;