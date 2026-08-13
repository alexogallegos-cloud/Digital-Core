CREATE FUNCTION "informix".sp_consulta_cte_cvv2din_tjts(pcte varchar (11))
    RETURNING char (5) as codigo ,char(100) as descripcion,
    varchar(16) as numtarjeta,varchar(5) as fechaexp,char (1) as estatus,
    varchar(15) as creditodebito, varchar(2) as tipo, varchar(150) as descproducto, decimal(19,4) as saldo;


DEFINE cCodret char (5);
DEFINE vMensaje char (100);
DEFINE vEstatusCVV2 char (1);
DEFINE isam_err  integer;
DEFINE vsqlerr   integer;
DEFINE error_info varchar(80);
DEFINE vNumTarjeta varchar(16);
DEFINE vFechaexp varchar(5);
DEFINE vExisteRegistro smallint;
DEFINE vCuentaTarjetas integer;
DEFINE vCuentaTarjetasA integer;
DEFINE vCredDeb        varchar(1);
DEFINE vCuenta         varchar(15);
DEFINE vTipo           varchar(2);
DEFINE vSaldoActual    decimal(19,4);
DEFINE vDescProducto varchar(150);
DEFINE vFechaexpM varchar(2);
DEFINE vFechaexpA varchar(4);
DEFINE vFechaExpT date;
DEFINE vCodigos char (5);
DEFINE vDescripcion char (100);

---EXECUTE PROCEDURE SALDO CHEQUES
DEFINE vcod_ret CHAR(5);
DEFINE vcuentasp CHAR(20);
DEFINE vnro_cte CHAR(20);
DEFINE vapell_pat CHAR(26);
DEFINE vapell_mat CHAR(26);
DEFINE vnombre1 CHAR(26);
DEFINE vnombre2 CHAR(26);
DEFINE vrazon_soc CHAR(60);
DEFINE vsta_cta CHAR(1);
DEFINE vsdo_disp MONEY(14,2);
DEFINE vsdo_ret MONEY(14,2);
DEFINE vsdo_ccc MONEY(14,2);
DEFINE vsdo_disp_ccc MONEY(14,2);
DEFINE vsdo_cta MONEY(14,2);
DEFINE vtipo_linea CHAR(1);
DEFINE vdescrip1 CHAR(40);
DEFINE vdescrip2 CHAR(40);
DEFINE vsdo_t1 MONEY(14,2);
DEFINE vsdo_cong MONEY(14,2);
DEFINE vimp_chq_sbc MONEY(14,2);
DEFINE vusubloq CHAR(8);
DEFINE vfecbloq DATE;
DEFINE vFechaTarjeta DATE;
DEFINE vStatus CHAR(4);
DEFINE vnum_tarjeta CHAR(16);
DEFINE vcta_clabe CHAR(18);
DEFINE vtarjetacliente CHAR(18);
DEFINE vtajetaregistrada CHAR(18);
DEFINE vAnioExp INTEGER;
DEFINE vMesExp INTEGER;
DEFINE vFechaExpC DATE;
DEFINE vFechaExpConcat DATE;
DEFINE vExisteRegistro2 smallint;
DEFINE vExisteRegistro3 smallint;
DEFINE vexistetarjeta smallint;

    --Set debug file to "/informix/argoz/cvvdinamico/consulta_cvv2.out";
    --trace on;

