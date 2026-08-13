CREATE PROCEDURE "informix".sp_encripta_folios(pnIdStatus SMALLINT, pdfchUltAccIni DATE, pdfchUltAccFin DATE, pnNulos SMALLINT)
RETURNING CHAR(5),CHAR(55);

	DEFINE vc_numcte CHAR(20);
	DEFINE vc_numcte_trim CHAR(20);
	DEFINE vsCodRet  CHAR(5);
	DEFINE viSqlErr  SMALLINT;
	DEFINE vsMesage  CHAR(55);	
	DEFINE nCommit   SMALLINT;
		
	LET vsCodRet = '00000';
	LET viSqlErr = 0;
	LET vsMesage = '';
	LET nCommit = 0;
	
	--SET DEBUG FILE TO '/informix/gaby/auditoria_observaciones/sp_enc_folio_masivo.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
    ON EXCEPTION SET viSqlErr
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet,vsMesage;
        END IF;
    END EXCEPTION;
    
    --Campos con valor
      IF pnNulos = 0 THEN
        FOREACH 
            SELECT numcte INTO vc_numcte
		      FROM bdinteg:si_bpiusuarios
		     WHERE id_status = pnIdStatus
		       AND date(f_ultimo_acceso) BETWEEN pdfchUltAccIni AND pdfchUltAccFin 
		       		
		    LET vc_numcte_trim = vc_numcte;
		    
            EXECUTE PROCEDURE bdibpi:sp_encripta_folio_contrato(vc_numcte_trim) INTO vsCodRet, vsMesage;

        END FOREACH;        
    ELSE  
        FOREACH 
            SELECT numcte INTO vc_numcte
		      FROM bdinteg:si_bpiusuarios
             WHERE id_status = pnIdStatus	     
               AND f_ultimo_acceso IS NULL
               AND date(f_status) BETWEEN pdfchUltAccIni AND pdfchUltAccFin
                        
		    LET vc_numcte_trim = vc_numcte;  
		                 	        
            EXECUTE PROCEDURE bdibpi:sp_encripta_folio_contrato(vc_numcte_trim) INTO vsCodRet, vsMesage;

        END FOREACH;
    END IF;

    LET vsMesage = 'Encriptacion exitosa';	
    	
	RETURN vsCodRet, TRIM(vsMesage);	
	
	END;
END PROCEDURE
DOCUMENT
"Encripta folio contrato",
"Autor : Fidel Arteaga",
"FECHA : 09/mar/2022",
"Descripcion de la modificaciÃ³n: Encriptación de folio contrato masivo";

