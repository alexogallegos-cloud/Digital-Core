CREATE PROCEDURE "informix".sd_datosriesgoscred(pempresa CHAR(3))
RETURNING CHAR(5);
--------------------------------------------------------------
--ACTIVIDAD:Recopila los datos de credito del cliente y los
--guarda en la tabla sc_riesgoscred.Si es otro mes, borra re-
--gistros de hace 2 meses dejando registrado el ultimo dia de
--ese mes a borrar.
--------------------------------------------------------------

--Definicion de variables
DEFINE vchrcodret			CHAR(5);
DEFINE vchrproducto			CHAR(4);
DEFINE vchrrfc	  			CHAR(13);
DEFINE vchractividad		CHAR(3);
DEFINE vchrresidencia		CHAR(1);
DEFINE vchredocivil			CHAR(2);
DEFINE vchrsexo	  			CHAR(1);
DEFINE vchrhabitaen			CHAR(2);
DEFINE vchrnumcte			CHAR(20);
DEFINE vchrnumcredito		CHAR(20);
DEFINE vchrocupacion		CHAR(30);

DEFINE vintcodret			INTEGER;

DEFINE vintaniohoy			SMALLINT;
DEFINE vintmeshoy			SMALLINT;
DEFINE vintdiahoy			SMALLINT;
DEFINE vintmesprox			SMALLINT;
DEFINE vintanioshab			SMALLINT;
DEFINE vintedad				SMALLINT;
DEFINE vintmessupr			SMALLINT;
DEFINE vintdiasupr 			SMALLINT;
DEFINE vintaniocte			SMALLINT; 
DEFINE vintmescte			SMALLINT;
DEFINE vintdiacte 			SMALLINT;
DEFINE vintdiasacumcap		SMALLINT;
DEFINE vintdiasmora			SMALLINT;

DEFINE vdtefecha			DATE;
DEFINE vdtefechavenc		DATE;
DEFINE vdteultmov			DATE;
DEFINE vdteprimermov        DATE;

DEFINE vdecmontootor		DECIMAL(18,2);
DEFINE vdecsdoinsoluto      DECIMAL(18,2);
DEFINE vdecsdoretenido      DECIMAL(18,2);
DEFINE vdecsdolindisp		DECIMAL(18,2);
DEFINE vdecsdodisp			DECIMAL(18,2);
DEFINE vdecsdopromdia		DECIMAL(18,2);
DEFINE vdecsdoacummes		DECIMAL(18,2);
DEFINE vdectasainteres		DECIMAL(9,6);
DEFINE vdecmontofin         DECIMAL(18,2);



BEGIN

ON EXCEPTION SET vintcodret
   IF vintcodret <> 0 THEN
      LET vchrcodret=vintcodret;
      RETURN vchrcodret;
   END IF;
END EXCEPTION;

--Inicializacion de variables
LET vchrcodret           ="000";
LET vchrproducto         ="";
LET vchrrfc              ="";
LET vchractividad        ="";
LET vchrresidencia       ="";
LET vchredocivil         ="";
LET vchrsexo             ="";
LET vchrhabitaen         ="";
LET vchrnumcte			 ="";
LET vchrnumcredito		 ="";
LET vchrocupacion		 ="";

LET vintcodret           =0;

LET vintaniohoy          =0;
LET vintmeshoy           =0;
LET vintdiahoy           =0;
LET vintmesprox          =0;
LET vintanioshab         =0;
LET vintedad             =0;
LET vintmessupr          =0;
LET vintdiasupr          =0;
LET vintaniocte          =0;
LET vintmescte           =0;
LET vintdiacte           =0;
LET vintdiasacumcap      =0;
LET vintdiasmora		 =0;

LET vdecmontootor        =0;
LET vdecsdoinsoluto      =0;
LET vdecsdoretenido      =0;
LET vdecsdolindisp       =0;
LET vdecsdodisp          =0;
LET vdecsdopromdia       =0;
LET vdecsdoacummes       =0;
LET vdectasainteres      =0;
LET vdecmontofin         =0;


SELECT YEAR(fecha_hoy),MONTH(fecha_hoy),DAY(fecha_hoy),MONTH(prox_fecha),fecha_hoy
INTO vintaniohoy, vintmeshoy,vintdiahoy,vintmesprox,vdtefecha 
FROM bdinteg:si_fechas;

