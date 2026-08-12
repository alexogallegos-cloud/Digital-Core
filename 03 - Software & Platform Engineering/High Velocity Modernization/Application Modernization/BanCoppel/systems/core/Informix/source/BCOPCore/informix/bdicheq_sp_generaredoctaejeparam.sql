CREATE PROCEDURE "informix".sp_generaredoctaejeparam (pEmpresa char(3), pFechaIni date, pFechaFin date)


RETURNING CHAR(5);

---Elaborado por : Jose Almeida
--Fecha: 17-06-2009
--Generar los estados de cuenta eje mensualmente por aniviersario y mesiversario.
---Modificó: Lorenzo Ibarra Garcia
--Fecha: 10-07-2009
--*Se cambio el tipo de la variable vSaldoProm ya que estaba como int y debe de ser MONEY(14,2).
--*Se modificó la forma en que se toma la fecha para las consultas ya qeu se estaba tomando la fecha actual cuando se debe de tomar
--la fecha de ayer ya que la información de la tabla sc_maehis está hasta esa fecha.
--*Se cambiaron de posición las variables vdeposito y vretiro ya que se estaban mandando mal al momento de hacer la inserción en ta tabla sc_detalle_edocta.
--Fecha de modificacion  20-06-2009
---Modifico José Almeida
--Se tomo el aniomes del registro en sc_movhis de donde se obtiene el
--mesiversario y se igualó a null, el saldo, retiro, deposito, y fecha de alta cuando la nlinea sea igual o mayor a 2.
--Cuando se toma la fecha_hoy de sc_fechas, ya no se toma de el campo sc
---Modificó: Lorenzo Ibarra Garcia
--Fecha:21-07-2009
--*Se modificó la empresa como parametro de entrada para que fuera un char(3)
--*La fecha de alta de las cuentas se estaba obteniendo de la sc_maehis cuando deberia de ser de la sc_maenoc.
--*Se cambió la parte donde se hace el control del proceso para que lo hiciera por medio de System ya que la hora de inicio y fin de proceso era la misma.
---Modificó: Lorenzo Ibarra Garcia
--Fecha:03-08-2009
--*Se agregaron las variables dFechaInicioMovimientos y dFechaFinMovimientos para pasarlas como parámetro al sp_GenerarEdoCtaEjeDetalle en vez de pasarle el añomes.
--*Se modificó la forma de saber una cuenta ha tenido movimientos en los últimos 6 meses, obteniendo el total de movimientos por un rango de fechas.
--*Se modificó la obtención del aniomes ya que se obtenia con un MAX, ahora se obtiene con la fechafin.
--*Se quitó la fecha por default para cuando el proceso no haya sido corrido, en vez de eso la fecha por default es el mes anterior al corrido del proceso.
---Modificó: Lorenzo Ibarra Garcia
--Fecha:10-08-2009
--*Se agregó el calculo para la fecha de emisión que ira insertada en cada una de las tablas del estado de cuenta la cual se obtiene con el dia_mesiversario de la tabla sc_configuracion_edocta.
--*Se modifico la parte donde se obtienen las cuentas para obtenerlas de la tabla sc_maehis.
--*Se modificó la validación donde se obtiene si una cuenta esta cumpliendo su aniversario.
--*Se quito el ciclo donde se traia las cuentas por un rango de fechas, en vez de eso se obtienen con un between.
--*Se quitó la fecha por default de la última ejecución del proceso que indicaba que se obtuvieran las cuentas de un mes anterior, 
--ahora si no se ha corrido el proceso solo se obtienen la cuentas de la sc_maehis con fechafin igual a la fecha_ant.
--*Cuando sea la segunda linea del detalle los campos deposito, retiro y saldo deben de ir con 0.00 en vez de null y la fechamov con '01-01-1900'
---Modificó: Lorenzo Ibarra Garcia
--Fecha:02-09-2009
--*Se corrigió la parte que genenera el calculo para la fecha de emisión que va insertada en cada una de las tablas del estado de cuenta.
--*Se agrego el codigo de retorno '006' para indicar que el dia_mesiversario de la tabla sc_configuracion_edocta es invalido.
--*Se calcula la fecha de emision anterior para saber si una cuenta corresponde al periodo anterior o al que sigue.
---Modificó: Lorenzo Ibarra Garcia
--Fecha:08-09-2009
--*Se corrigió la parte que calcula la fecha de emision anterior para que ya no le calcule un mes a la fecha de ultima ejecución
---Modificó: Lorenzo Ibarra Garcia, Bernardo Baez
--Fecha:18-09-2009
--*Se modificó el guardado de control de proceso que se hacia con un SYSTEM para que ahora lo haga con un INSERT directo.
--*Se agregó un BETWEEN en la parte del FOREACH para pasar por un rango de fechas a la tabla sc_encabezado_edocta.
--*Se calcula la fecha de emision que se le pasará al SP sp_GenerarEdoCtaEjeTXT.

