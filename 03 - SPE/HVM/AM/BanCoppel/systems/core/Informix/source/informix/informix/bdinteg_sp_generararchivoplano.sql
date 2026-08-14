CREATE PROCEDURE "informix".sp_generararchivoplano(cTipoMov CHAR(2), pFechaAct DATE)
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
    DEFINE cFechaArchivosCplDiario DATE;
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
    LET cFechaArchivosCplDiario = DATE(1);
	
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--SET LOCK MODE TO WAIT 10;

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
	

	--SET DEBUG FILE TO "/informix/jesus/sp_GenerarArchivoPlano.out";
	--SET DEBUG FILE TO "/resplogifx/archivoscartera/altaunica/envios/sp_GenerarArchivoPlano.out";
	--TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';

	LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica2';

	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '000001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto = 'TO';
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
    SELECT LIMIT 1 fecha_insert INTO cFechaArchivosCplDiario FROM bdinteg:"informix".si_archivoscoppeldiario;
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
				IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO') THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(cFechaArchivosCplDiario)||""||LPAD(MONTH(cFechaArchivosCplDiario),2,0)||""||LPAD(DAY(cFechaArchivosCplDiario),2,0);
					LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica2'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica2.unl';
					LET vsSQL = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax2.unl''' || ' DELIMITER ' || '''|''' || 
								' SELECT trama '||
								' FROM bdinteg:si_archivoscoppeldiario '||
								' WHERE tipomovto <> '||'''TO'''||
								' " > /resplogifx/archivoscartera/altaunica/envios/Ejecutamovimientosaltaunica2.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/Ejecutamovimientosaltaunica2.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax2.unl > " || sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica2.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "||"/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicaderechos2.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicaderechos2.txt";
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
					LET cFecha_hoy = YEAR(cFechaArchivosCplDiario)||""||LPAD(MONTH(cFechaArchivosCplDiario),2,0)||""||LPAD(DAY(cFechaArchivosCplDiario),2,0);
					LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica2'|| cFecha_hoy || '.txt';
					LET sPreNomArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica2.unl';
					---	GENERA EL ARCHIVO PLANO
					LET vsSQL1 = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax2.unl''' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscoppeldiario WHERE  tipomovto = '"||cTipoMov||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica2.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/Ejecutacifrasaltaunica2.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax2.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica2.unl > "|| sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| "/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos2.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos2.txt";
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