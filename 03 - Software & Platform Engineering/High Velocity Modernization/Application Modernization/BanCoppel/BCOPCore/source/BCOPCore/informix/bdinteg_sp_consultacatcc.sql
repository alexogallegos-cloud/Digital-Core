CREATE PROCEDURE "informix".sp_consultacatcc (pEmpresa CHAR (3),pCatalogo CHAR(15))  
	RETURNING 	CHAR(5)  AS CodigodeRetorno,
				CHAR(50) AS Mensaje,
				INTEGER  AS ID,
				CHAR(30) AS Descripcion;

---DECLARACIONES
DEFINE iSqlErr	INTEGER;
DEFINE iIsamErr	INTEGER;
DEFINE cCod_ret	CHAR(5);
DEFINE cMensaje	CHAR(50);


DEFINE iId	INTEGER;
DEFINE cDescripcion	CHAR(30);

LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCod_ret	= '00000';
LET cMensaje	='Consulta exitosa';

LET iId	= 0;
LET cDescripcion = '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret = iSqlErr;
		  LET cMensaje = 'Ocurri'||CHR(243) ||' un error de informix';
          RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),NVL(cDescripcion,'');
       END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	-- SET DEBUG FILE TO "/respaldosbd/josue/sp_consultacatcc.out";
	-- TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR TRIM(NVL(pCatalogo,'')) = '' THEN
		LET cCod_ret = "00002";
		LET cMensaje = 'Par'||CHR(225) ||'metros incompletos';
		RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),NVL(cDescripcion,'');
	ELSE
	
		IF TRIM(NVL(pCatalogo,'')) NOT IN ('1','2','3','4') THEN /*JMMO AGREGAR 4*/
			LET cCod_ret = "00003";
			LET cMensaje = 'El cat'||CHR(225) ||'logo consultado no existe';
		ELSE
	
			IF TRIM(NVL(pCatalogo,'')) = '1' THEN
				FOREACH WITH HOLD		
					
					SELECT id_region,region INTO iId,cDescripcion
					FROM  "informix".si_catregion_rh
				
					RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),TRIM(NVL(cDescripcion,'')) WITH RESUME;
					
				END FOREACH
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = "00001";
					LET cMensaje = 'No existe informaci'||CHR(243) ||'n del cat'||CHR(225) ||'logo consultado';
				END IF;
			ELIF TRIM(NVL(pCatalogo,'')) = '2' THEN
				FOREACH WITH HOLD		
					
					SELECT id_gerencia,gerencia_comercial INTO iId,cDescripcion
					FROM  "informix".si_catgcb_rh
				
					RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),TRIM(NVL(cDescripcion,'')) WITH RESUME;
					
				END FOREACH
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = "00001";
					LET cMensaje = 'No existe informaci'||CHR(243) ||'n del cat'||CHR(225) ||'logo consultado';
				END IF;
			ELIF TRIM(NVL(pCatalogo,'')) = '3' THEN
				FOREACH WITH HOLD		
					
					SELECT id_status,status INTO iId,cDescripcion
					FROM  "informix".si_catstatus_rh
					
					RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),TRIM(NVL(cDescripcion,'')) WITH RESUME;
					
				END FOREACH
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = "00001";
					LET cMensaje = 'No existe informaci'||CHR(243) ||'n del cat'||CHR(225) ||'logo consultado';
				END IF;
			/*JMMO*/	
			ELIF TRIM(NVL(pCatalogo,'')) = '4' THEN
				FOREACH WITH HOLD		
					
					SELECT id_coordinacion,Nom_coordinacion 
						INTO iId,cDescripcion
					FROM "informix".si_catczb_rh
					
					RETURN cCod_ret,NVL(cMensaje,''),NVL(iId,0),TRIM(NVL(cDescripcion,'')) WITH RESUME;
					
				END FOREACH
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = "00001";
					LET cMensaje = 'No existe informaci'||CHR(243) ||'n del cat'||CHR(225) ||'logo consultado';
				END IF;	
			/*JMMO*/	
			END IF;
		END IF;
	END IF;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'FOLIO:1604',
