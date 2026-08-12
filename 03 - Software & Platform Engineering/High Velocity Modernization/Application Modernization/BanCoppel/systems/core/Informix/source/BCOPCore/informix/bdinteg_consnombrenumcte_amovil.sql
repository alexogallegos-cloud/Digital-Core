CREATE PROCEDURE "informix".consnombrenumcte_amovil(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pPaterno CHAR(26),
                        pMaterno CHAR(26),
						pFechaNac DATE,
						pNo_Rfc CHAR(13),
						pRazon CHAR(60),
                        pSecuencia SMALLINT)

--RETURNING CHAR(5) as cod_ret,CHAR(60) as nombre_completo ,CHAR(20) as numcte,CHAR(13) as rfc,CHAR(2) as tipo_cte;
RETURNING CHAR(5) as cod_ret, CHAR(60) as nombre_completo, CHAR(26) as Nombre1 ,CHAR(26) as Nombre2,CHAR(26) as Paterno,CHAR(26) as Materno,CHAR(20) as numcte,CHAR(13) as rfc,CHAR(2) as tipo_cte, DATE as fech_nac;

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);
DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(26);
DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);
DEFINE v_tipocte 								  CHAR(2);
DEFINE v_f_nac                                    DATE;

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";
LET v_tipocte = "";
LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_paterno = "";
LET v_materno = "";
LET v_f_nac = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret,v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte, v_rfc,v_tipocte,v_f_nac;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_cod_ret, v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte, v_rfc, v_tipocte, v_f_nac;
END IF;

SET ISOLATION TO DIRTY READ;

IF pRazon IS NOT NULL AND pRazon !="" THEN
    FOREACH
        SELECT skip pSecuencia limit 21
             cte.razon_social,cte.numcte,cte.rfc,cte.tipo_cliente,cpm.fecha_constitct
 	    INTO v_razon_soc,v_numcte,v_rfc,v_tipocte,v_f_nac
        FROM si_cliente as cte, si_ctepm as cpm 
        WHERE cte.razon_social = prazon
           and cte.apell_paterno = ''
	       and cte.apell_materno = ''
           and cte.numcte = cpm.numcte
        ORDER BY cte.numcte
--        LET v_ciclo = v_ciclo+1;
--        IF v_ciclo <= psecuencia THEN
-- 	        CONTINUE FOREACH;
--        END IF;
        LET v_nombre_completo = v_razon_soc;
        RETURN v_cod_ret,v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte,v_rfc,v_tipocte,v_f_nac WITH RESUME;
    END FOREACH;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
        FOREACH
            SELECT skip pSecuencia limit 21
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc,tipo_cliente,pf.fecha_nac
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_tipocte,v_f_nac
      	    FROM si_ctepf pf, si_cliente cl
      	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte
--      	    LET v_ciclo = v_ciclo+1;
--      	    IF v_ciclo <= psecuencia THEN
--                 CONTINUE FOREACH;
--      	    END IF;
	        LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
	        RETURN v_cod_ret,v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte,v_rfc,v_tipocte,v_f_nac WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS

--	IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
	IF NVL(pPaterno,'') = ''  THEN
		LET v_cod_ret = "00002";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
		RETURN v_cod_ret, v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte, v_rfc,v_tipocte,v_f_nac;
--	ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
	ELIF NVL(pNombre1,'') = '' THEN
		LET v_cod_ret = "00003";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
		RETURN v_cod_ret, v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte,v_rfc,v_tipocte,v_f_nac;
	ELSE
        if ( pPaterno is null or pPaterno = "" ) then
           let pPaterno = "";
        else
           let pPaterno = trim(pPaterno)||"*";
        end if;

        if ( pMaterno is null or pMaterno = "" ) then
           let pMaterno = "";
        else
           let pMaterno = trim(pMaterno)||"*";
        end if;

        if ( pNombre1 is null or pNombre1 = "" ) then
           let pNombre1 = "";
        else
           let pNombre1 = trim(pNombre1)||"*";
        end if;

        if ( pNombre2 is null or pNombre2 = "" ) then
           let pNombre2 = "";
        else
           let pNombre2 = trim(pNombre2)||"*";
        end if;

--		LET pPaterno = TRIM(pPaterno)||"*";
--		LET pMaterno = TRIM(pMaterno)||"*";
--		LET pNombre1 = TRIM(pNombre1)||"*";
--		LET pNombre2 = TRIM(pNombre2)||"*";

		IF NVL(pFechaNac,'') <> '' THEN
			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc,tipo_cliente,pf.fecha_nac
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_tipocte,v_f_nac
				FROM si_ctepf pf, si_cliente cl
				WHERE cl.apell_paterno matches ppaterno
				AND cl.apell_materno matches pmaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo + 1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				RETURN v_cod_ret,v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte,v_rfc,v_tipocte,v_f_nac WITH RESUME;
			END FOREACH;

		ELSE

			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc,tipo_cliente
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_tipocte
				FROM si_cliente cte, si_ctepf pf
				WHERE apell_paterno matches ppaterno
				AND apell_materno matches pmaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo+1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				RETURN v_cod_ret,v_nombre_completo, v_nombre1, v_nombre2, v_paterno, v_materno, v_numcte,v_rfc,v_tipocte,v_f_nac WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'Consulta clientes por nombre(s) y apellido(s) y por fecha de nacimiento y regresa el tipo de cliente se usa en Apertura Movil',
