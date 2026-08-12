CREATE PROCEDURE "informix".sp_obtfoliocn2(p_empresa char(3))
    RETURNING   CHAR(5)  AS vcodret,
	            CHAR(12) AS vFolio;
 
    DEFINE vsqlerr    INTEGER;
    DEFINE iIsamErr   SMALLINT;
    DEFINE cErrorInfo CHAR(80);
	DEFINE vErrorInfo CHAR(80);
    DEFINE vcodret    CHAR(5);
	DEFINE intFolio   INTEGER;
    DEFINE vCod_param INTEGER;
	DEFINE vFolio     CHAR(12);
	DEFINE vFolioCN2  CHAR(3);
    	
	
    LET vsqlerr       = 0; 
    LET iIsamErr      = 0;
    LET cErrorInfo    = ""; 
	LET vErrorInfo    = "INICIO DEL PROCESO";
    LET vcodret       = "00000";	
    LET intFolio      = 0;	
	LET vCod_param    = 520;
	LET vFolio        = "";
	LET vFolioCN2     = "CN2";

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtfolioCN2.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            RETURN vcodRet,vFolio;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/comision.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
	
	--OBTIENE EL VALOR DEL FOLIO
	SELECT valor
    INTO   intFolio
    FROM   bdinteg:si_param
    WHERE  cod_param = vCod_param;
	
	--VALIDA QUE EXISTA EL PARAMETRO
	IF intFolio IS NULL OR intFolio = '' THEN 
	   LET vcodret    = 00001;
       LET vErrorInfo = 'SIN VALOR';
	    RETURN vcodRet,vErrorInfo;
	ELSE 
	   -- INCREMENTA EL FOLIO + 1 
	   LET  intFolio = intFolio + 1;
	END IF;
	
	--ACTUALIZA EL FOLIO PARA LA SIGUIENTE FOLIO
	UPDATE bdinteg:si_param 
	SET    valor = intFolio
	WHERE  cod_param = vCod_param;
	
	--ARMA LA CADENA DEL FOLIO FINAL
	LET vFolio = vFolioCN2||LPAD(intFolio,9,'0');

RETURN vcodRet,vFolio;
END; 
END PROCEDURE;