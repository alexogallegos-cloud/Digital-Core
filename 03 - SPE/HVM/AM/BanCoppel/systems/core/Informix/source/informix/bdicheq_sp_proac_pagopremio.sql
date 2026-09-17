CREATE PROCEDURE "informix".sp_proac_pagopremio()
RETURNING CHAR(5);

    DEFINE vcodret CHAR(5);
	DEFINE vcodret1 CHAR(5);
	DEFINE cCodRet CHAR(5);
    DEFINE vsqlerr INTEGER;
	DEFINE iContador INTEGER;
	DEFINE iContador2 INTEGER;
	DEFINE iSecuencia INTEGER;
    DEFINE cTransaccCargo CHAR(4);
	DEFINE cTransaccPremio CHAR(4);
	DEFINE cSucursal CHAR(4);
	DEFINE cSucursalOriginal CHAR(4);
	DEFINE cCargoEntreCuentas CHAR(4);
	DEFINE cAbonoEntreCuentas CHAR(4);
    DEFINE cCta_Eje CHAR (20);
	DEFINE cCta_PROAC CHAR (20);
	DEFINE cNumCte CHAR (20);
	DEFINE cNumeroFolio CHAR (20);
	DEFINE cNumeroFolio_Cargo CHAR (20);
    DEFINE mSdo_AcuHist MONEY(14,2);
	DEFINE mSdo_AcuDia MONEY(14,2);
	DEFINE mSdo_AcuTotal MONEY(14,2);
	DEFINE mPremPROAC MONEY(14,2);
	DEFINE mMontoNeto MONEY(14,2);
	DEFINE mMontoNeto1 MONEY(14,2);
	DEFINE mMontoNeto2 MONEY(14,2);
	DEFINE cPremioMax MONEY(14,2);
	DEFINE mSaldoEje MONEY(14,2);
    DEFINE dFecha_hoy DATE;
	DEFINE dFecha_Alta DATE;
	DEFINE dFecha_Canc DATE;
	DEFINE dFecha_MesIversario DATE;
	DEFINE dFecha_MesIversario1 DATE;
	DEFINE dFecha_MesIversario2 DATE;
	DEFINE dFecha_Canc_Nueva DATE;
    DEFINE dPorcenPrem2 DECIMAL;
	DEFINE dPorcenPrem1 DECIMAL;
	DEFINE dPorCadaMonto DECIMAL;
    DEFINE dHora DateTime HOUR TO SECOND;
    DEFINE cDescripcion CHAR(50);
    DEFINE cFformat1 CHAR(25);
	DEFINE cFformat2 CHAR(25);
    DEFINE cStatus CHAR(1);
    DEFINE vfechconmovhis DATE;
    DEFINE vfechconmovhisold DATE;
    DEFINE mSdo_AcuTotal1 MONEY(14,2);
	DEFINE mSdo_AcuTotal2 MONEY(14,2);

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET cDescripcion = 'Error Inesperado';
            INSERT INTO bdicheq:"informix".sc_proacprocesos (proceso,status,fecha_ejec,hora_ejec) VALUES ('PAGOPREMIO','0',dFecha_hoy,dHora);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_PROAC_PagoPremio.out";
    --TRACE ON;

    --Inicializar variables
    LET vcodret = "00000";
    LET vcodret1 = "00000";
    LET vsqlerr = 0;
    LET cTransaccCargo = "";
    LET cCta_Eje = "";
    LET mSdo_AcuHist = 0.00;
    LET mSdo_AcuDia  = 0.00;
    LET mSdo_AcuTotal = 0.00;
    LET mSdo_AcuTotal = 0.00;
    LET mMontoNeto = 0.00;
    LET mMontoNeto1 = 0.00;
    LET mMontoNeto2 = 0.00;
    LET dPorcenPrem2 = 0.00;
    LET dPorcenPrem1 = 0.00;
	LET dPorCadaMonto = 0.00;
    LET cPremioMax = 0.00;
    LET iContador = 0;
    LET iSecuencia = 0;
    LET dFecha_hoy = '01/01/1900';
    LET cCta_PROAC = "";
    LET cCodRet = "";
    LET cSucursal = "";
    LET cNumeroFolio = "";
    LET mSaldoEje = 0.00;
    LET cNumeroFolio_Cargo = "";
    Let dHora = CURRENT ;
    LET cSucursalOriginal = "";
    LET cFformat1 = "";
    LET cFformat2 = "";
    LET cStatus = "";
    LET cCargoEntreCuentas = "";
    LET cAbonoEntreCuentas = "";
    LET vfechconmovhis = '';
    LET vfechconmovhisold = '';
    LET mSdo_AcuTotal1 = 0;
    LET mSdo_AcuTotal2 = 0;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --obtiene la fecha hoy
    SELECT Fecha_hoy  
      INTO dFecha_hoy
      FROM bdicheq:"informix".sc_fechas;
      
    --Verifica que no se haya corrido el dia hoy segun el sistema
    IF EXISTS(SELECT 1 
                FROM bdicheq:"informix".sc_proacprocesos 
               WHERE proceso = 'PAGOPREMIO' 
                 AND fecha_ejec = dFecha_hoy ) THEN
        LET vcodret = "00011";
        LET cDescripcion = 'Duplicidad de Procesos';
        RETURN vcodret;
    END IF; 
	
    --Obtiene transaccion de cargo x redondeo
    SELECT valor 
      INTO cTransaccCargo
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'PROACTRANSACCCARGO';

    --Obtiene el premio maximo en PROAC
    SELECT valor 
      INTO cPremioMax
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'PROACMAXPREMIO      ';

    --Obtiene transaccion abono de premio PREMIO
    SELECT valor 
      INTO cTransaccPremio
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'PROACABONOPREMIO';

    --obtengo el % de premio 3er mes
    SELECT valor 
      INTO dPorcenPrem1
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam ='PROACPORCPREM1-3';

    --obtengo el % de premio del 4to al 12vo mese
    SELECT valor 
      INTO dPorcenPrem2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam ='PROACPORCPREM4-12';
	   
	--Obtengo el Por cada N pesos se paga premio                       
	SELECT valor 
	  INTO dPorCadaMonto
	  FROM bdicheq:"informix".sc_param 
	WHERE empresa = '001' 
	  AND codparam ='PROACPORCADAMONTO';
     
    --traspaso entre cuentas  cargo
    SELECT valor 
      INTO cCargoEntreCuentas
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'CARGOENTRECUENTAS';	
     
    --traspaso entre cuentas  abono
    {
	SELECT valor 
      INTO cAbonoEntreCuentas
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'ABONOENTRECUENTAS';
    }
	
	LET cAbonoEntreCuentas = '0280';
	
    SELECT valor
      INTO vfechconmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vfechconmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';

    --Ciclo de busquedas de cuentas inscritas.
    FOREACH	WITH HOLD
        SELECT cta_eje,fecha_alta,fecha_canc,cuenta,num_cte,secuencia,sucursal,prem_proac,status_cta 
          INTO cCta_Eje,dFecha_Alta,dFecha_Canc,cCta_PROAC,cNumCte,iSecuencia,cSucursalOriginal,mPremPROAC,cStatus
          FROM bdicheq:"informix".sc_proac
         WHERE status_cta IN ('1','3')	

        IF cStatus = '3' THEN 
            CONTINUE FOREACH;
        END IF;
        
        -- Obtengo informacion de la cuenta eje
        SELECT sucursal 
          INTO cSucursal
          FROM bdicheq:"informix".sc_maechq 
         WHERE empresa = '001' 
           AND cuenta = cCta_Eje;

        --Verifica si cuantos meses lleva la cuenta eje inscrita en el PROAC	
        FOR iContador = 3 TO 12 
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,iContador) 
            RETURNING vcodret1,dFecha_MesIversario;
            
            IF dFecha_MesIversario = dFecha_hoy THEN
                EXIT FOR;
            END IF;
        END FOR;
        
        --Validamos los movimientos del 1er al 3er mes PROAC
        IF iContador =  3 THEN
            -- Validar si el sdo de premios es el maximo
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,3) 
            RETURNING vcodret1,dFecha_MesIversario;
            
            -- // selecciona la suma de los movimientos por cargo por redondeo.
            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal1
              FROM bdicheq:"informix".sc_movhis  
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_Alta
               AND fech_alt < dFecha_MesIversario
               AND fech_alt >= vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
            
            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal2
              FROM bdicheq:"informix".sc_movhis_old
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_Alta
               AND fech_alt < dFecha_MesIversario
               AND fech_alt >= vfechconmovhisold
               AND fech_alt < vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
               
            LET mSdo_AcuTotal = mSdo_AcuTotal1 + mSdo_AcuTotal2;

            IF mSdo_AcuTotal = 0.00 THEN
                CONTINUE FOREACH;
            END IF;
            
			-- Calculo de redonde por porcentaje
			--LET mMontoNeto1 = ((mSdo_AcuTotal ) * dPorcenPrem1)/100;			
			-- Calculo de redondeo por regla
			LET mMontoNeto1 = ( ROUND ((mSdo_AcuTotal  / dPorCadaMonto) - .5 ) * dPorcenPrem1);

            IF mPremPROAC + mMontoNeto1 >= cPremioMax THEN
                LET mMontoNeto1 = (cPremioMax - mPremPROAC); 
            END IF;

            IF mMontoNeto1 = 0.00 THEN
                CONTINUE FOREACH;
            END IF;

            --Obtengo folio
            CALL bdicheq:"informix".sp_generafolionomina ("informix") RETURNING cCodRet, cNumeroFolio;

            --Abono (proac)
            CALL bdicheq:"informix".abono_ref ('001', cSucursalOriginal, "informix", cTransaccPremio,'0250', cNumeroFolio, cCta_PROAC, 0 ,mMontoNeto1, mMontoNeto1, 0, 0, 0, '01', 'Abono x Redondeo', '0','')
            RETURNING cCodRet;
        
            IF cCodRet = "000" THEN
                Let vcodret = '00000';
                
                SELECT sdo_actual 
                  INTO mMontoNeto2 
                  FROM bdicheq:"informix".sc_maechq  
                 WHERE empresa = '001'
                   AND cuenta = cCta_PROAC;

                UPDATE bdicheq:"informix".sc_proac 
                   SET prem_proac = NVL(prem_proac,0.00) +  mMontoNeto1, saldo = mMontoNeto2 
                 WHERE cuenta = cCta_PROAC 
                   AND secuencia = iSecuencia;
            END IF;
        END IF;
        
        --Validamos los movimientos del 4to al 11vo mes de PROAC
        IF iContador >= 4 AND iContador < 12 THEN
            -- Validar si el sdo de premios es el maximo
            IF mPremPROAC >= cPremioMax THEN
                CONTINUE FOREACH;
            END IF;
            
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,iContador-1) 
            RETURNING vcodret1,dFecha_MesIversario1;
            
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,iContador) 
            RETURNING vcodret1,dFecha_MesIversario2;

            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal1
              FROM bdicheq:"informix".sc_movhis  
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_MesIversario1
               AND fech_alt < dFecha_MesIversario2
               AND fech_alt >= vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
            
            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal2
              FROM bdicheq:"informix".sc_movhis_old  
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_MesIversario1
               AND fech_alt < dFecha_MesIversario2
               AND fech_alt >= vfechconmovhisold
               AND fech_alt < vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
               
            LET mSdo_AcuTotal = mSdo_AcuTotal1 + mSdo_AcuTotal2;

            IF mSdo_AcuTotal = 0.00 THEN
                CONTINUE FOREACH;
            END IF;

            
			-- Calculo de redonde por porcentaje
			-- LET mMontoNeto1 = ((mSdo_AcuTotal)  * dPorcenPrem2)/100;			
			-- Calculo de redondeo por regla
			LET mMontoNeto1 = ( ROUND ((mSdo_AcuTotal  / dPorCadaMonto) - .5 ) * dPorcenPrem2);

            IF mPremPROAC + mMontoNeto1 >= cPremioMax THEN
                LET mMontoNeto1 = (cPremioMax - mPremPROAC); 
            END IF;

            IF mMontoNeto1 = 0.00 THEN
                CONTINUE FOREACH;
            END IF;

            --Obtengo folio
            CALL bdicheq:"informix".sp_generafolionomina ("informix") 
            RETURNING cCodRet, cNumeroFolio;

            --Abono (proac)
            CALL bdicheq:"informix".abono_ref ('001', cSucursalOriginal, "informix", cTransaccPremio,'0250', cNumeroFolio, cCta_PROAC, 0 ,mMontoNeto1, mMontoNeto1, 0, 0, 0, '01', 'Abono x Redondeo', '0','')
            RETURNING cCodRet;
            
            IF cCodRet = "000" THEN
                Let vcodret = '00000';
                
                SELECT sdo_actual 
                  INTO mMontoNeto2 
                  FROM bdicheq:"informix".sc_maechq  
                 WHERE empresa = '001'
                   AND cuenta = cCta_PROAC;

                UPDATE bdicheq:"informix".sc_proac 
                   SET prem_proac = NVL(prem_proac,0.00) +  mMontoNeto1, saldo = mMontoNeto2 
                 WHERE cuenta = cCta_PROAC 
                   AND secuencia = iSecuencia;
            END IF;
        END IF;
        
        LET cDescripcion = 'Proceso Existoso';
        
        --Validamos los movimientos del 12vo mes PROAC
        IF iContador = 12 AND mPremPROAC <= cPremioMax  THEN
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,11) 
            RETURNING vcodret1,dFecha_MesIversario1;
            
            CALL bdinteg:"informix".sp_CorteSig(dFecha_Alta,12) 
            RETURNING vcodret1,dFecha_MesIversario2;

            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal1
              FROM bdicheq:"informix".sc_movhis  
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_MesIversario1
               AND fech_alt < dFecha_MesIversario2
               AND fech_alt >= vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
            
            SELECT NVL(SUM (monto_tot),0.00) 
              INTO mSdo_AcuTotal2
              FROM bdicheq:"informix".sc_movhis_old
             WHERE empresa = '001'
               AND cuenta = cCta_Eje		
               AND fech_alt >= dFecha_MesIversario1
               AND fech_alt < dFecha_MesIversario2
               AND fech_alt >= vfechconmovhisold
               AND fech_alt < vfechconmovhis
               AND cancelad <> 'S'
               AND transacc = cTransaccCargo;
               
            LET mSdo_AcuTotal = mSdo_AcuTotal1 + mSdo_AcuTotal2;

            IF mSdo_AcuTotal > 0.00 THEN	
                LET mSdo_AcuTotal = mSdo_AcuTotal;
                -- LET mMontoNeto1 = ((mSdo_AcuTotal ) * dPorcenPrem2)/100;
				-- Calculo de redondeo por regla
				LET mMontoNeto1 = ( ROUND ((mSdo_AcuTotal  / dPorCadaMonto) - .5 ) * dPorcenPrem2);

                IF mPremPROAC + mMontoNeto1 >= cPremioMax THEN
                    LET mMontoNeto1 = (cPremioMax - mPremPROAC); 
                END IF;

                IF mMontoNeto1 > 0.00 THEN
                    --Obtengo folio
                    CALL bdicheq:"informix".sp_generafolionomina ("informix") 
                    RETURNING cCodRet, cNumeroFolio;

                    --Abono (proac)
                    CALL bdicheq:"informix".abono_ref ('001', cSucursalOriginal, "informix", cTransaccPremio,'0250', cNumeroFolio, cCta_PROAC, 0 ,mMontoNeto1, mMontoNeto1, 0, 0, 0, '01', 'Abono x Premio', '0','')
                    RETURNING cCodRet;
                    
                    IF cCodRet = "000" THEN
                        Let vcodret = '00000';
                        
                        SELECT sdo_actual 
                          INTO mMontoNeto2 
                          FROM bdicheq:"informix".sc_maechq  
                         WHERE empresa = '001'
                           AND cuenta = cCta_PROAC;

                        UPDATE bdicheq:"informix".sc_proac 
                           SET prem_proac = NVL(prem_proac,0.00) +  mMontoNeto1, saldo = mMontoNeto2 
                         WHERE cuenta = cCta_PROAC 
                           AND secuencia = iSecuencia;
                    END IF;
                END IF;
            END IF;
        END IF;
        
        --Validamos si la cuenta cumplio  aniversario (Si es el caso esta se reinscribe automaticamente generando un nuevo registro en la sc_proac y limpiando el saldo de la cuenta proac en el maestro de cheques)
        IF dFecha_hoy >= dFecha_Canc THEN
            Let vcodret = '00000';

            SELECT sdo_actual 
              INTO mMontoNeto
              FROM bdicheq:"informix".sc_maechq
             WHERE empresa = '001' 
               AND cuenta = cCta_PROAC;
               
            LET cCodRet = '000';

            IF mMontoNeto > 0.00 THEN
                --Obtengo folio
                CALL bdicheq:"informix".sp_generafolionomina ("informix") 
                RETURNING cCodRet, cNumeroFolio_Cargo;

                --Cargo (eje)
                CALL bdicheq:"informix".cargo_ref('001', cSucursalOriginal, "informix", cCargoEntreCuentas, '0000', cNumeroFolio_Cargo, cCta_PROAC, 0, mMontoNeto, '01', 'Cargo x Traspaso ', '','')
                RETURNING cCodRet,cCargoEntreCuentas,dFecha_hoy,mSaldoEje,mMontoNeto ;

                IF cCodRet  = '000'  THEN
                    --Obtengo folio
                    CALL bdicheq:"informix".sp_generafolionomina ("informix") 
                    RETURNING cCodRet, cNumeroFolio;

                    --Abono (proac)
                    CALL bdicheq:"informix".abono_ref ('001', cSucursalOriginal, "informix", cAbonoEntreCuentas,'0250', cNumeroFolio, cCta_Eje, 0 ,mMontoNeto, mMontoNeto, 0, 0, 0, '01', 'Abono x Traspaso', '0','')
                    RETURNING cCodRet;
                END IF;
            END IF;		

			IF cCodRet  <> '000'  THEN
                --Reversion al cargo sp reverso();
                CALL bdicheq:"informix".reversion ('001', cSucursalOriginal, "informix",cNumeroFolio_Cargo, "C") 
                RETURNING cCodRet;
                
                LET vcodret = cCodret;
                CONTINUE FOREACH;
            ELSE
			   CALL bdicheq:"informix".sp_PROAC_Calc_ProximoAnio(dFecha_hoy) 
                    RETURNING cCodRet,dFecha_Canc_Nueva,cFformat1,cFformat2;
                
               UPDATE bdicheq:"informix".sc_proac 
                  SET status_cta = '4' 
                WHERE cuenta = cCta_PROAC 
                  AND secuencia = iSecuencia;

                INSERT INTO bdicheq:"informix".sc_proac (cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac)
                VALUES (cCta_PROAC,cNumCte,cCta_Eje,iSecuencia+1,'1',dFecha_hoy,dFecha_Canc_Nueva,cSucursalOriginal,0.00,0.00); 
                
                LET cDescripcion = 'Reinscripcion Automatica Exitosa';
            END IF
        END IF;
    END FOREACH
    
    INSERT INTO bdicheq:"informix".sc_proacprocesos (proceso,status,fecha_ejec,hora_ejec) 
    VALUES ('PAGOPREMIO','1',dFecha_hoy,dHora);

    RETURN vcodret;
    END
