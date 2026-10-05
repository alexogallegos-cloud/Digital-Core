import { NextRequest, NextResponse } from 'next/server';
import { seedDynamo } from '@/lib/dynamodb';

const SECRET = 'seed-coppel-2026';

export async function POST(req: NextRequest) {
  const key = req.nextUrl.searchParams.get('key');
  if (key !== SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const result = await seedDynamo();
  return NextResponse.json(result);
}

export async function GET() {
  return NextResponse.json({
    instructions: 'POST /api/seed?key=seed-coppel-2026 to seed DynamoDB with the product catalog.',
  });
}
