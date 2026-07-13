CREATE PROCEDURE "informix".sp_mc_obteninfocliente(pEmpresa CHAR(3),pNumSol CHAR(20),pNumcte CHAR(20))
RETURNING 
	CHAR(6)  AS codigo_retorno,
	CHAR(80) AS mensaje_retorno,
	CHAR(30) AS Estado,			
	CHAR(30) AS Ciudad,			
	CHAR(27) AS Municipio,
	CHAR(32) AS Colonia,
	CHAR(30) AS Calle,		    
	CHAR(10) AS NumExt,		   
	CHAR(10) AS NumInt,		    
	CHAR(5)  AS CodPostal,       
	SMALLINT AS Edificio,        
	CHAR(6)  AS Depto,	
	CHAR(13) AS TelCasa,	
	CHAR(13) AS TelCel,		
	CHAR(13) AS TelTrab,		
	CHAR(5)  AS Ext,		
	CHAR(80) AS Complemento,				    
	CHAR(60) AS LugarTrabajo ,
	CHAR(120) AS Actividad,    
	CHAR(120) AS SubActividad, 
	CHAR(104) AS NombreCong, 		
	CHAR(13)  AS TelCong, 		
	CHAR(104) AS NombreR1, 		 
	CHAR(13)  AS TelR1, 	
	CHAR(20)  AS ParentestoR1,   	
	CHAR(104) AS NombreR2, 	
	CHAR(13)  AS TelR2,	
	CHAR(20)  AS ParentestoR2;   		    
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cEstado			CHAR(30);
DEFINE cCiudad			CHAR(30);
DEFINE cMunicipio		CHAR(27);
DEFINE cColonia		    CHAR(32);

DEFINE cCalle		    CHAR(30);
DEFINE cNumExt		    CHAR(10);
DEFINE cNumInt		    CHAR(10);
DEFINE cCodPostal       CHAR(5);
DEFINE cDepto        	 CHAR(6);
DEFINE sEdificio	    SMALLINT;
DEFINE sTipoTel		    SMALLINT;
DEFINE cComplemento		CHAR(80);
DEFINE cTelCasa		CHAR(13);
DEFINE cTelCel		CHAR(13);
DEFINE cTel			CHAR(13);
DEFINE cTelTrab		CHAR(13);
DEFINE cExt		    CHAR(5);
DEFINE cLugarTrabajo CHAR(60);
DEFINE iActividad    INTEGER;
DEFINE iSubActividad INTEGER;
DEFINE cActividad    CHAR(120);
DEFINE cSubActividad CHAR(120);
--referencias
DEFINE cNombre 		 CHAR(104);
DEFINE cParentesco   CHAR(2);
DEFINE cDescParentesco CHAR(20);
DEFINE cTelRef 		CHAR(13);
DEFINE cNumcteRef   CHAR(20);
DEFINE cNombreCong 		CHAR(104);
DEFINE cParentestoCong  CHAR(20);
DEFINE cTelCong 		CHAR(13);
DEFINE cNombreR1 		CHAR(104);
DEFINE cParentestoR1    CHAR(20);
DEFINE cTelR1 	     	CHAR(13);
DEFINE cNombreR2 		CHAR(104);
DEFINE cParentestoR2    CHAR(20);
DEFINE cTelR2 		    CHAR(13);


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";

LET cEstado			= "";
LET cCiudad			= "";
LET cMunicipio		= "";
LET cColonia		= "";