'AUTOR:94912599', 
'FECHA:16/10/2015',
'DESCRIPCIÓN: Procedimiento para consultar el catálago de regiones,Estatus o gerencia comercial banco',
'SUSTENTO:9005- RQM 02 060 Modulo de mantenimiento al catalogo de CC-20151009_0101241.pdf',
'SOLICITA: Fernando Fernández Gómez',
'*******************************************',
'MANTENIMIENTO: Se modifica procedimiento para agrega el mantenimiento del nuevo catálogo ZONA, se agrega el nuevo ID 4',
'AUTOR: 95564047',
'FECHA: 2019/09/20',
'SUSTENTO: RQI 12 425 Nueva forma de reporte de planta activa en BancoN',
'FOLIO: 612',
'SOLICITA: Ricardo Recendiz';

CREATE PROCEDURE "informix".sp_consultaccbancon(cEmpresa CHAR(3),cCentroc char(4), cStatus integer)

--------------------------------------------------------------------
--DOCUMENTACIÃN
--Regresa la consulta de los centros de costos por centro o por estatus
--RealizÃ³: Richar 
--Fecha: 22/01/2015
--------------------------------------------------------------------
--DOCUMENTACIÃN
--Se agrega que se puedan consultar CC de Corporativos
--Modifica: Fernando FernÃ¡ndez GÃ³mez 
--Fecha: 17/08/2015
--------------------------------------------------------------------
--DOCUMENTACIÃN
--e modifica procedimiento para que regrese en nÃºmero de zona, y no el nombre, el nombre se obtendrÃ¡ desde el combo correspondiente de la aplicaciÃ³n, ademÃ¡s se agregaron las reglas de informix.
--Modifica: Jibran Mercado Obeso 
--Fecha: 20/09/2019
--Folio: 612
--Solicita: Ricardo Recendiz
--------------------------------------------------------------------
													
