CREATE PROCEDURE "informix".sp_cnsif_actualizamodulo(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_MODULO char(6),  
                                                      cD_MODULO char(20),cSTATUS char(1),dFECHA_MODIFICACION date,
                                                      cID_USUARIO_MODIFICACION char(8),cMAC_ADDRESS_MODIFICACION char(18),
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
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_actualizamodulo_2.out";
		--	TRACE ON;
		
		IF 	cID_MODULO ='' OR 
			cD_MODULO  ='' OR 
			cSTATUS ='' OR
			dFECHA_MODIFICACION = '' OR
			cID_USUARIO_MODIFICACION = '' OR 
			cMAC_ADDRESS_MODIFICACION = '' OR
			cIP_MODIFICACION  = ''  THEN
			 LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet;
		END IF;
		
		SELECT {+INDEX (bdinteg:si_seg_modulos idxidmodulo)} nvl(Count(id_modulo),0) INTO iexiste  FROM si_seg_modulos where id_modulo = cID_MODULO;
		IF iexiste = 0 THEN
			LET cCodRet = "00001";
		END IF;
		IF iexiste = 1 THEN
			UPDATE {+INDEX (bdinteg:si_seg_modulos idxidmodulo)} si_seg_modulos
			SET d_modulo = cD_MODULO,status = cSTATUS, fecha_modificacion = dFECHA_MODIFICACION,
				Id_usuario_modificacion = cID_USUARIO_MODIFICACION, mac_adress_modificacion = cMAC_ADDRESS_MODIFICACION,
				ip_modificacion = cIP_MODIFICACION
			WHERE id_modulo = cID_MODULO;
		END IF;
        
    RETURN cCodRet;
    END
END PROCEDURE		
DOCUMENT			
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP servira para actualizar los datos de la tabla modulos, se actualizaran datos como  la descripcion del modulo, su status",
"asi como datos que ayudaran a identificar quien realizo dichos cambios como el Id_usuario la ip y macaddrees del modulo que se esta modificando",
"FECHA : 20-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_actualizaperfil(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_PERFIL char(10),cD_PERFIL char(100),
														cSTATUS CHAR(1), dFECHA date,cID_USUARIO char(8),cMAC_ADDRESS char(18),
                                                      cIP varchar(16),iTIPO INTEGER)
 
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
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_actualizaperfil_2.out";
		--	TRACE ON;
		
		IF 	cID_USUARIOC = ''	OR 
			cID_FUNCIONC =''	OR 
			cID_PERFIL = '' 	OR 
			cD_PERFIL = ''		OR
			cSTATUS = '' 		OR
			dFECHA = ''			OR
			cID_USUARIO = ''	OR
			cMAC_ADDRESS = ''	OR
			cIP = ''		 	OR
			iTIPO  = 0			THEN
			LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet;
		END IF;
		IF iTIPO <> 1 AND iTIPO <> 2 THEN
			LET cCodRet = "00005";
			RETURN cCodRet;
		END IF;
		IF iTIPO = 1 THEN 
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles where id_perfil = cID_PERFIL;
			IF iexiste = 1 THEN
				LET cCodRet = "00004";
				RETURN cCodRet;		
			END IF;
			IF iexiste = 0 THEN
				INSERT INTO si_seg_perfiles(id_perfil,d_perfil,status,fecha_alta,id_usuario_alta,mac_adress_alta,ip_alta)
				VALUES(cID_PERFIL,cD_PERFIL,cSTATUS,dFECHA,cID_USUARIO,cMAC_ADDRESS,cIP);				
			END IF;
		END IF;
		
		IF iTIPO = 2 THEN
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles where id_perfil = cID_PERFIL;
			IF iexiste = 0 THEN
				LET cCodRet = "00001";
				RETURN cCodRet;		
			END IF;
			IF iexiste = 1 THEN
				UPDATE {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} si_seg_perfiles 
				SET d_perfil = cD_PERFIL,status=cSTATUS,fecha_modificacion=dFECHA,id_usuario_modificacion=cID_USUARIO,
				mac_adress_modificacion =cMAC_ADDRESS,ip_modificacion =cIP
				WHERE id_perfil = cID_PERFIL;
			END IF; 
		END IF;		
    RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP servira para mmodificar la tabla de perfiles si_seg_perfiles, dependiendo del id_perfil que se le indique al SP ",
"se modificaran datos como la descripcion de perfil, el status asi como los campos para saber quien y cuando se modifico",
"FECHA : 23-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_actualizaperfilfuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_PERFIL CHAR(10),cID_FUNCION CHAR(250),
														cSTATUS CHAR(25), dFECHA date,cID_USUARIO_2 char(8),cMAC_ADDRESS char(18),
                                                      cIP varchar(16),iTIPO INTEGER	)
 
    RETURNING CHAR(5);
													
	DEFINE iexiste INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iSql_err INT;
    DEFINE I,J,H,A      INTEGER;
    DEFINE CADENA  CHAR (10);
    DEFINE CADENA2  CHAR (1);
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
    LET I=1;
    LET J=1;
    LET H=1;
    LET A=1;
    LET CADENA="";
    LET CADENA2="";
		
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/informix/VH/sp_cnsif_actualizaperfilfuncion_2.out";
		--TRACE ON;
		
		IF 	cID_USUARIOC = ''			OR 
			cID_FUNCIONC =''			OR 
			cID_PERFIL = '' 			OR 
			cID_FUNCION = ''			OR
			cSTATUS = ''				OR
			dFECHA = ''					OR
			cID_USUARIO_2	= ''		OR
			cMAC_ADDRESS = ''			OR
			cIP = ''		 			OR
			iTIPO = 0					THEN
			LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	    INTO cCodRet;
	  
	    IF cCodRet = '00028' THEN 
			RETURN cCodRet;
	    END IF;
		
		IF iTIPO <> 1 AND iTIPO <> 2 THEN
			LET cCodRet = "00005";
			RETURN cCodRet;
		END IF;
		IF iTIPO = 1 THEN 
            FOR I=1 TO LENGTH(cID_FUNCION) STEP 10
                LET CADENA=TRIM(SUBSTR(cID_FUNCION,I,10));
                SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxsegperfun)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles_funciones  WHERE id_perfil = cID_PERFIL AND id_funcion = CADENA;
                    IF iexiste = 1 THEN
                        LET cCodRet = "00004";
                        RETURN cCodRet;	
                    ELSE
                        LET CADENA2=SUBSTR(TRIM(cSTATUS),A,1);
                        INSERT INTO si_seg_perfiles_funciones (id_perfil,id_funcion,status,fecha_alta,id_usuario_alta,mac_adress_alta,ip_alta)
                        VALUES(cID_PERFIL,CADENA,CADENA2,dFECHA,cID_USUARIO_2,cMAC_ADDRESS,cIP);
                        LET CADENA="";	
                        LET A=A+1;
                    END IF;
            END FOR
         ELIF iTIPO = 2 THEN
            FOR I=1 TO LENGTH(cID_FUNCION) STEP 10
                LET CADENA=TRIM(SUBSTR(cID_FUNCION,I,10));
                SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxsegperfun)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles_funciones  WHERE id_perfil = cID_PERFIL AND id_funcion = CADENA;
                    IF iexiste = 0 THEN
                        LET cCodRet = "00001";
                        RETURN cCodRet;	
                    ELSE
                        LET CADENA2=SUBSTR(TRIM(cSTATUS),A,1);
                        UPDATE {+INDEX (bdinteg:si_seg_perfiles_funciones idxsegperfun)} si_seg_perfiles_funciones
                        SET status=CADENA2,fecha_modificacion=dFECHA,
                        id_usuario_modificacion=cID_USUARIO_2,mac_adress_modificacion =cMAC_ADDRESS,ip_modificacion =cIP
                        WHERE id_perfil = cID_PERFIL AND id_funcion = CADENA;
                        LET CADENA="";	
                        LET A=A+1;
                    END IF;
            END FOR
         END IF;

    RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT
