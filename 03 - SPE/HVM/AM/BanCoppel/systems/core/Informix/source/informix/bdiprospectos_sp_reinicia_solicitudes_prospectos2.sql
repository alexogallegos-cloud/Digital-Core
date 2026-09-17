CREATE PROCEDURE "informix".sp_reinicia_solicitudes_prospectos2 ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);

DEFINE iSecuencia INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE iMax INTEGER;
DEFINE cClave CHAR(2);
DEFINE cDescripcion_status CHAR(40);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET cNumSol = "";
LET iMax = 0;
LET cClave = "";
LET cDescripcion_status = "";




BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_reinicia_solicitudes.out';
	--TRACE ON;

	
	--clientes con estatus EE con os generada sin respuesta
			SELECT   num_solicitud,secuencia,clave  from bdisolic:ss_osclientesupervisar a ,bdiprospectos:pr_cliente  b
			where a.num_solicitud= b.numcte_pros
			and tipo_cliente = 3 AND status_numcte_pros = 'EE'
			and fechaimpresion = DATE(1)
			and fecharespuesta = DATE(1)
			and secuencia < 10000000
			into temp paso_sol with no log;			
	--clientes con estatus EE con os generada con respuesta	
			insert into paso_sol
			SELECT   num_solicitud,secuencia,clave from bdisolic:ss_osclientesupervisar a ,bdiprospectos:pr_cliente  b
			where a.num_solicitud= b.numcte_pros
			and tipo_cliente = 3 AND status_numcte_pros = 'EE'
			and fechaimpresion <> DATE(1)
			and secuencia < 10000000;			
			insert into paso_sol			
			SELECT   num_solicitud,secuencia,clave from bdisolic:ss_osclientesupervisar a ,bdiprospectos:pr_cliente  b
			where a.num_solicitud= b.numcte_pros
			and tipo_cliente = 3 AND status_numcte_pros = 'EE'
			and fechaimpresion = DATE(1)
			and fecharespuesta <> DATE(1)
			and secuencia < 10000000;				
				
			create index inx_paso_sol on paso_sol(num_solicitud);
			
			update statistics high for table paso_sol;
			


	FOREACH WITH HOLD
		
			SELECT num_solicitud, secuencia,DECODE(clave,'R','RT','A','AT','D','OA','','OS','OS')
				INTO  cNumSol,iMax,cClave
				from paso_sol	
				
				BEGIN WORK;
					UPDATE bdiprospectos:"informix".pr_cliente
					SET status_numcte_pros = cClave 		,
					fecha_hora = CURRENT YEAR TO SECOND					
					WHERE numcte_pros = cNumSol;
		
					
					SELECT descripcion
					INTO cDescripcion_status
					FROM "informix".pr_status_sol
					WHERE empresa = '001' 
					AND status_solicitud = cClave;
			
					IF EXISTS (SELECT num_solicitud FROM"informix".pr_autorizacion WHERE num_solicitud = cNumSol AND status_solicitud = cClave ) THEN 
						DELETE FROM "informix".pr_autorizacion WHERE num_solicitud = cNumSol AND status_solicitud = cClave;
					END IF;
		
		
					INSERT INTO "informix".pr_autorizacion
					(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, situacion_especial,  
					causa_situacion, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora)
					VALUES ('001',"sistema",cNumSol,cClave,cDescripcion_status,'','', 
					0,TODAY,'',"sistema",CURRENT,0,CURRENT HOUR TO SECOND);
				
					IF cClave ='OS' THEN 
						UPDATE bdiprospectos:"informix".pr_solicitud_os
						SET status = 'P',secuenciaos = iMax, motivo_os = 15
						WHERE num_solicitud = cNumSol AND status = 'S';
					END IF;
					
					
				COMMIT WORK;
		
			
	END FOREACH;	
	
		
					
		RETURN cCodRet ;
END
END PROCEDURE
