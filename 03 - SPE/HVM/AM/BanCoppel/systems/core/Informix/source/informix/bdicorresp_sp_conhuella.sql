CREATE PROCEDURE "informix".sp_conhuella(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pnumcte CHAR(20))
  RETURNING CHAR(5),char(942),char(942);

define vcodret CHAR(5);
define vexiste CHAR(1);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vmapad  CHAR(942);
define vmapai  CHAR(942);



LET vcodret = "000";
LET vexiste = 0;
LET vmapad = "";
LET vmapai = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vmapad,vmapai;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = "" THEN
   LET vcodret = "110";
   RETURN vcodret,vmapad,vmapai;
END IF;


   SELECT dmapa,imapa  INTO vmapad,vmapai
   FROM   bdinteg:"informix".si_cte_huella
   WHERE  numcte = pnumcte
   AND    estado ="A";
   IF vmapad is null or vmapai is null THEN
      let vcodret = "132";
      RETURN vcodret,vmapad,vmapai;
   END IF

   RETURN vcodret,vmapad,vmapai;
END;
END PROCEDURE
DOCUMENT
"Consulta de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 06/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".corresp_calccomision_retefectdc( 
	pnum_tarjeta	CHAR(16),  		--- TARJETA DE CREDITO
	pmto_tot 		DECIMAL(14,2), 	--- MONTO
	pmoneda 		CHAR(3))  		--- REFERENCIA
RETURNING CHAR(3),     	--- CODIGO DE RETORNO
          CHAR(16), 	--- IMPORTE A RETIRAR
	      CHAR(16), 	--- IMPORTE COMISION
          CHAR(16); 	--- IMPORTE IVA COMISION

    DEFINE sql_err      	INTEGER;
    DEFINE isam_err     	INTEGER;
    DEFINE vcodret1     	CHAR(3);
    DEFINE vcodret2     	CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
    
	DEFINE cImpRetirar		CHAR(16);
	DEFINE cImpComision		CHAR(16);
	DEFINE cImpIvaComision	CHAR(16);
	DEFINE cTranConsSdo		CHAR(4);
	DEFINE iImpRetirar		INT8;
	DEFINE iImpComision		INT8;
	DEFINE iImpIvaComision	INT8;
	--// PARAMETROS SP_CONSULTA_RETIRO_TDC
	DEFINE crCodRet			CHAR(5);
	DEFINE crImpRetirar		DECIMAL(14,2);
	DEFINE crImpComision	DECIMAL(14,2);
	DEFINE crImpIvaComision	DECIMAL(14,2);
	DEFINE cNumCredito		CHAR(20);
	DEFINE vstatus_tar      CHAR(1);
	
   
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion     = 0;
	LET vproceso        = '0';
	
	LET cImpRetirar		= "";
	LET cImpComision		= "";
	LET cImpIvaComision	= "";
	LET cTranConsSdo	= "";
	LET iImpRetirar		= 0;
	LET iImpComision	= 0;
	LET iImpIvaComision	= 0;
	--// PARAMETROS SP_CONSULTA_RETIRO_TDC
	LET crCodRet			= "000";
	LET crImpRetirar		= 0.0;
	LET crImpComision		= 0.0;
	LET crImpIvaComision	= 0.0;	
	LET cNumCredito		= "";
	LET vstatus_tar      = '';
    	
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_calccomision_retefectdc.out";
     --SET DEBUG FILE TO "/informix/moha/corresp_calccomision_retefectdc.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_calccomision_retefectdc.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            ELSE
                LET vcodret1 = '999';
            END IF;
            RETURN vcodret1, cImpRetirar, cImpComision, cImpIvaComision;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF (pnum_tarjeta IS NULL) OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        
    END IF;
	
	LET pmto_tot = pmto_tot / 100;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
	
    -- // VALIDA DATOS DEL CREDITO
	SELECT num_credito, status_tar
	INTO cNumCredito, vstatus_tar
	FROM bdicred:sd_tarjeta
	WHERE num_tarjeta = pnum_tarjeta
	AND empresa = '001';
        
    IF cNumCredito is null THEN
        LET cNumCredito = ' ';
    END IF;
    
    IF vstatus_tar is null THEN
        LET vstatus_tar = ' ';
    END IF;
	
    IF (cNumCredito is null OR cNumCredito = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '008';
        RETURN vcodret1, cImpRetirar, cImpComision, cImpIvaComision;
    END IF;
	
	EXECUTE PROCEDURE bdicred: sp_consulta_retiro_tdc( "001", "5005", "", pnum_tarjeta, pmto_tot, "01")
	INTO crCodRet, crImpRetirar, crImpComision,	crImpIvaComision;
	IF crCodRet <> "000" THEN
		LET vcodret1 = '999';
		LET vcodret1 = LPAD(vcodret1,3,'0');
		IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
		
		RETURN vcodret1, cImpRetirar, cImpComision, cImpIvaComision;
	ELSE
		LET iImpRetirar = ROUND(crImpRetirar,0);
		LET cImpRetirar = LPAD(iImpRetirar,14,'0') || '00';
		LET iImpComision = ROUND(crImpComision,0);
		LET cImpComision = LPAD(iImpComision,14,'0') || '00';
		LET iImpIvaComision = ROUND(crImpIvaComision,0);
		LET cImpIvaComision = LPAD(iImpIvaComision,14,'0') || '00';
	END IF
	
	LET iImpRetirar		= 0;
	LET iImpComision	= 0;
	LET iImpIvaComision	= 0;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vcodret1, cImpRetirar, cImpComision, cImpIvaComision;
    
    END;

END PROCEDURE;