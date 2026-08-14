CREATE PROCEDURE "informix".sp_aforegeneraarchivosob(pUsuario CHAR(8) )

RETURNING CHAR(5),-->Codigo de Retorno CHAR(5) AS CodigoRet, 
	      CHAR(50);
DEFINE vcodret       CHAR(5);
DEFINE vCodRet1      CHAR(5);
DEFINE vsqlerr       INTEGER;
DEFINE dFechaActual	 DATE;
DEFINE cHoraActual	 DATETIME HOUR TO SECOND;
DEFINE cMensaje		CHAR(50);
DEFINE cNomProceso  CHAR(10);
DEFINE cFechaFormat CHAR(8);
DEFINE pNombreArchivo CHAR(30);
DEFINE cIndicadorNomArch CHAR(2);

LET vcodret = '00000';
LET dFechaActual = '';
LET vcodret1 = '00000';
LET cMensaje = '';
LET cNomProceso = '';
LET cFechaFormat = '';
LET pNombreArchivo = '';
LET cIndicadorNomArch = '';
LET cHoraActual = CURRENT HOUR TO SECOND;


-- SET DEBUG FILE TO "/home/informix/sp_AforeGeneraArchivosOB.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,cMensaje;
	END EXCEPTION;
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET cMensaje = 'Ocurrio un error no controlado';
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,pNombreArchivo,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
            Return vcodret,cMensaje;
        END IF;
    END EXCEPTION;
	
		--consulta la fecha actual del sistema de integral	
		SELECT {+  INDEX(bdicheq:sc_fechas idx_fechas1) } fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;
		
		LET cFechaFormat = LPAD(DAY(dFechaActual),2,0) || LPAD(MONTH(dFechaActual),2,0) || YEAR(dFechaActual);	
		LET cNomProceso = 'AfoEPPOB'; 
		LET cIndicadorNomArch = 'OB';
		
		FOREACH WITH HOLD
			SELECT nombre_arch INTO pNombreArchivo FROM bdiprog:pp_arch_afore 
			WHERE SUBSTR(nombre_arch,1,5) = 'PAGOS' 
			AND SUBSTR(nombre_arch,6,8) = cFechaFormat 
			AND SUBSTR(nombre_arch,15,2) = TRIM(cIndicadorNomArch)
			AND status = '20'
			AND tipo = 'P'
					
			CALL sp_aforearchconfob(pNombreArchivo,pUsuario)Returning vcodret,cMensaje;
			LET cMensaje = TRIM (cMensaje);
			IF vCodRet <> 0 THEN
				CONTINUE FOREACH;						
			END IF;
		END FOREACH;
		
		IF pNombreArchivo = '' OR pNombreArchivo IS NULL THEN
			LET cMensaje = 'No existen archivos por procesar';
		END IF;
		
		UPDATE pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = pNombreArchivo;
		RETURN vcodret,cMensaje;

END
END PROCEDURE;