END PROCEDURE
DOCUMENT
'AUTOR       : Jesus Antonio Bastidas Lopez',
'DESCRIPCION : Calcular los premios de los clientes PROAC y realizar su Abono en la Cuenta Accesoria',
'              de el monto redondeado y el premio por dichos montos segun el estandar del programa.',
'FECHA       : Febrero de 2009',
'VERSION     : 200902',
'BD          : BDICHEQ',
'AUTOR CAMBIO: Jesus Armando Mercado Figueroa',
'DESCRIPCION : Se cambio la forma de calculo del premio, ahora es por cada N (PROACPORCADAMONTO) cantidad se paga  ',
'              X (PROACPORCPREM1-3 o PROACPORCPREM4-12) cantidad de pesos                                          ',
'FECHA       : Febrero de 2012',
'VERSION     : 201202',
'BD          : BDICHEQ',
'AUTOR CAMBIO: Jose Angel Gaxiola Gaxiola',
'DESCRIPCION : Se cambio calculo de redondeo por regla de los premios, considerando del primer al tercer mes, ',
'              del cuarto al onceavo y del doceavo mes Proac.',
'FECHA       : Marzo de 2012',
'VERSION     : 201203',
'BD          : BDICHEQ';

CREATE PROCEDURE "informix".sp_obtprimerdeposito()
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80)	AS desc_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	
	DEFINE cCodRetMesSig	CHAR(5);
	DEFINE iDiasTransc		INTEGER;

	DEFINE cAnioMesActual	CHAR(6);
	DEFINE cAnioMesSig		CHAR(6);
	DEFINE cProducto		CHAR(4);
	DEFINE cCuenta			CHAR(20);
	DEFINE dtFechaAlta		DATE;
	DEFINE cSucursal		CHAR(4);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFecPrimerDep	DATE;
	DEFINE dtMontoPrimerDep	MONEY;
	DEFINE dFechaHoy		DATE;
	DEFINE iNumSerie		INT8;
	DEFINE cEmpresa			CHAR(3);



	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cAnioMesActual		= "";
	LET cAnioMesSig			= "";
	LET cProducto			= "";
	LET cCuenta				= "";
	LET dtFechaAlta			= DATE(1);
	LET cSucursal			= "";
	LET dtMesiversario		= DATE(1);
	LET dtFecPrimerDep		= NULL;
	LET dtMontoPrimerDep	= NULL;
	LET dFechaHoy			= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET iNumSerie			= 0;
	LET cEmpresa			= "";
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_obtprimerdeposito.out';
	--TRACE ON;

	
	FOREACH WITH HOLD
		SELECT cuenta
		INTO cCuenta
		FROM "informix".sc_indicadores
		WHERE cuenta >= '10000005016'
		AND fecha_apertura >= "07/08/2014"
		ORDER BY cuenta
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF	
		
		LET dtFecPrimerDep = NULL;
		LET dtMontoPrimerDep = NULL;
		
		FOREACH WITH HOLD
			SELECT FIRST 1 mov.fech_alt, mov.monto_tot
			  INTO dtFecPrimerDep, dtMontoPrimerDep
			  FROM "informix".sc_movhis mov,   
				   bdinteg:si_transacc trx
			 WHERE mov.empresa = trx.empresa
			   AND mov.cuenta = cCuenta
			   AND mov.fech_alt >= "07/08/2014"
			   AND mov.cancelad <> 'S'   
			   AND mov.transacc = trx.numero
			   AND trx.naturaleza = 'A'  
			   AND trx.se_emite_edocta = 'S'
			 ORDER BY mov.num_serial
			 
			 EXIT FOREACH;
		END FOREACH
		

		UPDATE "informix".sc_indicadores
		SET fec_prim_deposito_orig = dtFecPrimerDep, imp_prim_deposito_orig = dtMontoPrimerDep
		WHERE anio_mes = "201407" 
		AND cuenta = cCuenta;
		
		LET vcontador3 = vcontador3 + 1;
		LET cEmpresa = "";
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
	END FOREACH	

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para los primeros depositos mas recientes',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Abril 2014';

