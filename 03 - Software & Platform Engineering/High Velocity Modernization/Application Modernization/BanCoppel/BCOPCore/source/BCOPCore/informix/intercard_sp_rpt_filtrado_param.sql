CREATE PROCEDURE "informix".sp_rpt_filtrado_param(pdtFechaIni DATETIME YEAR TO FRACTION(5), -- --Fecha Inicio del Periodo '<mm-dd-aaaa'>
                                                  pdtFechaFin DATETIME YEAR TO FRACTION(5), ----Fecha Final del Periodo  '<mm-dd-aaaa'>
	                                              psEstado CHAR(2), --Codigo de bdinteg:si_estados.estado 
	                                              psCiudad CHAR(3), --Código de bdinteg:si_ciudades.ciudad 
	                                              psOrigen CHAR(1), --'N'-Nacional, 'I'-Internacional o en blanco cualquiera. 
	                                              psProdInd CHAR(1),--'A' - ATM, 'P' - POS y vacio para ambos.	 
	                                              psBin CHAR(6),    --Bin de acuerdo al catálogo intercard:bines.bin
	                                              psSubBin CHAR(2), -- Imagen de la tarjeta
	                                              psChipBanda CHAR(1), -- 'C' - Chip, 'B' - Banda, espacio en blanco todos.
	                                              psProductoInterCard CHAR(3), --Código de intercard:productotarjeta.codproductotarjeta  
	                                              psFechaExp CHAR(4), --Formato AAMM, 
	                                              psProducto CHAR(1), --  'C' - Crédito, 'D' - Débito. 
                                                  psMetodoCaptura CHAR(2), -- Se recibirá '00', '01'-Digitada,, '02'-ATM, '05'-Chip, '09', '80' - Fall Back, '81'-Digitada, '90'-Banda, '92'-ContactLess	 
	                                              psTipoTransaccionposDigitada CHAR(2), --intercard:movimiento.tipotransaccionposdigitada	 
                                                  psGiroComercio CHAR(4), --Código de intercard:gironegocio.codgironeg 
	                                              psIDTerminalRetailer CHAR(19), --No de afiliación o de cajero.
	                                              psCodigoIso CHAR(2), --  intercard:respuestaiso.codigoiso								  
                                                  det_estado   CHAR(1), 
	                                              det_Ciudad  CHAR(1),  
                                                  det_Origen  CHAR(1), 
	                                              det_Origen2 CHAR(1),  
	                                              det_ProdInd  CHAR(1),  
	                                              det_ProdInd2 CHAR(2),  
	                                              det_ChipBanda CHAR(1),  
	                                              det_MetodoCaptura CHAR(1),     
	                                              det_TipoTransaccionposDigitada CHAR(1),  
	                                              det_Bin CHAR(1),  
	                                              det_SubBin CHAR(1),  
	                                              det_ProductoInterCard CHAR(1),  
	                                              det_FechaExp CHAR(1),  
	                                              det_GiroComercio CHAR(1) , 
	                                              det_CodigoIso CHAR(1),  
	                                              det_IDTerminalRetailer CHAR(1),  
	                                              det_TerminalRetailer CHAR(1),  
	                                              det_ChipBanda2 CHAR(1)  )

    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(50) AS MENSAJE_RESPUESTA;
                   
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA CHAR(50);
    DEFINE RUTA_ORIGEN  VARCHAR(80);
	DEFINE PREFIJO_SCRIPTS CHAR(8);
	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE vExecuteSQL LVARCHAR(8000);	
	DEFINE vindicatabla  VARCHAR(25);
	DEFINE vindicatabla2 VARCHAR(25);
	
	DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
    DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
	DEFINE PREFIJO_ARCH2 VARCHAR(14);
	DEFINE vsCiudad   CHAR(3);
	
	DEFINE vfecha_hoy DATETIME YEAR TO FRACTION(5);
 
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'El proceso se ejecuto exitosamente.';
    --LET RUTA_ORIGEN = '/ifxsif01/_argoz/parametrico/'; -- Desarrollo 
    LET RUTA_ORIGEN = '/resplogifx/';  -- Producción 
	LET vExecuteSQL = '';
	LET PREFIJO_SCRIPTS = 'transcarga2_';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
	LET vindicatabla2 = '';
    LET CONTADOR_TRANSACCIONES = 1000;
	LET PREFIJO_ARCH2   = 'filtrado_rpt';
 
    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "sp_rpt_filtrado_param.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_filtrado_param.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
  

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;


     LET      psEstado                         = TRIM(psEstado);  
     LET      psCiudad                         = TRIM(psCiudad);  
     LET      psOrigen                         = TRIM(psOrigen);  
     LET      psProdInd                        = TRIM(psProdInd); 
     LET      psBin                            = TRIM(psBin); 
     LET      psSubBin                         = TRIM(psSubBin);  
     LET      psChipBanda                      = TRIM(psChipBanda);  
     LET      psProductoInterCard              = TRIM(psProductoInterCard);  
     LET      psFechaExp                       = TRIM(psFechaExp);  
     LET      psProducto                       = TRIM(psProducto); 
     LET      psMetodoCaptura                  = TRIM(psMetodoCaptura);  
     LET      psTipoTransaccionposDigitada     = TRIM(psTipoTransaccionposDigitada);
     LET      psGiroComercio                   = TRIM(psGiroComercio);  
     LET      psIDTerminalRetailer             = TRIM(psIDTerminalRetailer); 
     LET      psCodigoIso                      = TRIM(psCodigoIso);  
  
     LET      det_estado                        = TRIM(det_estado);   
	 LET      det_Ciudad                        = TRIM(det_Ciudad);   
     LET      det_Origen                        = TRIM(det_Origen);   
	 LET      det_Origen2                       = TRIM(det_Origen2);  
	 LET      det_ProdInd                       = TRIM(det_ProdInd);  
	 LET      det_ProdInd2                      = TRIM(det_ProdInd2); 
	 LET      det_ChipBanda                     = TRIM(det_ChipBanda);  
	 LET      det_MetodoCaptura                 = TRIM(det_MetodoCaptura);     
	 LET      det_TipoTransaccionposDigitada    = TRIM(det_TipoTransaccionposDigitada);
	 LET      det_Bin                           = TRIM(det_Bin);   
	 LET      det_SubBin                        = TRIM(det_SubBin);  
	 LET      det_ProductoInterCard             = TRIM(det_ProductoInterCard); 
	 LET      det_FechaExp                      = TRIM(det_FechaExp); 
	 LET      det_GiroComercio                  = TRIM(det_GiroComercio);  
	 LET      det_CodigoIso                     = TRIM(det_CodigoIso);     
	 LET      det_IDTerminalRetailer            = TRIM(det_IDTerminalRetailer);  
	 LET      det_TerminalRetailer              = TRIM(det_TerminalRetailer);   
	 LET      det_ChipBanda2  	                = TRIM(det_ChipBanda2);  	

            LET vdtFechaIni = pdtFechaIni;
			--LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';
			LET vdtFechaFin = pdtFechaFin;
			--LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';
 
  
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||PREFIJO_ARCH2||'.unl ' || 
		' SELECT  	tjt.numcliente, dir.estado,  edo.nombre, dir.ciudad, \"\" ,  mv.prodind, tpo.chip, \"\" , \"\" ,       ' ||
		'        	tjt.codproductotarjeta, \"\" , bin.creditodebito,  cta.numcuenta, mv.metodocaptura,       ' ||
		'           mv.tipotransaccionposdigitada, \"\",   tjt.fechaexp,  date(mv.fechahorainauth),mv.esnacional, mv.infreceptor,mv.codgironeg,          ' ||
		'           \"\"  , \"\" , \"\"  ,mv.monto,   mv.montocashback,  mv.montosurcharge, mv.codigoiso,   mv.motivo,          ' ||
		'           mv.numtarjeta, mv.formato, mv.codreversa, mv.idreceptor, mv.idterminal, mv.idretailer, mv.codtran, mv.montorealrevfzda    ' ||
		'		 FROM intercard:rpt_movimientopaso mv                                                                                    ' ||      
		'					LEFT JOIN intercard:tarjeta tjt on tjt.numtarjeta = mv.numtarjeta                                            ' ||
		'					LEFT JOIN intercard:lote lte on tjt.numerolote = lte.numerolote                                              ' ||
		'					LEFT JOIN intercard:tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta                         ' ||
	    '					LEFT JOIN intercard:tarjetacuenta cta on cta.numtarjeta = mv.Numtarjeta                                      ' ||
		'					LEFT JOIN bdinteg:si_direcciones_actual dir on dir.numcte = tjt.numcliente                                   ' ||                                            
		'					LEFT JOIN intercard:bines bin on bin.bin = tpo.bin                                                           ' ||
        '                   LEFT JOIN bdinteg:si_estados edo on edo.estado=	dir.estado		                                             ' ||					
        '                   WHERE                                                                                                        ' ||
		'					mv.FechaHoraInAuth BETWEEN ''"'||vdtFechaIni||'"'' AND ''"'||vdtFechaFin||'"''                                          ' ||
		'					AND dir.numcte = tjt.numcliente and dir.pais = \"001\" and dir.tipo_dir = \"1\"                     ' ||
		'					AND ((''"'||det_Estado||'"'' = \"A\" and dir.estado = ''"'||psEstado||'"'') OR (''"'||det_Estado||'"'' = \"T\"  AND 1 = 1))             ' ||
		'					AND ((''"'||det_Ciudad||'"'' = \"A\" and dir.ciudad = ''"'||psCiudad||'"'') OR (''"'||det_Ciudad||'"'' = \"T\"  AND 1 = 1))             ' ||
		'					AND ((''"'||det_Prodind||'"'' = \"A\" AND mv.ProdInd =  ''"'||det_ProdInd2||'"'' ) OR ( ''"'||det_Prodind||'"''  = \"T\"  AND 1 = 1))   ' ||
		'					AND tpo.clave_tipotarjeta = lte.clave_tipotarjeta                                                                                   ' ||
		'					AND ((''"'||det_ChipBanda||'"'' = \"A\" and tpo.chip = ''"'||det_ChipBanda2||'"'') OR (''"'||det_ChipBanda||'"'' = \"T\"  and 1 = 1))          ' ||
		'					AND ((''"'||det_bin||'"'' = \"A\" AND substring(mv.numtarjeta from 1 for 6) = ''"'||psBin||'"'') OR (''"'||det_bin||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND ((''"'||det_SubBin||'"'' = \"A\" AND substring(mv.numtarjeta from 7 for 2) = ''"'||psSubBin||'"'') OR (''"'||det_SubBin||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND ((''"'||det_productoInterCard||'"'' = \"A\" AND tjt.codproductotarjeta = ''"'||psProductoInterCard||'"'') OR (''"'||det_productoInterCard||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND substring(mv.numtarjeta from 1 for 6) = bin.bin                                                                                ' ||
        '                   AND bin.creditodebito =   ''"'||psProducto||'"''					                                                                       ' ||
		'				    AND((''"'||det_MetodoCaptura||'"'' = \"A\" AND mv.metodocaptura = ''"'||psMetodoCaptura||'"'') OR (''"'||det_MetodoCaptura||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND((''"'||det_tipotransaccionposdigitada||'"'' =  \"A\" AND mv.tipotransaccionposdigitada = ''"'||pstipotransaccionposdigitada||'"'') OR (''"'||det_tipotransaccionposdigitada||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND((''"'||det_FechaExp||'"'' = \"A\" AND tjt.fechaexp = ''"'||psFechaExp||'"'') OR (''"'||det_FechaExp||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND((''"'||det_Origen||'"'' = \"A\" AND mv.esnacional = ''"'||det_Origen2||'"'') OR (''"'||det_Origen||'"'' =   \"T\"  AND 1 = 1))   ' ||
		'					AND((''"'||det_GiroComercio||'"'' = \"A\" AND mv.codgironeg = ''"'||psGiroComercio||'"'') OR (''"'||det_GiroComercio||'"'' = \"T\"  AND 1 = 1))						 ' ||
		'					AND((''"'||det_IDTerminalRetailer||'"'' = \"A\" AND mv.IdTerminal = ''"'||psIDTerminalRetailer||'"'') OR  (''"'||det_IDTerminalRetailer||'"'' = ''"'||'A'||'"'' AND mv.IdRetailer = ''"'||psIDTerminalRetailer||'"'') OR (''"'||det_IDTerminalRetailer||'"'' = \"T\"  AND 1 = 1))  ' ||
		'					AND((''"'||det_TerminalRetailer||'"'' =  \"T\" AND mv.IdTerminal = ''"'||psIDTerminalRetailer||'"'')   OR (''"'||det_TerminalRetailer||'"'' = \"T\" AND 1 = 1)  ' ||
		'					 OR (''"'||det_TerminalRetailer||'"'' = ''"'||'R'||'"'' AND mv.IdRetailer = ''"'||psIDTerminalRetailer||'"'')   ' ||
		'					 OR (''"'||det_TerminalRetailer||'"'' = ''"'||'R'||'"'' AND 1 = 1)  ' ||
		'					 OR (''"'||det_TerminalRetailer||'"'' = \"A\" AND 1 = 1))  ' ||
		'				AND((''"'||det_CodigoIso||'"'' = \"A\" AND mv.codigoiso = ''"'||psCodigoIso||'"'') OR (''"'||det_CodigoIso||'"'' =  \"T\" AND 1 = 1));"> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL; 

		LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;
	 
	    LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          ''||PREFIJO_ARCH2||'.unl' || "' delimiter '|' "|| '37'||
                          "; INSERT INTO rptdinamico" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_movs.txt';
        SYSTEM vExecuteSQL; 

        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_movs.txt -l "||PREFIJO_SCRIPTS||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;      

	 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;

	END
END PROCEDURE;