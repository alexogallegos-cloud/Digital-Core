CREATE PROCEDURE "informix".sp_consulta_recuperacion (folio VARCHAR(11))

	RETURNING  MONEY AS AbonoTot, MONEY AS AbonoRecup, MONEY AS ComisionTot, MONEY AS ComisionRecup,MONEY AS IvaTot, MONEY AS IvaRecup;
    

    /* Variables para la salida del SP*/
    DEFINE v_AbonoTot MONEY;
    DEFINE v_AbonoRecup MONEY;
    DEFINE v_ComisionTot MONEY;
    DEFINE v_ComisionRecup MONEY;
    DEFINE v_IvaTot MONEY;
    DEFINE v_IvaRecup MONEY;

    /* Variables para el cÃÂ¡lculo del IVA*/
    DEFINE v_ComisionA MONEY;
    DEFINE v_IvaA MONEY;
    DEFINE v_Porcentaje INTEGER;
    DEFINE v_Ciento INTEGER;

	SET ISOLATION TO DIRTY READ;
	
    BEGIN

    LET v_ComisionA = 0;
    LET v_IvaA = 0;
    LET v_Ciento = 100;
    LET v_Porcentaje = 116;
    
    /* AsignaciÃÂ³n a las variables ComisiÃÂ³n e Iva*/
    LET v_ComisionTot= (SELECT total_comision 
                        FROM bdiaclaracion:acl_recuperacion_saldos 
                        WHERE folio_csuac = folio);

    LET v_IvaTot = (SELECT total_iva 
                        FROM bdiaclaracion:acl_recuperacion_saldos 
                        WHERE folio_csuac = folio);


    /* Variables para el cÃÂ¡lculo del IVA*/
    IF v_IvaTot == 0 THEN
        let v_ComisionA = (v_ComisionTot * v_Ciento) / v_Porcentaje;
        leT v_IvaA = v_ComisionTot - v_ComisionA;
        update bdiaclaracion:acl_recuperacion_saldos set total_comision = v_ComisionA, total_iva = v_IvaA where folio_csuac = folio;
    END IF;

    /* Consulta a la tabla acl_recuperacion_saldos*/
    SELECT total_abono AS AbonoTot, 
           abono_recuperado AS AbonoRecup, 
           total_comision AS ComisionTot, 
           comision_recuperada AS ComisionRecup, 
           total_iva AS IvaTot, 
           iva_recuperada AS IvaRecup
    INTO  v_AbonoTot,v_AbonoRecup, v_ComisionTot, v_ComisionRecup, v_IvaTot,v_IvaRecup  
    FROM bdiaclaracion:acl_recuperacion_saldos 
    WHERE folio_csuac = folio;

    RETURN v_AbonoTot, v_AbonoRecup, v_ComisionTot, v_ComisionRecup, v_IvaTot, v_IvaRecup;
    
    END;
END PROCEDURE;