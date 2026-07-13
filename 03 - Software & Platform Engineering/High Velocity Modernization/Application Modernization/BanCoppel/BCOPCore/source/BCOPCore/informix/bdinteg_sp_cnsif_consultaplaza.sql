CREATE PROCEDURE "informix".sp_cnsif_consultaplaza(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)  AS Cod_Retorno,
				          CHAR(3) AS Cod_Plaza,
                          CHAR(40) AS Nom_Plaza;
										
DEFINE iexiste 			INT;
DEFINE cCodRet          CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNomPlaza 	CHAR(40);	
DEFINE cNumPlaza           CHAR(3);	   
DEFINE iCont                 INTEGER;        				
--inicializando variables
LET iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			=  0;	
LET cNomPlaza        = "";
LET cNumPlaza              = "";
LET iCont           = 0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cNumPlaza, cNomPlaza;
		END IF;
	END EXCEPTION;
	  --    SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultaPlaza.out";
	  --    TRACE ON;
    IF 	cID_USUARIOC = '' 	OR
        cID_FUNCIONC = '' 	THEN 
            LET cCodRet = "00054";
            RETURN cCodRet,cNumPlaza, cNomPlaza;
    END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet, cNumPlaza, cNomPlaza;			
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cNumPlaza, cNomPlaza;
        END IF;
    END IF;  

 	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = "00028" THEN 
		RETURN cCodRet, cNumPlaza, cNomPlaza;
	END IF;			

    FOREACH
	   SELECT SKIP pNumRegistro FIRST pRecuperacion plaza, nombre INTO cNumPlaza, cNomPlaza  FROM si_plazas WHERE empresa = '001' AND plaza<>'900' order by plaza
        LET iCont=iCont+1;
        IF cNomPlaza IS NULL THEN
            LET cCodRet = "00105";
        END IF;
	    RETURN cCodRet, cNumPlaza, cNomPlaza with resume;
    END FOREACH;
		
    IF iCont = 0 THEN 
        LET cCodRet = '1001';
        RETURN cCodRet,cNumPlaza, cNomPlaza;
    END IF;
END

END PROCEDURE
DOCUMENT
"Autor :Victor Hugo Sánchez Mendoza",
"FUNCIONAMIENTO:Consulta Plazas CNSIFWEB",
"FECHA : 04-07-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".spconsultarmvtos( psEmpresa CHAR(3), psNumCredito CHAR(20), psCuenta CHAR(12), pdFechaInicial DATE, pdFechaFinal DATE )
	RETURNING CHAR(5) AS CodigoRetorno, CHAR(5) AS Transaccion, MONEY(14,2) AS Monto, CHAR(10) AS FechaMovimiento, CHAR(8) AS HoraMovimiento,
		CHAR(4) AS Sucursal, CHAR(1) AS Reversado, CHAR(16) AS FolioSucursal, CHAR(8) AS Usuario, CHAR(100) AS Nombre;

	-- Se declaran variables de error y de estado de retorno.
	DEFINE iSqlErr          INTEGER;
	DEFINE sCodRet        	CHAR(5);

	-- Se declaran variables de consultas de movimientos.
	DEFINE sTransaccion		CHAR(5);
	DEFINE mMonto			MONEY(14, 2);
	DEFINE dFechaMov		CHAR(10);
	DEFINE sHoraMov			CHAR(8);
	DEFINE sSucursal		CHAR(4);
	DEFINE sReversado		CHAR(1);
	DEFINE sFolioSuc		CHAR(16);
	DEFINE sUsuario			CHAR(8);
	DEFINE sNombre			CHAR(100);

	-- Se asignan valores por defecto a las variables de consultas de movimientos.
	LET sTransaccion 	= '';
	LET mMonto       	= 0.00;
	LET dFechaMov    	= '';
	LET sHoraMov     	= '';
	LET sSucursal    	= '';
	LET sReversado   	= '';
	LET sFolioSuc    	= '';
	LET sUsuario     	= '';
	LET sNombre			= '';

	--SET DEBUG FILE TO  "/informix/SIA/spconsultarmvtos.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION
			SET iSqlErr

			IF iSqlErr <> 0 THEN

				LET sCodRet = iSqlErr;

				RETURN sCodRet, '', '', '', '', '', '', '', '', '';

			END IF;
		END EXCEPTION;

		-- Se validan parámetros de entrada.
		IF NVL( psEmpresa, '' ) = '' OR NVL( pdFechaInicial, '' ) = '' OR NVL( pdFechaFinal, '' ) = ''
			OR ( NVL( psNumCredito, '' ) = '' AND NVL( psCuenta, '' ) = '' ) THEN

			LET sCodRet = '00001';

			RETURN sCodRet, '', '', '', '', '', '', '', '', '';

		END IF;

		IF ( psCuenta = '' ) THEN -- Consulta de movimientos de cuenta de crédito.

			FOREACH -- Se consulta la sd_movdia.
				SELECT a.transacc_suc, a.monto, TO_CHAR( a.fecha_mov, '%d/%m/%Y' ), a.hora_mov::DATETIME HOUR TO SECOND, a.sucursal, a.reversado, a.folio_suc,
						a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicred:sd_movdia a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					LEFT OUTER JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.num_credito = TRIM( psNumCredito )
					AND a.fecha_mov BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.secuencia IS NOT NULL
					AND a.hora_mov IS NOT NULL
					AND a.sucursal IS NOT NULL
					AND a.transacc_suc <> '0000'
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

			FOREACH -- Se Consulta la sd_movhis.
				SELECT a.transacc_suc, a.monto, TO_CHAR( a.fecha_mov, '%d/%m/%Y' ), a.hora_mov::DATETIME HOUR TO SECOND, a.sucursal, a.reversado, a.folio_suc,
						a.usuario AS empleado, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicred:sd_movhis a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					LEFT OUTER JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.num_credito = TRIM( psNumCredito )
					AND a.fecha_mov BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.secuencia IS NOT NULL
					AND a.hora_mov IS NOT NULL
					AND a.sucursal IS NOT NULL
					AND a.transacc_suc <> '0000'
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

		ELSE -- Consulta de movimientos de cuenta de débito.

			FOREACH -- Se consultan los movimientos en la sc_movdia.
				SELECT { +INDEX( bdicheq:sc_movdia idx_movdiacon ) } a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ),
						a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad, a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movdia a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.transacc_suc <> '0000'
					AND a.monto_tot IS NOT NULL
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

			FOREACH -- Se consultan los movimientos en la sc_movhis.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.transacc_suc <> '0000'
					AND a.monto_tot IS NOT NULL
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

			FOREACH -- Se consultan los movimientos en la sc_movhis_old.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis_old a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.transacc_suc <> '0000'
					AND a.monto_tot IS NOT NULL
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH

			FOREACH -- Se consultan los movimientos en la sc_movhis_old2.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis_old2 a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.transacc_suc <> '0000'
					AND a.monto_tot IS NOT NULL
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH

			FOREACH -- Se consultan los movimientos en la sc_movhis_old3.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis_old3 a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.monto_tot IS NOT NULL
					AND a.transacc_suc <> '0000'
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

			FOREACH -- Se consultan los movimientos en la sc_movhis_old4.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis_old4 a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.monto_tot IS NOT NULL
					AND a.transacc_suc <> '0000'
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

			FOREACH -- Se consultan los movimientos en la sc_movhis_old5.
				SELECT a.transacc_suc, a.monto_tot, TO_CHAR( a.fech_alt, '%d/%m/%Y' ), a.fech_hor::DATETIME HOUR TO SECOND, a.sucursal, a.cancelad,
						a.folio_suc, a.usuario, b.nombre
					INTO sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre
				FROM bdicheq:sc_movhis_old5 a
					JOIN bdinteg:si_ejecut b ON ( b.ejecutivo = a.usuario )
					JOIN bdinteg:si_transacc c ON ( c.numero = a.transacc_suc )
				WHERE a.empresa = psEmpresa
					AND a.cuenta = TRIM( psCuenta )
					AND a.fech_alt BETWEEN pdFechaInicial AND pdFechaFinal
					AND a.monto_tot IS NOT NULL
					AND a.transacc_suc <> '0000'
					AND c.se_emite_edocta = 'S'

				LET sCodRet = '00000';

				RETURN sCodRet,
					sTransaccion, mMonto, dFechaMov, sHoraMov, sSucursal, sReversado, sFolioSuc, sUsuario, sNombre WITH RESUME;

			END FOREACH;

		END IF;

	END
