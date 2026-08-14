CREATE PROCEDURE "informix".sp_reporte_donativos()
	
	RETURNING CHAR(5) as vcodret, CHAR(100) as desc_err;

    DEFINE vcodret 			CHAR(5);
    DEFINE desc_err 		CHAR(100);
	DEFINE vpaso   			INTEGER;
	DEFINE vfecha			DATE;
	DEFINE vfechanombre 	CHAR(10);
	DEFINE vNombreArchivo 	CHAR(100);
	DEFINE vsqlerr 			INTEGER;
	DEFINE vfecha_rep		DATE;
	DEFINE vsql         	CHAR(1200);
	
	
	LET vcodret   		= '0000';
	LET desc_err 		= '';
	LET vsql			= '';
	LET vpaso 			= 0;
	LET vfechanombre 	= '';

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::INICIO DEL REPORTE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    LET vpaso = 0;
	
	BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;
		
		---SET DEBUG FILE TO "/RESPALDOSNEW/mbucio/Vobos/19062020/sp_donativos.out";
		---TRACE ON;
    
		
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::GENERACION DE LA INFORMACION DEL REPORTE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	LET vpaso = 1;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		SELECT fecha_ant INTO vfecha 
		FROM bdinteg:si_fechas 
		WHERE empresa = '001';  

-- SE VALIDA QUE NO EXISTA INFORMACION DEL DIA, CARGADA EN LA BASE DE DATOS		
	LET vpaso = 2;	
	LET vfecha = to_char(vfecha);
	
		IF (EXISTS(SELECT {+AVOID_FULL ( bdicheq:"informix".sc_donaciones_atm_txns)} fecha FROM  bdicheq:"informix".sc_donaciones_atm_txns WHERE fecha = vfecha))

			THEN
				LET vcodret = '00012';
				LET desc_err = 'YA EXISTE INFORMACION DEL DIA EN LA TABLA "sc_donaciones_atm_txns"';
			
			RETURN vcodret, desc_err;
		END IF;

	LET vfecha_rep = to_char(vfecha);
	
-- SE VALIDA QUE EXISTAN REGISTROS DE DONACIONES EN EL DIA 
	LET vpaso = 3;
	
		IF ( (SELECT COUNT(*) FROM bdicheq:sc_movhis	
				WHERE fech_oper = vfecha_rep
				AND transacc IN ('0453','0493')) = 0 ) THEN
					
		LET vcodret = '00001';
		LET desc_err = 'NO SE ENCONTRO REGISTROS DE DONACIONES ESTE DÃA';
					
		END IF;
		
-- SE CARGA LA INFORMACION EN LA TABLA DE DETALLE
	
	LET vpaso = 4;	
	
		INSERT INTO bdicheq:sc_donaciones_atm_txns(fundacion,fecha,hora,cajero,folio,tarjeta,monto_donativo)
		SELECT CASE 
					WHEN A.transacc = '0450' THEN 'BECALOS' 
					WHEN a.transacc = '0492' THEN 'QUIERA_' 
			   ELSE '' END AS fundacion,
			   a.fech_oper AS fecha,
			   SUBSTR(a.fech_hor,1,8) AS hora,
			   SUBSTR(a.referencia,17,6) AS cajero,
			   a.folio_suc AS folio,
			   b.num_tarjeta AS tarjeta,
			   a.monto_tot AS monto_donativo
		FROM bdicheq:sc_movhis a, bdicheq:sc_tarjeta b
		WHERE a.cuenta = b.cuenta 
		AND transacc IN ('0492','0450')
		AND a.cancelad != 'S'
		AND b.status_tar = 'A'
        AND b.tipo_tarjeta = 'T'
		AND a.fech_oper = vfecha_rep
		ORDER  BY  hora ASC;
				
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::GENERACION DEL ARCHIVO:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	
	LET vfechanombre = SUBSTR(vfecha_rep,4,2)||'_'||SUBSTR(vfecha_rep,1,2)||'_'||SUBSTR(vfecha_rep,7,10);

	LET vNombreArchivo = 'Reporte_donativos_ATMs_'||vfechanombre||'.txt';
	LET vpaso= 50;
			LET vsql = '';
			LET vsql = 'echo "fundacion|fecha   |hora    |cajero|folio     |tarjeta         |monto_donativo">/respaldos/HEADERSreportedonativosatms.txt';
			system vsql;
	LET vpaso= 51;
			LET vsql = '';
			LET vsql = 'echo "UNLOAD TO /respaldos/CONTENIDOReporte_donativos_ATMs_'||vfechanombre||'.txt SELECT * FROM bdicheq:sc_donaciones_atm_txns where fecha = '''||vfecha_rep||'''order by hora;" >/respaldos/reportedonativosatms.sql'; 
			system vsql;
	LET vpaso= 52;
			LET vsql ='';
			LET vsql= 'dbaccess bdicheq  /respaldos/reportedonativosatms.sql';
			system vsql;
	LET vpaso= 53;
			LET vsql ='';
			LET vsql ='rm /respaldos/reportedonativosatms.sql';
			system vsql;
	LET vpaso= 54;
			LET vsql ='';
			LET vsql = "sed 's/|$//g' /respaldos/HEADERSreportedonativosatms.txt >>/respaldos//"||vNombreArchivo;
			system vsql;
	LET vpaso= 55;
			LET vsql ='';
			LET vsql = "sed 's/|$//g' /respaldos/CONTENIDOReporte_donativos_ATMs_"||vfechanombre||".txt  >>/respaldos/"||vNombreArchivo;
			system vsql;
	LET vpaso= 56;
			LET vsql ='';
			LET vsql ="rm /respaldos/HEADERSreportedonativosatms.txt";
			system vsql;
	LET vpaso= 57;
			LET vsql ='';
			LET vsql ="rm /respaldos/CONTENIDOReporte_donativos_ATMs_"||vfechanombre||".txt";
			system vsql;	
	
	LET vcodret='00000';
	LET desc_err= 'Se guardo la informacion correctamente de la fecha: '|| vfechanombre;	
		
	RETURN vcodret, desc_err;	
	
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::GENERACION DEL REPORTE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
		
	
	END;
END PROCEDURE;