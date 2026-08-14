CREATE PROCEDURE "informix".sp_consultacuentacredito(psNumCuenta CHAR(13), psNumCliente CHAR(20), psNumTarjeta CHAR(16), 
psEmpresa CHAR(4), piTipoBusqueda SMALLINT)
	
	RETURNING CHAR(5) AS CodigoRetorno, CHAR(13) AS NumCuenta, CHAR(20) AS NumCliente, CHAR(16) AS NumTarjeta, CHAR(40) AS DescProducto, 
	CHAR(26) AS Nombre1, CHAR(26) AS Nombre2, CHAR(26) AS ApellidoPaterno, CHAR(26) AS ApellidoMaterno, CHAR(30) AS Status;

	-- Declaración de variables.
	DEFINE sCodigoRetorno 	CHAR(5);
	DEFINE sSqlErr			INTEGER;
	DEFINE sNumCuenta		CHAR(12);
	DEFINE sNumCliente  	CHAR(9);
	DEFINE sNumTarjeta  	CHAR(16);
	DEFINE sProducto   		CHAR(11);
	DEFINE sNomProducto 	CHAR(40);
	DEFINE iCont			INTEGER;
	DEFINE sNombre1 		CHAR(26);
	DEFINE sNombre2 		CHAR(26);
	DEFINE sApellidoPaterno CHAR(25);
	DEFINE sApellidoMaterno CHAR(25);
	DEFINE sStatus   		CHAR(30);
	DEFINE sTipo 			CHAR(1);
	
	-- Asignación de valores a variables.
	LET sCodigoRetorno = '00000';
	LET sSqlErr = 0;
	LET sNumCuenta = '';
	LET sNumCliente = '';
	LET sNumTarjeta = '';
	LET sProducto = '';
	LET sNomProducto = '';
	LET iCont = 0;
	LET sNombre1 = '';
	LET sNombre2 = '';
	LET sApellidoPaterno = '';
	LET sApellidoMaterno = '';
	LET sStatus = '';
	LET sTipo = '';
	
	BEGIN	
		ON EXCEPTION SET sSqlErr		
			IF sSqlErr <> 0 THEN	            
				LET sCodigoRetorno = sSqlErr;				
	            RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto,
				sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno,	sStatus;				
			END IF;
		END EXCEPTION;
		
		SET ISOLATION DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		-- Búsqueda por  número de cuenta.
		IF(piTipoBusqueda = 1) THEN			
			LET psNumCuenta = TRIM(psNumCuenta);
						
			FOREACH
				--SELECT a.num_credito, a.numcte, c.num_tarjeta, a.status_cred, NVL(b.nombre_prod, '')
				--INTO sNumCuenta, sNumCliente, sNumTarjeta, sStatus, sNomProducto
				SELECT a.num_credito, a.numcte, c.num_tarjeta, NVL(b.nombre_prod, '')
				INTO sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto
				FROM bdicred:"informix".sd_maecred a
				LEFT OUTER JOIN bdicred:"informix".sd_tarjeta c ON (a.num_credito = c.num_credito) 
				JOIN bdicred:"informix".sd_definicion b ON (a.num_producto = b.num_producto)					
				WHERE c.num_credito = psNumCuenta AND c.empresa = psEmpresa /*AND c.status_tar = 'A'*/
				
				--IF (sNumCuenta <> '' AND sNumCliente <> '' AND sNumTarjeta <> '' AND sStatus <> '' AND sNomProducto <> '') THEN
				IF ( sNumCuenta <> '' AND sNumCliente <> '' AND sNumTarjeta <> '' AND sNomProducto <> '' ) THEN				
					SELECT numcte, NVL(nombre1, ''), NVL(nombre2, ''), NVL(apell_paterno, ''), NVL(apell_materno, '')
					INTO sNumCliente, sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno
					FROM bdinteg:"informix".si_cliente WHERE numcte = sNumCliente;
					
					IF (sNumCliente IS NOT NULL) THEN						
						--LET iCont = iCont + 1;						
						SELECT UPPER(b.descstatustarjeta)
						INTO sStatus FROM intercard:"informix".tarjeta a JOIN intercard:"informix".statustarjeta b
						ON (a.codstatustarjeta = b.codstatustarjeta) WHERE a.numtarjeta = sNumTarjeta;
							
						IF (sNumCliente IS NOT NULL) THEN 							
							LET iCont = iCont + 1;							
							RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto, 
							sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, sStatus WITH RESUME;							
						END IF;
					END IF;
				END IF;			
			END FOREACH;
			
		-- Búsqueda por número de cliente.
		ELIF (piTipoBusqueda = 2) THEN		
			LET psNumCliente = TRIM(psNumCliente);			
			
			FOREACH
				SELECT num_credito INTO sNumCuenta FROM bdicred:"informix".sd_maecred WHERE empresa = psEmpresa AND numcte = psNumCliente
				
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentacredito(sNumCuenta, psNumCliente, psNumTarjeta, psEmpresa, 1)
					INTO sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto, sNombre1, sNombre2, sApellidoPaterno, 
					sApellidoMaterno, sStatus
							
					IF (sCodigoRetorno = '00000') THEN					
						LET iCont = iCont + 1;						
						RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto, sNombre1, sNombre2, sApellidoPaterno, 
						sApellidoMaterno, sStatus WITH RESUME;					
					END IF;		
				END FOREACH;			
			END FOREACH;
		
		-- Búsqueda  por número de tarjeta.
		ELIF (piTipoBusqueda = 3) THEN			
			LET psNumTarjeta = TRIM(psNumTarjeta);			
			--SELECT a.num_credito, a.numcte, a.num_tarjeta, b.status_cred, NVL(c.nombre_prod, '')
			--INTO sNumCuenta, sNumCliente, sNumTarjeta, sStatus, sNomProducto
			SELECT a.num_credito, a.numcte, a.num_tarjeta, NVL(c.nombre_prod, '')
			INTO sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto
			FROM bdicred:"informix".sd_tarjeta a
			LEFT OUTER JOIN bdicred:"informix".sd_maecred b ON (a.num_credito = b.num_credito) 
			JOIN bdicred:"informix".sd_definicion c ON (b.num_producto = c.num_producto)				
			WHERE a.num_tarjeta = psNumTarjeta AND a.empresa = psEmpresa /*AND a.status_tar = 'A'*/;

			--IF ( sNumCuenta IS NOT NULL AND sNumCliente IS NOT NULL AND sNumTarjeta IS NOT NULL AND sStatus IS NOT NULL AND sNomProducto <> '' ) THEN
			IF (sNumCuenta IS NOT NULL AND sNumCliente IS NOT NULL AND sNumTarjeta IS NOT NULL AND sNomProducto <> '') THEN
				
				SELECT numcte, NVL(nombre1, ''), NVL(nombre2, ''), NVL(apell_paterno, ''), NVL( apell_materno, '')
				INTO sNumCliente, sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno
				FROM bdinteg:"informix".si_cliente WHERE numcte = sNumCliente;
				
				IF (sNumCliente IS NOT NULL) THEN
					--LET iCont = 1;
					SELECT UPPER(b.descstatustarjeta)
					INTO sStatus FROM intercard:"informix".tarjeta a JOIN intercard:"informix".statustarjeta b
					ON (a.codstatustarjeta = b.codstatustarjeta) WHERE a.numtarjeta = sNumTarjeta;
							
					IF (sNumCliente IS NOT NULL) THEN 						
						LET iCont = 1;					
						RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto, 
						sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, sStatus WITH RESUME;							
					END IF;
				END IF;
			END IF;			
		END IF;
	
		IF (iCont = 0) THEN		
			LET sCodigoRetorno = '00001'; -- Cliente no tiene cuentas.			
			RETURN sCodigoRetorno, sNumCuenta, sNumCliente, sNumTarjeta, sNomProducto,
			sNombre1, sNombre2, sApellidoPaterno, sApellidoMaterno, sStatus;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO:		Francisco Rodríguez Ibarra.',