"AUTOR : Victor Hugo Sánchez",
"FUNCIONAMIENTO: Este SP sirve para modificar e insertar perfiles. parametro tipo = 1 inserta un nuevo registro,parametro tipo = 2 actualiza el registro ",
"FECHA : 24-01-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_actualizausuario(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO char(8),iID_NIVEL_CONSULTA INTEGER,
															cID_PERFIL CHAR(10),cSTATUS CHAR(1), dFECHA date,cID_USUARIO_2 char(8),cMAC_ADDRESS char(18),
														  cIP varchar(16),iTIPO INTEGER,iBLOQUEO INTEGER)
 
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
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_actualizausuario_2.out";
		--TRACE ON;
		
		IF 	cID_USUARIOC = ''			OR 
			cID_FUNCIONC =''			OR 
			cID_USUARIO = '' 			OR 
			iID_NIVEL_CONSULTA IS NULL	OR
			cSTATUS = ''				OR
			dFECHA = ''					OR
			cID_USUARIO_2	= ''		OR
			cMAC_ADDRESS = ''			OR
			cIP = ''		 			OR
			iTIPO  = 0					OR
            IBLOQUEO IS NULL            THEN
			LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet;
		END IF;
		
		IF iTIPO <> 1 AND iTIPO <> 2 THEN
			LET cCodRet = "00005";
			RETURN cCodRet;
		END IF;
		IF iTIPO = 1 THEN 
			SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios WHERE id_usuario = cID_USUARIO;
			IF iexiste = 1 THEN
				LET cCodRet = "00004";
				RETURN cCodRet;		
			END IF;
			IF iexiste = 0 THEN
				INSERT INTO si_seg_usuarios(id_usuario,id_nivel_consulta,id_perfil,status,usu_bloqueo,fecha_alta,id_usuario_alta,mac_adress_alta,ip_alta)
				VALUES(cID_USUARIO,iID_NIVEL_CONSULTA,cID_PERFIL,cSTATUS,iBLOQUEO,dFECHA,cID_USUARIO_2,cMAC_ADDRESS,cIP);				
			END IF;
		END IF;
		
		IF iTIPO = 2 THEN
			SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios WHERE id_usuario = cID_USUARIO;
			IF iexiste = 0 THEN
				LET cCodRet = "00001";
				RETURN cCodRet;		
			END IF;
			IF iexiste = 1 THEN
				UPDATE 	si_seg_usuarios
				SET id_nivel_consulta= iID_NIVEL_CONSULTA,id_perfil=cID_PERFIL,status=cSTATUS,usu_bloqueo=iBLOQUEO,fecha_modificacion=dFECHA,
				id_usuario_modificacion=cID_USUARIO_2,mac_adress_modificacion =cMAC_ADDRESS,ip_modificacion =cIP
				WHERE id_usuario = cID_USUARIO;
			END IF; 
		END IF;		
    RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP servira para modificar la tabla de si_seg_usuarios segun el id_usuario que se envie al SP, se modificaran campos como id_nivel_consulta",
"el id perfil, el status y los campos para saber cuando y quien modifico dicho usuario",
"FECHA : 23-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_actualizausuariofuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO char(8),cID_FUNCION CHAR(250),
														cSTATUS CHAR(25), dFECHA date,cID_USUARIO_2 char(8),cMAC_ADDRESS char(18),
                                                      cIP varchar(16),iTIPO INTEGER)
 
    RETURNING CHAR(5);
													
	DEFINE iexiste INT;
	DEFINE cCodRet CHAR(5);
	DEFINE iSql_err INT;
    DEFINE I,J,H,A      INTEGER;
    DEFINE CADENA  CHAR (10);
    DEFINE CADENA2  CHAR (1);
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
    LET I=1;
    LET J=1;
    LET H=1;
    LET A=1;
    LET CADENA="";
    LET CADENA2="";
		
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_actualizausuariofuncion.out";
		--	TRACE ON;
		
		IF 	cID_USUARIOC = ''			OR 
			cID_FUNCIONC =''			OR 
			cID_USUARIO = '' 			OR 
			cID_FUNCION = ''			OR
			cSTATUS = ''				OR
			dFECHA = ''					OR
			cID_USUARIO_2	= ''		OR
			cMAC_ADDRESS = ''			OR
			cIP = ''		 			OR
			iTIPO  = 0					THEN
			LET cCodRet = "00003";
			 RETURN cCodRet;
		END IF;
		IF iTIPO <> 1 AND iTIPO <> 2 THEN
			LET cCodRet = "00005";
			RETURN cCodRet;
		END IF;

		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

		IF cCodRet = '00028' THEN 
			RETURN cCodRet;
		END IF;

		IF iTIPO = 1 THEN 
            FOR I=1 TO LENGTH(cID_FUNCION) STEP 10
                LET CADENA=TRIM(SUBSTR(cID_FUNCION,I,10));
                SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios_funciones  WHERE id_usuario = cID_USUARIO AND id_funcion	 = CADENA;
                    IF iexiste = 1 THEN
                        LET cCodRet = "00004";
                        RETURN cCodRet;	
                    ELSE
                        LET CADENA2=SUBSTR(TRIM(cSTATUS),A,1);
                        INSERT INTO si_seg_usuarios_funciones (id_usuario,id_funcion,status,fecha_alta,id_usuario_alta,mac_adress_alta,ip_alta)
                        VALUES(cID_USUARIO,CADENA,CADENA2,dFECHA,cID_USUARIO_2,cMAC_ADDRESS,cIP);	
                        LET CADENA="";	
                        LET A=A+1;
                    END IF;
            END FOR
         ELIF iTIPO = 2 THEN
            FOR I=1 TO LENGTH(cID_FUNCION) STEP 10
                LET CADENA=TRIM(SUBSTR(cID_FUNCION,I,10));
                SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios_funciones  WHERE  id_usuario = cID_USUARIO AND id_funcion = CADENA;
                    IF iexiste = 0 THEN
                        LET cCodRet = "00001";
                        RETURN cCodRet;	
                    ELSE
                        LET CADENA2=SUBSTR(TRIM(cSTATUS),A,1);
                        UPDATE 	si_seg_usuarios_funciones
                        SET status=CADENA2,fecha_modificacion=dFECHA,
                        id_usuario_modificacion=cID_USUARIO_2,mac_adress_modificacion =cMAC_ADDRESS,ip_modificacion =cIP
                        WHERE id_usuario = cID_USUARIO AND id_funcion = CADENA;
                        LET CADENA="";	
                        LET A=A+1;
                    END IF;
            END FOR
         END IF;
    RETURN cCodRet;
    END
