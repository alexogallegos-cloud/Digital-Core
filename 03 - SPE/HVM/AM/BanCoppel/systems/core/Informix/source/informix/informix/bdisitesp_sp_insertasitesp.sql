CREATE PROCEDURE "informix".sp_insertasitesp(pTipo INTEGER,
											pEmpresa CHAR(3),
											pNumCte CHAR(20),
											pSituacion CHAR(1),
											pCausa SMALLINT,
											pTipoMovto CHAR(1), 
											pCveSitEspOrigen CHAR(12),
											pSucursal CHAR(4), 
											pEmpleadoEfectuo CHAR(8), 
											pNombreEfectuo CHAR(40),
											pUsrModifica CHAR(9),
											pMsjModifica CHAR(100)) 											
											
RETURNING CHAR(5)  AS cCodRet,     
		  SMALLINT AS sPonderacion,
		  CHAR(1)  AS Situacion,
		  SMALLINT AS Causa;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE sPonderacion		SMALLINT;
DEFINE sPonderacionAct	SMALLINT;
DEFINE iSqlErr 			INTEGER;
DEFINE sNumCte			CHAR(20);
DEFINE cSituacionCte 	CHAR(1);
DEFINE sCausaCte 		SMALLINT;
DEFINE iIdMvto 			INTEGER;
DEFINE iIdMvtoHis		INTEGER;
DEFINE cSituacionAct 	CHAR(1);
DEFINE sCausaAct 		SMALLINT;
DEFINE cResultado 		CHAR(50);
DEFINE cCveSitEspOrigen CHAR(12);
DEFINE cSucursal        CHAR(4);
DEFINE cEmpleadoEfectuo CHAR(8);
DEFINE cfchalta			DATETIME year to second;
DEFINE cUsrModifica     char(9);
DEFINE cfchmodifica     DATETIME year to second;
DEFINE cNumCteAct      CHAR(20); 

--Inicializacion de Variables
LET cCodRet    		= '00000';
LET sPonderacion 	= "0";
LET sPonderacionAct = "0";
LET iSqlErr 		= 0;
LET sNumCte 		= "";
LET cSituacionCte 	="";
LET sCausaCte 		= 0;
LET iIdMvto 		= 0;
LET cSituacionAct 	= "";
LET sCausaAct 		= 0;
LET iIdMvtoHis 		= 0;
LET cResultado		= '';
LET cCveSitEspOrigen ='';
LET cSucursal        ='';
LET cEmpleadoEfectuo ='';
LET cfchalta		 ='';
LET cUsrModifica     ='';
LET cfchmodifica     ='';
LET cNumCteAct       ='';

