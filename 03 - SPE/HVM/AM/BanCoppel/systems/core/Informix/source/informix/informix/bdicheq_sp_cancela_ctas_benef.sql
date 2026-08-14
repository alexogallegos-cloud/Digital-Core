CREATE PROCEDURE "informix".sp_cancela_ctas_benef()
RETURNING VARCHAR(5), VARCHAR(50), INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
DEFINE vcodret1         VARCHAR(5);
DEFINE vcodret2         VARCHAR(5);
DEFINE error_info		VARCHAR(50);
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE vcontador1       INTEGER;
DEFINE vcontador2       INTEGER;
DEFINE vcontador3       INTEGER;
DEFINE vdatefecoper      DATE;
DEFINE vcharcta   		VARCHAR(20);
DEFINE vdatefeccan		DATE;
---------------------------
--Inicializando variables--
---------------------------
--SET DEBUG FILE TO "/informix/ifg/sp_cancela_ctas_benef.out"; --Se genera log en un archivo .out
--TRACE ON;
LET error_info		= 'INICIA PROCESO, SE CARGAN VARIABLES';
LET vcodret1        = '00000';
LET vcodret2        = '00000';
LET sql_err	        = 0;
LET isam_err        = 0;
LET vcontador1      = -1;
LET vcontador2      = 0;
LET vcontador3      = 0;
LET vdatefecoper    = TODAY;
LET vcharcta   		= '';
LET vdatefeccan		= TODAY;
-------------
--Inicia SP--
-------------
	BEGIN
		-------------------------
		--MAnejo de excepciones--
		-------------------------
		ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET error_info = error_info;
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--/SE VALIDA QUE LA CONSULTA CUENTE CON DATOS.
		SELECT COUNT(*)
							 INTO vcontador3
					FROM sc_maechq MAE INNER JOIN sc_cuentas_concentradas CON ON MAE.cuenta = CON.cuenta
						WHERE MAE.status_cta = '7'
						  AND CON.fecha_trasp_benefic IS NOT NULL;
		--/SI LA CONSULTA ANTERIOR ARROJO POR LO MENOS UNO SE INICIA EL PROCESO DE CANCELACION DE CUENTAS
		IF (vcontador3 > 0) THEN
				FOREACH WITH HOLD
						--/SE OPTIENEN LA CUENTA A CANCELAR Y LA FECHA DE TRASPASO
						SELECT  MAE.cuenta, CON.fecha_trasp_benefic
									 INTO vcharcta, vdatefeccan
							FROM sc_maechq MAE INNER JOIN sc_cuentas_concentradas CON ON MAE.cuenta = CON.cuenta
								WHERE MAE.status_cta = '7'
								  AND CON.fecha_trasp_benefic IS NOT NULL
						--/SE ACTIVA 	
						IF vcontador1 = -1 THEN
								LET vcontador1 = 0;
								BEGIN WORK;
						END IF;
						--/SE CANCELA CUENTA CONCENTRADA CON LA FECHA DE TRASPASO A BENEFICENCIA
						UPDATE sc_maechq SET status_cta = '2',
								 motivo = '14',
								 fec_cancelac = vdatefeccan
					 WHERE cuenta = vcharcta
					   AND status_cta = '7';
					   
					   --/incrementea contadores
					   LET vcontador1 = vcontador1 + 1;
					   LET vcontador2 = vcontador2 + 1; 
						
						--/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
						IF vcontador2 >= 1000 THEN
							LET vcontador2 = 0;
							COMMIT WORK;
							BEGIN WORK;
						 END IF;
				END FOREACH;
		--//SI LA CONSULTA NO ARROJO RESULTADOS DE INDICA A TRAVES DEL error_info
		ELSE
					LET error_info = 'TOTAL DE CUENTAS CANCELADAS EL DIA'||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||':';
					
		END IF;
		--/SI CONTADOR 2 NO LLEGO A LOS 1000 YA QUE TEMINO EL CICLO ANTERIOR, DEL TRABAJO SE TERMINA
		IF (vcontador2 > 0) THEN		
			COMMIT WORK;
		ELSE 
			LET vcontador1 = 0;
		END IF;
		
		LET error_info = 'TOTAL DE CUENTAS CANCELADAS EL DIA '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||':';
		
		RETURN vcodret1, error_info, vcontador1 ;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Israel Flores Gonzalez',
