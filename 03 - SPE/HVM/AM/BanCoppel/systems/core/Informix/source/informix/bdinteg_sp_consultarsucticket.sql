CREATE PROCEDURE "informix".sp_consultarsucticket (pEmpresa CHAR(3), pSucursal CHAR(4), pPlaza CHAR(3))
RETURNING      CHAR(5) AS retorno,CHAR(3) AS empresa,CHAR(4) AS sucursal,CHAR(40) AS nombreSuc,CHAR(40) AS ciudad,CHAR(40) AS estado,CHAR(40) AS direccion1,CHAR(40) AS direccion2,CHAR(14) AS telefono,CHAR(40) AS gerente,CHAR(40) AS subgerente,CHAR(2) AS tpo_sucursal;

DEFINE iSqlErr INTEGER;
DEFINE cCodret CHAR(5);
DEFINE cEmpresa CHAR(3);
DEFINE cSucursal CHAR(4);
DEFINE cNombreSuc CHAR(40);
DEFINE cCiudad CHAR(40);
DEFINE cEstado CHAR(40);
DEFINE cDireccion1 CHAR(40);
DEFINE cDireccion2 CHAR(40);
DEFINE cTelefono1 CHAR(14);
DEFINE cGerente CHAR(40);
DEFINE cSubgerente CHAR(40);
DEFINE cTipo_sucursal CHAR(2);
DEFINE cTipoConsulta CHAR(1);

LET iSqlErr = 0;
LET cCodret = '00000';
LET cEmpresa = '';
LET cSucursal = '';
LET cNombreSuc ='';
LET cCiudad ='';
LET cEstado ='';
LET cDireccion1 ='';
LET cDireccion2 ='';
LET cTelefono1 ='';
LET cGerente ='';   
LET cSubgerente ='';
LET cTipo_sucursal ='';
LET cTipoConsulta = '0';

BEGIN
	ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					LET cCodret = iSqlErr;
					RETURN cCodret,cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal;
				END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/mario/sp_consultarsucticket.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- VALIDACIONES  Y ASIGNACION DE TIPO DE CONSULTA--
	IF NVL(pEmpresa,'') = ''  THEN
			LET cCodret ='00001'; --debe proporcionarse la empresa      
	ELSE	
		IF  (NVL(pSucursal,'') = ''  AND NVL(pPlaza,'') = ''  ) THEN
			LET pSucursal = NULL;
			LET cTipoConsulta ='1'; --Consulta Todas las sucursales
		ELSE
			 IF  NVL(pSucursal,'') <> '' THEN
				 IF LENGTH(TRIM(pSucursal)) <>4 THEN
					 LET cCodret ='00002'; -- longitud de parametro pSucursal incorrecto		
				 ELSE
					 LET cTipoConsulta ='1'; --Consulta Por Sucursal
				 END IF;
			ELIF   NVL(pPlaza,'') <> ''  THEN
				IF 	LENGTH(TRIM(pPlaza)) <>3  THEN
					LET cCodret ='00003'; -- longitud de parametro pPlaza incorrecto	
				ELSE
					LET cTipoConsulta ='2'; --Consulta Por Plaza
			   END IF;	
			END IF;   
		END IF;	
	END IF;
	
	
	IF cCodret <> '00000' THEN	
		RETURN cCodret,cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal;
	END IF;
  
	IF cTipoConsulta = '1'  THEN 
			FOREACH			 
					SELECT {+INDEX(bdinteg:si_localidades idx_silocalidades),
							+INDEX(bdinteg:si_sucursales idx_sucursal)}
						   DISTINCT suc.empresa, ptf.id_ptf, suc.nombre,loc.desc_municipio AS nombre,est.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1, NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
					INTO  cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal
					FROM  "informix".si_ptf ptf
					INNER JOIN "informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND  ptf.tipo = suc.tipo)
					INNER JOIN "informix".si_estados est ON est.estado = ptf.cve_estado
					INNER JOIN "informix".si_plazas pla ON pla.plaza = suc.plaza
					LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
					WHERE ptf.id_ptf = NVL(pSucursal, sucursal) 
					AND suc.empresa = pEmpresa
					AND suc.tpo_sucursal = 'S'
					AND ptf.tipo <> 'C'
					ORDER BY ptf.id_ptf
					/*SELECT DISTINCT suc.empresa, suc.sucursal, suc.nombre,ciu.nombre,est.nombre,suc.direccion1, suc.direccion2, suc.telefono1, suc.gerente, suc.subger, suc.tpo_sucursal
					INTO  cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal
					FROM bdinteg:"informix".si_sucursales suc ,bdinteg:"informix".si_estados est,bdinteg:"informix".si_ciudades ciu ,bdinteg:"informix".si_plazas pla
					WHERE suc.sucursal = NVL(pSucursal, sucursal) 
					AND suc.empresa = pEmpresa
					AND est.estado = ciu.estado 
					AND suc.tpo_sucursal = 'S' 
					AND est.estado = suc.estado
					AND ciu.ciudad = suc.ciudad
					AND ciu.estado = suc.estado
					AND pla.plaza = suc.plaza
					ORDER BY suc.sucursal*/
				
					RETURN cCodret,cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal WITH RESUME;
			END FOREACH; 
	ELIF cTipoConsulta = '2' THEN 
	        FOREACH
					SELECT {+INDEX(bdinteg:si_localidades idx_silocalidades),
							+INDEX(bdinteg:si_sucursales idx_sucursal)}
						   DISTINCT suc.empresa, ptf.id_ptf, suc.nombre,loc.desc_municipio AS nombre,est.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1, NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
					INTO  cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal
					FROM "informix".si_ptf ptf
					INNER JOIN "informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND  ptf.tipo = suc.tipo)
					INNER JOIN "informix".si_estados est ON ( est.estado = ptf.cve_estado)
					INNER JOIN "informix".si_plazas pla ON pla.plaza = suc.plaza
					LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
					WHERE pla.plaza =  NVL(pPlaza, suc.plaza) 
					AND suc.empresa = pEmpresa
					AND suc.tpo_sucursal = 'S'
					AND ptf.tipo <> 'C' 
					ORDER BY ptf.id_ptf
					/*SELECT DISTINCT suc.empresa, suc.sucursal, suc.nombre,ciu.nombre,est.nombre,suc.direccion1, suc.direccion2, suc.telefono1, suc.gerente, suc.subger, suc.tpo_sucursal
					INTO  cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal
					FROM bdinteg:"informix".si_sucursales suc ,bdinteg:"informix".si_estados est,bdinteg:"informix".si_ciudades ciu ,bdinteg:"informix".si_plazas pla
					WHERE pla.plaza =  NVL(pPlaza, suc.plaza) 
					AND suc.empresa = pEmpresa
					AND est.estado = ciu.estado 
					AND suc.tpo_sucursal = 'S' 
					AND est.estado = suc.estado
					AND ciu.ciudad = suc.ciudad
					AND ciu.estado = suc.estado
					AND pla.plaza = suc.plaza
					ORDER BY suc.sucursal*/

					RETURN cCodret,cEmpresa,cSucursal,cNombreSuc,cCiudad,cEstado,cDireccion1,cDireccion2,cTelefono1,cGerente,cSubgerente,cTipo_sucursal WITH RESUME; 			
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
' DESCRIPCION:	Se crea SP para realizar consultas de sucursales y sucursales por zona para  modificar campañas de  el ticket inteligente ',  
' MODIFICO : Mario Gallardo Cardenas',			
' FECHA : 2013/06/17',
'BD:  bdinteg ';

