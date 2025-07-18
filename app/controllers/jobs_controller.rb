class JobsController < ApplicationController
  before_action :get_jobs, only: %i[index update]
  def index
    render inertia: "jobs/index", props: {
      jobs: @jobs
    }
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
    job = Job.find(params[:id])
    if job.update(job_params)
      flash[:success] = "Job updated"
    else
      flash[:error] = job.errors.full_messages.join(", ")
    end

    render inertia: "jobs/index", props: {
      jobs: @jobs
    }
  end

  def destroy
  end

  private

  def get_jobs
    @jobs = Job.includes(:agency, :client, :locum).all
  end

  def job_params
    params.require(:job).permit(:start, :end, :break_minutes, :actual_start, :actual_end, :actual_break_minutes, :notes_job, :notes_client, :notes_agency, :agency_id, :client_id, :locum_id)
  end
end
