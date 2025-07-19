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
    # Only return jobs that user's entity has access to
    return @jobs = [] unless @current_context&.current_entity

    entity_type = @current_context.current_entity.type
    entity_id = @current_context.current_entity.id

    @jobs = case entity_type
    when "Agency"
              Job.includes(:agency, :client, :locum).where(agency_id: entity_id)
    when "Client"
              Job.includes(:agency, :client, :locum).where(client_id: entity_id)
    when "Locum"
              Job.includes(:agency, :client, :locum).where(locum_id: entity_id)
    else
              Job.none
    end
  end

  def job_params
    params.require(:job).permit(:start, :end, :break_minutes, :actual_start, :actual_end, :actual_break_minutes, :notes_job, :notes_client, :notes_agency, :agency_id, :client_id, :locum_id)
  end
end
