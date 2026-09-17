CREATE PROCEDURE "informix".sp_constelefonofechaact(pEmpresa CHAR(3), pNumcte CHAR(20))
	RETURNING 	CHAR(5) AS retorno;
	
	-- DEFINICION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet  		CHAR(5);
	DEFINE cFechaHr         CHAR(23);
	DEFINE dFechaHoy        DATE;
	
	--INICIALIZACION DE VARIABLES       
	LET cCodRet         = '00001';
	LET iSqlErr         = 0;
	LET cFechaHr        = '';
    LET dFechaHoy       =CURRENT;
	
	--SET DEBUG FILE TO "/respaldosbd/jasmin/sp_constelefonofechaact.out"; 
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet =  iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumcte,'') <>'' THEN
		
			IF EXISTS (SELECT numcte FROM "informix".si_telefonos WHERE empresa = pEmpresa AND numcte =pNumCte)THEN
				 SELECT MAX(fecha_hora) 
				 INTO cFechaHr 
				 FROM "informix".si_telefonos 
				 WHERE empresa = pEmpresa 
				 AND numcte = pNumCte;
				 
				LET cFechaHr = SUBSTRING(cFechaHr FROM 6 FOR 2) || "/" || SUBSTRING(cFechaHr FROM 9 FOR 2) || "/" || SUBSTRING(cFechaHr FROM 1 FOR 4);
				
				SELECT fecha_hoy 
				INTO dFechaHoy
				FROM "informix".si_fechas 
				WHERE empresa = pEmpresa;
				
				
			   IF dFechaHoy = cFechaHr THEN
					LET cCodRet = '00002';
			   ELSE 
					LET cCodRet = '00000';
				
			   END IF;
			ELSE
			  LET cCodRet = '00000';	
			END IF;
		
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE             
DOCUMENT
'Creado: Jasmin Soto F.',
'Fecha: 13/11/2012',
'Descripcion: Se crea para capturar numero de telefono del cliente seleccionado',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_guarda_telefonos(pEmpresa CHAR(3), 
													    pNumcte CHAR (20), 
													    pTelcasa CHAR (10), 
													    pTelcelular CHAR (10), 
													    pTeloficina CHAR (10),
													    pTelotro CHAR (10),
													    pCarrier SMALLINT,
													    pExtension CHAR(5),
													    pUserInsert  CHAR(8))
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		   INTEGER;
DEFINE cCodRet 		   CHAR(5);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';

	--SET DEBUG FILE TO "/respaldosbd/jasmin/sp_guarda_telefonos.out"; 
	--TRACE ON; 

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	IF NVL(pEmpresa,'') <> '' AND NVL(pNumcte,'') <> '' AND (NVL(pTelcasa, '') <> '' OR NVL(pTelcelular, '') <> '' OR NVL(pTeloficina, '') <> '' OR NVL(pTelotro, '') <> '') THEN
		
		IF pTelcasa <> '' THEN
			
			EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelcasa, 1, '', 0, 1, pUserInsert) INTO cCodRet;
		
		END IF;
		IF cCodRet::INT = 0 OR cCodRet= '999' THEN
		
			IF pTelcelular <> '' THEN 
				
				EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelcelular, 2, '', pCarrier, 1, pUserInsert) INTO cCodRet;
			
			END IF;
			IF cCodRet::INT = 0 OR cCodRet= '999' THEN
			 
				IF pTeloficina <> '' THEN
			
					EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTeloficina, 3, pExtension, 0, 1, pUserInsert) INTO cCodRet;
			
				END IF;
				
				IF cCodRet::INT = 0 OR cCodRet= '999' THEN
					IF pTelotro <> '' THEN 
						EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelotro, 4, '', 0, 1, pUserInsert) INTO cCodRet;
			
					END IF;	
				END IF;
				 
			END IF;
		END IF;
	ELSE 
		LET cCodRet = '00001';	
	END IF;
	
RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para registrar cada telefono del cliente',
'AUTOR : Jasmin Soto F. ',
'FECHA : 20/11/2012',
'VERSION: 1.0',
'BD: bdinteg';

create procedure "informix".cons_dir_cte_esp( pcliente char(20), pnum_regs smallint )
RETURNING char(5), char(50), char(10), char(10), char(10), char(30), char(60), char(30), 
          char(80), char(40), char(100), char(100), char(13), char(13), char(10), char(10), char(10);
    
    DEFINE v_codret      char(5);
    DEFINE v_calle		 char(30);
    DEFINE v_numext	     char(10);
    DEFINE v_numint      char(10);
    DEFINE v_depto	     char(6);
    DEFINE v_colonia     char(30);
    DEFINE v_ciudad	     char(60);
    DEFINE v_estado      char(30);
    DEFINE v_obs         char(80);   
    DEFINE v_entrecalles char(40);   
    DEFINE v_cp          char(5);   
    DEFINE v_tel1   	 char(13);   
    DEFINE v_tel2   	 char(13);   
    DEFINE v_tel3   	 char(13);   
    DEFINE v_ext 	  	 char(10);
    DEFINE v_tpdir 	  	 char(1);
    DEFINE v_tipodir  	 char(10);
    DEFINE v_fechacap  	 char(10);
    DEFINE v_contador    smallint;
    DEFINE sql_err       int;
    DEFINE isam_err      int;   
    
    LET v_codret = "000";
    
    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, 
                   v_obs, v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
        end if;
    end exception;
    
    -- ****************************************************************************
    -- Valida la informacion de entrada
    -- ****************************************************************************
    IF pcliente is null then
        LET v_codret = 110;  -- datos de entrada incompletos	   
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
               v_obs, v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
    END IF;
    
    -- ****************************************************************************
    -- Inicializar variables
    -- ****************************************************************************
    let v_contador = 0;
    let v_ciudad   = " ";
    
    -- ****************************************************************************
    -- obtener registros
    -- ****************************************************************************
    FOREACH  -- direcciones completas del cliente
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, dir.departamento,
               zon.nombrezona as colonia, nvl(cds.nombre," ") as cd, edo.nombre as edo, dir.cod_postal, dir.observaciones, dir.entre_calles,
               tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, decode(tel1.tipo_tel,'1','Particular'), dir.fecha_insert
          into v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
               v_cp, v_obs, v_entrecalles, v_tel1, v_tel2, v_tel3, v_ext, v_tipodir, v_fechacap
          from bdinteg:si_direcciones dir
          left outer join bdinteg:si_estados edo on(edo.estado = dir.estado)
          left outer join bdinteg:si_ciudades cds on(cds.ciudad = dir.ciudad and cds.estado = dir.estado and cds.pais = 1)
          left outer join bdinteg:si_catzonas zon on (zon.numerociudad = dir.numerociudad and zon.numerocolonia = dir.numerocolonia)
          left outer join bdinteg:si_catcalles cal on(cal.numerocalle = dir.numerocalle)
          left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1)
          left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2)
          left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = dir.numcte and tel3.tipo_tel = 3)
         where dir.numcte = pcliente
         order by dir.secuencia
         
    LET v_contador = v_contador +1;
    
    IF v_contador < pnum_regs then
        CONTINUE FOREACH;
    END IF;    
    
    RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
           v_cp, v_obs, v_entrecalles, v_tel1, v_tel2, v_tel3, v_ext, v_tipodir, v_fechacap WITH resume;
    
    END FOREACH		
    
    END;    
    
END PROCEDURE;