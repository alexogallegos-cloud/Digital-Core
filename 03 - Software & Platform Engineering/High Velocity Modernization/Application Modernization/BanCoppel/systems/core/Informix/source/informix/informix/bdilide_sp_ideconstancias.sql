CREATE PROCEDURE "informix".sp_ideconstancias(pTipo SMALLINT, pNumeroCliente CHAR(20), pFecha CHAR(6))
RETURNING CHAR(5),  -- Codigo de Retorno
          CHAR(13), -- RFC Contribuyente
          CHAR(20), -- CURP Contribuyente
          CHAR(26), -- Apell Paterno
          CHAR(26), -- Apell Materno
          CHAR(26), -- Nombre1
          CHAR(26), -- Nombre2
          CHAR(60), -- RS Contribuyente
          CHAR(13), -- RFC Institucion
          CHAR(60), -- RS Institucion
          MONEY(16,2), -- Imp acumulado
          MONEY(16,2), -- Imp a recaudar
          MONEY(16,2), -- Imp recaudado
          MONEY(16,2), -- Imp pendiente
          MONEY(16,2), -- Imp Remanente
          CHAR (2), -- Tipo de Cambio
          CHAR(20), --Referencia
		  CHAR(60); --DesSufijo	DSB 20/02/2013
		  
    --*******************************************************************************************************
    -- Realizo   :Alejandro Osuna
    -- Proyecto : Correción Recaudacion del LIDE
    -- Actividad : Se modifico en el caso de que cuando el cliente sólo tuvo recaudación de periodos
    --                  anteriores, y no se le generó una recaudación en el periodo de consulta se grabe el 
    --                  numero de folio correspondiente
    -- Fecha     : 01 de Septiembre de 2008
    --*******************************************************************************************************
    --*******************************************************************************************************
    -- Modifico   :Alejandro Osuna
    -- Actividad : Se modifico todas las variables money, se pasaron de (10,2) a (16,2)
    -- Fecha     : 07 de Enero de 2008
    --*******************************************************************************************************
    --*******************************************************************************************************
    -- Modifico   :Martin Miranda
    -- Actividad : Se modifico para tomar en cuenta el campo rfc_alterno y si este no existe tomara el campo rfc
    -- Fecha     : 11 de marzo del 2011
    --*******************************************************************************************************

    -- DEFINICION DE VARIABLES
    DEFINE cCodRet CHAR(5);
    DEFINE cRfccontribuyente CHAR(13);
    DEFINE cCurpcopntribuyente CHAR(20);
    DEFINE cApellpaterno CHAR(26);
    DEFINE cApellmaterno CHAR(26);
    DEFINE cNombre1 CHAR(26);
    DEFINE cNombre2 CHAR(26);
    DEFINE cRazoncontribuyente CHAR(60);
    DEFINE cRfcinstitucion CHAR(13);
    DEFINE cRazoninstitucion CHAR(60);
    DEFINE mImpacumulado MONEY(16,2);
    DEFINE mImparecaudar MONEY(16,2);
    DEFINE mImprecaudado MONEY(16,2);
    DEFINE mImppendiente MONEY(16,2);
    DEFINE mImpremanente MONEY(16,2);
    DEFINE mTipocambio CHAR(2);
    define cAuxFecha   CHAR(6);
    DEFINE cFolio CHAR(20);
    DEFINE cTpo_persona CHAR(2);
    DEFINE vexiste INTEGER;
	DEFINE cDesSufijo CHAR(60); --DSB 20/02/2013

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "000";
    LET cRfccontribuyente = "";
    LET cCurpcopntribuyente = "";
    LET cApellpaterno = "";
    LET cApellmaterno = "";
    LET cNombre1 = "";
    LET cNombre2 = "";
    LET cRazoncontribuyente = "";
    LET cRfcinstitucion = "";
    LET cRazoninstitucion = "";
    LET mImpacumulado = 0;
    LET mImparecaudar = 0;
    LET mImprecaudado = 0;
    LET mImppendiente = 0;
    LET mImpremanente = 0;
    LET mTipocambio = "01";
    LET cAuxFecha = "";
    LET cFolio = "";
    LET cTpo_persona  = "";
    LET vexiste = 0;
	LET cDesSufijo = ''; --DSB 20/02/2013

    --- SET DEBUG FILE TO "/tmp/sp_ideconstancias.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Obtiene datos del Contribuyente
    SELECT tpo_persona
      INTO cTpo_persona
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumeroCliente;

    IF ( cTpo_persona = '01') THEN		
        IF (SELECT rfc_alterno FROM bdinteg:"informix".si_cliente WHERE empresa = '001' AND numcte = pNumeroCliente) <> "" THEN
            SELECT NVL(a.rfc_alterno, ''), NVL(b.curp, ''), NVL(a.apell_paterno, ''), NVL(a.apell_materno, ''), NVL(a.nombre1, ''), NVL(a.nombre2, ''), NVL(a.razon_social, '')
              INTO cRfccontribuyente, cCurpcopntribuyente, cApellpaterno, cApellmaterno, cNombre1, cNombre2, cRazoncontribuyente
              FROM bdinteg:"informix".si_cliente a, 
                   bdinteg:"informix".si_ctepf b
             WHERE a.numcte = pNumeroCliente
               AND a.numcte = b.numcte;
        ELSE
            SELECT NVL(a.rfc, ''), NVL(b.curp, ''), NVL(a.apell_paterno, ''), NVL(a.apell_materno, ''), NVL(a.nombre1, ''), NVL(a.nombre2, ''), NVL(a.razon_social, '')
              INTO cRfccontribuyente, cCurpcopntribuyente, cApellpaterno, cApellmaterno, cNombre1, cNombre2, cRazoncontribuyente
              FROM bdinteg:"informix".si_cliente a, 
                   bdinteg:"informix".si_ctepf b
             WHERE a.numcte = pNumeroCliente
               AND a.numcte = b.numcte;
        END IF
    END IF

    IF( cTpo_persona = '02')  THEN
        SELECT NVL(razon_social, ''), NVL(rfc, '')
          INTO cRazoncontribuyente, cRfccontribuyente
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pNumeroCliente;
		 
		 --DSB 20/02/2013
		SELECT NVL(descripcion, '')
		INTO cDesSufijo
		FROM bdinteg:"informix".si_sufijos suf,
			 bdinteg:"informix".si_ctepm cte
		WHERE suf.codigo = cte.sufijo 
		AND cte.numcte = pNumeroCliente;
    END IF	

    -- // Datos de identificacion de la institucion financiera recaudadora
    SELECT NVL(desc_valor, '')
      INTO cRfcinstitucion
      FROM bdilide:"informix".sl_parametros
     WHERE cve_param = '08'
       AND valor = '01';

    SELECT NVL(desc_valor, '')
      INTO cRazoninstitucion
      FROM bdilide:"informix".sl_parametros
     WHERE cve_param = '08'
       AND valor = '02';

    IF pTipo = 1 THEN
        -- // Mensual
        SELECT NVL(imp_excedente, 0), NVL(imp_arecaudar, 0), NVL(imp_recaudado, 0), NVL(imp_pendiente, 0), NVL(imp_anterior, 0)
          INTO mImpacumulado, mImparecaudar, mImprecaudado, mImppendiente, mImpremanente
          FROM bdilide:"informix".sl_constancias
         WHERE num_cte = pNumeroCliente
           AND aniomes = pFecha
           AND tipo_cons = 'M'
           AND rfc IS NOT NULL;

        SELECT COUNT(*)
          INTO vexiste
          FROM bdilide:"informix".sl_retlide 
         WHERE num_cte = pNumeroCliente 
           AND aniomes = pFecha
           AND rfc IS NOT NULL;

        IF vexiste > 0 THEN
        --- IF EXISTS (SELECT ref_ret  FROM bdilide:"informix".sl_retlide WHERE num_cte = pNumeroCliente AND aniomes = pFecha) THEN
            SELECT ref_ret  
              INTO cFolio 
              FROM bdilide:"informix".sl_retlide 
             WHERE num_cte = pNumeroCliente 
               AND aniomes = pFecha
               AND rfc IS NOT NULL;
        ELSE
            LET cFolio = pFecha ||''||pNumeroCliente;
        END IF

        RETURN cCodRet, cRfccontribuyente, cCurpcopntribuyente, cApellpaterno, cApellmaterno, cNombre1, cNombre2, cRazoncontribuyente,
               cRfcinstitucion, cRazoninstitucion, mImpacumulado, mImparecaudar, mImprecaudado, mImppendiente, mImpremanente, mTipocambio, cFolio, cDesSufijo;
    ELSE
        IF LENGTH(TRIM(pFecha)) = 4 THEN
            LET cAuxFecha = TRIM(pFecha) || '13';
        ELSE
            LET cAuxFecha = TRIM(pFecha);
        END IF;
        
        -- // Anual
        SELECT NVL(imp_excedente, 0), NVL(imp_arecaudar, 0), NVL(imp_recaudado, 0), NVL(imp_pendiente, 0)
          INTO mImpacumulado, mImparecaudar, mImprecaudado, mImppendiente
          FROM bdilide:"informix".sl_constancias
         WHERE num_cte = pNumeroCliente
           AND aniomes = cAuxFecha
           AND tipo_cons = 'A'
           AND rfc IS NOT NULL;

        LET cFolio = cAuxFecha ||''||pNumeroCliente;

        RETURN cCodRet, cRfccontribuyente, cCurpcopntribuyente, cApellpaterno, cApellmaterno, cNombre1, cNombre2, cRazoncontribuyente,
               cRfcinstitucion, cRazoninstitucion, mImpacumulado, mImparecaudar, mImprecaudado, mImppendiente, mImpremanente, mTipocambio, cFolio, cDesSufijo;
    END IF;
    
END PROCEDURE