END PROCEDURE
DOCUMENT
"AUTOR : Victor Hugo Sánchez",
"FUNCIONAMIENTO: Este SP sirve para modificar e insertar funciones de un usuario. parametro tipo = 1 inserta un nuevo registro,parametro tipo = 2 actualiza el registro ",
"FECHA : 15-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_buscaperfil(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_PERFIL CHAR (10),cD_PERFIL CHAR(100),cSTATUS CHAR(1),cTIPOBUSQUEDA CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)

    RETURNING CHAR(5),CHAR(10),CHAR(100),CHAR(1);
				

	--Variables
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cId_perfil2		CHAR(10);
	DEFINE cD_perfil2	 	CHAR(100);
	DEFINE cStatus2			char(1);
    DEFINE iCont            INTEGER;

	
	--inicializando variables
	LET iexiste 	= 0;
	LET cCodRet 	= "00000";	
	LET iSql_err 	= 0;
	LET cId_perfil2 = " ";
	LET cD_perfil2	= " ";
	LET cStatus2	= "";
    LET iCont=0;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_buscaperfil_2.out";
		--TRACE ON;
        IF 	cID_USUARIOC ='' 	OR 
            cID_FUNCIONC = '' 	OR 
            cTIPOBUSQUEDA ='' 		THEN
            LET cCodRet = "00003";
            RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
		END IF;

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
		END IF;
		
		IF cTIPOBUSQUEDA <> 1 AND cTIPOBUSQUEDA <> 2 THEN 
			LET cCodRet = "00005";
			RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
		END IF; 	
		IF cTIPOBUSQUEDA = 2 THEN
			IF cID_PERFIL = '' AND  cD_PERFIL = '' AND cSTATUS = '' THEN
				LET cCodRet = "00003";
				RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
			ELSE 
				IF cID_PERFIL <> ''THEN
                    SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} NVL(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles WHERE Id_perfil LIKE TRIM(cID_PERFIL)||'%';
                    IF iexiste = 0 THEN
                        LET cCodRet = "00002";
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF;
					set isolation to dirty read;
					FOREACH
						SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} SKIP pNumRegistro FIRST pRecuperacion Id_perfil,D_perfil,status INTO cId_perfil2,cD_perfil2,cStatus2
						FROM si_seg_perfiles
						WHERE Id_perfil LIKE TRIM(cID_PERFIL)||'%'
                        ORDER BY 1

                        LET iCont=iCont+1;
						RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2 with resume;
					END FOREACH;
                    IF iCont = 0 THEN
                        LET cCodRet = 1001; 
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF 
				ELIF cD_PERFIL <> '' THEN
                    SELECT {+INDEX (bdinteg:si_seg_perfiles idxdperfil)} NVL(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles WHERE d_perfil LIKE TRIM(cD_PERFIL)||'%';
                    IF iexiste = 0 THEN
                        LET cCodRet = "00002";
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF;
					set isolation to dirty read;
					FOREACH
                        SELECT {+INDEX (bdinteg:si_seg_perfiles idxdperfil)} SKIP pNumRegistro FIRST pRecuperacion Id_perfil,D_perfil,status INTO cId_perfil2,cD_perfil2,cStatus2
						FROM si_seg_perfiles
						WHERE d_perfil LIKE TRIM(cD_PERFIL)||'%'
                        ORDER BY 1

                        LET iCont=iCont+1;
						RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2 with resume;
					END FOREACH;
                    IF iCont = 0 THEN
                        LET cCodRet = 1001; 
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF 
				ELIF cSTATUS <> '' THEN
                    SELECT {+INDEX (bdinteg:si_seg_perfiles idxperstatus)} NVL(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles WHERE status LIKE TRIM(cSTATUS)||'%';
                    IF iexiste = 0 THEN
                        LET cCodRet = "00002";
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF;
					set isolation to dirty read;
                        FOREACH
                            SELECT {+INDEX (bdinteg:si_seg_perfiles idxperstatus)} SKIP pNumRegistro FIRST pRecuperacion Id_perfil,D_perfil,status INTO cId_perfil2,cD_perfil2,cStatus2
							FROM si_seg_perfiles
							WHERE status LIKE TRIM(cSTATUS)||'%'
                            ORDER BY 1

                            LET iCont=iCont+1;
							RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2 with resume;
					END FOREACH;
                    IF iCont = 0 THEN
                        LET cCodRet = 1001; 
                        RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
                    END IF 
				END IF;			
			END IF;
		ELIF cTIPOBUSQUEDA = 1 THEN
			IF 	cID_USUARIOC ='' 	OR 
				cID_FUNCIONC = '' 	OR 
				cID_PERFIL ='' 		THEN
				LET cCodRet = "00003";
				RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
			END IF;		
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles where id_perfil = cID_PERFIL;
			IF iexiste = 0 THEN
				LET cCodRet = "00002";
				RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
			END IF;
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} Id_perfil,D_perfil,status INTO cId_perfil2,cD_perfil2,cStatus2
			FROM si_seg_perfiles
			WHERE Id_perfil = cID_PERFIL;

			RETURN cCodRet,cId_perfil2,cD_perfil2,cStatus2;
		END IF;	
	END
END PROCEDURE 
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este SP hara una busqueda de perfil dependiendo del tipo que se requiera, si es del tipo 1 ",
"se hara la busqueda por el ID del perfil si es del tipo 2 se hara la busqueda por los parametros que el usuario indique",
"algunos de los parametros que el usuario puede ingresar son id_perfil, la descripcion del perfil  o el status el sp regresara",
"las coincidencias de los parametros escritos por el usuario",
"NOTA: para la busqueda de tipo 2  se tomara el primer parametro que escriba el usuario, por ejemeplo, si escribe el id_perfil solo se tomara",
"ese parametro para hacer la busqueda y los demas no se tomaran en cuenta.",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_conchequera(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
				returning CHAR(5)  AS Cod_Retorno, 
						  CHAR(20) AS Tipo_Regimen, 
						  DATE     AS Fecha_Recepcion, 
						  CHAR(50)  AS Status, 
						  INTEGER  AS Numero_Cheque_Inicial, 
						  INTEGER  AS Numero_Cheque_Final, 
						  INTEGER  AS Numero_Cheque, 
						  CHAR(10) AS Consecutivo;
				
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
							
--VARIABLES
DEFINE cNumeroCliente  CHAR(20);  -- vnumcte
DEFINE cNumeroCta      CHAR(20);  -- vcuenta
DEFINE cCveTipoRegimen CHAR(1);   -- Reg_firmas, tipo de regimen
DEFINE cTipoRegimen    CHAR(20);
DEFINE dFechaRecepcion DATE;      -- Fecha de Recepcion
DEFINE cStatus         CHAR(1);   -- Cve Estatus
DEFINE iNumCheqInicial INTEGER;   -- numero de cheque inicial
DEFINE iNumCheqFinal   INTEGER;   -- numero de cheque final
DEFINE iNumCheq        INTEGER;   -- numero de cheques
DEFINE cConsecutivo    CHAR(10);  -- consecutivo
DEFINE cDetalleStatus  CHAR(50);  -- Detalle de Estatus

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;
LET cNumeroCliente   = '';	
LET cNumeroCta       = '';
LET cCveTipoRegimen  = '';
LET cTipoRegimen     = '';
LET dFechaRecepcion  = "";
LET cStatus          = "";
LET iNumCheqInicial  = 0 ;
LET iNumCheqFinal    = 0 ;
LET iNumCheq         = 0 ;
LET cConsecutivo     = "";
LET cDetalleStatus   = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cTipoRegimen, dFechaRecepcion, cDetalleStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_conchequera.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = '' THEN 
		LET cCodRet = "00069";
		RETURN cCodRet,cTipoRegimen, dFechaRecepcion, cDetalleStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo;						
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'30','1')
	INTO
	cCodRet;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cTipoRegimen, dFechaRecepcion, cDetalleStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo;						
	END IF;
	-- TERMINA VALIDACION
	
	SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE empresa = '001' AND  cuenta = cNUMCUENTA; 
	IF iexiste  = 0 THEN 
	LET cCodRet = "00070";
	RETURN cCodRet,cTipoRegimen, dFechaRecepcion, cDetalleStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo;						
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	
	FOREACH 
	 EXECUTE PROCEDURE bdicntchq:sp_conchequera('001',cNUMCUENTA,'0')
	 INTO 		
	 cCodRet, cNumeroCliente, cNumeroCta, cCveTipoRegimen, dFechaRecepcion,
	 cStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo, cDetalleStatus
	 
	IF cCveTipoRegimen = '1' THEN
		LET cTipoRegimen = 'INDIVIDUAL';
	ELIF cCveTipoRegimen = '2' THEN
		LET cTipoRegimen = 'INDISTINTA';
	ELIF cCveTipoRegimen = '3' THEN
		LET cTipoRegimen = 'MANCOMUNADA';
	ELSE
		LET cTipoRegimen = 'OTRA';
	END IF;

	IF LENGTH(cCodRet) = 3 THEN
	 LET cCodRet = '00' || cCodRet;
	END IF;
	
	RETURN 	cCodRet,cTipoRegimen, dFechaRecepcion, cDetalleStatus, iNumCheqInicial, iNumCheqFinal, iNumCheq, cConsecutivo WITH resume;	
	
	END FOREACH;
		
		
			
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las Chequeras asociadas a una Cuenta de cheques. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cuenta",
"FECHA : 27-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consctesfirxnumcta(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))

RETURNING 	CHAR(5)  	AS Cod_Retorno,
			CHAR(20) 	AS Numero_Cuenta,
			CHAR(20)	 AS Numero_Cliente,
			CHAR(26) 	AS Nombre_1,
			CHAR(26) 	AS Nombre_2,
			CHAR(26) 	AS Apellido_Paterno,
			CHAR(26) 	AS Apellido_Materno,
			DATE     	AS Fecha_Nacimiento,
			CHAR(13) 	AS RFC,
			CHAR(2)  	AS CveTipo_Persona,
			CHAR(20) 	AS DescTipo_Persona,
			CHAR(30) 	AS Parentesco,
			MONEY(14,2) AS Porcentaje,
			CHAR(20) 	AS Tipo;


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cNumero_cuenta	CHAR(20);
DEFINE cNumero_cliente	CHAR(20);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cAPaterno		CHAR(26);
DEFINE cAMaterno		CHAR(26);
DEFINE dFNacimiento		DATE;
DEFINE crfc				CHAR(13);
DEFINE cTpersona		CHAR(2);
DEFINE cTPdescripcion	CHAR(20);
DEFINE cParentesco		CHAR(30);
DEFINE mPORCENTAJE		MONEY(14,2);
DEFINE cTIPO			CHAR(20);
DEFINE iContador        SMALLINT;



-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret 		= "00000";
LET cNumero_cuenta	= "";
LET cNumero_cliente	= "";
LET cNombre1		= "";
LET cNombre2		= "";
LET cAPaterno		= "";
LET cAMaterno		= "";
LET dFNacimiento	= "";
LET crfc			= "";
LET cTpersona		= "";
LET cTPdescripcion	= "";
LET cParentesco		= "";
LET mPORCENTAJE		= 0;
LET cTIPO			= "";
LET iContador       = 0;



-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO;
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consctesfirxnumcta.out";
--TRACE ON;
  IF cID_USUARIOC = "" OR 
	 cID_FUNCIONC = "" OR
     cNUMCUENTA  = ""  THEN
     LET scod_ret = "00036";
     RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO;
  END IF;

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO;
	END IF;
	-- TERMINA VALIDACION  
  
  -- Extrae FIRMANTES
  FOREACH
	SELECT numcte,cuenta,'A',parentesco
	INTO  cNumero_cliente,cNumero_cuenta,cTIPO,cParentesco
	FROM bdicheq:sc_firmantes
	WHERE cuenta = cNUMCUENTA ORDER BY secuencia
	
	SELECT descripcion 
	INTO  cParentesco 
	FROM bdinteg:si_parentesco
	WHERE parentesco  = cParentesco;
	
    
	SELECT  CL.nombre1,CL.nombre2, CL.apell_paterno,CL.apell_materno,CL.rfc,CL.tpo_persona,TP.descripcion
    INTO 
	cNombre1,cNombre2,cAPaterno,cAMaterno,crfc,cTpersona,cTPdescripcion
    FROM 
	bdinteg:si_cliente  CL,
	bdinteg:si_tipper TP
	WHERE  numcte = cNumero_cliente
	AND CL.tpo_persona=TP.tpo_persona;
	
	SELECT fecha_nac 
	INTO dFNacimiento
	FROM bdinteg:si_ctepf
	WHERE numcte =cNumero_cliente;
	
	LET iContador=1;
 	RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO WITH RESUME;

  END FOREACH

  -- Extrae los beneficiaros
  FOREACH
	SELECT numcte,cuenta,'B',parentesco,porcentaje
	INTO  cNumero_cliente,cNumero_cuenta,cTIPO,cParentesco,mPORCENTAJE
	FROM bdicheq:sc_beneficiario
	WHERE cuenta = cNUMCUENTA ORDER BY numcte
	
	SELECT descripcion 
	INTO  cParentesco 
	FROM bdinteg:si_parentesco
	WHERE parentesco  = cParentesco;
	
    
	SELECT  CL.nombre1,CL.nombre2, CL.apell_paterno,CL.apell_materno,CL.rfc,CL.tpo_persona,TP.descripcion
    INTO 
	cNombre1,cNombre2,cAPaterno,cAMaterno,crfc,cTpersona,cTPdescripcion
    FROM 
	bdinteg:si_cliente  CL,
	bdinteg:si_tipper TP
	WHERE  numcte = cNumero_cliente
	AND CL.tpo_persona=TP.tpo_persona;
	
	SELECT fecha_nac 
	INTO dFNacimiento
	FROM bdinteg:si_ctepf
	WHERE numcte =cNumero_cliente;
	
	LET iContador=1;  
	RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO WITH RESUME;

  END FOREACH;
  
  IF iContador=0 THEN
    LET scod_ret='00095';
    RETURN scod_ret,cNumero_cuenta, cNumero_cliente, cNombre1,cNombre2,cAPaterno,cAMaterno, dFNacimiento, crfc,cTpersona,cTPdescripcion,cParentesco,mPORCENTAJE,cTIPO;
  END IF;
END

END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda de adicionados y beneficiarios  de los clientes dependiendo del numero de cuenta que se el envie al SP",
"FECHA : 05-01-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consulta_amortizaciones_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)        AS Codigo_Retorno,       
						  DATE           AS Fecha_Cuota, 
						  INTEGER        AS Num_Pago,		  
						  DECIMAL(18,2)  AS Monto_Capital,
						  DECIMAL(18,2)  AS Pagado_Capital, 
						  DECIMAL(18,2)  AS Saldo_Capital,
						  DECIMAL(18,2)  AS Monto_Interes,
						  DECIMAL(18,2)  AS Pagado_Interes,
						  DECIMAL(18,2)  AS Saldo_Interes, 
						  DECIMAL(18,2)  AS Monto_mora,
						  DECIMAL(18,2)  AS Pagado_Mora,
						  DECIMAL(18,2)  AS Saldo_Moratorio,
						  DECIMAL(18,2)  AS Monto_Iva_Mora,
						  DECIMAL(18,2)  AS Pagado_iva_Mora,		  
						  DECIMAL(18,2)  AS Saldo_Iva_Mora,
						  DECIMAL(18,2)  AS Monto_Iva_Intereses,
						  DECIMAL(18,2)  AS Pagado_Iva_Intereses,
						  DECIMAL(18,2)  AS Saldo_Iva_Intereses,						  						  
						  CHAR(11)       AS Status_Principal;
						
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE ccodRetS        CHAR(6);        
DEFINE cErrorInfoR      CHAR(80);
DEFINE dtFechaCuota    DATE;
DEFINE iNumPago        INTEGER;
DEFINE dMontoCap       DECIMAL(18,2);
DEFINE dPagadoCap      DECIMAL(18,2);
DEFINE dSaldoCap       DECIMAL(18,2);
DEFINE dMontoint       DECIMAL(18,2);
DEFINE dPagadoint      DECIMAL(18,2);
DEFINE dSaldoint       DECIMAL(18,2);
DEFINE dMontoMora      DECIMAL(18,2);
DEFINE dPagoMora       DECIMAL(18,2);
DEFINE dSaldoMora      DECIMAL(18,2);
DEFINE dMonIvaMora     DECIMAL(18,2);
DEFINE dPagoIvaMora    DECIMAL(18,2);
DEFINE dSldIvaMora     DECIMAL(18,2);
DEFINE Monto_Iva_Intereses	 DECIMAL(18,2);  
DEFINE Pagado_Iva_Intereses	 DECIMAL(18,2);  
DEFINE Saldo_Iva_Intereses	 DECIMAL(18,2);   
DEFINE cStatus               CHAR(11);
DEFINE dSdoAmortiza          DECIMAL(18,2);

DEFINE iCont INTEGER;
--INICIALIZA VARIABLES
LET cCodRetS        = "";
LET cErrorInfoR     = "";     
LET dtFechaCuota    = "";
LET iNumPago        = 0;
LET dMontoCap       = 0;
LET dPagadoCap      = 0;
LET dSaldoCap       = 0;
LET dMontoint       = 0;
LET dPagadoint      = 0;
LET dSaldoint       = 0;
LET dMontoMora      = 0;
LET dPagoMora       = 0;
LET dSaldoMora      = 0;
LET dMonIvaMora     = 0;
LET dPagoIvaMora    = 0;
LET dSldIvaMora     = 0;
LET	Monto_Iva_Intereses	 = 0;  
LET	Pagado_Iva_Intereses	 = 0;  
LET	Saldo_Iva_Intereses	 = 0; 
LET cStatus         = '';
LET dSdoAmortiza    = 0;
LET iCont=0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,dtFechaCuota, NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_amortizaciones_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet,dtFechaCuota, NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet,dtFechaCuota, NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
		RETURN
			cCodRet,dtFechaCuota, NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
				cCodRet,dtFechaCuota, NVL(iNumPago,0), 
				NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
				NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
				NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
				NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');
	END IF;
	-- TERMINA VALIDACION	
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN 
			cCodRet,dtFechaCuota, NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'');
		END IF;
		
		IF pNumRegistro = 0 THEN
			DELETE FROM si_tempoamortizaciones WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
            SET ISOLATION TO DIRTY READ;
			FOREACH
			
				EXECUTE PROCEDURE bdicred:sp_consulta_amortizaciones_general ('001',cNUMCUENTA)
				INTO
				cCodRetS,cErrorInfoR,dtFechaCuota, iNumPago, dMontoCap, dPagadoCap, dSaldoCap, dMontoint,
				dPagadoint,dSaldoint,dMontoMora,dPagoMora,dSaldoMora,dMonIvaMora,dPagoIvaMora,dSldIvaMora,
				cStatus,dSdoAmortiza       

                IF cCodRetS<>'000000'  THEN

                    LET cCodRet = SUBSTR(cCodRetS,2,6);

                    IF cCodRet='00001' THEN
                        LET cCodRet ='00047';
                    ELIF cCodRet='00002' THEN
                        LET cCodRet ='00017';
                    END IF;    
                    RETURN  
                        cCodRet,dtFechaCuota, NVL(iNumPago,0), 
                        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
                        NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
                        NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
                        NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,''); 
                END IF;
					
				INSERT INTO si_tempoamortizaciones(codigo_retorno,fecha_cuota,num_pago,monto_capital,pagado_capital,saldo_capital,monto_interes,pagado_interes,
												   saldo_interes,monto_mora,pagado_mora,saldo_moratorio,monto_iva_mora,pagado_iva_mora,saldo_iva_mora,
												   monto_iva_intereses,pagado_iva_intereses,saldo_iva_intereses,status_principal,cuenta,ejecutivosif)
				VALUES(cCodRetS,dtFechaCuota, iNumPago,dMontoCap,dPagadoCap,dSaldoCap,dMontoint,dPagadoint,dSaldoint,dMontoMora,dPagoMora,dSaldoMora,dMonIvaMora,
					   dPagoIvaMora,dSldIvaMora,Monto_Iva_Intereses,Pagado_Iva_Intereses,Saldo_Iva_Intereses,cStatus,cNUMCUENTA,cID_USUARIOC);
				
			END FOREACH;
	
		END IF;
		
		SELECT NVL(COUNT(codigo_retorno),0) into iexiste FROM si_tempoamortizaciones WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00090";
            RETURN  
				cCodRet,dtFechaCuota, NVL(iNumPago,0), 
				NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
				NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
				NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
				NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,''); 
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
		
		SELECT SKIP pNumRegistro FIRST pRecuperacion
		codigo_retorno,fecha_cuota,num_pago,monto_capital,pagado_capital,saldo_capital,monto_interes,pagado_interes,
		saldo_interes,monto_mora,pagado_mora,saldo_moratorio,monto_iva_mora,pagado_iva_mora,saldo_iva_mora,
		monto_iva_intereses,pagado_iva_intereses,saldo_iva_intereses,status_principal
		INTO
		cCodRetS,dtFechaCuota, iNumPago,dMontoCap,dPagadoCap,dSaldoCap,dMontoint,dPagadoint,dSaldoint,dMontoMora,dPagoMora,dSaldoMora,dMonIvaMora,
		dPagoIvaMora,dSldIvaMora,Monto_Iva_Intereses,Pagado_Iva_Intereses,Saldo_Iva_Intereses,cStatus
		FROM si_tempoamortizaciones
		WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha_cuota
		
		LET cCodRet = SUBSTR(cCodRetS,2,6);
			   
		LET iCont=iCont + 1;
		
		RETURN 
				cCodRet,dtFechaCuota, NVL(iNumPago,0), 
				NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
				NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
				NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
				NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,'') WITH RESUME;
				
		END FOREACH;
		
		IF iCont = 0 THEN
		    DELETE FROM si_tempoamortizaciones WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = 1001; 
            RETURN  
				cCodRet,dtFechaCuota, NVL(iNumPago,0), 
				NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
				NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
				NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
				NVL(Monto_Iva_Intereses,0), NVL(Pagado_Iva_Intereses,0), NVL(Saldo_Iva_Intereses,0), NVL(cStatus,''); 
        END IF 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de la Tabla de Amortizaciones relacionada con una Cuenta de Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, se enviará como parámetro el No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consulta_disposiciones_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)                      AS Cod_Retorno,       
						  DATE                         AS Fecha,
						  DATETIME HOUR TO FRACTION(3) AS Hora,
						  CHAR(16)                     AS Folio,
						  DECIMAL(18,2)                AS Importe,
						  VARCHAR(140)                 AS Tipo;					
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cCodRetS       CHAR(6);
DEFINE cMensaje       CHAR(80);

