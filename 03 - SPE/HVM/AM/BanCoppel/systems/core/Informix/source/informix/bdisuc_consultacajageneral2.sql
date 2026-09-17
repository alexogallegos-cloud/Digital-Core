CREATE PROCEDURE "informix".consultacajageneral2(pempresa char(3), pcodproveedor char(4), pRegistros INTEGER, pRecuperacion INTEGER)
returning char(5), char (3), char (4), char (2), money (14), money (14), money (14),
          char (18), char (18), char (18), char (18), char (18), char (18), char (18),
          char (18), char (18), char (18), char (18), char (18), char (18), char (18),
          char (18), float (8), float (8), float (8), float (8), float (8), float (8),
          float (8), float (8), float (8), float (8), float (8), float (8), float (8), float (8),
          float (8), char (30), char (30), char(3), char(40),float (8),float(8), money(19,2), integer;
          
    define vcodret char(5);
    define vsqlerr integer;
    define vempresa char (3);
    define vcod_proveedor char (4);
    define vdivisa char (2);
    define vsaldo_anterior money (14);
    define vsaldo_asignado money (14);
    define vsaldo_total money (14);
    define vdenominacion_1 char (18);
    define vdenominacion_2 char (18);
    define vdenominacion_3 char (18);
    define vdenominacion_4 char (18);
    define vdenominacion_5 char (18);
    define vdenominacion_6 char (18);
    define vdenominacion_7 char (18);
    define vdenominacion_8 char (18);
    define vdenominacion_9 char (18);
    define vdenominacion_10 char (18);
    define vdenominacion_11 char (18);
    define vdenominacion_12 char (18);
    define vdenominacion_13 char (18);
    define vdenominacion_14 char (18);
    define vdenominacion_15 char (18);
    define vcantidad_1 float (8);
    define vcantidad_2 float (8);
    define vcantidad_3 float (8);
    define vcantidad_4 float (8);
    define vcantidad_5 float (8);
    define vcantidad_6 float (8);
    define vcantidad_7 float (8);
    define vcantidad_8 float (8);
    define vcantidad_9 float (8);
    define vcantidad_10 float (8);
    define vcantidad_11 float (8);
    define vcantidad_12 float (8);
    define vcantidad_13 float (8);
    define vcantidad_14 float (8);
    define vcantidad_15 float (8);
    define vdescripcion char (30);
    define vdescdivisa char(30);
    define vplaza char(3);
    define vnomplaza char(40);
    define vsaldo_disponible float(8);
    define vbill_det float(8);
    define vtotal_det float(8);
    define vcant_1d float(8);
    define vcant_2d float(8);
    define vcant_3d float(8);
    define vcant_4d float(8);
    define vcant_5d float(8);
    define vcant_6d float(8);
    define msaldo_autorizado money(19,2);
    define iporcentaje_variacion integer;
    define iExiste integer;

    let vcodret = "000";
    let  vsqlerr = 0;
    let vempresa = "";
    let vcod_proveedor = "";
    let vdivisa = "";
    let vsaldo_anterior = 0;
    let vsaldo_asignado = 0;
    let vsaldo_total = 0;
    let vdenominacion_1 = "";
    let vdenominacion_2  = "";
    let vdenominacion_3  = "";
    let vdenominacion_4  = "";
    let vdenominacion_5  = "";
    let vdenominacion_6  = "";
    let vdenominacion_7  = "";
    let vdenominacion_8  = "";
    let vdenominacion_9  = "";
    let vdenominacion_10 = "";
    let vdenominacion_11 = "";
    let vdenominacion_12 = "";
    let vdenominacion_13 = "";
    let vdenominacion_14 = "";
    let vdenominacion_15 = "";
    let vcantidad_1 = 0;
    let vcantidad_2 = 0;
    let vcantidad_3 = 0;
    let vcantidad_4 = 0;
    let vcantidad_5 = 0;
    let vcantidad_6 = 0;
    let vcantidad_7 = 0;
    let vcantidad_8 = 0;
    let vcantidad_9 = 0;
    let vcantidad_10 = 0;
    let vcantidad_11 = 0;
    let vcantidad_12 = 0;
    let vcantidad_13 = 0;
    let vcantidad_14 = 0;
    let vcantidad_15 = 0;
    let vdescripcion  = "";
    let vdescdivisa = "";
    let vplaza = "";
    let vnomplaza= "";
    let vsaldo_disponible = 0;
    let vbill_det = 0;
    let vtotal_det = 0;
    let vcant_1d = 0;
    let vcant_2d = 0;
    let vcant_3d = 0;
    let vcant_4d =0;
    let vcant_5d = 0;
    let vcant_6d = 0;
    let msaldo_autorizado = 0.0;
    let iporcentaje_variacion = 0;
    let iExiste = 0;

    --- set debug file to "condirec.out";
    --- trace on;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3, vdenominacion_4,
                   vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11, vdenominacion_12,
                   vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6, vcantidad_7,
                   vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15, vdescripcion, vdescdivisa, vplaza,
                   vnomplaza,vsaldo_disponible,vbill_det,msaldo_autorizado,iporcentaje_variacion;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 5;

    if pcodproveedor = "0000" then
        foreach
            SELECT SKIP pRegistros FIRST pRecuperacion cg.empresa, cg.cod_proveedor, cg.divisa, cg.saldo_anterior, cg.saldo_asignado, cg.saldo_total, cg.denominacion_1, cg.denominacion_2,
                   cg.denominacion_3, cg.denominacion_4, cg.denominacion_5, cg.denominacion_6, cg.denominacion_7, cg.denominacion_8, cg.denominacion_9,
                   cg.denominacion_10, cg.denominacion_11, cg.denominacion_12, cg.denominacion_13, cg.denominacion_14, cg.denominacion_15, cg.cantidad_1,
                   cg.cantidad_2, cg.cantidad_3, cg.cantidad_4, cg.cantidad_5, cg.cantidad_6, cg.cantidad_7, cg.cantidad_8, cg.cantidad_9, cg.cantidad_10,
                   cg.cantidad_11, cg.cantidad_12, cg.cantidad_13, cg.cantidad_14, cg.cantidad_15,cg.cantidad_1d,
                   cg.cantidad_2d, cg.cantidad_3d, cg.cantidad_4d, cg.cantidad_5d, cg.cantidad_6d, pro.descripcion, div.descripcion, pro.plaza, plz.descripcion,
			       cg.saldo_autorizado, cg.pcjte_variacion
              INTO vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3, vdenominacion_4,
                   vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11, vdenominacion_12,
                   vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6, vcantidad_7,
                   vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15,vcant_1d,vcant_2d,vcant_3d,
                   vcant_4d,vcant_5d,vcant_6d, vdescripcion, vdescdivisa,
                   vplaza, vnomplaza,msaldo_autorizado,iporcentaje_variacion
              FROM bdisuc:ss_cajageneral cg 
              left join bdisuc:ss_proveedores pro on (pro.cod_proveedor =  cg.cod_proveedor) 
              left join bdinteg:si_divisas div on (div.divisa =  cg.divisa) 
              left join bdinteg:si_plazas_cajagen plz on (plz.codigo_plaza = pro.plaza)
              
            let vbill_det = ((vdenominacion_1 * vcant_1d) + (vdenominacion_2 * vcant_2d) + (vdenominacion_3 * vcant_3d) + (vdenominacion_4 * vcant_4d) + (vdenominacion_5 * vcant_5d) + (vdenominacion_6 * vcant_6d));
            let vsaldo_total =vsaldo_total + vsaldo_asignado;
            let vsaldo_asignado = vsaldo_asignado - vbill_det;
            let vsaldo_disponible = vsaldo_total - (vsaldo_asignado + vbill_det) ;
            
            return vcodret, vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3,
                   vdenominacion_4, vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11,
                   vdenominacion_12, vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
                   vcantidad_6, vcantidad_7, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15,
                   vdescripcion, vdescdivisa, vplaza, vnomplaza, vsaldo_disponible,vbill_det,msaldo_autorizado,iporcentaje_variacion with resume;
        end foreach;
    else
        --- if exists (select cod_proveedor from ss_proveedores where cod_proveedor = pcodproveedor) Then
        select cod_proveedor 
          into iExiste
          from ss_proveedores 
         where cod_proveedor = pcodproveedor;
             
        if iExiste > 0 then
            foreach
                SELECT SKIP pRegistros FIRST pRecuperacion cg.empresa, cg.cod_proveedor, cg.divisa, cg.saldo_anterior, cg.saldo_asignado, cg.saldo_total, cg.denominacion_1, cg.denominacion_2,
                       cg.denominacion_3, cg.denominacion_4, cg.denominacion_5, cg.denominacion_6, cg.denominacion_7, cg.denominacion_8, cg.denominacion_9,
                       cg.denominacion_10, cg.denominacion_11, cg.denominacion_12, cg.denominacion_13, cg.denominacion_14, cg.denominacion_15, cg.cantidad_1,
                       cg.cantidad_2, cg.cantidad_3, cg.cantidad_4, cg.cantidad_5, cg.cantidad_6, cg.cantidad_7, cg.cantidad_8, cg.cantidad_9, cg.cantidad_10,
                       cg.cantidad_11, cg.cantidad_12, cg.cantidad_13, cg.cantidad_14, cg.cantidad_15,cg.cantidad_1d,
                       cg.cantidad_2d, cg.cantidad_3d, cg.cantidad_4d, cg.cantidad_5d, cg.cantidad_6d, pro.descripcion, div.descripcion, pro.plaza, plz.descripcion,
					   cg.saldo_autorizado, cg.pcjte_variacion
                  INTO vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3, vdenominacion_4,
                       vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11, vdenominacion_12,
                       vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6, vcantidad_7,
                       vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15,
                       vcant_1d,vcant_2d,vcant_3d,
                       vcant_4d,vcant_5d,vcant_6d, vdescripcion, vdescdivisa,
                       vplaza, vnomplaza,msaldo_autorizado,iporcentaje_variacion
                  FROM bdisuc:ss_cajageneral cg 
                  left join bdisuc:ss_proveedores pro on (pro.cod_proveedor =  cg.cod_proveedor) 
                  left join bdinteg:si_divisas div on (div.divisa =  cg.divisa) 
                  left join bdinteg:si_plazas_cajagen plz on (plz.codigo_plaza = pro.plaza)
                 WHERE cg.cod_proveedor = pcodproveedor
                 ORDER BY cod_proveedor
                 
                let vbill_det = ((vdenominacion_1 * vcant_1d) + (vdenominacion_2 * vcant_2d) + (vdenominacion_3 * vcant_3d) + (vdenominacion_4 * vcant_4d) + (vdenominacion_5 * vcant_5d) + (vdenominacion_6 * vcant_6d));
                let vsaldo_total =vsaldo_total + vsaldo_asignado;
                let vsaldo_asignado = vsaldo_asignado - vbill_det;
                let vsaldo_disponible = vsaldo_total - (vsaldo_asignado + vbill_det);
                
                return vcodret, vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3,
                       vdenominacion_4, vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11,
                       vdenominacion_12, vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
                       vcantidad_7, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15, vdescripcion, vdescdivisa,
                       vplaza, vnomplaza,vsaldo_disponible,vbill_det,msaldo_autorizado,iporcentaje_variacion with resume;
            end foreach;
        else
            let vcodret = '101';
            
            return vcodret, vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3,
                   vdenominacion_4, vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11,
                   vdenominacion_12, vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
                   vcantidad_7, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15, vdescripcion, vdescdivisa,
                   vplaza, vnomplaza,vsaldo_disponible,vbill_det,msaldo_autorizado,iporcentaje_variacion;
        end if;
    end if;
    
    end
    
