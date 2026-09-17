CREATE PROCEDURE "informix".sp_obtenerctas_cte_web(pEmpresa CHAR(3),
									 pNumCte CHAR(20),
									 pCuenta CHAR(20),
									 pTarjeta CHAR(20),
									 pTipoCuenta INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno,  
		  CHAR(20)  AS Cuenta;
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(5);	
    DEFINE cNumCte      	 CHAR(20);	
    DEFINE cCuenta      	 CHAR(20); 
    DEFINE cStatus      	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);	
	DEFINE iSqlErr      	 INTEGER;	

	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "00000";		
	LET cNumCte    	 	  = "";    
    LET cCuenta      	  = "";	
    LET cStatus      	  = "";
	LET cTarjeta     	  = "";	
	LET iSqlErr      	  = 0;	

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cCuenta;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/Sp_obtenerctas_cte.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';			 
			RETURN cCod_ret,cCuenta;
	ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
		LET cCod_ret = '00001';			
		RETURN cCod_ret,cCuenta;		
	ELSE
		IF pCuenta <> '' THEN
			SELECT num_cte,cuenta 
			INTO cNumCte,cCuenta 
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pCuenta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito 
				INTO cNumCte,cCuenta 
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = pCuenta;			
			END IF;
				
		ELIF pTarjeta <> '' THEN
			
			SELECT numcte,cuenta
			INTO cNumCte,cCuenta 
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE empresa = "001"
			AND num_tarjeta = pTarjeta
			AND status_tar = "A";
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito 
				INTO cNumCte,cCuenta 
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pTarjeta
				AND status_tar in ('A','I','C');
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = '00100';						
					RETURN cCod_ret,cCuenta;
				END IF;
			END IF;
				
		ELIF pNumCte <> '' THEN
			LET cNumCte = pNumCte;
		END IF;
			
		SELECT numcte 
		INTO cNumCte 
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = cNumCte;

		IF cNumCte IS NULL THEN
			LET cCod_ret = "00003";				
			RETURN cCod_ret,cCuenta;
		END IF;
		
		IF pTipoCuenta = "1" THEN
		-- *****************************************************************
		-- Extrae la informacion del Sistema de Cheques
		-- *****************************************************************
			FOREACH
				SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
				WHERE mc.num_cte = cNumCte AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5')					
				ORDER BY cuenta					

				RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;					
			END FOREACH;
							
		ELIF pTipoCuenta = "2" THEN											
			-- *********************************************************************
			-- Extrae la informacion del Sistema de Credito
			-- *********************************************************************
			
			--FOREACH
			--	SELECT DISTINCT ss.num_solicitud INTO cCuenta FROM bdisolic: ss_solicitudes ss					  
			--	WHERE numcte = cNumCte AND ss.status_solicitud = 'AT' ORDER BY 1
								
			--	RETURN cCod_ret, NVL(cCuenta,"")WITH RESUME;					
			--END FOREACH;
			
			FOREACH
				/*SELECT DISTINCT mc.num_credito INTO cCuenta	FROM bdicred:"informix".sd_maecred mc
				WHERE numcte = cNumCte AND mc.status_cred = 'AA' 
				AND num_producto in ('6001','6600','7000','8100')
				ORDER BY 1	*/
				--IFRS Se contempla nuevo estatus vigente por Etapas	
				SELECT DISTINCT mc.num_credito, mc.status_cred 
				INTO cCuenta, cStatus 
				FROM bdicred:"informix".sd_maecred mc
				INNER JOIN bdicred:sd_maesdos dos ON (mc.num_credito = dos.num_credito)
				WHERE numcte = cNumCte 
				AND mc.status_cred IN ('AA','E1')  
				AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
				--WHERE numcte = cNumCte AND mc.status_cred in ('AA')
				AND num_producto in ('6001','6600','7000','8100','8500')
				ORDER BY 1	                  
			
				RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;					
			END FOREACH;	

		ELIF pTipoCuenta = "3" THEN
			SELECT numcte,cuenta
			INTO cNumCte,cCuenta 
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE empresa = "001"
			AND num_tarjeta = pTarjeta;
		--	AND status_tar = "A";
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	

	  
		ElIF pTipoCuenta = "4" THEN
			SELECT numcte,num_credito 
			INTO cNumCte,cCuenta 
			FROM bdicred:"informix".sd_tarjeta 
			WHERE empresa = "001"
			AND num_tarjeta = pTarjeta;
			--      	AND status_tar = "A";
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	
		END IF;	
	END IF;		
