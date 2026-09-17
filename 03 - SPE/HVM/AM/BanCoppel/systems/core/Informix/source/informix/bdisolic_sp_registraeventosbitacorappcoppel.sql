CREATE PROCEDURE "informix".sp_registraeventosbitacorappcoppel( pConsulta       CHAR (1),
                                                                    pPromotor       CHAR(30),
	                                                                pSucursal       CHAR(4),
                                                                    pNumcteBanco    CHAR(20),
                                                                    pNumcteCoppel   CHAR(20),
                                                                    pFolioPrestamo  CHAR(20),
                                                                    pCandidato      CHAR(1),
                                                                    pSolicitud      CHAR(1),
                                                                    pAmortizacion   CHAR(1),
                                                                    pAsigCta        CHAR(1),
                                                                    pAsigTarj       CHAR(1),
                                                                    pAutorizacion   CHAR(1))

    RETURNING CHAR(6) AS codret;

    DEFINE iCodRet              INTEGER;
    DEFINE cCodRet              CHAR(6);
    DEFINE cConsulta            CHAR(1);
    DEFINE cpromotor            CHAR(30);
    DEFINE csucursal            CHAR(4);
    DEFINE dfechaInicioProceso  DATETIME YEAR TO SECOND;
    DEFINE dfechaFinProceso     DATETIME YEAR TO SECOND;
    DEFINE cnumcteBanco         CHAR(20);
    DEFINE cnumcteCoppel        CHAR(20);
    DEFINE cfolioPrestamo       CHAR(20);
    DEFINE ccandidato           CHAR(1);
    DEFINE csolicitud           CHAR(1);
    DEFINE camortizacion        CHAR(1);
    DEFINE cAsigCta             CHAR(1);
    DEFINE cAsigTarj            CHAR(1);
    DEFINE cautorizacion        CHAR(1);
    DEFINE cAuxiliarFecha       CHAR (30);

    LET iCodRet = 0;
    LET cCodRet ='';
    LET cConsulta = '';
    LET cpromotor = pPromotor;
    LET csucursal = pSucursal;
    LET dfechaInicioProceso = '';
    LET dfechaFinProceso = null;
    LET cnumcteBanco = pNumcteBanco;
    LET cnumcteCoppel = pNumcteCoppel;
    LET cfolioPrestamo = pFolioPrestamo;
    LET ccandidato = pCandidato;
    LET csolicitud = pSolicitud;
    LET camortizacion = pAmortizacion;
    LET cAsigCta = pAsigCta;
    LET cAsigTarj = pAsigTarj;
    LET cautorizacion = pAutorizacion;
    LET cAuxiliarFecha ='';

    BEGIN
        ON EXCEPTION SET iCodRet
            LET cCodRet = iCodRet;
            RETURN cCodRet;
        END EXCEPTION;

        --SET debug file to '/tmp/sp_registraeventosbitacorappcoppel.out';
        --trace on;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        IF pConsulta = '1' THEN

            INSERT INTO "informix".ss_bitacoraeventosppcoppel(promotor, sucursal, fechaInicioProceso, fechaFinProceso, numcteBanco, numcteCoppel, folioPrestamo, candidato, solicitud, amortizacion, AsigCta, AsigTarj, autorizacion)
                                                    VALUES(cpromotor, csucursal, CURRENT, dfechaFinProceso, cnumcteBanco, cnumcteCoppel, cfolioPrestamo, '0', '0', '0', '0', '0', '0');

            IF DBINFO('SQLCA.SQLERRD2')>0 THEN
                LET cCodRet = '000002';                RETURN cCodRet;
            END IF;
        END IF;

        IF pConsulta = '2' THEN
            IF pPromotor IS NULL THEN
                LET cCodRet = '000001'; ---Status vacio
                RETURN cCodRet;
            END IF;

            SELECT MAX (fechaInicioProceso)
              INTO cAuxiliarFecha
              FROM "informix".ss_bitacoraeventosppcoppel
             WHERE numcteCoppel = cnumcteCoppel AND fechaFinProceso IS NULL;
        
            IF(cAuxiliarFecha IS NOT NULL ) THEN

                UPDATE "informix".ss_bitacoraeventosppcoppel
                   SET fechaFinProceso = current, 
                       folioPrestamo = cfolioPrestamo, 
                       candidato = ccandidato, 
                       solicitud = csolicitud, 
                       amortizacion = camortizacion, 
                       AsigCta = cAsigCta, 
                       AsigTarj = cAsigTarj, 
                       autorizacion = cautorizacion
                 WHERE numcteCoppel = cnumcteCoppel 
                   AND fechaInicioProceso = cAuxiliarFecha;

            END IF;

            IF DBINFO('SQLCA.SQLERRD2')>0 THEN
                LET cCodRet = '000002';                
                RETURN cCodRet;
            END IF;

        END IF;

        IF DBINFO('SQLCA.SQLERRD2')>0 THEN
	        LET cCodRet = '000003';	RETURN cCodRet;
        END IF;

    END;

END PROCEDURE;