CREATE PROCEDURE "informix".sp_obtieneacumuladostddchip(pEmpresa CHAR(3))
--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret			CHAR(5);
DEFINE iSqlErr, iIsamErr INTEGER;
DEFINE cNombreArchivo	CHAR(50);
DEFINE cSql				CHAR(1000);
DEFINE cRuta			CHAR(50);
DEFINE cEncabezado		CHAR(600);
DEFINE dFechaHoy		DATE;
DEFINE iDias			INTEGER;
DEFINE iDia				INTEGER;
DEFINE iMes				INTEGER;
DEFINE cMes				CHAR(2);
DEFINE iAnio			INTEGER;
DEFINE iBiciesto		INTEGER;
DEFINE cSucursal		CHAR(4);
DEFINE cNombreSuc		CHAR(40);
DEFINE cCiudad			CHAR(3);
DEFINE cEstado			CHAR(2);
DEFINE cNombreCiudad	CHAR(60);
DEFINE cNombreEstado	CHAR(60);
DEFINE cNumEjecutivo	CHAR(8);
DEFINE cNombreEjecutivo	CHAR(45);
DEFINE cProducto		CHAR(4);
DEFINE cNombreProd		CHAR(40);
DEFINE dFecIni			DATE;
DEFINE dFecFin			DATE;
DEFINE dFecIniAcumulado	DATE;
DEFINE iTddChipEntreg	INTEGER;
DEFINE iTddChipCobro	INTEGER;
DEFINE dMontoTddChipCob	DECIMAL(14,2);
DEFINE iTddChipNOcobro	INTEGER;
DEFINE iAcumuladoAnio	INTEGER;
DEFINE iAcumuladoAnioCobro INTEGER;
DEFINE iAcumAnioNOcobro	INTEGER;
DEFINE dMontoAcumulado	DECIMAL(14,2);
DEFINE dFechaArchivo 	DATE;

--INICIALIZACION DE VARIABLES--
LET cCodret			= '00000';
LET iSqlErr 		= 0;
LET iIsamErr 		= 0;
LET cNombreArchivo	= '';
LET cSql			= '';
LET cRuta			= '';
LET cEncabezado		= '';
LET dFechaHoy		= '';
LET iDia			= 0;
LET iDias			= 0;
LET iMes			= 0;
LET cMes			= '';
LET iAnio			= 0;
LET iBiciesto		= 0;
LET cSucursal		= '';
LET cNombreSuc		= '';
LET cCiudad			= '';
LET cEstado			= '';
LET cNombreCiudad	= '';
LET cNombreEstado	= '';
LET cNumEjecutivo	= '';
LET cNombreEjecutivo= '';
LET cProducto		= '';
LET cNombreProd		= '';
LET dFecIni			= '';
LET dFecFin			= '';
LET dFecIniAcumulado= '';
LET iTddChipEntreg	= 0;
LET iTddChipCobro	= 0;
LET dMontoTddChipCob= 0;
LET iTddChipNOcobro	= 0;
LET iAcumuladoAnio	= 0;
LET iAcumuladoAnioCobro = 0;
LET iAcumAnioNOcobro= 0;
LET dMontoAcumulado	= 0;
LET dFechaArchivo 	= '';