END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Realiza consulta de Cliente para regresar la informaciÃ³n de sus cuentas de cheques, crÃ©ditos",
"Folio: 98",
"Autor: 95419888 Elmer LÃ³pez Valenzuela",
"Proyecto Tarjetas Personalizadas: ",
"Fecha: 05-10-2016",
"BD:bdinteg";

CREATE PROCEDURE "informix".sp_obtienecifrasdeclientesduplicados(iLimite INTEGER)
RETURNING CHAR(6);

	--DEFINICION DE VARIABLES
	DEFINE cCodret				CHAR(6);
	
	DEFINE cNumcte_uno			CHAR(13);
	DEFINE cNumcte_dos			CHAR(13);
	DEFINE cTipocte				CHAR(1);
	DEFINE cSexo				CHAR(1);
	DEFINE cStatusCta			CHAR(1);
	DEFINE cStatusCred			CHAR(2);
	DEFINE cStatusInv			CHAR(1);	
	DEFINE iTotalRegistros		INTEGER;
	DEFINE iErrorBD				INTEGER;
	DEFINE iContadorCtes		INTEGER;
	DEFINE iTAMANO_TRANSACCION	INTEGER;
	DEFINE iPOR_PROCESAR		INTEGER;
	DEFINE iId_comp				INTEGER;
	DEFINE iCifras_Obt1			INTEGER;
	DEFINE iCifras_Obt2			INTEGER;
	DEFINE siTipo_cliente 		SMALLINT;
	DEFINE siCtas_cap 			SMALLINT;
	DEFINE siCreditos 			SMALLINT;
	DEFINE siSolicitud_act 		SMALLINT;	
	DEFINE siInversiones 		SMALLINT;

	--INICIALIZACION DE VARIABLES
	LET cCodret  			= '000000';
	LET cNumcte_uno			= '';
	LET cNumcte_dos			= '';
	LET cTipocte			= '';
	LET cSexo				= '';
	LET cStatusCta			= '';
	LET cStatusCred			= '';
	LET cStatusInv			= '';
	LET iTotalRegistros		= 0;
	LET iContadorCtes		= 0;
	LET iTAMANO_TRANSACCION	= 5000;
	LET iPOR_PROCESAR		= iLimite;
	LET siTipo_cliente 		= 0;
	LET siCtas_cap 			= 0;
	LET siCreditos 			= 0;
	LET siSolicitud_act		= 0;
	LET siInversiones 		= 0;
	LET iId_comp			= 0;
	LET iCifras_Obt1		= 0;
	LET iCifras_Obt2		= 0;
	
	--SET DEBUG FILE TO '/informix/sp_obtienecifrasdeclientesduplicados.out';
	--TRACE ON;
	
    BEGIN
    	ON EXCEPTION SET iErrorBD
			LET cCodret = iErrorBD;
			ROLLBACK WORK;
			RETURN cCodret;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		SELECT COUNT (*)
		INTO iTotalRegistros
        FROM bdinteg:"informix".si_bitctedup
		WHERE procesado = 'f';
		
			--Valida si hay registros de cliente_uno pendientes de procesar
		IF iTotalRegistros > 0 THEN
			-- Inicia la busqueda de cifras de los clientes identificados como numcte_uno 
			FOREACH WITH HOLD 								
				SELECT {+INDEX(bdinteg:"informix".si_bitctedup idx_si_bitctedup_01)} LIMIT iPOR_PROCESAR id_comp, numcte_uno, numcte_dos, cifras_obtenidas_uno, cifras_obtenidas_dos
				INTO iId_comp, cNumcte_uno, cNumcte_dos, iCifras_Obt1, iCifras_Obt2
				FROM bdinteg:"informix".si_bitctedup
				WHERE procesado = 'f'
				--WHERE cifras_obtenidas_uno = 0 OR cifras_obtenidas_dos = 0
				
				IF iContadorCtes = 0 THEN
					BEGIN WORK;		
				END IF;	
				
				IF iCifras_Obt1 = 0 THEN
					SELECT NVL (tipo_cliente, '0'), NVL (sexo,'')
					INTO cTipocte, cSexo
					FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
					WHERE a.numcte = b.numcte
					AND a.numcte = cNumcte_uno;
						
					-- Valida que el cliente sea titular para buscar informacion relacionda a sus productos
					IF cTipocte = '1' THEN   
						--Obtiene la cantidad de cuentas de captacion activas e inactivas del cliente					
						SELECT COUNT(status_cta)
						INTO siCtas_cap
						FROM bdicheq:"informix".sc_maechq
						WHERE num_cte = cNumcte_uno
						AND status_cta <> 2 
						AND status_cta <> 7;

						--Obtiene la cantidad de creditos activos e inactivos del cliente
						--IFRS Se contemplan los nuevos estatus de crÃ©dito por etapas
						SELECT COUNT(status_cred)
						INTO siCreditos
						FROM bdicred:"informix".sd_maecred
						WHERE numcte = cNumcte_uno
						AND status_cred IN ('AA', 'BA','BT','E1','E2','E3');
						--AND status_cred IN ('AA', 'BA','BT');
						
						--Si no tiene creditos activos validara si tiene solicitudes de credito activas
						IF siCreditos = 0 THEN 					
							SELECT COUNT(status_solicitud) 
							INTO siSolicitud_act
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = cNumcte_uno
							AND status_solicitud NOT IN('RT', 'CM', 'AT', 'AN');
						END IF;
						
						--Obtiene la cantidad de inversiones activas e inactivas del cliente
						SELECT COUNT(status_cta)
						INTO siInversiones
						FROM bdinvers:"informix".sv_maeinv
						WHERE num_cte = cNumcte_uno
						AND status_cta <> 2;						
					END IF;
				
					--Actualiza las cifras del cliente uno
					UPDATE bdinteg:"informix".si_bitctedup 
					SET tipo_cliente_uno = cTipocte, sexo_uno = cSexo, ctas_cap_uno = siCtas_cap, creditos_uno = siCreditos, 
						solicitudes_act_uno = siSolicitud_act, inversiones_uno = siInversiones, cifras_obtenidas_uno = 1, 
						fecha_cifras_uno = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE numcte_uno = cNumcte_uno AND procesado = 'f';
				
					--Actualiza las cifras del cliente dos, si el cliente uno existe como cliente dos
					UPDATE bdinteg:"informix".si_bitctedup 
					SET tipo_cliente_dos = cTipocte, sexo_dos = cSexo, ctas_cap_dos = siCtas_cap, creditos_dos = siCreditos,
						solicitudes_act_dos = siSolicitud_act, inversiones_dos = siInversiones, cifras_obtenidas_dos = 1, 
						fecha_cifras_dos = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE numcte_dos = cNumcte_uno AND procesado = 'f';
					
					LET iCifras_Obt1 = 1;
					
					/*IF iCifras_Obt2 = 0 THEN 
						SELECT NVL (tipo_cliente, '0'), sexo
						INTO cTipocte, cSexo
						FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
						WHERE a.numcte = b.numcte
						AND a.numcte = cNumcte_dos;
					
						IF cTipocte = '1' THEN   
							--Obtiene la cantidad de cuentas de captacion activas e inactivas del cliente					
							SELECT COUNT(status_cta)
							INTO siCtas_cap
							FROM bdicheq:"informix".sc_maechq
							WHERE num_cte = cNumcte_dos
							AND status_cta <> 2 
							AND status_cta <> 7;

							--Obtiene la cantidad de creditos activos e inactivos del cliente
							SELECT COUNT(status_cred)
							INTO siCreditos
							FROM bdicred:"informix".sd_maecred
							WHERE numcte = cNumcte_dos
							AND status_cred IN ('AA', 'BA','BT');
							
							--Si no tiene creditos activos validara si tiene solicitudes de credito activas
							IF siCreditos = 0 THEN 					
								SELECT COUNT(status_solicitud) 
								INTO siSolicitud_act
								FROM bdisolic:"informix".ss_solicitudes
								WHERE numcte = cNumcte_dos
								AND status_solicitud NOT IN('RT', 'CM', 'AT', 'AN');
							END IF;
							
							--Obtiene la cantidad de inversiones activas e inactivas del cliente
							SELECT COUNT(status_cta)
							INTO siInversiones
							FROM bdinvers:"informix".sv_maeinv
							WHERE num_cte = cNumcte_dos
							AND status_cta <> 2;						
						END IF;
					
						UPDATE bdinteg:"informix".si_bitctedup 
						SET tipo_cliente_dos = cTipocte, sexo_dos = cSexo, ctas_cap_dos = siCtas_cap, creditos_dos = siCreditos,
							solicitudes_act_dos = siSolicitud_act, inversiones_dos = siInversiones, cifras_obtenidas_dos = 1, 
							fecha_cifras_dos = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
						WHERE numcte_dos = cNumcte_dos AND procesado = 'f';
					
						UPDATE bdinteg:"informix".si_bitctedup 
						SET tipo_cliente_uno = cTipocte, sexo_uno = cSexo, ctas_cap_uno = siCtas_cap, creditos_uno = siCreditos, 
							solicitudes_act_uno = siSolicitud_act, inversiones_uno = siInversiones, cifras_obtenidas_uno = 1, 
							fecha_cifras_uno = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
						WHERE numcte_uno = cNumcte_dos AND procesado = 'f';

						LET iCifras_Obt2 = 1;
					END IF;*/
				END IF;
				
				IF iCifras_Obt2 = 0 THEN 
					SELECT NVL (tipo_cliente, '0'), NVL (sexo,'')
					INTO cTipocte, cSexo
					FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
					WHERE a.numcte = b.numcte
					AND a.numcte = cNumcte_dos;
					
					
					IF cTipocte = '1' THEN   
						--Obtiene la cantidad de cuentas de captacion activas e inactivas del cliente					
						SELECT COUNT(status_cta)
						INTO siCtas_cap
						FROM bdicheq:"informix".sc_maechq
						WHERE num_cte = cNumcte_dos
						AND status_cta <> 2 
						AND status_cta <> 7;

						--Obtiene la cantidad de creditos activos e inactivos del cliente
						--IFRS Se contemplan los nuevos estatus de crÃ©dito por etapas
						SELECT COUNT(status_cred)
						INTO siCreditos
						FROM bdicred:"informix".sd_maecred
						WHERE numcte = cNumcte_dos
						AND status_cred IN ('AA', 'BA','BT','E1','E2','E3');
						--AND status_cred IN ('AA', 'BA','BT');
						
						--Si no tiene creditos activos validara si tiene solicitudes de credito activas
						IF siCreditos = 0 THEN 					
							SELECT COUNT(status_solicitud) 
							INTO siSolicitud_act
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = cNumcte_dos
							AND status_solicitud NOT IN('RT', 'CM', 'AT', 'AN');
						END IF;
						
						--Obtiene la cantidad de inversiones activas e inactivas del cliente
						SELECT COUNT(status_cta)
						INTO siInversiones
						FROM bdinvers:"informix".sv_maeinv
						WHERE num_cte = cNumcte_dos
						AND status_cta <> 2;						
					END IF;
				
					UPDATE bdinteg:"informix".si_bitctedup 
					SET tipo_cliente_dos = cTipocte, sexo_dos = cSexo, ctas_cap_dos = siCtas_cap, creditos_dos = siCreditos,
						solicitudes_act_dos = siSolicitud_act, inversiones_dos = siInversiones, cifras_obtenidas_dos = 1, 
						fecha_cifras_dos = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE numcte_dos = cNumcte_dos AND procesado = 'f';
					
					UPDATE bdinteg:"informix".si_bitctedup 
					SET tipo_cliente_uno = cTipocte, sexo_uno = cSexo, ctas_cap_uno = siCtas_cap, creditos_uno = siCreditos, 
						solicitudes_act_uno = siSolicitud_act, inversiones_uno = siInversiones, cifras_obtenidas_uno = 1, 
						fecha_cifras_uno = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE numcte_uno = cNumcte_dos AND procesado = 'f';

					LET iCifras_Obt2 = 1;
				END IF;
					
				IF (iCifras_Obt1 + iCifras_Obt2) = 2 THEN
					UPDATE si_bitctedup SET procesado = 't' WHERE id_comp = iId_comp;
				END IF;
				
				LET siCtas_cap = 0;
				LET siCreditos = 0;
				LET siSolicitud_act = 0;
				LET siInversiones = 0;
				LET cTipocte = '';
				LET cSexo = '';
				
				LET iContadorCtes = iContadorCtes + 1;
				
				IF (iContadorCtes >= iTAMANO_TRANSACCION) OR (iContadorCtes = iTotalRegistros) THEN
					LET iContadorCtes = 0;
					COMMIT WORK;
					UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_bitctedup;
				END IF;
			END FOREACH;
			
			IF iContadorCtes > 0 THEN
				COMMIT WORK;				
				LET iContadorCtes = 0;
			END IF;
		END IF;				
		
		RETURN  cCodret;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener cifras ',