--cEmpresa = 001
--cCc = el numero del centro de costros
--cStatus = estatus de la consulta del CC

 --DATOS A REGRESAR---	
	RETURNING CHAR(5) AS CodRetorno, 	--codret
			  CHAR(40)AS Nombre,	--Nombre del centro
              CHAR(4) AS Sucursal,  --Numero de Sucursal
			  CHAR(80)AS Direccion, --Direccion centro de costo
			  CHAR(30)AS Municipio, --Municipio Centro de costo
			  CHAR(40)AS Zona, --Zona de centro de costo
			  CHAR(30)AS Region, --Region Centro de costo
			  CHAR(30)AS GCB, --Gerente comercial
			  CHAR(15)AS Estatus; --Estatus del centro de costo
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
	
	DEFINE vNomCC CHAR(40);	--Nombre del centro
    DEFINE vSucursal CHAR(4);
	DEFINE vDirCC CHAR(80); --Direccion centro de costo
	DEFINE vMunCC CHAR(30); --Municipio Centro de costo
	DEFINE vZonCC CHAR(40); --Zona de centro de costo
	DEFINE vRegCC CHAR(30); --Region Centro de costo
	DEFINE vGerCC CHAR(30); --Gerente comercial
	DEFINE vEstCC CHAR(15); --Estatus del centro de costo
	DEFINE iValor INTEGER;		
	
	LET vNomCC ='';
    LET vSucursal ='';
	LET vDirCC ='';
	LET vMunCC ='';
	LET vZonCC ='';
	LET vRegCC ='';
	LET vGerCC ='';
	LET vEstCC ='';
	LET iValor = 0;
	LET cCodRet = '00000';
		
	--SET DEBUG FILE TO "sp_consultaccbancon.out";
	--TRACE ON;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '', '', '', '', '', '', '', ''; 
		END EXCEPTION;
		
		IF cStatus IS NULL OR cStatus='' THEN
			LET cStatus = 0;
		END IF;		
						
		IF cStatus = 0 THEN		
		
			IF(cCentroc = '' OR cCentroc IS NULL) OR (cEmpresa = '' OR cEmpresa IS NULL) THEN
				LET cCodRet = '00002';
				LET vNomCC = 'Parametros incompletos';
			ELSE				
				SELECT COUNT(*) INTO iValor FROM si_sucursales WHERE sucursal = cCentroc AND tpo_sucursal IN ('S','N')  AND empresa = cEmpresa;

				IF iValor > 0 THEN					
						
					SELECT a.nombre AS NOMBRE, 
						a.sucursal AS sucursal,
						ptf.calle||' '||ptf.num_ext||' '|| NVL(ptf.num_int,'') AS direccion,
						ci.nombre AS MUNICIPIO,
						d.id_coordinacion AS zona,
						cr.region AS region,
						cg.gerencia_comercial AS GCB,
						cs.status AS status 
					INTO vNomCC,vSucursal,vDirCC,vMunCC,vZonCC,vRegCC,vGerCC,vEstCC
					FROM si_sucursales a
					LEFT JOIN si_ptf ptf ON a.sucursal = ptf.id_ptf AND a.tipo = ptf.tipo
					LEFT JOIN si_ciudades ci ON ptf.cve_ciudad = ci.ciudad AND ptf.cve_estado = ci.estado  
					JOIN si_estados b ON ptf.cve_estado = b.estado
					LEFT JOIN si_catczb_rh d ON a.id_czb_rh = d.id_coordinacion /*JMMO NEW*/
					LEFT JOIN si_catregion_rh cr ON a.id_region_rh = cr.id_region
					LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh = cg.id_gerencia
					LEFT JOIN si_catstatus_rh cs ON a.id_status_rh = cs.id_status
					WHERE a.sucursal = cCentroc AND ptf.cve_estado = b.estado AND ptf.cve_ciudad = ci.ciudad AND NVL(a.id_czb_rh,0) = NVL(d.id_coordinacion,0)
					AND a.tpo_sucursal IN ('S','N') AND a.empresa = cEmpresa;
												
				ELSE
					LET cCodRet ='00001';
					LET vNomCC = 'No existen los datos de consulta';
				END IF;
				
			END IF;
			
		ELIF (cStatus > 0) THEN
						
			FOREACH			
			
				SELECT a.nombre AS NOMBRE, 
				    a.sucursal AS cc,
				    ptf.calle||' '||ptf.num_ext||' '||ptf.num_int AS direccion,
					ci.nombre AS MUNICIPIO,
					d.id_coordinacion AS zona,
					cr.region AS region,
					cg.gerencia_comercial AS GCB,
					cs.status AS status 
					INTO vNomCC,vSucursal,vDirCC,vMunCC,vZonCC,vRegCC,vGerCC,vEstCC
				FROM si_sucursales a
				LEFT JOIN si_ptf ptf ON a.sucursal = ptf.id_ptf AND a.tipo = ptf.tipo
				LEFT JOIN si_ciudades ci ON ptf.cve_ciudad = ci.ciudad AND ptf.cve_estado = ci.estado  
				JOIN si_estados b ON ptf.cve_estado = b.estado
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh = d.id_coordinacion /*JMMO NEW*/
				LEFT JOIN si_catregion_rh cr ON a.id_region_rh = cr.id_region
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh = cg.id_gerencia
				LEFT JOIN si_catstatus_rh cs ON a.id_status_rh = cs.id_status
				WHERE NVL(a.id_status_rh,0) = (CASE WHEN cStatus <> 4 THEN  cStatus ELSE NVL(id_status_rh,0) END) AND 
					  a.tpo_sucursal IN ('S','N') AND a.empresa = cEmpresa
					  
				RETURN cCodRet, TRIM(NVL(vNomCC,'')),TRIM(NVL(vSucursal,'')),TRIM(NVL(vDirCC,'')),TRIM(NVL(vMunCC,'')),TRIM(NVL(vZonCC,'')),TRIM(NVL(vRegCC,'')),TRIM(NVL(vGerCC,'')),TRIM(NVL(vEstCC,'')) WITH RESUME;	
				
			END FOREACH;
						
		ELSE 		
			LET cCodRet ='00002';
			LET vNomCC = 'No existen los datos de consulta';						
		END IF;
		RETURN cCodRet, TRIM(NVL(vNomCC,'')),TRIM(NVL(vSucursal,'')),TRIM(NVL(vDirCC,'')),TRIM(NVL(vMunCC,'')),TRIM(NVL(vZonCC,'')),TRIM(NVL(vRegCC,'')),TRIM(NVL(vGerCC,'')),TRIM(NVL(vEstCC,'')) WITH RESUME;			
	END;
END PROCEDURE;