END PROCEDURE
DOCUMENT
'CREADO:		Vladimir Félix Gálvez.',
'FECHA:			30 de abril de 2010.',
'DESCRIPCIÓN:	Consulta los movimientos ya sea de la cuenta o de un número de crédito',
'				en un rango de fechas.',
'RETORNO:		00000 Datos obtenidos satisfactoriamente',
'				00001 Parametros insuficientes.',
'MODIFICÓ:		Javier Chávez.',
'FECHA:			01/06/2010',
'MODIFICACIÓN:	Se dió un formato a la fecha que retorna.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			15 de Diciembre de 2010.',
'DESCRIPCIÓN:	Se agregan las consultas de las tablas bdicheq:sc_movdia, bdicheq:sc_movhis_old, bdicheq:sc_movhis_old2, bdicheq:sc_movhis_old3',
'				en consulta de movimientos de cuentas de débito.',
'				Se agrega bdicred:sd_movdia en consulta de movimientos de cuentas de crédito.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Viernes, 07 de Enero de 2011.',
'DESCRIPCIÓN:	Se agrega rango de consulta de fecha en las consultas de movimientos diarios.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Miércoles, 26 de Enero de 2011.',
'DESCRIPCIÓN:	Se agrega filtro en consultas de movimientos de la bdicheq para no permitir montos nulos.',

'MODIFICÓ:		Bernardo Beltrán Herrera.',
'FECHA:		Miércoles, 24 de Octubre de 2012.',
'DESCRIPCIÓN:	Se agrega búsqueda para las tablas sc_movhis_old4 y sc_movhis_old5.'
;

CREATE PROCEDURE "informix".sp_obtparamsorteo(pEmpresa char(3), pSucursal char(4) )
RETURNING CHAR(5), CHAR(5), CHAR(5), SMALLINT, SMALLINT, SMALLINT, SMALLINT;

DEFINE  SQL_ERR                  INTEGER;
DEFINE  ISAM_ERR                 INTEGER;
DEFINE  ERROR_INFO           CHAR(80);
DEFINE  P_COD_RET             CHAR(5);
DEFINE  cCveSorteoNormal   CHAR(5);
DEFINE cCveSorteoInst           CHAR(5);
DEFINE  iFlagSortNormal     SMALLINT;
DEFINE  iFlagImpNormal     SMALLINT;
DEFINE  iFlagSortInst            SMALLINT;
DEFINE  iFlagImpInst            SMALLINT;


LET SQL_ERR                 = 0;
LET ISAM_ERR                = 0;
LET ERROR_INFO          = '';
LET P_COD_RET            = '';
LET cCveSorteoNormal  = '';
LET cCveSorteoInst         = '';
LET iFlagSortNormal       = 0;
LET iFlagImpNormal        = 0;
LET iFlagSortInst               = 0;
LET iFlagImpInst               = 0;

BEGIN
 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      RETURN P_COD_RET,P_COD_RET,P_COD_RET, 0, 0, 0, 0;
 END EXCEPTION;
 
 --Set debug file to "/respaldosbd/saul/sp_obtparamsorteo.out";
 --Trace on;
   
   LET P_COD_RET = '00000';

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;

    IF pEmpresa IS NULL OR pEmpresa  = "" OR pSucursal IS NULL OR pSucursal  = ""  THEN
        LET P_COD_RET = "00001";
    END IF;

    IF P_COD_RET = "00000" THEN
 
       SELECT cve_sorteo_normal, cve_sorteo_inst, flag_sorteo_normal, flag_imprime_normal, flag_sorteo_inst, flag_imprime_inst 
       INTO      cCveSorteoNormal, cCveSorteoInst, iFlagSortNormal, iFlagImpNormal, iFlagSortInst, iFlagImpInst 
       FROM    si_sucursales_sorteo 
       WHERE empresa = pEmpresa
       AND       sucursal = pSucursal; 
    
       IF cCveSorteoNormal IS NULL OR cCveSorteoNormal =''  OR cCveSorteoInst IS NULL OR cCveSorteoInst ='' THEN
           LET P_COD_RET = "00002";
      END IF;    

    END IF;

     RETURN P_COD_RET, cCveSorteoNormal, cCveSorteoInst, iFlagSortNormal, iFlagImpNormal, iFlagSortInst, iFlagImpInst;   

END;
END PROCEDURE             
DOCUMENT
"Descripción: Procedimiento que obtiene los parametros del sorteo",
"BD: bdinteg",
"Fecha: 15-Octubre-2010",
"Autor: Saúl Ivanhoe Valdespino Hernández";

CREATE PROCEDURE "informix".sp_generaarchivoadicionalesc2(pempresa CHAR(3), pFechaAct DATE)
RETURNING
     CHAR(6);
	 
