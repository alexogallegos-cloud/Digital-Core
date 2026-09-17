CREATE PROCEDURE "informix".sp_dispersionnominavalidacionestatus_bpi( pCuenta CHAR(20),
                                                                  pNumeroEmpresa CHAR(3),
                                                                  pFechaGeneracion CHAR(10),
                                                                  pFolioArchivo INTEGER,
                                                                  pFechaActual CHAR(10),
                                                                  pHoraActual CHAR (8),
                                                                  pNombreArchivo CHAR(17),
                                                                  pNumeroEmpleado CHAR(10),
                                                                  pImporteEmpleado MONEY(18,2),
                                                                  pImporteNoAbonado MONEY(18,2),
                                                                  piTipoEmpresa		CHAR(1) )
RETURNING CHAR(3),CHAR(1),CHAR(1),MONEY(18,2),CHAR(4),CHAR(4);

    DEFINE vcodret          CHAR(3);
    DEFINE cEstatusCuenta   CHAR(1);
    DEFINE cSucursalAbono   CHAR(4);
    DEFINE cSucursalCargo   CHAR(4);
    DEFINE cMotivo          CHAR(2);
    DEFINE cConsulta        CHAR(1);
    DEFINE iExiste          INTEGER;
    DEFINE iAceptab         INTEGER;
    DEFINE iSqlerr          INTEGER;
    DEFINE iBandera         INTEGER;

    Begin

    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            Let vcodret = iSqlerr;
            RETURN vcodret,cEstatusCuenta,cConsulta,NVL(pImporteNoAbonado,'0.00'),cSucursalCargo,cSucursalAbono;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --Set Debug File To '/home/informix/ivonne/sp_dispersionnominavalidacionestatus.out';
    --Trace On;

    LET vcodret = "000";
    LET cEstatusCuenta	 = "";
    LET cSucursalAbono = "";
    LET cSucursalCargo	= "";
    LET cMotivo = "";
    LET cConsulta = "";
    LET iExiste = 0;
    LET iAceptab = 0;
    LET iBandera = 0;

    IF  pCuenta  <> "" AND pNumeroEmpresa <> "" AND pFechaGeneracion <> "" AND pFolioArchivo <> 0 AND pFechaActual <> "" AND pHoraActual <> "" THEN
        LET iBandera = 1;
        LET pImporteNoAbonado = '0.00';
    ELSE
        IF pCuenta  <> ""  AND pNombreArchivo <> "" AND pNumeroEmpleado <> "" AND NOT pImporteEmpleado IS NULL  AND NOT pImporteNoAbonado IS NULL AND piTipoEmpresa <> "" THEN
            LET iBandera = 2;
        END IF
    END IF;

    IF iBandera <> 1 AND iBandera <> 2 THEN
        LET vcodret = '805';
    END IF

    /* INICIO de Consulta para la cuenta eje */
    IF iBandera = 1 THEN
        Let cEstatusCuenta = '';
        Let cSucursalCargo = '';

        SELECT status_cta, sucursal,motivo
          INTO cEstatusCuenta, cSucursalCargo, cMotivo
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pCuenta;

        /* La Cuenta esta Cancelada */
        IF cEstatusCuenta = '2' THEN
            Let vcodret = "815";

             /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
            UPDATE bdicheq:sc_nominaencabezadosumario_bpi
               SET status = '8',
                   fecha_aplicado = pFechaActual,
                   hora_aplicado = pHoraActual
             WHERE empresa = pNumeroEmpresa
               AND fecha_gen = pFechaGeneracion
               AND folio_archivo = pFolioArchivo;
        END IF

        IF cEstatusCuenta = '3' THEN   -- La Cuenta esta Bloqueada

            SELECT "1"
              INTO iExiste
              FROM sc_ctabloqueo
             WHERE cuenta = pCuenta;

            IF iExiste = "1" THEN

                SELECT opcion
                  INTO iAceptab
                  FROM sc_ctabloqueo
                  WHERE cuenta = pCuenta;

                IF iAceptab = 4 THEN
                    Let vcodret = "820";

                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario_bpi
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF;

                IF iAceptab = 3 THEN
                    Let vcodret = "820";

                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario_bpi
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF;
            ELSE
                /* Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no cargos */
                SELECT cargo
                  INTO cConsulta
                  FROM sc_bloqueo
                 WHERE codigo=cMotivo;

                IF cConsulta = 'N' THEN
                    Let vcodret = "820";

                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario_bpi
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF
            END IF
        END IF
    END IF  /* FIN de Consulta para la cuenta eje */

    /* INICIO de Consulta para la cuenta Empleado */
    IF iBandera = 2 THEN
        Let cEstatusCuenta = '';
        Let cSucursalAbono = '';
        LET  cConsulta = "S";

        SELECT status_cta, sucursal,motivo
          INTO cEstatusCuenta, cSucursalAbono,cMotivo
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pCuenta;

        IF cEstatusCuenta = '2' THEN
            LET  cConsulta = "N";

            /* Cuenta Cancelada */
            UPDATE bdicheq:sc_nominamovimientos_bpi
               SET status = cEstatusCuenta
             WHERE nombre_archivo = pNombreArchivo
               AND num_empleado = pNumeroEmpleado;

            IF piTipoEmpresa = 2 THEN
                Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
            END IF
        END IF

        IF cEstatusCuenta = '3' THEN
            SELECT "1"
              INTO iExiste
              FROM sc_ctabloqueo
             WHERE cuenta = pCuenta;

            IF iExiste = "1" THEN

                SELECT opcion
                  INTO iAceptab
                  FROM sc_ctabloqueo
                 WHERE cuenta = pCuenta;

                IF iAceptab = 4 THEN
                    LET cConsulta = "N";
                    Let vcodret = "820";

                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos_bpi
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF;

                IF iAceptab = 2 THEN
                    LET cConsulta = "N";
                    Let vcodret = "820";

                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos_bpi
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF;
            ELSE
                /* Selecciono el campo Abono de sc_bloqueo, para saber si el tipo de bloqueo admite o no Abonos */
                SELECT abono
                  INTO cConsulta
                  FROM sc_bloqueo
                 WHERE codigo = cMotivo;

                IF cConsulta = 'N' THEN
                    Let vcodret = "820";

                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos_bpi
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF
            END IF
        END IF
    END IF  /* FIN de Consulta para la cuenta Empleado */

    RETURN vcodret,cEstatusCuenta,cConsulta,pImporteNoAbonado,cSucursalCargo,cSucursalAbono;

    END

