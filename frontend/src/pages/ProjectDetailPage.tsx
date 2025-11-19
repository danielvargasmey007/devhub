import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client/react';
import { GET_PROJECT } from '../graphql/queries';
import { CREATE_TASK, UPDATE_TASK, UPDATE_TASK_STATUS } from '../graphql/mutations';
import { Layout } from '../components/Layout';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormField } from '../components/FormField';
import { useIsAdmin } from '../hooks/useIsAdmin';
import { TaskStatus } from '../types';
import type { Task, TaskFormData, Project } from '../types';

const STATUS_COLORS = {
  PENDING: 'bg-gray-100 text-gray-800',
  IN_PROGRESS: 'bg-blue-100 text-blue-800',
  COMPLETED: 'bg-green-100 text-green-800',
  ARCHIVED: 'bg-purple-100 text-purple-800',
};

export const ProjectDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isAdmin = useIsAdmin();

  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);

  const [createFormData, setCreateFormData] = useState<TaskFormData>({
    title: '',
    description: '',
    status: TaskStatus.PENDING,
  });

  const [editFormData, setEditFormData] = useState<TaskFormData>({
    title: '',
    description: '',
    status: TaskStatus.PENDING,
  });

  const { loading, error, data, refetch } = useQuery<{ project: Project }>(GET_PROJECT, {
    variables: { id },
  });

  const [createTask, { loading: creating }] = useMutation<{ createTask: { task: Task | null; errors: string[] } }>(CREATE_TASK);
  const [updateTask, { loading: updating }] = useMutation<{ updateTask: { task: Task | null; errors: string[] } }>(UPDATE_TASK);
  const [updateTaskStatus] = useMutation<{ updateTaskStatus: { task: Task | null; errors: string[] } }>(UPDATE_TASK_STATUS);

  const handleCreateChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setCreateFormData({
      ...createFormData,
      [e.target.name]: e.target.value,
    });
  };

  const handleEditChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setEditFormData({
      ...editFormData,
      [e.target.name]: e.target.value,
    });
  };

  const handleCreateSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const result = await createTask({
        variables: {
          input: {
            projectId: id,
            ...createFormData,
          },
        },
      });

      if (result.data?.createTask?.errors && result.data.createTask.errors.length > 0) {
        alert(result.data.createTask.errors.join(', '));
      } else {
        setCreateFormData({
          title: '',
          description: '',
          status: TaskStatus.PENDING,
        });
        setIsCreateModalOpen(false);
        refetch();
      }
    } catch (err) {
      alert('Failed to create task');
      console.error(err);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedTask) return;

    try {
      // Separate status from other fields - updateTask doesn't accept status
      const { status, ...taskData } = editFormData;

      // Update task attributes (title, description, etc.)
      const result = await updateTask({
        variables: {
          input: {
            id: selectedTask.id,
            ...taskData,
          },
        },
      });

      if (result.data?.updateTask?.errors && result.data.updateTask.errors.length > 0) {
        alert(result.data.updateTask.errors.join(', '));
        return;
      }

      // If status changed, update it separately
      if (status !== selectedTask.status) {
        const statusResult = await updateTaskStatus({
          variables: {
            input: {
              id: selectedTask.id,
              status: status,
            },
          },
        });

        if (statusResult.data?.updateTaskStatus?.errors && statusResult.data.updateTaskStatus.errors.length > 0) {
          alert(statusResult.data.updateTaskStatus.errors.join(', '));
          return;
        }
      }

      setIsEditModalOpen(false);
      setSelectedTask(null);
      refetch();
    } catch (err) {
      alert('Failed to update task');
      console.error(err);
    }
  };

  const openEditModal = (task: Task) => {
    setSelectedTask(task);
    setEditFormData({
      title: task.title,
      description: task.description || '',
      status: task.status,
    });
    setIsEditModalOpen(true);
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-96">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-accent-500 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading project...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (error || !data?.project) {
    return (
      <Layout>
        <div className="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
          Error loading project: {error?.message || 'Project not found'}
        </div>
      </Layout>
    );
  }

  const project = data.project;
  const tasks: Task[] = project.tasks || [];

  return (
    <Layout>
      <div className="space-y-8">
        {/* Header */}
        <div>
          <Button
            variant="secondary"
            onClick={() => navigate('/projects')}
            className="mb-4"
          >
            ← Back to Projects
          </Button>

          <div className="flex justify-between items-start">
            <div>
              <h1 className="text-4xl font-bold text-gray-900">
                {project.name}
              </h1>
              <p className="mt-2 text-gray-600 text-lg">
                {project.description || 'No description'}
              </p>
            </div>
            {isAdmin && (
              <Button onClick={() => setIsCreateModalOpen(true)} variant="primary">
                + New Task
              </Button>
            )}
          </div>
        </div>

        {/* Tasks */}
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Tasks</h2>
          {tasks.length === 0 ? (
            <Card className="text-center py-12">
              <p className="text-gray-500 text-lg">
                No tasks yet. {isAdmin && 'Create your first task!'}
              </p>
            </Card>
          ) : (
            <div className="space-y-4">
              {tasks.map((task) => (
                <Card key={task.id} className="hover:shadow-2xl">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <h3 className="text-xl font-bold text-gray-900">
                          {task.title}
                        </h3>
                        <span
                          className={`px-3 py-1 rounded-full text-xs font-medium ${
                            STATUS_COLORS[task.status]
                          }`}
                        >
                          {task.status.replace('_', ' ')}
                        </span>
                      </div>
                      <p className="text-gray-600 mb-3">
                        {task.description || 'No description'}
                      </p>
                      {task.assignee && (
                        <p className="text-sm text-gray-500">
                          Assigned to: {task.assignee.name}
                        </p>
                      )}
                    </div>
                    {isAdmin && (
                      <Button
                        variant="secondary"
                        onClick={() => openEditModal(task)}
                        className="ml-4"
                      >
                        Edit
                      </Button>
                    )}
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Create Task Modal */}
        <Modal
          isOpen={isCreateModalOpen}
          onClose={() => setIsCreateModalOpen(false)}
          title="Create New Task"
        >
          <form onSubmit={handleCreateSubmit}>
            <FormField
              label="Task Title"
              name="title"
              value={createFormData.title}
              onChange={handleCreateChange}
              placeholder="Enter task title"
              required
            />

            <FormField
              label="Description"
              name="description"
              value={createFormData.description}
              onChange={handleCreateChange}
              placeholder="Enter task description"
              as="textarea"
            />

            <FormField
              label="Status"
              name="status"
              value={createFormData.status}
              onChange={handleCreateChange}
              as="select"
              required
            >
              <option value={TaskStatus.PENDING}>Pending</option>
              <option value={TaskStatus.IN_PROGRESS}>In Progress</option>
              <option value={TaskStatus.COMPLETED}>Completed</option>
              <option value={TaskStatus.ARCHIVED}>Archived</option>
            </FormField>

            <div className="flex justify-end space-x-3 mt-6">
              <Button
                type="button"
                variant="secondary"
                onClick={() => setIsCreateModalOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit" variant="primary" disabled={creating}>
                {creating ? 'Creating...' : 'Create Task'}
              </Button>
            </div>
          </form>
        </Modal>

        {/* Edit Task Modal */}
        <Modal
          isOpen={isEditModalOpen}
          onClose={() => setIsEditModalOpen(false)}
          title="Edit Task"
        >
          <form onSubmit={handleEditSubmit}>
            <FormField
              label="Task Title"
              name="title"
              value={editFormData.title}
              onChange={handleEditChange}
              placeholder="Enter task title"
              required
            />

            <FormField
              label="Description"
              name="description"
              value={editFormData.description}
              onChange={handleEditChange}
              placeholder="Enter task description"
              as="textarea"
            />

            <FormField
              label="Status"
              name="status"
              value={editFormData.status}
              onChange={handleEditChange}
              as="select"
              required
            >
              <option value={TaskStatus.PENDING}>Pending</option>
              <option value={TaskStatus.IN_PROGRESS}>In Progress</option>
              <option value={TaskStatus.COMPLETED}>Completed</option>
              <option value={TaskStatus.ARCHIVED}>Archived</option>
            </FormField>

            <div className="flex justify-end space-x-3 mt-6">
              <Button
                type="button"
                variant="secondary"
                onClick={() => setIsEditModalOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit" variant="primary" disabled={updating}>
                {updating ? 'Updating...' : 'Update Task'}
              </Button>
            </div>
          </form>
        </Modal>
      </div>
    </Layout>
  );
};