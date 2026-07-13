CREATE PROCEDURE "informix".sp_insertacteporenviar(
                        pEmpresa CHAR(3),
                        pSucursal CHAR(4),
                        pNumCte CHAR(20),
                        pNumSolicitud CHAR(20),
						pErrorDevuelto CHAR(6),
						pEstatus CHAR(1),
						pFechaInserta DATETIME YEAR TO SECOND,
						pFechaActualiza DATETIME YEAR TO SECOND)
	RETURNING CHAR(5);
	--Declaracion de variables
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

	--Inicializacion de variables
	LET cCodRet = '00000';

	--SET debug FILE TO '/tmp/sp_insertacteporenviar.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_insertacteporenviar .out';
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		INSERT INTO "informix".si_clientescoppelporenviar(empresa, sucursal, numcte, num_solicitud, error_devuelto, status, fecha_inserta, fecha_actualiza)
		VALUES(pEmpresa, pSucursal, pNumCte, pNumSolicitud, pErrorDevuelto, pEstatus, pFechaInserta, pFechaActualiza);
	
	--IF pSucursal='0318' OR pSucursal='0371' OR pSucursal='0905' OR pSucursal='0170' OR pSucursal='0249' OR pSucursal='0250' OR pSucursal='0253' OR pSucursal='0254' OR pSucursal='0255' OR pSucursal='0310' OR pSucursal='0332' OR pSucursal='0357' 	OR pSucursal='0358' OR pSucursal='0455' OR pSucursal='0814' OR pSucursal='0907' OR pSucursal='0933' OR pSucursal='0983' OR pSucursal='0255' OR pSucursal='1016'	OR pSucursal='1088' OR pSucursal='1203' OR pSucursal='1214' OR pSucursal='1405' THEN
		INSERT INTO bdinteg: "informix".si_situaciones_clientescoppel_porenviar (empresa,sucursal,numcte,cliente,idusituacion,resultados,status,mensaje,ctl_enviado,empleado,fecha_insert,fecha_modificacion)
		VALUES (pEmpresa,pSucursal,pNumCte,'',0,0,0,'',"0", '', CURRENT,'');		
	--END IF;



		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
"CREO  : Frank Gaxiola Gaxiola",
"FECHA : 05/Septiembre/2012",
"Ver.  : 1.1",
"BD    : bdinteg",
"MODIFICO : Carolina Verdugo",
"FECHA : 18/08/2015",
"FOLIO: 1743",
"DESCRIPCION : Se agrega insert a la tabla si_situaciones_clientescoppel_porenviar",
"SOLICITA:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".validafechadireccioncte(cNumcte char(20))
RETURNING CHAR(5),DATE;

    -- *************************************************************************
    -- | Procedimiento   : validafechadireccioncte
    -- | Versión                :1.0
    -- | Creado por         : Martha Aguirre
    -- | Fecha creacion  : Abril de 2010
    -- | Descripción        : Extrae la fecha de alta de direcciòn de cliente.
    -- *************************************************************************
    
    DEFINE dFechaInsert      DATE;
    DEFINE cCodRet           CHAR(5);
    
    LET dFechaInsert = date(1);
    LET cCodRet = '00000';
    
    --- SET DEBUG FILE TO '/tmp/validafechadireccioncte.out';
    --- TRACE ON;
    
    BEGIN
    
    SET ISOLATION TO DIRTY READ;
	
	if cNumcte = '' then
		
		LET cCodRet = '00001'; --- PARAMETRO VACIO
        LET dFechaInsert = date(1);	
		RETURN cCodRet, dFechaInsert;
		
	end if;
    
    SELECT {+INDEX(si_direcciones_actual idx_diract_ctetpo)}
           fecha_insert 
      into dFechaInsert  
      FROM si_direcciones_actual 
     where numcte = cNumcte
       AND tipo_dir = '1';
       
    if dFechaInsert is not null or dFechaInsert <> '' then
        
    else
        LET cCodRet = '00001'; --- FECHA DE INSERCION NO EXISTE
        LET dFechaInsert = date(1);
    END IF;

    RETURN cCodRet, dFechaInsert;
    
    END;
    
END PROCEDURE;