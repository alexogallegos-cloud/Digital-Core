package com.openpay.dashboard.channels;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : channels
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 2    FAN-OUT : 4    LOC approx: 790
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ChnRequest;
import com.openpay.dto.ChnResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class ChnService080 {

    // Collaborators (match the graph call edges):
    private final ChnRepository040 chnRepository040;
    private final ChnService072 chnService072;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
