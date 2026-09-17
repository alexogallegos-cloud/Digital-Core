CREATE PROCEDURE "informix".sp_cargainfo_sol_superv (pEmpresa CHAR(3), pNumSolicitud VARCHAR(20,1))
RETURNING
			CHAR(6) 	   AS CodRet,
			VARCHAR(20,1)  AS num_cte,
			VARCHAR(20,1)  AS num_solicitud,
			VARCHAR(80,1)  AS producto_desc,
			VARCHAR(80,1)  AS status_desc,
			CHAR(4)        AS sucursal,
			VARCHAR(150,1) AS nombre_cte,
			VARCHAR(13,1)  AS rfc,
			VARCHAR(30,1)  AS calle,
			VARCHAR(30,1)  AS estado,
			VARCHAR(6,1)   AS departamento, 
			VARCHAR(80,1)  AS complemento,
			VARCHAR(30,1)  AS ciudad,
			VARCHAR(27,1)  AS municipio,
			SMALLINT       AS edificio,
			VARCHAR(10,1)  AS num_int,
			VARCHAR(10,1)  AS num_ext,
			VARCHAR(5)     AS codigo_postal,
			VARCHAR(32,1)  AS zona_colonia,
			CHAR(13)       AS telefono_casa,
			CHAR(13)       AS telefono_celular,
			CHAR(13)       AS telefono_trabajo,
			CHAR(5)        AS ext_trabajo;
	
---DECLARACIONES
DEFINE cCodRet        CHAR(6); 
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE iNumReg        INTEGER;

DEFINE cEmpresa          CHAR(3);
DEFINE cNumSolicitud     VARCHAR(20,1);
DEFINE cNumcte           VARCHAR(20,1);
DEFINE cTpSol            CHAR(1);
DEFINE cStatusSol        CHAR(2);
DEFINE dMontoSol         DECIMAL(18,2);
DEFINE dMontoAut         DECIMAL(18,2);
DEFINE cNumProd          CHAR(4);
DEFINE cDescNumProd      VARCHAR(50,1);
DEFINE cDescStatusSol    VARCHAR(50,1);
DEFINE cSucursal         CHAR(4);
DEFINE dtFechaSol        DATE;
DEFINE cEnvioCop         CHAR(1);
DEFINE cPermCambio       CHAR(1);
DEFINE cNomCte           VARCHAR(150,1);
DEFINE cRfc              VARCHAR(13,1);
DEFINE cEstado           VARCHAR(30,1);
DEFINE cCiudad           VARCHAR(30,1);
DEFINE cMunicipio        VARCHAR(27,1);
DEFINE cColonia          VARCHAR(32,1);
DEFINE cCalle            VARCHAR(30,1);
DEFINE cNumExt           VARCHAR(10,1);
DEFINE cNumInt           VARCHAR(10,1);
DEFINE cCodPostal        VARCHAR(5);
DEFINE sEdificio         SMALLINT;
DEFINE cDepto            VARCHAR(6,1);
DEFINE cComplemento      VARCHAR(80,1);
DEFINE cTel1             CHAR(13);
DEFINE cExt1             CHAR(5);
DEFINE sTipoTel1         SMALLINT;
DEFINE cTel2             CHAR(13);
DEFINE cExt2             CHAR(5);
DEFINE sTipoTel2         SMALLINT;
DEFINE cTel3             CHAR(13);
DEFINE cExt3             CHAR(5);
DEFINE sTipoTel3         SMALLINT;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cCodRet             = "000000";
LET iNumReg             = 0;

