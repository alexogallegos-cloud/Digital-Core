CREATE PROCEDURE "informix".sp_sw_ro_consrepoficon(pUsuario CHAR(8), pIdFunciON CHAR(10), pFchInicio CHAR(10),pFchFin CHAR(10),  
										pRegistros INT, pRecuperaciON INT)
	RETURNING   CHAR(5) AS cCodRet,
				CHAR(8) AS  UserINSERT,
				CHAR(45) AS  NombreUser,
				CHAR(10) AS  FchOficio, 
				CHAR(10) AS  FchRecep, 
				CHAR(60) AS  Oficio,
				CHAR(60) AS  Expediente,
				INTEGER AS PerLoca,
				INTEGER AS PerHomo,
				INTEGER AS PerNoLo
	DEFINE cCodRet	   CHAR(5);
	DEFINE iSqlErr 	   INT;
	DEFINE cUsuariosIn CHAR(8);
	DEFINE iOficios   INTEGER;
	DEFINE iPerLoca   INTEGER;
	DEFINE iPerHomo   INTEGER;
	DEFINE iPerNoLo   INTEGER;
    DEFINE cStatusAux CHAR(1);
    DEFINE cStatusAux2 CHAR(1);
    DEFINE cStatusAux0 CHAR(1);
	DEFINE cStatusAux3 CHAR(1);
	DEFINE cNombreUser CHAR(45);
	DEFINE cfchOficio  CHAR(10); 
	DEFINE cfchRecep   CHAR(10); 
	DEFINE cOficio 	   CHAR(60);
	DEFINE cExpediente CHAR(60);
	DEFINE cCodRetorno CHAR(5);
	DEFINE cNumEmple   CHAR(8);
	DEFINE cUsuEstado  CHAR(1);
	DEFINE cUsuIp	   CHAR(15);
	DEFINE cUsuMac 	   CHAR(17);
	DEFINE iUsuBloqueo INTEGER;
    DEFINE iContador   INTEGER;
    DEFINE iRegistros  INTEGER;	
	LET cCodRet  = '00000';
	LET iSqlErr	 = 0;
	LET cUsuariosIn = '';
	LET iOficios = 0;
	LET iPerLoca  = 0;
	LET iPerHomo  = 0;
	LET iPerNoLo  = 0;
	LET cStatusAux  = '1';
    LET cStatusAux2 = '2';
    LET cStatusAux0 = '0';
	LET cStatusAux3  = '3';
	LET cNombreUser ='';
	LET cfchOficio  = ''; 
	LET cfchRecep  = ''; 
	LET cOficio 	= '';
	LET cExpediente = '';
	LET cCodRetorno = '';
	LET cNumEmple   = '';
	LET cUsuEstado	= '';
	LET cUsuIp		= '';
	LET cUsuMac     = '';
	LET iUsuBloqueo = 0;
    LET iContador   = 0; 
	LET iRegistros  = 0;	
	
		BEGIN
			--EXEPCIONES
				ON EXCEPTION SET  iSqlErr
					IF iSqlErr <> 0 THEN
						LET cCodRet= iSqlErr;
						RETURN  cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
								cfchRecep,  cOficio, cExpediente, iPerLoca,
								iPerHomo, iPerNoLo;
					END IF;				
				END EXCEPTION;
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
				EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
							cfchRecep,  cOficio, cExpediente, iPerLoca,
							iPerHomo, iPerNoLo;
				END IF;
			-- VALIDACIONES DE ENTRADA
				IF  pUsuario = '' OR 
					pIdFunciON = '' OR 
					pFchInicio  = '' OR 
					pFchFin  = '' OR 
					pRegistros = '' OR 
					pRecuperaciON = ''
					THEN
						LET cCodRet = '00003';
					RETURN cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
							cfchRecep,  cOficio, cExpediente, iPerLoca,
							iPerHomo, iPerNoLo;
				END IF;
               --VALIDA SI HAY DATOS 
				SET ISOLATION TO DIRTY READ;
             	  SELECT  {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} COUNT(*) INTO  iRegistros
                  FROM sw_ro_resulper WHERE status=1 AND  fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' )
                  AND fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S');
                --MANDAR CODIGO  "NO EXISTE DATOS"
                    IF iRegistros = 0 AND pRegistros = 0  THEN
                                 LET cCodRet='00017';
								 RETURN  cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
										cfchRecep,  cOficio, cExpediente, iPerLoca,
										iPerHomo, iPerNoLo;
		            END IF;
			    --CONSULTAR LOS DATOS CORRESPONDIENTES A LOS OFICIOS CONTESTADOS			
					SET ISOLATION TO DIRTY READ;
					FOREACH
                        SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} skip pRegistros FIRST  pRecuperaciON  DISTINCT  user_INSERT,id_oficio INTO cUsuariosIn, iOficios  
						FROM sw_ro_resulper 
						WHERE status=1 
							AND  fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 
							AND fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S')
                        IF cStatusAux = '1' THEN
                        --obtengo el numero de localizados de cada oficio 
							SET ISOLATION TO DIRTY READ;
                            SELECT COUNT(*) INTO iPerLoca 
							FROM  sw_ro_resulper 	
							WHERE user_INSERT = cUsuariosIn  
								AND  id_oficio = iOficios  
								AND status_busqueda = '1'; 
                        END IF;
                        IF cStatusAux2 = '2' THEN
                        --obtengo el numero de homonimos de cada oficio 
							SET ISOLATION TO DIRTY READ;
                            SELECT COUNT(DISTINCT id_busqueda) INTO iPerHomo 
							FROM  sw_ro_resulper 	
							WHERE user_INSERT = cUsuariosIn  
								AND  id_oficio = iOficios  
								AND status_busqueda = '2'; 
                        END IF; 
                        IF cStatusAux0 = '0' THEN
                            --obtengo el numero de No localizados de cada oficio 
							SET ISOLATION TO DIRTY READ;
                            SELECT COUNT(*) INTO iPerNoLo 
							FROM  sw_ro_resulper 	
							WHERE user_INSERT = cUsuariosIn  
								AND  id_oficio = iOficios  
								AND status_busqueda = '0';  
						END IF;
						IF cStatusAux3 = '3' THEN
							SET ISOLATION TO DIRTY READ;
							SELECT  fecha_oficio, fecha_recepcion, oficio, expediente  
                            INTO    cfchOficio, cfchRecep,  cOficio, cExpediente  
							FROM  sw_ro_maeoficios   
							WHERE  id_oficio = iOficios 
								AND  status=1;
                        END IF;
					    EXECUTE PROCEDURE bdinteg:sp_cnsif_consultaejecutivo(pUsuario , pIdFuncion, cUsuariosIn) 
                            INTO  cCodRetorno, cNumEmple, cUsuEstado, cUsuIp,
									cUsuMac, cNombreUser, iUsuBloqueo ;         
							LET iContador= iContador + 1;
                            RETURN cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
									cfchRecep,  cOficio, cExpediente, iPerLoca,
									iPerHomo, iPerNoLo 
								WITH resume;
					END FOREACH;
                    IF iContador = 0 THEN
                                 LET cCodRet='01001';
								 RETURN cCodRet, cUsuariosIn, cNombreUser,  cfchOficio, 
										cfchRecep,  cOficio, cExpediente, iPerLoca,
										iPerHomo, iPerNoLo;			
                    END IF;
		END
END PROCEDURE;