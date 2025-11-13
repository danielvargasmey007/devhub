class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  # GET /projects/:project_id/tasks
  def index
    @tasks = @project.tasks
  end

  # GET /projects/:project_id/tasks/:id
  def show
  end

  # GET /projects/:project_id/tasks/new
  def new
    @task = @project.tasks.build
  end

  # GET /projects/:project_id/tasks/:id/edit
  def edit
  end

  # POST /projects/:project_id/tasks
  def create
    creator = Core::Tasks::Creator.new(@project, task_params)

    if creator.call
      redirect_to project_task_path(@project, creator.task), notice: "Task was successfully created."
    else
      @task = creator.task
      flash.now[:alert] = creator.errors.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:project_id/tasks/:id
  def update
    # Use StatusUpdater service if status is being changed
    if task_params[:status].present? && task_params[:status] != @task.status
      updater = Core::Tasks::StatusUpdater.new(@task, task_params[:status])
      if updater.call
        redirect_to project_task_path(@project, @task), notice: "Task status was successfully updated."
      else
        flash.now[:alert] = updater.errors.join(", ")
        render :edit, status: :unprocessable_entity
      end
    else
      # Use regular Updater for non-status changes
      updater = Core::Tasks::Updater.new(@task, task_params)
      if updater.call
        redirect_to project_task_path(@project, @task), notice: "Task was successfully updated."
      else
        flash.now[:alert] = updater.errors.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end
  end

  # DELETE /projects/:project_id/tasks/:id
  def destroy
    destroyer = Core::Tasks::Destroyer.new(@task)

    if destroyer.call
      redirect_to project_path(@project), notice: "Task was successfully deleted."
    else
      flash[:alert] = destroyer.errors.join(", ")
      redirect_to project_task_path(@project, @task)
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :assignee_type, :assignee_id)
  end
end