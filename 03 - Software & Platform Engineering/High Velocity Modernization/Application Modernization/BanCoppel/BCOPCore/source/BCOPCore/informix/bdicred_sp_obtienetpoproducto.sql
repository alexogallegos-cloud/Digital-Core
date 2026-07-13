CREATE PROCEDURE "informix".sp_obtienetpoproducto()
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(7)  AS NumeroProd,
			CHAR(40) AS DescripcionProd;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cNumProducto		CHAR(7);
DEFINE cDescProducto	CHAR(40);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cNumProducto			= '';
LET cDescProducto			= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto);
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_obtienetpoproducto.out';
--TRACE ON;

	FOREACH
	
		SELECT abrevia_prod, descrip_prod
		INTO cNumProducto, cDescProducto
		FROM bdicred:"informix".sd_tipprod
		ORDER BY abrevia_prod
		
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto) WITH RESUME;
		
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto);
    END IF;
	
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Obtiene los productos de crédito y su descripción ',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 01/Dic/2011',
'BD    : BDICRED',
'Version: 20111201.1614';

CREATE PROCEDURE "informix".updtraspcred800(fecha_inicial date)
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
--DEFINE cVarDataErr      CHAR(100);
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vcuantos 	INTEGER;
DEFINE vactualizados 	INTEGER;
DEFINE vleidos   	INTEGER;
DEFINE vreferencia	CHAR(30);
DEFINE vchrfolio        CHAR(16);
DEFINE vfolio           CHAR(16);
DEFINE vtransaccion     CHAR(4);
DEFINE vusuario         CHAR(4);
DEFINE vchrtransuc      CHAR(4);
DEFINE vsucursal        CHAR(4);
DEFINE vdivisa          CHAR(2);
DEFINE vhora            CHAR(15);
DEFINE vnum_credito          CHAR(20);
DEFINE vchrTarjeta      CHAR(16);
DEFINE vimporte_abono   MONEY(14,2);
DEFINE vempresa         CHAR(3);
--DEFINE v_codigo_fun     CHAR(3);
--DEFINE v_codigo_ref     INTEGER;

--LET cVarDataErr = '';
LET vchrTarjeta = '';
LET vnum_credito = '';

BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
    	   LET vchrcodret = vintcodret;
           rollback work;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;

    --//DEBUG FLAG
    --SET debug file to "/tmp/updtraspcred800.out";
    --TRACE ON;

    --//Inicializacion de variables
    LET vchrcodret = '000';
    LET vempresa = '001';
    LET vtransaccion = '6800';
    LET vactualizados = 0;
    LET vleidos = 0;

    set isolation to dirty read;
    truncate table temporalcred800;

--    SELECT codigo_fun, codigo_ref 
--      INTO v_codigo_fun, v_codigo_ref
--      FROM sd_transfun 
--     WHERE transacc  = vtransaccion;
    
       SELECT secuenciaextendida, numtarjeta, idterminal, 0 as status
         FROM intercard:movimiento 
        WHERE fechahorainauth >= fecha_inicial
          AND numtarjeta matches '426807*'
          AND prodind = '01' 
          AND codtran = '01' 
          AND monto > 0 
          AND movreversado = 'F' 
          AND codigoiso = '00'
       union all
       SELECT secuenciaextendida, numtarjeta, idterminal, 0 as status
         FROM intercard:movimientohistorico
        WHERE fechalocaltransaccion >= lpad(month(date(fecha_inicial)),2,0)||lpad(day(date(fecha_inicial)),2,0) 
          and fechahorainauth >= fecha_inicial
          AND numtarjeta matches '426807*'
          AND prodind = '01' 
          AND codtran = '01' 
          AND monto > 0 
          AND movreversado = 'F' 
          AND codigoiso = '00' into temp resol with no log;


     create index temp1 on resol(secuenciaextendida, numtarjeta, idterminal, status);
     update statistics medium for table resol;


     INSERT INTO temporalcred800
     select secuenciaextendida, numtarjeta, idterminal, status from resol
     group by 1,2,3,4;

     update statistics medium for table bdicred:temporalcred800;

        FOREACH WITH HOLD
        
        SELECT trim(folio),tarjeta, trim(refer)
          INTO vfolio, vchrTarjeta, vreferencia
          FROM temporalcred800 
         WHERE status = 0

	begin work;

        SELECT limit 1 num_credito 
          INTO vnum_credito
          FROM sd_tarjeta
         WHERE empresa = vempresa
           AND num_tarjeta = vchrTarjeta;

        LET vcuantos = 0;
        LET vchrfolio = 'i'||trim(vfolio);

	UPDATE bdicred:sd_movhisedocta SET referencia = trim(referencia)||' '||vreferencia
	 WHERE empresa = vempresa 
       AND num_credito = vnum_credito
	   AND codigo_fun = '002' AND codigo_ref in (30,40,41,42)
	   AND fecha_mov >= fecha_inicial 
	   AND reversado = "N"
       AND folio_suc = trim(vchrfolio);

        LET vcuantos = DBINFO("sqlca.sqlerrd2");

        IF vcuantos > 0 then
           UPDATE temporalcred800
              SET status = 1
            WHERE folio = vfolio
              AND tarjeta = vchrTarjeta
              AND refer = vreferencia;
           LET vactualizados = vactualizados + 1;
        END IF
        LET vleidos = vleidos + 1;
        commit work;
    END FOREACH

    --//Entrega el codigo de retorno 
--  RETURN vchrcodret, "Registros leidos: " ||vleidos, "Registros Actualizados: " ||vactualizados;
    RETURN vchrcodret;

END
END PROCEDURE;