'FECHA:			30 de abril de 2010.',
'DESCRIPCIÓN:	Consulta los movimientos ya sea de la cuenta o de un número de crédito',
'				en un rango de fechas.',
'RETORNO:		00000 Datos obtenidos satisfactoriamente',
'				00001 Cliente sin cuentas.',

'MODIFICÓ:		Francisco Rodríguez Ibarra.',
'FECHA:			19-Mayo-2010',
'MODIFICACIÓN:	Se modificó SP para obtener correctamente el status de la tarjeta.',

'MODIFICÓ:		Francisco Rodríguez Ibarra.',
'FECHA:			01-junio-2010',
'MODIFICACIÓN:	Se valida que sean tarjetas de crédito con el bin.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			09-junio-2010',
'MODIFICACIÓN:	Se cambió la consulta del nombre del producto a la tabla sd_definicion, en lugar de sd_param.',

'MODIFICÓ:		Ulises Rodríguez Márquez.',
'FECHA:			Miércoles, 05 de Enero de 2011.',
'MODIFICACIÓN:	Se reestructuran y optimizan las búsquedas para consultar cuentas de crédito.',

'MODIFICÓ:		Bernardo Carlos Báez González .',
'FECHA:			10 de Febrero de 2012.',
'PRO./FOLIO:    SIFAuditoria-1249',
'PAQUETE/CU:    PCU-bdinteg/CU-0163-ConsultarCuentaCredito-SPL',
'MODIFICACIÓN:	Se Modifican Para que se Retorne el Status de Tarjeta en vez status de Credito',

