import { Injectable } from '@nestjs/common';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  // TODO: Implement authentication service
  
  login(loginDto: LoginDto) {
    // TODO: Implement JWT authentication
    return {
      access_token: 'todo-jwt-token',
      refresh_token: 'todo-refresh-token',
      user: {
        id: 'user123',
        email: loginDto.email,
        name: 'Dr. John Doe'
      }
    };
  }
}
