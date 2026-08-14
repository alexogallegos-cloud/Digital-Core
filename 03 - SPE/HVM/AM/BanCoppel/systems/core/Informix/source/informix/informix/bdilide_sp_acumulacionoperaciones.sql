CREATE PROCEDURE "informix".sp_acumulacionoperaciones( pEmpresa CHAR(3), pFechaProceso DATE, pCve_Usuario CHAR(8), pFechaultimodia DATE)
RETURNING CHAR(4);  -- REGRESO
                    -- "011" Indica que el proceso EOTC aun no se ha ejecutado
                    -- "012" Indica que la fecha que se recibio como parametro de entrada es nula.
                    -- "015" Indica que el parametro de monto ide no existe o el valor es nulo
                    -- "016" Indica que el parametro del porcentaje a recaudar no existe
                    -- "017" Fecha diferente al fin de mes
                    -- "018" Proceso de retencion diaria ya fue ejecutado
    
    ---- *************************************************
    ---  Realizo: Aymme Osuna                        
    ---  Actividad: Realizar el redondeo en el cálculo 
    ---             del IDE a cifras enteras.         
    ---  Solicito:Aymme Osuna                          
    ---  Fecha: 06/NOV/2008                             
    --- **************************************************
    
    -- DEFINICION DE VARIABLES
    DEFINE vcCodRet             CHAR(4);
    DEFINE vcAnioMes2           CHAR(6);
    DEFINE vcNumCte             CHAR(20);
    DEFINE vcRfc                CHAR(13);
    DEFINE vcUserInsert         CHAR(8);
    DEFINE vdFechaInsert        DATE ;
    DEFINE vcProceso            CHAR(10);
    DEFINE vcStatusEODeb        INTEGER;
    DEFINE vcStatusEOCrd        INTEGER;
    DEFINE vcStatus             CHAR(1);
    DEFINE vmImpTot             MONEY(16,2);
    DEFINE vdFechaMov           DATE;
    DEFINE vcTipoCta            CHAR(1);
    DEFINE vmMontLimite         MONEY(16,2);
    DEFINE viPorcaRecau         MONEY(16,2);
    DEFINE vsqlerr              INTEGER;
    DEFINE vdAnioMesAntTemp     DATE;
    DEFINE vcAnioMesAnt	        CHAR(6);
    DEFINE vmImpTotDep          MONEY;
    DEFINE vmImpTotIde          MONEY;
    DEFINE vmImpGrabar          MONEY;
    DEFINE vmMontoRecaudar      MONEY;
    DEFINE vcNumReferencia      CHAR(20);
    DEFINE viFalgRecau          INTEGER;
    DEFINE vdUltimoDiaMes       DATE;

    -- INICIALIZACION DE VARIBLES
    LET vcCodRet         = "000";
    LET vcAnioMes2       = '';
    LET vcNumCte         = '';
    LET vcRfc            = '';
    LET vcUserInsert     = '';
    LET vdFechaInsert    = '';
    LET vcProceso        = '';
    LET vcStatusEODeb    = 0;
    LET vcStatusEOCrd    = 0;
    LET vcStatus         = '';
    LET vmImpTot         = 0.00;
    LET vdFechaMov       = '';
    LET vcTipoCta        = '';
    LET vmMontLimite     = 0.00;
    LET viPorcaRecau     = 0;
    LET vsqlerr          = 0;
    LET vdAnioMesAntTemp = '';
    LET vcAnioMesAnt	 = '';
    LET vmImpTotDep      = 0.00;
    LET vmImpTotIde      = 0.00;
    LET vmImpGrabar      = 0.00;
    LET vmMontoRecaudar  = 0.00;
    LET vcNumReferencia  = "";
    LET viFalgRecau      = 0;
    LET vdUltimoDiaMes   = "";

    BEGIN
    
    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET  vcCodRet  = vsqlerr;
            RETURN vcCodRet;
        END IF;
    END  EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_AMOperacionesEfectivo.out";
    --- TRACE ON;
    
    -- // Validar la fecha que se recibe como parametro de entrada
    IF pFechaProceso IS  NULL OR pFechaProceso = "" THEN
        RETURN  "012" ;
    END IF;
    
    -- // Obtiene la fecha del ultimo dia del mes
    SELECT ult_dia_mes 
      INTO vdUltimoDiaMes 
      FROM bdinteg:si_fechas;
      
    IF pFechaProceso <> vdUltimoDiaMes THEN
        LET vcCodRet = "017";
        RETURN vcCodRet;
    END IF;
    
    -- // Valida que se haya ejecutado el proceso EOTD y EOTC
    SELECT COUNT(*) 
      INTO vcStatusEODeb 
      FROM bdilide:sl_procesos
     WHERE proceso  = "extoptar_d"  
       AND fech_proceso = pFechaProceso;
       
    SELECT COUNT(*) 
      INTO vcStatusEOCrd 
      FROM bdilide:sl_procesos
     WHERE proceso  = "extoptar_c"  
       AND fech_proceso = pFechaProceso;

    IF ( vcStatusEODeb <= 0 OR vcStatusEOCrd <= 0 ) THEN
        LET vcCodRet = "011"; 
        RETURN vcCodRet;
    END IF;
    
    -- // Validar que no hayan hecho las recaudaciones
    SELECT 1 
      INTO viFalgRecau 
      FROM bdilide:sl_procesos 
     WHERE fech_proceso = pFechaProceso 
       AND proceso = "ret_dialde" 
       AND status = "1";
       
    IF viFalgRecau = 1 THEN
        LET  vcCodRet = "018"; -- El proceso de recaudacion diaria ya se ejecuto anteriormente
        RETURN vcCodRet;
    END IF;
    
    LET vcStatus = "";
    
    -- // SE OBTIENE AÑO MES PARA POSTERIORES VALIDACIONES
    LET vcAnioMes2 = SUBSTRING(pFechaProceso from 7 for 10) || SUBSTRING(pFechaProceso from 1 for 2);
    
    -- // SE OBTIENE EL NOMBRE DEL PROCESO DE UNA FECHA DADA
    SELECT proceso, status 
      INTO vcProceso,vcStatus 
      FROM bdilide:sl_procesos
     WHERE fech_proceso = pFechaProceso 
       AND proceso = "acu_men_op";

    IF  vcProceso = "acu_men_op" THEN
        -- // PROCESO SE EJECUTÓ ANTERIORMENTE
        IF vcStatus = '1' THEN
            RETURN "999";
        ELSE
            DELETE FROM bdilide:sl_retlide 
             WHERE aniomes = vcAnioMes2;
        END IF;
    ELSE
        -- // SE INSERTA EL PROCESO DE "Acumulacion Mensual de Operaciones en Efectivo"
        INSERT INTO bdilide:sl_procesos(proceso,fech_proceso,status,user_insert,fecha_insert)
        VALUES ( "acu_men_op", pFechaProceso,'0',pCve_Usuario, CURRENT::DATE);
    END IF;

    -- // TOMANDO PARAMETROS DE IDE LOS CUALES SON: montoLimite y porcentaje de recaudación
    SELECT valor 
      INTO vmMontLimite 
      FROM bdilide:sl_parametros 
     WHERE cve_param ="01";
     
    IF vmMontLimite = 0 OR vmMontLimite IS NULL THEN
        LET vcCodRet = "015";
        RETURN vcCodRet;
    ELSE
        SELECT valor 
          INTO viPorcaRecau 
          FROM bdilide:sl_parametros 
         WHERE cve_param ="02";
         
        IF viPorcaRecau = 0 OR viPorcaRecau IS NULL THEN
            LET vcCodRet = "016";
            RETURN vcCodRet;
        END IF;
    END IF;
    
    -- // Obtiene la acumulación de operaciones en efectivo a nivel cliente
    FOREACH
        SELECT num_cte, SUM(imp_ide), SUM(imp_tot_dep)
          INTO vcNumCte, vmImpTotIde, vmImpTotDep
          FROM  bdilide:sl_movefec 
         WHERE aniomes =vcAnioMes2
         GROUP BY  num_cte

        select rfc  
          into vcRfc 
          from bdinteg:si_cliente
         where numcte = vcNumCte;

        -- // Valida si el importe total de los depositos excede el limite para aplicar IDE
        IF vmImpTotIde  > vmMontLimite THEN
            LET vmImpGrabar  = vmImpTotIde - vmMontLimite;
            LET vmMontoRecaudar = vmImpGrabar * viPorcaRecau;
            LET vmMontoRecaudar = ROUND(vmMontoRecaudar - 0.01); --- Esta linea se agrego para solucionar lo del redondeo

            IF vmMontoRecaudar > 0.00 THEN
                -- // Obtiene el número de la referencia
                LET vcNumReferencia = vcAnioMes2||''||vcNumCte;
                
                -- // Inserta registro en la tabla de retenciones lide
                INSERT INTO bdilide:sl_retlide(aniomes, num_cte, rfc,  ref_ret, imp_acumulado, imp_gravado, imp_arecaudar, pendiente, user_insert, fecha_insert )
                VALUES(vcAnioMes2 , vcNumCte, vcRfc, vcNumReferencia, vmImpTotIde,vmImpGrabar,vmMontoRecaudar, 'T',  pCve_Usuario, CURRENT :: DATE );
                
                -- // Actualiza el numero de referencia
                UPDATE bdilide:sl_movefec 
                   SET ref_ret = vcNumReferencia 
                 WHERE aniomes = vcAnioMes2 
                   AND num_cte = vcNumCte;
            END IF;
        END IF;
    END FOREACH;

    IF vcCodRet = "000" THEN
        -- // SE ACTUALIZA EL CAMPOS status EN 1 PARA INDICAR QUE EL PRCESO SE EJECUTÓ SATISFACTORIAMENTE
        UPDATE bdilide:sl_procesos 
           SET status = '1' 
         WHERE proceso =  "acu_men_op" 
           AND fech_proceso = pFechaProceso;
           
        -- // Controlde Procesos
        INSERT INTO bdinteg:sx_contproc(empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret)
        VALUES(pEmpresa, 'Acoplide', pFechaProceso, '23', 'F', pCve_Usuario, current hour to fraction(3), current hour to fraction(3), vcCodRet);

        RETURN vcCodRet;
    END IF;
    
    END ; 
    
END PROCEDURE;