END Procedure

DOCUMENT
'DESCRIPCION: Genera las validaciones para el estatus de la cuenta a consultar para la dispersion de nomina"',
'AUTOR: Jesus Antonio Bastidas Lopez',
'FECHA: Abril de 2009',
'VERSION: 200904',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_generamovtosfecha(pCuenta CHAR(20),
                                                 pFecha_ini date, 
                                                 pFecha_fin date, 
                                                 pSucursal CHAR(4), 
                                                 pMonto MONEY(18,2), 
                                                 pEmpleado CHAR(8), 
                                                 pUsuario CHAR(8), 
                                                 pRegistro INTEGER
												 )

RETURNING CHAR(5),DATE, CHAR(50), CHAR(40), CHAR(16), 
          MONEY(18,2), MONEY(18,2), MONEY(18,2);

    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
    DEFINE cTransacc		CHAR(50);
    DEFINE cTarjeta			CHAR(16);
    DEFINE cReferencia		CHAR(40);
    DEFINE dFecha_hoy       DATE;
    DEFINE dFecha_alt		DATE;
    DEFINE mSdo_antmov      MONEY(18,2);
    DEFINE cNatu			CHAR(1);
    DEFINE mCargo			MONEY(18,2);
    DEFINE mAbono			MONEY(18,2);
    DEFINE cConsmovhis		CHAR(10);	
    DEFINE cConsmovhisold   CHAR(10);
    DEFINE cConsmovhisold2  CHAR(10);
    DEFINE sCont			SMALLINT;
    DEFINE mMonto_mov		MONEY(18,2);
    DEFINE mSdo_antmovcal   MONEY(18,2);
    DEFINE mMonto_movcal	MONEY(18,2);
    DEFINE cNatu_ant        CHAR(1);
	DEFINE cTrans           CHAR(4) ;
	DEFINE cTrans2          CHAR(4) ;
