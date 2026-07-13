CREATE PROCEDURE "informix".sc_datosriesgosprueba(pempresa CHAR(3),pfechahoy DATE,pfechaprox DATE)
RETURNING CHAR(5);
--------------------------------------------------------------
--ACTIVIDAD:Recopila los datos de captacion del cliente y los
--guarda en la tabla sc_riesgoscap.Si es otro mes, borra re-
--gistros de hace 2 meses dejando registrado el ultimo dia de
--ese mes a borrar.
--------------------------------------------------------------

--Definicion de variables
DEFINE vchrcodret        CHAR(5);
DEFINE vchrnumcte        CHAR(20);
DEFINE vchrnumcuenta     CHAR(20);
DEFINE vchrsucursal	     CHAR(4);
DEFINE vchrplaza		 CHAR(3);
DEFINE vchrproducto	     CHAR(4);
DEFINE vchrrfc	  	     CHAR(13);
DEFINE vchractividad	 CHAR(3);
DEFINE vchrresidencia	 CHAR(1);
DEFINE vchredocivil		 CHAR(2);
DEFINE vchrsexo	  	     CHAR(1);
DEFINE vchrhabitaen		 CHAR(2);

DEFINE vintcodret        INTEGER;

DEFINE vdectasa			 DECIMAL(9,6);

DEFINE vintanioshab	     SMALLINT;
DEFINE vintedad          SMALLINT;
DEFINE vintaniohoy       SMALLINT;
DEFINE vintmeshoy        SMALLINT;
DEFINE vintmesprox       SMALLINT;
DEFINE vintmessupr       SMALLINT;
DEFINE vintdiasupr 	     SMALLINT;
DEFINE vintdiahoy 	     SMALLINT;
DEFINE vintaniocte       SMALLINT; 
DEFINE vintmescte        SMALLINT;
DEFINE vintdiacte 	     SMALLINT;
DEFINE vintdiasacum	     SMALLINT;

DEFINE vmnyacumsdo		 MONEY(14,2);
DEFINE vmnysdoprom		 MONEY(14,2);
DEFINE vmnysdoactual	 MONEY(14,2);
DEFINE vmnysdoret		 MONEY(14,2);
DEFINE vmnysdocong		 MONEY(14,2);

DEFINE vdteultpagoint	 DATE;



BEGIN

ON EXCEPTION SET vintcodret
   IF vintcodret <> 0 THEN
      LET vchrcodret=vintcodret;
      RETURN vchrcodret;
   END IF;
END EXCEPTION;

--Inicializacion de variables
LET vchrcodret        ="000";
LET vchrnumcte        ="";
LET vchrnumcuenta	  ="";
LET vchrsucursal      ="";
LET vchrplaza         ="";
LET vchrproducto      ="";
LET vchrrfc           ="";
LET vchractividad     ="";
LET vchrresidencia    ="";
LET vchredocivil      ="";
LET vchrsexo          ="";
LET vchrhabitaen      ="";

LET vintcodret        =0;

LET vdectasa          =0;

LET vintanioshab      =0;
LET vintedad          =0;
LET vintaniohoy       =0;
LET vintmeshoy        =0;
LET vintmesprox       =0;
LET vintmessupr       =0;
LET vintdiasupr       =0;
LET vintdiahoy        =0;
LET vintaniocte       =0;
LET vintmescte        =0;
LET vintdiacte        =0;
LET vintdiasacum      =0;

LET vmnyacumsdo       =0;
LET vmnysdoprom       =0;
LET vmnysdoactual     =0;
LET vmnysdoret		  =0;
LET vmnysdocong		  =0;



LET vintaniohoy = YEAR(pfechahoy);
LET vintmeshoy = MONTH(pfechahoy);
LET vintdiahoy = DAY(pfechahoy);
LET vintmesprox = MONTH(pfechaprox);


