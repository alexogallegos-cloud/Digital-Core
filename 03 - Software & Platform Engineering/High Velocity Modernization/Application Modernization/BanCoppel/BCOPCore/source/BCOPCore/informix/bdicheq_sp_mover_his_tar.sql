CREATE PROCEDURE "informix".sp_mover_his_tar(pProceso CHAR(3))

	RETURNING CHAR(5) as Codigoretorno, CHAR(30) as Mensaje;
	
--Definicion de variables
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(30);
DEFINE isam_error      	  INTEGER;
DEFINE visam_error	 	  INTEGER;

DEFINE vsCont			  INTEGER;
DEFINE vscountonline	  INTEGER;

DEFINE vistatus			  INTEGER;
DEFINE iContBorra		  INTEGER;
--Variables de tabla

DEFINE vagent_cd      	VARCHAR(3);
DEFINE vuser_request  	VARCHAR(8);
DEFINE vpassword      	VARCHAR(12);
DEFINE vip_origen     	VARCHAR(15);
DEFINE vid_sesion     	VARCHAR(30);
DEFINE vdate_request  	VARCHAR(8);
DEFINE vtime_request  	VARCHAR(8);
DEFINE vnumcte_numtar 	VARCHAR(20);
DEFINE vcod_error     	VARCHAR(5);
DEFINE vdescr_message 	VARCHAR(80);
DEFINE vcte_ban       	VARCHAR(20);
DEFINE vcte_cop       	VARCHAR(20);
DEFINE cnum_tarjeta   	CHAR(20);
DEFINE vfecha_asi     	VARCHAR(8);
DEFINE cestatus_tar   	CHAR(1);
DEFINE cind_tar       	CHAR(1);
DEFINE vdatetimeinsert	DATETIME YEAR TO SECOND;

--Termina definicion de variables	
LET viSqlError = 0;
LET isam_error = 0;
LET vsCodRetorno = '00000';
LET visam_error = 0;
LET vsMensaje = 'PROCESO CORRECTO';

LET vsCont = 0;
LET vscountonline = 0;
LET vistatus = 0;
LET iContBorra = 0;
--Inicializando Variables de tabla
LET vagent_cd         ='';
LET vuser_request     ='';
LET vpassword         ='';
LET vip_origen        ='';
LET vid_sesion        ='';
LET vdate_request     ='';
LET vtime_request     ='';
LET vnumcte_numtar    ='';
LET vcod_error        ='';
LET vdescr_message    ='';
LET vcte_ban          ='';
LET vcte_cop          ='';
LET cnum_tarjeta      ='';
LET vfecha_asi        ='';
LET cestatus_tar      ='';
LET cind_tar          ='';
LET vdatetimeinsert	=CURRENT;

--SET DEBUG FILE TO "/informix/jfponce/RQI63949script/sp_mover_mensajes.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdinteg:"informix".si_errores (sqlerror,error1,error2,error3,error4,error5,error6,user_insert,fecha_insert)
				VALUES (visam_error,viSqlError,0,0,0,0,0,vsMensaje,TODAY);
				
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	IF pProceso='TAR' THEN
	
		SELECT  COUNT(*) INTO vscountonline FROM
		bdicheq:"informix".sc_ws_coppel_bcpl_tar;
		
	   IF vscountonline > 0 THEN
	   
			BEGIN WORK;
		 
   
			FOREACH cursor_borra WITH HOLD FOR
			
				SELECT agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,
				numcte_numtar,cod_error,descr_message,cte_ban,cte_cop,num_tarjeta,fecha_asi,estatus_tar,ind_tar,datetimeinsert
				INTO vagent_cd,vuser_request,vpassword,vip_origen,vid_sesion,vdate_request,vtime_request,
				vnumcte_numtar,vcod_error,vdescr_message,vcte_ban,vcte_cop,cnum_tarjeta,vfecha_asi,cestatus_tar,cind_tar,vdatetimeinsert
				FROM bdicheq:"informix".sc_ws_coppel_bcpl_tar
			
				INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar_his(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,
				numcte_numtar,cod_error,descr_message,cte_ban,cte_cop,num_tarjeta,fecha_asi,estatus_tar,ind_tar,datetimeinsert)
				VALUES (vagent_cd,vuser_request,vpassword,vip_origen,vid_sesion,vdate_request,vtime_request,
				vnumcte_numtar,vcod_error,vdescr_message,vcte_ban,vcte_cop,cnum_tarjeta,vfecha_asi,cestatus_tar,cind_tar,vdatetimeinsert);
			
				LET vsCont = vsCont + 1;
			
				DELETE FROM "informix".sc_ws_coppel_bcpl_tar WHERE CURRENT OF cursor_borra;
				LET iContBorra = iContBorra + 1;
		
				IF iContBorra = 1000 THEN
					COMMIT WORK;
					LET iContBorra = 0;
					BEGIN WORK;
				END IF;

			END FOREACH;
			COMMIT WORK;
		END IF;
	END IF;
	
	RETURN vsCodRetorno, vsMensaje;	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea proceso para depurar registros de tabla sc_ws_coppel_bcpl_tar y pasar la informacion a una tabla historica',