DEFINE vaniomes CHAR(6);
DEFINE vcortSig CHAR(255);
DEFINE vcortSig2 INTEGER;
DEFINE vsecuencia INTEGER;
DEFINE vnlinea INTEGER;
DEFINE vidreg INTEGER;
DEFINE vultejec DATE;
DEFINE vmensajegeneraArch CHAR(80);
DEFINE vfecha_hoy DATE;
DEFINE vfecha_ant, vfechaAlta DATE;
DEFINE vcodret CHAR(5);
DEFINE vsqlerr, visamerr, vaniversario INTEGER;
DEFINE vcuenta CHAR(20);
DEFINE vSaldoProm MONEY(14,2);
DEFINE vacumSdo MONEY(14,2);
DEFINE vdiaSdo SMALLINT;
DEFINE vPrimDiaMes  DATE;
DEFINE vnumCte CHAR(20);
DEFINE vempresa CHAR(3);
DEFINE vcodRetspCortSig CHAR(6);
DEFINE vfechCortSig DATE;
DEFINE vcodRetgeneraArch CHAR(6);
DEFINE  vdescripcion CHAR(180);
DEFINE vsdocuenta MONEY(14,2);
DEFINE  vfechealt DATE;
DEFINE  vdeposito MONEY(14,2);
DEFINE vretiro MONEY(14,2);
DEFINE bInicia boolean;
DEFINE cErrorInfo char(80);
DEFINE vErrorInfo char(80);
DEFINE iIsamErr SMALLINT;
DEFINE vhorainicio DATE;
DEFINE vcodretDet CHAR(6);
DEFINE vcodretEnc CHAR(6);
DEFINE vFecha_emision DATE;
DEFINE vNum_cte CHAR(20);
DEFINE vNum_Tarjeta CHAR(16);
DEFINE vNombre_cte CHAR(150);
DEFINE vDireccion_cte CHAR(200);
DEFINE vDireccion_col CHAR(120);
DEFINE vDireccion_del CHAR(120);
DEFINE vEdo_cd CHAR(120);
DEFINE vCve_ruta CHAR(60);
DEFINE vSucursal_nombre CHAR(40);
DEFINE vSucursal_num CHAR(4);
DEFINE vRFC_Cliente CHAR(13);
DEFINE vCP CHAR(5);
DEFINE vCve_ahorro CHAR(60);
DEFINE vClabe CHAR(60);
DEFINE vCurp CHAR(60);
DEFINE vFechaAltaEnc DATE;
DEFINE vFechaInicio DATE;
DEFINE vMensajeProducto CHAR(255);
DEFINE vInserto CHAR(15);
DEFINE vSaldoAnterior DECIMAL(16,2);
DEFINE vDepositos DECIMAL(16,2);
DEFINE vInteresesPagados DECIMAL(16,2);
DEFINE vRetiros DECIMAL(16,2);
DEFINE vOtrosCargos DECIMAL(16,2);
DEFINE vIvaOtrosCargos DECIMAL(16,2);
DEFINE vSaldoCorte DECIMAL(16,2);
DEFINE vSaldoPromedio DECIMAL(16,2);
DEFINE vRetencionIsr DECIMAL(16,2);
DEFINE vInteresesNetos DECIMAL(16,2);
DEFINE viDias SMALLINT;
DEFINE vTasaBruta DECIMAL(9, 6);
DEFINE vPiePagina CHAR(255);
DEFINE vfechaFinal DATE;
DEFINE dFechaInicioMovimientos DATE;
DEFINE dFechaFinMovimientos DATE;
DEFINE vDiaMesiversario SMALLINT;
DEFINE dFechaEmisionSig DATE;
DEFINE dFechaEmisionAnt DATE;
DEFINE dFechaNacimiento DATE;
DEFINE dDiaPrimero DATE;
DEFINE dDiaUltimo DATE;
DEFINE iMesEmision SMALLINT;
DEFINE iAnioEmision INTEGER;
DEFINE cRetornoSPdias CHAR(6);
DEFINE vUltEjecImp DATE;
DEFINE dFechaTope DATE;
DEFINE dFechaEmision DATE;

