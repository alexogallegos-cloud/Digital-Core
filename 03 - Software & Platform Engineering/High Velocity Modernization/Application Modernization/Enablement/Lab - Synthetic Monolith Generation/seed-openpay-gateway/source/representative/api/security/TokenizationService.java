package com.openpay.api.security;

import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.shared.AuditContext;
import com.openpay.shared.CryptoUtils;
import com.openpay.shared.JdbcWriteGateway;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * ENABLER in-scope (seam) · component=API · domain=security · PCI · access=UPDATE.
 * Blast radius objetivo = 31 (ground-truth-enabler-seams.md) ↔ regression_scope
 * del fanout (tokenization-sys, wave 3, seam api-acl).
 *
 * Tokeniza el PAN: lo cifra contra el secreto del Vault y devuelve un token. Es de
 * los primeros que se extrae (wave 3) porque aisla el alcance PCI del resto del WAR.
 *
 * Anti-patrones plantados:
 *  - Muta el god DTO compartido (TransactionDTO.setCardToken) → acoplamiento por dato.
 *  - Hardcoded crypto/version params (regla congelada, riesgo de rotacion de llave).
 *  - Depende de VaultService (otro enabler) → dependencia entre seams: el orden de
 *    extraccion importa (Vault debe estar listo o stubbeado antes).
 */
@Service
public class TokenizationService {

    private final VaultService vaultService;          // enabler -> enabler (seam dep)

    // [PLANTADO · HARDCODED] version de esquema de token clavada en codigo
    private static final String TOKEN_SCHEME = "OPENPAY-TKN-V2";

    @Autowired
    public TokenizationService(VaultService vaultService) {
        this.vaultService = vaultService;
    }

    /** Tokeniza el PAN de una transaccion y lo escribe en el sistema de registro. */
    public ResponseEnvelope tokenize(TransactionDTO txn, AuditContext ctx) {
        String dek = vaultService.resolveDataKey(TOKEN_SCHEME);     // read del secreto
        String token = CryptoUtils.encryptDeterministic(/*pan*/ "", dek);

        // [PLANTADO · DTO-COUPLING] mutacion del DTO compartido:
        txn.setCardToken(token);

        JdbcWriteGateway.persist(ctx);   // [SINK] -> clasifica esta clase como 'update'
        return ResponseEnvelope.ok(token);
    }
}