CREATE PROCEDURE "informix".sp_transfer_sms()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  

/*DEFINICION DE VARIABLES */
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE vdFechaHoy         DATE;
DEFINE pFecha             DATE;
DEFINE cMaxregistros      VARCHAR(6);
DEFINE vsDia              VARCHAR(2);
DEFINE vsMes 		      VARCHAR(2);
DEFINE vsAnio 		      VARCHAR(2);
DEFINE vcCelular	      VARCHAR(10);
DEFINE vcnip	 	      VARCHAR(2);
DEFINE vcsaldo_cta	 	  VARCHAR(25);
DEFINE vcsexo	 	  	  VARCHAR(1);
DEFINE vcfech_nacimiento  VARCHAR(15);
DEFINE vcstatus_cta		  VARCHAR(5);
DEFINE vsStmt1			  CHAR(1000);
DEFINE vsStmt2			  CHAR(1000);
DEFINE viRegistros 		  INTEGER;
DEFINE vArch  			  INTEGER;
DEFINE vsNombreArchivo    VARCHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
--DEFINE vsfechacomp		  VARCHAR(10);
DEFINE vsdesc_status	  VARCHAR(100);
DEFINE vsnum_cta		  VARCHAR(20);
DEFINE vsfech_registro	  VARCHAR(20);
DEFINE vsAnio2 		      VARCHAR(4);
DEFINE vsMes2			  VARCHAR(30);
DEFINE vsMesAnt			  VARCHAR(2);

/*FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET pFecha = today;
LET cMaxregistros = '1000000000';
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET vcCelular = '';
LET vcnip = '';
LET vcsaldo_cta = '';
LET vcsexo = ' ';
LET vcfech_nacimiento = '';
LET vcstatus_cta = '';
LET vsStmt1 = '';
LET vsStmt2 = '';
LET viRegistros = 0;
LET vArch =0;
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
--LET vsfechacomp = '';
LET vsdesc_status = '';
LET vsnum_cta = '';
LET vsfech_registro= '';
LET vsAnio2= '';
LET vsMes2= '';
LET vsMesAnt= '';

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/ragomez/sp_transfer_sms_pba.out";
--TRACE ON;

BEGIN
	
	
	
	
	--Obtiene fecha hoy
	LET vsDia =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),9,2);
	LET vsMes =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),6,2);
	LET vsAnio = substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),3,2);
	LET vdFechaHoy = pFecha;
	
	LET vsfech_registro = LPAD(MONTH(today),2,'0')||'-01-'||YEAR(today);
	
	TRUNCATE TABLE "informix".mnsj_susc_paso;
	UPDATE statistics medium FOR TABLE "informix".mnsj_susc_paso;
				
				--Nombre del archivo
		LET vsNombreArchivo = 'SMS_TRANSFER'||'_'|| '05'|| NVL(vsMes,'01') || NVL(vsAnio,'01')||'_'|| vArch ||'.txt';
		
		LET vsStmt1 =  'CELULAR'||'|'||'PIN'||'|'||'SALDO'||'|'||'SEXO'||'|'||'FECHA_DE_NACIMIENTO'||'|'||'ESTATUS';
						INSERT INTO "informix".mnsj_susc_paso (linea)
						VALUES (vsStmt1);
		
		
		
		truncate table "informix".tf_account_balance_customer_tmp;

		INSERT INTO "informix".tf_account_balance_customer_tmp (cuenta,sdo_cta,fecha_proceso)
        SELECT {+INDEX(tf_account_balance_customer,idx_account_balance_customer)} cuenta,sdo_cta,max(fecha_proceso) 
		FROM "informix".tf_account_balance_customer group by 1,2;
		
		truncate table tf_assign_nip_tmp;
				
		INSERT INTO "informix".tf_assign_nip_tmp(cuenta,asigna_nip,status_cta,consecutivo)	
		SELECT {+INDEX(tf_assign_nip,idx_cta_consec)} cuenta,asigna_nip, status_cta, MAX(consecutivo) 
		FROM "informix".tf_assign_nip GROUP BY cuenta,asigna_nip,status_cta;
		
		SET LOCK MODE TO WAIT 3;
		
		FOREACH	WITH HOLD
			
			SELECT {+INDEX(tf_maecte,idx_status_cta)} m.cuenta_tf, m.telefono, m.fecha_nac, c.genero
			INTO vsnum_cta, vcCelular, vcfech_nacimiento, vcsexo
			FROM tf_maecte AS m 
			INNER JOIN tf_cte_online AS c
			ON m.cuenta_tf = c.cuenta_tf
			WHERE m.status_cta = 1
			
				
				SELECT LIMIT 1 asigna_nip, status_cta 
				INTO vcnip, vcstatus_cta
				FROM "informix".tf_assign_nip_tmp  WHERE consecutivo = (SELECT MAX(consecutivo) FROM "informix".tf_assign_nip_tmp
														WHERE cuenta=vsnum_cta); 
				
				
				SELECT {+INDEX(tf_account_balance_customer_tmp,idx_cta_fech_proceso_tmp)} LIMIT 1 sdo_cta 
				INTO vcsaldo_cta
				FROM "informix".tf_account_balance_customer_tmp WHERE cuenta = vsnum_cta   
				AND fecha_proceso::date =(SELECT {+INDEX(tf_account_balance_customer_tmp,idx_cta_fech_proceso_tmp)} MAX(fecha_proceso)
                                    FROM "informix".tf_account_balance_customer_tmp
                                    WHERE cuenta = vsnum_cta);
				
					
			
			IF (vcstatus_cta='20') THEN
					
				LET vsdesc_status ='PRE-ACTIVA';
					
			ELIF (vcstatus_cta= '30') THEN
						
				LET vsdesc_status ='ACTIVA';
				
						
			ELIF (vcstatus_cta= '40') THEN
						
				LET vsdesc_status ='PENDIENTE DE RETIRO';

							
			ELIF (vcstatus_cta= '50') THEN
								
				LET vsdesc_status ='CANCELADA';
								
							
			ELIF (vcstatus_cta='60') THEN
								
				LET vsdesc_status ='DORMANT';
				
			ELSE 
									
				LET vsdesc_status ='BLOQUEADA';
				
			END IF;
			
				IF  (vcnip) = '01' THEN
				
					LET vcnip = 'SI';
					
				ELSE
				
					LET vcnip = 'NO';
					
				END IF;
				
					LET vsStmt2 =  trim(vcCelular)||'|'||trim(vcnip)||'|'||trim(vcsaldo_cta)||'|'||trim(vcsexo)||'|'||trim(vcfech_nacimiento)||'|'||trim(vsdesc_status);
					INSERT INTO "informix".mnsj_susc_paso (linea)
					VALUES (vsStmt2);
						--LET vArch = vArch +1;
						LET viRegistros = viRegistros +1;
		END FOREACH; 
		
		IF viRegistros > 0 THEN
			EXECUTE PROCEDURE "informix".sp_generaarch_transfer(vsNombreArchivo) INTO vsCodRetorno;
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
	
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;