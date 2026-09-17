CREATE PROCEDURE "informix".sp_guardasituacionespecialcte(pTrama CHAR(5000))

	RETURNING CHAR (5) AS rCodRet;

	---------------------DECLARACION DE VARIABLES----------------------------------------
	DEFINE cEmpresa							CHAR(3);
	DEFINE dFecha							DATE;
	DEFINE dHora							DATETIME HOUR TO FRACTION(3);
	DEFINE iSqlErr							INTEGER;
	DEFINE cCodRet							CHAR(5);
	DEFINE sSec								SMALLINT;
    DEFINE sSec1							SMALLINT;
    DEFINE sSecN							SMALLINT;
    DEFINE sBanSec							SMALLINT;
    DEFINE sBandCons1						SMALLINT;
	DEFINE cTramaEntrada                    LVARCHAR(5000);
	DEFINE iPosicion                        INTEGER;
	DEFINE iPosicionTotal                   INTEGER;
	DEFINE sPosicionAnt                     SMALLINT;
	DEFINE cCteCoppel                       CHAR(20);
	DEFINE cCteBcpl                         CHAR(20);
	DEFINE iError                           SMALLINT;             
	DEFINE i                                SMALLINT;        
	DEFINE cTrama2                          LVARCHAR(5000);       
	DEFINE cIdu_tiposituacion	            CHAR(1);
	DEFINE iIdu_situacion					INTEGER;
	DEFINE iId_motivo						INTEGER;
	DEFINE iId_persona						INTEGER;
	DEFINE cDes_cuentas						CHAR(50);
	DEFINE cStatus							CHAR(1);
	DEFINE cMensaje							CHAR(120);         
	DEFINE sSesion                          SMALLINT;     
	DEFINE iRegistro                        SMALLINT;      
	DEFINE sBand                            SMALLINT;   
	DEFINE iStatusEnvio						INTEGER;
	DEFINE cSucursal						CHAR(4);
	DEFINE iStatusEnvio2					INTEGER;
    DEFINE iSituacion                       INTEGER;
    DEFINE iHSecuencia                      SMALLINT;
    DEFINE vempresah                        CHAR(3);
    DEFINE vsucursalh                       CHAR(4);
    DEFINE vclienteh                        CHAR(20);
    DEFINE vnum_cteh                        CHAR(20);
    DEFINE vsecuenciah                      SMALLINT;
    DEFINE vid_tiposituacionh               CHAR(1);
    DEFINE vidu_situacionh                  INTEGER;
    DEFINE vid_motivoh                      INTEGER;
    DEFINE vid_personah                     INTEGER;
    DEFINE vdes_cuentash                    CHAR(50);
    DEFINE vstatush                         CHAR(1);
    DEFINE vmensajeh                        CHAR(120);
    DEFINE vfechah                          DATE;
    DEFINE vhorah                           DATETIME HOUR TO FRACTION(3);
    DEFINE verrorh                          INTEGER;
    DEFINE vstatusenvioh                    INTEGER;

	----------------INICIALIZA DE VARIABLES------------------------------------------------
	LET cCodRet						=		'00001';
	LET iSqlErr						=		0;
	LET cEmpresa					=		'001';
	LET dFecha						=		'';
	LET dHora						= 		'';
	LET sSec						= 		0;
    LET sSecN						= 		0;
    LET sBanSec						= 		0;
	LET sBandCons1                  =       0;
	LET cTramaEntrada               =       '';
	LET iPosicion                   =       0;
	LET sPosicionAnt                =       0;
	LET cCteCoppel                  =       '';
	LET cCteBcpl                    =       '';
	LET iError                      =       0;   
	LET i                           =       0;
	LET iPosicionTotal              =       0;
	LET cTrama2                     =       '';
	LET cIdu_tiposituacion	        =  		'';
	LET iIdu_situacion				=		0;
	LET iId_motivo					=		0;
	LET iId_persona					=		0;
	LET cDes_cuentas				=		'';
	LET cStatus						=		'';
	LET cMensaje					=		'';
	LET sSesion                     =       0;
	LET iRegistro                   =       0;
	LET sBand                       =       0;
	LET iStatusEnvio				=		0;
	LET cSucursal 					= 		'';
	LET iStatusEnvio2				=		0;
    LET iSituacion                  =       0;
    LET sSec1                       =       0;
    LET iHSecuencia                 =       0;
    LET vempresah                   =       '';
    LET vsucursalh                  =       '';
    LET vclienteh                   =       '';
    LET vnum_cteh                   =       '';
    LET vsecuenciah                 =       0;
    LET vid_tiposituacionh          =       '';
    LET vidu_situacionh             =       0;
    LET vid_motivoh                 =       0;
    LET vid_personah                =       0;
    LET vdes_cuentash               =       '';
    LET vstatush                    =       '';
    LET vmensajeh                   =       '';
    LET vfechah                     =       '';
    LET vhorah                      =       '';
    LET verrorh                     =       0;
    LET vstatusenvioh               =       0;
	
	--SET DEBUG FILE TO '/informix/Cony/bitacorasSE/sp_guardasituacionespecialcte.out';
	--TRACE ON;

	BEGIN 

		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET dFecha = CURRENT::DATE;
		LET dHora = CURRENT;	
		LET cTramaEntrada = pTrama;
		LET cTramaEntrada = SUBSTR(cTramaEntrada,1,LENGTH(cTramaEntrada));

		IF NVL(cTramaEntrada,"") <> "" THEN

			FOREACH
				EXECUTE PROCEDURE bdinteg: "informix".sp_obtenerposicion_sitesp (cTramaEntrada,"|")
				INTO iPosicion, iPosicionTotal

				IF i = 0 THEN
					LET cCteCoppel = SUBSTR(cTramaEntrada,1,iPosicion - 1);
					LET sPosicionAnt = iPosicion + 1;
				ELIF i = 1 THEN
					LET cCteBcpl = SUBSTR(cTramaEntrada,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
				ELIF i = 2 THEN
					LET iError = SUBSTR(cTramaEntrada,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
					LET cTrama2 = SUBSTR(cTramaEntrada,sPosicionAnt,LENGTH(cTramaEntrada));
				ELIF i = 3 THEN
					LET iStatusEnvio = SUBSTR(cTramaEntrada,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
					LET cTrama2 = SUBSTR(cTramaEntrada,sPosicionAnt,LENGTH(cTramaEntrada));
				ELIF i = 4 THEN
					LET cSucursal = SUBSTR(cTramaEntrada,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
					LET cTrama2 = SUBSTR(cTramaEntrada,sPosicionAnt,LENGTH(cTramaEntrada));
					EXIT FOREACH;
				END IF;
				LET i = i + 1;
			END FOREACH;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				Let cCodRet = '00003'; -- No se encontraron registros
				RETURN cCodRet;
			END IF;
		
			
			 SELECT secuencia, NVL(statusenvio, 0) 
			 INTO sSec,iStatusEnvio2 -- Secuencia dentro de la tabla 
			 FROM "informix".ss_situaciones_especiales_cliente
			 WHERE cliente = cCteCoppel GROUP BY secuencia, statusenvio;		
			
			IF NVL(sSec,0) = 0 THEN 
                LET sSec = 0;
			END IF;     
			
			LET sSecN = sSec +1; --Nueva secuencia

			IF sSec>0  AND iStatusEnvio = 0  THEN	
               
				IF iStatusEnvio2 = 0 THEN 
					UPDATE "informix".ss_situaciones_especiales_cliente
					SET  fecha = CURRENT::DATE, hora = CURRENT
					WHERE cliente = cCteCoppel AND secuencia = sSec; 
				ELSE 
					--se insertan todos los registros encontrados en la tabla historica 			
					--INSERT INTO "informix".ss_historica_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion, idu_situacion, id_motivo, id_persona, des_cuentas, status, mensaje, fecha, hora, error, statusenvio)
					SELECT empresa, sucursal, cliente, num_cte, NVL(secuencia,0), idu_tiposituacion, idu_situacion, id_motivo, id_persona, des_cuentas, status, mensaje, fecha, hora, error,statusenvio			
					INTO vempresah, vsucursalh, vclienteh, vnum_cteh, vsecuenciah, vid_tiposituacionh, vidu_situacionh, vid_motivoh, vid_personah, vdes_cuentash, vstatush, vmensajeh, vfechah, vhorah, verrorh, vstatusenvioh
                    FROM "informix".ss_situaciones_especiales_cliente
					WHERE cliente = cCteCoppel AND secuencia = sSec;	

                    INSERT INTO "informix".ss_historica_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion, idu_situacion, id_motivo, id_persona, des_cuentas, status, mensaje, fecha, hora, error, statusenvio)
					VALUES(vempresah, vsucursalh, vclienteh, vnum_cteh, vsecuenciah, vid_tiposituacionh, vidu_situacionh, vid_motivoh, vid_personah, vdes_cuentash, vstatush, vmensajeh, vfechah, vhorah, verrorh, vstatusenvioh);
					--se  borran todos los registros encontrados en la tabla ss_situaciones_especiales_cliente	
                    
					DELETE
					FROM "informix".ss_situaciones_especiales_cliente
					WHERE cliente = cCteCoppel AND secuencia = sSec;
                    LET sBanSec=1;
				END IF;
			END IF;

			LET sPosicionAnt = 1;
		
			FOREACH
				EXECUTE PROCEDURE bdinteg: "informix".sp_obtenerposicion_sitesp (cTrama2,"|")
				INTO iPosicion, iPosicionTotal

				IF iRegistro = 0 THEN
					IF sBand = 1 THEN
						LET cIdu_tiposituacion = SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);   
						LET sBand = 0;
					ELSE
						LET cIdu_tiposituacion = SUBSTR(cTrama2,sPosicionAnt,sPosicionAnt);    
					END IF;
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 1 THEN
					LET iIdu_situacion = SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);	
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 2 THEN
					LET iId_motivo = SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 3 THEN
					LET iId_persona	= SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 4 THEN
					LET cDes_cuentas = SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 5 THEN
					LET cStatus	= SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;
				ELIF iRegistro = 6 THEN
					LET cMensaje = SUBSTR(cTrama2,sPosicionAnt,iPosicion - sPosicionAnt);
					LET sPosicionAnt = iPosicion + 1;	
				END IF;

				IF iRegistro = 6 THEN
					LET sBand = 1;
					LET iRegistro = 0;
					LET sSesion = sSesion + 1;
					IF iStatusEnvio = 2 THEN 
						UPDATE "informix".ss_situaciones_especiales_cliente
						SET status = cStatus, mensaje = cMensaje, fecha = CURRENT::DATE, hora = CURRENT, error = iError, statusenvio = iStatusEnvio
						WHERE cliente = cCteCoppel AND secuencia = sSec; 
					ELSE	 
                            IF sSec=1 OR sSec=0 THEN
                                 SELECT idu_situacion
                                 INTO iSituacion -- Secuencia dentro de la tabla 
                                 FROM "informix".ss_situaciones_especiales_cliente
                                 WHERE cliente = cCteCoppel  GROUP BY idu_situacion;
                                 
                                -- LET sBanSec=1;
                                SELECT Secuencia
                                 INTO iHSecuencia -- Secuencia dentro de la tabla historica 
                                 FROM "informix".ss_historica_situaciones_especiales_cliente
                                 WHERE cliente = cCteCoppel  GROUP BY secuencia;
                                 LET sSec1=sSec;
                                -- LET sBanSec=1;
                                 
                             END IF;

                            DELETE 
                            FROM "informix".ss_situaciones_especiales_cliente
                            WHERE cliente = cCteCoppel AND secuencia = sSec;

                            IF (sSec1=0 OR sSec1=1) THEN
                                IF NVL(iSituacion,'')='' and  NVL(iHSecuencia,0)=0 THEN
                                    LET sBanSec=2;
                                    IF sSec1=0 THEN
                                        LET sSec1=sSec1+1;
                                    END IF;
                                END IF;
                            END IF;
                            
                            IF sSec1 =1  AND NVL(iSituacion,'')='' and  NVL(iHSecuencia,0)=0 THEN
                                    INSERT INTO "informix".ss_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion,  idu_situacion,  id_motivo, id_persona, des_cuentas, status,  mensaje, fecha,  hora,	error, statusenvio)
                                    VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), NVL(sSec1,0), NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                            ELIF sSec1 =0  AND NVL(iSituacion,'')='' and  NVL(iHSecuencia,0)=0 THEN
                                    INSERT INTO "informix".ss_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion,  idu_situacion,  id_motivo, id_persona, des_cuentas, status,  mensaje, fecha,  hora,	error, statusenvio)
                                    VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), NVL(sSec1,0), NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                            ELSE     
                                IF sBanSec=1 THEN                                   
                                        INSERT INTO "informix".ss_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion,  idu_situacion,  id_motivo, id_persona, des_cuentas, status,  mensaje, fecha,  hora,	error, statusenvio)
                                        --VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), 8, NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                                        VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), NVL(sSec,0), NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                                ELIF sBanSec=2 THEN                             
                                        INSERT INTO "informix".ss_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion,  idu_situacion,  id_motivo, id_persona, des_cuentas, status,  mensaje, fecha,  hora,	error, statusenvio)
                                        --VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), 8, NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                                        VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')),NVL(sSec1,0), NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                                ELSE
                                                                 
                                        INSERT INTO "informix".ss_situaciones_especiales_cliente(empresa, sucursal, cliente, num_cte, secuencia, idu_tiposituacion,  idu_situacion,  id_motivo, id_persona, des_cuentas, status,  mensaje, fecha,  hora,	error, statusenvio)
                                        VALUES (cEmpresa, NVL(cSucursal, ''), TRIM(NVL(cCteCoppel,'')), TRIM(NVL(cCteBcpl,'')), NVL(sSecN,0), NVL(cIdu_tiposituacion, ''), NVL(iIdu_situacion,''),  NVL(iId_motivo, ''), NVL(iId_persona,''), NVL( cDes_cuentas, ''), NVL(cStatus, ''), NVL(cMensaje,''), dFecha, dHora, iError,NVL(iStatusEnvio,0));			
                           
                                END IF;
                            END IF;
                    END IF;
				ELSE
					LET iRegistro = iRegistro + 1;
				END IF;			
			END FOREACH;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				Let cCodRet = '00003'; -- No se encontraron registros
			ELSE
				LET cCodRet = '00000';
			END IF;		
		END IF;

		RETURN cCodRet;	
		
	END	
END PROCEDURE
