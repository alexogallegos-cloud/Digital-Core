CREATE PROCEDURE "informix".sp_consultarstatusbm(cEmpresa CHAR(3),cNumCte CHAR(20))

    RETURNING
	CHAR(5), -- Código de Retorno
	INTEGER, --Id Status
	CHAR(60);

	--Declaracion de variables
	DEFINE vsCodRet CHAR(5);
	DEFINE vsEdoRet SMALLINT;
	DEFINE vsMensajeRet CHAR(60);
	DEFINE vsEdoCte SMALLINT;
	DEFINE vsEdoCambiar SMALLINT;
	DEFINE vsDescEdoCambiar CHAR(60);
	DEFINE viSqlErr INTEGER;

	--SET DEBUG FILE TO "/home/informix/ivonne/sp_consultarstatusbm.out";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vsEdoRet = 0;
	LET vsMensajeRet = '';
	LET vsEdoCte = 0;
	LET vsEdoCambiar = 0;
	LET vsDescEdoCambiar = '';
	LET viSqlErr = 0;

	BEGIN

		ON EXCEPTION SET viSqlErr --Manejador de Errores
			IF viSqlErr <> 0 then
				LET vsCodRet = viSqlErr;
				RETURN vsCodRet,vsEdoRet,vsMensajeRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		--Validación de datos de entrada
		IF NVL(cNumCte, '') = '' THEN --Valida que el Numero de Cliente nosea nulo o espacio en blanco
			LET vsCodRet = '00001';
			LET vsEdoRet = '';
			LET vsMensajeRet = 'El Numero de Cliente es Requerido.';
		ELIF NVL(cEmpresa, '') = '' THEN --Valida que el Numero de Cliente nosea nulo o espacio en blanco
				LET vsCodRet = '00002';
				LET vsEdoRet = '';
				LET vsMensajeRet = 'La Empresa es Requerida.';
		ELSE
			IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(cNumCte)
				AND empresa = TRIM(cEmpresa)) THEN  --Valida que el Número de Cliente exista
				LET vsCodRet = '00003';
				LET vsEdoRet = '';
				LET vsMensajeRet = 'El Numero de Cliente No Existe.';
			END IF;
		END IF;

		IF vsCodRet = '00000' THEN --Obtiene el estado del Cliente y alos estados que puede cambiar

			SELECT id_status
			INTO vsEdoCte
			FROM bdinteg:"informix".si_bm_usuarios
			WHERE numcte = TRIM(cNumCte) AND empresa = TRIM(cEmpresa);

			IF EXISTS (SELECT status_destino FROM bdinteg:"informix".si_bmcatcambiostatus WHERE status_origen = vsEdoCte AND proceso = '02') THEN
						
				FOREACH

					SELECT status_destino
					INTO vsEdoCambiar
					FROM bdinteg:"informix".si_bmcatcambiostatus
					WHERE status_origen = vsEdoCte AND proceso = '02' ORDER BY status_destino

					SELECT desc_status
					INTO vsDescEdoCambiar
					FROM bdinteg:"informix".si_bpistatus
					WHERE id_status = vsEdoCambiar;

					LET vsEdoRet = vsEdoCambiar;
					LET vsMensajeRet = TRIM(vsDescEdoCambiar);

					RETURN vsCodRet,vsEdoRet,vsMensajeRet WITH RESUME;
					
				END FOREACH;
				
			ELSE
				LET vsCodRet = '00004';
				LET vsEdoRet = '';
				LET vsMensajeRet = 'El estatus del servicio no permite realizar ningún cambio';
				RETURN vsCodRet,vsEdoRet,vsMensajeRet WITH RESUME;
				
			END IF
					
		ELSE
			RETURN vsCodRet,vsEdoRet,vsMensajeRet;
		END IF

	END

END PROCEDURE

DOCUMENT
"Consulta el estatus del cliente en Banca Móvil",
"y muestra estatus posibles a cambiar",
"Autor : Martha Aguirre",
"FECHA : 2011/09/13",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: 07-08-2012 Bibiana Gaxiola V.",
"Se envía mensaje en pantalla para aquellos estatus que no permiten cambio";