--SET DEBUG FILE TO "/tmp/sp_obtieneacumuladostddchip.out";
--SET DEBUG FILE TO '/informix/PRISCILLA/sp_generaarchivoaltasolicitud2.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy FROM "informix".sc_fechas WHERE empresa = pEmpresa;

	IF NVL(dFechaHoy,'') <> '' THEN
		LET iDia = DAY(dFechaHoy);
		LET iMes = MONTH(dFechaHoy);
		LET iAnio = YEAR(dFechaHoy);

		IF iMes = 1 THEN
			LET iMes = 12;
			LET iAnio = iAnio - 1;
		ELSE
			LET iMes = iMes - 1;
		END IF;

		LET cMes = LPAD(iMes,2,'0');
		LET iBiciesto= MOD(iAnio,4);

		IF iMes = 1 OR iMes = 3 OR iMes = 5 OR iMes = 7 OR iMes = 8 OR iMes = 10 OR iMes = 12 THEN
			LET iDias = 31;
		ELIF iMes = 2 THEN  
			LET iDias = 28;
			IF iBiciesto = 0 THEN 
				LET iDias = iDias + 1;
			END IF;
		ELIF iMes = 4 OR iMes = 6 OR iMes = 9 OR iMes = 11 THEN
			LET iDias = 30;
		END IF;

		LET cNombreArchivo = "acumuladostddchip" || '02' || cMes || iAnio;

		
		SELECT valor INTO cRuta FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = 142;

		LET dFecIni = cMes ||'/01/' || TO_CHAR(iAnio);
		LET dFecFin = cMes || "/" || TO_CHAR(iDias) || "/" || TO_CHAR(iAnio);
		LET dFecIniAcumulado = '01/01/' || TO_CHAR(iAnio);
		LET dFechaArchivo = cMes || '/' || '02' || '/' || iAnio;

		IF NVL(cRuta,'') <> '' THEN
			LET cEncabezado = "SUCURSAL|NOMBRE|CIUDAD|ESTADO|GERENTE SUCURSAL|PRODUCTO|TDD CON CHIP ENTREGADAS|TDD CON CHIP COBRADAS|MONTO|TDD CON CHIP NO COBRADAS|ACUMULADO DEL AÑO DE TDD CON CHIP ENTREGADAS COBRADAS|MONTO ACUMULADO|ACUMULADO DEL AÑO DE TDD CON CHIP ENTREGADAS NO COBRADAS";

			LET cSql = 'echo "' || TRIM(cEncabezado) || '" >> ' || TRIM(cRuta) ||  TRIM(cNombreArchivo) || '.txt';
			SYSTEM cSql;

			FOREACH 
				SELECT DISTINCT sucursal INTO cSucursal
				FROM "informix".sc_acumuladostddchip WHERE fechainsert >= dFecIniAcumulado AND fechainsert <= dFechaArchivo
				ORDER BY sucursal

				IF NVL(cSucursal,'') <> '' THEN
					--SUCURSAL
					SELECT suc.nombre, ptf.cve_ciudad, ptf.cve_estado INTO cNombreSuc, cCiudad, cEstado
					FROM bdinteg:"informix".si_ptf ptf
					INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo
					WHERE  ptf.id_ptf = cSucursal AND ptf.tipo <> 'C' ;
					/*SELECT nombre, ciudad, estado INTO cNombreSuc, cCiudad, cEstado
					FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = cSucursal;*/

					--CIUDAD
					SELECT nombre INTO cNombreCiudad
					FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudad AND estado = cEstado;

					--ESTADO
					SELECT nombre INTO cNombreEstado 
					FROM bdinteg:"informix".si_estados WHERE estado = cEstado;

					--GERENTE SUCURSAL
					SELECT FIRST 1 ejecutivo, nombre INTO cNumEjecutivo, cNombreEjecutivo
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = pEmpresa AND sucursal = cSucursal AND password <> 'BAJA' AND nombramiento = 'GERENTE TITULAR'
					AND fecha_insert = (SELECT MAX(fecha_insert) FROM bdinteg:"informix".si_ejecut 
						WHERE empresa = pEmpresa AND sucursal = cSucursal AND password <> 'BAJA' AND nombramiento = 'GERENTE TITULAR');

					FOREACH 
						--PRODUCTO
						SELECT producto, nombre INTO cProducto, cNombreProd
						FROM "informix".sc_producto
						WHERE empresa = pEmpresa AND producto IN('1500','1900','2000','2500')
						ORDER BY producto

						SELECT (tarjentregadasctasab + tarjentregadas + adisentregadasctasab + adisentregadas),
							(tartitucobradasctasab + tartitucobradas + taradicobradasctasab + taradicobradas),
							(mtotottitnvacobctasab + mtotottitrepcobctasab + mtotottitnvacob + mtotottitrepcob + mtototadinvacobctasab + mtototadirepcobctasab + mtototadinvacob + mtototadirepcob)
						INTO iTddChipEntreg, --TDD CON CHIP ENTREGADAS DURANTE EL MES ANTERIOR
							iTddChipCobro, --TDD CON CHIP COBRADAS DURANTE EL MES ANTERIOR
							dMontoTddChipCob --MONTO TDD CHIP COBRADAS
						FROM "informix".sc_acumuladostddchip
						WHERE sucursal = cSucursal AND producto = cProducto AND fechainsert = dFechaArchivo;

						--TDD CON CHIP NO COBRADAS
						LET iTddChipNOcobro = iTddChipEntreg - iTddChipCobro;

						SELECT SUM(tarjentregadasctasab + tarjentregadas + adisentregadasctasab + adisentregadas),
							SUM(tartitucobradasctasab + tartitucobradas + taradicobradasctasab + taradicobradas),
							SUM(mtotottitnvacobctasab + mtotottitrepcobctasab + mtotottitnvacob + mtotottitrepcob + mtototadinvacobctasab + mtototadirepcobctasab + mtototadinvacob + mtototadirepcob)
						INTO iAcumuladoAnio, --ACUMULADO DEL AÑO EN TDD CON CHIP ENTREGADAS
							iAcumuladoAnioCobro, --ACUMULADO DEL AÑO EN TDD CON CHIP ENTREGADAS COBRADAS
							dMontoAcumulado --MONTO ACUMULADO DEL AÑO EN TDD CON CHIP ENTREGADAS
						FROM "informix".sc_acumuladostddchip
						WHERE sucursal = cSucursal AND producto = cProducto AND fechainsert >= dFecIniAcumulado AND fechainsert <= dFechaArchivo;

						--ACUMULADO DEL AÑO EN TDD CON CHIP ENTREGADAS NO COBRADAS
						LET iAcumAnioNOcobro = iAcumuladoAnio - iAcumuladoAnioCobro;

						LET cSql = 'echo "' || NVL(TRIM(cSucursal),'') || '|' || NVL(TRIM(cNombreSuc),'') || '|' || NVL(TRIM(cNombreCiudad),'') || '|' || NVL(TRIM(cNombreEstado),'') || '|' || NVL(TRIM(cNumEjecutivo),'') || '|' || NVL(TRIM(cNombreProd),'') || '|' || NVL(iTddChipEntreg,0) || '|' || NVL(iTddChipCobro,0) || '|' || NVL(dMontoTddChipCob,0.00) || '|' || NVL(iTddChipNOcobro,0) || '|' || NVL(iAcumuladoAnioCobro,0) || '|' || NVL(dMontoAcumulado,0.00) || '|' || NVL(iAcumAnioNOcobro,0) || '" >> ' || TRIM(cRuta) ||  trim(cNombreArchivo) || '.txt';
						SYSTEM cSql;

						LET cProducto        = '';
						LET cNombreProd		 = '';
						LET iTddChipEntreg   = 0;
						LET iTddChipCobro    = 0;
						LET dMontoTddChipCob = 0;
						LET iTddChipNOcobro  = 0;
						LET iAcumuladoAnio   = 0;
						LET iAcumuladoAnioCobro = 0;
						LET iAcumAnioNOcobro = 0;
						LET dMontoAcumulado	 = 0;
					END FOREACH;
				END IF;
				
				LET cSucursal		= '';
				LET cNombreSuc		= '';
				LET cCiudad			= '';
				LET cEstado			= '';
				LET cNombreCiudad	= '';
				LET cNombreEstado	= '';
				LET cNumEjecutivo	= '';
				LET cNombreEjecutivo= '';
			END FOREACH;
		ELSE
			LET cCodret = "00002"; --Ruta sin Definir
		END IF;
	ELSE
		LET cCodret = "00001"; --Fecha Vacia
	END IF;

	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