--DEFINICION DE VARIABLES
--CLIENTE
DEFINE vClave CHAR(1); --DEFAULT 'C'
DEFINE vcaja SMALLINT;
DEFINE varea CHAR(1); --DEFAULT ''
DEFINE vcliente_ref CHAR(20); --#TITULAR CHECAR QUE SEA EL NUMERO DEL TITULAR
DEFINE vnombre1 CHAR(26); --DEFAULT BLANCO
DEFINE vnombre2 CHAR(26); --DEFAULT BLANCO
DEFINE vapell_paterno CHAR(26); --DEFAULT BLANCO
DEFINE vapell_materno CHAR(26); --DEFAULT BLANCO
DEFINE vcurp CHAR(18);
DEFINE vclaveelector CHAR(18); --DEFAULT BLANCO
DEFINE vclaveidentificacion CHAR(2); --DEFAULT BLANCO
DEFINE videntificacion CHAR(8); --DEFAULT BLANCO
DEFINE vciudad SMALLINT; --DEFAULT 0
DEFINE vcolonia INTEGER; --DEFAULT 0
DEFINE vcalle INTEGER; --DEFAULT 0
DEFINE snumerocasa INTEGER; --DEFAULT 0
DEFINE vdeptointerior CHAR(4); --DEFAULT BLANCO
DEFINE vrumbo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplemento CHAR(80); --DEFAULT BLANCO
DEFINE ventrecalles CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhc SMALLINT; --DEFAULT 0
DEFINE vuhcmanzana SMALLINT; --DEFAULT 0
DEFINE vuhcotros SMALLINT; --DEFAULT 0
DEFINE vuhcandador SMALLINT; --DEFAULT 0
DEFINE vuhcetapa SMALLINT; --DEFAULT 0
DEFINE vuhclote  SMALLINT; --DEFAULT 0
DEFINE vuhcedificio SMALLINT; --DEFAULT 0
DEFINE vuhcentrada SMALLINT; --DEFAULT 0
DEFINE vtelefono INT8; --DEFAULT 0
DEFINE vtelefonocelular INT8; --DEFAULT 0
DEFINE vcasapropia CHAR(1);
DEFINE vniptitular CHAR(7); --DEFAULT BLANCO
DEFINE vnipadicional CHAR(9); --DEFAULT A
DEFINE vsexo CHAR(1); --DEFAULT BLANCO
DEFINE vestadocivil CHAR(1); --DEFAULT BLANCO
DEFINE cfechanac CHAR(10);
DEFINE cfechadesdecuandovive CHAR(10);
DEFINE vpersonasvivenendomicilio INTEGER; --DEFAULT 0
DEFINE vescolaridad CHAR(1); --DEFAULT BLANCO
DEFINE vtiposueldo CHAR(1); --DEFAULT BLANCO
DEFINE vnumerodependientes SMALLINT; --DEFAULT 0
DEFINE vpersonastrabajan SMALLINT;
DEFINE vlimitecredito SMALLINT; --DEFAULT 0
DEFINE vingresomensual SMALLINT; --DEFAULT 0
DEFINE vsituacionespecial CHAR(1); --DEFAULT BLANCO
DEFINE vcausasituacionespecial SMALLINT; --DEFAULT 0
DEFINE vclaveautrechaza CHAR(1); --DEFAULT BLANCO
DEFINE vaceptadosupervisadorechazado CHAR(1); --DEFAULT BLANCO
DEFINE vclientenuevo CHAR(1); --DEFAULT BLANCO
DEFINE vcreditojoven CHAR(1); --DEFAULT BLANCO
DEFINE vlugartrabajo CHAR(20); --DEFAULT BLANCO
DEFINE vciudadtrabajo SMALLINT; --DEFAULT 0
DEFINE vcoloniatrabajo  SMALLINT; --DEFAULT 0
DEFINE vcalletrabajo INTEGER; --DEFAULT 0
DEFINE snumerocasatrabajo INTEGER; --DEFAULT 0
DEFINE vdeptoointeriortrabajo CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementotrabajo CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallestrabajo CHAR(40); --DEFAULT BLANCO
DEFINE vflaguht SMALLINT; --DEFAULT 0
DEFINE vuhtmanzana SMALLINT; --DEFAULT 0
DEFINE vuhtotros SMALLINT; --DEFAULT 0
DEFINE vuhtandador SMALLINT; --DEFAULT 0
DEFINE vuhtetapa SMALLINT; --DEFAULT 0
DEFINE vuhtlote SMALLINT; --DEFAULT 0
DEFINE vuhtedificio SMALLINT; --DEFAULT 0
DEFINE vuhtentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajo INT8; --DEFAULT 0
DEFINE vextensiontrabajo INTEGER; --DEFAULT 0
DEFINE vpuesto CHAR(1); --DEFAULT BLANCO
DEFINE vopcionpuesto SMALLINT; --DEFAULT 0
DEFINE cfechaantiguedtrab CHAR(10);
--CONYUGE
DEFINE vclienteconyuge CHAR(20); --DEFAULT 0
DEFINE vnombreunoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE cSexoConyuge CHAR(1); --DEFAULT BLANCO
DEFINE vlugartrabajoconyuge CHAR(20); --DEFAULT BLANCO
DEFINE vciudadconyuge SMALLINT; --DEFAULT 0
DEFINE vcoloniaconyuge INTEGER; --DEFAULT 0
DEFINE vcalletrabajoconyuge INTEGER; --DEFAULT 0
DEFINE snumerocasaconyugue INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorconyuge CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajoconyuge CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoconyuge CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesconyuge CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhy SMALLINT; --DEFAULT 0
DEFINE vuhymanzana SMALLINT; --DEFAULT 0
DEFINE vuhyotros SMALLINT; --DEFAULT 0
DEFINE vuhyandador  SMALLINT; --DEFAULT 0
DEFINE vuhyetapa SMALLINT; --DEFAULT 0 
DEFINE vuhylote SMALLINT; --DEFAULT 0
DEFINE vuhyedificio SMALLINT; --DEFAULT 0
DEFINE vuhyentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajoconyuge INT8; --DEFAULT 0
DEFINE vtelefonocelularconyuge INT8; --DEFAULT 0
DEFINE vclaveconyugefamilia CHAR (1);
--REFERENCIA 1
DEFINE vclientereferencia CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia CHAR(1); --DEFAULT BLANCO
DEFINE vciudadreferencia SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia INTEGER; --DEFAULT 0
DEFINE vcallereferencia INTEGER; --DEFAULT 0
DEFINE snumerocasaref INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia1 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana SMALLINT; --DEFAULT 0
DEFINE vuhrotros SMALLINT; --DEFAULT 0
DEFINE vuhrandador SMALLINT; --DEFAULT 0
DEFINE vuhretapa SMALLINT; --DEFAULT 0
DEFINE vuhrlote SMALLINT; --DEFAULT 0
DEFINE vuhredificio SMALLINT; --DEFAULT 0
DEFINE vuhrentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia INT8; --DEFAULT 0       
DEFINE vtelefonocelularreferencia INT8; --DEFAULT 0
DEFINE vclavereferencia1 CHAR(1); --DEFAULT BLANCO
--REFERENCIA 2
DEFINE vclientereferencia2 CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE vciudadreferencia2 SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia2 INTEGER; --DEFAULT 0
DEFINE vcallereferencia2 INTEGER; --DEFAULT 0
DEFINE snumerocasaref2 INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia2 CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia2 CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia2 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr2 SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana2 SMALLINT; --DEFAULT 0
DEFINE vuhrotros2 SMALLINT; --DEFAULT 0
DEFINE vuhrandador2 SMALLINT; --DEFAULT 0
DEFINE vuhretapa2 SMALLINT; --DEFAULT 0
DEFINE vuhrlote2 SMALLINT; --DEFAULT 0
DEFINE vuhredificio2 SMALLINT; --DEFAULT 0
DEFINE vuhrentrada2 SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia2 INT8; --DEFAULT 0
DEFINE vtelefonocelularreferencia2 INT8; --DEFAULT 0
DEFINE vclavereferencia2 CHAR(1); --DEFAULT BLANCO
------
DEFINE vreferencia2 INTEGER; --DEFAULT 0
DEFINE vreferencia3 INTEGER; --DEFAULT 0
DEFINE vmarcadatosin CHAR(1); --DEFAULT BLANCO
DEFINE vtiporeposicion SMALLINT; --DEFAULT 2
DEFINE vreposicion INTEGER; --DEFAULT 0
DEFINE vflagentregotarjeta CHAR(1); --DEFAULT BLANCO
DEFINE vefectuo INTEGER;
DEFINE vtiendafolio SMALLINT;
DEFINE vfolio CHAR(20); --DEFAULT 0
DEFINE cfechaaltacte CHAR (10);
DEFINE vflagnoreconocehuella CHAR(1); --DEFAULT BLANCO
DEFINE vfoliotienda INTEGER; --DEFAULT 0
DEFINE vrfc CHAR(13); --DEFAULT BLANCO
DEFINE vcveburo CHAR(2); --DEFAULT BLANCO
DEFINE vfolioaut CHAR(4); --DEFAULT BLANCO
DEFINE vfolioconsulta CHAR(9); --DEFAULT BLANCO
DEFINE vfolioconcir CHAR(10); --DEFAULT BLANCO
DEFINE vnegocio SMALLINT; --DEFAULT 0
DEFINE vsubnegocio SMALLINT; --DEFAULT 0
DEFINE vempleadoautorizo INTEGER; --DEFAULT 0
DEFINE vtipo CHAR(1); --DEFAULT BLANCO
DEFINE cfechamovto CHAR (19); 
DEFINE vnumerosolicituddecredito CHAR(20); --DEFAULT 0
DEFINE vnumcte CHAR(20); --DEFAULT BLANCO
DEFINE vtiendafolioanterior SMALLINT;
DEFINE vfolioanterior INTEGER; --DEFAULT 0
DEFINE vclaveproducto SMALLINT; --DEFAULT 0
DEFINE vflagactualizacion INTEGER; --DEFAULT 0
--------
DEFINE vSistsegsocial SMALLINT; --DEFAULT 0
DEFINE vTiposueldoext SMALLINT; --DEFAULT 0
DEFINE vNumempleados SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuesto SMALLINT; --DEFAULT 0
DEFINE vPuestoext SMALLINT; --DEFAULT 0
DEFINE vOpcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vNumempleadosext SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vTipoOrigen CHAR(1); --DEFAULT BLANCO
DEFINE vTipoProducto CHAR(5); --DEFAULT BLANCO
--Modificacion Campos nuevos
DEFINE iEmpleadoSubCob INTEGER; --DEFAULT 0
DEFINE sFlagCapHuella SMALLINT; --DEFAULT 0
DEFINE cMarcarConsultado CHAR(2); --DEFAULT BLANCO
DEFINE sFlagTestParametrico SMALLINT; --DEFAULT 0
DEFINE sFlagCapCobranza SMALLINT; --DEFAULT 0
DEFINE iEmpleadoGteAutori INTEGER; --DEFAULT 0
DEFINE cFlagConsBuro CHAR(2); --DEFAULT BLANCO
DEFINE cBuroPilotoTestig CHAR(1); --DEFAULT BLANCO
DEFINE cNacionalidad CHAR(3); --DEFAULT BLANCO
DEFINE cNoFm3 CHAR(18); --DEFAULT BLANCO
DEFINE cEmail CHAR(60); --DEFAULT BLANCO
DEFINE cApellCasada CHAR(26); --DEFAULT BLANCO
DEFINE cPais CHAR(3); --DEFAULT BLANCO
DEFINE cNoIMSS CHAR(12); --DEFAULT BLANCO
DEFINE cEstado CHAR(3); --DEFAULT BLANCO
DEFINE cDelegMunicip CHAR(3); --DEFAULT BLANCO
DEFINE cNumInterior CHAR(4); --DEFAULT BLANCO
DEFINE sPropNegocio SMALLINT; --DEFAULT 0
DEFINE sParCelulares SMALLINT; --DEFAULT 0 
DEFINE sParAltoRiesgo SMALLINT; --DEFAULT 0
DEFINE sParPrestamo SMALLINT; --DEFAULT 0
DEFINE cModeloCel CHAR(1); --DEFAULT BLANCO
DEFINE cFechaConsBuro CHAR(10); --DEFAULT 1900/01/01
DEFINE iMontoIngMensual INTEGER; --DEFAULT 0
DEFINE iCapSistematicabono INTEGER; --DEFAULT 0
DEFINE iTopeAbonoCoppel INTEGER; --DEFAULT 0
DEFINE iLineaCrediTope INTEGER; --DEFAULT 0
DEFINE iCapMaximaAbono INTEGER; --DEFAULT 0
DEFINE iCapRealAbono INTEGER; --DEFAULT 0
DEFINE iLineaCredReal INTEGER; --DEFAULT 0 
DEFINE iCompromisosSic INTEGER; --DEFAULT 0
DEFINE iFlagLineaCredEsp INTEGER; --DEFAULT 0
DEFINE cClienteConyugebcpl CHAR(20); --DEFAULT BLANCO
DEFINE cClienteReferencia1bcpl CHAR(20); --DEFAULT BLANCO
DEFINE cClienteReferencia2bcpl CHAR(20); --DEFAULT BLANCO

