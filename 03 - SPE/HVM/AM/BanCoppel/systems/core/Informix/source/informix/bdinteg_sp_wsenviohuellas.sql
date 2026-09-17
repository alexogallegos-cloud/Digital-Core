CREATE PROCEDURE "informix".sp_wsenviohuellas(fechaActual DATE,registros INT)

RETURNING
        CHAR(5)   as ccCodRetorno,
        char(100) as mensaje,
        CHAR(10)  as cCliente_coppel,
        CHAR(10)  as cCliente_banco,
        CHAR(10)  as cUsuario,
        CHAR      as cSexo,
        CHAR      as cCompany,
        CHAR      as cstore_number,
        CHAR      as cStatus_huella,
        date      as dFecha_insert,
        CHAR      as cDpositiond,
        CHAR      as cDsecuencia,
        CHAR(942) as cDMapa,
        CHAR      as cIpositiond,
        CHAR      as cIsecuencia,
        CHAR(942) as cIMapa;


DEFINE  ccCodRetorno    CHAR(5);
DEFINE  mensaje         char(100);                                                                        
DEFINE  cCliente_coppel CHAR(10);
DEFINE  cCliente_banco  CHAR(10);
DEFINE  cUsuario        CHAR(10);
DEFINE  cSexo           CHAR;
DEFINE  cCompany        CHAR;
DEFINE  cstore_number   CHAR;
DEFINE  cStatus_huella  CHAR;
DEFINE  dFecha_insert   date;
DEFINE  cDpositiond     CHAR;
DEFINE  cDsecuencia     CHAR;
DEFINE  cDMapa          CHAR(942);
DEFINE  cIpositiond     CHAR;
DEFINE  cIsecuencia     CHAR;
DEFINE  cIMapa          CHAR(942);
DEFINE  iNumreg         INTEGER;
DEFINE  sql_err         INTEGER;
DEFINE  isam_err        INTEGER;
DEFINE  vcodret1        INTEGER;
DEFINE  vcodret2        INTEGER;

LET  ccCodRetorno       = '00000';
LET  mensaje            = 'EXITO' ;
LET  cCliente_coppel    = '';
LET  cCliente_banco     = '';
LET  cUsuario           = '';
LET  cSexo              = '';
LET  cCompany           = '';
LET  cstore_number      = '';
LET  cStatus_huella     = '';
LET  dFecha_insert      = mdy(01,01,1900);
LET  cDpositiond        = '';
LET  cDsecuencia        = '';
LET  cDMapa             = '';
LET  cIpositiond        = '';
LET  cIsecuencia        = '';
LET  cIMapa             = '';
LET  iNumreg            = 0;

BEGIN

        ON EXCEPTION SET sql_err, isam_err
            IF sql_err <> 0 THEN
                                LET ccCodRetorno = sql_err;
                                LET mensaje = 'NUM ISAM ERR: '|| isam_err || ' ' || "SQL";
            RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,TODAY,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/EPG/sp_wsenviohuellas.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
        IF   ( registros IS NULL OR registros = '' OR registros < 0  ) THEN
                LET ccCodRetorno = '00002';
                LET mensaje = "Valor de variable registros no validos";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF

        DELETE FROM sp_temphuella;
		
        INSERT INTO  bdinteg:cte_coppel_huella 
        SELECT a.numcte_coppel,0,c.numcte_banco, CURRENT TIMESTAMP,a.fecha_insert,'' 
        FROM clientes_coppel_envia_xml a 
        LEFT JOIN cte_coppel_huella b ON a.numcte_coppel = b.numcte_coppel 
        LEFT JOIN si_relacion_ctebcplcpl c ON c.cliente = a.numcte_coppel
        WHERE b.numcte_coppel IS NULL AND a.fecha_insert >= MDY(month (fechaActual),day (fechaActual),year(fechaActual));
 

        INSERT INTO  bdinteg:sp_temphuella 
        SELECT LIMIT registros numcte_coppel, numcte_banco 
		FROM cte_coppel_huella
		--INNER JOIN si_huella_linea AS a on numcte_banco = a.numcte 
		WHERE estatus = 0  
			and date (fec_xml_creacion)= MDY(month (fechaActual),day (fechaActual),year(fechaActual));

					
        FOREACH
              
            SELECT LIMIT registros d.numcte_coppel, d.numcte_banco
            INTO  cCliente_coppel,cCliente_banco
            FROM sp_temphuella AS d
                    
			SELECT empleado, sexo, 5 AS company, 2 AS store_number, status_huella, date (fecha_alta_huella),  2 AS positiond, secuencia, dmapa, 7 AS positiond, secuencia, imapa 
            INTO  cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa
            FROM si_huella_linea AS a 
			WHERE a.numcte = cCliente_banco;	
				
			IF cUsuario is null THEN
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 3, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
			ELSE
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 1, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
				LET iNumreg = iNumreg + 1;     	 

				RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa WITH RESUME;

			END IF;
			
        END FOREACH;


        IF  iNumreg = 0 THEN
                LET ccCodRetorno = '00001';
                LET mensaje = "No se encontro informacion por actualizar";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;

END


END PROCEDURE;