CREATE PROCEDURE "informix".sp_consulta_datos_sucursal_numero (p_numeroSuc CHAR(4), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(4) AS sucursal, CHAR(40) AS nombreSucursal, CHAR(30) AS nombreEstado, CHAR(60) AS nombreCiudad;

	--definicion de variables--	    
	DEFINE resultado_numeroSucursal 	CHAR(4);
    DEFINE resultado_nombreSucursal		CHAR(40);
    DEFINE resultado_nombreEstado		CHAR(30);
    DEFINE resultado_nombreCiudad		CHAR(60);

    DEFINE iSqlErr                     	INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_numeroSucursal = '';
	LET resultado_nombreSucursal = '';
	LET resultado_nombreEstado = '';
	LET resultado_nombreCiudad = '';

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    	LET resultado_numeroSucursal = '';
						LET resultado_nombreSucursal = '';
						LET resultado_nombreEstado = '';
						LET resultado_nombreCiudad = '';
                    RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad;
                END IF;
        END EXCEPTION;
      
			SELECT DISTINCT si_ptf.id_ptf, si_sucursales.nombre, si_estados.nombre, loc.desc_municipio as nombre
	        INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad
			FROM bdinteg:si_ptf
			JOIN bdinteg:si_sucursales ON (si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo)
			JOIN bdinteg:si_estados ON bdinteg:si_estados.estado = bdinteg:si_ptf.cve_estado                
            LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = si_ptf.cve_estado AND 
                                                          loc.cve_mun = si_ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = si_ptf.cve_localidad AND 
                                                          loc.cve_col = si_ptf.cve_col )
            WHERE si_sucursales.empresa = p_sNumeroEmpresa
                AND si_ptf.id_ptf = p_numeroSuc AND  si_ptf.tipo <> 'C';
            /*SELECT DISTINCT sucursal, si_sucursales.nombre, si_estados.nombre, si_ciudades.nombre
	        INTO resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad
			FROM (bdinteg:si_sucursales JOIN bdinteg:si_ciudades ON bdinteg:si_ciudades.ciudad = bdinteg:si_sucursales.ciudad
				AND  bdinteg:si_ciudades.estado = bdinteg:si_sucursales.estado 
				AND  bdinteg:si_ciudades.pais = bdinteg:si_sucursales.pais) JOIN bdinteg:si_estados 
				ON bdinteg:si_estados.estado = bdinteg:si_sucursales.estado                
            WHERE empresa = p_sNumeroEmpresa
                AND sucursal = p_numeroSuc;*/
	        RETURN resultado_numeroSucursal, resultado_nombreSucursal, resultado_nombreEstado, resultado_nombreCiudad WITH RESUME;
	END
END PROCEDURE;