'El proceso obtendrÃÂÃÂ¡ cifras en cuanto al total de productos (credito, captacion e inversiones)', 
'relacionados al cliente e identificar cuales de ellos se encuentran activos y/o inactivos. ', 
'De ahÃÂÃÂ­ poder determinar cuales podrian ser candidatos a fusiÃÂÃÂ³n automatica',
'FECHA : 25/Marzo/2014',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_pay_cuenta_his(pinicio DATE, pfin DATE)
RETURNING VARCHAR(10), varchar(255);


	DEFINE v_sqlc1        		VARCHAR(250);
	DEFINE v_sqlc2        		VARCHAR(250);
	DEFINE v_sqlc3        		VARCHAR(250);
	DEFINE v_sqlc4        		VARCHAR(250);
	DEFINE v_sqlc5        		VARCHAR(250);
	DEFINE v_sqlc6        		VARCHAR(250);
	DEFINE v_sqlc7        		VARCHAR(250);
	DEFINE v_sqlc8       		VARCHAR(250);
	DEFINE v_sqlc9        		VARCHAR(250);
	DEFINE v_sqlc10        		VARCHAR(250);
	
	
	DEFINE v_sqld1        		VARCHAR(250);
	DEFINE v_sqld2        		VARCHAR(250);
	DEFINE v_sqld3        		VARCHAR(250);
	DEFINE v_sqld4        		VARCHAR(250);
	DEFINE v_sqld5        		VARCHAR(250);
	DEFINE v_sqld6        		VARCHAR(250);
	DEFINE v_sqld7        		VARCHAR(250);
	DEFINE v_sqld8       		VARCHAR(250);
	DEFINE v_sqld9        		VARCHAR(250);
	DEFINE v_sqld10        		VARCHAR(250);
	
	DEFINE v_sql        		CHAR(250);
	
	
	
	
	DEFINE v_sql2        		CHAR(250);
	DEFINE v_comprime		    CHAR(200);
	DEFINE v_comprime2		    CHAR(200);
	
	DEFINE vcod_ret         	VARCHAR(10); 
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	CHAR(40);
	
	DEFINE vfechaini			CHAR(8);
	DEFINE vfechafin			CHAR(8);
	
	DEFINE vfini				CHAR(10);
	DEFINE vffin				CHAR(10);
	
	


