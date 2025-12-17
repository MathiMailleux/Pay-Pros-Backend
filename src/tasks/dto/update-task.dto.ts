import { IsString, IsOptional, IsEnum, IsDateString, MinLength, MaxLength } from 'class-validator';
import { TaskStatus } from '@prisma/client';

export class UpdateTaskDto {
  @IsString({ message: 'Title must be a string' })
  @MinLength(1, { message: 'Title cannot be empty' })
  @MaxLength(200, { message: 'Title cannot exceed 200 characters' })
  @IsOptional()
  title?: string;

  @IsString({ message: 'Description must be a string' })
  @IsOptional()
  @MaxLength(2000, { message: 'Description cannot exceed 2000 characters' })
  description?: string;

  @IsDateString({}, { message: 'Due date must be a valid date' })
  @IsOptional()
  dueDate?: string;

  @IsEnum(TaskStatus, { message: 'Status must be PENDING or COMPLETED' })
  @IsOptional()
  status?: TaskStatus;
}