CREATE PROCEDURE "informix".sp_cnsif_actualizafuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_FUNCION char(10),cID_MODULO char(6),
														iID_SUBMODULO INTEGER, cD_FUNCION_LINK char(60),cD_FUNCION char(100),cSTATUS char(1),
                                                      dFECHA_MODIFICACION date,cID_USUARIO_MODIFICACION char(8),cMAC_ADDRESS_MODIFICACION char(18),
                                                      cIP_MODIFICACION varchar(16))
 
    RETURNING CHAR(5);
													
	DEFINE iexiste INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iSql_err INT;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
		
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_actualizafuncion.out";
		--TRACE ON;
		
		IF 	cID_USUARIOC = '' OR 
			cID_FUNCIONC ='' OR 
			cID_FUNCION = '' OR
			cID_MODULO = '' OR 
			iID_SUBMODULO = '' OR 
			cD_FUNCION_LINK = '' OR
			cD_FUNCION = '' OR 
			cSTATUS = '' OR
			dFECHA_MODIFICACION = '' OR
			cID_USUARIO_MODIFICACION = '' OR 
			cMAC_ADDRESS_MODIFICACION = ''	OR
            cIP_MODIFICACION = '' THEN
			LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
        IF cID_FUNCION='SEG010' THEN
            LET cCodRet='00107';
			RETURN cCodRet;
		END IF;		
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet;
		END IF;		
		
		SELECT nvl(Count(id_funcion),0) INTO iexiste  FROM si_seg_funciones where id_funcion = cID_FUNCION;
		IF iexiste = 0 THEN
			LET cCodRet = "00001";
		END IF;
		IF iexiste = 1 THEN
			UPDATE si_seg_funciones
			SET id_modulo=cID_MODULO,id_submodulo=iID_SUBMODULO,d_funcion_link = cD_FUNCION_LINK,d_funcion = cD_FUNCION,status = cSTATUS, 
				fecha_modificacion = dFECHA_MODIFICACION,Id_usuario_modificacion = cID_USUARIO_MODIFICACION, 
				mac_adress_modificacion = cMAC_ADDRESS_MODIFICACION,ip_modificacion = cIP_MODIFICACION
			where id_funcion = cID_FUNCION;
		END IF;   
    RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP servira para actualizar los datos de la tabla funciones, se actualizaran datos como funcion_link, status, asi como datos que ayudaran a", 
"identificar quien realizo dichos cambios como el Id_usuario la ip y macaddrees del usuario que esta modificando",
"FECHA : 21-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cierra_sesiones_bm() 
RETURNING CHAR(5) AS vCodRet1;
        
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
        
    DEFINE vnumcel              CHAR(15);
    DEFINE vsecmax              INTEGER;
    DEFINE vid_session          INTEGER;
    DEFINE vnumcte              CHAR(20);
    DEFINE vid_oper             CHAR(4);
            
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = '';
        
    LET vnumcel     = '';
    LET vsecmax     = 0;
    LET vid_session = 0;
    LET vnumcte     = '';
    LET vid_oper    = '';
        
    BEGIN
        
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cierra_sesiones_bm.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cierra_sesiones_bm.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH
        SELECT UNIQUE numcel
          INTO vnumcel
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
         
        SELECT MAX(secuencia)
          INTO vsecmax
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
           AND numcel = vnumcel;
           
        IF vsecmax is null OR vsecmax = 0 THEN
            CONTINUE FOREACH;
        END IF;
         
        FOREACH
            SELECT id_session, numcte, id_oper
              INTO vid_session, vnumcte, vid_oper
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND numcel = vnumcel
               AND secuencia = vsecmax
                    
            IF vid_oper <> '1001' THEN
                IF ( SELECT CURRENT HOUR TO SECOND - EXTEND(fech_oper, HOUR TO SECOND)
                       FROM bdinteg:"informix".si_bm_bitacora
                      WHERE DATE(fech_oper) = CURRENT::DATE
                        AND numcel = vnumcel
                        AND secuencia = vsecmax ) > '00:05:00' THEN
                      
                    LET vsecmax = vsecmax + 1;
                    
                    INSERT INTO bdinteg:"informix".si_bm_bitacora( id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol )
                    VALUES( vid_session, CURRENT, vnumcte, vsecmax, '1001', vnumcel, null, null );
                END IF;
            END IF;
            
            LET vid_session = 0;
            LET vnumcte     = '';
            LET vid_oper    = '';
        END FOREACH;
        
        LET vnumcel     = '';
        LET vsecmax     = 0;
    END FOREACH;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;