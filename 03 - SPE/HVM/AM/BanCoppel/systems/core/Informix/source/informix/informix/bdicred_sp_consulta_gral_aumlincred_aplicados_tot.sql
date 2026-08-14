CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados_tot(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pOpcFecha CHAR(1), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  INTEGER  		AS TotalRegs;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 		DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador				INTEGER;
	DEFINE cNomEjecutivoMaxPuesto	CHAR(45);
	DEFINE cEjecutivo				CHAR(10);
	DEFINE iTotReg              	INTEGER;

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZO LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 	= DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';
    LET iTotReg                     = 0;

	BEGIN
		
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet, iTotReg;	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_gral_aumlincred_aplicados_tot.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = '';
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet, iTotReg;
		ELSE
		
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados WHERE usuario = pUsuario;
		
			IF pOpcFecha = '1' THEN --Busqueda por fechaOrigen: fecha_insert	
					
					FOREACH WITH HOLD							
						SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte, a.lincred_actual,a.lincred_sugerida,
							a.status,a.causa_status, a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion, vcNumSol, cOrigen, vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status, cEjecutivo
							FROM  bdicred:"informix".sd_bitacora_aumlincred a
							WHERE a.status = 'AP'	
							AND a.fecha_insert  >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_insert  <= pFechaFinal
							ORDER BY fecha_insert
					
						
						LET dMontoIncremento = dLinCredCal - dLinCredAct;
						IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
							LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
						ELSE
							LET dIncremento = 0;
						END IF;
						
						SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
						INTO vcNombre, vcApellPaterno,vcApellMaterno
						FROM bdinteg:'informix'.si_cliente
						WHERE numcte = vcNumCte;
						
					
					IF NVL(cCausa,'') <> '' THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM "informix".sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;
						
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
					LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');				
						LET iContador = iContador + 1;
						
						INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
						VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
		
						
					END FOREACH; 
						
				ELSE
						--Busqueda por fechaAtencion: fecha_status
						FOREACH WITH HOLD							
							SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte,						
								a.lincred_actual,a.lincred_sugerida,a.status,a.causa_status,
								a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status,cEjecutivo
							FROM "informix".sd_bitacora_aumlincred a
							WHERE a.status = "AP"	
							AND a.fecha_status >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_status <= pFechaFinal							
							ORDER BY fecha_status
						
							
							LET dMontoIncremento = dLinCredCal - dLinCredAct;
							IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
								LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
							ELSE
								LET dIncremento = 0;
							END IF;
							
							SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
							INTO vcNombre, vcApellPaterno,vcApellMaterno
							FROM bdinteg:"informix".si_cliente
							WHERE numcte = vcNumCte;
							
							
						IF NVL(cCausa,'') <> '' THEN
						
						--se obtiene la descripcion del motivo de rechazo o cancelacion
							SELECT causa_status||' - '||TRIM(descripcion)
							INTO vcMotivo
							FROM 'informix'.sd_causas_aumlincred
							WHERE status = cStatus
							AND causa_status = cCausa;
						END IF;
							
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
						LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');		
						
							LET iContador = iContador + 1;
							INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
							VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
						END FOREACH; 
		END IF; 
		
		SELECT COUNT(*) 
		INTO iTotReg 
		FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados 
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotReg;
						
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,iTotReg;
				END IF;	   		
			--END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha AtenciÃ³n)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_depura_si_refclientes()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE vNumCte      VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vNumCte      = '';
LET fFecha       = date(1);

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_movhis2.out';
--    TRACE ON;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 11;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(11,'');
    END IF;

	select empresa, num_solicitud, numcte
	 from bdisolic:ss_solicitudes 
	where status_solicitud in ('CN','RT') 
	  AND fecha_insert <= mdy('12','31','2018')
	  AND num_solicitud > vNumCredAux 
	  into temp paso1 with no log;
	  
	create unique index inx_paso1 on paso1(num_solicitud, numcte);
	update statistics medium for table paso1;


    FOREACH WITH HOLD
       SELECT a.num_solicitud, a.numcte
	       INTO vNumCred, vNumCte
           FROM paso1 a,
                bdinteg:si_refclientes b
          WHERE a.empresa = b.empresa
            and a.numcte = b.numcte
            and a.num_solicitud = b.num_solicitud
		  group by 1,2
		  order by 1

        BEGIN WORK;

            insert into bdinteg:si_refclientes_0819
            select * from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            delete from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 11;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;