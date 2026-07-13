CREATE PROCEDURE "informix".sp_consultaccbancon_tipo(cEmpresa CHAR(3),cCentroIni CHAR(4),cCentroFin CHAR(4), cFiltro INTEGER)
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Regresa la consulta de los centros de costos por centro
--Realizó: Richar 
--Fecha: 13/02/2015
--------------------------------------------------------------------													
--cEmpresa = 001
--cCentroIni = el numero del centro de costros inicial, se validara numericos antes
--cStatus = estatus de la consulta del CC
--------------------------------------------------------------------
--MODIFICACIÓN
--Se quita la validación a.sucursal>='9000' para que al consultar por detalle de planta actual (filtro = 1) muestre todos los centros de costo
--Realizó Fernando Gpe. López González
--Liberado a producción 13/10/2015
--------------------------------------------------------------------
--MODIFICACIÓN: Se actualiza procedimiento para tomar el nombre de la zona y gcb y no id como actualmente se realiza.
--AUTOR: 95564047
--FOLIO: 612
--CENTRO: 230204
--SOLICITA: Ricardo Recendiz
--------------------------------------------------------------------

 --DATOS A REGRESAR---	
	RETURNING CHAR(5) AS codret, 	--codret
			  CHAR(50) AS mensaje, --Mensaje de error o validaciones
			  CHAR(4) AS Sucursal,	--Numero de centro de costo
			  CHAR(40) AS NomSucursal,	--Nombre del centro              
			  CHAR(40) AS Zona, --Zona de centro de costo			  
			  CHAR(30) AS GerenteC; --Gerente comercial
			  
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------	
	DEFINE vNomCC CHAR(40);	--Nombre del centro
    DEFINE vSucursal CHAR(4);
	DEFINE vZonCC CHAR(40); --Zona de centro de costo	
	DEFINE vGerCC CHAR(40); --Gerente comercial
	DEFINE vTSuc CHAR(1);			
	
	LET vNomCC ='';
    LET vSucursal ='';
	LET vZonCC ='';
	LET vGerCC ='';	
		
--	SET DEBUG FILE TO "sp_consultaccbancon_tipo.out";
--	TRACE ON;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '', '', '', '', ''; 
		END EXCEPTION;
									
		IF (cCentroIni = '' OR cCentroIni IS NULL) OR (cCentroFin = '' OR cCentroFin IS NULL) OR (cFiltro = '' OR cFiltro IS NULL) THEN
			LET cCodRet ='00002';
			RETURN cCodRet, 'Parametros incompletos', '','','',''; 
		END IF;				

		IF cFiltro = 1 THEN
		
			FOREACH
				SELECT tpo_sucursal,TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.Nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB				
				INTO vTSuc,vNomCC,vSucursal,vZonCC,vGerCC								
				FROM si_sucursales a
				--LEFT JOIN si_plazas d ON a.plaza=d.plaza
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion				
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='S' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				UNION
				SELECT tpo_sucursal,TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.Nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB														
				FROM si_sucursales a
				--LEFT JOIN si_plazas d ON a.plaza=d.plaza						
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='N' /*AND a.sucursal>='9000'*/ AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				ORDER BY tpo_sucursal DESC,TRIM(sucursal),nombre

				LET cCodRet ='00000';

				RETURN cCodRet,'Consulta exitosa', vSucursal,vNomCC,  vZonCC, vGerCC WITH RESUME;
			END FOREACH;												
				
		ELIF cFiltro=2 THEN
		
			FOREACH
				SELECT tpo_sucursal,TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB				
				INTO vTSuc,vNomCC,vSucursal,vZonCC,vGerCC								
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza						
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='S' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				ORDER BY a.sucursal

				LET cCodRet ='00000';

				RETURN cCodRet,'Consulta exitosa', vSucursal,vNomCC,  vZonCC, vGerCC WITH RESUME; 						

			END FOREACH;		
			
		ELIF cFiltro=3 THEN
		
			FOREACH
				SELECT tpo_sucursal,
					TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB				
				INTO vTSuc,vNomCC,vSucursal,vZonCC,vGerCC								
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza						
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='S' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				UNION
				SELECT tpo_sucursal,
					TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB														
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza						
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='N' AND a.sucursal>='9000' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				ORDER BY zona

				LET cCodRet ='00000';

				RETURN cCodRet,'Consulta exitosa', vSucursal,vNomCC,  vZonCC, vGerCC WITH RESUME; 						

			END FOREACH;
					
		ELIF cFiltro = 4 THEN
		
			FOREACH
				SELECT tpo_sucursal,TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB				
				INTO vTSuc,vNomCC,vSucursal,vZonCC,vGerCC								
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion					
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='N' AND a.sucursal >='9000'AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				ORDER BY a.sucursal

				LET cCodRet ='00000';

				RETURN cCodRet,'Consulta exitosa', vSucursal,vNomCC,  vZonCC, vGerCC WITH RESUME; 						

				END FOREACH;			

		ELIF cFiltro = 5 THEN
		
			FOREACH
				SELECT tpo_sucursal,
					TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB				
				INTO vTSuc,vNomCC,vSucursal,vZonCC,vGerCC								
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza	 					
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='S' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				UNION
				SELECT tpo_sucursal,
					TRIM(a.nombre) AS NOMBRE, 
					TRIM(a.sucursal)AS SUCURSAL,																
					TRIM(d.nom_coordinacion) AS zona,								
					cg.gerencia_comercial AS GCB														
				FROM si_sucursales a
				--left join si_plazas d on a.plaza=d.plaza						
				LEFT JOIN si_catczb_rh d ON a.id_czb_rh=d.id_coordinacion
				LEFT JOIN si_catgcb_rh cg ON a.id_gerencia_rh=cg.id_gerencia						
				WHERE tpo_sucursal='N' AND a.sucursal>='9000' AND (a.sucursal>=cCentroIni AND a.sucursal<=cCentroFin) AND a.empresa=cEmpresa          
				ORDER BY GCB

				LET cCodRet ='00000';

				RETURN cCodRet,'Consulta exitosa', vSucursal,vNomCC,  vZonCC, vGerCC WITH RESUME; 						

			END FOREACH;				
		END IF;						
	END;
END PROCEDURE;