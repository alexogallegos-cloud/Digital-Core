CREATE PROCEDURE "informix".sp_genera_bd_transfer()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  

/*DEFINICION DE VARIABLES */
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE vdFechaHoy         DATE;
DEFINE pFecha             DATE;
DEFINE vsDia              VARCHAR(2);
DEFINE vsMes 		      VARCHAR(2);
DEFINE vsAnio 		      VARCHAR(2);

DEFINE vsNombre			  VARCHAR(35);
DEFINE vsApell_Pat		  VARCHAR(30);
DEFINE vsApell_Mat		  VARCHAR(30);
DEFINE vsNumeroCliente	  VARCHAR(12);
DEFINE vcCelular	      VARCHAR(10);
DEFINE vsAnioNac		  VARCHAR(10);
DEFINE vsMesNac		  	  VARCHAR(10);
DEFINE vsDiaNac		  	  VARCHAR(10);
DEFINE vsEstado			  VARCHAR(30);
DEFINE vsMunicipio		  VARCHAR(30);
DEFINE vsDiaApert    	  VARCHAR(10);
DEFINE vsMesApert    	  VARCHAR(10);
DEFINE vsAnioApert    	  VARCHAR(10);
DEFINE vcstatus_cta		  VARCHAR(5);
DEFINE vsCancelacion_cta  VARCHAR(10);
DEFINE vsUltima_trans	  VARCHAR(10);

DEFINE vsStmt1			  CHAR(1000);
DEFINE vsStmt2			  CHAR(1000);
DEFINE viRegistros 		  INTEGER;
--DEFINE vArch  			  INTEGER;
DEFINE vsDelimiter        VARCHAR(1);
DEFINE vsNombreArchivo    VARCHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE vsfechacomp		  VARCHAR(10);
DEFINE vsestatus_cta	  VARCHAR(100);
--DEFINE vsnum_cta		  VARCHAR(20);
DEFINE vsfech_registro	  VARCHAR(20);
DEFINE vsfech_registro2	  VARCHAR(20);
DEFINE vsAnio2 		      VARCHAR(4);
DEFINE vsMes2			  VARCHAR(30);
DEFINE vsMesAnt			  VARCHAR(2);


