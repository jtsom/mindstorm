class ProjectScoresController < ApplicationController

  respond_to :html, :xml, :json

  before_action :authenticate

  def new
    @team = @current_competition.teams.find params[:team_id]
    @projectscore = ProjectScore.new
    respond_with(@team, @projectscore)
  end

  def index
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.project_scores)
  end

  def show
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.project_scores.find(params[:id]))
  end

  def create
    @team = @current_competition.teams.find(params[:team_id])
    @projectscore = @team.project_scores.build(scores_params)
    flash[:notice] = "Project score created" if @projectscore.save

    respond_with(@team, @projectscore, :location => @team)
  end

  def edit
    @team = @current_competition.teams.find(params[:team_id])
    @projectscore = @team.project_scores.find(params[:id])

    respond_with(@team, @projectscore)
  end

  def update
    @team = @current_competition.teams.find(params[:team_id])
    @project_score = @team.project_scores.find(params[:id]).update_attributes(scores_params)
    flash[:notice] = "Project score updated" if @project_score
    respond_with(@team, @project_score, :location => @team)
  end

  def destroy
    @team = @current_competition.teams.find(params[:team_id])
    score = @team.project_scores.find(params[:id])
    score.destroy
    flash[:notice] = "Project Score Entry team #{@team.fll_number} deleted."
    redirect_to @team
  end

  private
    def authenticate
      if current_competition == nil
        redirect_to root_url
      end
    end

    def scores_params
      params.require(:project_score).permit(:rank, :total_score, :r_problemID, :r_source, :r_analysis, :r_review, :r_comments,
                                      :i_teamsolution, :i_innovation, :i_implementation, :i_comments,
                                      :p_preseffective, :p_creativity, :p_sharing, :p_comments,
                                      :judge_name, :research, :innovative_solution, :presentation,
                                      :award_research, :award_innosolution, :award_presentation, :p_gj_comments, :p_ta_comments)
    end


end
