import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { TaskStatus } from '@prisma/client';

@Injectable()
export class TasksService {
  private readonly logger = new Logger(TasksService.name);

  constructor(private prisma: PrismaService) {}

  async create(userId: number, createTaskDto: CreateTaskDto) {
    const task = await this.prisma.task.create({
      data: {
        ...createTaskDto,
        userId,
      },
    });

    this.logger.log(`Task created: ${task.id} by user: ${userId}`);
    return task;
  }

  async findAll(userId: number) {
    return await this.prisma.task.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: number, userId: number) {
    const task = await this.prisma.task.findUnique({
      where: { id },
    });

    if (!task) {
      this.logger.warn(`Task not found: ${id}`);
      throw new NotFoundException(`Task with ID ${id} not found`);
    }

    if (task.userId !== userId) {
      this.logger.warn(`Unauthorized access attempt to task: ${id} by user: ${userId}`);
      throw new ForbiddenException('You do not have permission to access this task');
    }

    return task;
  }

  async update(id: number, userId: number, updateTaskDto: UpdateTaskDto) {
    await this.findOne(id, userId);

    const updatedTask = await this.prisma.task.update({
      where: { id },
      data: updateTaskDto,
    });

    this.logger.log(`Task updated: ${id} by user: ${userId}`);
    return updatedTask;
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);

    await this.prisma.task.delete({
      where: { id },
    });

    this.logger.log(`Task deleted: ${id} by user: ${userId}`);
    return {
      message: 'Task deleted successfully',
      taskId: id,
    };
  }

  async toggleStatus(id: number, userId: number) {
    const task = await this.findOne(id, userId);

    const newStatus =
      task.status === TaskStatus.PENDING
        ? TaskStatus.COMPLETED
        : TaskStatus.PENDING;

    const updatedTask = await this.prisma.task.update({
      where: { id },
      data: { status: newStatus },
    });

    this.logger.log(`Task status toggled: ${id} to ${newStatus} by user: ${userId}`);
    return updatedTask;
  }
}

