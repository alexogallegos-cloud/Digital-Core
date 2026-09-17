CREATE PROCEDURE "informix".sp_consultaparamcobranza(pCodParam INTEGER)
	returning 	char(5)  	as CodRetorno,
				DATE		as fecha,
				CHAR(100)	as ruta;
								
			--Declararacion de Varibles
		DEFINE cSqlErr		INTEGER;
		DEFINE vCodRet 		CHAR(5);
		DEFINE dFecha		DATE;
		DEFINE vruta		CHAR(100);
		
		LET cSqlErr = 		0;
		LET vCodRet = 		"00000";
		LET vruta	= 		"";
		
		--SET DEBUG FILE TO "/home/sysifx/alex/sp_consultaparamcobranza.out";
		--TRACE ON;
		BEGIN
			 ON EXCEPTION SET cSqlErr
		        IF cSqlerr <> 0 THEN
		            Let vCodRet = cSqlErr;
					RETURN vCodRet,dFecha,vruta;
				END IF;
			END EXCEPTION; 
			--se obtiene la fecha
			SELECT unique(fecha_hoy) INTO dFecha FROM bdinteg:si_fechas;
			--se obtiene la ruta
			SELECT TRIM(valor) INTO vruta FROM bdicobranza:cb_param WHERE cod_param = pCodParam;
			
			IF vruta IS NULL OR vruta = '' OR dFecha IS NULL OR dFecha = '' THEN
				LET vCodRet = '00001';
			END IF;
			
			RETURN vCodRet,dFecha,vruta;
		END;
END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Mtto-AdminComapañas',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Extrae la la fecha hoy y la ruta del archivo',
'Fecha: 2010/06/24',
'Version: 20100624.0847',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_importaarchgestioncat()

RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE cMensaje                     CHAR(80);

DEFINE cCadena                      CHAR (500);
DEFINE vPath                        CHAR(50);
DEFINE vNomArch                     CHAR(30);
DEFINE vSeparador                   CHAR(1); 
DEFINE vMes                         CHAR(2);
DEFINE vAnio                        CHAR(4);
DEFINE vExtensionArch               CHAR(4);
------------------------------------------------------------

-- Creado por: MACF
-- Fecha: 16/06/2010
-- Para cargar un archivo de Gestión de cobranza administrativa
LET cCod_ret       = '00000';
LET sql_err        = 0;
LET cMensaje       = 'Proceso Exitoso';
LET cCadena        = '';
LET vPath          = '';
LET vSeparador     = '|';
LET vExtensionArch = '.txt';

  BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/macf/SP_ImportarArchGestionCob.out";
    --SET DEBUG FILE TO "/home/syscobra/SP_ImportarArchGestionCob.out";
    --TRACE ON;

    SELECT substr(fecha_hoy,7,4) into vAnio from bdinteg:si_fechas;
    SELECT substr(fecha_hoy,1,2) into vMes from bdinteg:si_fechas;

    select valor into vPath 
    from bdicobranza:cb_param 
    where cod_param = 1;

    select valor into vNomArch 
    from bdicobranza:cb_param 
    where cod_param = 11;


    LET cCadena = 'echo "load from ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || vAnio || vMes || vExtensionArch || ' delimiter ''' || vSeparador || ''' insert into bdicobranza:cb_gestioncobadmin" >' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_cb_gestioncobadmin.sql';
insert into cb_bitacora(empresa, mensaje) values(1,cCadena);

    System SUBSTR(cCadena,1,LENGTH(cCadena));
    let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_cb_gestioncobadmin.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
    let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_cb_gestioncobadmin.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
          


    RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;