LET cCalle		    = "";
LET cNumExt		    = "";
LET cNumInt		    = "";
LET cCodPostal      = "";
LET sEdificio       = "";
LET cDepto		    = 0;
LET cComplemento	= "";
LET cTelCasa		= "";
LET cTelCel			= "";
LET cTel			= "";
LET cTelTrab		= "";
LET cExt		    = "";
LET cLugarTrabajo   = "";
LET iActividad      = 0;
LET iSubActividad   = 0;
LET cActividad      = "";
LET cSubActividad   = "";
--referencias
LET cNombre 		= "";
LET cParentesco     = "";
LET cDescParentesco = "";
LET cTelRef 		= "";
LET cNumcteRef      = "";
LET cNombreCong 	= "";
LET cParentestoCong = "";
LET cTelCong 		= "";
LET cNombreR1 		= "";
LET cParentestoR1   = "";
LET cTelR1 	     	= "";
LET cNombreR2 		= "";
LET cParentestoR2   = "";
LET cTelR2 		    = "";

       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cErrorInfo,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_mc_obteninfocliente.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	  --CONTROL DE ERRORES POR PARAMETRO--
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSol,'')= '' OR  NVL(pNumcte, '') = '' THEN
		LET cCodret = '000001';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS'; 
		RETURN cCodRet, cMensajeRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
	 END IF;
	 

   SELECT  TRIM(NVL(edo1.nombre,'')),TRIM(NVL(ciudad1.nombreciudad,'')),
			NVL(zonas1.poblacionzona, '') ,	NVL(zonas1.NombreZona,'')  ,
			NVL(calle1.nombrecalle,'') , TRIM(dir1.numeroextcalle) ,
			TRIM(dir1.numerointcalle) ,	LPAD(TRIM(dir1.cod_postal),5,'0') ,
			LPAD(dir1.edificio,5,'0') ,	RPAD(TRIM(dir1.departamento),6,' ') ,
			RPAD(TRIM(dir1.observaciones),80,' ')
		INTO cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cComplemento
	FROM "informix".si_direcciones_actual dir1        
	LEFT OUTER JOIN "informix".si_estados     edo1    ON (edo1.estado = dir1.estado)
	LEFT OUTER JOIN "informix".si_catciudades ciudad1 ON (ciudad1.numerociudad = dir1.numerociudad)
	LEFT OUTER JOIN "informix".si_catzonas    zonas1  ON (dir1.numerociudad = zonas1.numerociudad and dir1.numerocolonia = zonas1.numerocolonia)
	LEFT OUTER JOIN "informix".si_catcalles   calle1  ON (dir1.numerocalle  = calle1.numerocalle) 
	WHERE dir1.numcte = pNumcte 
	AND   dir1.tipo_dir  = '1'
	AND NVL(dir1.secuencia,0) = (SELECT NVL(MAX(secuencia),0) 
							     FROM "informix".si_direcciones_actual dir 
								 WHERE dir.tipo_dir = dir1.tipo_dir AND dir.numcte = pNumcte);
	

	FOREACH 
		SELECT telefono,extension,tipo_tel
			INTO cTel,cExt,sTipoTel
		FROM "informix".si_telefonos_actual a	 
		WHERE a.empresa = '001' 
		AND a.numcte = pNumcte 
		AND a.tipo_tel IN (1,2,3)		
		AND a.status_tel = 'A'
		
		IF sTipoTel = 1 THEN
			LET cTelCasa =cTel;
			LET cExt = "";
		ELIF sTipoTel = 2 THEN
			LET cTelCel = cTel;
			LET cExt = "";
		ELIF sTipoTel = 3 THEN
			LET cTelTrab = cTel;
			LET cExt = cExt;
		END IF;
	
	END FOREACH;						 
		
		
		
		
	SELECT nombre_empresa,claveopcionpuesto ,clavesubopcionpuesto 	
		INTO cLugarTrabajo,iActividad,iSubActividad
	FROM "informix".si_ingresos 
	WHERE empresa = pEmpresa
	AND numcte = pNumcte
	AND tipo_ingreso='T'
	AND sec_ingreso= (SELECT MAX(sec_ingreso)
					FROM "informix".si_ingresos  
					WHERE empresa = pEmpresa 
					AND numcte = pNumcte
					AND tipo_ingreso='T');
		
	SELECT descrip 
	INTO cActividad
	FROM "informix".si_actsubact
	WHERE id_act =  iActividad AND id_subact = 0;

	SELECT descrip 
	INTO cSubActividad
	FROM  "informix".si_actsubact
	WHERE id_act =  iActividad AND id_subact = iSubActividad;
	  
	IF NVL(cActividad,"") = "" THEN
		LET cActividad = cSubActividad;
		LET cSubActividad ="";
	END IF;

	FOREACH
	
		SELECT NVL(refe.nombre_ref, "" ) , refe.parentesco,par.descripcion , NVL(refe.telefono_ref, "") ,refe.numcte_ref
			INTO cNombre,cParentesco, cDescParentesco,cTelRef,cNumcteRef
		FROM bdisolic:"informix".ss_refpersonales AS refe
		INNER JOIN "informix".si_parentesco AS par ON (refe.parentesco = par.parentesco) 
		WHERE refe.num_solicitud  = pNumSol		
		
		
		 IF cParentesco = "E" THEN
			LET cTelCong= cTelRef;
			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNombreCong
			FROM "informix".si_cliente
			WHERE empresa = '001'
			AND numcte = cNumcteRef;
			
			LET cNombreR2 = "";
			LET cParentestoR2 = "";
			LET cTelR2= "";
		 END IF;
		 IF cNumcteRef = "R1" AND  cParentesco <> "E" THEN
			LET cNombreR1 = cNombre;
			LET cParentestoR1= cDescParentesco;
			LET cTelR1= cTelRef;
		 ELIF cNumcteRef <> "R1" AND  cParentesco <> "E" THEN
			LET cNombreR2 = cNombre;
			LET cParentestoR2 = cDescParentesco;
			LET cTelR2= cTelRef;
		 END IF

	END FOREACH;     		  
	
	 
	RETURN cCodRet, cMensajeRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de los datos del cliente',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 18/02/2013',
'BD    : bdinteg',
'Version: 20130218.1210';

CREATE PROCEDURE "informix".sp_actvalidacioncofetel_pba( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1))
    RETURNING CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;

    -- Inicializa variables
     LET cCodRet = "00000";
     LET iSql_err = 0;
     LET iMaxSecuencia = 0;

    --SET debug FILE TO "/tmp/sp_actvalidacioncofetel.out";
    --trace ON;
	 
	-----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la si_direcciones si el telefono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	 
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SELECT max(secuencia) INTO iMaxSecuencia  from si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

        IF cFlagTelefonoCasa = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel1 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;
		
		IF cFlagTelefonoCelular = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel2 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

		IF cFlagTelefonoOficina = 1 AND cTipoDireccion = "2" THEN
            UPDATE si_direcciones SET ind_COFETELtel3 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;