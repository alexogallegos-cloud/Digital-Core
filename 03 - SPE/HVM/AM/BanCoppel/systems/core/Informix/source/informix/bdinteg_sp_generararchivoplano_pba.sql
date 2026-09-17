CREATE PROCEDURE "informix".sp_generararchivoplano_pba(cTipoMov CHAR(2), pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL CHAR (1050) ;
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE  v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	
	SET LOCK MODE TO WAIT 10;


BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	SET DEBUG FILE TO "/resplogifx/archivoscartera/altaunica/envios/sp_generararchivoplano_pba.out";
	--SET DEBUG FILE TO "/resplogifx/archivoscartera/altaunica/envios/sp_GenerarArchivoPlano.out";
	TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';

	---LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET vRuta = '/respaldos/rodolfo/';
	---LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica';
	LET sNombreArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica';

	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '000001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto = 'TO';
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
				IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO') THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica.unl';
					---LET vsSQL = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax.unl''' || ' DELIMITER ' || '''|''' || 
					LET vsSQL = ' echo "UNLOAD TO ' || '''/respaldos/rodolfo/movimientosaltaunicax.unl''' || ' DELIMITER ' || '''|''' || 
								' SELECT trama '||
								' FROM bdinteg:si_archivoscoppeldiario '||
								' WHERE tipomovto <> '||'''TO'''||
								' " > /respaldos/rodolfo/Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg /respaldos/rodolfo/Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax.unl > " || sPreNomArchivoFinal;
					LET vsSQL =  "/resplogifx/archivoscartera/altaunica/envios/sed_arc.sh /respaldos/rodolfo/movimientosaltaunicax.unl " || sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica.unl > " || sNombreArchivoFinal;
					---SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "||"/respaldos/rodolfo/movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm /respaldos/rodolfo/movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO bdinteg:"informix".si_archivoscoppelhistorial(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto <> 'TO';
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto <> 'TO';
					
				END IF;
			ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
				LET v_cod_ret = '000000';
				IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto = 'TO') THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					---LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica'|| cFecha_hoy || '.txt';
					LET sNombreArchivoFinal = '/respaldos/rodolfo/cifrasaltaunica'|| cFecha_hoy || '.txt';
					---LET sPreNomArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica.unl';
					LET sPreNomArchivoFinal = '/respaldos/rodolfo/cifrasaltaunica.unl';
					---	GENERA EL ARCHIVO PLANO
					---LET vsSQL1 = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax.unl''' || ' DELIMITER ' || '''|''';
					LET vsSQL1 = ' echo "UNLOAD TO ' || '''/respaldos/rodolfo/cifrasaltaunicax.unl''' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscoppeldiario WHERE  tipomovto = '"||cTipoMov||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/Ejecutacifrasaltaunica.sql';
					LET vsSQL = 'dbaccess bdinteg /respaldos/rodolfo/Ejecutacifrasaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					LET vsSQL =  "sed 's/\\//g' /respaldos/rodolfo/cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica.unl > "|| sNombreArchivoFinal;
					LET vsSQL =  "sed 's/|$//g' /respaldos/rodolfo/cifrasaltaunica.unl > "|| sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| "/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos.txt";
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| "/respaldos/rodolfo/cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos.txt";
					LET vsSQL =  "rm /respaldos/rodolfo/cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;

					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO bdinteg:"informix".si_archivoscoppelhistorial(empresa,secuencia,identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'', trama,tipomovto,fecha_insert, cFechaSistema
					FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto = 'TO';
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto = 'TO';
					
				END IF;
			END IF;
		ELSE
			LET v_cod_ret = '000002';
		END IF;
	ELSE
		LET v_cod_ret = '000003';
	END IF;
	RETURN v_cod_ret;
END;
--##############################################################################
--## Procedimiento   : "informix".sp_GenerarArchivoPlano
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Realiza la generacion del archivo plano.
--##############################################################################
--## Modificado por  : Adrian Lara
--## Fecha creacion  : Octubre de 2011
--## Descripcion     : Se cambia el nombre al archivo que se genera y se agrega sentencia para limpiar el archivo.
--##############################################################################
END PROCEDURE;