class JobsController < ApplicationController
  def index
    @jobs = Job.includes(:agency, :client, :locum).all

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
  end

  def destroy
  end
end