'AUTOR : Ismael Hernandez',
'FECHA : 08/11/2010',
'BD    : bdinteg',
'VER   : 1.0';

create procedure "informix".sp_consejecutivomac(pejecutivo char(8), pmac char(12))
       returning char(5),char(1) ;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;


define vmac char(12);
define vstatus char(1);
define vmach char(1) ;
define vsucursal char(4) ;
define vdepto char(3) ;
define vpuesto char(3) ;
define varea char(3) ;

let vmach="0" ;
let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vmac = "";
let vstatus = "";
let vsucursal = "";
let vdepto = "";
let vpuesto = "";
let varea = "";

set isolation to dirty read;
set lock mode to wait 3;

begin

   on exception set vsqlerr
      if vsqlerr <> 0 then
	 -- rollback work;
         let vcodret = vsqlerr;
         return vcodret,vmac ;
      end if;
   end exception;

-- Begin work;

        Select sucursal, departamento, puesto
        into vsucursal, vdepto, vpuesto
        from si_ejecut
        where ejecutivo = pejecutivo;

        if cast(nvl(vsucursal,'0') as int) > 0 and cast(nvl(vdepto,'0') as int) = 0 then

            Select {+INDEX(si_macarea idx_si_macarea)} area
            into varea
            From si_macarea
            where sucursal='0001' and puesto = vpuesto;

            if exists(Select ejecutivo From si_macejecutivo where ejecutivo = pejecutivo) then
                Foreach
                    Select mac, status
                    into vmac, vstatus
                    from si_macejecutivo
                    where ejecutivo = pejecutivo

                    if exists(Select {+INDEX(si_sucursalesmaquina idx_si_sucursalesmaquina)} mac From si_sucursalesmaquina where sucursal = trim(vmac) and area = varea and mac = upper(pmac)) then
                        if vstatus in ('A','T') then
                            let vmach='1';
                            exit Foreach;
                        else
                            let vmach='2';
                        end if;
                    else
                         let vmach='3';
                    end if;
                end Foreach;
            else
                let vmach='3';
            end if;

        else
            if exists(select me.mac from si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac)) then
                if exists(select me.mac from si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac) and me.status in ('A','T')  ) then
                    let vmach='1';
                else
                    let vmach='3';
                end if;
            else
                let vmach='2';
            end if;
        end if;

     return    vcodret,vmach ;

-- commit work;

end
end procedure
DOCUMENT
"regresa mac",
"Autor : Daniel Zambada, Modificó: Frank Gaxiola",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_conciliarcatalogocalles()

RETURNING CHAR(6), CHAR(80);

------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE vnumerocalle                     INTEGER;
DEFINE vnombrecalle                     CHAR(30);
DEFINE v_numerocalle                    INTEGER;
DEFINE vfechahoy                        DATE;

DEFINE vdia                             DATE;
DEFINE vHora                            CHAR(8);
DEFINE vEmpresa                         CHAR(3);
DEFINE vProceso                         CHAR(30);
DEFINE vProcesoinicio                   CHAR(30);
------------------------------------------------------------
LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = 'Proceso Exitoso';
LET vnumerocalle  = 0;
LET vnombrecalle  = '';
LET v_numerocalle = 0;

LET vEmpresa       = '001';
LET vProceso       = 'sp_conciliarcatalogocalles';
LET vProcesoinicio = 'PROCESO INICIALIZADO';
/*
Creado por José Almeida
Fecha de creacion 22 de octubre de 2009
Deberá instalarse en BDINTEG
Se creo para el conciliamiento de datos
de las calles que existen en el catalogo de coppel
con los de bancoopel, aquellas calles que existen en
coppel y no bancoppel seran insertadas en el catalogo
*/
      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
           
            INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 

            
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
	    
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
        VALUES (vProceso,'11111' , vProcesoinicio, user, vdia, vHora, null); 

	    
        ---------------Obtenemos la fecha de Hoy-----------------
        SELECT fecha_hoy 
        INTO   vfechahoy
        FROM   bdinteg:si_fechas;
        
        ---------------Borramos los datos de la tabla para insertar nuevos conciliados--------
        DELETE si_catcalles_bcpl_cpl;
        
        --------------Obtenemos los datos de las dos tablas y cuando no existan en bancoopel-----
        --------------se insertaran en el catalogo de bancoopel-----------------------------------
     FOREACH 
        SELECT a.numerocalle, a.nombrecalle, b.numerocalle
        INTO   vnumerocalle, vnombrecalle, v_numerocalle
        FROM   BDINTEG:si_catcalles_coppel a  
        LEFT OUTER JOIN BDINTEG:si_catcalles b ON (a.numerocalle = b.numerocalle)
        
                    IF ( v_numerocalle IS NULL )  THEN
                            
        INSERT INTO BDINTEG:si_catcalles_bcpl_cpl (numerocalle, fecha_conciliacion, tipo_actualizacion) 
                                   VALUES (vnumerocalle, vfechahoy, 'I');
        
                          ---Agregar que inserte directamente en si_catcalles
                          INSERT INTO bdinteg:si_catcalles (numerocalle, nombrecalle, f_inserta)
                                      VALUES(vnumerocalle, vnombrecalle, vfechahoy);
                                   
        UPDATE     BDINTEG:si_catcalles_coppel SET b_conciliado = 'V' WHERE numerocalle = vnumerocalle;             
                                   
                     END IF;
                     
      END FOREACH;
        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 

      
                 RETURN cCod_ret, cMensaje;
        END;
        END PROCEDURE;