'Descripcion: Proceso automativo que cancela cuentas con Status 7',
'             de la tabla bdicheq:sc_maecheq tomando la fecha de ',
'             cancelaciÃ³n de la tabla bdicheq:sc_cuentas_concentradas',
'Fecha: 2017/06/16',
'Peticion: RQI 11 1812 - Cambio de estatus de cuentas traspasadas a la beneficencia',
'Version: 20170616.1',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consintisrxprod2(pfecha DATE , pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5), DATE, CHAR(4), CHAR(40), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2);
		    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      INTEGER;
    DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrCobrado  DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
    LET dFecha       = '';
    LET cProducto    = '';
    LET cNombre      = '';
    LET mInteresCalc = 0.00;
    LET mInteresPag  = 0.00;
    LET mDifInteres  = 0.00;
    LET mIsrCalc     = 0.00;
    LET mIsrCobrado  = 0.00;
    LET mDifIsr      = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/tmp/sp_consintisrxprod2.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
        END IF;
    END EXCEPTION;  
    
     --SET DEBUG FILE TO "/tmp/mfinis/sp_consintisrxprod2.out";
     --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
    END IF;
    
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_pagoints_cobroisr
     WHERE fecha = pFecha;
           
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
    ELSE
        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion fecha, producto, nombre, 
                   SUM(interes_calculado), SUM(interes_pagado), SUM(diferencia_interes), 
                   SUM(isr_calculado), SUM(isr_cobrado), SUM(diferencia_isr)
              INTO dFecha, cProducto, cNombre, 
                   mInteresCalc, mInteresPag, mDifInteres, 
                   mIsrCalc, mIsrCobrado, mDifIsr
              FROM bdicheq:sc_pagoints_cobroisr
             WHERE fecha = pFecha
             GROUP BY 1, 2, 3
             ORDER BY 1, 2
             
            RETURN cCodRet1, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr WITH RESUME;
            
            LET dFecha       = '';
            LET cProducto    = '';
            LET cNombre      = '';
            LET mInteresCalc = 0.00;
            LET mInteresPag  = 0.00;
            LET mDifInteres  = 0.00;
            LET mIsrCalc     = 0.00;
            LET mIsrCobrado  = 0.00;
            LET mDifIsr      = 0.00;
        END FOREACH;
    END IF;
     
    END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid pricipal de la funcionalidad',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/07/2017',
'DESCRIPCION: Se realiza el cambio del tipo de dato para la variable iExiste',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consintisrxprod2_totales(pfecha DATE)
		RETURNING CHAR(5), INTEGER;
		    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      INTEGER;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/tmp/sp_consintisrxprod2_totales.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, iExiste;
        END IF;
    END EXCEPTION;  
    
     --SET DEBUG FILE TO "/tmp/mfinis/sp_consintisrxprod2_totales.out";
    -- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, iExiste;
    END IF;
    
    
	SELECT COUNT(DISTINCT(producto)) 
		INTO iExiste
		FROM bdicheq:sc_pagoints_cobroisr
		WHERE fecha = pfecha;
           
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, iExiste;
    ELSE
        RETURN cCodRet1, iExiste;
    END IF;
     
    END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los total de los datos para el llenado del grid pricipal de la funcionalidad',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/07/2017',
'DESCRIPCION: Se realiza el cambio del tipo de dato para la variable iExiste',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consultsolicitudes( pfecha_reg date, cod_oper integer, no_pag integer, pregistros integer)
RETURNING CHAR(3),
 integer, 
 CHAR(30),
 CHAR(10),
 CHAR(20),
 CHAR(30),
 integer;

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(3);
DEFINE Cod_ret           CHAR(3);
DEFINE isolicitudes      INTEGER;
DEFINE cFolio            CHAR(30);
DEFINE cNumcte           CHAR(10);
DEFINE cBanco            CHAR(20);
DEFINE cEstatus          CHAR(30);
DEFINE vfechoy           CHAR(8); 
DEFINE vfecant           CHAR(8); 
DEFINE vsql              CHAR(400);
DEFINE pSalto		     INTEGER;
DEFINE vfecha_reg        CHAR(8);  
       