CREATE PROCEDURE "informix".sp_obtienetarjetasentregadas(pFechaHoy DATE)
--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret					CHAR(5);
DEFINE iSqlErr, iIsamErr 		INTEGER;
DEFINE cNombreArchivo			CHAR(50);
DEFINE cSql						CHAR(3000);
DEFINE cRuta					CHAR(50);
DEFINE cEncabezado				CHAR(2000);
DEFINE cEmpresa 				CHAR(3);
DEFINE iDias					INTEGER;
DEFINE iDia						INTEGER;
DEFINE iMes						INTEGER;
DEFINE cMes						CHAR(2);
DEFINE cNomMes 					CHAR(20);
DEFINE iAnio					INTEGER;
DEFINE iBiciesto				INTEGER;
DEFINE dFechaIni				DATE;
DEFINE dFechaFin				DATE;
DEFINE dtFechaIni				DATETIME YEAR TO SECOND;
DEFINE dtFechaFin				DATETIME YEAR TO SECOND;
DEFINE dFechaArchivo			DATE;
DEFINE dFecIniAcumulado			DATE;
DEFINE cSucursal				CHAR(4);
DEFINE cClaveSuc				CHAR(5);
DEFINE cProducto				CHAR(4);
DEFINE cNombreProd				CHAR(40);
DEFINE cNumTarjeta				CHAR(20);
DEFINE dFechaAsignacion			DATE;
DEFINE cTipoTarjeta				CHAR(1);
DEFINE cTipoAsignacion			CHAR(1);
DEFINE cCobroComision			CHAR(1);
DEFINE cCuenta					CHAR(20);
DEFINE iTarjetasEntregadas 		INTEGER;
DEFINE iTarjSuceptibleCobro		INTEGER;
DEFINE iTarjetasCobradas 		INTEGER;
DEFINE iTarjCondonadasGte 		INTEGER;
DEFINE mMtoTotalSuceptibleCobro DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradas 	DECIMAL(14,2);
DEFINE dcCostoPromedioComision 	DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobro DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGte 	DECIMAL(14,2);
DEFINE iTarjetasEntregadasMes	INTEGER;
DEFINE iTarjSuceptibleCobroMes	INTEGER;
DEFINE iTarjetasCobradasMes		INTEGER;
DEFINE iTarjCondonadasGteMes	INTEGER;
DEFINE mMtoTotalSuceptibleCobroMes DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasMes	DECIMAL(14,2);
DEFINE dcCostoPromedioComisionMes DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroMes DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteMes DECIMAL(14,2);
DEFINE iTarjetasEntregadasAcum	INTEGER;
DEFINE iTarjSuceptibleCobroAcum	INTEGER;
DEFINE iTarjetasCobradasAcum	INTEGER;
DEFINE iTarjCondonadasGteAcum	INTEGER;
DEFINE mMtoTotalSuceptibleCobroAcum DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasAcum DECIMAL(14,2);
DEFINE dcCostoPromedioComisionAcum DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroAcum DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteAcum DECIMAL(14,2);
DEFINE cIva						CHAR(100);
DEFINE mMontoTot				MONEY(14,2);
DEFINE mMtoTot					MONEY(14,2);
DEFINE mMontoCom				MONEY(14,2);
DEFINE cEstadoCom				CHAR(1);
DEFINE iCobrada 				INTEGER;
DEFINE cEtiqueta 				CHAR(40);
DEFINE iBanRegs					INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodret					= '00000';
LET iSqlErr 				= 0;
LET iIsamErr 				= 0;
LET cNombreArchivo			= '';
LET cSql					= '';
LET cRuta					= '';
LET cEncabezado				= '';
LET cEmpresa 				= '001';
LET iDias					= 0;
LET iDia					= 0;
LET iMes					= 0;
LET cMes					= '';
LET cNomMes 				= '';
LET iAnio					= 0;
LET iBiciesto				= 0;
LET dFechaIni				= '';
LET dFechaFin				= '';
LET dtFechaIni				= '';
LET dtFechaFin				= '';
LET dFechaArchivo			= '';
LET dFecIniAcumulado 		= '';
LET cSucursal				= '';
LET cClaveSuc				= '';
LET cProducto				= '';
LET cNombreProd				= '';
LET cNumTarjeta				= '';
LET dFechaAsignacion		= '';
LET cTipoTarjeta			= '';
LET cTipoAsignacion			= '';
LET cCobroComision			= '';
LET cCuenta					= '';
LET iTarjetasEntregadas 	= 0;
LET iTarjSuceptibleCobro 	= 0;
LET iTarjetasCobradas 		= 0;
LET iTarjCondonadasGte 		= 0;
LET mMtoTotalSuceptibleCobro = 0;
LET mMtoTotalTarjCobradas 	= 0;
LET dcCostoPromedioComision = 0;
LET dcPorcTarjSuceptibleCobro = 0;
LET dcPorcTarjCondonadasGte = 0;
LET iTarjetasEntregadasMes	= 0;
LET iTarjSuceptibleCobroMes	= 0;
LET iTarjetasCobradasMes	= 0;
LET iTarjCondonadasGteMes	= 0;
LET mMtoTotalSuceptibleCobroMes = 0;
LET mMtoTotalTarjCobradasMes = 0;
LET dcCostoPromedioComisionMes = 0;
LET dcPorcTarjSuceptibleCobroMes = 0;
LET dcPorcTarjCondonadasGteMes = 0;
LET iTarjetasEntregadasAcum	= 0;
LET iTarjSuceptibleCobroAcum = 0;
LET iTarjetasCobradasAcum 	= 0;
LET iTarjCondonadasGteAcum	= 0;
LET mMtoTotalSuceptibleCobroAcum = 0;
LET mMtoTotalTarjCobradasAcum = 0;
LET dcCostoPromedioComisionAcum = 0;
LET dcPorcTarjSuceptibleCobroAcum = 0;
LET dcPorcTarjCondonadasGteAcum = 0;
LET cIva					= 0;
LET mMontoTot				= 0;
LET mMtoTot					= 0;
LET mMontoCom				= 0;
LET cEstadoCom 				= '';
LET iCobrada 				= 0;
LET cEtiqueta 				= 0;
LET iBanRegs				= 0;

