CREATE PROCEDURE "informix".sp_sn_retrieve_client_status(pNumCta CHAR(20),pNumCte CHAR(20),pNumRegistros SMALLINT)
        RETURNING CHAR(5), INT,CHAR(20),CHAR(4),CHAR(40), SMALLINT, CHAR(25),SMALLINT,DATE,SMALLINT,DATE,SMALLINT,SMALLINT,CHAR(25),SMALLINT,SMALLINT,SMALLINT,CHAR(6)
        
        DEFINE vCodRet                  CHAR(5);
        DEFINE vEmpresa                 CHAR(25);
        DEFINE sqlErr                   INTEGER;
        DEFINE iStatus                  SMALLINT;
        DEFINE iEmpresa                 SMALLINT;
        DEFINE iGrupoBenef              SMALLINT;
        DEFINE iTipoCliente             SMALLINT;
        DEFINE iCuentaNomina            SMALLINT;
        DEFINE iEstatusCuentaNomina     SMALLINT;
        DEFINE iEstatusPeticionCliente  SMALLINT;
        DEFINE iPeriodicidad            SMALLINT;
        DEFINE iId                      INT;
        DEFINE dFechaAlta               DATE;
        DEFINE dFechaBaja               DATE;
        DEFINE vProceso                 CHAR(6);
        DEFINE vNumCta                  CHAR(20);

        DEFINE vProd                    CHAR(4);
        DEFINE vProdNombre              CHAR(40);
        DEFINE vGrupoBenefDescrip       CHAR(25);
        DEFINE vStatusCta               CHAR(1);

        LET vCodRet                     = "00001";
        LET vEmpresa                    = "";
        LET sqlErr                      = 0;
        LET iStatus                     = 0;
        LET iId                         = 0;
        LET iEmpresa                    = 0;          
        LET iGrupoBenef                 = 0;        
        LET iTipoCliente                = 0;
        LET iCuentaNomina               = 0;
        LET iEstatusCuentaNomina        = 0;
        LET iEstatusPeticionCliente     = 0;
        LET iPeriodicidad               = 0;
        LET vProceso                    = "";
        LET vNumCta                     = "";
        LET dFechaBaja                  = NULL;
        LET dFechaAlta                  = NULL;
        LET vProd                       = "";
        LET vProdNombre                 = "";
        LET vGrupoBenefDescrip          = "";
        LET vStatusCta                  = "";