LET cEmpresa            = '';
LET cNumSolicitud       = '';
LET cNumcte             = '';
LET cTpSol              = '';
LET cStatusSol          = '';
LET dMontoSol           = 0;
LET dMontoAut           = 0;
LET cNumProd            = '';
LET cDescNumProd        = '';
LET cDescStatusSol      = '';
LET cSucursal           = '';
LET dtFechaSol          = DATE(1);
LET cEnvioCop           = '';
LET cPermCambio         = '';
LET cNomCte             = '';
LET cRfc                = '';
LET cEstado             = '';
LET cCiudad             = '';
LET cMunicipio          = '';
LET cColonia            = '';
LET cCalle              = '';
LET cNumExt             = '';
LET cNumInt             = '';
LET cCodPostal          = '';
LET sEdificio           = 0;
LET cDepto              = '';
LET cComplemento        = '';
LET cTel1               = '';
LET cExt1               = '';
LET sTipoTel1           = 0;
LET cTel2               = '';
LET cExt2               = '';
LET sTipoTel2           = 0;
LET cTel3               = '';
LET cExt3               = '';
LET sTipoTel3           = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	RETURN	NVL(cCodRet,''), NVL(cNumcte,''), NVL(cNumSolicitud,''), NVL(cNumProd,'')||'-'||NVL(cDescNumProd,''),
		NVL(cStatusSol,'')||'-'||NVL(cDescStatusSol,''), NVL(cSucursal,''), NVL(cNomCte,''), NVL(cRfc,''),
		NVL(cCalle,''), NVL(cEstado,''), NVL(cDepto,''), NVL(cComplemento,''), NVL(cCiudad,''),
		NVL(cMunicipio,''),NVL(sEdificio,0), NVL(cNumInt,''), NVL(cNumExt,''),NVL(cCodPostal,''),
		NVL(cColonia,''), NVL(cTel1,''), NVL(cTel2,''), NVL(cTel3,''), NVL(cExt3,'');
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO '/informix/jesus/sp_cargainfo_sol_superv.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa     
  FROM bdinteg:si_empresas 
 WHERE empresa= pEmpresa;
  
IF cEmpresa IS NULL THEN
  LET cCodRet = '000001';
RETURN	NVL(cCodRet,''), NVL(cNumcte,''), NVL(cNumSolicitud,''), NVL(cNumProd,'')||'-'||NVL(cDescNumProd,''),
		NVL(cStatusSol,'')||'-'||NVL(cDescStatusSol,''), NVL(cSucursal,''), NVL(cNomCte,''), NVL(cRfc,''),
		NVL(cCalle,''), NVL(cEstado,''), NVL(cDepto,''), NVL(cComplemento,''), NVL(cCiudad,''),
		NVL(cMunicipio,''),NVL(sEdificio,0), NVL(cNumInt,''), NVL(cNumExt,''),NVL(cCodPostal,''),
		NVL(cColonia,''), NVL(cTel1,''), NVL(cTel2,''), NVL(cTel3,''), NVL(cExt3,'');
END IF;

IF NVL(pNumSolicitud,'') = '' THEN
  LET cCodRet = '000002';
  RETURN	NVL(cCodRet,''), NVL(cNumcte,''), NVL(cNumSolicitud,''), NVL(cNumProd,'')||'-'||NVL(cDescNumProd,''),
		NVL(cStatusSol,'')||'-'||NVL(cDescStatusSol,''), NVL(cSucursal,''), NVL(cNomCte,''), NVL(cRfc,''),
		NVL(cCalle,''), NVL(cEstado,''), NVL(cDepto,''), NVL(cComplemento,''), NVL(cCiudad,''),
		NVL(cMunicipio,''),NVL(sEdificio,0), NVL(cNumInt,''), NVL(cNumExt,''),NVL(cCodPostal,''),
		NVL(cColonia,''), NVL(cTel1,''), NVL(cTel2,''), NVL(cTel3,''), NVL(cExt3,'');
END IF;   


SELECT a.num_solicitud, a.numcte, a.tipo_solicitud, NVL(a.status_solicitud, '') ,  NVL(a.monto_solicitado,0) , NVL(a.monto_autorizado,0) ,
	   b.num_producto, b.nombre_prod, ss.descripcion, a.sucursal,a.fecha_insert,envio_parametrico,permite_cambio
  INTO cNumSolicitud,cNumcte,cTpSol,cStatusSol,dMontoSol,dMontoAut,cNumProd,cDescNumProd,cDescStatusSol,cSucursal,dtFechaSol,cEnvioCop,cPermCambio
  FROM "informix".ss_solicitudes as a 
  LEFT JOIN bdicred:"informix".sd_definicion as b on (b.empresa=a.empresa AND a.num_producto = b.num_producto)
  LEFT JOIN "informix".ss_status_sol as ss On (ss.empresa=a.empresa AND ss.status_solicitud = a.status_solicitud)    	
  LEFT JOIN "informix".ss_cambio_status_mc as sc On (sc.empresa=a.empresa
													AND sc.status_inicial = a.status_solicitud 
													AND secuencia  = (SELECT MAX(secuencia) 
																		FROM "informix".ss_cambio_status_mc 
																		WHERE empresa=a.empresa
																		AND status_inicial = a.status_solicitud))    	
	WHERE a.empresa = pEmpresa
 AND a.num_solicitud = pNumSolicitud;	 
 

