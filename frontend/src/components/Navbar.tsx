import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { useDispatch } from 'react-redux';
import { logout } from '../store/authSlice';
import type { AppDispatch } from '../store';
import { Button } from './Button';

export const Navbar: React.FC = () => {
  const { isAuthenticated, currentUser } = useAuth();
  const dispatch = useDispatch<AppDispatch>();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await dispatch(logout());
    navigate('/login');
  };

  return (
    <nav className="bg-navy-950 shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center">
            <span className="text-2xl font-bold text-white">
              Dev<span className="text-accent-400">Hub</span>
            </span>
          </Link>

          {/* Navigation Links */}
          <div className="flex items-center space-x-6">
            {isAuthenticated ? (
              <>
                <Link
                  to="/projects"
                  className="text-gray-300 hover:text-white transition-colors duration-200 font-medium"
                >
                  Projects
                </Link>
                <div className="flex items-center space-x-4">
                  <span className="text-gray-300 text-sm">
                    {currentUser?.email}
                    {currentUser?.admin && (
                      <span className="ml-2 px-2 py-1 bg-accent-500 text-white text-xs rounded-full">
                        Admin
                      </span>
                    )}
                  </span>
                  <Button onClick={handleLogout} variant="secondary">
                    Logout
                  </Button>
                </div>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="text-gray-300 hover:text-white transition-colors duration-200 font-medium"
                >
                  Login
                </Link>
                <Link to="/signup">
                  <Button variant="primary">Sign Up</Button>
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};