--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' '||error_info;
			
           END IF;
       END EXCEPTION;   
	   

--set debug file to "/tmp/sp_pay_tarjeta_his.out";
--TRACE ON;		

	LET v_sql = ''; 
	
	LET v_sqlc1 = ''; 
	LET v_sqlc2 = ''; 
	LET v_sqlc3 = ''; 
	LET v_sqlc4 = ''; 
	LET v_sqlc5 = '';
	LET v_sqlc6 = ''; 
	LET v_sqlc7 = ''; 
	LET v_sqlc8 = ''; 
	LET v_sqlc9 = ''; 
	LET v_sqlc10 = '';
	
	LET v_sqld1 = ''; 
	LET v_sqld2 = ''; 
	LET v_sqld3 = ''; 
	LET v_sqld4 = ''; 
	LET v_sqld5 = '';
	LET v_sqld6 = ''; 
	LET v_sqld7 = ''; 
	LET v_sqld8 = ''; 
	LET v_sqld9 = ''; 
	LET v_sqld10 = '';
	

	LET v_comprime = '';
	LET v_comprime2 = '';

	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';	
	
	LET vfechaini = TO_CHAR(pinicio,'%Y%m%d') ;	
	LET vfechafin = TO_CHAR(pfin,'%Y%m%d');	
	
	LET vfini = TO_CHAR(pinicio,'%m-%d-%Y') ;	
	LET vffin = TO_CHAR(pfin,'%m-%d-%Y');
	
