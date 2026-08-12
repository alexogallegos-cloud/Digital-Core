CREATE PROCEDURE "informix".sp_consultaconstancia_isr(pEmpresa CHAR(3),pNumCte CHAR(20),pCuenta CHAR(20),pTarjeta CHAR(20) , pTipo CHAR(1),pRegistros SMALLINT)

RETURNING
	CHAR(6) 	AS Cod_Ret,
	CHAR(20) 	AS Cuenta,
	CHAR(1) 	AS ServicioISR;

	DEFINE iSqlErr 			INTEGER;
	DEFINE iNRows 			INTEGER;
	DEFINE cCodRet 			CHAR(6);
	DEFINE cCuenta 			CHAR(20);
	DEFINE cCuentaTarjeta 	CHAR(20);
	DEFINE cServicioISR 	CHAR(1);
	DEFINE cValor 			CHAR(60);
	
	LET iSqlErr 		= 0;
	LET iNRows 			= 0;
	LET cCodRet 		= '000000';
	LET cCuenta 		= '';
	LET cCuentaTarjeta 	= '';
	LET cServicioISR 	= '';
	LET cValor 			= '' ;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			END IF;
		END EXCEPTION;    

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/tmp/sp_consultaconstancia_isr.sql";
		--TRACE ON;
		
		IF  TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCte, '')) = '' AND TRIM(NVL(pCuenta, '')) = '' AND TRIM(NVL(pTarjeta,'') )= '' OR TRIM(NVL(pTipo,'')) = '' THEN
			LET cCodRet = '000002';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
		END IF
		
		SELECT valor INTO cValor FROM "informix".sc_param WHERE codparam = 'periodoactual';
		
		IF NVL(pTipo,'') = '1' THEN
			IF NVL(pNumCte, '') <> '' THEN
				FOREACH		    
					SELECT SKIP pRegistros DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND num_cte = TRIM(NVL(pNumCte,''))
					ORDER BY cuenta ASC
					
					SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec: "informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,'')) WITH RESUME;
					
				END FOREACH;
				
			ELIF NVL(pCuenta, '') <> '' THEN
							
					SELECT DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND cuenta = TRIM(NVL(pCuenta,''));
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			
			ELIF NVL(pTarjeta, '') <> '' THEN
			
					SELECT cuenta INTO cCuentaTarjeta FROM "informix".sc_tarjeta WHERE num_tarjeta = TRIM(NVL(pTarjeta,''));

					SELECT DISTINCT(cuenta) INTO cCuenta
					FROM "informix".sc_retenisr
					WHERE empresa = TRIM(NVL(pEmpresa,'')) AND cuenta = TRIM(NVL(cCuentaTarjeta,''));
						
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));		

			END IF;
		ELIF NVL(pTipo,'') = '2' THEN
			IF NVL(pNumCte, '') <> '' THEN
				FOREACH		    
					SELECT SKIP pRegistros DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a , "informix".sc_maechq b
					WHERE a.empresa = NVL(pEmpresa,'') AND a.num_cte = NVL(pNumCte,'')
					AND a.ejercicio >= NVL(cvalor,'') AND a.cuenta = b.cuenta
					
					SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;	
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,'')) WITH RESUME;
					
				END FOREACH;
				
			ELIF NVL(pCuenta, '') <> '' THEN						
							
					SELECT  DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a, "informix".sc_maechq b
					WHERE a.empresa = TRIM(NVL(pEmpresa,'')) AND a.cuenta = TRIM(NVL(pCuenta,'')) AND a.ejercicio >= TRIM(NVL(cvalor,'')) AND a.cuenta = b.cuenta;
					
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
			
			ELIF NVL(pTarjeta, '') <> '' THEN
			
					SELECT cuenta INTO cCuentaTarjeta FROM "informix".sc_tarjeta WHERE num_tarjeta = TRIM(NVL(pTarjeta,''));

					SELECT  DISTINCT(a.cuenta) INTO cCuenta
					FROM "informix".sc_retenisr a, "informix".sc_maechq b
					WHERE a.empresa = TRIM(NVL(pEmpresa,'')) AND a.cuenta = TRIM(NVL(cCuentaTarjeta,'')) AND a.ejercicio >= TRIM(NVL(cvalor,'')) AND a.cuenta = b.cuenta;
						
					LET iNRows = dbinfo("sqlca.sqlerrd2");		
					IF iNRows <> 0 THEN
						SELECT status_serv_elec INTO cServicioISR FROM bdiedoelec:"informix".edelec_constancia WHERE cuenta= TRIM(NVL(cCuenta,''));
						LET iNRows = dbinfo("sqlca.sqlerrd2");		
						IF iNRows = 0 THEN LET cServicioISR = 'I'; END IF;
					ELSE
						LET cCodRet = '000005';
					END IF;

					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));

			END IF;
		ELSE
			LET cCodRet = '000005';
		END IF;
		
		LET iNRows = dbinfo("sqlca.sqlerrd2");		
		IF iNRows = 0 OR  cCodRet <> '000000' THEN
			LET cCodRet = '000005';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCuenta,'')),TRIM(NVL(cServicioISR,''));
		END IF;		

	END;
