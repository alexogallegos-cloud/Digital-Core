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