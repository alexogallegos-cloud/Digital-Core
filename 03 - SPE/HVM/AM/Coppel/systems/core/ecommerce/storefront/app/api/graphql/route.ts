import { ApolloServer } from '@apollo/server';
import { NextRequest, NextResponse } from 'next/server';
import { getProductsFromDynamo } from '@/lib/dynamodb';
import { searchProducts } from '@/lib/products';

const typeDefs = `#graphql
  """
  Producto del catálogo Coppel.
  Cada campo proviene de un subgrafo diferente en la federación Apollo.
  """
  type Product {
    id: String!
    brand: String!
    name: String!
    price: Float!           # subgrafo: precios
    oldPrice: Float!        # subgrafo: precios
    emoji: String!
    isOffer: Boolean!       # subgrafo: precios
    isInternational: Boolean!
    subgraph: String!
    category: String!
    subcategory: String!    # subgrafo: catálogo
  }

  type Query {
    """Devuelve productos por subcategoría — subgrafo catálogo + búsqueda"""
    products(subcategory: String!): [Product!]!
    """Búsqueda de texto libre — subgrafo búsqueda (LucidWorks simulado)"""
    search(query: String!): [Product!]!
  }
`;

const resolvers = {
  Query: {
    products: async (_: unknown, args: { subcategory: string }) =>
      getProductsFromDynamo(args.subcategory),
    search: async (_: unknown, args: { query: string }) =>
      searchProducts(args.query),
  },
};

// Singleton para evitar cold-start en cada request
let server: ApolloServer | null = null;

async function getServer(): Promise<ApolloServer> {
  if (!server) {
    server = new ApolloServer({ typeDefs, resolvers });
    await server.start();
  }
  return server;
}

export async function POST(req: NextRequest) {
  const apollo = await getServer();
  const body = await req.json();

  const result = await apollo.executeOperation({
    query: body.query,
    variables: body.variables ?? {},
    operationName: body.operationName,
  });

  if (result.body.kind === 'single') {
    return NextResponse.json(result.body.singleResult);
  }

  return NextResponse.json(
    { errors: [{ message: 'Incremental delivery not supported' }] },
    { status: 400 }
  );
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/graphql',
    method: 'POST',
    example: {
      query: '{ products(subcategory: "tv-video") { id brand name price subgraph } }',
    },
  });
}
