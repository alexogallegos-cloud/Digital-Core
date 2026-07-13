CREATE PROCEDURE "informix".sp_guarda_tenedor_bym_web(pAp_paterno CHAR(40), pAp_materno CHAR(40), pNombre_1 CHAR(40) ,pNombre_2 CHAR(40), pFecha_nac CHAR(10), pRfc CHAR(13), pIdentificacion CHAR(20), pNum_identificacion CHAR(40), pCalle CHAR(40), pNumero_calle CHAR(10), pColonia CHAR(6), pDelegacion_poblacion  CHAR(3), pCod_postal  CHAR(5), pCiudad  CHAR(3), pEstado CHAR(2),  pTelefono CHAR(13), pTipo_tel CHAR(10), pEmail CHAR(30), pEjecutivo_insert CHAR(8))
RETURNING   CHAR(5) AS CodRet,
            INTEGER AS IdTenedor ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE iIdTenedor           INTEGER;

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '00000';
LET iIdTenedor          = 0;



SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_guarda_tenedor_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, iIdTenedor;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pAp_paterno,'')) <> '' AND TRIM(NVL(pNombre_1,'')) <> '' AND TRIM(NVL(pFecha_nac,'')) <> ''  AND  TRIM(NVL(pRfc,'')) <> '' AND TRIM(NVL(pCalle,'')) <> '' AND TRIM(NVL(pNumero_calle,'')) <> '' AND TRIM(NVL(pColonia,'')) <> '' AND TRIM(NVL(pCod_postal,'')) <> '' AND TRIM(NVL(pEstado,'')) <> '' AND TRIM(NVL(pTelefono,'')) <> '' AND  TRIM(NVL(pTipo_tel,'')) <> '' AND TRIM(NVL(pEjecutivo_insert,'')) <> '' THEN 
		IF CAST(TRIM(pEstado) AS INTEGER) = 9 THEN 
			IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
				LET cCodRet  = '00001';
			ELSE
				IF TRIM(NVL(pCiudad,'')) = '' THEN  	
					LET pCiudad  = ' ';
				END IF;
			END IF;
		ELSE
			IF TRIM(NVL(pCiudad,'')) = '' THEN  	
				LET cCodRet  = '00001';
			ELSE
				IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
					LET pDelegacion_poblacion  = ' ';
				END IF;
			END IF;
			
		END IF;
		
		IF cCodRet  = '00000' THEN
		
			INSERT INTO bdisuc:"informix".ss_tenedor_pieza(ap_paterno,ap_materno,nombre_1,nombre_2,fecha_nac,rfc,identificacion,num_identificacion,calle,numero_calle,colonia,delegacion_poblacion,cod_postal,ciudad,estado,telefono,tipo_tel,email,ejecutivo_insert,fecha_insert) 
			VALUES(pAp_paterno,pAp_materno,pNombre_1,pNombre_2,pFecha_nac,pRfc,pIdentificacion,pNum_identificacion,pCalle,pNumero_calle,pColonia,pDelegacion_poblacion,pCod_postal,pCiudad,pEstado,pTelefono,pTipo_tel,pEmail,pEjecutivo_insert,CURRENT);
			
			SELECT MAX(id_tenedor)
			INTO iIdTenedor
			FROM bdisuc:"informix".ss_tenedor_pieza
			WHERE ap_paterno = pAp_paterno
			AND ap_materno = pAp_materno
			AND nombre_1 = pNombre_1
			AND nombre_2 = pNombre_2
			AND fecha_nac = pFecha_nac
			AND rfc = pRfc;
			
			IF NVL(iIdTenedor,0) = 0 THEN
				LET cCodRet  = '00001'; -- luego pregunto
			END IF;
			
		END IF;
	
	ELSE
		LET cCodRet  = '00001';
	END IF;
	
	RETURN cCodRet, iIdTenedor;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: 98640909 - LUIS BELTRAN',
'FECHA: 13-11-2019',
'DESCRIPCION: SE CREA CLON DEL sp_guarda_tenedor_bym MODIFICANDO EL CODRET A CHAR(5)',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_recepdota_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
                pfolio_suc char(16),
                pfolio_dota char(8),
  		ptransaccion char(4),
		pdivisa CHAR(2),
                pfecha date,
		pmonto_dot money(14,2))
RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum smallint;
DEFINE vmontodot money(14,2);
DEFINE vstatus char(2);


LET vcodret = "00000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vmontodot = 0;
LET vstatus  = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/recepdota.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio_dota = '' then
   LET vcodret = "00110";
ELSE

    select plaza_cajagen into vplaza
    from   bdinteg:si_sucursales
    where  sucursal = psucursal;

    select cod_proveedor into vproveedor
    from   ss_proveedores
    where  plaza = vplaza;

    select 1,monto,status into vnum,vmontodot,vstatus
    from   ss_mae_entradasalida
    where  folio_oper = pfolio_dota;
    if vnum is null then
       LET vcodret = "00100";
       return vcodret;
    else
       if vmontodot != pmonto_dot then
          LET vcodret = "00102";
          return vcodret;
       end if
       if Trim(vstatus) = "08" then
          LET vcodret = "00103";
          return vcodret;
       end if
       if Trim(vstatus) != "11" then
          LET vcodret = "00104";
          return vcodret;
       end if
    end if

    UPDATE ss_mae_entradasalida
    SET    fecha_recepcion = pfecha,
           hora_recepcion = vhora,
           usuario_recepcion = pcajeroprincipal,
           status = '05'
    WHERE  folio_oper = pfolio_dota;
    UPDATE ss_cajageneral
    SET    saldo_asignado = saldo_asignado - pmonto_dot
    WHERE  cod_proveedor = vproveedor;

  {  INSERT INTO ss_operaciones
	  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
           denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
           denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
           denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
           cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
           cantidad_13,cantidad_14,cantidad_15)
    VALUES
          (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
           pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
	   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

    INSERT INTO ss_mae_entradasalida
           (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
            status,monto)
    VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);
}

END IF;

RETURN vcodret;
END;
END PROCEDURE;