package com.openpay.api.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : security
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 3    FAN-OUT : 7    LOC approx: 765
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecEntity;

@Service
public class SecService013 {

    // Collaborators (match the graph call edges):
    private final ApiKeyService apiKeyService;
    private final CryptoUtils cryptoUtils;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final SecRepository035 secRepository035;
    private final SecRepository078 secRepository078;
    private final SecService130 secService130;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