'AUTOR         : Daniela Ramírez',
'DESCRIPCION   : Genera archivo .txt con info. de acumulados TDD CHIP',
'BASE DE DATOS : bdicheq',
'FECHA         : 21/Febrero/2013';

create procedure "informix".auditapase_ant(pfecha_trab date,pempresa char(3),pusuario char(8))
returning char(5);

define vproceso                char(20);
define w_cod_ret               char(5);
define tmousuario              char(8);
define tmocontrol_poliza       integer;
define tmofecha_captura        date;
define tmosecuencia            integer;
define tmoempresa              char(3);
define tmoccmayor              char(4);
define tmoccsub                char(2);
define tmoccsubsub             char(2);
define tmoccssubsub            char(2);
define tmoccsssubsub           char(2);
define tmosector               char(2);
define tmociudad               char(3);
define tmosucursal             char(4);
define tmocentro_costo         char(4);
define tmonro_auxiliar         char(12);
define tmonaturaleza           char(1);
define tmomonto                money(18,2);
define tmodescripcion_det      char(50);
define tmofecha_valida         date ;
define tmomoneda               char(2);
define tmovalor_cambio         money(12,7);
define tmovalor_div_cambio     money(12,7);
define tmomca_aplic            char(1);
define tmopoliza_usuario       char(8);
define tmotipo_mov             char(1);
define v_cuantos               integer;
define v_debitos               money(18,2);
define v_creditos              money(18,2);
define v_tipo_cuenta           char(1);
define v_auxiliar              char(1);
define v_aux                   char(12);
define v_sucursal              char(4);
define v_region                smallint;
define v_monant                char(2);
define v_numero                integer;
define v_regional              char(3);

LET tmosecuencia = 0;
LET tmoccmayor = " ";
LET tmoccsub   = " ";
LET tmoccsubsub = " ";
LET tmoccssubsub = " ";
LET tmoccsssubsub = " ";
LET tmosector = " ";
LET tmonro_auxiliar = " ";
LET w_cod_ret = "00000";
let tmocentro_costo = "";
LET v_numero = 0;
LET v_regional = "";