DEFINE dtFechaMov     DATE;
DEFINE dtHoraMov      DATETIME HOUR TO FRACTION;
DEFINE cFolioSuc      CHAR(16);
DEFINE dMonto         DECIMAL(18,2);
DEFINE vDescripcion   VARCHAR(140);
DEFINE dLinAut        DECIMAL(18,2);

DEFINE iCont          INTEGER;

--INICIALIZA VARIABLES
LET dtFechaMov     = DATE(1);
LET dtHoraMov      = CURRENT;
LET cFolioSuc      = "";
LET dMonto          = 0;
LET vDescripcion    = "";
LET dLinAut         = 0;
LET iCont           = 0;
LET cCodRetS        = "";
LET cMensaje        = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_disposiciones_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
		RETURN
			cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
        END IF;
    END IF;    
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
	END IF;
	-- TERMINA VALIDACION		
	FOREACH
        SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
        UNION
        SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
    END FOREACH;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN 
		cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
	END IF;
	
	IF pNumRegistro = 0 THEN
		DELETE FROM si_tempodisposiciones WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:sp_consulta_disposiciones_general  ('001',cNUMCUENTA)
			INTO
			cCodRetS,cMensaje, dtFechaMov, dtHoraMov, cFolioSuc, dMonto, vDescripcion, dLinAut
			
			LET cCodRet = SUBSTR(cCodRetS,2,6);
	
			IF cCodRet != '00000' THEN	
                IF cCodRet='00002' THEN
                    LET cCodRet ='00017';
                END IF;
				RETURN  
				cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
			END IF;
	
			INSERT INTO si_tempodisposiciones(cod_ret,fecha,hora,folio,importe,tipo,cuenta,ejecutivosif) 
			VALUES(cCodRetS,dtFechaMov, dtHoraMov, cFolioSuc, dMonto, vDescripcion, cNUMCUENTA,cID_USUARIOC);
			
		END FOREACH;

	END IF
	
	SET ISOLATION TO DIRTY READ;
    FOREACH
	
        SELECT SKIP pNumRegistro FIRST pRecuperacion
        cod_ret,fecha,hora,folio,importe,tipo
        INTO
        cCodRetS,dtFechaMov, dtHoraMov, cFolioSuc, dMonto, vDescripcion
        FROM si_tempodisposiciones
        WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha,hora desc

        LET cCodRet = SUBSTR(cCodRetS,2,6);

        LET iCont=iCont + 1;

        RETURN 
                cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'') WITH RESUME;
			
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE FROM si_tempodisposiciones WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
		LET cCodRet = '1001'; 
		RETURN  
		cCodRet, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,'');
	END IF 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las Disposiciones asociadas a una Cuenta de Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Cuenta.",