LET vaniomes = "";
LET vcodretDet = "";
LET vcodretEnC = "";
LET vhorainicio = "";
LET cErrorInfo="";
LET vErrorInfo= "INICIO DEL PROCESO";
LET vcortSig2 = 0;
LET vcortSig = "";
LET vsecuencia = 0;
LET vnlinea =0;
LET vidreg = 0;
LET vultejec = '';
LET vUltEjecImp = '';
LET vmensajegeneraArch = "";
LET vsqlerr = 0;
LET vdeposito = 0;
LET vretiro = 0;
LET vfechealt = "";
LET vsdocuenta = 0;
LET vdescripcion = "";
LET vempresa = "";
LET vnumCte= "";
LET vcuenta = "";
LET vfechaAlta = "";
LET vcodret = "000";
LET vfecha_hoy = "";
LET vfecha_ant = "";
LET vaniversario = 0;
LET bInicia = "F";
LET iIsamErr = 0;
LET vFecha_emision = "01-01-1900";
LET vNum_cte = "";
LET vNum_Tarjeta = "";
LET vNombre_cte = "";
LET vDireccion_cte = "";
LET vDireccion_col = "";
LET vDireccion_del = "";
LET vEdo_cd = "";
LET vCve_ruta = "";
LET vSucursal_nombre = "";
LET vSucursal_num  = "";
LET vRFC_Cliente = "";
LET vCP = "";
LET vCve_ahorro = "";
LET vClabe = "";
LET vCurp = "";
LET vFechaAlta = "";
LET vFechaInicio = "";
LET vMensajeProducto = "";
LET vInserto = "";
LET vSaldoAnterior = 0;
LET vDepositos = 0;
LET vInteresesPagados = 0;
LET vRetiros = 0;
LET vOtrosCargos = 0;
LET vIvaOtrosCargos = 0;
LET vSaldoCorte = 0;
LET vSaldoPromedio = 0;
LET vacumSdo = 0;
LET vRetencionIsr = 0;
LET vInteresesNetos = 0;
LET viDias = 0;
LET vTasaBruta = 0;
LET vPiePagina  = "";
LET vfechaFinal = "";
LET dFechaInicioMovimientos = '01-01-1900';
LET dFechaFinMovimientos = '01-01-1900';
LET vDiaMesiversario = 0;
LET dFechaEmisionSig = '01-01-1900';
LET dFechaEmisionAnt = '01-01-1900';
LET dFechaNacimiento = '01-01-1900';
LET dDiaPrimero = "01-01-1900";
LET dDiaUltimo = "01-01-1900";
LET iMesEmision = 0;
LET iAnioEmision = 0;
LET cRetornoSPdias = 0;
LET vUltEjecImp = '';
LET dFechaTope = "01-01-1900";
LET dFechaEmision = '01-01-1900';

--SET DEBUG FILE TO "/pisa/lflores/sp_GenerarEdoCtaEje.out";
--TRACE ON;

