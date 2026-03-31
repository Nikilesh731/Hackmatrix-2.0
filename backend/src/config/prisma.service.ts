import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    // Temporarily disable database connection for CORS testing
    console.log('Database connection temporarily disabled for testing');
    // await this.$connect();
  }

  async onModuleDestroy() {
    // await this.$disconnect();
  }
}
