CREATE PROCEDURE "informix".sp_validacobrocomision
(
pEmpresa  		CHAR(3),
pCuenta   		CHAR(20),
pNumcte   		CHAR(20),
pSucursal 		CHAR(4),
pProducto 		CHAR(4),
pTipo_tarjeta   INTEGER,
pTipo	  		INTEGER
)
	--DATOS A REGRESAR--
	RETURNING 
	CHAR(5) AS CodRet, 
	CHAR(3) AS Codverif,
	CHAR(3) AS CobComi; 
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet				CHAR(5);
	DEFINE cCodverif			CHAR(3); --- cCobComi(Codigo verifica si ya existe el cliente en la tabla)
	DEFINE cCobComi				CHAR(3); --- cCobComi(Cobro Comision)
	DEFINE iSqlErr				INTEGER;
	DEFINE cTipotarjeta			CHAR(4);
	DEFINE ccobcomision			CHAR(1);
	DEFINE vexiste				CHAR(1);
	DEFINE vvereversado			CHAR(1);
	DEFINE vchecacomision		CHAR(1);
	

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet					= '00000';
	LET cCodverif				= '000';
	LET cCobComi				= '000';
	LET iSqlErr					= 0;
	LET cTipotarjeta			= '';
	LET ccobcomision			= '';
		
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
	BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodverif,cCobComi;  
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/sp_validaasignaciontdd.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

-- ****************************************************************************
-- *                    	VALIDAR PARAMETROs  	 		                  *
-- ****************************************************************************

	IF TRIM(NVL(pNumcte,'')) = '' OR TRIM(NVL(pCuenta,'')) = '' THEN
		LET cCodRet = '00001'; --ALGUNO DE LOS PARAMETROS ESTA VACIO O NULO
		RETURN cCodRet,cCodverif,cCobComi;
	END IF;
			
-- ****************************************************************************
-- *                        PROCESO PRINCIPAL                                *
-- ****************************************************************************
		
	IF pTipo_tarjeta = 1 THEN -- pTipo_tarjeta significa que es para el cliente titular asignando el valor de "T"
		LET cTipotarjeta = 'T';
	END IF;
	
	IF pTipo = 1 THEN  ---	Tipo 1 Valida si el cliente existe, en caso que no existe lo va a registrar.
		
		-- Valida si ya se encuentra registrado el cliente en la tabla
		SELECT "1" INTO vexiste from "informix".sc_det_cobrocomision 
		where empresa = pEmpresa and cuenta = pCuenta and numcte = pNumcte and producto = pProducto;
		
		IF vexiste = "1" THEN
			LET cCodverif = '001'; -- Existe el cliente en la tabla
		ELSE
			-- Se insertara en la tabla bdicheq:sc_det_cobrocomision la cual sera la que indique si ya se cobro la comision
			-- se insertara vacio el cobro de la comision ya que no se aplicado el proceso.
			INSERT INTO "informix".sc_det_cobrocomision(empresa, cuenta, numcte, sucursal, producto, tipo_tarjeta, cobro_comision, fechactual) 
			VALUES(pEmpresa, pCuenta, pNumcte, pSucursal, pProducto, cTipotarjeta, '', current);	
		END IF;
		
		
	ELIF pTipo = 2 THEN  --- Tipo 2 se valida si el cliente ya cobro la comision
	
		select cobro_comision INTO ccobcomision from "informix".sc_det_cobrocomision 
		where empresa = pEmpresa and cuenta = pCuenta and numcte = pNumcte and producto = pProducto;
		
		If ccobcomision = 'S' THEN -- Si el valor es 'S' significa que ya se cobro la comision
			LET cCobComi = '001'; -- Se cobro la comision
		END IF;
		
	ELIF pTipo = 3 THEN  --- Tipo 3 Modifica la tabla sc_det_cobrocomision para indicar que ya se cobro la comision.
	
		--- Valida si ya se cobro la comision antes de modificar la tabla sc_det_cobrocomision
		select "1" INTO vvereversado from bdicheq:"informix".sc_movdia 
		where cuenta = pCuenta and transacc = '3260' and cancelad <> 'S';
		
		IF vvereversado = "1" THEN
		
			Update "informix".sc_det_cobrocomision set cobro_comision = 'S' 
			where empresa = pEmpresa and cuenta = pCuenta and numcte = pNumcte and producto = pProducto;
			
		END IF;
		
	ELIF pTipo = 4 THEN  --- Tipo 4 Valida si el cliente ya cobro la comision para ser eliminado y evitar que la tabla contenga muchos datos.

		--- Se valida que el cliente ya tenga cobrada la comision.
		SELECT "1" INTO vchecacomision from "informix".sc_det_cobrocomision 
		where empresa = pEmpresa and cuenta = pCuenta and numcte = pNumcte 
		and producto = pProducto and cobro_comision = 'S';
		
		IF vchecacomision = "1" THEN
		
			Delete from "informix".sc_det_cobrocomision where empresa = pEmpresa and cuenta = pCuenta and numcte = pNumcte and producto = pProducto;
			
		END IF; 		
		
	END IF
	
	RETURN cCodRet,cCodverif,cCobComi;
END
END PROCEDURE
DOCUMENT
'AUTOR: 		Gisela Rivera ',
'FECHA: 		10/08/2016',
'DESCRIPCION: 	Se crea procedimiento para validar cuando asigna una tarjeta de debito identifique',
'				que cliente es el que se le va a cobrar la comision.',
'BD: 			bdicheq',
'SISTEMA: 		astardeb.exe';

CREATE PROCEDURE "informix".sp_bloqctasinformadas( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE vtrxabierta  SMALLINT;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcuenta      CHAR(20);
    
    LET vcodret1    = '000';
    LET vcodret2    = '';
    LET vcodret3    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcomienza   = -1;
    LET vtrxabierta = 0;
    LET vcontador1  = 0;
    LET vcontador2  = 0;
    LET vcuenta     = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqctasinformadas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
        END IF;
        RETURN vcodret1, vcontador1;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqctasinformadas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '5'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vtrxabierta = '1';
            BEGIN WORK;
        END IF;
        
        UPDATE sc_maechq
           SET motivo = '55'
         WHERE cuenta = vcuenta;
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vtrxabierta = 1 THEN
        COMMIT WORK;
        LET vtrxabierta = 0;
    END IF;

    RETURN vcodret1, vcontador1;
    
    END;

END PROCEDURE;