--	DEFINE cCansela         CHAR(1); DSB 08/11/2011
	DEFINE iNumSerial       INTEGER;
--	DEFINE iContador        INTEGER;  

    LET cCodRet     = "00000";
	LET iSqlErr     = 0;
    LET cTransacc	= "";
    LET cTarjeta	= "";
    LET cReferencia	= "";
    LET dFecha_hoy  = DATE(1);
    LET dFecha_alt  = DATE(1);
    LET mSdo_antmov = 0;
    LET cNatu		= '';
    LET mCargo      = 0;
    LET mAbono 		= 0;
    LET cConsmovhis	= '';
    LET sCont		= 0;
    LET mMonto_mov	= 0;
    LET mSdo_antmovcal = 0;
    LET mMonto_movcal  = 0;
    LET cNatu_ant	= '';
    LET cConsmovhisold	= '';
    LET cConsmovhisold2 = '';
	LET cTrans =  '';
	LET cTrans2 =  '';
--	LET cCansela =  '';  DSB 08/11/2011
	LET iNumSerial =  0;
--	LET iContador  =  0;  
	
	SET LOCK MODE TO WAIT 3;
	
    BEGIN

    ON EXCEPTION SET iSqlErr
        IF cCodRet != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, dFecha_alt, cTransacc, cReferencia,
                   cTarjeta, mCargo, mAbono, mSdo_antmov;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    --SET DEBUG FILE TO "/respaldosbd/cris/sp_generamovtosfecha.out";
    --TRACE ON;

    IF NOT EXISTS (SELECT cuenta 
                     FROM Bdicheq:"informix".sc_maechq 
                    WHERE empresa= '001' 
                      AND cuenta = pcuenta)THEN    
        LET cCodRet = "10000"; -- // No existe cuenta
        RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,
               cTarjeta, mCargo, mAbono, mSdo_antmov;
    END IF;
    
    IF EXISTS( SELECT {+INDEX(sc_conmovtosfecha idx_conmovtosfecha)} usuario 
                 FROM bdicheq:"informix".sc_conmovtosfecha 
                WHERE usuario = pUsuario) THEN
        DELETE {+INDEX(sc_conmovtosfecha idx_conmovtosfecha)} sc_conmovtosfecha 
         WHERE usuario = pUsuario;
    END IF;
    
    SELECT {+INDEX(sc_fechas idx_fechas1)} fecha_hoy
      INTO dFecha_hoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = '001';

    IF pFecha_fin < dFecha_hoy AND pFecha_ini <= pFecha_fin THEN

        IF pMonto = "" OR pMonto IS NULL THEN
            LET pMonto = 0;
        END IF;

        SELECT valor
          INTO cConsmovhis
          FROM Bdicheq:"informix".sc_param
         WHERE empresa = '001'
           AND codparam = 'fechcon_movhis';
           
        SELECT valor
          INTO cConsmovhisold
          FROM bdicheq:"informix".sc_param
         WHERE empresa = '001'
           AND codparam = 'FechIniCon_movhis_ol';
           
        SELECT valor
          INTO cConsmovhisold2
          FROM bdicheq:"informix".sc_param
         WHERE empresa = '001'
           AND codparam = 'FechaIniMovhisOld2';

		   
        INSERT INTO bdicheq:"informix".sc_conmovtosfecha
        SELECT {+INDEX(sc_movhis idx_movhisnew4)}
               NVL(fech_alt, " "), 
               NVL(TRIM(transacc||' '||descripcion), " "),
               NVL(referencia, " "), 
               NVL(num_tarjeta, " "), 
               NVL(monto_tot, 0), 
               NVL(sdo_cuenta, 0), 
               NVL(naturaleza, " "),
               NVL(fech_hor, " "), 
               pUsuario,
			   NVL(m.cancelad, " "),
			   NVL(num_serial,0)
          FROM bdicheq:"informix".sc_movhis m,
               bdinteg:"informix".si_transacc t
         WHERE m.empresa = "001" 
           AND m.cuenta = pCuenta
           AND m.fech_alt BETWEEN pFecha_ini AND pFecha_fin
           AND m.fech_alt >= cConsmovhis
          --AND m.cancelad <> 'S'
           AND m.transacc = t.numero
           AND m.monto_tot = CASE WHEN pMonto = 0 THEN monto_tot ELSE pMonto END
           AND m.sucursal = CASE WHEN pSucursal = "" THEN sucursal ELSE pSucursal END
           AND m.usuario = CASE WHEN pEmpleado = "" THEN usuario ELSE pEmpleado END
           AND t.empresa = m.empresa
           AND t.numero = m.transacc
           AND t.se_emite_edocta = "S";
		   
        
        INSERT INTO bdicheq:"informix".sc_conmovtosfecha
        SELECT {+INDEX(sc_movhis_old movhis1)}
               NVL(fech_alt, " "), 
               NVL(TRIM(transacc||' '||descripcion), " "),
               NVL(referencia, " "), 
               NVL(num_tarjeta, " "), 
               NVL(monto_tot, 0), 
               NVL(sdo_cuenta, 0), 
               NVL(naturaleza, " "),
               NVL(fech_hor, " "), 
               pUsuario,
			   NVL(m.cancelad, " "),
			   NVL(num_serial,0)
          FROM bdicheq:"informix".sc_movhis_old m,
               bdinteg:"informix".si_transacc t
         WHERE m.empresa = "001" 
           AND m.cuenta = pCuenta
           AND m.fech_alt BETWEEN pFecha_ini AND pFecha_fin
           AND m.fech_alt >= cConsmovhisold
           AND m.fech_alt < cConsmovhis
           --AND m.cancelad <> 'S'
           AND m.transacc = t.numero
           AND m.monto_tot = CASE WHEN pMonto = 0 THEN monto_tot ELSE pMonto END
           AND m.sucursal = CASE WHEN pSucursal = "" THEN sucursal ELSE pSucursal END
           AND m.usuario = CASE WHEN pEmpleado = "" THEN usuario ELSE pEmpleado END
           AND t.empresa = m.empresa
           AND t.numero = m.transacc
           AND t.se_emite_edocta = "S";
           
        INSERT INTO bdicheq:"informix".sc_conmovtosfecha
        SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
               NVL(fech_alt, " "), 
               NVL(TRIM(transacc||' '||descripcion), " "),
               NVL(referencia, " "), 
               NVL(num_tarjeta, " "), 
               NVL(monto_tot, 0), 
               NVL(sdo_cuenta, 0), 
               NVL(naturaleza, " "),
               NVL(fech_hor, " "), 
               pUsuario,
			   NVL(m.cancelad, " "),
			   NVL(num_serial,0)
          FROM bdicheq:"informix".sc_movhis_old2 m,
               bdinteg:"informix".si_transacc t
         WHERE m.empresa = "001" 
           AND m.cuenta = pCuenta
           AND m.fech_alt BETWEEN pFecha_ini AND pFecha_fin
           AND m.fech_alt >= cConsmovhisold2
           AND m.fech_alt < cConsmovhisold
           --AND m.cancelad <> 'S'
           AND m.transacc = t.numero
           AND m.monto_tot = CASE WHEN pMonto = 0 THEN monto_tot ELSE pMonto END
           AND m.sucursal = CASE WHEN pSucursal = "" THEN sucursal ELSE pSucursal END
           AND m.usuario = CASE WHEN pEmpleado = "" THEN usuario ELSE pEmpleado END
           AND t.empresa = m.empresa
           AND t.numero = m.transacc
           AND t.se_emite_edocta = "S";
		   
           
        INSERT INTO bdicheq:"informix".sc_conmovtosfecha
        SELECT {+INDEX(sc_movhis_old3 movhis1_old3)}
               NVL(fech_alt, " "), 
               NVL(TRIM(transacc||' '||descripcion), " "),
               NVL(referencia, " "), 
               NVL(num_tarjeta, " "), 
               NVL(monto_tot, 0), 
               NVL(sdo_cuenta, 0), 
               NVL(naturaleza, " "),
               NVL(fech_hor, " "), 
               pUsuario,
			   NVL(m.cancelad, " "),
			   NVL(num_serial,0)
          FROM bdicheq:"informix".sc_movhis_old3 m,
               bdinteg:"informix".si_transacc t
         WHERE m.empresa = "001" 
           AND m.cuenta = pCuenta
           AND m.fech_alt BETWEEN pFecha_ini AND pFecha_fin
           AND m.fech_alt < cConsmovhisold2
           --AND m.cancelad <> 'S'
           AND m.transacc = t.numero
           AND m.monto_tot = CASE WHEN pMonto = 0 THEN monto_tot ELSE pMonto END
           AND m.sucursal = CASE WHEN pSucursal = "" THEN sucursal ELSE pSucursal END
           AND m.usuario = CASE WHEN pEmpleado = "" THEN usuario ELSE pEmpleado END
           AND t.empresa = m.empresa
           AND t.numero = m.transacc
           AND t.se_emite_edocta = "S";

        IF pSucursal <> '' OR pMonto <> 0 OR pEmpleado <> '' THEN -- // Valida que los filtros Sucursal, Empleado o monto se hallan utilizado.

            FOREACH  -- // se utilizaron filtros y regresa valores sin calcular saldos.
                SELECT {+INDEX(sc_conmovtosfecha idx_conmovtosfecha)}
                       SKIP pRegistro FIRST 20 
                       NVL(fech_alt, " "),
                       NVL(TRIM(transacc), " "), 
					   SUBSTR(transacc, 1,4),
                       NVL(TRIM(referencia), " "),
                       NVL(TRIM(num_tarjeta), " "), 
                       NVL(monto_mov, 0),
                       NVL(sdo_cuenta, 0), 
                       NVL(TRIM(naturaleza), " "),
					   NVL(num_serial,0)
                  INTO dFecha_alt, cTransacc, cTrans, cReferencia, cTarjeta, mMonto_mov, mSdo_antmov,cNatu, iNumSerial
                  FROM bdicheq:"informix".sc_conmovtosfecha
                 WHERE usuario = pUsuario
			  ORDER BY num_serial
				
				LET cTrans = cTrans;
                
				IF cNatu = 'C' THEN
                    LET mCargo = mMonto_mov;
                    LET mAbono = 0;
                ELSE
                    LET mAbono = mMonto_mov;
                    LET mCargo = 0;
                END IF;
				
		--		LET icontador = 1;  
				
				RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmov WITH RESUME;
            END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '30000';
				RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmov;
			END IF;	

        ELSE

            FOREACH  -- // Se utilizo solo cuenta y rango de fechas como filtro, por lo tanto se reconstruyen saldos.
               
					SELECT {+INDEX(sc_conmovtosfecha idx_conmovtosfecha)}
						SKIP pRegistro FIRST 20
						NVL(fech_alt, " "),
						NVL(TRIM(transacc), " "),
						SUBSTR(transacc, 1,4),
						NVL(TRIM(referencia), " "),
						NVL(TRIM(num_tarjeta), " "), 
						NVL(monto_mov, 0),
						NVL(sdo_cuenta, 0), 
						NVL(TRIM(naturaleza), " "),
					    NVL(num_serial,0)
						   
					INTO dFecha_alt, cTransacc, cTrans, cReferencia, cTarjeta, mMonto_mov, mSdo_antmov,cNatu, iNumSerial
					FROM Bdicheq:"informix".sc_conmovtosfecha
					WHERE usuario = pUsuario
					AND cancelad <> "S"
					ORDER BY num_serial
				 
				IF sCont =  0 THEN
				
					FOREACH
						SELECT first 1 NVL(sdo_cuenta, 0) 
						INTO  mSdo_antmov
						FROM Bdicheq:"informix".sc_conmovtosfecha
						WHERE usuario = pUsuario
						AND cancelad = "S"
						AND fech_alt = dFecha_alt
						AND num_serial < iNumSerial
					END FOREACH;
					
							
					LET mSdo_antmovcal = mSdo_antmov;
                    LET mMonto_movcal = mMonto_mov;
                    LET cNatu_ant = cNatu;

                    IF cNatu = 'C' THEN
                        LET mCargo = mMonto_mov;
                        LET mAbono = 0.00;
                    ELSE
                        LET mAbono = mMonto_mov;
                        LET mCargo = 0.00;
                    END IF;

                    LET sCont = 1;

					RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmov WITH RESUME;


					CONTINUE FOREACH;
				
				
				END IF;
					
				
				IF cTrans <> "0250" AND cTrans <> "0232"  THEN
					IF cTrans2 <> "0250" AND cTrans2 <> "0232"  THEN
						LET cTrans2 = cTrans;			
						IF cNatu_ant = 'C' THEN
								--Saldo anterior                --Saldo anterior                --Monto Movimiento
							LET mSdo_antmovcal = mSdo_antmovcal - mMonto_movcal;
						--	LET mMonto_movcal = mMonto_mov;  DSB-08/11/2011
						ELSE
							LET mSdo_antmovcal = mSdo_antmovcal + mMonto_movcal;
						--	LET mMonto_movcal = mMonto_mov;  DSB-08/11/2011
						END IF;
					ELSE
						LET cTrans2 = cTrans;
						-- DSB-08/11/2011
						/*IF cNatu_ant = 'C' THEN
							LET mSdo_antmovcal = mSdo_antmovcal;
						--	LET mMonto_movcal = mMonto_mov;
						ELSE
							LET mSdo_antmovcal = mSdo_antmovcal;
						--	LET mMonto_movcal = mMonto_mov;
						END IF;*/
						LET mSdo_antmovcal = mSdo_antmov;		
					END IF;
				ELSE
					
					IF cTrans2 <> "0250" AND cTrans2 <> "0232"  AND cTrans2 <> "" THEN
						LET cTrans2 = cTrans;
						IF cNatu_ant = 'C' THEN
							LET mSdo_antmovcal = mSdo_antmovcal - mMonto_movcal;
						--	LET mMonto_movcal = mMonto_mov;  DSB-08/11/2011
						ELSE
							LET mSdo_antmovcal = mSdo_antmovcal + mMonto_movcal;
						--	LET mMonto_movcal = mMonto_mov;  DSB-08/11/2011
						END IF;
					
					ELSE
						LET cTrans2 = cTrans;
						--DSB-08/11/2011
						/*IF cNatu_ant = 'C' THEN
							--LET mSdo_antmovcal = mSdo_antmovcal;
							LET mSdo_antmovcal = mSdo_antmov;						
						--	LET mMonto_movcal = mMonto_mov;
						ELSE
							--LET mSdo_antmovcal = mSdo_antmovcal;
							LET mSdo_antmovcal = mSdo_antmov;						
							--LET mMonto_movcal = mMonto_mov;
						END IF;*/
						LET mSdo_antmovcal = mSdo_antmov;						
					END IF;
				END IF;
				LET mMonto_movcal = mMonto_mov;
                IF cNatu = 'C' THEN
                    LET mCargo = mMonto_mov;
                    LET mAbono = 0.00;
                ELSE
                    LET mCargo = 0.00 ;
                    LET mAbono = mMonto_mov;	
                END IF;

			--	LET icontador = 1;  
								
                LET cNatu_ant = cNatu;	  
				RETURN cCodRet,dFecha_alt, cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmovcal WITH RESUME;
				

			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '30000';
				RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmov;
			END IF;	
			
        END IF;
		
	
    ELSE

        LET cCodRet = '20000';
        
        RETURN cCodRet,dFecha_alt,cTransacc,cReferencia,cTarjeta, mCargo, mAbono, mSdo_antmov;

    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'AUTOR: Abigail Vasavilbazo Cañedo',
