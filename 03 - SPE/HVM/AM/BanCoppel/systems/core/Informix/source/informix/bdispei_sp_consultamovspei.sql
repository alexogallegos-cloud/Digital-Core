CREATE PROCEDURE "informix".sp_consultamovspei(pFecha DATE, pSucursal CHAR(4))
RETURNING CHAR(5) AS rCod_retorno,
		CHAR(50) AS rMensaje;

	-- ***************************************************************************
	-- Declaracion de variables
	-- ***************************************************************************
	DEFINE iSql_err INTEGER;
	DEFINE cCod_retorno CHAR(5);
	DEFINE cMensaje VARCHAR(50);
	DEFINE cClaveRastreo VARCHAR(30);
	
	DEFINE iCount INTEGER;

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCod_retorno = iSql_err;
			LET cMensaje = 'Ocurrio un error.';
			RETURN cCod_retorno, cMensaje;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Elmer/sp_consultamovspei.out';
	--TRACE ON;

	-- ***************************************************************************
	-- Inicializacion de variables
	-- ***************************************************************************
	LET iSql_err = 0;
	LET cCod_retorno = '00001';
	LET cMensaje = '';
	LET cClaveRastreo = '';
	
	LET iCount = 0;

	SET LOCK MODE TO WAIT 3;

	IF ((pFecha IS NOT NULL OR pFecha <> '') AND (pSucursal IS NOT NULL OR pSucursal <> '')) THEN
		SELECT LIMIT 1 pago.vchrclaverastreo INTO cClaveRastreo
		  FROM bdispei: tblpago pago,
			   bdispei: tbldetranpago det
		 WHERE pago.dtfechacaptura = pFecha
		   AND pago.chrsentidopago = 'E'
		   AND pago.intcvetipopago = 1
		   AND pago.vchrclaverastreo = det.clave_rastreo
		   AND det.transacc = "0274"	
		   AND det.sucursal = pSucursal		
		   AND pago.chrestatusenvio IN ('L','D','C');
		
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCod_retorno = '00003';
			LET cMensaje = 'No existen movimientos de spei para ese dia';
		ELSE
			LET cCod_retorno = '00000';
			LET cMensaje = 'Si existen movimientos de spei para ese dia';
		END IF;
	ELSE
		LET cCod_retorno = '00002';
		LET cMensaje = 'Uno de los parametros viene vacio';
	END IF;
	
	RETURN cCod_retorno, cMensaje;

END PROCEDURE
DOCUMENT
'Folio: 778',
'AUTOR : Elmer Lopez Valenzuela',
'FECHA : 25/02/2022',
'MODIFICACION: Procedimiento para consultar si existen movimientos de spei.',
'SOLICITA: Abraham Narvaez',
'BD: bdispei';

CREATE PROCEDURE "informix".speicentral() 

RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(5);
	DEFINE vexiste          INTEGER;
	
      
    DEFINE vcountresult     INTEGER;
   

    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = "000";
	LET vexiste  = 0;
       
	
	-- SET DEBUG FILE TO "/ifxsif01/scripts/speicentral.out";
     
	-- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
	 
	 SELECT COUNT(*) 
	  INTO vexiste
	  FROM bdinteg:si_feriado
	 WHERE
	 fecha::DATE = CURRENT::DATE;
	 
	 IF vexiste = 0 THEN
        SELECT count(*) 
			INTO vcountresult
			FROM tblpago
		   WHERE dtfechavalor = today;
   
		IF vcountresult = 0 THEN
			LET vcodret1 = '00000';
		ELSE
			--LET vcodret1 = '11111';
			LET vcodret1 = '00000'; 
		END IF;
	 
	 ELSE
	 
		LET vcodret1 = '22222';
	 
	 END IF
       
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;