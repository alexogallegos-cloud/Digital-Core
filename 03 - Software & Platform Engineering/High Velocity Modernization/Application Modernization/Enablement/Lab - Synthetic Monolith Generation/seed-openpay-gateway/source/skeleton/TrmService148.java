package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 5    FAN-OUT : 9    LOC approx: 216
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;

@Service
public class TrmService148 {

    // Collaborators (match the graph call edges):
    private final CryptoUtils cryptoUtils;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final SecService096 secService096;
    private final StringUtils stringUtils;
    private final TrmRepository006 trmRepository006;
    private final TrmRepository070 trmRepository070;
    private final TrmService103 trmService103;
    private final TrmService149 trmService149;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