BEGIN
	ON EXCEPTION SET vsqlerr,isam_err, error_info
        IF vsqlerr <> 0 THEN
			LET  vMensaje  = error_info;
			LET cCodret=vsqlerr;
			LET vEstatusCVV2='E';
           RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual;
        END IF;
    END EXCEPTION;
	
	
	LET cCodret='00000';
	LET vCodigos='00000';
	LET vMensaje='';
    LET vDescripcion='';
	LET vEstatusCVV2='';
	LET vNumTarjeta='';
	LET vFechaexp='';
	LET vExisteRegistro=0;
	LET vExisteRegistro2=0;
	LET vExisteRegistro3=0;
	LET vCuentaTarjetas=0;
	LET vCuentaTarjetasA=0;
	LET vtarjetacliente = '';
	LET vCredDeb='';
	LET vCuenta='';
	LET vTipo='';
	LET vSaldoActual=0;
	LET vDescProducto='';
	LET vFechaexpM='';
	LET vFechaexpA='';
	LET vAnioExp=0;
	LET vMesExp=0;
	LET vFechaExpC='';
	LET vFechaExpConcat='';
	LET vexistetarjeta=0;
	LET vFechaTarjeta='';
	LET vStatus='';
	
	
	-----VARIABLES SP CHEQUES
	LET vcod_ret='';
	LET vcuenta='';
	LET vnro_cte='';
	LET vapell_pat='';
	LET vapell_mat='';
	LET vnombre1='';
	LET vnombre2=''; 
	LET vrazon_soc='';
	LET vsta_cta='';
	LET vsdo_disp=0;
	LET vsdo_ret=0;
	LET vsdo_ccc=0;
	LET vsdo_disp_ccc=0;
	LET vsdo_cta=0;
	LET vtipo_linea='';
	LET vdescrip1='';
	LET vdescrip2='';
	LET vsdo_t1=0; 
	LET vsdo_cong=0;
	LET vimp_chq_sbc=0;
	LET vusubloq='';
	LET vfecbloq=CURRENT;
	LET vnum_tarjeta='';
	LET vcta_clabe='';

	
	
	IF  (pcte IS NULL) OR (pcte='') THEN
	   LET cCodret='00100';
		LET vEstatusCVV2='N';
		LET vMensaje='Numero cliente vacio';
		RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual;
	END IF;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) 
		INTO vCuentaTarjetasA
	FROM intercard:tarjeta
	WHERE numcliente=pcte
	AND codstatustarjeta IN ('ACT','INA','BLO','BLT');
	
	IF vCuentaTarjetasA=0 THEN 
        LET cCodret='00300';
        LET vEstatusCVV2='T';
        LET vMensaje='No tiene tarjetas activas';
        RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual;
	END IF;
	
	LET vFechaExpT=(extend(today, year to month) +0 units month)::date;

	FOREACH

		SELECT numtarjeta,(SUBSTR(fechaexp,3,4)||'/'||'01'||'/'||'20'||SUBSTR(fechaexp,1,2))::date fecha_concat ,codstatustarjeta
		INTO vtarjetacliente,vFechaTarjeta,vStatus
		FROM intercard:tarjeta 
		WHERE numcliente = pcte
		AND codproductotarjeta NOT IN('007')
		AND codstatusasignada = 'SIA'
		 
		LET vExisteRegistro2 = dbinfo("sqlca.sqlerrd2");

		IF vExisteRegistro2 > 0 AND vFechaTarjeta >= vFechaExpT and vStatus IN ('ACT','INA','BLO','BLT') THEN
			SELECT numtarjeta 
			INTO vtajetaregistrada
			FROM intercard:tarjeta_indicadores 
			WHERE numtarjeta = vtarjetacliente
			AND cvv2dinamico = 'V';
			LET vexistetarjeta = dbinfo("sqlca.sqlerrd2");

			IF vexistetarjeta == 0 THEN
	
				EXECUTE PROCEDURE intercard:sp_registro_cte_cvv2din(pcte)
				INTO vCodigos, vDescripcion;
			ELSE 
				CONTINUE FOREACH;
			END IF;
		END IF;
	END FOREACH;
	
	FOREACH
    
     SELECT DISTINCT {+AVOID_FULL intercard:tarjeta}t.numtarjeta,t.fechaexp,p.tipoproducto,(SUBSTR(fechaexp,3,4)||'/'||'01'||'/'||'20'||SUBSTR(fechaexp,1,2))::date fecha_concat
            INTO vNumTarjeta,vFechaexp,vTipo,vFechaExpConcat
                FROM intercard:tarjeta t
                    LEFT JOIN intercard:producto_tipo p
                    ON t.codproductotarjeta = p.codproductotarjeta
                    WHERE t.numcliente=pcte
                    AND (SUBSTR(fechaexp,3,4)||'/'||'01'||'/'||'20'||SUBSTR(fechaexp,1,2))::date >= vFechaExpT 
                    AND t.codstatustarjeta  IN ('ACT','INA','BLO','BLT')
                    AND t.codproductotarjeta NOT IN ('007')
					AND t.codstatusasignada = 'SIA'
                    
                    SELECT DISTINCT {+AVOID_FULL intercard:tarjeta} creditodebito INTO vCredDeb FROM intercard:bines WHERE bin = SUBSTR(vNumTarjeta,1,6) ;
                    SELECT DISTINCT {+AVOID_FULL intercard:tarjeta} cvv2dinamico INTO vEstatusCVV2 FROM intercard:tarjeta_indicadores WHERE numtarjeta = vNumTarjeta AND cvv2dinamico = 'V' ;
                    SELECT DISTINCT {+AVOID_FULL intercard:tarjeta} numcuenta INTO vCuenta FROM intercard:tarjetacuenta WHERE numtarjeta = vNumTarjeta ;
                                
		LET vFechaexpM=SUBSTRING(vFechaexp from 3 for 4);
		LET vFechaexpA=SUBSTRING(vFechaexp from 1 for 2);
		LET vFechaexp= vFechaexpM || '/' || vFechaexpA;
        
        --IF creado para validar las tarjetas expiradas y no incluir la condicion dentro de la
        --consulta empleada en el FOREACH asÃÂ­ como la funcion substr en el campo fecha de expiracion
        IF (vFechaExpConcat >= vFechaExpT) THEN
            IF (vCredDeb='D') THEN
                IF vTipo='DT' THEN
                    SELECT nombre
                        INTO vDescProducto
                    FROM bdicheq:sc_producto pr
                    WHERE producto= SUBSTR(vCuenta,1,4);
                    
                    LET vSaldoActual=0;
                    
                ELIF vTipo='DD' AND substr(vNumTarjeta,1,8)='40081904' THEN
                
                    SELECT nombre
                        INTO vDescProducto
                    FROM bdicheq:sc_producto pr
                        INNER JOIN bdicheq:sc_maechq ma 
                            ON (pr.producto=ma.producto)
                    WHERE ma.cuenta = vCuenta;
                    
                    LET vSaldoActual=0;
                    
                ELSE
                        
                    SELECT nombre
                    INTO vDescProducto
                    FROM bdicheq:sc_producto pr
                    INNER JOIN bdicheq:sc_maechq ma
                        ON (pr.producto=ma.producto)
                    WHERE ma.cuenta = vCuenta;
                    
                    
                    EXECUTE PROCEDURE bdicheq:cons_sdos1("001",vCuenta, vNumTarjeta)
                        INTO vcod_ret,vcuentasp,vnro_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vsta_cta,vSaldoActual,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
                            vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe;
                    
                END IF;
            
            ELSE
                SELECT nombre_prod
                    INTO vDescProducto
                FROM bdicred:sd_definicion df
                INNER JOIN bdicred:sd_maecred ma
                ON df.num_producto=ma.num_producto
                WHERE ma.num_credito=vCuenta;
                
                SELECT monto_otorgado - (sdo_cap_insoluto + sdo_retenido)
                    INTO vSaldoActual
                FROM bdicred:sd_maesdos
                WHERE num_credito=vCuenta;
                
            END IF;                 
                 
        ELSE 

            CONTINUE FOREACH;
        END IF;
            
		
		RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual WITH RESUME;
			
        LET vExisteRegistro = dbinfo("sqlca.sqlerrd2");
	
	END FOREACH;
	
	
	IF vExisteRegistro=0 THEN 
		LET cCodret='00100';
		LET vEstatusCVV2='N';
		LET vMensaje='No existen registros en tabla tarjeta_indicadores';
		RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual;
	END IF;
	
	IF vCodigos != '00000' THEN
	    LET cCodret=vCodigos;
		LET vEstatusCVV2='N';
		LET vMensaje=vDescripcion;
		RETURN cCodret,vMensaje,vNumTarjeta,vFechaexp,vEstatusCVV2,vCredDeb,vTipo,vDescProducto,vSaldoActual;
	END IF;

END;
END FUNCTION;