import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client/react';
import { GET_PROJECTS } from '../graphql/queries';
import { CREATE_PROJECT } from '../graphql/mutations';
import { Layout } from '../components/Layout';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Modal } from '../components/Modal';
import { FormField } from '../components/FormField';
import { useIsAdmin } from '../hooks/useIsAdmin';
import type { Project, ProjectFormData } from '../types';

export const ProjectsListPage: React.FC = () => {
  const navigate = useNavigate();
  const isAdmin = useIsAdmin();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState<ProjectFormData>({
    name: '',
    description: '',
  });

  const { loading, error, data, refetch } = useQuery<{ projects: Project[] }>(GET_PROJECTS);
  const [createProject, { loading: creating }] = useMutation<{ createProject: { project: Project | null; errors: string[] } }>(CREATE_PROJECT);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const result = await createProject({
        variables: {
          input: formData,
        },
      });

      if (result.data?.createProject?.errors && result.data.createProject.errors.length > 0) {
        alert(result.data.createProject.errors.join(', '));
      } else {
        setFormData({ name: '', description: '' });
        setIsModalOpen(false);
        refetch();
      }
    } catch (err) {
      alert('Failed to create project');
      console.error(err);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-96">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading projects...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <div className="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
          Error loading projects: {error.message}
        </div>
      </Layout>
    );
  }

  const projects: Project[] = data?.projects || [];

  return (
    <Layout>
      <div className="space-y-8">
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-4xl font-bold text-gray-900">Projects</h1>
            <p className="mt-2 text-gray-600">
              Manage your development projects and tasks
            </p>
          </div>
          {isAdmin && (
            <Button onClick={() => setIsModalOpen(true)} variant="primary">
              + New Project
            </Button>
          )}
        </div>

        {/* Projects Grid */}
        {projects.length === 0 ? (
          <Card className="text-center py-12">
            <p className="text-gray-500 text-lg">
              No projects yet. {isAdmin && 'Create your first project!'}
            </p>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project) => (
              <Card
                key={project.id}
                onClick={() => navigate(`/projects/${project.id}`)}
                className="cursor-pointer hover:shadow-2xl"
              >
                <h3 className="text-xl font-bold text-gray-900 mb-2">
                  {project.name}
                </h3>
                <p className="text-gray-600 mb-4 line-clamp-2">
                  {project.description || 'No description provided'}
                </p>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-500">
                    {project.tasks?.length || 0} tasks
                  </span>
                  <span className="text-primary-600 font-medium">
                    View Details →
                  </span>
                </div>
              </Card>
            ))}
          </div>
        )}

        {/* Create Project Modal */}
        <Modal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          title="Create New Project"
        >
          <form onSubmit={handleSubmit}>
            <FormField
              label="Project Name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder="Enter project name"
              required
            />

            <FormField
              label="Description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              placeholder="Enter project description"
              as="textarea"
            />

            <div className="flex justify-end space-x-3 mt-6">
              <Button
                type="button"
                variant="secondary"
                onClick={() => setIsModalOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit" variant="primary" disabled={creating}>
                {creating ? 'Creating...' : 'Create Project'}
              </Button>
            </div>
          </form>
        </Modal>
      </div>
    </Layout>
  );
};