DEFINE cfolio_sol        CHAR(30);  
DEFINE cfech_sol         CHAR(8);
DEFINE cnomb_cte         CHAR(60); 
DEFINE crfc_cte          CHAR(13);
DEFINE ccta_recept       CHAR(20);
DEFINE ctipo_cta_rec     CHAR(2);
DEFINE cbco_receptor     CHAR(5);
DEFINE ccta_ordenante    CHAR(20);
DEFINE ctipo_cta_orden   CHAR(2);
DEFINE cbco_orden        CHAR(5);
DEFINE cnombco_orden     CHAR(20);
DEFINE cfecha_nac        DATE;
DEFINE crfc_emp          CHAR(12);
DEFINE cestatus_resp     CHAR(2);
DEFINE cfecha_resp       CHAR(8);
DEFINE ccurp_cte         CHAR(18);
DEFINE cnum_cte          CHAR(9); 
DEFINE dtFechaIni        DATE;
DEFINE dtFechaHoy        DATE;
DEFINE dtfecant          DATE; 
DEFINE iRegistros		 INTEGER; 

--VALORES INICIALES
LET cSqlerr 			= 0;
LET cCodret 			= '';
LET Cod_ret             = '';
LET isolicitudes        = 0; 
LET cFolio              = '';
LET cNumcte             = '';     
LET cBanco              = '';
LET cEstatus            = ''; 
LET vfechoy             = ''; 
LET vfecant             = '';
LET vsql                = '';
LET pSalto              = 0;   
LET vfecha_reg          = ''; 