"FECHA : 06-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultaejecutivo(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO CHAR(8))

    RETURNING CHAR(5),CHAR(8),CHAR(1),CHAR(15),CHAR(17),CHAR(45),INTEGER;


	--Variables
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cNumero_empleado		CHAR(8);
	DEFINE cUsu_estado		 	CHAR(1);
	DEFINE cUsu_ip				CHAR(15);
	DEFINE cUsu_mac				CHAR(17);
	DEFINE cNombre				char(45);
	DEFINE iUsu_bloqueo 		INTEGER;



	--inicializando variables
	LET iexiste 	= 0;
	LET cCodRet 	= "00000";
	LET iSql_err 	= 0;
	LET cNumero_empleado = " ";
	LET cUsu_estado	= " ";
	LET cUsu_ip	= "";
	LET cUsu_mac = " ";
	LET cNombre = "" ;
	LET iUsu_bloqueo = 0;
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaejecutivo.out";
		--	TRACE ON;
		IF cID_USUARIO = '' OR
			cID_USUARIOC = '' OR
			cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo;
		END IF;
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo;
		END IF;		
		
		SELECT NVL(COUNT(ejecutivo),0) INTO iexiste FROM si_ejecut WHERE ejecutivo = cID_USUARIO;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo;
		END IF;
		set isolation to dirty read;
		--FOREACH
			SELECT limit 1 EJ.ejecutivo, MA.status, SM.ipmaquina, Ma.mac, EJ.nombre, nvl(us.usu_bloqueo,0)
			INTO cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo
			FROM si_ejecut EJ
			LEFT JOIN si_macejecutivo MA
			ON  MA.ejecutivo = EJ.ejecutivo
			LEFT JOIN si_sucursalesmaquina SM
			ON  SM.mac=MA.mac
			LEFT JOIN si_seg_usuarios US
			ON US.id_usuario = EJ.ejecutivo
			WHERE EJ.ejecutivo = cID_USUARIO;
			RETURN cCodRet,cNumero_empleado,cUsu_estado,cUsu_ip,cUsu_mac,cNombre,iUsu_bloqueo;
		--END FOREACH;
	END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp hara la busqueda de los datos de ejecutivo por el Id_usuario y regresara atos como numero del ejecutivo, el status, la mac Address de su maquina",