'MODIFICÓ:		Fabiola Corrales Tapia.',
'FECHA:			22 de Febrero de 2012.',
'PRO./FOLIO:    SIFAuditoria-1249',
'MODIFICACIÓN:	Se modifica para corregir sintaxis de y reglas de programación';

CREATE PROCEDURE "informix".sp_actualizahuellalinea(pNumCte CHAR(20), pTicket CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) AS CodigoRetorno;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSql_err INTEGER;
	DEFINE cCodRet 	CHAR(5);
	
	--INICIALIZACION DE VARIABLES--
	LET iSql_err = 0;
	LET cCodRet  = '00000';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_actualizahuellalinea.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND status_consulta = "0") THEN
		
			IF SUBSTR(pTicket,1,1) <> "-" THEN 
			
				--No ocurrieron errores en el servicio
				UPDATE bdinteg:"informix".si_huella_linea
				SET ticket = pTicket, status_consulta = "1"
				WHERE numcte = pNumCte
				AND ticket = ""
				AND status_consulta = "0";
			
			ELSE
			
				--Ocurrio algun error en el servicio
				UPDATE bdinteg:"informix".si_huella_linea
				SET ticket = pTicket, status_consulta = "3"
				WHERE numcte = pNumCte
				AND ticket = ""
				AND status_consulta = "0";
			
			END IF;
			
		ELSE
		
			LET cCodRet = '00001'; --No existe cliente en si_huella_linea
			
		END IF;
		
		RETURN cCodRet;

	END

END PROCEDURE

DOCUMENT
'Se actualiza bdinteg:si_huella_linea los campos ticket',
'estatus consulta de 0(Por enviar) a 1(Enviada) Si no ocurrio algun error en el servicio',
'estatus consulta de 0(Por enviar) a 3(Consultada) Si ocurrio algun error en el servicio',
'Autor :Daniela Ramírez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_conhuella2(pempresa CHAR(3),
                                          psucursal CHAR(4),
                                          pejecutivo CHAR(8),
                                          pnumcte CHAR(20))
	
	RETURNING CHAR(5),CHAR(942),CHAR(942),SMALLINT,CHAR(1),CHAR(8),CHAR(4),CHAR(10),CHAR(8),CHAR(10),CHAR(22);
	
	DEFINE vcodret			CHAR(5);
	DEFINE vexiste			CHAR(1);
	DEFINE vsqlerr			INTEGER;
	DEFINE visamerr			INTEGER;
	DEFINE vMapad			CHAR(942);
	DEFINE vMapai			CHAR(942);
	DEFINE vSecuencia		SMALLINT;
	DEFINE vEstado			CHAR(1);
	DEFINE vUsuario			CHAR(8);
	DEFINE vSucursal		CHAR(4);
	DEFINE vFecha_alta		CHAR(10);
	DEFINE vUsuario_camb	CHAR(8);
	DEFINE vFecha_camb		CHAR(10);
	DEFINE vFecha_ult_camb	CHAR(22);

	LET vcodret = "000";
	LET vexiste = 0;
	LET vMapad = "";
	LET vMapai = "";
	LET vSecuencia = 0;
	LET vEstado = "";
	LET vUsuario = "";
	LET vSucursal = "";
	LET vFecha_alta = "";
	LET vUsuario_camb = "";
	LET vFecha_camb = "";
	LET vFecha_ult_camb = "";
	
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET vsqlerr,visamerr
		   IF vsqlerr != 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
		   END IF;
		END EXCEPTION;
		
		--- Verifica recepcion correcta de datos
		IF pnumcte IS NULL OR Trim(pnumcte) = "" THEN
		   LET vcodret = "110";
		   RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
		END IF;
		
		SELECT 	1 INTO vexiste
		FROM 	bdinteg:"informix".si_ejecut
		WHERE 	ejecutivo = pejecutivo;
		   
		IF vexiste IS NULL THEN
		   LET vcodret="112";
		   RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
		END IF;
		
		SELECT 	dmapa, imapa, secuencia, estado, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, fech_ult_camb 
		INTO 	vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb
		FROM   	bdinteg:"informix".si_cte_huella
		WHERE  	numcte = pnumcte
		AND    	estado ="A";
		
		IF vMapad IS NULL OR vMapai IS NULL THEN
			let vcodret = "132";
			RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
		END IF
		
		IF vSecuencia IS NULL OR vEstado IS NULL OR vUsuario IS NULL OR vSucursal IS NULL OR vFecha_alta IS NULL    THEN
			let vcodret = "150";
			RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
		END IF

		RETURN vcodret, vMapad, vMapai, vSecuencia, vEstado, vUsuario, vSucursal, vFecha_alta, vUsuario_camb, vFecha_camb, vFecha_ult_camb;
	END;
