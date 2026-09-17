CREATE PROCEDURE "informix".sp_altaserv_edoctamov_iccat(pempresa CHAR(3), pnumcte CHAR(9),pcuenta CHAR(20),pproducto CHAR(4),pusuario CHAR(9),ptipo CHAR(1))

	RETURNING CHAR(9) AS CodRet;

	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetorno		CHAR(9);
	DEFINE sCuenta			CHAR(20);
	DEFINE iCantReg		INTEGER;
	 
	LET iSqlErr	 = 	0;
	LET cCodRetorno	 = 	'000000000';
	LET sCuenta	 = '';
	LET iCantReg = 0;
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/tmp/sp_altaserv_edoctamov_iccat.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;	
	
		
		IF TRIM(pempresa) = '' AND TRIM(pnumcte) = '' AND TRIM(pproducto) = '' AND TRIM(pusuario) = '' AND TRIM(pcuenta) = '' THEN
		
			LET cCodRetorno = '000000002';				
			RETURN cCodRetorno;
			
		ELSE
		
			IF ptipo = '0' THEN		
												
				
				SELECT  DISTINCT(cuenta)
				INTO sCuenta
				FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				
				IF iCantReg = 0 THEN
			
					LET sCuenta = '';
					LET cCodRetorno = '000000003';					
					
				END IF;
				
				RETURN cCodRetorno;
	
			
				
			ELIF ptipo = '1' THEN
				
				INSERT INTO bdinteg: "informix".si_altaserv_edoctamov (empresa,numcte,cuenta,producto,fecha_cancel_servicio,user_modif) 
				VALUES (pempresa,pnumcte,pcuenta,pproducto,current,pusuario);
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000000004';
				END IF;
				
				RETURN cCodRetorno;
				
			ELIF ptipo = '2' THEN
			
				DELETE FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa 
				AND numcte = pnumcte 
				AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000000005';
				END IF;
						
				RETURN cCodRetorno;
				
			END IF;
			
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 353-RQM 10 943 - Activación y Cancelación de envío por correo electrónico del Estado de Movimientos para ICCAT',
'AUTOR: Juan Pablo Soto',
'FECHA: 20/12/2017',
'SE CREA PROCEDIMIENTO PARA INSERTAR A LOS CLIENTES QUE CANCELEN EL SERVICIO',
'DB:BDINTEG';

CREATE PROCEDURE "informix".sp_consulta_carrier_flex()

     RETURNING	CHAR(4) AS idCarrier, CHAR(40) AS nombreCarrier;

	--definicion de variables--	    
	DEFINE resultado_idCarrier	 	CHAR(4);
    DEFINE resultado_nombreCarrier	CHAR(40);
    DEFINE iSqlErr                  INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_idCarrier = '';
	LET resultado_nombreCarrier = '';

    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                   		LET resultado_idCarrier = '';
						LET resultado_nombreCarrier = '';
                    RETURN resultado_idCarrier, resultado_nombreCarrier;
                END IF;
        END EXCEPTION;
      
		FOREACH
			SELECT cve_carrier, nombre_carrier
			INTO resultado_idCarrier, resultado_nombreCarrier
			FROM bdinteg:si_carriers car, bdicred:"informix".sd_param_campania par
			WHERE car.cve_carrier = par.valor_numerico
			AND par.tipo_campania  =69
			AND par.grupo_parametro ='FLEX_MOVIL'				
			
            RETURN resultado_idCarrier, resultado_nombreCarrier WITH resume;
        END FOREACH;
	END
END PROCEDURE;