# DevHub Frontend

React 18 + TypeScript frontend for DevHub project management platform.

## Tech Stack

- **React 18** + TypeScript + Vite
- **Redux Toolkit** - Authentication state
- **Apollo Client 4** - GraphQL API
- **React Router v6** - Routing with protected routes
- **Tailwind CSS v3** - Styling

## Project Structure

```
src/
├── api/          # REST (auth) and GraphQL clients
├── components/   # Reusable UI components
├── graphql/      # Queries and mutations
├── hooks/        # useAuth, useIsAdmin
├── pages/        # Login, Signup, Projects, ProjectDetail
├── store/        # Redux auth slice
└── types/        # TypeScript definitions
```

## Setup

```bash
npm install
npm run dev    # http://localhost:5173
```

Backend must be running on `localhost:3000`.