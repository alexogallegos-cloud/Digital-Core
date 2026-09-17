CREATE PROCEDURE "informix".tc_consulta_concilia 
		(
		pEmpresa CHAR(3), 
		pFechaProceso DATE,
		pTipoConcilia CHAR(3)
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter 
		--	Consecutivo  1 caracter 
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5),	VARCHAR(30),	DATE,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER,
					INTEGER,	INTEGER,			INTEGER;
	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	DEFINE v_archivo						VARCHAR(30);
	DEFINE v_fecha							DATE;
	DEFINE v_recibidos_total		INTEGER;
	DEFINE v_recibidos_cargo		INTEGER;
	DEFINE v_recibidos_abono		INTEGER;
	DEFINE v_recibidos_reversa	INTEGER;
	DEFINE v_procesados					INTEGER;
	DEFINE v_cargo_concilia			INTEGER;
	DEFINE v_cargo_aplica				INTEGER;
	DEFINE v_cargo_error				INTEGER;
	DEFINE v_abono_concilia			INTEGER;
	DEFINE v_abono_aplica				INTEGER;
	DEFINE v_abono_error				INTEGER;
	DEFINE v_reversa_concilia		INTEGER;
	DEFINE v_reversa_aplica			INTEGER;
	DEFINE v_reversa_error			INTEGER;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	--	DEFINE v_recibidos_total	INTEGER;
	--	DEFINE v_recibidos_cargo	INTEGER;
	--	DEFINE v_recibidos_abono	INTEGER;
	--	DEFINE v_recibidos_reversa	INTEGER;
	
	--	DEFINE v_concilia_total		INTEGER;
	DEFINE v_concilia_cargo		INTEGER;
	DEFINE v_concilia_abono		INTEGER;
	DEFINE v_concilia_reversa	INTEGER;
	
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	LET v_archivo							= "";
	LET v_fecha								= " ";
	LET v_recibidos_total			= 0;
	LET v_recibidos_cargo			= 0;
	LET v_recibidos_abono			= 0;
	LET v_recibidos_reversa		= 0;
	LET v_procesados					= 0;
	LET v_cargo_concilia			= 0;
	LET v_cargo_aplica				= 0;
	LET v_cargo_error					= 0;
	LET v_abono_concilia			= 0;
	LET v_abono_aplica				= 0;
	LET v_abono_error					= 0;
	LET v_reversa_concilia		= 0;
	LET v_reversa_aplica			= 0;
	LET v_reversa_error				= 0;
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	--	LET v_recibidos_total	= 0;
	--	LET v_recibidos_cargo	= 0;
	--	LET v_recibidos_abono	= 0;
	--	LET v_recibidos_reversa	= 0;
	
	--	LET v_concilia_total	= 0;
	LET v_concilia_cargo	= 0;
	LET v_concilia_abono	= 0;
	LET v_concilia_reversa	= 0;
	
BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN 	cod_ret,	"",			" ",
							0,				0,			0,
							0,				0,			0,
							0,				0,			0,
							0,				0,			0,
							0,				0,			0;
   END EXCEPTION;

 --SET DEBUG FILE TO "tc_aplica_concilia.out";
 --TRACE ON;

  SET LOCK MODE TO WAIT 10;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	FOREACH 
		SELECT 	archivo,					fecha,							recibidos_total,
						recibidos_cargo,	recibidos_abono,		recibidos_reversa,
						procesados,				cargo_concilia,			cargo_aplica,
						cargo_error,			abono_concilia,			abono_aplica,
						abono_error,			reversa_concilia,		reversa_aplica,
						reversa_error
		INTO 		v_archivo,					v_fecha,						v_recibidos_total,
						v_recibidos_cargo,	v_recibidos_abono,	v_recibidos_reversa,
						v_procesados,				v_cargo_concilia,		v_cargo_aplica,	
						v_cargo_error,			v_abono_concilia,		v_abono_aplica,
						v_abono_error,			v_reversa_concilia,	v_reversa_aplica,
						v_reversa_error
		FROM  td_conciliaarchivos
		WHERE	fecha_recepcion = pFechaProceso AND tipoarchivo = NVL(pTipoConcilia,tipoarchivo)
		
		LET v_concilia_cargo		= NVL(v_cargo_concilia,0) 	+ NVL(v_cargo_aplica,0) 	+ NVL(v_cargo_error,0);
		LET v_concilia_abono		= NVL(v_abono_concilia,0) 	+ NVL(v_abono_aplica,0) 	+ NVL(v_abono_error,0);
		LET v_concilia_reversa	= NVL(v_reversa_concilia,0) + NVL(v_reversa_aplica,0) + NVL(v_reversa_error,0);


		RETURN 	cod_ret,
						NVL(v_archivo,0),							NVL(v_fecha,0),							NVL(v_recibidos_cargo,0),
						NVL(v_cargo_concilia,0),			NVL(v_cargo_aplica,0),			NVL(v_cargo_error,0),
						NVL(v_recibidos_cargo,0) - 		NVL(v_concilia_cargo,0),
																																			NVL(v_recibidos_abono,0),	
						NVL(v_abono_concilia,0),			NVL(v_abono_aplica,0),			NVL(v_abono_error,0),
						NVL(v_recibidos_abono,0) - 		NVL(v_concilia_abono,0),
																																			NVL(v_recibidos_reversa,0),
						NVL(v_reversa_concilia,0),		NVL(v_reversa_aplica,0),		NVL(v_reversa_error,0),
						NVL(v_recibidos_reversa,0) - 	NVL(v_concilia_reversa,0)		WITH RESUME;

	END FOREACH;
	

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE
DOCUMENT
'ESTA FUNCION APLICA EL PROCESO DE CONCILIACION ',
'AUTOR : Cristian Campos Diaz ',
'FECHA : 29 Mayo 2008',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".conciliadebito(pempresa char(3),
                                pnum_tarjeta char(16),
                                psucursal char(4),
                                pusuario char(8),
                                ptipomov char(1),
                                ptransacc char(4),
                                pfoliosuc char(16),
                                pmonto_tot money(14,2),
                                pdivisa char(2),
                                preferencia char(40),
                                pfolioori char(16),
				pvRfcComer char (20),
				pvRef23 char(23))
       returning char(5),char(1);