end procedure
document 'SPL Clonado de bdisuc:consultacajageneral para el manejo de paginacion',
'AUTOR: Oscar Flores Conde',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 08/03/2017',
'DESCRIPCION: Se modifico el SPL para agregar los campos saldo autorizado, rango minimo, rango maximo y el indicador.',
'FUNCIONALIDAD: Monitor de Efectivo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_cajagen()

RETURNING CHAR(5), CHAR(100), CHAR(4), CHAR(40);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE msj CHAR(100);
DEFINE vcod_proveedor CHAR(4);
DEFINE vdescripcion CHAR(40);

LET cod_ret = '00000';
LET msj = 'Operación exitosa';
LET vcod_proveedor = '';
LET vdescripcion = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;
        LET msj = ERROR_INFO;
        RETURN cod_ret, msj, vcod_proveedor, vdescripcion;
    END EXCEPTION;

    set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT {+index(bdisuc:"informix".ss_proveedores idx01ss_proveedores)}
               cod_proveedor, SUBSTR(descripcion, 14)
          INTO vcod_proveedor, vdescripcion
          FROM bdisuc:"informix".ss_proveedores
         ORDER BY descripcion

        RETURN cod_ret, msj, vcod_proveedor, vdescripcion WITH RESUME;
    END FOREACH;
END;

END PROCEDURE;