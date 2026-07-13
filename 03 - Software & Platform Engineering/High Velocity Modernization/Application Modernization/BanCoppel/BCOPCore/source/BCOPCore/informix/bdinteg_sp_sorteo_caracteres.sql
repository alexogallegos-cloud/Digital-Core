CREATE PROCEDURE "informix".sp_sorteo_caracteres (cadena lvarchar) 
RETURNING lvarchar;

--DefiniciÃ³n de Variables 
 DEFINE s_cadena lvarchar;
 DEFINE s_cadena2 lvarchar;
 DEFINE s_cadena_total lvarchar;
 DEFINE s_cadena_tam int;
 DEFINE s_long_cadena int;
 DEFINE s_ascii INTEGER;

 --Asignacion Inicial
 LET s_cadena = '';
 LET s_cadena2 = '';
 LET s_cadena_tam = 0;
 LET s_long_cadena = 1;
 LET s_ascii = 0; 
 LET s_cadena = cadena;
 LET s_cadena_total = '';
 
 BEGIN

 SET ISOLATION TO DIRTY READ;
 SET LOCK MODE TO WAIT 3;
-- SET DEBUG FILE TO  '/ifxsif01/sor/sp_caracteres.out';
--TRACE ON;
IF (NVL(s_cadena,'') <> '') THEN
  LET s_cadena_tam = LENGTH(s_cadena);
    --Ciclo de AnÃ¡lisis
  WHILE (s_long_cadena <= s_cadena_tam)
   LET s_cadena2 = SUBSTR(s_cadena,s_long_cadena,1);
   LET s_ascii = ASCII(s_cadena2);
    IF s_ascii BETWEEN 65 AND 90 OR s_ascii BETWEEN 97 AND 122 THEN
     LET s_long_cadena = ( s_long_cadena + 1);
     LET s_cadena_total = s_cadena_total || s_cadena2;
    ELSE
     IF(s_ascii BETWEEN 224 AND 229) THEN 
      LET s_cadena2 = 'a';
       LET s_long_cadena = ( s_long_cadena + 1);
       LET s_cadena_total = s_cadena_total || s_cadena2;
      ELSE 
       IF(s_ascii BETWEEN 192 AND 197) THEN 
        LET s_cadena2 = 'A';
        LET s_long_cadena = ( s_long_cadena + 1);
        LET s_cadena_total = s_cadena_total || s_cadena2;
       ELSE
        IF(s_ascii BETWEEN 232 AND 235) THEN 
         LET s_cadena2 = 'e';
         LET s_long_cadena = ( s_long_cadena + 1);
         LET s_cadena_total = s_cadena_total || s_cadena2;
        ELSE 
         IF(s_ascii BETWEEN 200 AND 203) THEN 
          LET s_cadena2 = 'E';
          LET s_long_cadena = ( s_long_cadena + 1);
          LET s_cadena_total = s_cadena_total || s_cadena2;
         ELSE
          IF(s_ascii BETWEEN 236 AND 239) THEN 
           LET s_cadena2 = 'i';
           LET s_long_cadena = ( s_long_cadena + 1);
           LET s_cadena_total = s_cadena_total || s_cadena2;
          ELSE 
           IF(s_ascii BETWEEN 204 AND 207) THEN 
            LET s_cadena2 = 'I';
            LET s_long_cadena = ( s_long_cadena + 1);
            LET s_cadena_total = s_cadena_total || s_cadena2;
           ELSE
            IF(s_ascii BETWEEN 242 AND 246)THEN 
             LET s_cadena2 = 'o';
             LET s_long_cadena = ( s_long_cadena + 1);
             LET s_cadena_total = s_cadena_total || s_cadena2;
            ELSE 
             IF(s_ascii BETWEEN 210 AND 214) THEN 
              LET s_cadena2 = 'O';
              LET s_long_cadena = ( s_long_cadena + 1);
              LET s_cadena_total = s_cadena_total || s_cadena2;
             ELSE
              IF(s_ascii BETWEEN 249 AND 252)THEN 
               LET s_cadena2 = 'u';
               LET s_long_cadena = ( s_long_cadena + 1);
               LET s_cadena_total = s_cadena_total || s_cadena2;
              ELSE 
               IF(s_ascii BETWEEN 217 AND 220) THEN 
                LET s_cadena2 = 'U';
                LET s_long_cadena = ( s_long_cadena + 1);
                LET s_cadena_total = s_cadena_total || s_cadena2;
               ELSE
                IF s_ascii = 209 THEN 
                 LET s_cadena2 = 'N';
                 LET s_long_cadena = ( s_long_cadena + 1);
                 LET s_cadena_total = s_cadena_total || s_cadena2;
                ELSE 
                 IF s_ascii = 241 THEN 
                  LET s_cadena2 = 'n';
                  LET s_long_cadena = ( s_long_cadena + 1);
                  LET s_cadena_total = s_cadena_total || s_cadena2;
                 ELSE 
                  IF s_ascii = 199 THEN 
                   LET s_cadena2 = 'C';
                   LET s_long_cadena = ( s_long_cadena + 1);
                   LET s_cadena_total = s_cadena_total || s_cadena2;
                  ELSE
                   IF s_ascii = 231 THEN 
                    LET s_cadena2 = 'c';
                    LET s_long_cadena = ( s_long_cadena + 1);
                    LET s_cadena_total = s_cadena_total || s_cadena2;
                   ELSE 
                    IF s_ascii = 221 or s_ascii = 159 THEN 
                     LET s_cadena2 = 'Y';
                     LET s_long_cadena = ( s_long_cadena + 1);
                     LET s_cadena_total = s_cadena_total || s_cadena2;
                    ELSE
                     IF s_ascii = 142 THEN 
                      LET s_cadena2 = 'Z';
                      LET s_long_cadena = ( s_long_cadena + 1);
                      LET s_cadena_total = s_cadena_total || s_cadena2;
                     ELSE
                      IF s_ascii = 158 THEN 
                       LET s_cadena2 = 'z';
                       LET s_long_cadena = ( s_long_cadena + 1);
                       LET s_cadena_total = s_cadena_total || s_cadena2;
                      ELSE
                       IF s_ascii = 138 THEN 
                        LET s_cadena2 = 'S';
                        LET s_long_cadena = ( s_long_cadena + 1);
                        LET s_cadena_total = s_cadena_total || s_cadena2;
                       ELSE
                        IF s_ascii = 154 THEN 
                         LET s_cadena2 = 's';
                         LET s_long_cadena = ( s_long_cadena + 1);
                         LET s_cadena_total = s_cadena_total || s_cadena2;
                         ELSE 
						  --2018-09-21: GM3 PDRH Ini.- Anexo de cÃ³digo para ASCII 32 
                          IF s_ascii = 32 THEN
                           LET s_cadena2 = ' ';
                           LET s_long_cadena = ( s_long_cadena + 1);
                           LET s_cadena_total = s_cadena_total || s_cadena2;
						 --2018-09-21: Fin GM3 PDRH.
						  ELSE
						  ------------------------------------------- Incluir los numeros
                         -- LET s_cadena2 = '';
                         -- LET s_long_cadena = ( s_long_cadena + 1);
							IF s_ascii = 48 THEN
								LET s_cadena2 = '0';
								LET s_long_cadena = ( s_long_cadena + 1);
								LET s_cadena_total = s_cadena_total || s_cadena2;
							ELSE
								IF s_ascii = 49 THEN
								LET s_cadena2 = '1';
								LET s_long_cadena = ( s_long_cadena + 1);
								LET s_cadena_total = s_cadena_total || s_cadena2;
								ELSE
									IF s_ascii = 50 THEN
										LET s_cadena2 = '2';
										LET s_long_cadena = ( s_long_cadena + 1);
										LET s_cadena_total = s_cadena_total || s_cadena2;
									ELSE
										IF s_ascii = 51 THEN
										LET s_cadena2 = '3';
										LET s_long_cadena = ( s_long_cadena + 1);
										LET s_cadena_total = s_cadena_total || s_cadena2;
										ELSE
											IF s_ascii = 52 THEN
											LET s_cadena2 = '4';
											LET s_long_cadena = ( s_long_cadena + 1);
											LET s_cadena_total = s_cadena_total || s_cadena2;
											ELSE
												IF s_ascii = 53 THEN
												LET s_cadena2 = '5';
												LET s_long_cadena = ( s_long_cadena + 1);
												LET s_cadena_total = s_cadena_total || s_cadena2;
												ELSE
													IF s_ascii = 54 THEN
														LET s_cadena2 = '6';
														LET s_long_cadena = ( s_long_cadena + 1);
														LET s_cadena_total = s_cadena_total || s_cadena2;
													ELSE
														IF s_ascii = 55 THEN
														LET s_cadena2 = '7';
														LET s_long_cadena = ( s_long_cadena + 1);
														LET s_cadena_total = s_cadena_total || s_cadena2;
														ELSE
															IF s_ascii = 56 THEN
																LET s_cadena2 = '8';
																LET s_long_cadena = ( s_long_cadena + 1);
																LET s_cadena_total = s_cadena_total || s_cadena2;
															ELSE
																IF s_ascii = 57 THEN
																	LET s_cadena2 = '9';
																	LET s_long_cadena = ( s_long_cadena + 1);
																	LET s_cadena_total = s_cadena_total || s_cadena2;
																ELSE
																	LET s_cadena2 = '';
																	LET s_long_cadena = ( s_long_cadena + 1);
																END IF;
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
                         END IF;
						END IF 
                       END IF;
                      END IF;
                     END IF;
                    END IF;
                   END IF; 
                  END IF;
                 END IF;
                END IF;
               END IF;
              END IF;
             END IF;
            END IF;
           END IF;
          END IF;
         END IF;
        END IF;
       END IF;
      END IF; 
     END IF; 
    END WHILE;
   END IF;
  RETURN s_cadena_total;
 END;  

END PROCEDURE;