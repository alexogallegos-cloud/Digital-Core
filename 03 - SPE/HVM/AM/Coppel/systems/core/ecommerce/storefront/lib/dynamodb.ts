import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, QueryCommand, BatchWriteCommand } from '@aws-sdk/lib-dynamodb';
import { PRODUCTS, Product } from './products';

const TABLE_NAME = 'coppel-products';
const REGION = process.env.AWS_REGION || 'us-east-1';

const client = new DynamoDBClient({ region: REGION });
export const ddb = DynamoDBDocumentClient.from(client);

export async function getProductsFromDynamo(subcategory: string): Promise<Product[]> {
  try {
    const res = await ddb.send(new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: 'subcategory-index',
      KeyConditionExpression: 'subcategory = :sc',
      ExpressionAttributeValues: { ':sc': subcategory },
    }));
    return (res.Items || []) as Product[];
  } catch {
    // DynamoDB not yet seeded — fall back to local data
    return PRODUCTS.filter(p => p.subcategory === subcategory);
  }
}

export async function seedDynamo(): Promise<{ seeded: number }> {
  const items = PRODUCTS.map(p => ({ PutRequest: { Item: p } }));
  const chunks = [];
  for (let i = 0; i < items.length; i += 25) chunks.push(items.slice(i, i + 25));
  for (const chunk of chunks) {
    await ddb.send(new BatchWriteCommand({ RequestItems: { [TABLE_NAME]: chunk } }));
  }
  return { seeded: PRODUCTS.length };
}