--info cuenta cheq
LET v_sqld1 = 'echo "SELECT  ''9914'' AS mti,'||
        'LPAD(TRIM(c.num_cte), 15, ''0'') AS num_cte,'||
        'CASE WHEN c.producto=''2000'' THEN ''D'''||
             ' ELSE ''D'''||
            ' END  AS tipo_prod,'||
        'LPAD(TRIM(c.cuenta), 15, ''0'') AS num_cta,'|| '"'||' > qryctacheq.sql'; 
		
LET v_sqld2 = 'echo "LPAD(c.status_cta, 5, 0) AS estado,'||
        ' ''484'' AS cod_moneda,'||
        'LPAD(0 , 15 , ''0'')  AS lim_cred,'||
        'LPAD( 0 , 15, ''0'') AS disponible,'||
        'TO_CHAR(NVL(n.fecha_alta,MDY(1,1,1900)),''%Y%m%d'') AS fecha_apertura,'|| '"'||' >> qryctacheq.sql'; 
		
LET v_sqld3 = 'echo "CASE WHEN c.status_cta = ''2'''||
                    ' THEN TO_CHAR(NVL(c.fecha_proceso,MDY(1,1,1900)),''%Y%m%d'')'||  
        ' ELSE TO_CHAR(MDY(1,1,1900),''%Y%m%d'')'||	
        ' END AS fecha_cierre,'||
		'c.producto AS prod,'||
		'n.fecha_alta AS fecha'|| '"'||' >> qryctacheq.sql'; 
		