"la ip de su maquina y el nombre del ejecutivo",
"FECHA : 27-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultaempleado(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMEMPLE CHAR(8))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(8)  AS Numero_Empleado,
						  CHAR(45) AS Nombre,
						  CHAR(30) AS Cargo,
						  CHAR(45) AS Sucursal;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--CLIENTES VARIABLES
DEFINE cNoempleado	       CHAR(8);
DEFINE cNombre	           CHAR(45);
DEFINE cCargo	           CHAR(30);
DEFINE cSucursal		   CHAR(45);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cNoempleado         ="";
LET cNombre 			= "";
LET cCargo				= "";
LET cSucursal			= "";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cNoempleado,cNombre,cCargo,cSucursal;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaempleado.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMEMPLE  = ''	THEN 
		LET cCodRet = "00054";
		RETURN cCodRet,cNoempleado,cNombre,cCargo,cSucursal;
	END IF;	

	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = '00028' THEN 
		RETURN cCodRet,cNoempleado,cNombre,cCargo,cSucursal;
	END IF;			
	
	SELECT NVL(COUNT(ejecutivo),0) into iexiste FROM si_ejecut WHERE ejecutivo  = cNUMEMPLE;
	
	IF iexiste  = 0 THEN 
		LET cCodRet = "00072";
		RETURN cCodRet,cNoempleado,cNombre,cCargo,cSucursal;
	END IF;
		
	SELECT LIMIT 1 e.ejecutivo,e.nombre,p.nombramiento as cargo,s.sucursal|| ' ' ||s.nombre as sucursal
	INTO 		
	cNoempleado,cNombre,cCargo,cSucursal		
	FROM si_ejecut e
	LEFT JOIN si_puestosrelacion p
	ON  e.puesto = p.puesto_bancoppel
	LEFT JOIN si_sucursales s
	ON  e.sucursal = s.sucursal
	WHERE e.empresa='001' and e.ejecutivo = cNUMEMPLE;
	
	RETURN cCodRet,cNoempleado,cNombre,cCargo,cSucursal;

END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Realizar la Búsqueda de Ejecutivos BanCoppel  en la Base de Datos central de Informix, enviando como parámetro el  No. de Empleado",
"FECHA : 16-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultafecha()

    RETURNING CHAR(5),DATE,DATETIME HOUR to FRACTION(3);


	DEFINE cCodRet 		CHAR(5);
	DEFINE iSql_err 	INT;
	DEFINE dFecha	 	DATE;
	DEFINE dHora		DATETIME HOUR to FRACTION(3);


	LET cCodRet = "00000";
	LET iSql_err = 0;
	LET	dFecha ="";
	LET dHora = TO_DATE("00:00","%H:%M");

	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,dFecha,dHora;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultafecha.out";
		--TRACE ON;
		LET dFecha = current;
		LET dHora = current;
		RETURN  cCodRet,dFecha,dHora with resume;
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este sp regresa la fecha y la hora actual",
"FECHA : 28-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultamodulo(cID_USUARIOC char(8),cID_FUNCIONC char(10))
 
    RETURNING CHAR(5),CHAR(6),CHAR(20),CHAR(1);
													
	DEFINE iexiste 		INT;
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSql_err 	INT;
    DEFINE iBan          INT;
	DEFINE cId_modulo 	CHAR(6);
	DEFINE cD_Modulo	CHAR(20);
	DEFINE cStatus		CHAR(1);
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_modulo ="00";
	LET cD_modulo = "00";
	LET cStatus = "0";
    LET iBan = 0;
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_modulo,cD_modulo,cStatus;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaamodulo.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_modulo,cD_modulo,cStatus;
		END IF;	

		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_modulo,cD_modulo,cStatus;
		END IF;
		
		SELECT {+INDEX (bdinteg:si_seg_modulos idxidmodulo)} nvl(Count(id_modulo),0) INTO iexiste  FROM si_seg_modulos where id_modulo is not null;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_modulo,cD_modulo,cStatus;
		END IF;
        set isolation to dirty read;
		FOREACH
			SELECT {+INDEX (bdinteg:si_seg_modulos idxidmodulo)} Id_modulo, D_modulo,Status INTO cId_modulo,cD_modulo,cStatus FROM si_seg_modulos where id_modulo is not null
			RETURN cCodRet,cId_Modulo,cD_modulo,cStatus with resume;
		END FOREACH;		
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP regresara todos los modulos que se encuentran registrados dentro de la base de datos ",
"FECHA : 20-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultanivel(cID_USUARIOC char(8),cID_FUNCIONC char(10))
 
    RETURNING CHAR(5),INTEGER,CHAR(60);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cId_nivel_consulta	INTEGER;
	DEFINE cD_nivel_consulta	CHAR(60);
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_nivel_consulta ="00";
	LET cD_nivel_consulta = "00";

	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_nivel_consulta,cD_nivel_consulta;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultanivel.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_nivel_consulta,cD_nivel_consulta;
		END IF;		
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_nivel_consulta,cD_nivel_consulta;
		END IF;		
		
		SELECT {+INDEX (bdinteg:si_seg_nivel_consulta idxnivc)} nvl(Count(id_nivel_consulta),0) INTO iexiste  FROM si_seg_nivel_consulta where id_nivel_consulta is not null;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_nivel_consulta,cD_nivel_consulta;
		END IF;
		set isolation to dirty read;
        FOREACH
			SELECT {+INDEX (bdinteg:si_seg_nivel_consulta idxnivc)} Id_nivel_consulta, D_nivel_consulta 
			INTO cId_nivel_consulta,cD_nivel_consulta
			FROM si_seg_nivel_consulta where id_nivel_consulta is not null
			RETURN cCodRet,cId_nivel_consulta,cD_nivel_consulta with resume;
		END FOREACH;		
    END
