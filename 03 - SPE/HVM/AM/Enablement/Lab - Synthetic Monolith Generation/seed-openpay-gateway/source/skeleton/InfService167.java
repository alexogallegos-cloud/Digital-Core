package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 5    FAN-OUT : 8    LOC approx: 411
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService167 {

    // Collaborators (match the graph call edges):
    private final InfRepository039 infRepository039;
    private final InfService063 infService063;
    private final InfService214 infService214;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final MerService011 merService011;
    private final StringUtils stringUtils;
    private final TokenizationService tokenizationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