LET v_sqld4 = 'echo " FROM bdicheq:sc_maechq c,'||
          'bdicheq:sc_maenoc n'||
	 ' WHERE c.status_cta <> ''4'''||
		' AND c.empresa = ''001'''|| 
		' AND n.empresa = c.empresa'||	
		' AND n.cuenta = c.cuenta'||
		' AND n.fecha_alta BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''|| '"'||' >> qryctacheq.sql'; 

	
	
	
LET v_sqld5 = 'echo "INTO temp his_info_cta_cheq WITH NO LOG;'|| 
			'SELECT LPAD(char_length(mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||'||
			'lim_cred||disponible||fecha_apertura||fecha_cierre),4,0)'||
			'||mti||num_cte'|| '"'||' >> qryctacheq.sql'; 
			
LET v_sqld6 = 'echo "||tipo_prod||num_cta||estado||cod_moneda||lim_cred||disponible||fecha_apertura||fecha_cierre AS trama'||
	  ' FROM his_info_cta_cheq'||
	  ' INTO temp his_cta_cheq WITH NO LOG;'|| '"'||' >> qryctacheq.sql'; 

	  
LET v_sqld7 = 'echo " UNLOAD TO ''cta_cheq_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  ' SELECT * FROM his_cta_cheq;'|| '"'||' >> qryctacheq.sql'; 
	  
	SYSTEM v_sqld1;
	SYSTEM v_sqld2;
	SYSTEM v_sqld3;
	SYSTEM v_sqld4;
	SYSTEM v_sqld5;
	SYSTEM v_sqld6;
	SYSTEM v_sqld7;
      LET v_sqld1 = "dbaccess bdipayt qryctacheq.sql";
    SYSTEM v_sqld1;  
	  
  
--Comprimir Archivo 		
SYSTEM v_comprime;
      LET v_comprime = "gzip -9 'cta_cheq_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime;


