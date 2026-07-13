CREATE PROCEDURE "informix".sp_cnsif_consultausuariofuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO CHAR(8),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5),CHAR(8),CHAR(10),CHAR(100),CHAR(6),CHAR(20),INTEGER,CHAR(60),INTEGER, CHAR(1), CHAR(1);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cID_USUARIO_2 		CHAR(8);
	DEFINE cID_FUNCION			CHAR(10);
	DEFINE cD_FUNCION			CHAR(100);
	DEFINE cID_MODULO			CHAR(6);
	DEFINE cD_MODULO			CHAR(20);
	DEFINE iID_SUBMODULO		INTEGER;
	DEFINE cD_SUBMODULO			CHAR(60);
	DEFINE iORDEN				INTEGER;
	DEFINE cSTATUS_FUNCION		CHAR(1);
	DEFINE cSTATUS_FUNCIONU		CHAR(1);
    DEFINE iCont            INTEGER;
	
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cID_USUARIO_2 = " ";
	LET cID_FUNCION = " ";
	LET cD_FUNCION	= " ";
	LET cID_MODULO = " ";	
	LET cD_MODULO	= " ";	
	LET iID_SUBMODULO = 0	;
	LET cD_SUBMODULO =  " ";
	LET iORDEN	= 0;
	LET cSTATUS_FUNCION = " ";
	LET cSTATUS_FUNCIONU = " ";
    LET iCont=0;
	
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultausuariofuncion.out";
		--TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' 	OR
		cID_USUARIO = ''	THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		
		
		SELECT nvl(COUNT(id_usuario),0) INTO iexiste  FROM si_seg_usuarios_funciones WHERE id_usuario= cID_USUARIO;
		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

        SELECT NVL(COUNT(UF.id_funcion),0) INTO iexiste
        FROM  si_seg_usuarios_funciones UF
        LEFT JOIN si_seg_funciones FU
        ON UF.id_funcion  = FU.id_funcion 
        LEFT JOIN si_seg_modulos MO
        ON MO.id_modulo = FU.Id_modulo
        LEFT JOIN si_seg_submodulo SU
        ON SU.id_submodulo = FU.id_submodulo
        WHERE id_usuario= cID_USUARIO;

		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion UF.id_usuario, UF.id_funcion, FU.d_funcion, FU.id_modulo,MO.d_modulo, FU.id_submodulo, SU.d_submodulo, FU.orden, FU.status, UF.status 
			INTO
			cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU
			FROM  si_seg_usuarios_funciones UF
			LEFT JOIN si_seg_funciones FU
			ON UF.id_funcion  = FU.id_funcion 
			LEFT JOIN si_seg_modulos MO
			ON MO.id_modulo = FU.Id_modulo
			LEFT JOIN si_seg_submodulo SU
			ON SU.id_submodulo = FU.id_submodulo
			WHERE id_usuario= cID_USUARIO
            ORDER BY id_submodulo,orden

            LET iCont=iCont+1;
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU with resume;
		END FOREACH
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        END IF 
    END