CREATE PROCEDURE "informix".sp_encripta_folio_contrato(pc_num_cli CHAR(20))
RETURNING CHAR(5), CHAR(55);

	DEFINE vc_folioact CHAR(36);
	DEFINE vcCodRet CHAR(5);
	DEFINE viSqlErr INTEGER;
	DEFINE vcMensaje CHAR(55);	
	DEFINE vc_folioContrato CHAR(55);
	DEFINE vcValor CHAR(3);
	DEFINE vcEncriptacion CHAR(40);
	DEFINE vcLetra CHAR(1);
	DEFINE idx SMALLINT;
	DEFINE vn_tamanio SMALLINT;
	DEFINE vc_num_cli CHAR(20);
	DEFINE vc_mensaje CHAR(55);

	LET vcCodRet = '00000';
	LET viSqlErr = 0;
	LET vcMensaje = '';
	LET vcLetra = '';
	LET idx = 1;
	LET vn_tamanio = 0;
	LET vc_num_cli = '';
	LET vc_mensaje = '';
	
	--SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_encripta_folio_contrato.out';
	--TRACE ON;
	
	IF NVL(pc_num_cli, '') = '' OR pc_num_cli IS NULL THEN 
		LET vcCodRet = '00003';
		LET vcMensaje = 'Valor Nulo';
	END IF;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET vcCodRet = viSqlErr;
                RETURN vcCodRet, vcMensaje;
            END IF;	
        END EXCEPTION; 	
        
	    IF LENGTH(pc_num_cli) > 0 OR pc_num_cli <> '' THEN	 
	        
	        LET vc_num_cli = TRIM(pc_num_cli);

	        SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} folio_contrato INTO vc_folioact
		      FROM bdinteg:si_bpiusuarios
             WHERE empresa = '001' AND numcte = pc_num_cli;
             
            LET vn_tamanio = length(TRIM(vc_folioact));
             
            IF LENGTH(vc_folioact) <= 12 THEN
                FOR idx in (1 to vn_tamanio)
                    LET vcLetra = SUBSTR(vc_folioact,idx,1);
                    
                    SELECT valor INTO vcValor 
                      FROM bdibpi:bpi_base_encripta
                     WHERE letra = vcLetra;
                     
                    LET vcMensaje = vcValor || vcMensaje;
                    
                END FOR;

                LET vc_mensaje = TRIM(vcMensaje);
                
                UPDATE {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} bdinteg:si_bpiusuarios SET
			     folio_contrato = vcMensaje
		         WHERE empresa = '001' AND numcte = pc_num_cli; 
                
            ELSE
                LET vcCodRet = '00003';
                LET vcMensaje = vc_folioact;            
            END IF;
        END IF;
            
	    RETURN vcCodRet, vcMensaje;
	    
    END;			
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para cifrar folio contrato.',
'AUTOR : Fidel Arteaga G',
'FECHA : 15 de Marzo 2022',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_cargareversatokendig(pTipo CHAR(1), pSistema CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20), pSucursal CHAR(4), pNumEmpleado CHAR(9), pFolio_Suc CHAR (16), pTipoServicio SMALLINT, pIp CHAR(15), pFolio CHAR(12),pStatusToken SMALLINT)
RETURNING CHAR(5), CHAR(10);

--Declaracion de variables
DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE viEdoCte SMALLINT;
DEFINE vsSolicitud CHAR(10);
DEFINE sDivisa CHAR(2);
DEFINE sNumTarjeta CHAR(20);
DEFINE vsTipoSer CHAR(2);
DEFINE vTrans  CHAR(4);
DEFINE dFecha  DATE;
DEFINE sSaldo  MONEY(14,2);
DEFINE vTransaccion INTEGER;
DEFINE vCodRet CHAR(10);
DEFINE vParam  CHAR(2);
DEFINE vsNumSolicitud CHAR(10);
DEFINE mIva MONEY(16,2);
DEFINE vFolio CHAR(12); --DVRP 01/07/2011
DEFINE cTipoPersona	CHAR(2);
DEFINE pCount INTEGER;
DEFINE cNstoken CHAR(9);
DEFINE vnstoken CHAR(9);


--SET isolation to cursor stability;
SET LOCK MODE TO WAIT 3; 
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "/informix/gaby/spl_inc/sp_cargareversatokendig.out";
--TRACE ON;

--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsSolicitud = '';
LET sNumTarjeta = '';
LET vsTipoSer = '';
LET vParam = '';
LET vCodRet = '00000';
LET vsNumSolicitud = '0000000000';
LET mIva = 0;
LET vFolio = '';
LET cTipoPersona = '';
LET pCount =0;
--Inicio del procedimiento

	