END PROCEDURE
DOCUMENT
"Consulta de Huella de cliente persona fisica y todos los registros de la tabla si_cte_huella",
"Autor : Rodolfo Javier Tortolero Varela",
"FECHA : 17/Febrero/2012",
"Ver.  : 1.1",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_grabahuellalineahistorico()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) AS CodigoRetorno;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 	INTEGER;
	DEFINE cCodRet 	CHAR(5);

	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';


	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_grabahuellalineahistorico.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS(SELECT status_consulta FROM bdinteg:"informix".si_huella_linea WHERE status_consulta = 3) THEN
				
			INSERT INTO bdinteg:"informix".si_huella_linea_hist
				 SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
				 empleado, tipo_sensor,	dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, ticket, status_consulta
				   FROM bdinteg:"informix".si_huella_linea
				  WHERE status_consulta = "3";
						
			DELETE FROM bdinteg:"informix".si_huella_linea WHERE status_consulta = "3";
			
		END IF;
		
		RETURN cCodRet;

	END

END PROCEDURE

DOCUMENT
'Inserta en la bdinteg:si_huella_linea',
'Autor :Daniela Ramírez',
'FECHA : 08/Febrero/2012',
'BD: bdinteg';

CREATE PROCEDURE  "informix".conscteppesfamilia_n(pempresa char(3), pnumcte char(20))

    RETURNING CHAR(5), -- Codigo Retorno
                             CHAR(3), -- Empresa
                             CHAR(20), -- Numcte
                             SMALLINT, -- Secuencia
                             CHAR(20), -- NumCteFamiliar
                             CHAR(60), -- Nombre Familiar
                             CHAR(3), -- Parentesco
                             CHAR(8), -- User_Insert
                             DATE; -- Fecha_Insert

-- Definicion de Variables
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;
-- si_ppefamilia
DEFINE vempresa CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vsecuencia SMALLINT;
DEFINE vnumctefamiliar  CHAR(20);
DEFINE vnombrefamiliar  CHAR(105);
DEFINE vparentesco CHAR(2);
DEFINE vuser_insert  CHAR(8);
DEFINE vfecha_insert DATE;

-- Inicializacion de Variables
LET vciclo = 0;                        
LET vcodret = "000";
LET  vsqlerr = 0;
-- si_ppefamilia
LET vempresa = "";
LET vnumcte = "";
LET vsecuencia = 0;
LET vnumctefamiliar  = "";
LET vnombrefamiliar  = "";
LET vparentesco = "";
LET vuser_insert = "";
LET vfecha_insert = "";

    --SET DEBUG FILE TO "/respaldosbd/conscteppesfamilia_n.out";
    --TRACE ON;

BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, vempresa, vnumcte, vsecuencia , vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;

    FOREACH

        SELECT empresa, numcte, secuencia, numctefamiliar, nombrefamiliar, parentesco, usuario_insert, fecha_insert
              INTO vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert
            FROM bdinteg:"informix".si_ppefamilia
         WHERE numcte = pnumcte
          ORDER BY secuencia

        RETURN vcodret, vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert WITH RESUME;
    
    END FOREACH;
      
