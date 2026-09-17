CREATE PROCEDURE "informix".sp_consultapaises_web(pNumeroPagina INTEGER, pCantidadRegistros INTEGER)

--ENTRADAS:
--pNumeroPagina			= Número de página del segmento, iniciando en 0, 1, 2 hasta que se terminen los datos de la tablas.
--pCantidadRegistros	= Número de registros por segmentos, si es 0 tomará 16 como defecto.

--RETORNOS:
--000000 = Éxitoso.
--000001 = No hay registros para esos parámetros.
--000002 = Parámetros Negativos.

--DATOS DE RETORNO
RETURNING
CHAR(05) AS codRet,
CHAR(03) AS idPais,
CHAR(30) AS nombrePais;
		
--DEFINICIÓN DE VARIABLES
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(05);
DEFINE cIdPais		CHAR(03);
DEFINE cNombrePais	CHAR(30);
DEFINE iNumeroPag	INTEGER;
DEFINE iCantidadRe	INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr		= 0;
LET cCodRet		= '00000';
LET cIdPais		= '';
LET cNombrePais	= '';
LET iNumeroPag	= 0;
LET iCantidadRe	= 0;
	
	--SET DEBUG FILE TO "";
	--TRACE ON;
	
-- INICIO DEL PROCEDIMIENTO
	BEGIN
		-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdPais,cNombrePais;
			END IF;
		END EXCEPTION;	
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR PARÁMETROS NULOS O NEGATIVOS
		IF NVL(pNumeroPagina, 0) < 0 OR NVL(pCantidadRegistros, 0) < 0 THEN
			LET cCodRet = '00002';
			LET cNombrePais = 'Parámetros en cero o negativos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
		
		--ESTABLECER VALORES POR DEFECTO
		IF pCantidadRegistros = 0 THEN
			LET iCantidadRe = 16;
		ELSE
			LET iCantidadRe = pCantidadRegistros;
		END IF
		LET iNumeroPag = pNumeroPagina * iCantidadRe;
	
		FOREACH
			--CONSULTAR LA TABLA si_paisnacion
			SELECT SKIP iNumeroPag FIRST iCantidadRe id_pais, nombre 
			INTO cIdPais, cNombrePais
			FROM bdinteg:"informix".si_paisnacion
			ORDER BY nombre

			RETURN cCodRet, cIdPais, cNombrePais WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			LET cNombrePais = 'Sin Datos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
			
	END
END PROCEDURE
DOCUMENT
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - José Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripción:	Creación de SP que consulta el catálogo de paises por segmentos",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694";

CREATE PROCEDURE "informix".sp_consultareferencias_web (pEmpresa char(3), pNumeroCliente char(20))
        returning char(5), integer, integer;

--Creado: Rodolfo Tortolero Varela
--Fecha: 05/03/2009
--Consulta las secuencias maximas del cliente en la tabla si_refclientes

--Se Definen Variables
DEFINE iSqlErr INTEGER;
DEFINE vcodret char(5);
DEFINE iSecuencia1 integer;
DEFINE iSecuencia2 integer;

--Se Inicializan Variables
LET vcodret = "00000";
LET iSecuencia1  = 0;
LET iSecuencia2  = 0;

    BEGIN
            ON EXCEPTION
                    SET iSqlErr
                    IF iSqlErr <> 0 THEN
                            LET vCodRet = iSqlErr;
                            RETURN  vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            END EXCEPTION;

            SELECT  MAX(secuencia)  INTO iSecuencia1
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente;

            SELECT  MAX(secuencia)  INTO iSecuencia2
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente AND secuencia < iSecuencia1;

            IF iSecuencia1 <> 0 OR iSecuencia1 IS NOT NULL THEN
                    IF iSecuencia2 <> 0  OR iSecuencia2 IS NOT NULL THEN
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    ELSE
                            LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            ELSE
                    LET vcodret = '00001'; --No tiene NÃºmero de Secuencia
                    RETURN vcodret, iSecuencia1, iSecuencia2;
            END IF;
    END;
END PROCEDURE;