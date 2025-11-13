class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/:id
  def show
    @tasks = @project.tasks
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/:id/edit
  def edit
  end

  # POST /projects
  def create
    creator = Core::Projects::Creator.new(project_params)

    if creator.call
      redirect_to creator.project, notice: "Project was successfully created."
    else
      @project = creator.project
      flash.now[:alert] = creator.errors.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:id
  def update
    updater = Core::Projects::Updater.new(@project, project_params)

    if updater.call
      redirect_to @project, notice: "Project was successfully updated."
    else
      flash.now[:alert] = updater.errors.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:id
  def destroy
    destroyer = Core::Projects::Destroyer.new(@project)

    if destroyer.call
      redirect_to projects_url, notice: "Project was successfully deleted."
    else
      flash[:alert] = destroyer.errors.join(", ")
      redirect_to @project
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end