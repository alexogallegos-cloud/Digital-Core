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
            ciudad
         INTO
            v_regional
         FROM
            bdinteg:si_sucursales
         WHERE
            empresa = pempresa
         AND
            sucursal = tmosucursal;

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
         sucursal
      INTO
         v_sucursal
      FROM
         bdinteg:si_sucursales
      WHERE
         empresa  = pempresa
      AND sucursal = tmosucursal;

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