END PROCEDURE
DOCUMENT
'FOLIO: 37-RQI 15 023 CONSULTA CFDI-ISR',
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 07/04/2016',
'MODIFICACIÃN: SE CREA PROCEDIMIENTO PARA OBTENER LAS CUENTAS QUE TIENEN CONSTANCIA DE RETENCION DE ISR',
'Y EL SERVICIO ACTIVO DE ISR MEDIANTE CORREO ELECTRONICO',
'SOLICITA: RODOLFO GÃMEZ',
'DB:BDICHEQ';

CREATE PROCEDURE "informix".sp_consultaperiodo_isr (pEmpresa CHAR(3),pCuenta CHAR(20), pRegistros SMALLINT)
RETURNING
	CHAR(6) AS Cod_Ret,
	CHAR(4) AS Periodo;

	DEFINE iSqlErr INTEGER;
	DEFINE iNRows INTEGER;
	DEFINE cCodRet CHAR(6);
	DEFINE cPeriodo CHAR(4);
	
	LET iSqlErr = 0;
	LET iNRows = 0;
	LET cCodRet = '000000';
	LET cPeriodo = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cPeriodo;
		END IF;
	END EXCEPTION;    

	SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

	  --SET DEBUG FILE TO "/tmp/sp_consultaperiodo_isr.out";
	  --TRACE ON;
	
	IF  NVL(pEmpresa,'') = ''  OR NVL(pCuenta, '') = ''  THEN
		LET cCodRet = '000002';
		RETURN cCodRet,cPeriodo;
	END IF

	FOREACH		    
		SELECT SKIP pRegistros DISTINCT(ejercicio) INTO cPeriodo
		FROM 'informix'.sc_retenisr
		WHERE empresa = pEmpresa 
		AND cuenta = pCuenta
		ORDER BY ejercicio ASC		
		
		RETURN cCodRet,NVL(cPeriodo,'')  WITH RESUME;
		
	END FOREACH;	
	
	LET iNRows = dbinfo("sqlca.sqlerrd2");		
	IF iNRows = 0 THEN
		LET cCodRet = '000005';
		RETURN cCodRet,cPeriodo;
	END IF;		

END;
END PROCEDURE
DOCUMENT
'Folio: 37-RQI 15 023 Consulta de Constancia',
'Autor: 95281495-Ernesto Aguilera',
'Fecha: 08/04/2016',
'ModificaciÃ³n: Se crea procedimiento para obtener los periodos de las cuentas que tienen constancia de retencion de ISR y el servicio activo de ISR mediante correo electronico',
'Sustento: RQI 15 023 Consulta CFDI-ISR.pdf',
'Solicita: Rodolfo GÃ³mez',
'DB:bdicheq';

CREATE PROCEDURE "informix".sc_datosriesgoscaptacion()
RETURNING CHAR(5);
--------------------------------------------------------------
--ACTIVIDAD:Recopila los datos de captacion del cliente, como
--el saldo disponible hasta el dia de hoy y los guarda en la
--tabla sc_riesgoscap.
--------------------------------------------------------------

--Definicion de variables
DEFINE vchrcodret        CHAR(5);
DEFINE vchrnumcte        CHAR(20);
DEFINE vchrnumcuenta     CHAR(20);
DEFINE vchrsucursal	     CHAR(4);
DEFINE vchrplaza		 CHAR(3);
DEFINE vchrproducto	     CHAR(4);
DEFINE vchractividad     CHAR(3);
DEFINE vchrresidencia	 CHAR(1);
DEFINE vchredocivil		 CHAR(2);
DEFINE vchrsexo	  	     CHAR(1);
DEFINE vchrhabitaen		 CHAR(2);
DEFINE vchrocupacion     CHAR(30);
DEFINE vchrciudad        CHAR(15);

DEFINE vintcodret        INTEGER;

DEFINE vdectasa			 DECIMAL(9,6);

DEFINE vintanioshab	     SMALLINT;
DEFINE vintdiasacum      SMALLINT;
DEFINE vintdependientes  SMALLINT;

DEFINE vmnyacumsdo		 MONEY(14,2);
DEFINE vmnysdoprom		 MONEY(14,2);
DEFINE vmnysdoactual	 MONEY(14,2);
DEFINE vmnysdoret		 MONEY(14,2);
DEFINE vmnysdocong		 MONEY(14,2);
DEFINE vmnyacumsdopos    MONEY(14,2);

DEFINE vdtefechaaniv     DATE;
DEFINE vdtefechaalta     DATE;
DEFINE vdteprimermov     DATE;
DEFINE vdteultimomov     DATE;
DEFINE vdtefechahoy      DATE;