END PROCEDURE	
DOCUMENT	
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP regresara todos los niveles de consulta que existen dentro de la base de datos ",
"FECHA : 28-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultaperfil(cID_USUARIOC char(8),cID_FUNCIONC char(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
 
    RETURNING CHAR(5),CHAR(10),CHAR(100),CHAR(1);
													
	DEFINE iexiste 		INT;
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSql_err 	INT;
	DEFINE cId_perfil 	CHAR(10);
	DEFINE cD_perfil	CHAR(100);
	DEFINE cStatus		CHAR(1);
    DEFINE iCont        INTEGER;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_perfil ="00";
	LET cD_perfil = "00";
	LET cStatus = "0";
    LET iCont=0;

	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaperfil.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;
		
		SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles where id_perfil is not null;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
		END IF;
		set isolation to dirty read;
        FOREACH
			SELECT {+INDEX (bdinteg:si_seg_perfiles idxidperseg)} SKIP pNumRegistro FIRST pRecuperacion Id_perfil, D_perfil,Status INTO cId_perfil,cD_perfil,cStatus FROM si_seg_perfiles 
            where id_perfil is not null order by 2

            LET iCont=iCont+1;

			RETURN cCodRet,cId_perfil,cD_perfil,cStatus with resume;
		END FOREACH;
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cId_perfil,cD_perfil,cStatus;
        END IF 		
    END
END PROCEDURE	
DOCUMENT	
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este sp consultara y regresara los resultados de todos los perfiles creados dentro de la base", 
"FECHA : 23-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_consultaperfilfuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_PERFIL CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5),CHAR(10),CHAR(100),CHAR(6),CHAR(20),INTEGER,CHAR(60), CHAR(1),INTEGER, CHAR(1);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cID_FUNCION			CHAR(10);
	DEFINE cD_FUNCION			CHAR(100);
	DEFINE cID_MODULO			CHAR(6);
	DEFINE cD_MODULO			CHAR(20);
	DEFINE iID_SUBMODULO		INTEGER;
	DEFINE cD_SUBMODULO			CHAR(60);
	DEFINE cSTATUS_FUNCION		CHAR(1);
	DEFINE iORDEN				INTEGER;
	DEFINE cSTATUS_FUNCIONP		CHAR(1);
	DEFINE iCont            INTEGER;
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cID_FUNCION = " ";
	LET cD_FUNCION	= " ";
	LET cID_MODULO = " ";	
	LET cD_MODULO	= " ";	
	LET iID_SUBMODULO = 0	;
	LET cD_SUBMODULO =  " ";
	LET cSTATUS_FUNCION = " ";
	LET iORDEN	= 0;
	LET cSTATUS_FUNCIONP = " ";
    LET iCont=0;
	
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaperfilfuncion.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' 	OR
		cID_PERFIL = ''	THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;		
	
        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
            END IF;
        END IF; 
	
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;		
		
		SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxidperfu)} nvl(Count(id_perfil),0) INTO iexiste  FROM si_seg_perfiles_funciones WHERE id_perfil= cID_PERFIL;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
		END IF;
		set isolation to dirty read;
		FOREACH
			SELECT {+INDEX (bdinteg:si_seg_perfiles_funciones idxidperfu)} SKIP pNumRegistro FIRST pRecuperacion PF.id_funcion, FU.d_funcion, FU.id_modulo,MO.d_modulo, FU.id_submodulo, SU.d_submodulo,  Fu.status, FU.orden,PF.status 
			INTO
			cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP
			FROM  si_seg_perfiles_funciones  PF
			LEFT JOIN si_seg_funciones FU
			ON PF.id_funcion  = FU.id_funcion 
			LEFT JOIN si_seg_modulos MO
			ON MO.id_modulo = FU.Id_modulo
			LEFT JOIN si_seg_submodulo SU
			ON SU.id_submodulo = FU.id_submodulo
			WHERE id_perfil= cID_PERFIL
            order by orden,id_submodulo

            LET iCont=iCont+1;
			RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP with resume;
		END FOREACH
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,cSTATUS_FUNCION,iORDEN,cSTATUS_FUNCIONP;
        END IF 
    END
END PROCEDURE	
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP regresara el  perfil de funciones que se encuentra registrado en la base de la tabla si_seg_funciones", 
"dependiendo del Id_perfil que envie al SP, se regresaran datos como el id_funcion, la descripcion , el id_modulo, la descripcion del modulo,", 
"el id_submodulo, la descripcion del submodulo, el orden y el status ",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_detalleburo(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMSOL CHAR(20),cInstitucion CHAR(03))
							
				returning CHAR(5)   AS Cod_Retorno,
						  CHAR(255) AS Datos_Personales,
						  CHAR(257) AS Direccion,
						  CHAR(510) AS Tipo_Rechazo;
				
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cDatosPersonales	   CHAR(255);
DEFINE cDireccion	       CHAR(255);
DEFINE cTiporechazo	       CHAR(500);
--VARIABLE PARA CACHAR CAMPOS DEL PROCEDIMIENTO
DEFINE vCcod_Ret   CHAR(5);
DEFINE vMensaje1 CHAR(255);
DEFINE vMensaje2 CHAR(255);


--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cDatosPersonales	= "";
LET cDireccion 			= "";
LET cTiporechazo		= "";
LET vCcod_Ret	   = "00000";
LET vMensaje1		    = "";
LET vMensaje2		    = "";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_detalleburo_2.out";
	--TRACE ON;
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMSOL,'22','6')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
	END IF;
	-- TERMINA VALIDACION
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMSOL  = ''	THEN 
		LET cCodRet = "00059";
		RETURN
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
	END IF;	

		SELECT NVL(COUNT(num_solicitud),0) into iexiste FROM bdiburo:br_traslado WHERE num_solicitud  = cNUMSOL;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00073";
			RETURN 
			cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
		END IF;
		 
		select envio[89,250],'PA' || trim(envio1)
		INTO cDatosPersonales,cDireccion
		from bdiburo:br_traslado  
		Where  num_solicitud = cNUMSOL	
		AND    institucion   = cInstitucion;
		
		set isolation to dirty read;
		FOREACH
			execute procedure bdiburo:sp_consulta_error(cInstitucion,cNUMSOL)
			INTO vCcod_Ret,vMensaje1,vMensaje2 
		END FOREACH;
		
		IF LENGTH(vCcod_Ret) = 3 THEN
			LET  cCodRet = '00' || vCcod_Ret;
		ELIF LENGTH(vCcod_Ret) = 5 THEN
			LET  cCodRet = vCcod_Ret;
		END IF
		
		LET cTiporechazo = vMensaje1 || vMensaje2;
		
		RETURN 
		cCodRet,cDatosPersonales,cDireccion,cTiporechazo;
			
		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del detalle de la Consulta al Buró de Crédito. El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Solicitud",
