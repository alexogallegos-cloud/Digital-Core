package com.openpay.dashboard.channels;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : channels
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 6    LOC approx: 605
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ChnResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class ChnService223 {

    // Collaborators (match the graph call edges):
    private final ChnRepository074 chnRepository074;
    private final ChnService269 chnService269;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final StringUtils stringUtils;
    private final TokenizationService tokenizationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