--SET DEBUG FILE TO '/tmp/cristo/sp_insertasitesp.sql';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,sPonderacion,cSituacionCte,sCausaCte;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT MAX(idmovto)+1
		INTO iIdMvto
	FROM bdisitesp:"informix".se_ctessitespcte;
	
	SELECT MAX(idmovto)+1
		INTO iIdMvtoHis
	FROM bdisitesp:"informix".se_ctessitespcte_his;
		
	
		IF 	pTipo = 1 THEN	
			IF  ((pTipo IS NULL OR pTipo = 0) 
				OR	(pNumCte IS NULL OR pNumCte = '') 
				OR (pSituacion IS NULL OR pSituacion = '') 
				OR (pCausa IS NULL OR pCausa = '') 
				OR (pEmpresa IS NULL OR pEmpresa = '') 
				OR (pTipoMovto IS NULL OR pTipoMovto = '') 
				OR (pCveSitEspOrigen IS NULL OR pCveSitEspOrigen = '')
				OR (pSucursal IS NULL OR pSucursal = '') 
				OR (pEmpleadoEfectuo IS NULL OR pEmpleadoEfectuo = '')
				OR (pNombreEfectuo IS NULL OR pNombreEfectuo = '')) THEN
				LET cCodRet = '00001'; 
			ELSE
								
				IF pCveSitEspOrigen = 'S' THEN
					LET pCveSitEspOrigen = '5';
				END IF;
				
				IF pSituacion='P' AND pCausa='109' THEN
					FOREACH
						SELECT limit 1 resultado INTO cResultado
						FROM bdinteg:"informix".si_bitacora_ife
						WHERE numcte=pNumCte AND fecha >= TODAY 
						ORDER BY fecha DESC
					END FOREACH;
					
					IF Trim(NVL(cResultado,''))<>'Falso' THEN
						RETURN cCodRet, sPonderacion,cSituacionCte,sCausaCte;
					END IF;
					
				END IF;
				
				
                IF EXISTS (SELECT * FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte) THEN
                    SELECT ponderacion INTO sPonderacion 
                     FROM bdisitesp:"informix".se_catsitesp  
                      WHERE situacion = pSituacion AND causa = pCausa;
                   
                    SELECT ponderacion INTO sPonderacionAct 
                     FROM bdisitesp:"informix".se_catsitesp a inner join bdisitesp:"informix".se_ctessitespcte b
                        on a.situacion=b.situacion and a.causa=b.causa 
                      WHERE b.numcte=pNumCte;


                   IF (sPonderacion<=sPonderacionAct) OR (sPonderacionAct = 0) THEN
                       INSERT INTO se_ctessitespcte_his
                       SELECT iIdMvtoHis, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
                        FROM bdisitesp:se_ctessitespcte
                         WHERE numcte=pNumCte
						 and causa not in (61,62);

                        DELETE FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte;

                        INSERT INTO bdisitesp:"informix".se_ctessitespcte
                            (idmovto,empresa,numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo,
                            fechamovto, usralta, fchalta,usrmodifica,fchmodifica,motivo_desmarcaje )							
                        VALUES (iIdMvto,pEmpresa,pNumCte, pSituacion, pCausa, pCveSitEspOrigen, pSucursal,pTipoMovto,
                            pEmpleadoEfectuo,pNombreEfectuo, CURRENT, pEmpleadoEfectuo, CURRENT,'','','');
                   
				   ELIF pCausa not in (61,62) THEN
		
                        INSERT INTO se_ctessitespcte_his(idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, 
                                    sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
                        VALUES(iIdMvtoHis, pTipoMovto, pNumCte, pEmpresa, pSituacion, pCausa, pCveSitEspOrigen, 
                                    pSucursal, pEmpleadoEfectuo, '', CURRENT, '', CURRENT);
                   END IF;

                ELSE
                    INSERT INTO bdisitesp:"informix".se_ctessitespcte
                    (idmovto,empresa,numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo,
                    fechamovto, usralta, fchalta,usrmodifica,fchmodifica,motivo_desmarcaje )							
                    VALUES (iIdMvto,pEmpresa,pNumCte, pSituacion, pCausa, pCveSitEspOrigen, pSucursal,pTipoMovto,
                    pEmpleadoEfectuo,pNombreEfectuo, CURRENT, pEmpleadoEfectuo, CURRENT,'','','');
                END IF;
                
				SELECT a.situacion, a.causa, b.ponderacion
				INTO cSituacionCte, sCausaCte, sPonderacion
				FROM bdisitesp:se_ctessitespcte a, bdisitesp:se_catsitesp b
				WHERE a.numcte = pNumCte
				AND a.situacion = b.situacion
				AND a.causa = b.causa;
				
			END IF;
		ELIF pTipo = 2 THEN
			IF ((pSituacion IS NULL OR pSituacion = '')
					OR (pCausa IS NULL OR pCausa = '')
					OR (pEmpleadoEfectuo IS NULL OR pEmpleadoEfectuo = '')) THEN
					LET cCodRet = '00001';
			ELSE 
			
					SELECT numcte 
					INTO sNumCte 
					FROM bdisitesp:"informix".se_ctessitespcte 
					WHERE numcte = pNumCte;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCodRet = '00003';
					ELSE

                        SELECT ponderacion INTO sPonderacion 
                         FROM bdisitesp:"informix".se_catsitesp  
                          WHERE situacion = pSituacion AND causa = pCausa;

                        SELECT a.ponderacion, b.situacion, b.causa INTO sPonderacionAct, cSituacionAct, sCausaAct 
                         FROM bdisitesp:"informix".se_catsitesp a INNER JOIN bdisitesp:"informix".se_ctessitespcte b
                            ON a.situacion=b.situacion AND a.causa=b.causa 
                          WHERE b.numcte=pNumCte;
						  
                        IF sPonderacion<=sPonderacionAct OR sPonderacionAct='0' OR (cSituacionAct = 'U' AND sCausaAct = 61 AND pSituacion = 'U' AND pCausa = 65) THEN
                           
						   INSERT INTO se_ctessitespcte_his
							 SELECT iIdMvtoHis, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
							   FROM bdisitesp:se_ctessitespcte
								WHERE numcte=pNumCte
								and causa not in (61,62);

                            UPDATE bdisitesp:"informix".se_ctessitespcte 
                            SET situacion = pSituacion, causa = pCausa, usrmodifica = pEmpleadoEfectuo, fchmodifica = CURRENT
                            WHERE numcte = pNumCte;
							
						ELIF pCausa not in (61,62) THEN
					
							 INSERT INTO se_ctessitespcte_his(idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, 
                                    sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
							 VALUES(iIdMvtoHis, pTipoMovto, pNumCte, pEmpresa, pSituacion, pCausa, pCveSitEspOrigen, 
                                    pSucursal, pEmpleadoEfectuo, '', CURRENT, '', CURRENT);
						
                        END IF;   

						
					END IF;	
			END IF;	
		ELIF pTipo = 3 THEN
			SELECT ponderacion 
			INTO sPonderacion 
			FROM bdisitesp:"informix".se_catsitesp  
			WHERE situacion = pSituacion 
			AND causa = pCausa; 
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00005';
			END IF;		
			
		ELIF pTipo = 4 THEN
			SELECT situacion,causa 
			INTO cSituacionCte,sCausaCte
			FROM bdisitesp:"informix".se_ctessitespcte 
			WHERE numcte = pNumCte;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cSituacionCte = '';
				LET sCausaCte = 0;
			END IF;	
	
		ELIF pTipo = 5 THEN
		
			SELECT numcte INTO cNumCteAct FROM bdisitesp:se_ctessitespcte WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;
			
			IF NVL(cNumCteAct,'')= pNumCte THEN 
				SELECT limit 1 his.situacion,his.causa,cat.ponderacion,his.cvesitesporigen,his.sucursal,his.empleadoefectuo,his.fchalta,his.usrmodifica,his.fchmodifica
				INTO cSituacionCte,sCausaCte,sPonderacion,cCveSitEspOrigen,cSucursal,cEmpleadoEfectuo,cfchalta,cUsrModifica,cfchmodifica
				FROM bdisitesp:se_ctessitespcte_his as his, bdisitesp:se_catsitesp cat
				WHERE his.numcte=pNumCte and his.causa not in (61,62)
				and his.situacion=cat.situacion and his.causa=cat.causa and his.situacion <> pSituacion and his.causa <> pCausa;				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					DELETE FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;	
					DELETE FROM bdisitesp:"informix".se_ctessitespcte_his WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;
					LET cSituacionCte ='';
					LET sCausaCte = 0;
					LET sPonderacion ='0';
				ELSE
					UPDATE bdisitesp:"informix".se_ctessitespcte 
					SET situacion = cSituacionCte, causa = sCausaCte, cvesitesporigen = cCveSitEspOrigen, sucursal = cSucursal,empleadoefectuo=cEmpleadoEfectuo,fchalta=cfchalta,usrmodifica=cUsrModifica,fchmodifica = cfchmodifica
					WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;
												
					IF dbinfo("sqlca.sqlerrd2") > 0 THEN 
						DELETE FROM bdisitesp:"informix".se_ctessitespcte_his WHERE numcte = pNumCte and situacion = cSituacionCte and causa = sCausaCte;
					END IF;	
				END IF;					
			ELSE
				LET cSituacionCte ='';
				LET sCausaCte = 0;
				LET sPonderacion ='0';
			END IF;
			
			
			
		ELSE
			LET cCodRet = '00004';
		END IF;
	
		
	RETURN cCodRet, sPonderacion,cSituacionCte,sCausaCte;
END;

END PROCEDURE
