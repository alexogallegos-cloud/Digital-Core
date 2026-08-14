package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 14    FAN-OUT : 5    LOC approx: 178
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService028 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final InfRepository075 infRepository075;
    private final InfService006 infService006;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