LET cfolio_sol        = '';  
LET cfech_sol         = '';
LET cnomb_cte         = ''; 
LET crfc_cte          = '';
LET ccta_recept       = '';
LET ctipo_cta_rec     = '';
LET cbco_receptor     = '';
LET ccta_ordenante    = '';
LET ctipo_cta_orden   = '';
LET cbco_orden        = '';
LET cnombco_orden     = '';
LET cfecha_nac        = ''; 
LET crfc_emp          = '';
LET cestatus_resp     = '';
LET cfecha_resp       = '';
LET ccurp_cte         = '';
LET cnum_cte          = '';
LET dtFechaIni  = DATE(1);
LET dtFechaHoy  = DATE(1);
LET dtfecant    = DATE(1);
LET iRegistros		  = 0;


	BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret, isolicitudes, cFolio,cNumcte,cnombco_orden,cEstatus, iRegistros;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_consultsolicitudes.out";
		--TRACE ON;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
  
	-- //  ENVIA CODIGO DE ERROR SI EXISTE UN PARAMETRO NULO
  
		IF NVL(pfecha_reg, "") = "" OR NVL(cod_oper,"") = "" OR NVL(no_pag,"") = "" OR NVL(pregistros,"") = ""  THEN
			LET cCodRet = "002";	
			RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
		END IF;
  
	-- // OBTIENE PARAMETRO DE LA FECHA DE HOY 
	
			SELECT fecha_hoy
			INTO dtFechaHoy
			FROM bdicheq:"informix".sc_fechas
			WHERE empresa = '001';
  
	-- // ENVIA CODIGO DE ERROR SI LA FECHA ESTA MAS DE 5 DIAS ATRAS O ES UNA FECHA  FUTURA.
 
				LET dtFechaIni = dtFechaHoy - 5 UNITS DAY;    --  La consulta se realiza 5 dias atras.			
			IF pfecha_reg < dtFechaIni OR pfecha_reg > dtFechaHoy THEN
				LET cCodRet = "003";
				RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
			END IF;		
			
	
	--// PONE EN VARIABLES LA FECHA SOLICITADA Y EL DIA ANTERIOR DE LA MISMA
	
			LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0); 
						
			LET dtfecant = pfecha_reg - 5 UNITS DAY;		
			LET vfecant=   YEAR(dtfecant)||LPAD(MONTH(dtfecant),2,0)||LPAD(DAY(dtfecant),2,0);
					
						 		
			IF cod_oper=20  THEN

				IF no_pag =0  THEN
			
					-- //LIMPIAR LAS TABLAS TEMPORALES
					DELETE FROM sc_portacec_archivotemp;
                    CREATE sequence myseq;

                    INSERT into  sc_portacec_archivotemp (secuencia,folio_solicitud,fecha_solicitud,nombre_cte,rfc_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,fecha_nacimiento,rfc_empresa,estatus_respuesta,fecha_respuesta,curp_cte)
                    SELECT myseq.nextval, folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc_cte, 	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fecha_nacimiento, 
						rfc_empresa,'00' as estatus_respuesta, '00000000' as fecha_respuesta,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte
						from sc_portacec_solicitud ps
					    WHERE fecha_solicitud	BETWEEN vfecant and vfecha_reg			 
						and estatus_portabilidad='2'
						and clave_sentido='2'							
						and (fecha_respuesta =  '' OR fecha_respuesta IS null)
					    and folio_solicitud not in (SELECT folio_solicitud
					    FROM sc_portacec_bitacora_solicitudes);
                     
                        SELECT COUNT(*) INTO iRegistros 
					    FROM sc_portacec_archivotemp;    

                    DROP sequence myseq;
				
					foreach 
					
						select SKIP no_pag FIRST pregistros folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc, 
						num_cte,	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select vchrnombrecorto
						from bdinteg:si_bancos
						where cvecesif= bco_ordenante) as bco_ordenante,
						(select fecha_nac
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fec_nac, 
						rfc_empresa,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte	
						into cfolio_sol,cfech_sol,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte
						from sc_portacec_solicitud ps
						where fecha_solicitud BETWEEN vfecant and vfecha_reg
						and estatus_portabilidad='2'
						and clave_sentido='2'											
                        and (fecha_respuesta =  '' OR fecha_respuesta IS null)
			            and folio_solicitud not in (SELECT folio_solicitud
					    FROM sc_portacec_bitacora_solicitudes)
                        
						
			
						LET isolicitudes= isolicitudes+1;
						if isolicitudes <>0 then
							LET cCodret='000';	
						end if	
			
						RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
					end foreach
				
			
				ELSE 

                    SELECT COUNT(*) INTO iRegistros 
					FROM sc_portacec_archivotemp;    
				
					foreach 		
						select SKIP no_pag FIRST pregistros folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc, 
						num_cte,	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select vchrnombrecorto
						from bdinteg:si_bancos
						where cvecesif= bco_ordenante) as bco_ordenante,
						(select fecha_nac
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fec_nac, 
						rfc_empresa,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte	
						into cfolio_sol,cfech_sol,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte
						from sc_portacec_solicitud ps
						where fecha_solicitud BETWEEN vfecant and vfecha_reg
						and estatus_portabilidad='2'
						and clave_sentido='2'						
                        and (fecha_respuesta =  '' OR fecha_respuesta IS null)
						and folio_solicitud not in (SELECT folio_solicitud
					    FROM sc_portacec_bitacora_solicitudes)
						
						
						LET isolicitudes=isolicitudes + (no_pag +1 );
						if isolicitudes <>0 then
							LET cCodret='000';	
						end if
                         
                        LET no_pag=0;
												
						RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
					end foreach
				end if

			ELIF cod_oper=21  THEN
			
                  SELECT COUNT(*)
                             INTO iRegistros 
                             FROM sc_portacec_archivotemp;  
				foreach 		
					
				select SKIP no_pag FIRST pregistros 
				ps.folio_solicitud, 
                        por.num_cte, 
                                    vchrnombrecorto, 
                                    pr.descripcion

                                    into cfolio_sol,cNumcte, cnombco_orden, cEstatus
                                    from sc_portacec_archivotemp ps,
                                    bdinteg:si_bancos si,
                                    sc_portacec_solicitud por,
                                    sc_portacec_estatus_respuesta pr
                                    where ps.folio_solicitud= por.folio_solicitud
                                    and   ps.bco_ordenante= si.cvecesif
                                    and   ps.estatus_respuesta= pr.estatus_respuesta
				

				
				
					LET isolicitudes= isolicitudes+1;
					if isolicitudes <>0 then
						LET cCodret='000';	
					end if
												
					RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
				end foreach

			ELSE
                LET cCodRet = '004';    --CODIGO DE OPERACION INVALIDO

				RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
										
			END IF

					--// NO EXISTEN DATOS
				IF isolicitudes = 0 THEN
					LET cCodRet = '001';
				RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
				END IF
			
			
	END
	END PROCEDURE
  
  
  ;