FOREACH

	SELECT mae.numcte,mae.num_credito,mae.num_producto,mae.tasa_interes,mxo.fecha_vencto,dos.monto_otorgado,
		   dos.sdo_cap_insoluto,dos.monto_financiado,dos.sdo_retenido,dos.sdo_acum_mes_cap,dos.dias_acum_cap,
		   cli.rfc,cli.actividad_princ,cli.residencia,cte.estado_civil,cte.sexo,cte.habita_en,cte.anios_habita,
		   pro.descripcion,YEAR(cte.fecha_nac),MONTH(cte.fecha_nac),DAY(cte.fecha_nac)
	INTO vchrnumcte,vchrnumcredito,vchrproducto,vdectasainteres,vdtefechavenc,vdecmontootor,
	     vdecsdoinsoluto,vdecmontofin,vdecsdoretenido,vdecsdoacummes,vintdiasacumcap,
	     vchrrfc,vchractividad,vchrresidencia,vchredocivil,vchrsexo,vchrhabitaen,vintanioshab,
		 vchrocupacion,vintaniocte,vintmescte,vintdiacte
	FROM sd_maecred mae
	LEFT OUTER JOIN sd_maesdos dos ON(mae.num_credito=dos.num_credito AND mae.empresa=dos.empresa)
	LEFT OUTER JOIN sd_maecredanexo mxo ON(mae.num_credito=mxo.num_credito AND mae.empresa=mxo.empresa)
	LEFT OUTER JOIN bdinteg:si_cliente cli ON(mae.numcte=cli.numcte AND mae.empresa=cli.empresa)
	LEFT OUTER JOIN bdinteg:si_ctepf cte ON(mae.numcte=cte.numcte AND mae.empresa=cte.empresa)
	LEFT OUTER JOIN bdinteg:si_profesion ON(cte.profesion=pro.profesion)
	WHERE mae.empresa=pempresa AND mae.status_cred IN ("AA",'E1') AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
	
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
	
	IF vdecsdoretenido IS NOT NULL AND vdecsdoinsoluto IS NOT NULL THEN
		LET vdecsdolindisp = vdecsdoretenido + vdecsdoinsoluto;
	ELSE
		IF vdecsdoretenido IS NOT NULL THEN
			LET vdecsdolindisp = vdecsdoretenido;
		ELIF vdecsdoinsoluto IS NOT NULL THEN
			LET vdecsdolindisp = vdecsdoinsoluto;
		ELSE
			LET vdecsdolindisp = 0;
		END IF;
	END IF;
	
	IF vdecmontootor IS NOT NULL THEN
		LET vdecsdodisp = vdecmontootor - vdecsdolindisp;
	ELSE
		LET vdecsdodisp = 0;
	END IF;
	
	IF vdecsdoacummes IS NOT NULL AND vintdiasacumcap IS NOT NULL AND vintdiasacumcap <> 0 THEN
		LET vdecsdopromdia = vdecsdoacummes / vintdiasacumcap;
	ELSE
		LET vdecsdopromdia = 0;
	END IF;
	
	IF vdtefecha IS NOT NULL AND vdtefechavenc IS NOT NULL THEN
		LET vintdiasmora = ( vdtefecha - vdtefechavenc ) / 30;
	ELSE
		LET vintdiasmora = 0;
	END IF;
	
	SELECT MAX(fecha_mov),MIN(fecha_mov) INTO vdteultmov,vdteprimermov FROM sd_movhis WHERE num_credito = vchrnumcredito;
	
	DELETE FROM sd_riesgoscred WHERE empresa = pempresa AND numcte = vchrnumcte 
								AND numcredito = vchrnumcredito AND fecha = vdtefecha;
	INSERT INTO sd_riesgoscred ( empresa,numcte,numcredito,producto,fechavenc,linmaxcred,sdolindisp,sdodisponible,
								sdopromdia,montofin,tasainteres,rfc,actividad,ocupacion,residencia,edocivil,sexo,
								habitaen,anioshab,edad,ciclosmora,fecha,fecprimermov,fecultmov ) 
	VALUES ( pempresa,vchrnumcte,vchrnumcredito,vchrproducto,vdtefechavenc,vdecmontootor,vdecsdolindisp,vdecsdodisp,
			vdecsdopromdia,vdecmontofin,vdectasainteres,vchrrfc,vchractividad,vchrocupacion,vchrresidencia,vchredocivil,vchrsexo,
			vchrhabitaen,vintanioshab,vintedad,vintdiasmora,vdtefecha,vdteprimermov,vdteultmov );
			
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
				
	SELECT MAX(DAY(fecha)) INTO vintdiasupr FROM sd_riesgoscred 
	WHERE MONTH(fecha) = vintmessupr AND YEAR(fecha) = vintaniohoy;
	
	DELETE FROM sd_riesgoscred
	WHERE YEAR(fecha) = vintaniohoy AND MONTH(fecha) = vintmessupr AND DAY(fecha) < vintdiasupr;
END IF;

RETURN vchrcodret;
END;

END PROCEDURE;