END PROCEDURE	
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP devolvera las funciones del usuarios dependiendo del id_usuario que ingresen para la consulta",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_extrae_telefonos_comp( pcEmpresa CHAR(3) )
RETURNING CHAR(5)  AS vcCodRet1,
          CHAR(5)  AS vcCodRet2,
          CHAR(50) AS vcCodRet3,
          INTEGER  AS viContador1,
          INTEGER  AS viContador2;
    
    DEFINE vcCodRet1        CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE viComienza       SMALLINT;
    DEFINE viComienza2      SMALLINT;
    DEFINE viEnTransacc     SMALLINT;
    DEFINE viContador1      INTEGER;
    DEFINE viContador2      INTEGER;
    
    DEFINE vcCteMin         CHAR(20);
    DEFINE vcCteMax         CHAR(20);
    DEFINE vcCteMini        CHAR(20);
    DEFINE vcCteMaxi        CHAR(20);
    DEFINE vcNumCte         CHAR(20);
    DEFINE viSecuencia      SMALLINT;
    DEFINE vcTipoDir        CHAR(1);
    DEFINE vcTipoTelef1     CHAR(1);
    DEFINE vcTelefono1      CHAR(50);
    DEFINE vcTipoTelef2     CHAR(1);
    DEFINE vcTelefono2      CHAR(50);
    DEFINE vcTipoTelef3     CHAR(1);
    DEFINE vcTelefono3      CHAR(50);
    DEFINE vcExtension      CHAR(50);
    DEFINE vcUserInsert     CHAR(50);
    DEFINE vdFechaInsert    CHAR(50);
    DEFINE vCodRetValTel    CHAR(5);
    DEFINE vcValCasa        CHAR(1);
    DEFINE vcValCelular     CHAR(1);
    DEFINE vcValOficina     CHAR(1);
    DEFINE viCofetel        CHAR(1);    
    DEFINE vExisteTel       INTEGER;
    DEFINE vExisteTelAct    INTEGER;
    DEFINE vcTipoTelefono   CHAR(1);
    DEFINE vcTelefono       CHAR(50);
    DEFINE viTipoTel        SMALLINT;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO CONCLUIDO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viComienza   = -1;
    LET viComienza2  = -1;
    LET viEnTransacc = 0;
    LET viContador1  = 0;
    LET viContador2  = 0;
    
    LET vcCteMin       = '';
    LET vcCteMax       = '';
    LET vcCteMini      = '';
    LET vcCteMaxi      = '';
    LET vcNumCte       = '';
    LET viSecuencia    = 0;
    LET vcTipoDir      = '';
    LET vcTipoTelef1   = '';
    LET vcTelefono1    = '';
    LET vcTipoTelef2   = '';
    LET vcTelefono2    = '';
    LET vcTipoTelef3   = '';
    LET vcTelefono3    = '';
    LET vcExtension    = '';
    LET vcUserInsert   = '';
    LET vdFechaInsert  = '';
    LET vCodRetValTel  = '';
    LET vcValCasa      = '';
    LET vcValCelular   = '';
    LET vcValOficina   = '';
    LET viCofetel      = 'F';
    LET vExisteTel     = 0;
    LET vExisteTelAct  = 0;
    LET vcTipoTelefono = '';
    LET vcTelefono     = '';
    LET viTipoTel      = 0;
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2 ;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pcEmpresa is null OR pcEmpresa = '' ) THEN
        LET vcCodRet1 = '110';
        RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;
    END IF;
    
    -- // TABLA PARA TODAS LAS CUENTAS
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_telefonos_tmp_comp') THEN
        DROP TABLE si_telefonos_tmp_comp;        
    END IF;
    
    CREATE TABLE si_telefonos_tmp_comp
      (
        numcte          CHAR(20),
        tipo_dir        CHAR(1), 
        secuencia       SMALLINT, 
        tipo_telefono   CHAR(1), 
        telefono        CHAR(13), 
        extension       CHAR(5), 
        user_insert     CHAR(8), 
        fecha_insert    DATE
      )
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM bdinteg:"informix".si_cliente;
      
    SELECT numcte
      FROM bdinteg:"informix".si_direcciones
     WHERE numcte BETWEEN vcCteMin AND vcCteMax
       AND fecha_insert >= '06/15/2012'
    INTO TEMP tmp_ctes WITH NO LOG;
    CREATE INDEX idx_cte_tmp ON tmp_ctes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM tmp_ctes;
    
    FOREACH WITH HOLD
        SELECT numcte
          INTO vcNumCte
          FROM tmp_ctes   
         WHERE numcte BETWEEN vcCteMin AND vcCteMax
         
        IF viComienza = -1 THEN
            LET viComienza = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
        
        FOREACH
            SELECT secuencia, tipo_dir, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, user_insert, fecha_insert
              INTO viSecuencia, vcTipoDir, vcTipoTelef1, vcTelefono1, vcTipoTelef2, vcTelefono2, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_direcciones
             WHERE numcte = vcNumCte
               AND fecha_insert >= '06/15/2012'
             ORDER BY secuencia DESC
             
            IF ( vcTipoTelef1 is not null AND vcTipoTelef1 <> '' ) AND ( vcTelefono1 is not null AND vcTelefono1 <> '' AND LENGTH(vcTelefono1) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef1, vcTelefono1, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef2 is not null AND vcTipoTelef2 <> '' ) AND ( vcTelefono2 is not null AND vcTelefono2 <> '' AND LENGTH(vcTelefono2) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef2, vcTelefono2, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef3 is not null AND vcTipoTelef3 <> '' ) AND ( vcTelefono3 is not null AND vcTelefono3 <> '' AND LENGTH(vcTelefono3) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert);
            END IF;
            
            LET viSecuencia   = 0;
            LET vcTipoDir     = '';
            LET vcTipoTelef1  = '';
            LET vcTelefono1   = '';
            LET vcTipoTelef2  = '';
            LET vcTelefono2   = '';
            LET vcTipoTelef3  = '';
            LET vcTelefono3   = '';
            LET vcExtension   = '';
            LET vcUserInsert  = '';
            LET vdFechaInsert = '';
        END FOREACH;
        
        LET viContador1 = viContador1 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    CREATE INDEX idx_teltmp_ctecomp ON si_telefonos_tmp_comp(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE si_telefonos_tmp_comp;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMini, vcCteMaxi
      FROM bdinteg:"informix".si_telefonos_tmp_comp;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vcNumCte
          FROM bdinteg:"informix".si_telefonos_tmp_comp
         WHERE numcte BETWEEN vcCteMini AND vcCteMaxi
           
        IF viComienza2 = -1 THEN
            LET viComienza2 = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
            
        FOREACH
            SELECT tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert
              INTO vcTipoDir, viSecuencia, vcTipoTelefono, vcTelefono, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_telefonos_tmp_comp
             WHERE numcte = vcNumCte
             ORDER BY secuencia
            
            IF   vcTipoDir = '1' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 1; --- CASA
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            END IF;
            
            -- // VALIDA SI YA EXISTE EL TELEFONO
            SELECT COUNT(*)
              INTO vExisteTel
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = vcNumCte
               AND tipo_tel = viTipoTel
               AND telefono = vcTelefono;
            
            IF vExisteTel = 0 THEN
                -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
                EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono(pcEmpresa, vcTelefono, vcTelefono, vcTelefono)
                INTO vCodRetValTel, vcValCasa, vcValCelular, vcValOficina;
                
                IF vcValCasa = '1' OR vcValCelular = '1' OR vcValOficina = '1' THEN
                    LET viCofetel = 'V';
                END IF;
                
                UPDATE bdinteg:"informix".si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = vcNumCte
                   AND tipo_tel = viTipoTel;
                   
                -- // OBTIENE EL NUMERO DE SECUENCIA
                SELECT MAX(secuencia)
                  INTO viSecuencia
                  FROM bdinteg:"informix".si_telefonos
                 WHERE numcte = vcNumCte;
                         
                IF viSecuencia is null OR viSecuencia = '' THEN
                    LET viSecuencia = 0;
                END IF;
                
                LET viSecuencia = viSecuencia + 1;
                
                INSERT INTO bdinteg:"informix".si_telefonos
                (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert)
                VALUES
                (pcEmpresa, vcNumCte, vcTelefono, viTipoTel, 'A', viSecuencia, vcExtension, 0, 1, 0, viCofetel, vdFechaInsert, vcUserInsert);
            END IF;
            
            LET vcTipoDir      = '';
            LET viSecuencia    = 0;
            LET vcTipoTelefono = '';
            LET vcTelefono     = '';
            LET vcExtension    = '';
            LET vcUserInsert   = '';
            LET vdFechaInsert  = '';
            LET viTipoTel      = 0;
            LET vCodRetValTel  = '';
            LET vcValCasa      = '';
            LET vcValCelular   = '';
            LET vcValOficina   = '';
            LET viCofetel      = 'F';
            LET vExisteTel     = 0;
            LET vExisteTelAct  = 0;
        END FOREACH;  
            
        LET viContador2 = viContador2 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    END;

    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;

END PROCEDURE;