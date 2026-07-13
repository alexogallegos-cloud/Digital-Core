CREATE PROCEDURE "informix".sp_obtiene_nombre_img_faltante
(
	pcEmpresa 		CHAR(3),
	pdFechaAlta		DATE
)

RETURNING
--DATOS A REGRESAR--
CHAR (5),
CHAR(60);   					--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE iSql_err 		INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE wBegin			CHAR(1);
DEFINE nombre_img		CHAR (60);

--INICIACION DE VARIABLES--
LET iSql_err 			=	0;
LET cCodRet 			=	'00000';
LET wBegin				=	'N';
LET nombre_img			=   '';

	--SET DEBUG FILE TO "/tmp/sp_valida_imagencheque.out";
	--TRACE ON;


	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				 RETURN cCodRet, nombre_img;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pcEmpresa,'') = '' OR  NVL(pdFechaAlta,"")="" THEN
			LET cCodRet = '00001';
			RETURN cCodRet, nombre_img;
		END IF
		
			FOREACH
			
					select a.cvebanco || RTRIM(RPAD(' ', 20 - LEN(a.numcuenta)) || a.numcuenta) ||
						   RTRIM(RPAD(' ', 7 - LEN(a.numcheque)) || a.numcheque) 
						   || a.lado_ft || a.usuario_alta || YEAR(a.fecha_alta) || MONTH(a.fecha_alta)|| DAY(a.fecha_alta)|| "." || a.imagen_formato as imagen
					  into nombre_img
					  from bditef:"informix".cce_cheques_img a
				inner join bditef:"informix".cce_cheques_det c on a.pcEmpresa = c.empresa
					   and a.cvebanco = c.cvebanco
					   and a.numcuenta = c.numcuenta
					   and a.numcheque = c.numcheque
					   and a.fecha_alta = c.fecha_alta
					 where a.empresa = pcEmpresa
					   and c.fecha_alta = pdFechaAlta
					   and a.imagen is null
					 union all
					select a.cvebanco || RTRIM(RPAD(' ', 20 - LEN(a.numcuenta)) || a.numcuenta) || 
						   RTRIM(RPAD(' ', 7 - LEN(a.numcheque)) || a.numcheque) 
						   || a.lado_ft || a.usuario_alta || YEAR(a.fecha_alta) || MONTH(a.fecha_alta)|| DAY(a.fecha_alta)|| "." || a.imagen_formato as imagen 
					  from bditef:cce_cheques_img a
					 where a.cvebanco = '137'
					   and a.fecha_alta = pdFechaAlta
					   and a.imagen is null
				  order by 1

				RETURN cCodRet,nombre_img WITH RESUME;	
								
			END FOREACH;
			
		
	END;

END PROCEDURE;