SELECT TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno), rfc
	INTO cNomCte, cRfc
	FROM bdinteg:"informix".si_cliente cte
	INNER JOIN bdinteg:"informix".si_ctepf pf ON (pf.Empresa = cte.empresa and pf.numcte= cte.numcte)
	WHERE cte.empresa = pEmpresa 
	AND cte.numcte = cNumcte; 
 
 SELECT  TRIM(NVL(edo1.nombre,'')),TRIM(NVL(ciudad1.nombreciudad,'')),
			NVL(zonas1.poblacionzona, '') ,	NVL(zonas1.NombreZona,'')  ,
			NVL(calle1.nombrecalle,'') , TRIM(dir1.numeroextcalle) ,
			TRIM(dir1.numerointcalle) ,	LPAD(TRIM(dir1.cod_postal),5,'0') ,
			LPAD(dir1.edificio,5,'0') ,	RPAD(TRIM(dir1.departamento),6,' ') ,
			RPAD(TRIM(dir1.observaciones),80,' ')
		INTO cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cComplemento
	FROM bdinteg:"informix".si_direcciones_actual dir1        
	LEFT OUTER JOIN bdinteg:"informix".si_estados     edo1    ON (edo1.estado = dir1.estado)
	LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciudad1 ON (ciudad1.numerociudad = dir1.numerociudad)
	LEFT OUTER JOIN bdinteg:"informix".si_catzonas    zonas1  ON (dir1.numerociudad = zonas1.numerociudad and dir1.numerocolonia = zonas1.numerocolonia)
	LEFT OUTER JOIN bdinteg:"informix".si_catcalles   calle1  ON (dir1.numerocalle  = calle1.numerocalle) 
	WHERE dir1.numcte = cNumcte 
	AND   dir1.tipo_dir  = '1'
	AND NVL(dir1.secuencia,0) = (SELECT NVL(MAX(secuencia),0) 
							     FROM bdinteg:"informix".si_direcciones_actual dir 
								 WHERE dir.tipo_dir = dir1.tipo_dir AND dir.numcte = cNumcte);
		
		
	SELECT telefono,extension,tipo_tel
	  INTO cTel1,cExt1,sTipoTel1
	  FROM bdinteg:"informix".si_telefonos_actual a	 
	 WHERE a.empresa = pEmpresa
	   AND a.numcte = cNumcte 
	   AND a.tipo_tel = 1
	   AND a.status_tel = 'A';
	 
	SELECT telefono,extension,tipo_tel
	  INTO cTel2,cExt2,sTipoTel2
	  FROM bdinteg:"informix".si_telefonos_actual a	 
	 WHERE a.empresa = pEmpresa
	   AND a.numcte = cNumcte 
	   AND a.tipo_tel = 2
	   AND a.status_tel = 'A';	 
	   
	SELECT telefono,extension,tipo_tel
	  INTO cTel3,cExt3,sTipoTel3
	  FROM bdinteg:"informix".si_telefonos_actual a	 
	 WHERE a.empresa = pEmpresa
	   AND a.numcte = cNumcte 
	   AND a.tipo_tel = 3
	   AND a.status_tel = 'A';	 


RETURN	NVL(cCodRet,''), NVL(cNumcte,''), NVL(cNumSolicitud,''), NVL(cNumProd,'')||'-'||NVL(cDescNumProd,''),
		NVL(cStatusSol,'')||'-'||NVL(cDescStatusSol,''), NVL(cSucursal,''), NVL(cNomCte,''), NVL(cRfc,''),
		NVL(cCalle,''), NVL(cEstado,''), NVL(cDepto,''), NVL(cComplemento,''), NVL(cCiudad,''),
		NVL(cMunicipio,''),NVL(sEdificio,0), NVL(cNumInt,''), NVL(cNumExt,''),NVL(cCodPostal,''),
		NVL(cColonia,''), NVL(cTel1,''), NVL(cTel2,''), NVL(cTel3,''), NVL(cExt3,'');

END
END PROCEDURE