--info cuenta cred

    --para activos
	LET v_sqlc1 = 'echo "SELECT  ''9914'' AS mti,'||
		'LPAD(TRIM(c.numcte), 15, ''0'') AS num_cte,'||
		'CASE WHEN c.num_producto = ''6001'' THEN ''C'''|| 
             ' ELSE ''C'''||
          ' END AS tipo_prod,'||
        'LPAD(TRIM(c.num_credito), 15, ''0'') AS num_cta,'|| '"'||' > qryctacred.sql';
		--IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas
	LET v_sqlc2 = 'echo "CASE WHEN c.id_unidad_prod IS NOT NULL THEN ''00003'''||' >> qryctacred.sql';

			--' WHEN c.status_cred = ''AA'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''||
            --' WHEN c.status_cred = ''BA'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''|| '"'||' >> qryctacred.sql';
			 
--	LET v_sqlc3 = 'echo " WHEN c.status_cred = ''BT'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''||
	LET v_sqlc3 = 'echo " ELSE ''00001'''||
          ' END AS estado,'|| 
        '''484'' AS cod_moneda,'||
        'LPAD(REPLACE(CAST(NVL(m.monto_otorgado,0) AS DECIMAL(13,2)),''.'','''') ,15,0) AS lim_cred,'|| '"'||' >> qryctacred.sql';
		
	LET v_sqlc4 = 'echo "CASE WHEN (m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido) < 0'||
             ' THEN  ''-''||LPAD(REPLACE((REPLACE(CAST(NVL((m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido),0) AS DECIMAL(13,2)),''.'',''''))'||
			 ',''-'',''''),14,0)'|| '"'||' >> qryctacred.sql';  
			 
	LET v_sqlc5 = 'echo " ELSE LPAD(REPLACE(CAST(NVL((m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido),0) AS DECIMAL(13,2)),''.'','''') ,15,0)'|| 
          ' END AS disponible,'|| 
        'TO_CHAR(NVL(c.fecha_apertura,MDY(1,1,1900)),''%Y%m%d'') AS fecha_apertura,'|| '"'||' >> qryctacred.sql';
		
	LET v_sqlc6 = 'echo "TO_CHAR(MDY(1,1,1900),''%Y%m%d'') AS fecha_cierre,'||
		'c.num_producto AS prod,'||
		'c.fecha_apertura AS fecha'||
	 ' FROM bdicred:sd_maecred c,'||
          'bdicred:sd_maesdos m'|| '"'||' >> qryctacred.sql';
	--IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas	  
	LET v_sqlc7 = 'echo " WHERE c.empresa = ''001'''|| 
        ' AND c.num_credito = m.num_credito'|| 
		' AND c.status_cred IN (''AA'', ''BA'', ''BT'',''E1'', ''E2'', ''E3'')'||
       --' AND c.status_cred IN (''AA'', ''BA'', ''BT'')'||
		' AND c.fecha_apertura BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''|| 
		' INTO temp his_info_cta_cred_act WITH NO LOG;'||'"'||' >> qryctacred.sql';
		
	LET v_sqlc8 = 'echo " SELECT LPAD(char_length(mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||'||
					'lim_cred||disponible||fecha_apertura||fecha_cierre),4,0)'||
					'||mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||lim_cred||disponible||'||'"'||' >> qryctacred.sql';
			
	LET v_sqlc9 = 'echo "fecha_apertura||fecha_cierre AS trama'||
					' FROM his_info_cta_cred_act'||
					' INTO temp his_cta_cred WITH NO LOG;'||
		' UNLOAD TO ''cta_cred_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  ' SELECT * FROM his_cta_cred;'|| '"'||' >> qryctacred.sql'; 
	

	
	SYSTEM v_sqlc1;
	SYSTEM v_sqlc2;
	SYSTEM v_sqlc3;
	SYSTEM v_sqlc4;
	SYSTEM v_sqlc5;
	SYSTEM v_sqlc6;
	SYSTEM v_sqlc7;
	SYSTEM v_sqlc8;
	SYSTEM v_sqlc9;
      LET v_sqlc1 = "dbaccess bdipayt qryctacred.sql";
    SYSTEM v_sqlc1;
	
	--Comprimir Archivo 		
SYSTEM v_comprime2;
      LET v_comprime2 = "gzip -9 'cta_cred_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime2;
		
    RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;