"FECHA : 13-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_empcli(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(3)  AS Cve_Empresa,
						  CHAR(60) AS Nombre,
						  CHAR(30) AS Puesto,
						  CHAR(02) AS Puesto_Especial,
						  DECIMAL(4,2) AS Antiguedad,
						  CHAR(40) AS Nombre_Departamento,
						  MONEY(14,2) AS Ingreso_Mensual;
									
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--CLIENTES VARIABLES
DEFINE cEmpresa		        CHAR(3);
DEFINE cNombre	           CHAR(60);
DEFINE cPuesto	           CHAR(30);
DEFINE cPuestoEsp		   CHAR(02);
DEFINE dAntiguedad	   DECIMAL(4,2);
DEFINE cNombreDepto		   CHAR(40);
DEFINE mIngresoMensual	MONEY(14,2);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cEmpresa	 		= "";
LET cNombre 			= "";
LET cPuesto				= "";
LET cPuestoEsp			= "";
LET dAntiguedad			=  0;
LET cNombreDepto		= "";
LET mIngresoMensual 	=  0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_empcli.out";
	--	TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE  = ''	THEN 
		LET cCodRet = "00054";
		RETURN
			cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'06','2')
	INTO
	cCodRet;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;
	-- TERMINA VALIDACION		
/*
	SELECT NVL(COUNT(numcte),0) into iexiste FROM bdisolic:ss_solicitudes WHERE numcte  = cNUMCLIENTE;
	
	IF iexiste  = 0 THEN 
		LET cCodRet = "00022";
		RETURN 
		cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual;
	END IF;
*/		
	SELECT  LIMIT 1 nvl(ing.empresa,'') as Empresa,rpad(TRIM(nvl(ing.nombre_empresa,'')),25,' ') AS nombre_empresa, 
			rpad(TRIM(nvl(puest.descripcion,'')),30,' ') as puesto, nvl(puesto_esp,'') as puestoEsp,nvl(antiguedad,0) as antiguedad,
			nvl(nombre_depto,'') as nombreDepto,nvl(ing.ingreso_mensual, 0) AS ingresomensual
	INTO 		
	cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual		
	FROM  bdisolic:ss_solicitudes cte 
	LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa 
	AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos ing1 
	WHERE ing1.empresa=cte.empresa AND ing1.numcte = cte.numcte)) 
	LEFT OUTER JOIN bdinteg:si_puestos  puest  ON (puest.puesto = ing.puesto) 
	WHERE cte.empresa= '001' AND cte.numcte= cNUMCLIENTE;
	
	RETURN 
	cCodRet,cEmpresa,cNombre,cPuesto,cPuestoEsp,dAntiguedad,cNombreDepto,mIngresoMensual ;

END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Datos del Empleo de un Cliente.  El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Cliente",
"FECHA : 10-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_maxedocta(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMEMPLEADO CHAR(20))

				returning CHAR(5)  AS Cod_Retorno,
						  INTEGER  AS Consulta;
								
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;
--CLIENTES VARIABLES
DEFINE iConsulta	   INTEGER;

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;
LET iConsulta	 		= 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,iConsulta;
		END IF;
	END EXCEPTION;
	
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_maxedocta.out";
	--	TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMEMPLEADO  = ''	THEN
		LET cCodRet = "00036";
		RETURN
			cCodRet,iConsulta;
	END IF;
	
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

		IF cCodRet = '00028' THEN 
			RETURN cCodRet,iConsulta;
		END IF;			

	SET ISOLATION TO DIRTY READ;
	
	SELECT max(consulta)
	INTO iConsulta
	FROM bdicheq:vedocta
	WHERE empresa = '001'
	AND cod_usuario = cNUMEMPLEADO;

	RETURN
	cCodRet,iConsulta;

		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la consulta Máxima para ejecutar el SP de Movimiento al Detalle. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Empleado.",
"FECHA : 12-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_validaipmacejecutivo(cIDUSUARIO CHAR(8),cIP CHAR(16), cMAC CHAR(18))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(8)  AS Numero_Empleado,
						  CHAR(45) AS Nombre;
				
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
-- VARIABLES
DEFINE cNumeroEmpleado   	CHAR(8);
DEFINE cNombre	   		    CHAR(45);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	

LET cNumeroEmpleado	 	= "";
LET cNombre		        =  "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
	END EXCEPTION;
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_validaipmacejecutivo.out";
	--	TRACE ON;
	IF 	cIDUSUARIO   = ''   OR
		cIP          = ''   OR
		cMAC         = '' THEN 
		LET cCodRet = "00003";
		RETURN
			cCodRet, cNumeroEmpleado, cNombre;
	END IF;	

		SELECT NVL(COUNT(ejecutivo),0) into iexiste FROM si_ejecut WHERE ejecutivo  = cIDUSUARIO;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00025";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		SELECT NVL(COUNT(mac),0) into iexiste FROM si_macejecutivo WHERE mac  = cMAC;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00026";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		SELECT NVL(COUNT(ipmaquina),0) into iexiste FROM si_sucursalesmaquina WHERE ipmaquina  = cIP;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00027";
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre;
		END IF;
		set isolation to dirty read;
		FOREACH 			
			SELECT si.ejecutivo,si.nombre
			INTO 
			cNumeroEmpleado, cNombre
			FROM si_ejecut si
			LEFT JOIN si_macejecutivo mac
			ON si.ejecutivo = mac.ejecutivo
			LEFT JOIN si_sucursalesmaquina sm
			ON mac.mac = sm.mac
			WHERE si.ejecutivo = cIDUSUARIO
			AND mac.mac = cMAC
			AND sm.ipmaquina = cIP
			
			
			RETURN 
			cCodRet, cNumeroEmpleado, cNombre with resume;
			
		END FOREACH;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Realizar la validación de los Ejecutivos BanCoppel existentes en la Base de Datos central de Informix.",
"FECHA : 08-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_actualizastatususuario_bei(pEmpresa char(3), pNumCliente char(20), pUsuario char(50), 
pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
   returning char(5);

   --Modificó: Manuel Ramos Figueroa
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Fecha: 01-09-2011
--
   --Modificó: Ing. Alfonso Cruz
   --Actividad: INSERTA EL CAMBIO DEL ESTATUS DEL CLIENTE EN bdinteg:si_cambiostctepm
   --Fecha: 01-09-2011
   
   DEFINE cCod_ret char(5);
   DEFINE sql_err integer;
   DEFINE iStatus integer;

   LET cCod_ret       = "000";
   LET iStatus = "0";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF pNumCliente <> "" THEN

        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND num_cliente = pNumCliente ) THEN

			SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa and num_cliente = pNumCliente;
				
				
				INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  
				VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);

				UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND num_cliente = pNumCliente;

				LET cCod_ret = '000';  -- Usuario bloqueado
        ELSE

            LET cCod_ret = '001';  -- No existe el Cliente
        END IF ;

    ELSE

        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

			SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa and usuario = pUsuario;

				INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  
				VALUES (pNumCliente, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);

				 UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cCod_ret = '000';  -- Usuario bloqueado
        ELSE

            LET cCod_ret = '002';  -- No existe el Usuario
        END IF ;
    END IF ;

    RETURN cCod_ret;

END

END PROCEDURE ;