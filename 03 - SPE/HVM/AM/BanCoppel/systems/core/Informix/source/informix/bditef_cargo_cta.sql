create procedure "informix".cargo_cta( pempresa    char(3),
                                       pcuenta     char(20),
                                       pnrocheque  integer,
                                       pimporte    decimal(16,2),
                                       pmoneda     char(2),
                                       psec_ctl    integer,
                                       pusuario    char(8),
                                       pfecha_hoy  date,
                                       pnomarch    char(30) )
returning char(5),  -- codret
          char(2),  -- motdevol
          char(1),  -- procesado
          char(35), -- msg
          char(4),  -- sucursal
          char(16), -- folio_suc
          char(4);  -- transacc	
    
    -- v1.0 version inicial
    -- bancoppel, eduardo espinosa abr10
    
    define vsqlerr          integer;
    define vcodret          char(5);
    define vmotdevol        char(2);
    define vprocesado       char(1);
    define vmsg             char(35);
    define vcuenta          char(20);
    define vsdodisp         money;
    define vsaldo           money;
    define vstatuscta       char(1);
    define vmotivo          char(2);
    define vchequestat      char(1); 
    define vstatus          char(2);
    define vstatchq         char(1);
    define vcargo           char(1);
    define vcheqgirados     integer;
    define vcheqgratis      integer;
    define vfecha_hoy       date;
    define vfecha2          date;
    define vctavalida       char(1);
    define vfecha_proc_cta  date;
    define vsucursal        char(4);   
    define vfolio           char(16);
    define vtrans           char(4);
    define vimportecom      decimal(16,2);
    define vimporte         decimal(16,2);
    define vcomchqgratis    decimal(16,2);
    define viva             decimal(10,2);
    define viva_cob         decimal(10,2);
    define vmontopend       decimal(16,2);
    define vproducto        char(4);
    define vreferencia      char(40);
    define vtransaccion     char(4);
    define vmontoret        decimal(16,2);
    define vbandera         char(1);
    define vtran_cargo      char(4);
    define vtran_cgodev     char(4);
    define vtran_abodev     char(4);
    define vtran_comdev     char(4);
    define vtran_ivacom     char(4);   
    define vtran_chqgira    char(4);
    define vfuepagado       char(1);
    DEFINE vFormaAplic      CHAR(1);
    define vbco_pres        char(3);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vmvodevv         char (20);
    DEFINE vdevolucion      smallint;
	DEFINE vfechacalendario date;
	DEFINE vComChqGirCob	money;
	DEFINE cTpoPersona		CHAR(1);
	define iExisteBloq		smallint;
	define iOpcionBloq		smallint;
	define vfechaOperacion  date;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    define mSdoActual              MONEY(14,2);
    define mSdoRetenido        	   MONEY(14,2);
    define mSdoCongelado           MONEY(14,2);
    define mSaldoSbc               MONEY(14,2);
    define mImpChqSbg              MONEY(14,2); 
    define cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    define cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    let vcodret          = "000";
    let vfolio           = "0000000000000000";
    let vmotdevol        = "";
    let vmsg             = "";
    let vprocesado       = "0";  
    let vctavalida       = "0";  
    let vbandera         = "0";
    let vcargo           = "S";
    let vfecha_hoy       = pfecha_hoy;
	let vfechacalendario = pfecha_hoy;
    let vfuepagado       = "N";
    let vcomchqgratis    = 0;
    let vfecha_proc_cta  = "";
    let vbco_pres        = "000";
    let vFormaAplic      = "3";
    LET vMontoDif        = 0;
	let vtrans           = "0000";
    let vmvodevv         = "";
    let vdevolucion      = 0;
	let vComChqGirCob	 = 0.0;
	LET cTpoPersona		 = "";
	let iExisteBloq      = 0;
	let iOpcionBloq      = 0;
	let vfechaOperacion  = TODAY;
    --RQM 09 704. Se agregan las siguientes variable DFTL
    let mSdoActual         			= 0;
    let mSdoRetenido           		= 0;
    let mSdoCongelado          		= 0;
    let mSaldoSbc           		= 0;
    let mImpChqSbg      			= 0;
    let cCodRetConsSdo      		= '00000';
    let cMensajeRetConsSdo  		= '';
    let vsucursal = '';

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            ROLLBACK WORK;
            -- grabar el error
            update cce_propios_det
               set cod_ret     = vcodret,
                   usuario_dev = pusuario
             where fecha_entrada = pfecha_hoy
               and secuencia     = psec_ctl
               and c_cuenta      = pcuenta
               and c_cheque      = pnrocheque             
               and nombrearchivo = pnomarch;
               
            return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
        end if
    end exception;
    
    -- set debug file to "/tmp/cargo_cta.out";
	--set debug file to "/informix/moha/cargo_cta.out";
    --trace on;
    
    BEGIN WORK;     
    
    -- si ya se proceso en cce_propios_det salir
    select status
      into vstatus
      from cce_propios_det
     where fecha_entrada = pfecha_hoy
       and secuencia     = psec_ctl
       and c_cuenta      = pcuenta
       and c_cheque      = pnrocheque
       and nombrearchivo = pnomarch;
    
    if vstatus <> "01" then
        let vcodret     = "200";
        let vmsg        = "ya procesado";
        let vprocesado  = "1";
        ROLLBACK;
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;    
    end if
    
	-- Fecha actual
	select fecha_hoy
      into vfechacalendario
      from bdicheq:sc_fechas 
     where empresa = pempresa;
     
    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null or pnrocheque = "" or pnrocheque < 1 then
        let vcodret = "100";
        let vmsg    = "datos de entrada incompletos";
        ROLLBACK;
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if
    
    -- cheques gratis mes
    select valor
      into vcheqgratis
      from bdicntchq:sq_param
     where cod_param = 1; 
    
    if dbinfo("sqlca.sqlerrd2") = 0 then
        let vprocesado  = "0";
        let vcodret     = "101";
        let vmsg        = "no existe param 1 sq_param cheq gratis";
        ROLLBACK;
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if    
    
    -- cargar todos los parametros y transacciones
    -- cargo normal
    select valor
      into vtran_cargo
      from cce_param, bdinteg:si_transacc
     where valor = numero
       and cod_param = 7;
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "121";
        let vmsg = "tran cargo normal no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if       
    
    -- cargo devolucion
    select valor
      into vtran_cgodev
      from cce_param, 
           bdinteg:si_transacc
     where valor = numero
       and cod_param = 8;     
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "122";
        let vmsg = "tran cargo dev no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if 
    
    -- abono devolucion
    select valor
      into vtran_abodev
      from cce_param, 
           bdinteg:si_transacc
     where valor = numero
       and cod_param = 9;  
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "123";
        let vmsg = "tran abono dev no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if     
    
    -- transaccion comision devolucion
    select valor
      into vtran_comdev
      from cce_param, 
           bdinteg:si_transacc
     where valor = numero
       and cod_param = 10;   
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "124";
        let vmsg = "tran com dev no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if  
    
     -- transaccion iva comision
    select valor
      into vtran_ivacom
      from cce_param, 
           bdinteg:si_transacc
     where valor = numero
       and cod_param = 11;  
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "125";
        let vmsg = "tran iva com no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if                
    
    -- transaccion cheque girado
    select valor
      into vtran_chqgira
      from cce_param, 
           bdinteg:si_transacc
     where valor = numero
       and cod_param = 13;   
       
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "126";
        let vmsg = "tran com chq girado no existe";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if 
    
    --- tasa iva
    select valor
      into viva
      from bdinteg:si_param
     where empresa = pempresa   
       and cod_param = 47;
       
    -- no trajo datos
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vcodret = "127";
        let vmsg = "no existe valor iva";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if 
    
    --- comision cheque girado
    -- 3238 com cheque girado                                                               
    let vtrans = vtran_chqgira;
	
    ---- importe de la comision
    select monto_aplica
      into vcomchqgratis
      from bdicheq:sc_comisiones
     where empresa = pempresa 
       and comision = vtrans;

    -- no trajo datos
    if dbinfo("sqlca.sqlerrd2") = 0 then
        ROLLBACK WORK;
        let vmsg = "no existe comision chq girado";
        let vprocesado = "0";                  
        let vcodret = "131";
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
    end if 
    
    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques ï¿½ que si la cuenta esta cancelada (status_cta="2")
    select cuenta, status_cta, motivo, chq_exp_mes, sucursal, producto, fecha_proceso,
		   sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      into vcuenta, vstatuscta, vmotivo, vcheqgirados, vsucursal, vproducto, vfecha_proc_cta,
           mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
      from bdicheq:sc_maechq
     where empresa = pempresa   
       and cuenta = pcuenta;

    --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
	EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo ('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
	INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdodisp;

    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta in("2", "6") then
        let vmotdevol  = "02";
        let vprocesado = "1";
        let vctavalida = "0";
    else
		SELECT tpper_valida
		INTO cTpoPersona
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = "001" 
		AND producto = vproducto;
		
		IF cTpoPersona IN ("2","4","5") AND vproducto IN ("1200","1600","2200") THEN
			SELECT com_chq_gir_cob
			INTO vComChqGirCob
			FROM bdicheq:"informix".sc_maecomtasserv_pm
			WHERE cuenta = pcuenta;
			
			IF vComChqGirCob IS NOT NULL THEN
				LET vcomchqgratis = vComChqGirCob;
			ELIF vComChqGirCob = 0 THEN
				LET vcomchqgratis = 0;
			END IF
		END IF

        -- cta bloqueada pero acepta cargos
        if vstatuscta = "3" then
			select count(*)
			  into iExisteBloq
			  from bdicheq:sc_ctabloqueo
			 where cuenta = pcuenta;
			 
			if iExisteBloq > 0 then
				select opcion
				  into iOpcionBloq
				  from bdicheq:sc_ctabloqueo
				 where cuenta = pcuenta;
				 
				if iOpcionBloq = 1 then
					if pimporte > vsdodisp then
						let vmotdevol   = "09"; -- cuenta bloqueada
						let vprocesado  = "1";
						let vctavalida  = "0";
					end if
				end if
				
				if iOpcionBloq in(3,4) then
					let vmotdevol   = "09"; -- cuenta bloqueada
					let vprocesado  = "1";
					let vctavalida  = "0";
				end if
			else
				select cargo 
				  into vcargo
				  from bdicheq:sc_bloqueo
				 where codigo = vmotivo;
				 
				if vcargo = "N" then
					let vmotdevol   = "09"; -- cuenta bloqueada
					let vprocesado  = "1";
					let vctavalida  = "0";
				end if
			end if;
        end if        

        if ( vstatuscta = '4' or vstatuscta = '5' ) then
            let vfecha_proc_cta = vfechacalendario;
        end if
        
        if ( vstatuscta in('6','7','8') ) then
            let vfecha_proc_cta = vfechacalendario;
            let vmotdevol  = "02";
            let vprocesado = "1";
            let vctavalida = "0";
        end if   
            
        -- validar status cheque
        /* ******************************************
        A   Activo  
        U   Presentado en Sucursal, se debe pagar
        I   Incompleto 51
        P   Pagado de Sucursal 16
        M   Pagado por Camara 16
        S   Presentado en Sucursal 
        N   Presentado por Camara
        C   Cancelado 52
        R   Revocado 08
        D   Destruido 51
        J   Bloqueado por Orden Judicial 07
        B   Bloqueado por Autoridades 07
        F   Fraudulento 23
        X   Extraviado 52
        ****************************************** */
        
        let vctavalida  = "0";
        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        if vcargo = "S" then
            select estado
              into vchequestat
              from bdicheq:sc_contch
             where empresa = pempresa
               and cuenta  = pcuenta
               and numero  = pnrocheque;
               
            -- no encontro registros
            -- La numeraciï¿½n del cheque no corresponde 
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol  = "51";
                let vprocesado = "1";
                let vctavalida = "0";          
            end if
            
            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                let vctavalida = "1";  
            end if
            
            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Pagado Suc. o Cam.";
                let vdevolucion = 1;
            end if 
            
            -- presentado por camara
            if vchequestat = "N" then
                let vmotdevol   = "18"; -- se cambio por la 53 a peticiï¿½n de CECOBAN. 30-07-2012. JGP.
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Presentado por Cam.";
                let vdevolucion = 1;
            end if       
                
            -- revocado
            if vchequestat = "R" then
                let vmotdevol   = "08";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Revocado";
                let vdevolucion = 1;
            end if                
            
            -- CHEQUE CANCELADO
            if vchequestat = "C" then
                let vmotdevol   = "52";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Cancelado";
                let vdevolucion = 1;
            end if 
            
            -- CHEQUE EXTRAVIADO
             if vchequestat = "X" then
                let vmotdevol   = "52";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Extraviado";
                let vdevolucion = 1;
            end if
            
            -- CHEQUE FRAUDULENTO
             if vchequestat = "F" then
                let vmotdevol   = "23";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Fraudulento";
                let vdevolucion = 1;
            end if
            
            -- incompleto
            if vchequestat = "I" then
                let vmotdevol   = "51";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Incompleto";
                let vdevolucion = 1;
            end if 
            
            -- destruido
            if vchequestat = "D" then
                let vmotdevol   = "23";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Destruido";
                let vdevolucion = 1;
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J" then
                let vmotdevol   = "07";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Bloqueado Orden Jud.";
                let vdevolucion = 1;
            end if 
            
            -- bloqueado autoridades
            if vchequestat = "B" then
                let vmotdevol   = "09";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "Bloqueado";
                let vdevolucion = 1;
            end if 
            
            -- no ha sido activado
            if vchequestat = "E" or vchequestat = "S" then
                let vmotdevol   = "24";
                let vprocesado  = "1";
                let vctavalida  = "0"; 
                let vmvodevv    = "No ha sido activado";
                let vdevolucion = 1;
            end if 
        end if -- cuenta bloqueada
    end if --cuenta, sdo_actual
    
    -- aplicar cargo/comision
    let vfolio = pusuario || to_char(current hour to fraction,"%H%M%S") || substr(pcuenta, length(pcuenta)-1,2);
    
    if vctavalida = "1" then
        select bco_presenta 
          into vbco_pres 
          from cce_propios_det
         where fecha_entrada = vfecha_hoy
           and secuencia     = psec_ctl
           and c_cuenta      = pcuenta
           and c_cheque      = pnrocheque
           and nombrearchivo = pnomarch;
           
        let vfolio = pusuario || to_char(current hour to fraction,"%H%M%S") || substr(pcuenta, length(pcuenta)-1,2);
        
        -- aplicar cargo a la cuenta
        if vsdodisp >= pimporte then
            -- 0231 PAGO CHEQUE CAMARA   
            let vmsg = "0231 PAGO CHEQUE CAMARA";                           
            let vtrans = vtran_cargo;
            let vmotdevol = "00";
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque;
            
            call bdicheq:cargo_ref(pempresa, vsucursal, pusuario, vtrans, "0000", vfolio, pcuenta, pnrocheque, pimporte, pmoneda, vreferencia, "", "")
            returning vcodret,vtransaccion,vfecha2,vsaldo,vmontoret;  
            
            if vcodret <> "000" then
                ROLLBACK WORK;
                let vmsg = "ERROR CARGO_REF 0231";
                let vprocesado = "0";
                return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
            else
                let vmotdevol  = "00";
                let vprocesado = "1";
                let vmsg = "procesado satisfactoriamente"; 
                let vfuepagado = "S";  
                
                -- validacion del contador de expedidos
                select chq_exp_mes 
                  into vcheqgirados
                  from bdicheq:sc_maechq
                 where empresa = pempresa
                   and cuenta  = pcuenta;
                   
                let Vmsg = "CHEQUES GRATIS CARGO CUENTA";
                
                if vcheqgirados > vcheqgratis then
                    update cce_propios_det
                       set com_cobrada   = com_cobrada + vcomchqgratis,
                           iva_cobrado   = iva_cobrado + (vcomchqgratis * viva),
                           sdo_cuenta    = vsaldo
                     where fecha_entrada = vfecha_hoy
                       and secuencia     = psec_ctl
                       and c_cuenta      = pcuenta
                       and c_cheque      = pnrocheque
                       and nombrearchivo = pnomarch;
                end if 
            end if;  
        else 
            -- sin fondos
            -- cargar comision e iva
            let vmotdevol   = "01";
            let vctavalida  = "0";
            
            -- 3313 cgo dev.camara REFERENCIA  
            let vmsg = "3313 cgo dev.camara REFERENCIA";                             
            let vtrans = vtran_cgodev;
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque ||" mot "||vmotdevol;
            -- let vreferencia = "chq dev nro "|| pnrocheque ||" mot "||vmotdevol;
            let vmsg = "01 movdia cgo";
            
            insert into bdicheq:sc_movdia values 
            ( 0, vfolio, vsucursal, pusuario, vfecha_proc_cta, vfecha_proc_cta, current hour to fraction(3), vtrans,vsucursal, vproducto, 
              pempresa, pcuenta, vmotdevol, pnrocheque, pimporte, pimporte, 0, 0, 0, "", "1", 0, "0000", vreferencia, 0, "", "", "", vfechaOperacion);  
              
            -- 3314 abono dev camara REFERENCIA 
            let vmsg = "3314 abono dev camara REFERENCIA"; 
            let vtrans = vtran_abodev;
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque ||" mot "||vmotdevol;
            -- let vreferencia = "chq dev nro "|| pnrocheque ||" mot "|| vmotdevol;
            let vmsg = "01 MOVDIA ABON";
            
            insert into bdicheq:sc_movdia values 
            ( 0, vfolio, vsucursal, pusuario, vfecha_proc_cta, vfecha_proc_cta, current hour to fraction(3), vtrans, vsucursal, vproducto, 
              pempresa, pcuenta, vmotdevol, pnrocheque, pimporte, pimporte, 0, 0, 0, "", "1", 0, "0000", vreferencia, 0, "", "", "", vfechaOperacion); 
              
            -- 3224 com.cheq.dev.propios                                                                 
            let vtrans = vtran_comdev;
            -- let vreferencia = "";
		
            ---- importe de la comision
            select monto_aplica, forma_aplica
              into vimporte, vFormaAplic
              from bdicheq:sc_comisiones
             where empresa = pempresa 
               and comision = vtrans;
               
            -- no trajo datos
            if dbinfo("sqlca.sqlerrd2") = 0 then
                ROLLBACK WORK;
                let vmsg = "no existe comision";
                let vprocesado = "0";                  
                let vcodret = "130";
                return vcodret,vmotdevol,vprocesado,vmsg, vsucursal, vfolio, vtrans;
            end if           

			SELECT tpper_valida
			INTO cTpoPersona
			FROM bdicheq:"informix".sc_producto
			WHERE empresa = "001" 
			AND producto = vproducto;	
            
            -- INCORPORAR NUEVA VALIDACION DE IMPORTE DE COMISION' - JGP
            IF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
                LET vMontoDif = pimporte - vsdodisp;
                
                IF vMontoDif > vimporte THEN
                    LET vimporte = vimporte;
                ELSE
                    LET vimporte = vMontoDif;
                END IF
            END IF
            
            -- no le alcanza el sdo para pagar la comision + iva
            -- tomar parte proporcional com e iva
            if vsdodisp < vimporte * (1 + viva) then
                let vimportecom = vsdodisp / (1 + viva);
                let vmontopend = vimporte - vimportecom;
                let vbandera = "1";
            else
                -- importe completo de la comision
                let vimportecom = vimporte;
            end if 
            
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque;
            
            -- sumar uno a los expedidos dado que no entro
            -- por cargo_ref
            update bdicheq:sc_maechq
               set chq_exp_mes = chq_exp_mes + 1 
             where empresa = pempresa
               and cuenta  = pcuenta;                   
               
            -- cargar comision del cheque cuando tiene saldo 
            if vsdodisp >= 0.10 then --mayor a .10 para cargar comi e iva
                let vmsg = "CARGO REF"; 
                
                call bdicheq:cargo_ref( pempresa, vsucursal, pusuario, vtrans, "0000", vfolio, pcuenta, pnrocheque, vimportecom, pmoneda, vreferencia, "", "" )
                returning vcodret, vtransaccion, vfecha2, vsaldo, vmontoret; 
                
                if vcodret <> "000"  then
                    ROLLBACK WORK;
                    let vmsg = "01 ERR COM.CHEQ.DEV.PROPIOS";
                    return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
                end if;   
                
                -- 0260 iva comisiones                                               
                let vtrans = vtran_ivacom;
                -- let vreferencia = "";
                let viva_cob = trunc((vimportecom * viva),2);
                
				-- Ajuste por redondeo
				IF vimportecom + viva_cob > vsdodisp THEN
					LET viva_cob = vsdodisp - vimportecom;
				END IF;
                
                call bdicheq:cargo_ref( pempresa, vsucursal, pusuario, vtrans, "0000", vfolio, pcuenta, pnrocheque, viva_cob, pmoneda, vreferencia, "", "" )
                returning vcodret, vtransaccion, vfecha2, vsaldo, vmontoret;  
                
                if vcodret <> "000"  then
                    ROLLBACK WORK;
                    let vmsg = "01 err iva comisiones";
                    return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
                end if
                
                let vmsg = "GRABA COM IVA COMPLETOS +++ 01";
                LET vimportecom = vimportecom;
                
                -- grabar comision e iva completos
                update cce_propios_det
                   set com_cobrada   = vimportecom,
                       iva_cobrado   = viva_cob
                 where fecha_entrada = vfecha_hoy
                   and secuencia     = psec_ctl
                   and c_cuenta      = pcuenta
                   and c_cheque      = pnrocheque
                   and nombrearchivo = pnomarch;                
            end if
   
            -- grabar la parte pendiente de comision
            if vbandera = "1" then
                -- insertar en sc_detcomis
                insert into bdicheq:sc_detcomis values
                ( pempresa, pcuenta, vtran_comdev, vmontopend, 0, vfecha_proc_cta, "", "P", vfolio );
                
                -- registrar residuo comision pendiente
                update bdicheq:sc_maechq
                   set com_pendiente = com_pendiente + vmontopend 
                 where empresa = pempresa
                   and cuenta  = pcuenta;
                   
                LET vmontopend = vmontopend;
                
                -- grabar comision pendiente
                update cce_propios_det
                   set com_pend      = com_pend + vmontopend
                 where fecha_entrada = vfecha_hoy
                   and secuencia     = psec_ctl
                   and c_cuenta      = pcuenta
                   and c_cheque      = pnrocheque
                   and nombrearchivo = pnomarch; 
            end if
            
            -- todo ok
            let vprocesado = "1";
        end if -- vsdodisp
    end if --vctavalida
    
    -- cargar el motivo de la devolucion
    if vmotdevol <> "00" then
        select descripcion 
          into vmsg
          from bdinteg:si_coddevcam
         where codigo = vmotdevol;
    end if
    
    -- actualizar cce_propios_det 10 dev, 05 pagado
    if vctavalida = "0" then
        let vstatus = "10";
        let vstatchq = "N"; -- presentado en cam, no pagado
        
        -- sumarle uno al contador de cheques devueltos
        update bdicheq:sc_maechq
           set chq_dev = chq_dev + 1
         where empresa = pempresa
           and cuenta  = pcuenta;       
    else
        let vstatus  = "05";
        let vstatchq = "M"; -- pagado por camara
    end if
    
    update cce_propios_det
       set mot_devol     = vmotdevol,
           status        = vstatus,
           cod_ret       = trim(vcodret),
           fecha_proceso = vfecha_proc_cta,
           usuario_dev   = pusuario,
           sdo_cuenta    = vsdodisp
     where fecha_entrada = vfecha_hoy
       and secuencia     = psec_ctl
       and c_cuenta      = pcuenta
       and c_cheque      = pnrocheque
       and nombrearchivo = pnomarch;

   -- actualizar bdicheq:sc_contch
    update bdicheq:sc_contch
       set estado     = vstatchq,
           fecha_alta = vfecha_proc_cta,
           importe    = pimporte
     where empresa    = pempresa
       and cuenta     = pcuenta
       and numero     = pnrocheque;      
    
    -- si la cuenta esta bloqueda salir
    if vcargo = "N" and vmotdevol = "09" then
        COMMIT WORK;
        return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;              
    end if 
    
    -- contar cuantos cheques expedidos tiene al momento
    -- porque cargo_ref los actualiza
    let vcheqgirados = 0;
    
    select chq_exp_mes 
      into vcheqgirados
      from bdicheq:sc_maechq
     where empresa = pempresa
       and cuenta  = pcuenta;
    
    -- cobrarle comision cheques gratis
    -- considerando que cargo_ref ya le cobro la expedicion
    if vcheqgirados > vcheqgratis and vfuepagado = "N" then
        let vbandera = "";
        --- comision cheque girado
        -- let vreferencia = "";
        -- saldo cuenta
        select sdo_actual, sdo_retenido, sdo_cong, status_cta, saldo_sbc
          into mSdoActual, mSdoRetenido, mSdoCongelado, vstatuscta, mSaldoSbc
          from bdicheq:sc_maechq
         where empresa = pempresa   
           and cuenta = pcuenta;

        --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo ('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, null, null, null, 'F', 2) 
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdodisp; 

        if vstatuscta in("2", "6") THEN
           let vsdodisp = 0;
        end if;		   
           
        if vsdodisp < vcomchqgratis * (1 + viva) then
            let vimportecom  = vsdodisp / (1 + viva);
            let vmontopend = vcomchqgratis - vimportecom;
            let vbandera = "1";
        else
           -- importe completo de la comision
            let vimportecom = vcomchqgratis;
        end if         
        
        -- saldo 0 no aplicar cargo_ref
        if vsdodisp >= 0.10 then
            let vfolio = pusuario || to_char(current hour to fraction,"%H%M%S") || substr(pcuenta, length(pcuenta)-1,2);
				 
            -- let vreferencia = "chq nro "|| pnrocheque;
            let vtrans = vtran_chqgira;
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque;
            
            call bdicheq:cargo_ref( pempresa, vsucursal, pusuario, vtrans, "0000", vfolio, pcuenta, pnrocheque, vimportecom, pmoneda, vreferencia, "", "" )
            returning vcodret, vtransaccion, vfecha2, vsaldo, vmontoret; 
            
            if vcodret <> "000"  then
                ROLLBACK WORK;
                let vmsg = "02 err com.cheq.dev.propios";
                return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
            end if;   
            
            -- 0260 iva comisiones                                               
            let vtrans = vtran_ivacom;
            -- let vreferencia = "";
            let vreferencia = "Banco: "|| vbco_pres ||" Cheque No.: " || pnrocheque;
            -- let viva_cob = vimportecom * viva;
            let viva_cob = trunc((vimportecom * viva),2);
            
	    	-- Ajuste por redondeo
			IF vimportecom + viva_cob > vsdodisp THEN
				LET viva_cob = vsdodisp - vimportecom;
			END IF;
            
            call bdicheq:cargo_ref( pempresa, vsucursal, pusuario, vtrans, "0000", vfolio, pcuenta, pnrocheque, viva_cob, pmoneda, vreferencia, "", "" )
            returning vcodret, vtransaccion, vfecha2, vsaldo, vmontoret;  
            
            if vcodret <> "000"  then
                ROLLBACK WORK;
                let vmsg = "02 err iva comisiones";
                return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;
            end if
            
            let vcomchqgratis = vcomchqgratis;
            
            -- grabar comision e iva completos 16mzo10
            update cce_propios_det
               set com_cobrada   = com_cobrada + vcomchqgratis,
                   iva_cobrado   = iva_cobrado + viva_cob,
                   sdo_cuenta    = vsdodisp
             where fecha_entrada = vfecha_hoy
               and secuencia     = psec_ctl
               and c_cuenta      = pcuenta
               and c_cheque      = pnrocheque
               and nombrearchivo = pnomarch;
        else
            let vmontopend = vcomchqgratis;
        end if    
        
        -- grabar la parte pendiente de comision
        if vbandera = "1" then
            -- insertar en sc_detcomis
            insert into bdicheq:sc_detcomis values
            ( pempresa, pcuenta, vtran_comdev, vmontopend ,0, vfecha_proc_cta, "", "P", vfolio );
            
            -- registrar residuo comision pendiente
            update bdicheq:sc_maechq
               set com_pendiente = com_pendiente + vmontopend 
             where empresa = pempresa
               and cuenta  = pcuenta;
               
            let vmsg = "GRABAR LA PARTE PENDIENTE DE COMISION CHQ GRATIS";
            let vmontopend = vmontopend;
            
            -- grabar comision pendiente 16mzo10
            update cce_propios_det
               set com_pend      = com_pend + vmontopend,
                   sdo_cuenta    = vsdodisp
             where fecha_entrada = vfecha_hoy
               and secuencia     = psec_ctl
               and c_cuenta      = pcuenta
               and c_cheque      = pnrocheque 
               and nombrearchivo = pnomarch;
        end if
    end if -- cheques gratis
    
    IF vmotdevol <> "01" THEN -- dev. cam
        IF vdevolucion = 1 THEN
            INSERT INTO bdicheq:sc_movdia VALUES
            ( 0, vfolio, vsucursal, pusuario, vfecha_proc_cta, vfecha_proc_cta, current hour to fraction(3), vtran_cgodev, vsucursal, vproducto, pempresa, pcuenta,
              vmotdevol, pnrocheque, pimporte, pimporte, 0, 0, 0, " ", "1", 0, "0000", "Cheque No. "|| trim(pnrocheque::char(7)) || " " || vmvodevv, 0, " ", " ", "", vfechaOperacion);

            INSERT INTO bdicheq:sc_movdia VALUES
            ( 0, vfolio, vsucursal, pusuario, vfecha_proc_cta, vfecha_proc_cta, current hour to fraction(3), vtran_abodev, vsucursal, vproducto, pempresa, pcuenta,
              vmotdevol, pnrocheque, pimporte, pimporte, 0, 0, 0, " ", "1", 0, "0000", "Cheque No. "|| trim(pnrocheque::char(7)) || " " || vmvodevv, 0, " ", " ", "", vfechaOperacion);
        END IF;
    END IF;
    
    COMMIT WORK;
    
    return vcodret, vmotdevol, vprocesado, vmsg, vsucursal, vfolio, vtrans;      
    
    end;
    
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bditef',
'VER:                   1.2',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/11/03',
'RAZON:                 Se agrega la correcta referencia al spl sp_cons_sdodisp_x_tpcalculo',
'                       ya que no se localizaba en la ubicaciÃ³n especificada',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bditef',
'VER:                   1.3';

CREATE PROCEDURE "informix".sp_tef_generareplistnegra()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cStmt				CHAR(1000);
DEFINE dFecha_Ayer			DATE;
DEFINE cRutaArchDet			CHAR(100);
DEFINE cNombreArch          CHAR(30);
DEFINE cFecha_presentacion  CHAR(8);
DEFINE cTipo_registro       CHAR(4);
DEFINE cNum_secuencia       CHAR(7);
DEFINE vCod_operacion       CHAR(2);
DEFINE vCod_divisa          CHAR(2);
DEFINE cFecha_trans         CHAR(8);
DEFINE cBanco_presentador   CHAR(45);
DEFINE cBanco_receptor      CHAR(45);
DEFINE cImporte             CHAR(15);
DEFINE cUso_futuro_ccen     CHAR(16);
DEFINE cTipo_operacion      CHAR(2);
DEFINE cFecha_aplica        CHAR(8);
DEFINE cTipo_cta_ord        CHAR(2);
DEFINE cNum_cta_ord         CHAR(20);
DEFINE cNombre_ord          CHAR(40);
DEFINE cRfc_ord             CHAR(20);
DEFINE cTipo_cta_rec        CHAR(2);
DEFINE cNum_cta_rec         CHAR(20);
DEFINE cNombre_rec          CHAR(40);
DEFINE cRfc_rec             CHAR(18);
DEFINE cRef_servicio        CHAR(40);
DEFINE cNombre_titular_serv CHAR(40);
DEFINE cImporte_iva         CHAR(15);
DEFINE cRef_numerica        CHAR(7);
DEFINE cRef_leyenda         CHAR(40);
DEFINE vClave_rastreo       CHAR(40);
DEFINE cMotivo_dev          CHAR(40);
DEFINE cFecha_pres_ini      CHAR(8);
DEFINE cSol_confirmacion    CHAR(1);
DEFINE cUso_futuro_banco    CHAR(11);
DEFINE cRef_confirmacion    CHAR(30);
DEFINE cUso_futuro_cce      CHAR(1);
DEFINE cTasa_tiie_prom      CHAR(7);
DEFINE cDias_retraso        CHAR(3);
DEFINE cImp_tot_int         CHAR(15);
DEFINE vCve_status          CHAR(40);
DEFINE cFolio_suc           CHAR(20);
DEFINE cUser_insert         CHAR(8);
DEFINE cFecha_insert        CHAR(10);
DEFINE cTipo_cta            CHAR(20);
DEFINE iCuantos             INTEGER;
DEFINE cRutaArchivos        CHAR(50);
DEFINE vNombreArch          CHAR(30);
DEFINE vFechaPresentacion   CHAR(8);





--INICIALIZACION DE VARIABLES--
LET cCodRet				 = "00000";
LET cMensaje			 = 'PROCESO EXITOSO';
LET iSqlErr				 = 0;
LET cStmt				 = '';
LET dFecha_Ayer			 = DATE(1);
LET cNombreArch          = '';
LET cFecha_presentacion  = '';
LET cTipo_registro       = '';
LET cNum_secuencia       = '';
LET vCod_operacion       = '';
LET vCod_divisa          = '';
LET cFecha_trans         = '';
LET cBanco_presentador   = '';
LET cBanco_receptor      = '';
LET cImporte             = '';
LET cUso_futuro_ccen     = '';
LET cTipo_operacion      = '';
LET cFecha_aplica        = '';
LET cTipo_cta_ord        = '';
LET cNum_cta_ord         = '';
LET cNombre_ord          = '';
LET cRfc_ord             = '';
LET cTipo_cta_rec        = '';
LET cNum_cta_rec         = '';
LET cNombre_rec          = '';
LET cRfc_rec             = '';
LET cRef_servicio        = '';
LET cNombre_titular_serv = '';
LET cImporte_iva         = '';
LET cRef_numerica        = '';
LET cRef_leyenda         = '';
LET vClave_rastreo       = '';
LET cMotivo_dev          = '';
LET cFecha_pres_ini      = '';
LET cSol_confirmacion    = '';
LET cUso_futuro_banco    = '';
LET cRef_confirmacion    = '';
LET cUso_futuro_cce      = '';
LET cTasa_tiie_prom      = '';
LET cDias_retraso        = '';
LET cImp_tot_int         = '';
LET vCve_status          = '';
LET cFolio_suc           = '';
LET cUser_insert         = '';
LET cFecha_insert        = '';
LET cTipo_cta            = '';
LET iCuantos             = 0;
LET cRutaArchivos        = '';
LET vNombreArch          = '';
LET vFechaPresentacion   = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO  '/RESPALDOSNEW/depuraremesas/sp_generaarchivocobranzaservcpl.out';
	    --TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;	

		SELECT FIRST 1 Valor INTO cRutaArchivos FROM BdiTef:Tef_Parametros WHERE cod_param = '72';	
		
		SELECT MAX(fecha_insert) INTO dFecha_Ayer FROM bditef:tef_cce_archivos 
		WHERE nombre_arch LIKE '%S01137A2.A60%';
		 
		LET cRutaArchDet  =  TRIM(cRutaArchivos) || '/Reporte_tef_' || LPAD(DAY (dFecha_Ayer),2,'0') || LPAD(MONTH (dFecha_Ayer),2,'0') || YEAR(dFecha_Ayer)  || '.csv';
		
		LET vNombreArch = 'S01137A2.A60'|| LPAD(DAY(dFecha_Ayer),2,'0') || '98';
		LET vFechaPresentacion = YEAR(dFecha_Ayer)  || LPAD(MONTH (dFecha_Ayer),2,'0') || LPAD(DAY (dFecha_Ayer),2,'0');
		
		
		SELECT COUNT(*) INTO iCuantos FROM bditef:tef_cce_detalle a WHERE a.nombre_arch = TRIM(vNombreArch) AND a.fecha_presentacion = TRIM(vFechaPresentacion) AND a.cod_operacion='60';
				
		IF iCuantos	> 0 THEN
				
				LET cStmt =   'echo "' || TRIM('NOMBRE ARCHIVO') || ',' || TRIM('FECHA PRESENTACION') || ',' || TRIM('TIPO REGISTRO') || ',' || TRIM('NUMERO SECUENCIA') || ',' || TRIM('CODIGO OPERACION') || 
				',' || TRIM('DIVISA') || ',' || TRIM('FECHA TRANS') || ',' || TRIM('BANCO PRESENTADOR') || ',' || TRIM('BANCO RECEPTOR') || ',' || TRIM('IMPORTE') || ',' || TRIM('CAMPO USO FUTURO') || 
				',' || TRIM('TIPO OPERACION') || ',' || TRIM('FECHA APLICA') || ',' || TRIM('TIPO CTA ORD') || ',' || TRIM('NUM CTA ORD') || ',' || TRIM('NOMBRE ORD') || ',' || TRIM('RFC ORD') || 
				',' || TRIM('TIPO CTA REC') || ',' || TRIM('NUM CTA REC') || ',' || TRIM('NOMBRE REC') || ',' || TRIM('RFC REC') || ',' || TRIM('REF SERVICIO') || ',' || TRIM('NOMBRE TITULAR SERV') ||
				',' || TRIM('IMPORTE IVA') || ',' || TRIM('REF NUMERICA') || ',' || TRIM('REF LEYENDA') || ',' || TRIM('CLAVE RASTREO') || ',' || TRIM('MOTIVO DEVOLUCION') || ',' || TRIM('FECHA PRES INI') ||
				',' || TRIM('SOLICITUD CONFIRMACION') || ',' || TRIM('CAMPO USO FUTURO') || ',' || TRIM('TASA TIIE PROM') || ',' || TRIM('DIAS RETRASO') || ',' || TRIM('IMP TOT IN') ||
				',' || TRIM('ESTATUS') || ',' || TRIM('FOLIO SUC') || ',' || TRIM('USER INSERT') || ',' || TRIM('FECHA OPERACION') || ',' || TRIM('TIPO CTA') ||'" >> ' || cRutaArchDet;
				SYSTEM cStmt;
				FOREACH
					select a.nombre_arch,a.fecha_presentacion,a.tipo_registro as prueba,a.num_secuencia,a.cod_operacion,a.cod_divisa,a.fecha_trans,     
					b.descripcion,c.descripcion,a.importe / 100,a.uso_futuro_ccen,a.tipo_operacion,a.fecha_aplica,a.tipo_cta_ord,     
					a.num_cta_ord,a.nombre_ord,a.rfc_ord,a.tipo_cta_rec,a.num_cta_rec,a.nombre_rec,a.rfc_rec,a.ref_servicio,a.nombre_titular_serv,a.importe_iva,a.ref_numerica,     
					a.ref_leyenda,a.clave_rastreo,e.descripcion,a.fecha_pres_ini,a.solicitud_confirmacion,a.uso_futuro_banco,a.ref_confirmacion,a.uso_futuro_cce,     
					a.tasa_tiie_prom,a.dias_retraso,a.imp_tot_int,d.descripcion,a.folio_suc,a.user_insert,a.fecha_insert,a.tipo_cta
					INTO cNombreArch,cFecha_presentacion,cTipo_registro,cNum_secuencia,vCod_operacion,vCod_divisa,cFecha_trans,cBanco_presentador,cBanco_receptor,cImporte,
					cUso_futuro_ccen,cTipo_operacion,cFecha_aplica,cTipo_cta_ord,cNum_cta_ord,cNombre_ord,cRfc_ord,cTipo_cta_rec,cNum_cta_rec,cNombre_rec,
					cRfc_rec,cRef_servicio,cNombre_titular_serv,cImporte_iva,cRef_numerica,cRef_leyenda,vClave_rastreo,cMotivo_dev,cFecha_pres_ini,cSol_confirmacion,
					cUso_futuro_banco,cRef_confirmacion,cUso_futuro_cce,cTasa_tiie_prom,cDias_retraso,cImp_tot_int,vCve_status,cFolio_suc,cUser_insert,cFecha_insert,cTipo_cta   	
					from bditef:tef_cce_detalle a, bdinteg:si_bancos b, bdinteg:si_bancos c,bditef:tef_status_pago d,bditef:tef_cat_devoluciones e
					where a.nombre_arch = TRIM(vNombreArch)
					and a.fecha_presentacion = TRIM(vFechaPresentacion)
					and a.cod_operacion='60'
					and b.banco=a.banco_presentador
					and c.banco=a.banco_receptor
					and d.cve_status=a.cve_status
					and e.motivo_dev=a.motivo_dev
					order by 4 asc
					
					LET cStmt = 'echo "' || TRIM(NVL(replace(cNombreArch,',',''),'')) || ',' || TRIM(NVL(replace(cFecha_presentacion,',',''),'')) || ',' || TO_CHAR(replace(cTipo_registro,',','')) || ',' || TRIM(NVL(replace(cNum_secuencia,',',''),'')) || 
					',' || TRIM(NVL(replace(vCod_operacion,',',''),''))   || ',' || TRIM(NVL(replace(vCod_divisa,',',''),''))       || ',' || TRIM(NVL(replace(cFecha_trans,',',''),''))       || ',' || TRIM(NVL(replace(cBanco_presentador,',',''),''))  || ',' || TRIM(NVL(replace(cBanco_receptor,',',''),'')) ||
					',' || TRIM(NVL(replace(cImporte,',',''),''))         || ',' || TRIM(NVL(replace(cUso_futuro_ccen,',',''),''))  || ',' || TRIM(NVL(replace(cTipo_operacion,',',''),''))    || ',' || TRIM(NVL(replace(cFecha_aplica,',',''),''))       || ',' || TRIM(NVL(replace(cTipo_cta_ord,',',''),''))   || 
					',' || TRIM(NVL(replace(cNum_cta_ord,',',''),''))     || ',' || TRIM(NVL(replace(cNombre_ord,',',''),''))       || ',' || TRIM(NVL(replace(cRfc_ord,',',''),''))           || ',' || TRIM(NVL(replace(cTipo_cta_rec,',',''),''))       || ',' || TRIM(NVL(replace(cNum_cta_rec,',',''),''))    || 
					',' || TRIM(NVL(replace(cNombre_rec,',',''),''))      || ',' || TRIM(NVL(replace(cRfc_rec,',',''),''))          || ',' || TRIM(NVL(replace(cRef_servicio,',',''),''))      || ',' || TRIM(NVL(replace(cNombre_titular_serv,',',''),''))|| ',' || TRIM(NVL(replace(cImporte_iva,',',''),''))    || 
					',' || TRIM(NVL(replace(cRef_numerica,',',''),''))    || ',' || TRIM(NVL(replace(cRef_leyenda,',',''),''))      || ',' || TRIM(NVL(replace(vClave_rastreo,',',''),''))     || ',' || TRIM(NVL(replace(cMotivo_dev,',',''),''))         || ',' || TRIM(NVL(replace(cFecha_pres_ini,',',''),'')) || 
					',' || TRIM(NVL(replace(cSol_confirmacion,',',''),''))|| ',' || TRIM(NVL(replace(cUso_futuro_cce,',',''),''))   || ',' || TRIM(NVL(replace(cTasa_tiie_prom,',',''),''))    || ',' || TRIM(NVL(replace(cDias_retraso,',',''),''))       || ',' || TRIM(NVL(replace(cImp_tot_int,',',''),''))    || 
					',' || TRIM(NVL(replace(vCve_status,',',''),''))      || ',' || TRIM(NVL(replace(cFolio_suc,',',''),''))        || ',' || TRIM(NVL(replace(cUser_insert,',',''),''))       || ',' || TRIM(NVL(replace(cFecha_insert,',',''),''))       || ',' || TRIM(NVL(replace(cTipo_cta,',',''),''))       ||'" >> ' || cRutaArchDet;
					SYSTEM cStmt;
				
				END FOREACH;
					
		ELSE		
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo " 0 " >> ' || cRutaArchDet;
			SYSTEM cStmt;			
		END IF;			
				
		RETURN cCodRet, cMensaje;
	END;	
END PROCEDURE;