CREATE PROCEDURE "informix".sp_idegeneraconstanciaanual( pFecha DATE, pUsuario CHAR(8))

    -- DATOS A REGRESAR
	RETURNING
    CHAR(5);  -- Codigo de Retorno

    -- DEFINICION DE VARIABLES
    DEFINE vCodRet CHAR(5);
    DEFINE vNumcliente CHAR(20);
    DEFINE vRfc CHAR(13);
    DEFINE vSumImpGrabado MONEY(16,2);
    DEFINE vSumImparecaudar MONEY(16,2);
    DEFINE vSumImprecaudado MONEY(16,2);
    DEFINE vSumImppendiente MONEY(16,2);
    DEFINE vSumImpanterior  MONEY(16,2);
    DEFINE vTipocambio   MONEY(16,2);
    DEFINE vAniomes CHAR(6);
    DEFINE vAnio CHAR(4);
    DEFINE vcAnioActual CHAR(4);
    DEFINE vMesActual CHAR(2);
    DEFINE vcMes CHAR(2);
    DEFINE vcDia CHAR(2);
    DEFINE vcDiaActual CHAR(2);
    DEFINE vProceso CHAR(10);
    DEFINE vsqlerr INTEGER;
    DEFINE vdAnioPasado DATE;
    DEFINE vcStatus CHAR(1);
    DEFINE vcAnioAnterior INT;
    DEFINE vdFecha  char(10);
    DEFINE vdFechaActual  DATE;
    DEFINE viFechaRecibida INT;
    DEFINE viFechaInicio INT;
    DEFINE viFechaFin INT;
    DEFINE vcMesActual CHAR(2);
    DEFINE vcTransaccionalidad CHAR(1);

	--INICIALIZACION DE VARIABLES--
    LET vCodRet = '00000';
    LET vNumcliente = "";
    LET vRfc = "";
    LET vSumImpGrabado   = 0;
    LET vSumImparecaudar = 0;
    LET vSumImprecaudado = 0;
    LET vSumImppendiente = 0;
    LET vSumImpanterior = 0;
    LET vTipocambio = 0;
    LET vAniomes = "";
    LET vAnio = "";
    LET vsqlerr = 0;
    LET vcStatus = '';
    LET vcAnioAnterior = '';
    LET viFechaRecibida = 0;
    LET viFechaInicio = 0;
    LET viFechaFin = 0;
    LET vcTransaccionalidad = 'N';

  --  LET viFecha2 = 0;
     BEGIN

        ON EXCEPTION  SET vsqlerr
                IF vsqlerr <> 0  THEN

                    IF vcTransaccionalidad = 'S' THEN
                        ROLLBACK WORK;
                       -- let vCodRet = '?';   ROLLBACK WORK; RETURN vCodRet || '!!!!';
                    END IF;
                     LET  vCodRet  = vsqlerr;
                    RETURN vCodRet;
                END IF;

  
         END  EXCEPTION;


        --SET DEBUG FILE TO "/tmp/sp_idegeneraconstancianual.out";
        --TRACE ON;

        -- SE TOMA EL ANO Y MES CON BASE EN LA FECHA DE PARÁMETRO   
     

        LET vAnio            =    year( pFecha);
        LET vcDia            = LPAD(day( pFecha),2,0);
        LET vcMes            = LPAD(month( pFecha ),2,0);
        LET viFechaRecibida = (vAnio || vcMes || vcDia)::INT;

        SELECT fecha_hoy INTO vdFechaActual FROM bdinteg:si_fechas;


        let vcAnioActual = year(vdFechaActual );
        let vcMesActual = LPAD(month( vdFechaActual ),2,0);
        let vcDiaActual = LPAD(day( vdFechaActual),2,0);

        
        LET vcAnioAnterior   = vcAnioActual -1;
        LET viFechaInicio   = ((vcAnioActual || '0101')::INT);
        LET viFechaFin      = ((vcAnioActual || '0210')::INT);

        LET vAniomes         = vcAnioAnterior || '13';


   set isolation to dirty read;

   IF (vcMesActual = '01') or (vcMesActual = '02' and vcDiaActual <= '10') THEN


        -- se valida si es el mes de enero o dia primero de febero pero del año actual. 
        if  (vAnio = vcAnioActual) and viFechaRecibida >= viFechaInicio and   viFechaRecibida <=   viFechaFin  THEN

       --IF  (vAnio = vcAnioActual) and (vMesActual = '01' and vcMes = '01') or ( (vMesActual = '02' and vcMes =  '02') and (vcDiaActual = '01' and vcDia = '01' ))   THEN 
               -- SI FECHA NO ES IGUAL A LA ACTUAL
               IF vdFechaActual <> pFecha THEN
                    LET vCodRet = '22222';
                    RETURN vCodRet;
                    
               END IF;
   