END
END PROCEDURE
DOCUMENT
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 15/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_cargaservicios(pEmpresa CHAR(3), pTipo CHAR(1), pUsuario CHAR(8),
											  pIP CHAR(16), pClaveip CHAR(20),
											  pPuerto CHAR(6), pClavepuerto CHAR(20),
											  pMensaje CHAR(10), pClavemsg CHAR(20),
											  pSubmensaje CHAR(10), pClavesubmsg CHAR(20))
	RETURNING CHAR(5);
	
	DEFINE vCodret	CHAR(5);
	DEFINE vsqlerr	INTEGER;
	DEFINE visamerr	INTEGER;
	DEFINE vSucursal CHAR(4);

	LET vCodret = "000";
	LET vSucursal = "";
	
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET vsqlerr, visamerr
		   IF vsqlerr != 0 THEN
				LET vCodret = vsqlerr;
				RETURN vCodret;
		   END IF;
		END EXCEPTION;

		IF pTipo = "1" THEN	--si tipo = 1 inserta 4 registros en la tabla.
			FOREACH

				SELECT 	sucursal
				INTO 	vSucursal
				FROM   	bdinteg:"informix".si_sucursales
				WHERE  	empresa = pEmpresa
				AND		tpo_sucursal = 'S'
				ORDER BY sucursal
				
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClavemsg, pMensaje, '1', pUsuario, CURRENT);
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClavesubmsg, pSubmensaje, '1', pUsuario, CURRENT);
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClaveip, pIP, '1', pUsuario, CURRENT);
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClavepuerto, pPuerto, '1', pUsuario, CURRENT);
				
			END FOREACH
			
		ELIF pTipo = "2" THEN -- si tipo = 2 inserta 3 registros en la tabla.
			FOREACH

				SELECT 	sucursal
				INTO 	vSucursal
				FROM   	bdinteg:"informix".si_sucursales
				WHERE  	empresa = pEmpresa
				AND		tpo_sucursal = 'S'
				ORDER BY sucursal
				
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClavemsg, pMensaje, '1', pUsuario, CURRENT);
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClaveip, pIP, '1', pUsuario, CURRENT);
				INSERT INTO bdinteg:"informix".si_sucservicios (empresa, sucursal, cod_servicio, valor, flag_servicio, user_insert, fecha_insert) VALUES(pEmpresa, vSucursal, pClavepuerto, pPuerto, '1', pUsuario, CURRENT);
				
			END FOREACH
		
		END IF;

		RETURN vCodret;
	END;
END PROCEDURE
DOCUMENT
"Consulta ",
"Autor : Rodolfo Javier Tortolero Varela",
"FECHA : 17/Febrero/2012",
"Ver.  : 1.1",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_cortesig(pFecha date, pMeses integer)
RETURNING char(6), date;

    DEFINE vccodret             char(6);
    DEFINE vccodret2            char(6);
    DEFINE vccodret3            char(60);
    DEFINE vsqlerr              integer;
    DEFINE visamerr             integer;
    DEFINE vdescerr             char(60);
    DEFINE vCodret              char(6);
    DEFINE dDiaPrimero          date;
    DEFINE dDiaUltimo           date;
    DEFINE dFechaMesResultante  date;
    DEFINE dDiaUltimoResultante date;
    
    LET vccodret  = '000';
    LET vccodret2 = '000';
    LET vccodret3 = '';
    LET vsqlerr   = 0;
    LET visamerr  = 0;
    LET vdescerr  = '';
    LET vCodret   = '';
    LET dDiaPrimero = '';
    LET dDiaUltimo  = '';
    LET dFechaMesResultante = '';
    LET dDiaUltimoResultante = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cortesig.err';
        TRACE ON;
        IF vsqlerr <> 0  THEN
            LET vcCodRet  = vsqlerr;
            LET vccodret2 = visamerr;
            LET vccodret3 = vdescerr;
            RETURN vcCodRet, pFecha;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cortesig.out';
    --- TRACE ON;

    IF day(pfecha) >= 29 THEN
        -- // TOMAR EL DÍA 1  Y HACER SUMA DE MESES
        EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(lpad(month(pFecha), 2, '0'), year(pFecha)) 
        INTO vCodret, dDiaPrimero, dDiaUltimo;

        LET dFechaMesResultante = dDiaPrimero + pMeses units month;

        -- // OBTENER DIA ULTIMO DEL MES DE LA FECHA RESULTANTE
        EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(lpad(month(dFechaMesResultante), 2, '0'), year(dFechaMesResultante)) 
        INTO vCodret, dDiaPrimero, dDiaUltimoResultante;

        -- // VALIDAR SI EL DIA DE MESIVERSARIO EXISTE EN EL MES DE FECHA RESULTANTE
        IF day(pFecha) > Day(dDiaUltimoResultante) THEN
            -- // NO EXISTE EL DÍA, TOMAR EL DÍA ULTIMO DE ESE MES
            RETURN '00', dDiaUltimoResultante;
        ELSE
            -- // DIA SI EXISTE, SUMA DE MESES NORMAL
            RETURN '00', pFecha + pMeses units month;
        END IF;
    ELSE
        RETURN '00', pFecha + pMeses units month;
    END IF;

    END;

END PROCEDURE;