--OTRAS VARIABLES
DEFINE cFolioSucursal CHAR(4);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
--DEFINE vfechanacimiento DATE; 
--DEFINE iAniosHabita INTEGER;
DEFINE vfechaaltacliente DATE;
DEFINE vfechamovto DATE;
--DEFINE vcasa INTEGER;
--DEFINE vcasatrabajo INTEGER; --INT
--DEFINE vcasatrabajoconyuge CHAR(10);
--DEFINE vcasareferencia CHAR(10);
--DEFINE vcasareferencia2 CHAR(10);
--DEFINE cUnidadHabit CHAR(1);
--DEFINE vTipo_Dir CHAR(2);
DEFINE vFecha_Hoy DATE;
DEFINE vNombre CHAR(104);
--DEFINE vEdad INTEGER;
DEFINE vsSQL LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(6);
DEFINE dFechaAlta DATE;
--DEFINE cValor CHAR(20);
--DEFINE iIngreso INTEGER;
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
--DEFINE dEvaluacion1 DECIMAL(5,2);
--DEFINE dEvaluacion2 DECIMAL(5,2);
DEFINE iSecuencia INTEGER;
DEFINE cMarcaHit CHAR(2);
--DEFINE iElemento INTEGER;
--DEFINE vfolio2 CHAR(20);
--DEFINE dfechasolicitud DATE;
--DEFINE vtiendafolio2 CHAR(5);
--DEFINE dFechaResidencia date;
--DEFINE dFechaLaborando date;
DEFINE iSecAdic INTEGER;
DEFINE iCuentaRegistros INTEGER;

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET vClave = 'C'; --DEFAULT C
LET vcaja = 0; --dbs-17/09/2012
LET varea = ''; --DEFAULT BLANCO --dsb-17/09/2012
LET vcliente_ref = '0'; --Cliente Coppel --INT
LET vnombre1 = ''; --DEFAULT BLANCO
LET vnombre2 = ''; --DEFAULT BLANCO
LET vapell_paterno = ''; --DEFAULT BLANCO
LET vapell_materno = ''; --DEFAULT BLANCO
LET vcurp = ''; --DEFAULT BLANCO
LET vclaveelector = ''; --DEFAULT BLANCO
LET vclaveidentificacion = ''; --DEFAULT BLANCO
LET videntificacion = ''; --DEFAULT BLANCO
LET vciudad = 0; --DEFAULT 0
LET vcolonia = 0; --DEFAULT 0
LET vcalle = 0; --DEFAULT 0
LET snumerocasa = 0; --DEFAULT 0
LET vdeptointerior = ''; --DEFAULT BLANCO
LET vrumbo = ''; --DEFAULT BLANCO
LET vcomplemento = ''; --DEFAULT BLANCO
LET ventrecalles = ''; --DEFAULT BLANCO
LET vflaguhc = 0; --DEFAULT 0
LET vuhcmanzana = 0; --DEFAULT 0
LET vuhcotros = 0; --DEFAULT 0
LET vuhcandador = 0; --DEFAULT 0
LET vuhcetapa = 0; --DEFAULT 0
LET vuhclote  = 0; --DEFAULT 0
LET vuhcedificio = 0; --DEFAULT 0
LET vuhcentrada = 0; --DEFAULT 0
LET vtelefono = 0; --DEFAULT 0
LET vtelefonocelular = 0; --DEFAULT 0
LET vcasapropia = ''; --DEFAULT BLANCO
LET vniptitular = ''; --DEFAULT BLANCO
LET vnipadicional = 'A'; --DEFAULT A --dsb-17/09/2012
LET vsexo = ''; --DEFAULT BLANCO
LET vestadocivil = ''; --DEFAULT BLANCO
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0; --DEFAULT 0
LET vescolaridad = ''; --DEFAULT BLANCO
LET vtiposueldo = ''; --DEFAULT BLANCO
LET vnumerodependientes = 0; --DEFAULT 0
LET vpersonastrabajan = 0; --DEFAULT 0
LET vlimitecredito = 0; --DEFAULT 0 
LET vingresomensual = 0; --DEFAULT 0
LET vsituacionespecial = ''; --DEFAULT BLANCO
LET vcausasituacionespecial = 0; --DEFAULT 0
LET vclaveautrechaza = ''; --DEFAULT BLANCO
LET vaceptadosupervisadorechazado = ''; --DEFAULT BLANCO
LET vclientenuevo = ''; --DEFAULT BLANCO
LET vcreditojoven = ''; --DEFAULT BLANCO
LET vlugartrabajo = ''; --DEFAULT BLANCO
LET vciudadtrabajo = 0; --DEFAULT 0
LET vcoloniatrabajo  = 0; --DEFAULT 0
LET vcalletrabajo  = 0; --DEFAULT 0
LET snumerocasatrabajo = 0; --DEFAULT 0
LET vdeptoointeriortrabajo = ''; --DEFAULT BLANCO
LET vrumbotrabajo = ''; --DEFAULT BLANCO
LET vcomplementotrabajo = ''; --DEFAULT BLANCO
LET ventrecallestrabajo = ''; --DEFAULT BLANCO
LET vflaguht = 0; --DEFAULT 0
LET vuhtmanzana = 0; --DEFAULT 0
LET vuhtotros = 0; --DEFAULT 0
LET vuhtandador = 0; --DEFAULT 0
LET vuhtetapa = 0; --DEFAULT 0
LET vuhtlote = 0; --DEFAULT 0
LET vuhtedificio = 0; --DEFAULT 0
LET vuhtentrada = 0; --DEFAULT 0
LET vtelefonotrabajo = 0; --DEFAULT 0
LET vextensiontrabajo = 0; --DEFAULT 0
LET vpuesto = ''; --DEFAULT BLANCO
LET vopcionpuesto = 0; --DEFAULT 0
LET cfechaantiguedtrab = '1900/01/01'; 
--CONYUGE
LET vclienteconyuge = '0'; --DEFAULT 0
LET vnombreunoconyuge = ''; --DEFAULT BLANCO
LET vnombredosconyuge = ''; --DEFAULT BLANCO
LET vapellidopaternoconyuge = ''; --DEFAULT BLANCO
LET vapellidomaternoconyuge = ''; --DEFAULT BLANCO
LET cSexoConyuge = ''; --DEFAULT BLANCO
LET vlugartrabajoconyuge = ''; --DEFAULT BLANCO
LET vciudadconyuge = 0; --DEFAULT 0
LET vcoloniaconyuge = 0; --DEFAULT 0
LET vcalletrabajoconyuge = 0; --DEFAULT 0
LET snumerocasaconyugue = 0; --DEFAULT 0
LET vdeptoointeriorconyuge = ''; --DEFAULT BLANCO
LET vrumbotrabajoconyuge = ''; --DEFAULT BLANCO
LET vcomplementoconyuge = ''; --DEFAULT BLANCO
LET ventrecallesconyuge = ''; --DEFAULT BLANCO
LET vflaguhy = 0; --DEFAULT 0
LET vuhymanzana = 0; --DEFAULT 0
LET vuhyotros = 0; --DEFAULT 0
LET vuhyandador  = 0; --DEFAULT 0
LET vuhyetapa = 0; --DEFAULT 0
LET vuhylote = 0; --DEFAULT 0
LET vuhyedificio = 0; --DEFAULT 0
LET vuhyentrada = 0; --DEFAULT 0
LET vtelefonotrabajoconyuge = 0; --DEFAULT 0
LET vtelefonocelularconyuge = 0; --DEFAULT 0
LET vclaveconyugefamilia = ''; --DEFAULT BLANCO
--REFERENCIA 1
LET vclientereferencia = '0'; --DEFAULT 0
LET vnombreunoreferencia = ''; --DEFAULT BLANCO
LET vnombredosreferencia = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia = ''; --DEFAULT BLANCO
LET cSexoReferencia = ''; --DEFAULT BLANCO
LET vciudadreferencia = 0; --DEFAULT 0
LET vcoloniareferencia = 0; --DEFAULT 0
LET vcallereferencia = 0; --DEFAULT 0
LET snumerocasaref = 0; --DEFAULT 0
LET vdeptoointeriorreferencia = ''; --DEFAULT BLANCO
LET vrumboreferencia = ''; --DEFAULT BLANCO
LET vcomplementoreferencia = ''; --DEFAULT BLANCO
LET ventrecallesreferencia1 = ''; --DEFAULT BLANCO
LET vflaguhr = 0; --DEFAULT 0
LET vuhrmanzana = 0 ; --DEFAULT 0
LET vuhrotros = 0 ; --DEFAULT 0
LET vuhrandador = 0; --DEFAULT 0
LET vuhretapa = 0; --DEFAULT 0
LET vuhrlote = 0; --DEFAULT 0
LET vuhredificio = 0; --DEFAULT 0
LET vuhrentrada = 0; --DEFAULT 0
LET vtelefonoreferencia = 0; --DEFAULT 0   
LET vtelefonocelularreferencia = 0; --DEFAULT 0
LET vclavereferencia1 = ''; --DEFAULT BLANCO
--REFERENCIA 2
LET vclientereferencia2 = '0'; --DEFAULT 0
LET vnombreunoreferencia2 = ''; --DEFAULT BLANCO
LET vnombredosreferencia2 = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia2 = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia2 = ''; --DEFAULT BLANCO
LET cSexoReferencia2 = ''; --DEFAULT BLANCO
LET vciudadreferencia2 = 0; --DEFAULT 0 
LET vcoloniareferencia2 = 0; --DEFAULT 0
LET vcallereferencia2 = 0; --DEFAULT 0
LET snumerocasaref2 = 0; --DEFAULT 0
LET vdeptoointeriorreferencia2 = ''; --DEFAULT BLANCO
LET vrumboreferencia2 = ''; --DEFAULT BLANCO
LET vcomplementoreferencia2 = ''; --DEFAULT BLANCO
LET ventrecallesreferencia2 = ''; --DEFAULT BLANCO
LET vflaguhr2 = 0; --DEFAULT 0 
LET vuhrmanzana2 = 0; --DEFAULT 0
LET vuhrotros2 = 0; --DEFAULT 0
LET vuhrandador2 = 0; --DEFAULT 0
LET vuhretapa2 = 0; --DEFAULT 0
LET vuhrlote2 = 0; --DEFAULT 0
LET vuhredificio2 = 0; --DEFAULT 0
LET vuhrentrada2 = 0; --DEFAULT 0
LET vtelefonoreferencia2 = 0; --DEFAULT 0
LET vtelefonocelularreferencia2 = 0; --DEFAULT 0
LET vclavereferencia2 = ''; --DEFAULT BLANCO
------
LET vreferencia2 = 0; --DEFAULT 0
LET vreferencia3 = 0; --DEFAULT 0
LET vmarcadatosin = ''; --DEFAULT BLANCO
LET vtiporeposicion = 2; --DEFAULT 2 --dsb-17/09/2012
LET vreposicion = 0; --DEFAULT 0
LET vflagentregotarjeta = 'A'; --DEFAULT BLANCO --dsb-17/09/2012
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0'; --DEFAULT 0
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = ''; --DEFAULT BLANCO
LET vfoliotienda = 0; --DEFAULT 0
LET vrfc = ''; 
LET vcveburo = ''; --DEFAULT BLANCO
LET vfolioaut = ''; --DEFAULT BLANCO
LET vfolioconsulta = ''; --DEFAULT BLANCO
LET vfolioconcir = ''; --DEFAULT BLANCO
LET vnegocio = 0; --DEFAULT 0
LET vsubnegocio = 0; --DEFAULT 0
LET vempleadoautorizo = 0; --DEFAULT 0
LET vtipo = ''; --DEFAULT BLANCO
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '0'; --DEFAULT 0
LET vnumcte = '';
LET vtiendafolioanterior = 0; --DEFAULT 0
LET vfolioanterior = 0; --DEFAULT 0
LET vclaveproducto = 0; --6500
LET vflagactualizacion = 0; --DEFAULT 0
--------
LET vSistsegsocial = 0; --DEFAULT 0
LET vTiposueldoext = 0; --DEFAULT 0
LET vNumempleados = 0; --DEFAULT 0
LET vSubopcionpuesto = 0; --DEFAULT 0
LET vPuestoext = 0; --DEFAULT 0
LET vOpcionpuestoext = 0; --DEFAULT 0
LET vNumempleadosext = 0; --DEFAULT 0
LET vSubopcionpuestoext = 0; --DEFAULT 0
LET vTipoOrigen = ''; --DEFAULT BLANCO
LET vTipoProducto = '01000'; --DEFAULT BLANCO
--Modificacion Campos nuevos
LET iEmpleadoSubCob = 0; --DEFAULT 0
LET sFlagCapHuella = 0; --DEFAULT 0
LET cMarcarConsultado = ''; --DEFAULT BLANCO
LET sFlagTestParametrico = 0; --DEFAULT 0
LET sFlagCapCobranza = 0; --DEFAULT 0
LET iEmpleadoGteAutori = 0; --DEFAULT 0
LET cFlagConsBuro = ''; --DEFAULT BLANCO
LET cBuroPilotoTestig = ''; --DEFAULT BLANCO
LET cNacionalidad = ''; --DEFAULT BLANCO
LET cNoFm3 = ''; --DEFAULT BLANCO
LET cEmail = ''; --DEFAULT BLANCO
LET cApellCasada = ''; --DEFAULT BLANCO
LET cPais = ''; --DEFAULT BLANCO
LET cNoIMSS = ''; --DEFAULT BLANCO
LET cEstado = ''; --DEFAULT BLANCO
LET cDelegMunicip = ''; --DEFAULT BLANCO
LET cNumInterior = ''; --DEFAULT BLANCO
LET sPropNegocio = 0; --DEFAULT 0
LET sParCelulares = 0; --DEFAULT 0 
LET sParAltoRiesgo = 0; --DEFAULT 0
LET sParPrestamo = 0; --DEFAULT 0
LET cModeloCel = ''; --DEFAULT BLANCO
LET cFechaConsBuro = '1900/01/01';
LET iMontoIngMensual = 0; --DEFAULT 0
LET iCapSistematicabono = 0; --DEFAULT 0
LET iTopeAbonoCoppel = 0; --DEFAULT 0
LET iLineaCrediTope = 0; --DEFAULT 0
LET iCapMaximaAbono = 0; --DEFAULT 0
LET iCapRealAbono = 0; --DEFAULT 0
LET iLineaCredReal = 0; --DEFAULT 0
LET iCompromisosSic = 0; --DEFAULT 0
LET iFlagLineaCredEsp = 0; --DEFAULT 0
LET cClienteConyugebcpl = ''; --DEFAULT BLANCO
LET cClienteReferencia1bcpl = ''; --DEFAULT BLANCO
LET cClienteReferencia2bcpl = ''; --DEFAULT BLANCO