--DEBUG FLAG
--SET debug file to "/tmp/sc_datosriesgoscaptacion.out";
--TRACE ON;

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
LET vchractividad     ="";
LET vchrresidencia    ="";
LET vchredocivil      ="";
LET vchrsexo          ="";
LET vchrhabitaen      ="";
LET vchrocupacion     ="";
LET vchrciudad        ="";

LET vintcodret        =0;

LET vdectasa          =0;

LET vintanioshab      =0;
LET vintdiasacum      =0;
LET vintdependientes  =0;

LET vmnyacumsdo       =0;
LET vmnysdoprom       =0;
LET vmnysdoactual     =0;
LET vmnysdoret		  =0;
LET vmnysdocong		  =0;


TRUNCATE TABLE bdicheq:sc_riesgoscap;

--Obtiene la fecha del dia de hoy
SELECT fecha_hoy INTO vdtefechahoy FROM bdinteg:si_fechas;

FOREACH
    SELECT mae.num_cte,mae.cuenta,mae.sucursal,mae.plaza,mae.producto,fec.valor,
           cli.actividad_princ,cli.residencia,cte.estado_civil,cte.sexo,cte.anios_habita,
           noc.acum_sdo_pos,noc.dias_acum_int,mae.sdo_actual,mae.sdo_retenido,mae.sdo_cong,noc.acum_sdo_pos,
           noc.fecha_alta,cli.fecha_alta,pfs.descripcion,cte.dependientes
    INTO vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdectasa,
         vchractividad,vchrresidencia,vchredocivil,vchrsexo,vintanioshab,
         vmnyacumsdo,vintdiasacum,vmnysdoactual,vmnysdoret,vmnysdocong,vmnyacumsdopos,
         vdtefechaaniv,vdtefechaalta,vchrocupacion,vintdependientes
    FROM bdicheq:sc_maechq mae
    LEFT OUTER JOIN bdicheq:sc_producto pro ON(mae.producto=pro.producto AND mae.empresa=pro.empresa)
    LEFT OUTER JOIN bdicheq:sc_maenoc noc ON(noc.cuenta=mae.cuenta AND mae.empresa=noc.empresa)
	LEFT OUTER JOIN bdinteg:si_cliente cli ON(mae.num_cte=cli.numcte AND mae.empresa=cli.empresa)
	LEFT OUTER JOIN bdinteg:si_ctepf cte ON(mae.num_cte=cte.numcte AND mae.empresa=cte.empresa)
	LEFT OUTER JOIN bdinteg:si_fechavalor fec ON(pro.tasa=fec.tasa AND pro.empresa=fec.empresa)
    LEFT OUTER JOIN bdinteg:si_profesion pfs ON(cte.profesion=pfs.profesion)
    WHERE mae.status_cta='1' AND mae.empresa='001'

    --Calcula el saldo promedio del cliente
	IF vmnysdoprom IS NOT NULL AND vmnyacumsdo IS NOT NULL AND vintdiasacum IS NOT NULL AND vintdiasacum <> 0 THEN
		LET vmnysdoprom = vmnyacumsdo / vintdiasacum;
	END IF;

    --Calcula el saldo actual del cliente
	IF vmnysdoactual IS NOT NULL AND vmnysdoret IS NOT NULL AND vmnysdocong IS NOT NULL THEN
		LET vmnysdoactual = vmnysdoactual - (vmnysdoret + vmnysdocong);
	END IF;

    --Obtiene la fecha del primer y ultimo movimiento
    SELECT MIN(fech_alt),MAX(fech_alt) INTO vdteprimermov,vdteultimomov
    FROM bdicheq:sc_movhis WHERE cuenta=vchrnumcuenta;

    --Obtiene la ciudad del cliente
    SELECT a.nombreciudad INTO vchrciudad FROM bdinteg:si_catciudades a,bdinteg:si_direcciones b
    WHERE b.numcte=vchrnumcte AND b.numerociudad=a.numerociudad AND b.tipo_dir='1' AND b.secuencia=1;

    INSERT INTO sc_riesgoscap ( empresa,numcte,cuenta,sucursal,plaza,producto,tasa,actividad,residencia,
                                edocivil,sexo,anioshab,sdoprom,sdodisp,fecha,ocupacion,dependientes,
                                ciudad,provintdev,fechaaniv,fecaltacte,primermov,ultimomov)
    VALUES ( '001',vchrnumcte,vchrnumcuenta,vchrsucursal,vchrplaza,vchrproducto,vdectasa,vchractividad,vchrresidencia,
            vchredocivil,vchrsexo,vintanioshab,vmnysdoprom,vmnysdoactual,vdtefechahoy,vchrocupacion,vintdependientes,
            vchrciudad,vmnyacumsdopos,vdtefechaaniv,vdtefechaalta,vdteprimermov,vdteultimomov);

END FOREACH;

RETURN vchrcodret;
END;

END PROCEDURE;