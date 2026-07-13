CREATE PROCEDURE "informix".consrecursos(pEmpresa char(3), pNumeroCuenta char(20))

-- DATOS A REGRESAR --
RETURNING char(5),     -- Codigo de retorno
          char(2),     -- Procedencia apertura
          char(2),     -- Procedencia mantener
          char(2),     -- Monto
          char(2),     -- Dep. Cantidad
          char(2),     -- Dep. Monto
          char(2),     -- Ret. Cantidad
          char(2),     -- Ret. Monto
          char(60),    -- Procedencia apertura descripcion
          char(60),    -- Procedencia mantener descripcion
          char(60),    -- Monto descripcion
          char(60),    -- Dep. Cantidad descripcion
          char(60),    -- Dep. Monto descripcion
          char(60),    -- Ret. Cantidad descripcion
          char(60),    -- Ret. Monto descripcion
          char(2),     -- Forma de Apertura
          money(14,2), -- Monto de Apertura
          CHAR(20)     -- Cuenta de Cargo

-- VARIABLES --
DEFINE vCodRet          char(5);
DEFINE vp_aper          char(2);
DEFINE vp_mant          char(2);
DEFINE vm_mensual       char(2);
DEFINE vd_cant          char(2);
DEFINE vd_monto         char(2);
DEFINE vr_cant          char(2);
DEFINE vr_monto         char(2);

DEFINE vp_aper_desc     char(60);
DEFINE vp_mant_desc     char(60);
DEFINE vm_mensual_desc  char(60);
DEFINE vd_cant_desc     char(60);
DEFINE vd_monto_desc    char(60);
DEFINE vr_cant_desc     char(60);
DEFINE vr_monto_desc    char(60);
DEFINE vforma_aper      char(2);
DEFINE vmonto_aper      money(14,2);
DEFINE vcta_cargo       char(20);
DEFINE vprodcrec        char(4);
DEFINE vprodcta     char(4);


-- INICIALIZACION DE VARIABLES --
LET vCodRet         ="000";
LET vp_aper         ="";
LET vp_mant         ="";
LET vm_mensual      ="";
LET vd_cant         ="";
LET vd_monto        ="";
LET vr_cant         ="";
LET vr_monto        ="";
LET vp_aper_desc    ="";
LET vp_mant_desc    ="";
LET vm_mensual_desc ="";
LET vd_cant_desc    ="";
LET vd_monto_desc   ="";
LET vr_cant_desc    ="";
LET vr_monto_desc   ="";
LET vforma_aper     = "";
LET vmonto_aper     = 0;
LET vcta_cargo      = "";
LET vprodcrec       = "";
LET vprodcta        = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT valor 
  INTO vprodcrec
  FROM bdicheq:sc_param
 WHERE empresa = pEmpresa
   AND codparam = "PRODCREC";

if exists (select cuenta 
             from bdicheq:sc_maechq 
            where empresa = pEmpresa 
              and cuenta = pNumeroCuenta) Then
            
    SELECT producto 
      INTO vprodcta
      FROM bdicheq:sc_maechq
     WHERE empresa = pEmpresa
       AND cuenta = pNumeroCuenta;

    IF vprodcta = vprodcrec THEN

        SELECT proced_aperturacta, proced_mantenercta, monto_mensual, depositos_cantidad, 
               depositos_monto, retiros_cantidad, retiros_monto, imp_chq_rem, instrucc, cuentadep
          INTO vp_aper, vp_mant, vm_mensual, vd_cant, vd_monto,
               vr_cant, vr_monto, vmonto_aper, vforma_aper, vcta_cargo
          FROM bdicheq:sc_maechq a, bdicheq:sc_maeinstrucc b
         WHERE a.empresa =  pEmpresa 
           AND a.cuenta =  pNumeroCuenta
           AND b.empresa = a.empresa
           and b.cuenta = a.cuenta
           and b.capint = "R";
    ELSE
        SELECT proced_aperturacta, proced_mantenercta, monto_mensual,
               depositos_cantidad, depositos_monto,
               retiros_cantidad, retiros_monto, imp_chq_rem, "", ""
          INTO vp_aper, vp_mant, vm_mensual, vd_cant, vd_monto,
               vr_cant, vr_monto, vmonto_aper, vforma_aper, vcta_cargo
          FROM bdicheq:sc_maechq a
         WHERE a.empresa =  pEmpresa 
           AND a.cuenta =  pNumeroCuenta;
    END IF

    SELECT {+INDEX(si_tipo_procedencia idx_procedencia), +INDEX(si_tipo_montomes idx_montomes), +INDEX(si_tipo_nummov idx_nummov), +INDEX(si_tipo_montomov idx_montomov)} 
           a.descripcion, d.descripcion, b.descripcion, c.descripcion
      INTO vp_aper_desc, vm_mensual_desc, vd_cant_desc, vd_monto_desc
      FROM bdinteg:si_tipo_procedencia a,
           bdinteg:si_tipo_nummov b,
           bdinteg:si_tipo_montomov c,
           bdinteg:si_tipo_montomes d
     WHERE a.procedencia = vp_aper 
       and b.codnummo = vd_cant 
       and c.codnummonto = vd_monto 
       and d.codigo = vm_mensual;

    SELECT {+INDEX(si_tipo_procedencia idx_procedencia), +INDEX(si_tipo_nummov idx_nummov), +INDEX(si_tipo_montomov idx_montomov)} 
           a.descripcion, b.descripcion, c.descripcion
      INTO vp_mant_desc, vr_cant_desc, vr_monto_desc
      FROM bdinteg:si_tipo_procedencia a,
           bdinteg:si_tipo_nummov b,
           bdinteg:si_tipo_montomov c
     WHERE a.procedencia = vp_mant 
       and b.codnummo = vr_cant 
       and c.codnummonto = vr_monto;

    RETURN vCodRet, vp_aper, vp_mant, vm_mensual, vd_cant, vd_monto, vr_cant, vr_monto,vp_aper_desc, vp_mant_desc,
           vm_mensual_desc, vd_cant_desc, vd_monto_desc, vr_cant_desc, vr_monto_desc, vforma_aper,
           vmonto_aper, vcta_cargo;

end if;

END PROCEDURE;