--
               IF EXISTS (SELECT proceso FROM bdilide:sl_procesos WHERE proceso = 'ret_dialde' AND year(fech_proceso) = vcAnioAnterior AND month( fech_proceso ) = '12' AND day( fech_proceso) ='31'  AND status = 1) THEN

                    -- SE OBTIENE EL ESTADO DEL PROCESO CONSTANCIA MENSUAL
                   SELECT status  INTO vcStatus FROM bdilide:sl_procesos  WHERE proceso  = 'constanual' AND  year(fech_proceso) =  vAnio;

                   -- SI ES NÚLO EL PROCESO NO EXISTE Y ENTONCES SE REGISTRA
                   IF vcStatus IS NULL THEN

                        INSERT INTO bdilide:sl_procesos VALUES('constanual', pFecha, '0', pUsuario, CURRENT ::DATE );

                    ELIF vcStatus = '0' or  vcStatus = '' THEN

                        DELETE FROM bdilide:sl_constancias WHERE aniomes = vAnioMes AND tipo_cons = 'A';

                    ELIF vcStatus = '1' THEN
                        LET vCodRet = '00002';
                        RETURN vCodRet;
                    END IF;

                  -- EMPEZAR ETAPA TRANSACCIONAL
                  BEGIN WORK; LET vcTransaccionalidad = 'S';
                  FOREACH
                        --SELECT DISTINCT(num_cte), rfc, SUM(imp_gravado), SUM(imp_arecaudar), SUM(imp_recaudado)--, SUM(imp_pendiente)--, SUM(imp_anterior)
                        --INTO vNumcliente, vRfc, vSumImpGrabado, vSumImparecaudar, vSumImprecaudado
                        --FROM bdilide:sl_retlide
                        --WHERE substr(aniomes, 1, 4) = vcAnioAnterior
                        --GROUP BY num_cte, rfc

                       SELECT DISTINCT(num_cte), SUM(imp_gravado), SUM(imp_arecaudar), SUM(imp_recaudado)--, SUM(imp_pendiente)--, SUM(imp_anterior)
                        INTO vNumcliente, vSumImpGrabado, vSumImparecaudar, vSumImprecaudado
                        FROM bdilide:sl_retlide
                        WHERE substr(aniomes, 1, 4) = vcAnioAnterior
                        GROUP BY num_cte

                        SELECT rfc INTO vRfc FROM bdinteg:si_cliente WHERE numcte = vNumcliente;

                       LET  vSumImppendiente = (NVL(vSumImparecaudar,0) - NVL(vSumImprecaudado,0) ); 

                                               
                       INSERT INTO bdilide:sl_constancias
                       VALUES (vAniomes, vNumcliente, 'A', vRfc, NVL(vSumImpGrabado,0), NVL(vSumImparecaudar,0), NVL(vSumImprecaudado,0), NVL(vSumImppendiente,0), NVL(vSumImpanterior,0),vTipocambio, pUsuario, CURRENT::DATE);
                
                   END FOREACH;

                   -- SE ACTUALIZA ÉSTE PROCESO PARA INDICAR QUE SE EJECUTÓ CORRECTAMENTE. (PROCESO DE CONSTANCIAS MENSUAL).
                    UPDATE bdilide:sl_procesos set status = '1' WHERE proceso = 'constanual' AND fech_proceso = pFecha;
                    -- COMMIT
                    COMMIT WORK; LET vcTransaccionalidad = 'N';
                ELSE
                    LET vCodRet = '00001';
                    RETURN vCodRet;
                END IF;
       ELSE
            -- NO ES RANGO DE FECHA VALIDO PARA EFECTUAR PROCESO
            LET  vCodRet  = '11111';


        END IF;

    ELSE
            -- NO ES TIEMPO PARA REALIZAR PROCESO
            LET  vCodRet  = '55555';
    END IF;     
    END;

RETURN vCodRet;

END PROCEDURE;