--SET DEBUG FILE TO '/informix/PRISCILLA/auditapase_ant.out';
--trace on;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

DELETE FROM co_auditpase
WHERE usuario = pusuario
AND   empresa = pempresa
AND   fecha_captura = pfecha_trab;

DELETE FROM co_detpol
WHERE  empresa = pempresa
AND    fecha_captura = pfecha_trab
AND    usuario = pusuario;

DELETE FROM co_poliza
WHERE  empresa = pempresa
AND    fecha_captura = pfecha_trab
AND    usuario = pusuario;

LET tmocontrol_poliza = 0;

-- CHECA SI LAS POLIZAS ESTAN CUADRADAS POR MONEDA.
FOREACH
   SELECT
      moneda,
      sum(monto)
   INTO
      tmomoneda,
      v_debitos
   FROM
      co_poldet
   WHERE
      usuario = pusuario
   AND
      fecha_captura = pfecha_trab
   AND
      naturaleza = "D"
   AND
      empresa = pempresa
   GROUP BY
      usuario,
      moneda
   ORDER BY
      moneda

   SELECT
      sum(monto)
   INTO
      v_creditos
   FROM
      co_poldet
   WHERE
      usuario = pusuario
   AND
      fecha_captura = pfecha_trab
   AND
      moneda = tmomoneda
   AND
      naturaleza = "C"
   AND
      empresa = pempresa;

   IF (v_creditos IS NULL) THEN
      LET v_creditos = 0;
   END IF

   IF (v_debitos is null) then
      LET v_debitos = 0;
   END IF

   IF (v_debitos <> v_creditos) then
      LET w_cod_ret = "106";
      INSERT INTO
      co_auditpase
      VALUES
      (pusuario,tmomoneda,pfecha_trab,tmosecuencia,pempresa,
       tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
       tmosector,tmonro_auxiliar,w_cod_ret);
   END IF
END FOREACH

LET v_monant = " ";

SELECT MAX(numero) INTO tmocontrol_poliza
FROM bdicont:co_ctrlpoliza;

