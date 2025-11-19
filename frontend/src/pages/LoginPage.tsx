import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import type { AppDispatch } from '../store';
import { login, clearError } from '../store/authSlice';
import { useAuth } from '../hooks/useAuth';
import { FormField } from '../components/FormField';
import { Button } from '../components/Button';
import { Card } from '../components/Card';

export const LoginPage: React.FC = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  const dispatch = useDispatch<AppDispatch>();
  const navigate = useNavigate();
  const { loading, isAuthenticated } = useAuth();

  useEffect(() => {
    console.log('LoginPage - isAuthenticated changed:', isAuthenticated);
    if (isAuthenticated) {
      console.log('LoginPage - Navigating to /projects because isAuthenticated is true');
      navigate('/projects');
    }
  }, [isAuthenticated, navigate]);

  useEffect(() => {
    return () => {
      dispatch(clearError());
    };
  }, [dispatch]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log('LoginPage - Form submitted with:', { email: formData.email, password: '***' });
    const result = await dispatch(login(formData));
    console.log('LoginPage - Login result:', result);
    if (login.fulfilled.match(result)) {
      console.log('LoginPage - Login successful, navigating to /projects');
      navigate('/projects');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-navy-900 via-navy-800 to-primary-900 py-12 px-4 sm:px-6 lg:px-8">
      <Card className="max-w-md w-full space-y-8">
        <div>
          <h2 className="text-center text-4xl font-extrabold text-gray-900 mb-35">
            Welcome to <span className="text-primary-500">DevHub</span>
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Sign in to your account
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4">
            <FormField
              label="Email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="you@arkusnexus.com"
              required
            />

            <FormField
              label="Password"
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="Enter your password"
              required
            />
          </div>

          <div className="mb-20">
            <Button
              type="submit"
              variant="primary"
              disabled={loading}
              className="w-full"
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </div>

          <div className="text-center mt-8">
              <p className="mt-11 text-center text-sm text-gray-600">
                  Made with Love for
              </p>
              <div className="flex justify-center">
                  <img
                      src="/images/arkus-logo.webp"
                      alt="Arkus Nexus"
                      className="h-4 w-auto"
                  />
              </div>
          </div>
        </form>
      </Card>
    </div>
  );
};