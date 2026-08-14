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