BEGIN
 ---***************************************************************************************************************************************************
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            LET vErrorInfo = cErrorInfo;
            IF bInicia="T" THEN
                ROLLBACK Work;
            END IF;
			{
			UPDATE bdicheq:sc_contproc_edocta 
			SET status_proc = 'C', cod_ret = vcodret, mensaje = vErrorInfo,
			hora_fin = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
			(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
			FROM bdicheq:sc_fechas WHERE empresa = pempresa)
			WHERE fecha = vfecha_hoy
			AND  status_proc = 'I'
			AND tipo_proc  = 'D';
            }
            RETURN vcodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    
    IF TRIM(pEmpresa) = '' OR pEmpresa IS NULL THEN
        LET vcodret = '001';
        RETURN vcodret;
    ELSE    
        --obtener la fecha de ayer y hoy
        SELECT {+INDEX(sc_fechas idx_fechas1)}
               fecha_ant, fecha_hoy
          INTO vfecha_ant, vfecha_hoy
          FROM BDICHEQ:sc_fechas
	 WHERE empresa = pEmpresa;
	    LET vfecha_ant = pFechaIni;
		LET vfecha_hoy = pFechaIni + 1 ;
		
        
        --obtener el dia en que se descargan los archivos de texto
        SELECT {+INDEX(sc_configuracion_edocta idx_diamesiv)} 
	       dia_mesiversario
          INTO vDiaMesiversario
          FROM sc_configuracion_edocta
	 WHERE dia_mesiversario IS NOT NULL;
     
        --validar que el dia_mesiversario sea un dia valido
        IF vDiaMesiversario < 1 OR vDiaMesiversario > 31 THEN
            LET vcodret = '006';
            RETURN vcodret;
        END IF;

        --armar la fecha de emision siguiente
        LET iMesEmision = MONTH(vfecha_ant);
        LET iAnioEmision = YEAR(vfecha_ant);      
        
        IF DAY(vfecha_ant) < vdiaMesiversario THEN
        
            EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((iMesEmision)::char(2),(iAnioEmision)::char(4))
            INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;  
            
            IF DAY(dDiaUltimo) <= vdiaMesiversario THEN
                LET dFechaEmisionSig = dDiaUltimo;
            ELSE
                LET dFechaEmisionSig = MDY(iMesEmision, vDiaMesiversario, iAnioEmision);
            END IF;
        ELSE
            IF (iMesEmision +1) = 13 THEN
                LET iMesEmision = 1;
                LET iAnioEmision = iAnioEmision + 1;
            ELSE
                LET iMesEmision = iMesEmision + 1;
            END IF;
            EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((iMesEmision)::char(2),(iAnioEmision)::char(4))
            INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;
            
            IF DAY(dDiaUltimo) <= vdiaMesiversario THEN
                LET dFechaEmisionSig = dDiaUltimo;
            ELSE
                LET dFechaEmisionSig = MDY(iMesEmision, vDiaMesiversario, iAnioEmision);
            END IF;
        END IF;
        

        --obtener la fecha en que se ejecuto por ultima vez el proceso diario.
        SELECT {+INDEX(sc_contproc_edocta idx_contproc_edocta)} 
	      MAX(fecha)
          INTO vultejec
          FROM sc_contproc_edocta
         WHERE proceso = 'GENERA EDO CTA EJE'
	   AND empresa = pEmpresa
	   AND status_proc = 'F'
           AND tipo_proc = 'D';
		LET vultejec=pFechaIni-1;
           
        IF vultejec IS NULL THEN
            SELECT {+INDEX(sc_contproc_edocta idx_contproc_edocta)} 
            NVL(MAX(fecha - 1 UNITS DAY),vfecha_ant)
            INTO vultejec
            FROM sc_contproc_edocta
            WHERE proceso = 'GENERA EDO CTA EJE'
            AND empresa = pEmpresa
            AND (status_proc = 'C' or status_proc = 'I')
            AND tipo_proc = 'D';
        END IF;
       
        --obtener la fecha en que se ejecuto por ultima vez el proceso de impresion.
        SELECT {+INDEX(sc_contproc_edocta idx_contproc_edocta)} 
	      MAX(fecha)
          INTO vUltEjecImp
          FROM sc_contproc_edocta
         WHERE proceso = 'GENERA ARCH CTA EJE'
	   AND empresa = pEmpresa
	   AND status_proc = 'F'
           AND tipo_proc = 'I';

        	
        IF vUltEjecImp IS NULL THEN
            SELECT {+INDEX(sc_contproc_edocta idx_contproc_edocta)} 
            NVL(MAX(fecha),vfecha_ant)
            INTO vUltEjecImp
            FROM sc_contproc_edocta
            WHERE proceso = 'GENERA ARCH CTA EJE'
            AND empresa = pEmpresa
            AND status_proc = 'C'
            AND tipo_proc = 'I';
        END IF;
        
        --armar la fecha de emision anterior
        LET iMesEmision = MONTH(vultejec);
        LET iAnioEmision = YEAR(vultejec);      
        
        EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((iMesEmision)::char(2),(iAnioEmision)::char(4))
        INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;  
            
        IF DAY(dDiaUltimo) <= vdiaMesiversario THEN
            LET dFechaEmisionAnt = dDiaUltimo;
        ELSE
            LET dFechaEmisionAnt = MDY(iMesEmision, vDiaMesiversario, iAnioEmision);
        END IF;

        IF vultejec < vfecha_hoy THEN --si no se ejecuto hoy
            
            --si no hay registro de que el proceso haya quedado inconcluso se inserta uno nuevo, sino solo se actualiza
           -- IF NOT EXISTS(SELECT {+INDEX(sc_contproc_edocta idx_contproc_edocta)} empresa 
			--    FROM sc_contproc_edocta 
			--   WHERE proceso = 'GENERA EDO CTA EJE' 
			--     AND fecha = vfecha_hoy 
			--     AND empresa = pEmpresa 
			 ---    AND (status_proc = 'C' or status_proc = 'I') 
			--     AND tipo_proc  = 'D') THEN
				
			--	INSERT INTO BDICHEQ:sc_contproc_edocta (empresa, proceso, fecha, tipo_proc, status_proc, ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje) 
			--	VALUES(pempresa, 'GENERA EDO CTA EJE',vfecha_hoy, 'D', 'I', USER, 
			--	(SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
			--	(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
			--	FROM bdicheq:sc_fechas WHERE empresa = pempresa), 
			--	NULL, vcodret, vErrorInfo);
				
           -- ELSE
			
			--	UPDATE bdicheq:sc_contproc_edocta 
			--	SET status_proc =  'I',
			--	hora_inicio = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
			--	(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
			--	FROM bdicheq:sc_fechas WHERE empresa = pempresa),
			--	hora_fin = NULL 
			--	WHERE fecha = vfecha_hoy
			--	AND status_proc = 'C'
			--	AND  tipo_proc = 'D';

            --END IF;
            
            WHILE dFechaTope <> vfecha_ant
                --obtener la fecha hasta la que se obtendran las cuentas
                IF vultejec < dFechaEmisionAnt THEN
                    IF vUltEjecImp >= dFechaEmisionAnt THEN
                        IF vUltEjecImp > dFechaEmisionAnt THEN
                            IF vfecha_ant < dFechaEmisionAnt THEN                                    
                                LET dFechaTope = vfecha_ant;
                                LET dFechaEmision = dFechaEmisionAnt; 
                            ELSE
                                    LET dFechaTope = dFechaEmisionAnt - 1 UNITS DAY;
                                    LET dFechaEmision = dFechaEmisionAnt;
                            END IF;
                        ELSE
                            LET dFechaTope = vfecha_ant;
                            LET dFechaEmision = dFechaEmisionSig;                        
                        END IF;
                    ELSE 
                        IF EXISTS(SELECT fecha FROM sc_contproc_edocta WHERE proceso = 'GENERA ARCH CTA EJE' AND empresa = pEmpresa) THEN
                            IF vfecha_ant < dFechaEmisionAnt THEN                                    
                                LET dFechaTope = vfecha_ant;
                                LET dFechaEmision = dFechaEmisionAnt; 
                            ELSE
                                LET dFechaTope = dFechaEmisionAnt - 1 UNITS DAY;
                                LET dFechaEmision = dFechaEmisionAnt;
                            END IF;
                        ELSE
                            LET dFechaTope = vfecha_ant;
                            LET dFechaEmision = dFechaEmisionAnt;
                        END IF;
                    END IF;
                ELSE
                    LET dFechaTope = vfecha_ant;
                    LET dFechaEmision = dFechaEmisionSig;
                END IF;            
              
                FOREACH WITH HOLD
                    --obtener las cuentas que sean participantes y que cumplan su aniversario o mesiversario
                    SELECT Mae.aniomes, Mae.cuenta, Mae.num_cte, Mae.fechaini, Mae.fechafin, Mae.acum_sdo_pos, Mae.dia_sdo_pos
                      INTO vaniomes, vcuenta, vnumCte, dFechaInicioMovimientos, dFechaFinMovimientos, vacumSdo, vdiaSdo
                      FROM bdicheq:sc_maehis AS Mae, 
                   bdicheq:sc_prod_participan_edocta AS PP
                     WHERE Mae.empresa = pEmpresa
                   AND Mae.cuenta not in (SELECT EE.num_cuenta 
                            FROM bdicheq:sc_encabezado_edocta EE 
                           WHERE EE.fechafinal BETWEEN pFechaIni AND pFechaFin
                             AND Mae.cuenta = EE.num_cuenta)
                AND Mae.aniomes between(select min(aniomes) from sc_maehis)and 
                                (select max(aniomes) from sc_maehis)
                 AND Mae.fechafin BETWEEN pFechaIni AND pFechaFin
                         AND PP.Producto=Mae.Producto
                      -- AND PP.empresa= pEmpresa
                      -- AND Mae.empresa = PP.empresa
                         AND PP.gpo_producto = 'CH' 
                      -- AND Mae.Producto = PP.Producto
               
                       

                    --verificar que la cuenta no tenga ligada una inversi?n creciente o un pagar?
                    IF NOT EXISTS( SELECT CHQ.cuenta
                                                FROM bdicheq:SC_MAECHQ CHQ
                                                WHERE CHQ.EMPRESA = pEmpresa
                                                AND CHQ.producto = '1100'
                                                AND CHQ.status_cta = 1
                                                AND CHQ.NUM_CTE = vnumCte
                                                AND CHQ.CUENTA = vcuenta
                                                AND EXISTS(SELECT INV.EMPRESA FROM bdinvers:SV_MAEINV INV
                                                                        WHERE INV.EMPRESA=CHQ.EMPRESA
                                                                        AND INV.NUM_CTE= CHQ.NUM_CTE
                                                                        AND INV.STATUS_CTA ='1' )) THEN
                        --verificar que la cuenta no tenga ligada una tarjeta de cr?dito
                        IF NOT EXISTS(SELECT numcte FROM bdicred:sd_maecred WHERE numcte = vnumCte) THEN
                            
                            --calcular saldo promedio de la cuenta
                            IF vdiaSdo <>  0 THEN
                                LET vSaldoProm = vacumSdo / vdiaSdo;
                            ELSE
                                LET vSaldoProm = 0;
                            END IF;                            
                            
                            BEGIN WORK;
                            LET bInicia = "T";
                            
                            IF vSaldoProm > 50 THEN

                                --ejecutar el store para llenar el encabezado
                                SELECT NVL(MAX(idreg),0) + 1
                                INTO vidreg
                                FROM bdicheq:sc_encabezado_edocta;

                                EXECUTE PROCEDURE SP_generarEdoCtaejeencabezado(pEmpresa, vcuenta, vaniomes)
                                INTO
                                vcodretEnc,
                                vFecha_emision,
                                vNum_cte,
                                vNum_Tarjeta,
                                vNombre_cte,
                                vDireccion_cte,
                                vDireccion_col,
                                vDireccion_del,
                                vEdo_cd,
                                vCve_ruta,
                                vSucursal_nombre,
                                vRFC_Cliente,
                                vCP,
                                vCve_ahorro,
                                vClabe,
                                vCurp,
                                vFechaAltaEnc,
                                vFechaInicio,
                                vMensajeProducto,
                                vInserto,
                                vfechaFinal,
                                vSucursal_num,
                                vSaldoAnterior,
                                vDepositos,
                                vInteresesPagados,
                                vRetiros,
                                vOtrosCargos,
                                vIvaOtrosCargos,
                                vSaldoCorte,
                                vSaldoPromedio,
                                vRetencionIsr,
                                vInteresesNetos,
                                viDias,
                                vTasaBruta,
                                vPiePagina;
                                --hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado fue satisfactorio
                                IF trim(vcodretEnc) = '000' THEN

                                    INSERT INTO sc_encabezado_edocta
                                    (
                                    idreg,
                                    fecha_emision,
                                    num_cuenta,
                                    num_cte,
                                    num_tarjeta,
                                    nombre_cte,
                                    direccion_cte,
                                    direccion_col,
                                    direccion_del,
                                    edo_cd,
                                    cve_ruta,
                                    sucursal_nombre,
                                    rfc,
                                    cp,
                                    cve_ahorro,
                                    clabe,
                                    curp,
                                    fechaalta,
                                    fechainicio,
                                    mensajeproducto,
                                    inserto,
                                    fechafinal,
                                    sucursal
                                    )
                                    VALUES(
                                    vidreg,
                                    dFechaEmision,
                                    vcuenta,
                                    vNum_cte,
                                    vNum_Tarjeta,
                                    vNombre_cte,
                                    vDireccion_cte,
                                    vDireccion_col,
                                    vDireccion_del,
                                    vEdo_cd,
                                    vCve_ruta,
                                    vSucursal_nombre,
                                    vRFC_Cliente,
                                    vCP,
                                    vCve_ahorro,
                                    vClabe,
                                    vCurp,
                                    vFechaAltaEnc,
                                    vFechaInicio,
                                    vMensajeProducto,
                                    vinserto,
                                    vfechaFinal,
                                    vSucursal_num
                                    );
                                    INSERT INTO sc_encabezado2_edocta
                                    (
                                    idreg,
                                    fecha_emision,
                                    num_cuenta,
                                    saldoanterior,
                                    depositos,
                                    interesespagados,
                                    retiros,
                                    otroscargos,
                                    ivaotroscargos,
                                    saldocorte,
                                    saldopromedio,
                                    retencionisr,
                                    interesesnetos,
                                    dias,
                                    tasabruta
                                    )

                                    VALUES(
                                    vidreg,
                                    dFechaEmision,
                                    vcuenta,
                                    vSaldoAnterior,
                                    vDepositos,
                                    vInteresesPagados,
                                    vRetiros,
                                    vOtrosCargos,
                                    vIvaOtrosCargos,
                                    vSaldoCorte,
                                    vSaldoPromedio,
                                    vRetencionIsr,
                                    vInteresesNetos,
                                    viDias,
                                    vTasaBruta
                                    );

                                    LET vsecuencia = 1;
                                    LET vnlinea = 1;

                                    INSERT INTO sc_piepagina_edocta
                                    (
                                    idreg,
                                    fecha_emision,
                                    num_cuenta,
                                    secuencia,
                                    nlinea,
                                    mensaje
                                    )
                                    VALUES(
                                    vidreg,
                                    dFechaEmision,
                                    vcuenta,
                                    vsecuencia,
                                    vnlinea,
                                    vPiePagina
                                    );

                                ELSE
                                    --si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuci?n
                                    ROLLBACK Work;
                                    LET bInicia = "F";
                                    LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                                    LET vcodret = '003';

									UPDATE bdicheq:sc_contproc_edocta 
									SET status_proc = 'C',
									cod_ret = vcodret,
									mensaje = vErrorInfo,
									hora_fin = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
									(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
									FROM bdicheq:sc_fechas WHERE empresa = pempresa)
									WHERE fecha = vfecha_hoy
									AND  status_proc = 'I'
									AND tipo_proc = 'D';
                                    
                                    RETURN vcodret;
                                END IF;


    ---***************************************************************************************************************************************************
                                --ejecutar store para el detalle

                                LET vsecuencia = 0;

                                FOREACH

                                    EXECUTE PROCEDURE sp_GenerarEdoCtaEjeDetalle(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                                    INTO
                                    vcodretDet,
                                    vdescripcion,
                                    vsdocuenta,
                                    vfechealt,
                                    vdeposito,
                                    vretiro
                                    --si el resultado fue satisfactorio hacer las inserciones para los detalles
                                    IF trim(vcodretDet) = '000' THEN

                                        LET vsecuencia = vsecuencia + 1;
                                        LET vnlinea = 0;

                                        FOREACH
                                            
                                            --cortar los detalles en lineas
                                            EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion,40)
                                            INTO vcortSig, vcortsig2

                                            LET  vnlinea =vnlinea + 1;

                                                IF vnlinea > 1 THEN
                                                       LET vretiro = 0.00;
                                                       LET vdeposito = 0.00;
                                                       LET vsdocuenta = 0.00;
                                                       LET vfechealt = '01-01-1900';
                                                END IF;

                                            INSERT INTO bdicheq:sc_detalle_edocta
                                            (
                                            idreg,
                                            fecha_emision,
                                            num_cuenta,
                                            secuencia,
                                            nlinea,
                                            fechamov,
                                            descripcion,
                                            retiro,
                                            deposito,
                                            saldo
                                            )
                                            VALUES
                                            (
                                            vidreg,
                                            dFechaEmision,
                                            vcuenta,
                                            vsecuencia,
                                            vnlinea,
                                            vfechealt,
                                            vcortSig,
                                            vretiro,
                                            vdeposito,
                                            vsdocuenta
                                            );
                                        END FOREACH;
                                    ELSE
                                        --si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuci?n
                                        IF trim(vcodretDet) <> '002' THEN --002=la cuenta no tiene movimientos
                                            ROLLBACK Work;
                                            LET bInicia = "F";
                                            LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                                            LET vcodret = '004';

											UPDATE bdicheq:sc_contproc_edocta 
											SET status_proc = 'C',
											cod_ret = vcodret,
											mensaje = vErrorInfo,
											hora_fin = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
											(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
											FROM bdicheq:sc_fechas WHERE empresa = pempresa)
											WHERE fecha = vfecha_hoy
											AND  status_proc = 'I'
											AND tipo_proc  = 'D';
                                            
                                            RETURN vcodret;
                                        END IF;
                                    END IF;

                                END FOREACH;


    ---***************************************************************************************************************************************************
                            ELSE --saldo menor igual a 50

                                --obtener la fecha de alta de la cuenta para saber si es su aniversario
                                SELECT fecha_alta
                                INTO vfechaAlta
                                FROM bdicheq:sc_maenoc
                                WHERE cuenta = vcuenta
                                AND empresa = pEmpresa;
                                
                                --obtener el mes y dia de corte para compararlo con la fech_alt
                                LET dFechaNacimiento = dFechaFinMovimientos + 1 UNITS DAY;

                                IF TO_CHAR(vfechaAlta, '%m%d') = TO_CHAR(dFechaNacimiento, '%m%d' ) THEN
                                    LET  vaniversario = 1;
                                ELIF
                                    TO_CHAR(vfechaAlta,'%m%d')  = '0229' AND TO_CHAR(dFechaNacimiento + 1 UNITS DAY, '%m%d') <> '0229'  THEN
                                    IF TO_CHAR(dFechaNacimiento,'%m%d' ) = '0228' THEN
                                        LET vaniversario = 1;
                                    END IF;
                                END IF;

                                IF vaniversario = 1 THEN
                                    
                                    --verificar que la cuenta no tenga movimientos en los ?ltimos 6 meses.
                                    EXECUTE PROCEDURE bdicheq:sp_cortesig(dFechaFinMovimientos,-6)
                                    INTO vcodRetspCortSig, vfechCortSig;
                                    
                                    IF NOT EXISTS (SELECT  Cuenta
                                            FROM bdicheq:sc_movhis
                                            WHERE cuenta = vcuenta
                                            AND fech_alt BETWEEN vfechCortSig AND dFechaFinMovimientos) THEN  
                                            
                                        --ejecutar el store para llenar encabezado
                                        SELECT NVL(MAX(idreg),0) + 1
                                        INTO vidreg
                                        FROM bdicheq:sc_encabezado_edocta;

                                        EXECUTE PROCEDURE SP_GenerarEdoCtaEjeEncabezado(pEmpresa, vcuenta, vaniomes)
                                        INTO
                                        vcodretEnc,
                                        vFecha_emision,
                                        vNum_cte,
                                        vNum_Tarjeta,
                                        vNombre_cte,
                                        vDireccion_cte,
                                        vDireccion_col,
                                        vDireccion_del,
                                        vEdo_cd,
                                        vCve_ruta,
                                        vSucursal_nombre,
                                        vRFC_Cliente,
                                        vCP,
                                        vCve_ahorro,
                                        vClabe,
                                        vCurp,
                                        vFechaAltaEnc,
                                        vFechaInicio,
                                        vMensajeProducto,
                                        vInserto,
                                        vfechaFinal,
                                        vSucursal_num,
                                        vSaldoAnterior,
                                        vDepositos,
                                        vInteresesPagados,
                                        vRetiros,
                                        vOtrosCargos,
                                        vIvaOtrosCargos,
                                        vSaldoCorte,
                                        vSaldoPromedio,
                                        vRetencionIsr,
                                        vInteresesNetos,
                                        viDias,
                                        vTasaBruta,
                                        vPiePagina;
                                        --si el resultado fue satisfactorio hacer las inserciones
                                        IF trim(vcodretEnc) = '000' THEN

                                            INSERT INTO sc_encabezado_edocta
                                            (
                                            idreg,
                                            fecha_emision,
                                            num_cuenta,
                                            num_cte,
                                            num_tarjeta,
                                            nombre_cte,
                                            direccion_cte,
                                            direccion_col,
                                            direccion_del,
                                            edo_cd,
                                            cve_ruta,
                                            sucursal_nombre,
                                            rfc,
                                            cp,
                                            cve_ahorro,
                                            clabe,
                                            curp,
                                            fechaalta,
                                            fechainicio,
                                            mensajeproducto,
                                            inserto,
                                            fechafinal,
                                            sucursal
                                            )
                                            VALUES(
                                            vidreg,
                                            dFechaEmision,
                                            vcuenta,
                                            vNum_cte,
                                            vNum_Tarjeta,
                                            vNombre_cte,
                                            vDireccion_cte,
                                            vDireccion_col,
                                            vDireccion_del,
                                            vEdo_cd,
                                            vCve_ruta,
                                            vSucursal_nombre,
                                            vRFC_Cliente,
                                            vCP,
                                            vCve_ahorro,
                                            vClabe,
                                            vCurp,
                                            vFechaAltaEnc,
                                            vFechaInicio,
                                            vMensajeProducto,
                                            vInserto,
                                            vfechaFinal,
                                            vSucursal_num
                                            );
                                            INSERT INTO sc_encabezado2_edocta
                                            (
                                            idreg,
                                            fecha_emision,
                                            num_cuenta,
                                            saldoanterior,
                                            depositos,
                                            interesespagados,
                                            retiros,
                                            otroscargos,
                                            ivaotroscargos,
                                            saldocorte,
                                            saldopromedio,
                                            retencionisr,
                                            interesesnetos,
                                            dias,
                                            tasabruta
                                            )

                                            VALUES(
                                            vidreg,
                                            dFechaEmision,
                                            vcuenta,
                                            vSaldoAnterior,
                                            vDepositos,
                                            vInteresesPagados,
                                            vRetiros,
                                            vOtrosCargos,
                                            vIvaOtrosCargos,
                                            vSaldoCorte,
                                            vSaldoPromedio,
                                            vRetencionIsr,
                                            vInteresesNetos,
                                            viDias,
                                            vTasaBruta
                                            );

                                            LET vsecuencia = 1;
                                            LET vnlinea = 1;

                                            INSERT INTO sc_piepagina_edocta
                                            (
                                            idreg,
                                            fecha_emision,
                                            num_cuenta,
                                            secuencia,
                                            nlinea,
                                            mensaje
                                            )
                                            VALUES(
                                            vidreg,
                                            dFechaEmision,
                                            vcuenta,
                                            vsecuencia,
                                            vnlinea,
                                            vPiePagina
                                            );

                                        ELSE
                                            --si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuci?n
                                            ROLLBACK Work;
                                            LET bInicia = "F";
                                            LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                                            LET vcodret = '005' ;

											UPDATE bdicheq:sc_contproc_edocta 
											SET status_proc = 'C',
											cod_ret = vcodret,
											mensaje = vErrorInfo,
											hora_fin = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
											(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
											FROM bdicheq:sc_fechas WHERE empresa = pempresa)
											WHERE fecha = vfecha_hoy
											AND  status_proc = 'I'
											AND tipo_proc  = 'D';
                                            
                                            RETURN vcodret;
                                        END IF;
                                    END IF; --si tiene movimientos los ultimos 6 meses
                                END IF; -- IF vaniversario = 1
                            END IF; --finaliza if promedio mayor a 50
                            COMMIT WORK;
                            LET bInicia = "F";
                        END IF; -- finaliza  if  not  exists  en la sd_maecred
                    END IF; -- finaliza  if  not  exists  de las cuentas que no participan
                    
                END FOREACH;
                
                LET vultejec = dFechaTope + 1 UNITS DAY;
            END WHILE;

---**************************************************************************************************************************************************
            
        
            --armar la fecha de emision para los archivos de texto
            LET iMesEmision = MONTH(vfecha_hoy);
            LET iAnioEmision = YEAR(vfecha_hoy);      
            
            EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((iMesEmision)::char(2),(iAnioEmision)::char(4))
            INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;  
                
            IF DAY(dDiaUltimo) <= vdiaMesiversario THEN
                LET dFechaEmision = dDiaUltimo;
            ELSE
                LET dFechaEmision = MDY(iMesEmision, vDiaMesiversario, iAnioEmision);
            END IF;            
            
            --generar archivos de impresi?n si se cumple la fecha para generarlo
            --IF  vfecha_hoy = dFechaEmision THEN

               -- EXECUTE PROCEDURE bdicheq:sp_GenerarEdoCtaEjeTXT(pempresa, dFechaEmision)
               -- INTO vcodRetgeneraArch, vmensajegeneraArch;

            --END IF;
            --actualizar el control de proceso
            LET vErrorInfo = 'PROCESO EXITOSO';
			{
			UPDATE bdicheq:sc_contproc_edocta 
			SET status_proc = 'F',
			cod_ret = vcodret,
			mensaje = vErrorInfo,
			hora_fin = (SELECT (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals) + 
			(fecha_hoy - (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals)) 
			FROM bdicheq:sc_fechas WHERE empresa = pempresa)
			WHERE fecha = vfecha_hoy
			AND  status_proc = 'I'
			AND tipo_proc  = 'D';
            } 
        ELSE --el proceso ya fue ejecutado el dia de hoy        
        
            --armar la fecha de emision para los archivos de texto
            LET iMesEmision = MONTH(vfecha_hoy);
            LET iAnioEmision = YEAR(vfecha_hoy);      
            
            EXECUTE PROCEDURE bdinteg:sp_diaprimeroultimomesanio((iMesEmision)::char(2),(iAnioEmision)::char(4))
            INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;  
            
            IF DAY(dDiaUltimo) <= vdiaMesiversario THEN
                LET dFechaEmision = dDiaUltimo;
            ELSE
                LET dFechaEmision = MDY(iMesEmision, vDiaMesiversario, iAnioEmision);
            END IF;     
            {
            --generar archivos de impresi?n si se cumple la fecha para generarlo
            IF  vfecha_hoy = dFechaEmision THEN
                --generar los archivos de impresion si es la fecha de impresion y no han sido generados
                --IF NOT EXISTS (SELECT +INDEX(sc_contproc_edocta idx_contproc_edocta)  proceso
                                --FROM bdicheq:sc_contproc_edocta
                               -- WHERE proceso = 'GENERA ARCH CTA EJE'
				--AND status_proc = 'F'
                               -- AND tipo_proc = 'I'
                               -- AND fecha = vfecha_hoy) THEN
					
                   -- EXECUTE PROCEDURE bdicheq:sp_GenerarEdoCtaEjeTXT(pempresa, dFechaEmision)
                   -- INTO vcodRetgeneraArch, vmensajegeneraArch;
                    RETURN vcodret;
                ELSE
                    LET  vcodret = '002';-- el proceso ya fue ejecutado el dia de hoy
                    RETURN vcodret;
                END IF;
            ELSE
                LET  vcodret = '002';-- el proceso ya fue ejecutado el dia de hoy
                RETURN vcodret;

            END IF;
			}
        END IF;

    END IF; --si la empresa es null
    RETURN vcodret;
END;
END PROCEDURE;