// User types
export interface User {
  id: string;
  name: string;
  email: string;
  admin: boolean;
}

// Project types
export interface Project {
  id: string;
  name: string;
  description: string | null;
  tasks?: Task[];
}

// Task types
export const TaskStatus = {
  PENDING: 'PENDING',
  IN_PROGRESS: 'IN_PROGRESS',
  COMPLETED: 'COMPLETED',
  ARCHIVED: 'ARCHIVED',
} as const;

export type TaskStatusType = typeof TaskStatus[keyof typeof TaskStatus];

export interface Task {
  id: string;
  title: string;
  description: string | null;
  status: TaskStatusType;
  project?: Project;
  assignee?: User | null;
  assigneeType?: string | null;
  assigneeId?: string | null;
}

// Form types
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignupData {
  name: string;
  email: string;
  password: string;
  passwordConfirmation: string;
}

export interface ProjectFormData {
  name: string;
  description: string;
}

export interface TaskFormData {
  title: string;
  description: string;
  status: TaskStatusType;
  assigneeId?: string;
}

// API Response types
export interface AuthResponse {
  success: boolean;
  message?: string;
  user?: User;
}

export interface GraphQLError {
  message: string;
}

export interface MutationResponse<T> {
  data: T | null;
  errors: string[];
}