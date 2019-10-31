class CorevalueScoresController < ApplicationController

  respond_to :html, :xml, :json
  before_action :authenticate
  def new
    @team = @current_competition.teams.find params[:team_id]
    @corevalue_score = CorevalueScore.new
    respond_with(@team, @corevalue_score)
  end

  def index
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.corevalue_scores)
  end

  def show
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.corevalue_scores.find(params[:id]))
  end

  def create
    @team = @current_competition.teams.find(params[:team_id])
    @corevalue_score = @team.corevalue_scores.build(scores_params)
    flash[:notice] = "Core Values score created" if @corevalue_score.save

    respond_with(@team, @corevalue_score, :location => @team)
  end

  def edit
    @team = @current_competition.teams.find(params[:team_id])
    @corevalue_score = @team.corevalue_scores.find(params[:id])

    respond_with(@team, @corevalue_score)
  end

  def update
    team = @current_competition.teams.find(params[:team_id])
    corevalue_score = team.corevalue_scores.find(params[:id]).update_attributes(scores_params)
    flash[:notice] = "Core Values score updated" if corevalue_score
    respond_with(team, corevalue_score, :location => team)
  end

  def destroy
    @team = @current_competition.teams.find(params[:team_id])
    score = @team.corevalue_scores.find(params[:id])
    score.destroy
    flash[:notice] = "Core Value Score Entry team #{@team.fll_number} deleted."
    redirect_to @team
  end

  private
    def authenticate
      if current_competition == nil
        redirect_to root_url
      end
    end

    def scores_params
      params.require(:corevalue_score).permit(:i_discovery,:i_team_spirit, :i_integration, :i_comments,
                    :t_effectiveness, :t_efficiency, :t_initiative, :t_comments,
                    :g_inclusion, :g_respect, :g_coopertition, :g_comments,
                    :total_score, :judge_name, :inspiration, :teamwork, :grac_prof,
                    :award_inspiration, :award_teamwork, :award_gracprof, :cv_gj_comments, :cv_ta_coments)
    end
end