FOREACH
	SELECT mae.num_cte,mae.cuenta,mae.sucursal,mae.plaza,mae.producto,mae.ultpagoint,fec.valor,cli.rfc,
		   cli.actividad_princ,cli.residencia,cte.estado_civil,cte.sexo,cte.habita_en,cte.anios_habita,
		   noc.acum_sdo_pos,noc.dias_acum_int,mae.sdo_actual,mae.sdo_retenido,mae.sdo_cong,YEAR(cte.fecha_nac),MONTH(cte.fecha_nac),DAY(cte.fecha_nac)
	INTO vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdteultpagoint,vdectasa,vchrrfc,
		 vchractividad,vchrresidencia,vchredocivil,vchrsexo,vchrhabitaen,vintanioshab,
		 vmnyacumsdo,vintdiasacum,vmnysdoactual,vmnysdoret,vmnysdocong,vintaniocte,vintmescte,vintdiacte 
	FROM sc_maechq mae
	LEFT OUTER JOIN sc_producto pro ON(mae.producto=pro.producto AND mae.empresa=pro.empresa)
	LEFT OUTER JOIN sc_maenoc noc ON(noc.cuenta=mae.cuenta AND mae.empresa=noc.empresa)
	LEFT OUTER JOIN bdinteg:si_cliente cli ON(mae.num_cte=cli.numcte AND mae.empresa=cli.empresa)
	LEFT OUTER JOIN bdinteg:si_ctepf cte ON(mae.num_cte=cte.numcte AND mae.empresa=cte.empresa)
	LEFT OUTER JOIN bdinteg:si_fechavalor fec ON(pro.tasa=fec.tasa AND pro.empresa=fec.empresa)
	WHERE mae.status_cta="1" AND mae.empresa=pempresa
		
	--Calcula la edad del cliente
	IF vintaniocte IS NOT NULL AND vintmescte IS NOT NULL AND vintdiacte IS NOT NULL AND
		vintaniohoy IS NOT NULL AND vintmeshoy IS NOT NULL AND vintdiahoy IS NOT NULL THEN
		
		LET vintedad = vintaniohoy - vintaniocte;
		IF vintmeshoy >= vintmescte THEN
			IF vintmeshoy = vintmescte THEN
				IF vintdiahoy >= vintdiacte THEN
					LET vintedad = vintedad + 1;
				END IF;
			ELSE	
				LET vintedad = vintedad + 1;
			END IF;
		END IF;
	
	END IF;
	
	IF vmnysdoprom IS NOT NULL AND vmnyacumsdo IS NOT NULL AND vintdiasacum IS NOT NULL AND vintdiasacum <> 0 THEN
		LET vmnysdoprom = vmnyacumsdo / vintdiasacum;
	END IF;

	IF vmnysdoactual IS NOT NULL AND vmnysdoret IS NOT NULL AND vmnysdocong IS NOT NULL THEN
		LET vmnysdoactual = vmnysdoactual - (vmnysdoret + vmnysdocong);
	END IF;
	
	DELETE FROM sc_riesgoscap WHERE empresa = pempresa AND numcte = vchrnumcte
									AND cuenta = vchrnumcuenta AND fecha = pfechahoy;
	INSERT INTO sc_riesgoscap ( empresa,numcte,cuenta,sucursal,plaza,producto,fechaaniv,tasa,rfc,actividad,residencia,
								edocivil,sexo,habitaen,anioshab,acumsdo,edad,sdoprom,sdodisp,fecha ) 
	VALUES ( pempresa,vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdteultpagoint,vdectasa,vchrrfc,vchractividad,vchrresidencia,
			vchredocivil,vchrsexo,vchrhabitaen,vintanioshab,vmnyacumsdo,vintedad,vmnysdoprom,vmnysdoactual,pfechahoy );
		
END FOREACH;

IF vintmesprox <> vintmeshoy THEN
	IF vintmesprox = 1 THEN
		LET vintmessupr = 11;
		LET vintaniohoy = vintaniohoy - 1;
	ELIF vintmesprox = 2 THEN
		LET vintmessupr = 12;
		LET vintaniohoy = vintaniohoy - 1;
	ELSE
		LET vintmessupr = vintmesprox - 2;
	END IF;
				
	SELECT MAX(DAY(fecha)) INTO vintdiasupr FROM sc_riesgoscap 
	WHERE MONTH(fecha) = vintmessupr AND YEAR(fecha) = vintaniohoy;
	
	DELETE FROM sc_riesgoscap
	WHERE YEAR(fecha) = vintaniohoy AND MONTH(fecha) = vintmessupr AND DAY(fecha) < vintdiasupr;
	
END IF;
RETURN vchrcodret;
END;

END PROCEDURE;