define vcodret char(5);
define vsqlerr integer;
define vbandera char(1);
define vcuenta char(20);
define vtranret char(4);
define vnum_serial integer;
define vcancelad char(1);
define vfecapli date;
define vsdodisp money(14,2);
define vmtoapli money(14,2);
define vTranResp CHAR(4);
define vTipoTran char(2);
--set debug file to "conciliadebito.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vbandera;
      end if
   end exception;

   let vcodret = "000";
   let vbandera = "E";
   let vsqlerr = 0;
   let vcuenta = "";
   let vtranret = "";
   let vnum_serial = 0;
   let vcancelad = "";
   let vfecapli = "";
   let vsdodisp = 0;
   let vmtoapli = 0;
   let vTranResp = "";
   let vTipoTran = "";


   select cuenta into vcuenta
      from sc_tarjeta
      where empresa = pempresa and num_tarjeta = pnum_tarjeta;
   if vcuenta is null then
      let vcodret = "111";
      let vbandera = "E";
      return vcodret,vbandera;
   end if

   select num_serial,cancelad
      into vnum_serial,vcancelad
      from sc_movhis
      where empresa = pempresa and cuenta = vcuenta and
            folio_suc = pfoliosuc and transacc = ptransacc;

  IF vnum_serial IS NULL THEN  -- Temporal
     select num_serial,cancelad
      into vnum_serial,vcancelad
      from sc_movhis
      where empresa = pempresa and cuenta = vcuenta and
            folio_suc = pfoliosuc and
            monto_tot = pmonto_tot;
  END IF


        LET vTranResp = ptransacc;

      	SELECT NVL(tranlibprot,"0000"),tipo_tran
          INTO ptransacc,vTipoTran
          FROM bdinteg:si_transacc
         WHERE empresa = pempresa
           AND numero = ptransacc
           AND sistema = "01";

      if ptipomov = "C" then

           if vTipoTran  in ("00","01","02") then
	      let vbandera = "C";
	      return vcodret,vbandera;
	   end if;

        IF ptransacc = "0000" OR ptransacc = " " THEN
              LET ptransacc = vTranResp;
        END IF

         call cargo_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                        pfoliosuc,vcuenta,0,pmonto_tot,pdivisa,preferencia,
                        pnum_tarjeta,"")
              returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
         if vcodret <> "000" and vcodret <> "400" then
            let vbandera = "E";
            return vcodret,vbandera;
	 elif vcodret = "400" then
            let vbandera = "0";
            return vcodret,vbandera;
	 else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
      if ptipomov = "A" then
      	 LET ptransacc = "0813";
         call abono_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                        pfoliosuc,vcuenta,0,pmonto_tot,pmonto_tot,0,0,0,
                        pdivisa,preferencia,pnum_tarjeta,"")
              returning vcodret;
         if vcodret <> "000" then
            let vbandera = "E";
            return vcodret,vbandera;
         else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
      if ptipomov = "R" then
         call reversiontd(pempresa,psucursal,pusuario,pfolioori,"A",
                          vcuenta,ptransacc)
              returning vcodret;
         if vcodret <> "000" then
            let vbandera = "E";
            return vcodret,vbandera;
         else
            let vbandera = "C";
            return vcodret,vbandera;
         end if
      end if
  return vcodret,vbandera;
end
end procedure
;