'AUTOR : Juan Francisco Ponce Damian',
'FECHA : 21/06/2023',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_verifica_retiro_efectivo( pSucursal CHAR(4), pCuenta CHAR(20), pMonto DECIMAL(14,2), pFechaHoy DATE, pFechaIni DATE )
RETURNING CHAR(3), DATE, DECIMAL(14,2);
	
	DEFINE vsqlerr   	INTEGER;
    DEFINE visamerr   	INTEGER;
    DEFINE vdescerr   	CHAR(50);
    DEFINE vcodret   	CHAR(5);
    DEFINE vcodret2  	CHAR(5);
    DEFINE vcodret3     CHAR(50);
    
    DEFINE cTpoLimite   CHAR(1);
    DEFINE mMtoLimite   DECIMAL(14,2);
    DEFINE iPlazo       SMALLINT;
    DEFINE mMontoAcum   DECIMAL(16,2);
    DEFINE dtFecha      DATE;
    DEFINE cDia         CHAR(2);
    DEFINE cAnioMes     CHAR(6);
    DEFINE mSdoCuenta   DECIMAL(14,2);
    DEFINE iExisteSuc   SMALLINT;
    DEFINE iPeriodicidad SMALLINT;
	
	LET vsqlerr    = 0; 
    LET visamerr   = 0; 
    LET vdescerr   = 0; 
    LET vcodret    = '000'; 
    LET vcodret2   = ''; 
    LET vcodret3   = ''; 
    
    LET cTpoLimite = '';
    LET mMtoLimite = 0.00;
    LET iPlazo     = 0;
    LET mMontoAcum = 0.00;
    LET dtFecha    = '';
    LET cDia       = '';  
    LET cAnioMes   = '';  
    LET mSdoCuenta = 0.00;
    LET iExisteSuc = 0;
    LET iPeriodicidad = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifica_retiro_efectivo.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret, dtFecha, mSdoCuenta;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifica_retiro_efectivo.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor 
      INTO cTpoLimite
      FROM sc_param
     WHERE codparam = 'LimSuc/Gen';
    
    IF cTpoLimite = 'S' THEN
        SELECT COUNT(*)
          INTO iExisteSuc
          FROM sc_limiteretiro
         WHERE sucursal = pSucursal;  
         
        IF iExisteSuc > 0 THEN
            SELECT monto, plazo, periodicidad   
              INTO mMtoLimite, iPlazo, iPeriodicidad
              FROM sc_limiteretiro                         
             WHERE sucursal = pSucursal;  
             
            IF pMonto <= mMtoLimite THEN
                SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                       NVL(SUM(monto), 0.00) 
                  INTO mMontoAcum
                  FROM sc_retirosefectivo
                 WHERE cuenta = pCuenta
                   AND fecha = pFechaHoy
                   AND transacc = '0223'
                   AND sucursal = pSucursal;
                
                LET mMontoAcum = mMontoAcum + pMonto;
                
                IF mMontoAcum > mMtoLimite THEN 
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
            
            IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
                LET dtFecha = (pFechaHoy - iPlazo);
                
                LET cDia = LPAD(DAY(dtFecha),2,'0'); 
                LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
                
                SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                     '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                     '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                     '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                     '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                     '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, 
                                     '31', capvig31, 0.00 )
                  INTO mSdoCuenta
                  FROM sc_sdodiarioc
                 WHERE cuenta = pCuenta
                   AND aniomes = cAnioMes;
                
                IF pMonto > mSdoCuenta THEN
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
        ELSE
            SELECT monto, plazo, periodicidad   
              INTO mMtoLimite, iPlazo, iPeriodicidad
              FROM sc_limiteretiro                         
             WHERE sucursal = '9999';  
             
            IF pMonto <= mMtoLimite THEN
                SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                       NVL(SUM(monto), 0.00) 
                  INTO mMontoAcum
                  FROM sc_retirosefectivo
                 WHERE cuenta = pCuenta
                   AND fecha = pFechaHoy
                   AND transacc = '0223';
                   --AND sucursal = pSucursal;
                
                LET mMontoAcum = mMontoAcum + pMonto;
                
                IF mMontoAcum > mMtoLimite THEN 
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
            
            IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
                LET dtFecha = (pFechaHoy - iPlazo);
                
                LET cDia = LPAD(DAY(dtFecha),2,'0'); 
                LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
                
                SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                     '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                     '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                     '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                     '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                     '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
                  INTO mSdoCuenta
                  FROM sc_sdodiarioc
                 WHERE cuenta = pCuenta
                   AND aniomes = cAnioMes;
                
                IF pMonto > mSdoCuenta THEN
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
        END IF;
    ELSE  
        SELECT monto, plazo, periodicidad   
          INTO mMtoLimite, iPlazo, iPeriodicidad
          FROM sc_limiteretiro                         
         WHERE sucursal = '9999';  
         
        IF pMonto <= mMtoLimite THEN
            SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                   NVL(SUM(monto), 0.00) 
              INTO mMontoAcum
              FROM sc_retirosefectivo
             WHERE cuenta = pCuenta
               AND fecha = pFechaHoy
               AND transacc = '0223';
               --AND sucursal = pSucursal;
            
            LET mMontoAcum = mMontoAcum + pMonto;
            
            IF mMontoAcum > mMtoLimite THEN 
                LET vcodret = '777';
                LET dtFecha = (pFechaHoy - iPlazo);
                RETURN vcodret, dtFecha, mSdoCuenta;
            ELSE
                LET vcodret = '000';
                LET dtFecha = pFechaHoy;
                RETURN vcodret, dtFecha, mSdoCuenta;
            END IF;
        END IF;
        
        IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
            LET dtFecha = (pFechaHoy - iPlazo);
            
            LET cDia = LPAD(DAY(dtFecha),2,'0'); 
            LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
            
            SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                 '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                 '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                 '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                 '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                 '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
              INTO mSdoCuenta
              FROM sc_sdodiarioc
             WHERE cuenta = pCuenta
               AND aniomes = cAnioMes;
            
            IF pMonto > mSdoCuenta THEN
                LET vcodret = '777';
                LET dtFecha = (pFechaHoy - iPlazo);
                RETURN vcodret, dtFecha, mSdoCuenta;
            ELSE
                LET vcodret = '000';
                LET dtFecha = pFechaHoy;
                RETURN vcodret, dtFecha, mSdoCuenta;
            END IF;
        END IF;
    END IF;
    
    /* #################################################################################################################################
    LET dtFecha = (pFechaHoy - iPlazo);
    
    IF dtFecha < pFechaHoy THEN
        LET cDia = LPAD(DAY(dtFecha),2,'0'); 
        LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
        
        SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                             '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                             '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                             '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                             '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                             '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
          INTO mSdoCuenta
          FROM sc_sdodiarioc
         WHERE cuenta = pCuenta
           AND aniomes = cAnioMes;
           
        IF mMontoAcum > mSdoCuenta THEN
            LET vcodret = '777';
            RETURN vcodret, dtFecha, mSdoCuenta;
        END IF;
    END IF;
    
    RETURN vcodret, dtFecha, mSdoCuenta;
    ################################################################################################################################# */
	  
    END;
    
END PROCEDURE;