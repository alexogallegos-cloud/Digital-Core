package com.openpay.api.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 24    FAN-OUT : 3    LOC approx: 873
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class BinManagerService {

    // Collaborators (match the graph call edges):
    private final InfRepository075 infRepository075;
    private final JdbcReadGateway jdbcReadGateway;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