BEGIN

    ON EXCEPTION SET viSqlErr
       IF viSqlErr <> 0 THEN
			LET vcodret = viSqlErr;
        RETURN vsCodRet, vsNumSolicitud;
       END IF;
	END EXCEPTION;
	
    
	
     IF NVL(pTipo, '') = '' OR  NVL(pEmpresa, '') = '' OR NVL(pNumCte, '') = ''  OR  NVL(pStatusToken, '') = '' OR NVL(pSucursal, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
        LET vsCodRet = '-1';
        RETURN vsCodRet, vsNumSolicitud;
	 END IF;

    LET vsCodRet = '00000';

    IF vsCodRet = '00000' THEN
     
        IF pTipo = '8' THEN
		
        	LET pFolio_suc = "SINCOMIS" || TRIM(SUBSTRING(pFolio_suc FROM 9 FOR 16));
			
			IF CAST(vsCodRet AS INTEGER) = 0 THEN
			
				IF pStatusToken = 0 THEN
					LET pStatusToken = 300;
				END IF;

				SELECT {+INDEX bdinteg: "informix".si_bpiusuarios idx_bpi} folio_contrato 
				  INTO vFolio
				  FROM bdinteg:"informix".si_bpiusuarios 
				 WHERE numcte = pNumCte AND empresa = pEmpresa; --DVRP 01/07/2011
				 

				SELECT COUNT (*) INTO pCount FROM bdinteg:"informix".si_bpitoken where num_cliente = pNumCte AND empresa = pEmpresa;
				SELECT COUNT (*) INTO cNstoken 	FROM bdinteg:"informix".si_bpitoken;
							
							LET vnstoken = 'TEMP' ||  TRIM(SUBSTRING(cNstoken+1 FROM 2 FOR 6));
							

				IF TRIM(pFolio) = "" THEN
					IF pCount > 0 THEN							
							update bdinteg:"informix".si_bpitoken set ns_token=vnstoken, suc_registro=pSucursal, folio_token=vFolio, id_status_token='140', f_status=CURRENT, f_registro=CURRENT, tipo_token='2'
							where num_cliente = pNumCte AND empresa = pEmpresa;	
					ELSE		
							INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro,tipo_token)
								 VALUES(pEmpresa, pNumCte, vnstoken, pSucursal, vFolio, '140', CURRENT, CURRENT,'2');
					END IF;	 
				ELSE
					IF pCount > 0 THEN							
							update bdinteg:"informix".si_bpitoken set ns_token=vnstoken, suc_registro=pSucursal, folio_token=pFolio, id_status_token='140', f_status=CURRENT, f_registro=CURRENT, tipo_token='2'
							where num_cliente = pNumCte AND empresa = pEmpresa;	
					ELSE		
						
						INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro,tipo_token)
							 VALUES(pEmpresa, pNumCte, vnstoken, pSucursal, pFolio, '140', CURRENT, CURRENT,'2');
					END IF;
				END IF; 
				
				
				SELECT (MAX(solicitud) + 1) into vsNumSolicitud FROM bdibpi:"informix".bpi_tokensolicitud;
				LET vsNumSolicitud = LPAD(CAST(NVL(Trim(vsNumSolicitud), 0000000001) AS INTEGER), 10, '0');
				

				INSERT INTO bdibpi:"informix".bpi_tokensolicitud (solicitud, numcte, id_status, sucursal, f_solicitud, sec_domicilio, f_atencion, usr_solicita, empresa, tipo, folio_suc)
					 VALUES (vsNumSolicitud, pNumCte, pStatusToken, pSucursal, '1900-01-01 12:00:00', '', '1900-01-01 12:00:00', pNumEmpleado, pEmpresa, pTipo,pFolio_suc);

				--LET vsNumSolicitud = (SELECT LPAD(CAST(MAX(Trim(solicitud)) AS INTEGER), 10, '0') FROM bdibpi:"informix".bpi_tokensolicitud  WHERE numcte = pNumCte);
				
				
						
				
			END IF;
			
			IF vsCodRet = 0 THEN
								
				SELECT tpo_persona INTO cTipoPersona FROM bdinteg: "informix".si_cliente WHERE numcte = pNumCte;
		
				-- Inserta el registro de conciliación
				INSERT INTO bdibpi: "informix".tkn_solcobranza 
				(solicitud, Numcte, id_status, f_solicitud, folio_suc, f_cobro, T_Persona )
				VALUES (vsNumSolicitud, pNumCte, pStatusToken, CURRENT, pFolio_Suc,current,cTipoPersona);	
			
			END IF;

		ELSE
			LET vsCodRet = '-2';
        END IF;

	END IF;
		
	RETURN vsCodRet, vsNumSolicitud;