--SET DEBUG FILE TO "/informix/IrisA/sp_obtienetarjetasentregadas.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	IF NVL(pFechaHoy,'') <> '' THEN
		LET iDia = DAY(pFechaHoy);
		LET iMes = MONTH(pFechaHoy);
		LET iAnio = YEAR(pFechaHoy);

		IF iMes = 1 THEN
			LET iMes = 12;
			LET iAnio = iAnio -1;
		ELSE
			LET iMes = iMes -1; 
		END IF;

		LET cMes = LPAD(iMes,2,'0');
		LET iBiciesto= MOD(iAnio,4);

		IF iMes = 1 OR iMes = 3 OR iMes = 5 OR iMes = 7 OR iMes = 8 OR iMes = 10 OR iMes = 12 THEN
			LET iDias = 31;
		ELIF iMes = 2 THEN  
			LET iDias = 28;
			IF iBiciesto = 0 THEN 
				LET iDias = iDias + 1;
			END IF;
		ELIF iMes = 4 OR iMes = 6 OR iMes = 9 OR iMes = 11 THEN
			LET iDias = 30;
		END IF;

		IF iMes = 1  THEN LET cNomMes = 'ENERO';      END IF;
		IF iMes = 2  THEN LET cNomMes = 'FEBRERO';    END IF;
		IF iMes = 3  THEN LET cNomMes = 'MARZO';      END IF;
		IF iMes = 4  THEN LET cNomMes = 'ABRIL';      END IF;
		IF iMes = 5  THEN LET cNomMes = 'MAYO';       END IF;
		IF iMes = 6  THEN LET cNomMes = 'JUNIO';      END IF;
		IF iMes = 7  THEN LET cNomMes = 'JULIO';      END IF;
		IF iMes = 8  THEN LET cNomMes = 'AGOSTO';     END IF;
		IF iMes = 9  THEN LET cNomMes = 'SEPTIEMBRE'; END IF;
		IF iMes = 10 THEN LET cNomMes = 'OCTUBRE';    END IF;
		IF iMes = 11 THEN LET cNomMes = 'NOVIEMBRE';  END IF;
		IF iMes = 12 THEN LET cNomMes = 'DICIEMBRE';  END IF;

		LET cNombreArchivo = "cuentasefectivasabiertas" || LPAD(iDia,2,'0') || cMes || iAnio;

		SELECT valor INTO cRuta FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = 141;

		LET dFechaIni = cMes || '/01/' || TO_CHAR(iAnio);
		LET dFechaFin = cMes || '/' || TO_CHAR(iDias) || '/' || TO_CHAR(iAnio);
		LET dFechaArchivo = cMes || '/' || '02' || '/' || iAnio;
		LET dFecIniAcumulado = '01/01/' || TO_CHAR(iAnio);

		LET dtFechaIni = dFechaIni::DATETIME YEAR TO SECOND;
		LET dtFechaFin = (dFechaFin + 1 UNITS DAY)::DATETIME YEAR TO SECOND;

		IF NVL(cRuta,'') <> '' THEN
			LET cEncabezado = "PRODUCTO|ENTREGADAS|SUCEPTIBLES DE COBRO|$|COBRADAS|$|COSTO PROMEDIO COMISION|%|CONDONADAS POR GERENTE|%";

			LET cSql = 'echo "' || TRIM(cEncabezado) || '" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
			SYSTEM cSql;

			SELECT valor INTO cIva FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = 47;

			--FOREACH
				--SUCURSAL
				--SELECT sucursal INTO cSucursal 
				--FROM bdinteg:"informix".si_sucursales 
				--WHERE empresa = cEmpresa AND tpo_sucursal = 'S'
				--ORDER BY sucursal

				--LET cClaveSuc = '0' || cSucursal;

				FOREACH 
					--PRODUCTO
					SELECT producto INTO cProducto
					FROM "informix".sc_producto 
					WHERE empresa = cEmpresa AND producto IN('1500','1900','2000','2500')
					ORDER BY producto

					FOREACH 
						SELECT tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision
						INTO cNumTarjeta, dFechaAsignacion, cCuenta, cTipoTarjeta, cTipoAsignacion, cCobroComision
						FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq--, intercard:"informix".lote lote
						WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
						AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin 
							FROM intercard:"informix".tipotarjeta WHERE chip = 'V')
						AND tarj.numtarjeta = cheq.num_tarjeta AND cheq.prodtarjeta = cProducto
						--AND tarj.numerolote = lote.numerolote AND lote.clave_sucursal = cClaveSuc

						IF NVL(cNumTarjeta,'') <> '' THEN
							LET iBanRegs = 1;

							IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN
								--TARJETAS ENTREGADAS
								LET iTarjetasEntregadas = iTarjetasEntregadas + 1;

								IF NVL(cCobroComision,'') = 'S' THEN
									--TARJETAS SUCEPTIBLES DE COBRO
									LET iTarjSuceptibleCobro = iTarjSuceptibleCobro + 1;

									IF NVL(cTipoAsignacion,'') = 'N' THEN
										SELECT FIRST 1 monto_com, estado_com INTO mMontoTot, cEstadoCom
										FROM "informix".sc_detcomis
										WHERE empresa = cEmpresa AND cuenta = cCuenta 
										AND comision = '3260' AND fecha_alta = dFechaAsignacion;
									ELIF NVL(cTipoAsignacion,'') = 'R' THEN
										SELECT FIRST 1 monto_com, estado_com INTO mMontoTot, cEstadoCom
										FROM "informix".sc_detcomis
										WHERE empresa = cEmpresa AND cuenta = cCuenta 
										AND comision = '3261' AND fecha_alta = dFechaAsignacion;
									END IF;

									IF NVL(mMontoTot,0) <> 0 AND NVL(cEstadoCom,'') = 'A' THEN
										LET iTarjetasCobradas = iTarjetasCobradas + 1;
										LET iCobrada = 1;
									END IF;

									IF NVL(mMontoTot,0) = 0 THEN
										IF NVL(cTipoAsignacion,'') = 'N' THEN
											SELECT SUM(monto_tot) INTO mMtoTot
											FROM "informix".sc_movhis 
											WHERE empresa = cEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362') 
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										ELIF NVL(cTipoAsignacion,'') = 'R' THEN
											SELECT SUM(monto_tot) INTO mMtoTot
											FROM "informix".sc_movhis 
											WHERE empresa = cEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363') 
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										END IF;

										IF NVL(mMtoTot,0) <> 0 THEN
											LET iTarjetasCobradas = iTarjetasCobradas + 1;
											LET iCobrada = 1;
										END IF;
									ELSE
										LET mMontoCom = TRUNC((NVL(mMontoTot,0) * cIVA),2);
										LET mMtoTot = NVL(mMontoTot,0) + NVL(mMontoCom,0);
										LET mMontoTot = 0;
										LET mMontoCom = 0;
									END IF;

									IF iCobrada = 1 THEN
										--MONTO TOTAL DE TARJETAS COBRADAS
										LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
									END IF;

									--MONTO TOTAL DE TARJETAS SUCEPTIBRES DE COBRO
									LET mMtoTotalSuceptibleCobro = mMtoTotalSuceptibleCobro + NVL(mMtoTot,0);
									LET mMtoTot = 0;
									LET iCobrada = 0;
									
								ELIF NVL(cCobroComision,'') = 'N' THEN
									--TARJETAS CONDONADAS POR GERENTE
									LET iTarjCondonadasGte = iTarjCondonadasGte + 1;
								END IF;
							END IF;
						END IF;
					END FOREACH;

					IF NVL(iTarjSuceptibleCobro,0) > 0 THEN
						--COSTO PROMEDIO COMISION
						LET dcCostoPromedioComision = NVL(mMtoTotalSuceptibleCobro,0) / iTarjSuceptibleCobro;
					END IF;

					IF NVL(iTarjetasEntregadas,0) > 0 THEN
						--PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO
						LET dcPorcTarjSuceptibleCobro = (NVL(iTarjSuceptibleCobro,0) * 100) / iTarjetasEntregadas;

						--PORCENTAJE TARJETAS CONDONADAS POR GERENTE
						LET dcPorcTarjCondonadasGte = (NVL(iTarjCondonadasGte,0) * 100) / iTarjetasEntregadas;
					END IF;

					IF iBanRegs = 1 OR iTarjetasEntregadas <> 0 THEN
						INSERT INTO "informix".sc_acumuladostddentregadas(sucursal,producto,tarjetasentregadas,tarjsuceptiblecobro,mtototalsuceptiblecobro,
							tarjetascobradas,mtototaltarjcobradas,costopromediocomision,porctarjsuceptiblecobro,tarjcondonadasgte,porctarjcondonadasgte,
							fechainsert)
						VALUES(TRIM(cSucursal),TRIM(cProducto),iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,
							iTarjetasCobradas,mMtoTotalTarjCobradas,dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte,
							dFechaArchivo);

						LET iBanRegs = 0;
					END IF;

					LET iTarjetasEntregadas 	= 0;
					LET iTarjSuceptibleCobro 	= 0;
					LET mMtoTotalSuceptibleCobro = 0;
					LET iTarjetasCobradas 		= 0;
					LET mMtoTotalTarjCobradas 	= 0;
					LET dcCostoPromedioComision = 0;
					LET dcPorcTarjSuceptibleCobro = 0;
					LET iTarjCondonadasGte 		= 0;
					LET dcPorcTarjCondonadasGte = 0;
				END FOREACH;
			--END FOREACH;
			
			FOREACH 
				--RENGLON DEL DETALLE POR PRODUCTO
				SELECT TRIM(producto), TRIM(nombre) INTO cProducto, cNombreProd
				FROM "informix".sc_producto 
				WHERE empresa = cEmpresa AND producto IN('1500','1900','2000','2500')
				ORDER BY producto

				SELECT SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),
					SUM(costopromediocomision),SUM(porctarjsuceptiblecobro),SUM(tarjcondonadasgte),SUM(porctarjcondonadasgte)
				INTO iTarjetasEntregadas,iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,iTarjetasCobradas,mMtoTotalTarjCobradas,
					dcCostoPromedioComision,dcPorcTarjSuceptibleCobro,iTarjCondonadasGte,dcPorcTarjCondonadasGte
				FROM "informix".sc_acumuladostddentregadas
				WHERE producto = cProducto AND fechainsert = dFechaArchivo;

				LET cSql = 'echo "' || TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjSuceptibleCobro,0) || '|' || NVL(mMtoTotalSuceptibleCobro,0) || '|' || NVL(iTarjetasCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(dcCostoPromedioComision,0) || '|' || NVL(dcPorcTarjSuceptibleCobro,0) || '|' || NVL(iTarjCondonadasGte,0) || '|' || NVL(dcPorcTarjCondonadasGte,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
				SYSTEM cSql;

				-- RENGLON DEL DETALLE POR MES
				LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;
				LET iTarjSuceptibleCobroMes = iTarjSuceptibleCobroMes + iTarjSuceptibleCobro;
				LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
				LET iTarjCondonadasGteMes = iTarjCondonadasGteMes + iTarjCondonadasGte;
				LET mMtoTotalSuceptibleCobroMes = mMtoTotalSuceptibleCobroMes + mMtoTotalSuceptibleCobro;
				LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;

				LET iTarjetasEntregadas 	= 0;
				LET iTarjSuceptibleCobro 	= 0;
				LET mMtoTotalSuceptibleCobro = 0;
				LET iTarjetasCobradas 		= 0;
				LET mMtoTotalTarjCobradas 	= 0;
				LET dcCostoPromedioComision = 0;
				LET dcPorcTarjSuceptibleCobro = 0;
				LET iTarjCondonadasGte 		= 0;
				LET dcPorcTarjCondonadasGte = 0;
			END FOREACH;

			IF NVL(iTarjSuceptibleCobroMes,0) > 0 THEN
				--COSTO PROMEDIO COMISION POR MES
				LET dcCostoPromedioComisionMes = NVL(mMtoTotalSuceptibleCobroMes,0) / iTarjSuceptibleCobroMes;
			END IF;

			IF NVL(iTarjetasEntregadasMes,0) > 0 THEN
				--PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO POR MES
				LET dcPorcTarjSuceptibleCobroMes = (NVL(iTarjSuceptibleCobroMes,0) * 100) / iTarjetasEntregadasMes;

				--PORCENTAJE TARJETAS CONDONADAS POR GERENTE POR MES
				LET dcPorcTarjCondonadasGteMes = (NVL(iTarjCondonadasGteMes,0) * 100) / iTarjetasEntregadasMes;
			END IF;

			LET cSql = '';
			LET cEtiqueta = 'TOTAL MES ' || cNomMes;
			LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasMes,0) || '|' || NVL(iTarjSuceptibleCobroMes,0) || '|' || NVL(mMtoTotalSuceptibleCobroMes,0) || '|' || NVL(iTarjetasCobradasMes,0) || '|' || NVL(mMtoTotalTarjCobradasMes,0) || '|' || NVL(dcCostoPromedioComisionMes,0) || '|' || NVL(dcPorcTarjSuceptibleCobroMes,0) || '|' || NVL(iTarjCondonadasGteMes,0) || '|' || NVL(dcPorcTarjCondonadasGteMes,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
			SYSTEM cSql;

			-- FILA DEL DETALLE DEL ACUMULADO DEL AÑO
			SELECT SUM(tarjetasentregadas),SUM(tarjsuceptiblecobro),SUM(mtototalsuceptiblecobro),SUM(tarjetascobradas),SUM(mtototaltarjcobradas),SUM(tarjcondonadasgte)
			INTO iTarjetasEntregadasAcum,iTarjSuceptibleCobroAcum,mMtoTotalSuceptibleCobroAcum,iTarjetasCobradasAcum,mMtoTotalTarjCobradasAcum,iTarjCondonadasGteAcum
			FROM "informix".sc_acumuladostddentregadas
			WHERE fechainsert >= dFecIniAcumulado AND fechainsert <= dFechaArchivo;

			IF NVL(iTarjSuceptibleCobroAcum,0) > 0 THEN
				--COSTO PROMEDIO COMISION DEL ACUMULADO DEL AÑO
				LET dcCostoPromedioComisionAcum = NVL(mMtoTotalSuceptibleCobroAcum,0) / iTarjSuceptibleCobroAcum;
			END IF;

			IF NVL(iTarjetasEntregadasAcum,0) > 0 THEN
				--PORCENTAJE TARJETAS SUCEPTIBLES DE COBRO DEL ACUMULADO DEL AÑO
				LET dcPorcTarjSuceptibleCobroAcum = (NVL(iTarjSuceptibleCobroAcum,0) * 100) / iTarjetasEntregadasAcum;

				--PORCENTAJE TARJETAS CONDONADAS POR GERENTE DEL ACUMULADO DEL AÑO
				LET dcPorcTarjCondonadasGteAcum = (NVL(iTarjCondonadasGteAcum,0) * 100) / iTarjetasEntregadasAcum;
			END IF;

			LET cSql = '';
			LET cEtiqueta = 'ACUMULADO ' || TO_CHAR(iAnio);
			LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasAcum,0) || '|' || NVL(iTarjSuceptibleCobroAcum,0) || '|' || NVL(mMtoTotalSuceptibleCobroAcum,0) || '|' || NVL(iTarjetasCobradasAcum,0) || '|' || NVL(mMtoTotalTarjCobradasAcum,0) || '|' || NVL(dcCostoPromedioComisionAcum,0) || '|' || NVL(dcPorcTarjSuceptibleCobroAcum,0) || '|' || NVL(iTarjCondonadasGteAcum,0) || '|' || NVL(dcPorcTarjCondonadasGteAcum,0) ||'" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
			SYSTEM cSql;
		ELSE
			LET cCodret = "00002"; --Ruta sin Definir
		END IF;
	ELSE
		LET cCodret = "00001"; --Fecha Vacia
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;