'DESCRIPCION: Procedimiento que obtiene los movimientos en un rango de fechas, con filtros por sucursal, monto',
' y no.empleado',
'VERSION: 20090415.',
'BD: Bdicheq',
'MODIFICACION: RQM 06164 Conceptos Nuevos en Reportes de Movimientos de Depocitos SBC',
'AUTOR: Héctor Manuel Bojórquez Ruelas',
'DESCRIPCION: Se agrega validacion para que cuando sean transacciones de SBC(0250 y 0232) no afecte el saldo',
'VERSION: 20110912',
'BD: bdicheq',
'MODIFICACION: RQM 06164 Se Cambio para que la informacion se regrese oordenada en base al campo num_serial de  la tabla de movimientos',
'              así como tambien que se tomen en cuenta los movimiento scancelados al momento de pintar el saldo de su primer dia de movimientos ',
'AUTOR: Héctor Manuel Bojórquez Ruelas',
'DESCRIPCION: Se agrega validacion para que cuando sean transacciones de SBC(0250 y 0232) no afecte el saldo',
'             Se Cambio para que la informacion se regrese oordenada en base al campo num_serial de  la tabla de movimientos',
'             así como tambien que se tomen en cuenta los movimiento scancelados al momento de pintar el saldo de su primer dia de movimientos',
'VERSION: 20110922',
'BD: bdicheq',
'AUTOR: Jose Angel Gaxiola Gaxiola',
'DESCRIPCION:Se comento parte del codigo del sp_generamovtosfecha, ya que no estaba asignando el saldo correctamente', 
'cuando se trataba de transacciones SBC',
'VERSION: 20111108.';