--OTRAS VARIABLES
LET cFolioSucursal = '820'; --DSB-17/09/2012
LET vHora = '';
--LET vfechanacimiento = DATE(1); 
--LET iAniosHabita = 0;
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
--LET vcasa = 0;
--LET vcasatrabajo = 0; --INT
--LET vcasatrabajoconyuge = '';
--LET vcasareferencia = '';
--LET vcasareferencia2 = '';
--LET cUnidadHabit = '';
--LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
--LET vEdad = 0;
LET vsSQL = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
--LET cValor = '';
--LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
--LET dEvaluacion1 = 0;
--LET dEvaluacion2 = 0;
LET iSecuencia = 0;
LET cMarcaHit = '';
--LET iElemento = 0;
--LET vfolio2 = '';
--LET dfechasolicitud = date(1);
--LET vtiendafolio2 = '';
LET iSecAdic = 0;
LET iCuentaRegistros = 0;

--SET DEBUG FILE TO '/tmp/sp_GeneraArchivoAdicionalesC2.out';
--TRACE ON;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		SET DEBUG FILE TO '/RESPALDOS/sp_GeneraArchivoAdicionalesC2.out';
		TRACE ON;
            	LET vnumerosolicituddecredito = vnumerosolicituddecredito;
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN 
	
		SELECT fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas;
	
		IF vFecha_Hoy = mdy(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002';
			LET iCuentaRegistros = 2;
		ELSE	
			---GENERAR ARCHIVO ADICIONAL PARA CLAVE "C"
			FOREACH
			    --dsb-17/09/2012
				/*SELECT numctebanco, numctecoppel, numtarjeta, secuencia, fecha
				INTO vnumcte, vcliente_ref, vnipadicional, iSecAdic, vfechaaltacliente
				FROM bditarjcop:"informix".detallerepadic
				WHERE secuencia > 0 AND tipocliente = 'A' AND fecha = pFechaAct*/
				SELECT numctebanco, numctecoppel, secuencia, fecha
				INTO vnumcte, vcliente_ref, iSecAdic, vfechaaltacliente
				FROM bditarjcop:"informix".detallerepadic
				WHERE secuencia > 0 AND tipocliente = 'A'
				AND fecha = pFechaAct
				
				IF vnumcte <> '' AND vcliente_ref <> '' THEN
				    --dsb-17/09/2012
					/*IF iSecAdic = 1 THEN
						LET vnipadicional = 'A';
					END IF;*/
					
					SELECT sucursal, user_insert
					INTO cFolioSucursal, vefectuo
					FROM bdinteg:"informix".si_adiccoppel
					WHERE numcte = vnumcte AND secuencia > 1 AND numtarcoppel = vcliente_ref;
					
					--LET vreposicion = vcliente_ref;
					
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					--DA FORMATO A LAS FECHAS
					--LET cfechanac = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH (vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					--LET cfechadesdecuandovive = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,'0')||"/"||LPAD(DAY(vfechaaltacliente),2,'0');
					--LET cfechaantiguedtrab = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,'0')||"/"||LPAD(DAY(vfechaaltacliente),2,'0');
					
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;
					
					
					--SECUENCIA DE ARCHIVO
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE tipomovto <> 'TO' OR tipomovto = 'TO') THEN
						IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE tipomovto <> 'TO' OR tipomovto = 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
						
					LET vsSQL = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(vnombre1)||"|"||TRIM(vnombre2)||"|"||TRIM(vapell_paterno)||"|"||TRIM(vapell_materno)||"|"
							||TRIM(vcurp)||"|"||TRIM(vclaveelector)||"|"||TRIM(vclaveidentificacion)||"|"||TRIM(videntificacion)||"|"||vciudad||"|"||vcolonia||"|"||vcalle||"|"||snumerocasa||"|"||TRIM(vdeptointerior)||"|"
							||TRIM(vrumbo);
					LET vsSQL = vsSQL || "|" ||TRIM(vcomplemento)||"|"||TRIM(ventrecalles)||"|"||vflaguhc||"|"||vuhcmanzana||"|"||vuhcotros||"|"||vuhcandador||"|"||vuhcetapa||"|"||vuhclote||"|"
							||vuhcedificio||"|"||vuhcentrada||"|"||vtelefono||"|"||vtelefonocelular||"|"||TRIM(vcasapropia)||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(vsexo)||"|" 
							||TRIM(vestadocivil)||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||vpersonasvivenendomicilio||"|"||TRIM(vescolaridad)||"|"||TRIM(vtiposueldo);
					LET vsSQL = vsSQL || "|"  ||vnumerodependientes||"|"||vpersonastrabajan||"|"||vlimitecredito||"|"||vingresomensual||"|"||TRIM(vsituacionespecial)||"|"||vcausasituacionespecial||"|"
							||TRIM(vclaveautrechaza)||"|" ||TRIM(vaceptadosupervisadorechazado)||"|"||TRIM(vclientenuevo)||"|"||TRIM(vcreditojoven)||"|"||TRIM(vlugartrabajo)||"|"||vciudadtrabajo||"|" 
							||vcoloniatrabajo||"|"||vcalletrabajo||"|"||snumerocasatrabajo||"|"||TRIM(vdeptoointeriortrabajo)||"|"||TRIM(vrumbotrabajo)||"|"||TRIM(vcomplementotrabajo)||"|"||TRIM(ventrecallestrabajo);
					LET vsSQL = vsSQL || "|" ||vflaguht||"|"||vuhtmanzana||"|"||vuhtotros||"|"||vuhtandador||"|"||vuhtetapa||"|"||vuhtlote||"|"||vuhtedificio||"|"||vuhtentrada||"|"||vtelefonotrabajo||"|" 
							||vextensiontrabajo||"|"||TRIM(vpuesto)||"|"||vopcionpuesto||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(vclienteconyuge)||"|"||TRIM(vnombreunoconyuge)||"|"||TRIM(vnombredosconyuge)||"|"
							||TRIM(vapellidopaternoconyuge)||"|"||TRIM(vapellidomaternoconyuge)||"|"||TRIM(cSexoConyuge)||"|"||TRIM(vlugartrabajoconyuge)||"|"||vciudadconyuge||"|"||vcoloniaconyuge||"|"||vcalletrabajoconyuge||"|" 
							||snumerocasaconyugue||"|"||TRIM(vdeptoointeriorconyuge)||"|"||TRIM(vrumbotrabajoconyuge)||"|"||TRIM(vcomplementoconyuge)||"|"||TRIM(ventrecallesconyuge);
					LET vsSQL = vsSQL|| "|" ||vflaguhy||"|"||vuhymanzana||"|"||vuhyotros||"|"||vuhyandador||"|"||vuhyetapa||"|"||vuhylote||"|"||vuhyedificio||"|"||vuhyentrada||"|"||vtelefonotrabajoconyuge||"|" 
							||vtelefonocelularconyuge||"|"||TRIM(vclaveconyugefamilia)||"|"||TRIM(vclientereferencia)||"|"||TRIM(vnombreunoreferencia)||"|"||TRIM(vnombredosreferencia)||"|"   
							||TRIM(vapellidopaternoreferencia)||"|"||TRIM(vapellidomaternoreferencia)||"|"||TRIM(cSexoReferencia)||"|"||vciudadreferencia||"|"||vcoloniareferencia||"|"||vcallereferencia||"|" 
							||snumerocasaref||"|"||TRIM(vdeptoointeriorreferencia)||"|"||TRIM(vrumboreferencia)||"|"||TRIM(vcomplementoreferencia)||"|"||TRIM(ventrecallesreferencia1)||"|"||vflaguhr||"|" 
							||vuhrmanzana||"|"||vuhrotros||"|"||vuhrandador||"|"||vuhretapa||"|"||vuhrlote||"|"||vuhredificio||"|"||vuhrentrada||"|"||vtelefonoreferencia||"|"||vtelefonocelularreferencia;				  
					LET vsSQL = vsSQL|| "|" ||TRIM(vclavereferencia1)||"|"||TRIM(vclientereferencia2)||"|"||TRIM(vnombreunoreferencia2)||"|"||TRIM(vnombredosreferencia2)||"|"||TRIM(vapellidopaternoreferencia2)||"|"||TRIM(vapellidomaternoreferencia2)||"|" 
							||TRIM(cSexoReferencia2)||"|"||vciudadreferencia2||"|"||vcoloniareferencia2||"|"||vcallereferencia2||"|"||snumerocasaref2||"|"||TRIM(vdeptoointeriorreferencia2)||"|"||TRIM(vrumboreferencia2)||"|" 
							||TRIM(vcomplementoreferencia2)||"|"||TRIM(ventrecallesreferencia2)||"|"||vflaguhr2||"|"||vuhrmanzana2||"|"||vuhrotros2||"|"||vuhrandador2||"|"||vuhretapa2||"|"||vuhrlote2||"|" 
							||vuhredificio2||"|"||vuhrentrada2||"|"||vtelefonoreferencia2||"|"||vtelefonocelularreferencia2||"|"||TRIM(vclavereferencia2)||"|"||vreferencia2||"|"||vreferencia3||"|"||vmarcadatosin||"|" 
							||vtiporeposicion||"|"||vreposicion|| "|" ||TRIM(vflagentregotarjeta)|| "|" || NVL(vefectuo, 0)|| "|" || NVL(vtiendafolio, 0) || "|" ||TRIM(vfolio)||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"   
							||TRIM(vflagnoreconocehuella)|| "|"||vfoliotienda|| "|" ||TRIM(vrfc)||"|"||TRIM(vcveburo)|| "|" ||TRIM(vfolioaut)|| "|" ||TRIM(vfolioconsulta)|| "|" ||TRIM(vfolioconcir)|| "|" ||vnegocio||"|"||vsubnegocio|| "|"   
							||vempleadoautorizo|| "|" ||TRIM(vtipo)|| "|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(vnumerosolicituddecredito)|| "|" ||TRIM(vnumcte)|| "|" ||vtiendafolioanterior||"|"||vfolioanterior||"|" 
							||vclaveproducto|| "|" ||vflagactualizacion|| "|" ||vSistsegsocial||"|"||vTiposueldoext|| "|" ||vNumempleados|| "|" ||vSubopcionpuesto|| "|" ||vPuestoext||"|"||vOpcionpuestoext||"|"
							||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, 0))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||cMarcaHit||"|"
							||iEmpleadoSubCob||"|"||sFlagCapHuella||"|"||cMarcarConsultado||"|"||sFlagTestParametrico||"|"||sFlagCapCobranza||"|"||iEmpleadoGteAutori||"|"||NVL(cFlagConsBuro,'')||"|"||cBuroPilotoTestig||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"
							||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||cDelegMunicip||"|"||TRIM(NVL(cNumInterior,''))||"|"||sPropNegocio||"|"||sParCelulares||"|"||sParAltoRiesgo||"|"||sParPrestamo||"|"||cModeloCel||"|"
							||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"
							||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);
					LET vsSQL = NVL(vsSQL, '');
					
					INSERT INTO bdinteg:"informix".si_archivoscoppeldiario  (empresa,secuencia,sucursal,trama,tipomovto,fecha_insert)
					VALUES (pempresa,iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);
					
					LET iCuentaRegistros = 1;
				ELSE
					LET vCodRetorno = '000003';
					LET iCuentaRegistros = 2;
				END IF;
			END FOREACH;
		END IF;
	ELSE
		LET vCodRetorno = '000001';
		LET iCuentaRegistros = 2;
	END IF;
	
	IF iCuentaRegistros = 1 THEN
		LET vCodRetorno = '000000';
	ELIF iCuentaRegistros = 0 THEN
		LET vCodRetorno = '000005';
	END IF;
	
	RETURN vCodRetorno;
END;
--*************************************************************************
--| Procedimiento   : "informix".sp_GeneraArchivoAdicionalesC
--| Version         : 1.0
--| Creado por      : Mohamed Carreón
--| Fecha creacion  : Diciembre de 2008
--| Descripcion 	: Realiza la extraccion de datos para archivos adicionales.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Junio de 2011
--| Descripción     : Se generan archivos, se agreagan nuevas consultas y correcciones en la trama de datos.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Octubre de 2011
--| Descripción     : Se modifica tipo de consulta para obtener los datos de las Asignaciones y Reposiciones del Adcional.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Febrero 2012
--| Descripción     : Se agregan 32 nuevos campos a la trama de salida que incluyen los datos del nuevo parametrico.
--*************************************************************************
--| Modificado por  : Victor Hugo Nuñez
--| Ultima Modif.   : 17 Septiembre  2012
--| Descripción     : Se modifican defaults y consulta nipadicional
--*************************************************************************
END PROCEDURE;