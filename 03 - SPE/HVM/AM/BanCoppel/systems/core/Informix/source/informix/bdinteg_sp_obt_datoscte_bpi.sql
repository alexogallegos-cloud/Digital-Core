CREATE PROCEDURE "informix".sp_obt_datoscte_bpi(pEmpresa char(3), pNumCte char(20), pTipoValidacion integer)
returning char(5),char(20), char(26),char(26),char(26),char(26), smallint, date;

    --------------------------------------------------------------------------------------------
    -- RealizÃ³: Mauricio LeÃ³n
    -- Actividad: Obtiene los datos del cliente
    -- SolicitÃ³: Mauricio LeÃ³n
    -- Fecha de Solicitud: 28/12/2008
    -- ModificÃ³: Javier CalderÃ³n
    -- Fecha de ModificaciÃ³n: 04/03/2009
    ---------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------
    --Modificacion: se modifico para omitir tablas temporales, ya hacer consulta directa., ademas se modifico el LEFT OUTER JOIN por RIGHT OUTER --JOIN
    --Modifico: Francisco Rodriguez Ibarra
    --Fecha:20-07-2010
	---------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------
	--Modificacion: se actualiza para que obtenga todas la cuentas de crÃ©dito del cliente.
    --Modifico: JosÃ© de JesÃºs Nevarez
    --Fecha:29-11-2017
    ---------------------------------------------------------------------------------------------
    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
    DEFINE vNumTarjeta char(20);
    DEFINE vNombre1, vNombre2, vApellPaterno, vApellMaterno  char(26);
    DEFINE iCont, vIdStatus, vRegistros SMALLINT;
    DEFINE vCuenta char(11);
    DEFINE vFechaNac date;

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET cod_ret = '000';
    LET vNumTarjeta = ' ';
    LET vNombre1 = ' ';
    LET vNombre2 = ' ';
    LET vApellPaterno = ' ';
    LET vApellMaterno = ' ';
    LET vIdStatus = 0;
    LET vFechaNac = '01-01-1900';
    LET vRegistros = 0;
    LET iCont = 0;
    LET vCuenta = '';

    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;
        END IF
    END EXCEPTION;
	
   --SET DEBUG FILE TO '/informix/JoseDeJesus/sp_obt_datoscte_bpi.out';
   --TRACE ON;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte ) THEN
        SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac, c.id_status
          INTO vNombre1, vNombre2, vApellPaterno, vApellMaterno, vFechaNac, vIdStatus
          FROM bdinteg:"informix".si_cliente a,  bdinteg:"informix".si_ctepf b, bdinteg:"informix".si_bpiusuarios c
         WHERE a.numcte = pNumCte 
           AND a.empresa = pEmpresa
           AND a.numcte = b.numcte 
           AND a.numcte = c.numcte;
		
		
        IF vIdStatus <> 10 AND vIdStatus <> 95 AND vIdStatus <> 21 THEN
            LET cod_ret = '004'; --Estatus incorrecto
        END IF
		
		IF vIdStatus == 21 THEN
			UPDATE bdinteg:"informix".si_bpiusuarios  SET id_status=10 WHERE empresa = pEmpresa AND numcte = pNumCte;
			LET vIdStatus=10;
        END IF
		
    ELSE
        LET cod_ret = '001'; --Cliente no existe
    END IF
	
    IF cod_ret = '000' THEN

        IF pTipoValidacion = 1 THEN
			FOREACH
				SELECT tr.num_tarjeta, mc.num_credito
				INTO vNumTarjeta, vCuenta
				FROM bdicred:"informix".sd_maecred mc
				JOIN bdicred:"informix".sd_tarjeta tr ON ( tr.empresa = pEmpresa AND mc.num_credito = tr.num_credito AND tr.tipo_tarjeta = 'T' AND tr.secuencia = ( SELECT MAX(secuencia) 
					FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND mc.num_credito = num_credito AND tipo_tarjeta = 'T' ) )
					WHERE mc.numcte = pNumCte

                LET vRegistros = vRegistros + 1;

                RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac WITH RESUME;
			END FOREACH;
            
			 IF vRegistros = 0 THEN
                LET cod_ret = '003'; --Cliente no tiene cuentas de crÃ©dito
            END IF
        ELIF pTipoValidacion = 2 THEN
            FOREACH
                SELECT {(+INDEX) bdicheq:"informix".sc_maechq maecheques} nvl(b.num_tarjeta,'0000000000000000')
                  INTO vNumTarjeta
                  FROM bdicheq:"informix".sc_maechq  a
                 RIGHT OUTER JOIN bdicheq:"informix".sc_tarjeta b ON ( b.empresa = pEmpresa AND 
                                                            a.cuenta = b.cuenta  AND 
                                                            b.secuencia <> 0     AND 
                                                            b.status_tar = 'A'   AND 
                                                            b.tipo_tarjeta = 'T' )
                 WHERE a.num_cte = pNumCte
                   AND a.status_cta NOT IN('2')

                LET vRegistros = vRegistros + 1;

                RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac WITH RESUME;
            END FOREACH;

            IF vRegistros = 0 THEN
                LET cod_ret = '002'; --Cliente no tiene cuentas de dÃ©bito
            END IF
		ELSE
			RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;
        END IF
	ELSE
		RETURN cod_ret, vNumTarjeta, vNombre1, vNombre2, vApellPaterno, vApellMaterno, vIdStatus, vFechaNac;	
    END IF
END    
END PROCEDURE ;