CREATE PROCEDURE "informix".sp_cancela_tarjetas_efecplus( pcEmpresa  CHAR(3) )
RETURNING CHAR(5)  AS vcCodret1,
          CHAR(5)  AS vcCodret2,
          CHAR(50) AS vcCodret3,
          INTEGER  AS viContador;
    
    DEFINE vcCodret1    CHAR(5);
    DEFINE vcCodret2    CHAR(5);
    DEFINE vcCodret3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viContador   INTEGER;
    DEFINE vComienza    SMALLINT;
    DEFINE viTransacc   SMALLINT;
    
    DEFINE vcCuenta     CHAR(20);
    DEFINE vcTarjeta    CHAR(16);
    DEFINE vdCapVigAcum DECIMAL(18,2);
    DEFINE vdDiasAcum   SMALLINT;
    DEFINE vdPromedio   DECIMAL(18,2);
    DEFINE vsql         CHAR(500);
    DEFINE vstmt        CHAR(250);
    
    LET vcCodret1 = '000';
    LET vcCodret2 = '000';
    LET vcCodret3 = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET viSqlErr  = 0;
    LET viIsamErr = 0;
    LET vcDescErr = '';
    LET viContador = 0;
    LET vComienza  = 0;
    LET viTransacc = 0;
    
    LET vcCuenta     = '';
    LET vcTarjeta    = '';
    LET vdCapVigAcum = 0.00;
    LET vdDiasAcum   = 0;
    LET vdPromedio   = 0.00;
    LET vsql         = '';
    LET vstmt        = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_tarjetas_efecplus.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodret1 = viSqlErr;
            LET vcCodret2 = viIsamErr;
            LET vcCodret3 = vcDescErr;
            IF viTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodret1, vcCodret2, vcCodret3, viContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_tarjetas_efecplus.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasefecplus') THEN
        DROP TABLE ctasefecplus;
    END IF;
    
    CREATE TABLE ctasefecplus( cuenta char(20) not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_ctaefp ON ctasefecplus(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasefecplus.unl DELIMITER ''","'' INSERT INTO ctasefecplus" > /resplogifx/conciliachq/ctasefp.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasefp.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasefecplus;
    
    FOREACH WITH HOLD
        SELECT cuenta 
          INTO vcCuenta
          FROM ctasefecplus
         WHERE cuenta is not null
         
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;
        
        BEGIN WORK;
        LET viTransacc = 1;
         
        FOREACH
            SELECT num_tarjeta
              INTO vcTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pcEmpresa
               AND cuenta = vcCuenta
               AND secuencia > 0
        
            UPDATE bdicheq:"informix".sc_tarjeta
               SET status_tar = 'C'
             WHERE empresa = pcEmpresa
               AND cuenta = vcCuenta
               AND num_tarjeta = vcTarjeta;
               
            UPDATE intercard:"informix".tarjeta
               SET codstatustarjeta = 'CAN'
             WHERE numtarjeta = vcTarjeta;
        END FOREACH;
        
        LET viContador = viContador + 1;
           
        COMMIT WORK;
        LET viTransacc = 0;
        
        LET vcCuenta  = '';
        LET vcTarjeta = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodret1, vcCodret2, vcCodret3, viContador;

END PROCEDURE;