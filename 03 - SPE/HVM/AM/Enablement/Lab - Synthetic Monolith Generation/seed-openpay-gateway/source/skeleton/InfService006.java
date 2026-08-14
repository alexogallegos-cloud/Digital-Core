package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 13    FAN-OUT : 8    LOC approx: 332
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService006 {

    // Collaborators (match the graph call edges):
    private final AuditLogger auditLogger;
    private final InfRepository004 infRepository004;
    private final InfRepository034 infRepository034;
    private final InfService063 infService063;
    private final InfService195 infService195;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