FOREACH
   SELECT *
   INTO
      tmousuario,
      tmofecha_captura,
      tmosecuencia,
      tmoempresa,
      tmoccmayor,
      tmoccsub,
      tmoccsubsub,
      tmoccssubsub,
      tmoccsssubsub,
      tmosector,
      tmociudad,
      tmosucursal,
      tmonro_auxiliar,
      tmonaturaleza,
      tmomonto,
      tmodescripcion_det,
      tmofecha_valida,
      tmomoneda,
      tmocentro_costo
   FROM  co_poldet
   WHERE empresa = pempresa
   AND   fecha_captura = pfecha_trab
   AND   usuario = pusuario
   ORDER BY moneda, secuencia

   IF tmomoneda != v_monant THEN
      LET tmocontrol_poliza = tmocontrol_poliza + 1;
      UPDATE bdicont:co_ctrlpoliza SET numero=tmocontrol_poliza;

   -- CAMBIO 26/08/2002 JLG
      INSERT INTO co_poliza
      VALUES (pempresa,
              pusuario,
              tmocontrol_poliza,
              pfecha_trab,
              0, 0, 0, tmomoneda,"X");
   END IF

   SELECT
      tipo_cuenta,
      auxiliar
   INTO
      v_tipo_cuenta,
      v_auxiliar
   FROM
      bdinteg:si_catalog
   WHERE
       empresa    = pempresa
   AND ccmayor    = tmoccmayor
   AND ccsub      = tmoccsub
   AND ccsubsub   = tmoccsubsub
   AND ccssubsub  = tmoccssubsub
   AND ccsssubsub = tmoccsssubsub
   AND sector     = tmosector;

   IF (v_tipo_cuenta IS NULL) THEN
      LET w_cod_ret = "100";       {Cuenta contable no existe}
      INSERT INTO
      co_auditpase
      VALUES
      (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
       tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
       tmosector,tmonro_auxiliar,w_cod_ret);
   END IF;

   if w_cod_ret != "100" then
      IF v_tipo_cuenta = "T" THEN
         LET w_cod_ret = "101";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      END IF

      IF (v_auxiliar = "N") THEN
         IF (tmonro_auxiliar <> " ") THEN
            LET w_cod_ret = "118";
            INSERT INTO
            co_auditpase
            VALUES
            (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
             tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
             tmosector,tmonro_auxiliar,w_cod_ret);
         END IF
      ELSE
         {SELECT
            cve_ciudad
         INTO
            v_regional
         FROM
            bdinteg:si_ptf
         WHERE
            id_ptf = tmosucursal
         AND
            tipo <> 'C' ;
         /*SELECT
            ciudad
         INTO
            v_regional
         FROM
            bdinteg:si_sucursales
         WHERE
            empresa = pempresa
         AND
            sucursal = tmosucursal;*/

         LET tmonro_auxiliar = v_regional||"0"||tmonro_auxiliar[5,12];}

         SELECT
            numero
         INTO
            v_aux
         FROM
            co_auxiliar
         WHERE
            empresa = pempresa
         AND
            numero = tmonro_auxiliar;

         IF (v_aux is null) THEN
            --LET w_cod_ret = "102";
            --INSERT INTO
            --co_auditpase
            --VALUES
            --(tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
            -- tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
            -- tmosector,tmonro_auxiliar,w_cod_ret);
            
            {SELECT nombre,
		   sucursal
	    INTO   
	    FROM bdinteg:si_ejecut
	    WHERE ejecutivo=tmonro_auxiliar[5,12];}
            
            INSERT INTO
            bdicont:co_auxiliar(empresa,numero,tp_persona,
			apell_paterno,apell_materno,nombre1,nombre2,
			razon_soc,
			dom_calle_nro,dom_colonia,dom_delegacion,dom_poblacion,dom_codpost,
			telefono,rfc_alfa,rfc_nro,rfc_homo,sector,sucursal,
			nacionalidad,num_referencia,
			adicionado,fecha_alta,modificado,fecha_mod,
			estatus)
            VALUES
            (pempresa,tmonro_auxiliar,"01",
             'NVO AUXILIAR','NVO AUXILIAR','NVO AUXILIAR','',
             NULL,
             'POR ASIGNAR','POR ASIGNAR','POR ASIGNAR','POR ASIGNAR','11111',
             '','','','','32',tmonro_auxiliar[1,4],
             '001','',
             tmonro_auxiliar[1,4],tmofecha_captura,tmonro_auxiliar[1,4],tmofecha_captura,
             'S');

         END IF
      END IF

      SELECT
         id_ptf
      INTO
         v_sucursal
      FROM
         bdinteg:si_ptf
      WHERE
          id_ptf = tmosucursal
      AND tipo <> 'C';
      /*SELECT
         sucursal
      INTO
         v_sucursal
      FROM
         bdinteg:si_sucursales
      WHERE
         empresa  = pempresa
      AND sucursal = tmosucursal;*/

      IF (v_sucursal is null) THEN
         LET w_cod_ret = "103";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      END IF

      LET v_region = 0;
      SELECT count(*)
      INTO v_region
      FROM bdinteg:si_regional
      WHERE empresa = tmoempresa
      AND   regional = tmociudad;

      IF v_region <= 0 THEN
         LET w_cod_ret = "105";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      end if

      LET tmovalor_cambio = 0;
      LET tmovalor_div_cambio = 0;
      LET tmomca_aplic = " ";
      LET tmopoliza_usuario = "099";
      LET tmotipo_mov = " ";
      
     IF w_cod_ret = "00000" THEN
         INSERT INTO co_detpol VALUES
         (tmousuario,
          tmocontrol_poliza,
          tmofecha_captura,
          tmosecuencia,
          tmoempresa,
          tmoccmayor,
          tmoccsub,
          tmoccsubsub,
          tmoccssubsub,
          tmoccsssubsub,
          tmosector,
          tmociudad,
          tmosucursal,
          tmonro_auxiliar,
          tmonaturaleza,
          tmomonto,
          tmodescripcion_det,
          tmofecha_valida,
          tmomoneda,
          tmovalor_cambio,
          tmovalor_div_cambio,
          tmomca_aplic,
          tmopoliza_usuario,
          tmotipo_mov,
          tmocentro_costo);
      END IF
      LET  v_monant = tmomoneda;
   end if
END FOREACH

SELECT COUNT(*)
INTO   v_cuantos
FROM   co_auditpase
WHERE  usuario = pusuario
AND    empresa = pempresa
AND    fecha_captura = pfecha_trab;

IF v_cuantos = 0 THEN
   FOREACH
      SELECT UNIQUE control_poliza
      INTO          tmocontrol_poliza
      FROM co_detpol
      WHERE empresa = pempresa
      AND   fecha_captura = pfecha_trab
      AND   usuario = pusuario

     EXECUTE PROCEDURE act_encab_ant(pempresa,pusuario,pfecha_trab,tmocontrol_poliza) INTO w_cod_ret;
   END FOREACH
END IF

return w_cod_ret;

end procedure;