/*FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET pFecha = today;
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';

LET vsNombre='';
LET vsApell_Pat='';
LET vsApell_Mat='';
LET vsNumeroCliente='';
LET vcCelular	   ='';
LET vsAnioNac	   ='';
LET vsMesNac	   ='';
LET vsDiaNac	   ='';
LET vsEstado	   ='';
LET vsMunicipio	   ='';
LET vsDiaApert ='';
LET vsMesApert ='';
LET vsAnioApert ='';
LET vcstatus_cta   ='';
LET vsCancelacion_cta='';
LET vsUltima_trans ='';

LET vsStmt1 = '';
LET vsStmt2 = '';
LET viRegistros = 0;
--LET vArch =0;
LET vsDelimiter= '';
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET vsfechacomp = '';
LET vsestatus_cta = '';
--LET vsnum_cta = '';
LET vsfech_registro= '';
LET vsfech_registro2= '';
LET vsAnio2= '';
LET vsMes2= '';
LET vsMesAnt= '';

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/ragomez/sp_genera_bd_transfer.out";
--TRACE ON;

BEGIN
	
	
	SELECT current - 1 units month
	INTO vsMes2 
	FROM bdinteg:"informix".si_fechas;
	
	--LET vsMes2 = vdFechaHoy - 1 units month;
	
	--Obtiene fecha hoy
	LET vsDia =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),9,2);
	LET vsMes =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),6,2);
	LET vsAnio = substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),3,2);
	LET vdFechaHoy = pFecha;
	LET vsfechacomp = LPAD(YEAR(TODAY),4,'0')||'-'||LPAD(MONTH(TODAY),2,'0')||'-'||LPAD(DAY(TODAY),2,'0');
	
	LET vsMesAnt = substr(vsMes2 , 6,2);
	LET vsAnio2 = LPAD(YEAR(TODAY),4,'0');
	
	
	LET vsfech_registro = NVL(vsMesAnt,'01')||'-'||'01'||'-'||NVL(vsAnio2,'01');
	LET vsfech_registro2 = NVL(vsMes,'01')||'-'||'01'||'-'||NVL(vsAnio2,'01');
	
	
	IF (vsCodRetorno='00000') THEN
	
	TRUNCATE "informix".tf_user_transfer_tmp;
	
	  INSERT INTO "informix".tf_user_transfer_tmp SELECT {+INDEX(tf_user_transfer,idx_cta_fecha_tf_user)} cuenta,MAX(fecha_corte) AS fecha_corte, MAX(consecutivo) AS consecutivo 
	  FROM "informix".tf_user_transfer
	  /*WHERE fecha_corte::date >=vsfech_registro AND fecha_corte::date <= vsfech_registro2*/ GROUP BY cuenta;
  			
				--Nombre del archivo
		LET vsNombreArchivo = 'BD_TRANSFER'||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01')||'.csv';
		
		LET vsStmt1 =  'Nombre'||','||'Apell_Pat'||','||'Apell_Mat'||','||'Cuenta'||','||'Celular'||','||'Año_Nac'||','
						||'Mes_Nac'||','||'Dia_Nac'||','||'Estado'||','||'Municipio'||','||'Dia_Aper'||','||'Mes_Aper'||','||'Año_Aper'||','
						||'Estatus'||','||'Fecha_Cancelacion'||','||'Ult_Transaccion';
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt1);
		
		SET LOCK MODE TO WAIT 3;
		
		FOREACH	WITH HOLD
			
			SELECT {+INDEX(tf_user_transfer,idx_cta_fecha_tf_user)} SUBSTR(nom_cliente,0,(INSTR(nom_cliente, '/',0))-1) AS nombre, 
													SUBSTR(nom_cliente,(INSTR(nom_cliente, '/',0)+1),(INSTR(nom_cliente, ',',0)-1) - (INSTR(nom_cliente, '/',0))) AS apellido1, 
													SUBSTR(nom_cliente,(INSTR(nom_cliente, ',',0)+1)) AS apellido2,
													a.numcte,a.telefono,
													SUBSTR(fecha_nac,7,4) as anio_nac , SUBSTR(fecha_nac,0,2) as mes_nac, SUBSTR(fecha_nac,4,2) as dia_nac,
													trim(b.estado) as estado,a.poblacion,
													SUBSTR(fecha_alta,4,2) as dia_alta , SUBSTR(fecha_alta,0,2) as mes_alta, SUBSTR(fecha_alta,7,4) as anio_alta,
													a.status_cta,a.fecha_baja,a.fecha_ult_transac 
			INTO vsNombre,vsApell_Pat,vsApell_Mat,vsNumeroCliente,vcCelular,vsAnioNac,vsMesNac,vsDiaNac,vsEstado,vsMunicipio,vsDiaApert,vsMesApert,vsAnioApert,vcstatus_cta,vsCancelacion_cta,vsUltima_trans
			FROM "informix".tf_user_transfer AS a
			JOIN tf_entidadfed_rpt AS b
			ON a.estado = b.id
			JOIN tf_user_transfer_tmp AS c
			ON  c.numcte = a.cuenta AND c.fecha_corte::date = a.fecha_corte::date AND c.consecutivo = a.consecutivo
			/*WHERE a.fecha_corte::date >= vsfech_registro AND a.fecha_corte::date <= vsfech_registro2*/
			
			
      
			IF (vcstatus_cta='20') THEN
					
				LET vsestatus_cta ='PRE-ACTIVA';
				LET vsCancelacion_cta='';
					
			ELIF (vcstatus_cta= '30') THEN
						
				LET vsestatus_cta ='ACTIVA';
				LET vsCancelacion_cta='';
				
						
			ELIF (vcstatus_cta= '40') THEN
						
				LET vsestatus_cta ='PENDIENTE DE RETIRO';
				LET vsCancelacion_cta='';

							
			ELIF (vcstatus_cta= '50') THEN
								
				LET vsestatus_cta ='CANCELADA';
								
							
			ELIF (vcstatus_cta='60') THEN
								
				LET vsestatus_cta ='DORMANT';
				LET vsCancelacion_cta='';
				
			ELSE 
									
				LET vsestatus_cta ='BLOQUEADA';
				LET vsCancelacion_cta='';
				
			END IF;
				
					LET vsStmt2 =  trim(vsNombre)||','||trim(vsApell_Pat)||','||trim(vsApell_Mat)||','||trim(vsNumeroCliente)||','||trim(vcCelular)||','||trim(vsAnioNac)||','
								   ||trim(vsMesNac)||','||trim(vsDiaNac)||','||trim(vsEstado)||','||trim(vsMunicipio)||','||trim(vsDiaApert)||','||trim(vsMesApert)||','||trim(vsAnioApert)||','
								   ||trim(vsestatus_cta)||','||trim(vsCancelacion_cta)||','||trim(vsUltima_trans);
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt2);
						--LET vArch = vArch +1;
						LET viRegistros = viRegistros +1;
		END FOREACH; 
		
         
		IF viRegistros > 0 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_generaarch_transfer(vsNombreArchivo,vsDelimiter) INTO vsCodRetorno;
				IF vsCodRetorno <> '00000' THEN
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_generaarch', vdFechaHoy,CURRENT);
					LET vsMensaje = 'Error en la generacion de archivo';	
				END IF;
		END IF;
			
		IF vsCodRetorno = '00000' THEN
			LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
			UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE proceso = 'BD_TRANSFER'
			and fecha_proceso = vdFechaHoy;				
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;