END
END PROCEDURE
DOCUMENT
"FOLIO:RQI 03 639 Proceso OFI para Implementación de Token Digital",
"Descripcion: Se Clona SP sp_cargareversatokendig se valida el nuevo status y tipo para la solicitud de token digital",
"Modifico   : JESUS ANTONIO CAAMAL ORDAZ",
"Fecha      : 01/02/2018",
"BD         : bdibpi ",
"Descripcion: Se agrega validación de si_bpitoken, si existe el registro lo actualiza",
"Fecha      : 08/01/2019",
"Modifico   : Gabriela Aguilar",
"Descripcion: Se agrega validación de si_bpitoken, inserta con tipo token 2",
"Fecha      : 19/07/2019",
"Modifico   : Gabriela Aguilar",
"Descripcion: Debido al cambio de servicio a avanzado, se genera token generico TEM",
"Fecha      : 14/04/2020",
"Modifico   : Gabriela Aguilar",
"Descripcion: Se optimiza spl, se separa el query select del insert para bpi_tokensolicitud ",
"Fecha      : 16/08/2021",
"Modifico   : Gabriela Aguilar";

CREATE PROCEDURE "informix".sp_encripta_folios(pnIdStatus SMALLINT, pContador INT)
RETURNING CHAR(5),CHAR(55);

	DEFINE vc_numcte CHAR(20);
	DEFINE vc_numcte_trim CHAR(20);
	DEFINE vsCodRet  CHAR(5);
	DEFINE viSqlErr  SMALLINT;
	DEFINE vsMesage  CHAR(55);	
	DEFINE nCommit   SMALLINT;

	LET vsCodRet = '00000';
	LET viSqlErr = 0;
	LET vsMesage = '';
	LET nCommit = 0;
	
--	SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_enc_folio_masivo.out';
--	TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
    ON EXCEPTION SET viSqlErr
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet,vsMesage;
        END IF;
    END EXCEPTION;
    
	IF pContador IS NULL THEN
	 
		LET vsMesage = 'Datos de entrada incorrectos';	
		RETURN vsCodRet, TRIM(vsMesage);	
	 
	ELIF pnIdStatus IS NULL THEN
	 
		LET vsMesage = 'Datos de entrada incorrectos';	
		RETURN vsCodRet, TRIM(vsMesage);	
	 
	END IF;

--Ciclo de encriptado

        FOREACH 
            SELECT numcte INTO vc_numcte
		      FROM bdinteg:si_bpiusuarios
		     WHERE id_status = pnIdStatus
			   AND LENGTH(folio_contrato) = 12
			   AND f_encriptado IS NULL LIMIT pContador

		    
            EXECUTE PROCEDURE bdibpi:sp_encripta_folio_contrato(vc_numcte) INTO vsCodRet, vsMesage;
			
			UPDATE bdinteg:si_bpiusuarios set f_encriptado= CURRENT WHERE numcte = vc_numcte AND empresa = '001';
				

        END FOREACH;        

    LET vsMesage = 'Encriptacion exitosa';	
    	
	RETURN vsCodRet, TRIM(vsMesage);	
	
	END;
END PROCEDURE
DOCUMENT
"Encripta folio contrato",
"Autor : Fidel Arteaga",
"FECHA : 09/mar/2022",
"Descripcion de la modificaciÃ³n: Encriptación de folio contrato masivo";

CREATE PROCEDURE "informix".sp_consulta_dynatrace ()
RETURNING CHAR(5);
    DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE fechaMonitoreo CHAR(60);

    LET codRet = '00000';
    LET viSqlErr = 0;
    LET fechaMonitoreo = CURRENT;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet;
            END IF;	
        END EXCEPTION;
	--SET DEBUG FILE TO "/informix/JuanRivera/Traces/sp_consulta_dynatrace.out";
	--TRACE ON;
-- cambiar que consulta a la bdibpi:bpi_param
	SELECT f_fin INTO fechaMonitoreo FROM bdibpi:"informix".bpi_param where id_param ='24';
        IF fechaMonitoreo  <> '' AND fechaMonitoreo <> 'NULL' THEN
		
            UPDATE bdibpi:"informix".bpi_param SET f_fin = CURRENT where id_param ='24';

        END IF;


        RETURN codRet;
    END;
END PROCEDURE
;