BEGIN
        
        ON EXCEPTION SET sqlErr
                IF sqlErr <> 0 THEN
                        LET vCodRet = sqlErr;
                        RETURN vCodRet,iId,vNumCta,vProd,vProdNombre,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso;
                END IF;
        END EXCEPTION;

        -- SET DEBUG FILE TO "/INFORMIXDUMP/sp_sn_retrieve_client_status.trc";
        -- TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
		LET pNumCte = TRIM(pNumCte);
		LET pNumCta = TRIM(pNumCta);
		
        IF TRIM(NVL(pNumCta,'')) = '' AND TRIM(NVL(pNumCte,'')) = '' THEN
                RETURN vCodRet,iId,vNumCta,vProd,vProdNombre,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso;
        ELSE
                IF TRIM(NVL(pNumCta,'')) = '' THEN
                        FOREACH
                                SELECT SKIP pNumRegistros FIRST 20 cta.id,cta.numcta,prod.producto,prod.nombre,maechq.status_cta,cta.estatus,emp.descripcion,cta.cuentaNomina,cta.fechaAltaDeNomina,cta.estatusCuentaNomina,cta.fechaBajaDeNomina,cta.empresagc,cta.grupoBeneficios,gpo.descripcion,cta.periodicidad,cta.tipoCliente,cta.estatusPeticionCliente,cta.proceso
                                INTO iId,vNumCta,vProd,vProdNombre,vStatusCta,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso
                                FROM "informix".sn_cte_cta_nomina cta
                                INNER JOIN "informix".sn_empresas_gc emp
                                        ON (cta.empresagc = emp.idEmpresa)
                                INNER JOIN "informix".sn_gpo_beneficios_cta_nomina gpo
                                        ON(gpo.idGrupo = cta.grupoBeneficios)
                                INNER JOIN bdicheq: "informix".sc_maechq maechq
                                        ON(maechq.cuenta = cta.numcta)
                                INNER JOIN bdicheq: "informix".sc_producto prod
                                        ON(prod.producto = maechq.producto
                                        AND maechq.empresa = prod.empresa)
                                WHERE cta.numcte = pNumCte
                                        AND maechq.status_cta = '1'
                                ORDER BY cta.numcta DESC

                               LET vCodRet = '00000'; 
                               RETURN vCodRet,iId,vNumCta,vProd,vProdNombre,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso WITH RESUME;
                        END FOREACH;
                ELSE
                        SELECT FIRST 1 cta.id,cta.numcta,prod.producto,prod.nombre,maechq.status_cta,cta.estatus,emp.descripcion,cta.cuentaNomina,cta.fechaAltaDeNomina,cta.estatusCuentaNomina,cta.fechaBajaDeNomina,cta.empresagc,cta.grupoBeneficios,gpo.descripcion,cta.periodicidad,cta.tipoCliente,cta.estatusPeticionCliente,cta.proceso
                        INTO iId,vNumCta,vProd,vProdNombre,vStatusCta,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso
                        FROM "informix".sn_cte_cta_nomina cta
                        INNER JOIN "informix".sn_empresas_gc emp
                                ON (cta.empresagc = emp.idEmpresa)
                        INNER JOIN "informix".sn_gpo_beneficios_cta_nomina gpo
                                ON(gpo.idGrupo = cta.grupoBeneficios)
                        INNER JOIN bdicheq: "informix".sc_maechq maechq
                                ON(maechq.cuenta = cta.numcta)
                        INNER JOIN bdicheq: "informix".sc_producto prod
                                ON(prod.producto = maechq.producto
                                AND maechq.empresa = prod.empresa)
                        WHERE cta.numcte = pNumCte
                                AND cta.numcta = pNumCta;

                        IF DBINFO('sqlca.sqlerrd2') > 0 THEN
                            IF vStatusCta != '1' THEN
                                    LET vCodRet = '00003';
                            ELSE
                                    LET vCodRet = '00000';
                            END IF;
                            RETURN vCodRet,iId,vNumCta,vProd,vProdNombre,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso;
                        END IF;
                END IF;
        END IF;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                LET vCodRet                     = "00002";
                LET iId                         = 0; 
                LET iStatus                     = 0;
                LET vEmpresa                    = "";
                LET iCuentaNomina               = 0;
                LET iEstatusCuentaNomina        = 0;
                LET iEmpresa                    = 0;
                LET iGrupoBenef                 = 0;
                LET iPeriodicidad               = 0;
                LET iTipoCliente                = 0;
                LET iEstatusPeticionCliente     = 0;
                LET vProceso                    = ""; 
                LET vNumCta                     = ""; 
                LET dFechaBaja                  = NULL;  
                LET dFechaAlta                  = NULL;
                LET vProd                       = "";
                LET vProdNombre                 = "";
                LET vGrupoBenefDescrip          = "";
                RETURN vCodRet,iId,vNumCta,vProd,vProdNombre,iStatus,vEmpresa,iCuentaNomina,dFechaAlta,iEstatusCuentaNomina,dFechaBaja,iEmpresa,iGrupoBenef,vGrupoBenefDescrip,iPeriodicidad,iTipoCliente,iEstatusPeticionCliente,vProceso;
        END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimiento almacenado ejecuta una consulta en la cual se obtienen datos del cliente relacionados con sus cuentas de nomina.',
'PETICION: Iniciativa cuenta Nomina',
'AUTOR: Jorge Arturo Astorga',
'FECHA DE CREACION: 2022/08/19',
'BD: bdiadminnomina';